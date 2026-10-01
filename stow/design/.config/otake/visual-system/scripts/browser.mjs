// ヘッドレスChromeをDevTools Protocolのパイプ（--remote-debugging-pipe）で操作する最小実装。
// WebSocketやpuppeteerに依存せず、Node 20以降で動く。

import { spawn, spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { resolve } from "node:path";

/** 1コマンドの応答待ちの上限。重いページの描画とスクリーンショットを含めても通常は数秒で終わる */
const COMMAND_TIMEOUT_MS = 30_000;

/** ChromiumのPDF・画像変換に使うブラウザを探す。見つからなければ空文字 */
export function browserExecutable() {
  if (
    process.env.PUPPETEER_EXECUTABLE_PATH &&
    existsSync(process.env.PUPPETEER_EXECUTABLE_PATH)
  ) {
    return process.env.PUPPETEER_EXECUTABLE_PATH;
  }
  for (const commandName of [
    "google-chrome",
    "chromium",
    "chromium-browser",
    "brave-browser",
    "microsoft-edge",
  ]) {
    const result = spawnSync("which", [commandName], { encoding: "utf8" });
    if (result.status === 0 && result.stdout.trim()) {
      return result.stdout.trim();
    }
  }
  for (const [application, executable] of [
    ["Google Chrome.app", "Google Chrome"],
    ["Chromium.app", "Chromium"],
    ["Brave Browser.app", "Brave Browser"],
    ["Microsoft Edge.app", "Microsoft Edge"],
  ]) {
    const candidate = resolve(
      "/",
      "Applications",
      application,
      "Contents",
      "MacOS",
      executable,
    );
    if (existsSync(candidate)) {
      return candidate;
    }
  }
  return "";
}

class CdpPipe {
  constructor(child) {
    this.child = child;
    this.nextId = 1;
    this.pending = new Map();
    this.listeners = new Set();
    this.buffer = Buffer.alloc(0);
    child.stdio[4].on("data", (chunk) => this.receive(chunk));
    child.on("exit", (code) => {
      for (const { reject, timer } of this.pending.values()) {
        clearTimeout(timer);
        reject(new Error(`Chromeが終了しました（code ${code}）`));
      }
      this.pending.clear();
    });
  }

  receive(chunk) {
    this.buffer = Buffer.concat([this.buffer, chunk]);
    let end = this.buffer.indexOf(0);
    while (end !== -1) {
      const message = JSON.parse(this.buffer.subarray(0, end).toString("utf8"));
      this.buffer = this.buffer.subarray(end + 1);
      if (message.id && this.pending.has(message.id)) {
        const { resolve: done, reject, timer } = this.pending.get(message.id);
        clearTimeout(timer);
        this.pending.delete(message.id);
        if (message.error) {
          reject(new Error(`${message.error.message}${message.error.data ? `: ${message.error.data}` : ""}`));
        } else {
          done(message.result);
        }
      } else if (message.method) {
        for (const listener of [...this.listeners]) {
          listener(message);
        }
      }
      end = this.buffer.indexOf(0);
    }
  }

  send(method, params = {}, sessionId) {
    const id = this.nextId;
    this.nextId += 1;
    const message = { id, method, params, ...(sessionId ? { sessionId } : {}) };
    return new Promise((done, reject) => {
      const timer = setTimeout(() => {
        this.pending.delete(id);
        reject(new Error(`${method} が${COMMAND_TIMEOUT_MS / 1000}秒以内に応答しません`));
      }, COMMAND_TIMEOUT_MS);
      this.pending.set(id, { resolve: done, reject, timer });
      this.child.stdio[3].write(`${JSON.stringify(message)}\0`);
    });
  }

  waitFor(method, predicate = () => true) {
    return new Promise((done, reject) => {
      const timer = setTimeout(() => {
        this.listeners.delete(listener);
        reject(new Error(`${method} を${COMMAND_TIMEOUT_MS / 1000}秒以内に受信できません`));
      }, COMMAND_TIMEOUT_MS);
      const listener = (message) => {
        if (message.method === method && predicate(message)) {
          clearTimeout(timer);
          this.listeners.delete(listener);
          done(message.params);
        }
      };
      this.listeners.add(listener);
    });
  }
}

/**
 * ヘッドレスChromeを起動し、1枚のページを操作する関数を渡す。
 * @param {(page: {send: Function, evaluate: Function, screenshot: Function}) => Promise<any>} task
 */
export async function withPage(url, viewport, task) {
  const executable = browserExecutable();
  if (!executable) {
    throw new Error(
      "Chrome系ブラウザが見つかりません（PUPPETEER_EXECUTABLE_PATHで指定できます）",
    );
  }
  const profileDir = mkdtempSync(resolve(tmpdir(), "ovs-chrome-"));
  const flags = [
    "--headless=new",
    "--remote-debugging-pipe",
    `--user-data-dir=${profileDir}`,
    "--no-first-run",
    "--no-default-browser-check",
    "--disable-extensions",
    "--disable-background-networking",
    "--disable-sync",
    "--hide-scrollbars",
    "--mute-audio",
    "--allow-file-access-from-files",
  ];
  // GitHub ActionsのUbuntuはユーザー名前空間の制限でサンドボックスを起動できない
  if (process.env.CI === "true" || process.env.OVS_CHROME_NO_SANDBOX === "1") {
    flags.push("--no-sandbox");
  }
  const child = spawn(executable, [...flags, "about:blank"], {
    stdio: ["ignore", "ignore", "pipe", "pipe", "pipe"],
  });
  let stderr = "";
  child.stderr.on("data", (chunk) => {
    stderr = `${stderr}${chunk}`.slice(-4000);
  });
  const spawnError = new Promise((_, reject) => {
    child.once("error", (error) => reject(new Error(`Chromeを起動できません: ${error.message}`)));
  });
  const cdp = new CdpPipe(child);
  try {
    const run = (async () => {
      const { targetId } = await cdp.send("Target.createTarget", { url: "about:blank" });
      const { sessionId } = await cdp.send("Target.attachToTarget", { targetId, flatten: true });
      const send = (method, params) => cdp.send(method, params, sessionId);
      await send("Page.enable");
      await send("Emulation.setDeviceMetricsOverride", {
        width: viewport.width,
        height: viewport.height,
        deviceScaleFactor: 1,
        mobile: false,
      });
      const loaded = cdp.waitFor("Page.loadEventFired", (message) => message.sessionId === sessionId);
      const navigation = await send("Page.navigate", { url });
      if (navigation.errorText) {
        throw new Error(`${url} を開けません: ${navigation.errorText}`);
      }
      await loaded;
      const evaluate = async (expression) => {
        const response = await send("Runtime.evaluate", {
          expression,
          awaitPromise: true,
          returnByValue: true,
        });
        if (response.exceptionDetails) {
          const detail = response.exceptionDetails.exception?.description ?? response.exceptionDetails.text;
          throw new Error(`ページ内の処理に失敗しました: ${detail}`);
        }
        return response.result.value;
      };
      const screenshot = async (clip) => {
        const { data } = await send("Page.captureScreenshot", {
          format: "png",
          clip: { ...clip, scale: clip.scale ?? 1 },
          captureBeyondViewport: true,
        });
        return Buffer.from(data, "base64");
      };
      return task({ send, evaluate, screenshot });
    })();
    return await Promise.race([run, spawnError]);
  } catch (error) {
    if (stderr.trim() && /Chromeが終了|起動できません/.test(error.message)) {
      error.message = `${error.message}\n${stderr.trim().split("\n").slice(-5).join("\n")}`;
    }
    throw error;
  } finally {
    const exited = new Promise((done) => {
      if (child.exitCode !== null) done();
      else child.once("exit", done);
    });
    try {
      await Promise.race([
        cdp.send("Browser.close"),
        new Promise((done) => setTimeout(done, 2000)),
      ]);
    } catch {
      // 既に終了している
    }
    await Promise.race([exited, new Promise((done) => setTimeout(done, 2000))]);
    if (child.exitCode === null) {
      child.kill("SIGKILL");
    }
    rmSync(profileDir, { recursive: true, force: true });
  }
}
