#!/usr/bin/env node

import { spawn, spawnSync } from "node:child_process";
import { mkdir, stat, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { createInterface as createLineReader } from "node:readline";
import { createInterface as createPrompt } from "node:readline/promises";

const DEFAULT_THRESHOLD = 20;
const DEFAULT_INTERVAL_HOURS = 24;
const REQUEST_TIMEOUT_MS = 15_000;
const stateMarker =
  process.env.CODEX_SESSION_CLEANUP_STATE_FILE ||
  join(homedir(), ".codex", "state", "session-cleanup-last-prompt");

function parsePositiveInteger(value, fallback, { allowZero = false } = {}) {
  const parsed = Number.parseInt(value ?? "", 10);
  const minimum = allowZero ? 0 : 1;
  return Number.isInteger(parsed) && parsed >= minimum ? parsed : fallback;
}

function parseArguments(argv) {
  let mode = "--interactive";
  let codexBinary = join(
    homedir(),
    ".codex",
    "packages",
    "standalone",
    "current",
    "codex",
  );
  const deleteIds = [];
  let confirmed = false;

  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    switch (argument) {
      case "--maybe-prompt":
      case "--interactive":
      case "--count":
        mode = argument;
        break;
      case "--delete":
        mode = "--delete";
        while (argv[index + 1] && !argv[index + 1].startsWith("--")) {
          deleteIds.push(argv[index + 1]);
          index += 1;
        }
        break;
      case "--codex":
        index += 1;
        if (!argv[index]) {
          throw new Error("--codex requires a path");
        }
        codexBinary = argv[index];
        break;
      case "--yes":
        confirmed = true;
        break;
      case "-h":
      case "--help":
        mode = "--help";
        break;
      default:
        throw new Error(`Unknown argument: ${argument}`);
    }
  }

  return { mode, codexBinary, deleteIds, confirmed };
}

function printHelp() {
  console.log(`Usage:
  session-cleanup.mjs --maybe-prompt [--codex PATH]
  session-cleanup.mjs --interactive [--codex PATH]
  session-cleanup.mjs --count [--codex PATH]
  session-cleanup.mjs --delete ID... --yes [--codex PATH]

Environment:
  CODEX_SESSION_CLEANUP_THRESHOLD       Prompt at this active-session count (default: 20)
  CODEX_SESSION_CLEANUP_INTERVAL_HOURS  Minimum hours between prompts (default: 24)
  CODEX_SESSION_CLEANUP_ENABLED=0       Disable the startup check`);
}

function createAppServerClient(codexBinary) {
  const appServer = spawn(codexBinary, ["app-server"], {
    stdio: ["pipe", "pipe", "pipe"],
  });
  const lines = createLineReader({ input: appServer.stdout });
  const pending = new Map();
  let nextId = 1;
  let stderr = "";
  let exitedError = null;

  appServer.stderr.on("data", (chunk) => {
    stderr = `${stderr}${chunk.toString()}`.slice(-8_000);
  });

  function rejectPending(error) {
    for (const { reject, timer } of pending.values()) {
      clearTimeout(timer);
      reject(error);
    }
    pending.clear();
  }

  appServer.on("error", (error) => {
    exitedError = error;
    rejectPending(error);
  });

  appServer.on("exit", (code, signal) => {
    if (code === 0 || signal === "SIGTERM") {
      return;
    }
    const detail = stderr.trim();
    exitedError = new Error(
      `codex app-server exited (${code ?? signal})${detail ? `: ${detail}` : ""}`,
    );
    rejectPending(exitedError);
  });

  lines.on("line", (line) => {
    let message;
    try {
      message = JSON.parse(line);
    } catch {
      return;
    }

    if (message.id == null || !pending.has(message.id)) {
      return;
    }

    const { resolve, reject, timer } = pending.get(message.id);
    clearTimeout(timer);
    pending.delete(message.id);

    if (message.error) {
      reject(new Error(JSON.stringify(message.error)));
    } else {
      resolve(message.result);
    }
  });

  function send(message) {
    if (exitedError) {
      throw exitedError;
    }
    appServer.stdin.write(`${JSON.stringify(message)}\n`);
  }

  function request(method, params) {
    const id = nextId;
    nextId += 1;

    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => {
        pending.delete(id);
        reject(new Error(`Timed out waiting for ${method}`));
      }, REQUEST_TIMEOUT_MS);
      pending.set(id, { resolve, reject, timer });

      try {
        send({ method, id, params });
      } catch (error) {
        clearTimeout(timer);
        pending.delete(id);
        reject(error);
      }
    });
  }

  async function initialize() {
    await request("initialize", {
      clientInfo: {
        name: "codex_session_cleanup",
        title: "Codex session cleanup",
        version: "1.0.0",
      },
    });
    send({ method: "initialized", params: {} });
  }

  function close() {
    const error = new Error("codex app-server closed");
    rejectPending(error);
    lines.close();
    appServer.stdin.end();
    appServer.kill("SIGTERM");
  }

  return { initialize, request, close };
}

async function listActiveThreads(codexBinary, { stateDbOnly }) {
  const client = createAppServerClient(codexBinary);
  const threads = [];
  const seenIds = new Set();
  let cursor = null;

  try {
    await client.initialize();

    do {
      const result = await client.request("thread/list", {
        archived: false,
        cursor,
        limit: 100,
        sortKey: "updated_at",
        sortDirection: "asc",
        useStateDbOnly: stateDbOnly,
      });

      for (const thread of result.data ?? []) {
        if (!seenIds.has(thread.id)) {
          seenIds.add(thread.id);
          threads.push(thread);
        }
      }
      cursor = result.nextCursor ?? null;
    } while (cursor);
  } finally {
    client.close();
  }

  return threads;
}

function sanitize(value, fallback = "") {
  const text = String(value ?? "")
    .replace(/[\u0000-\u001f\u007f-\u009f]+/g, " ")
    .replace(/\s{2,}/g, " ")
    .trim();
  return text || fallback;
}

function shorten(value, maxLength) {
  return value.length <= maxLength
    ? value
    : `${value.slice(0, Math.max(1, maxLength - 1))}…`;
}

function displayPath(value) {
  const home = homedir();
  const path = sanitize(value, "(cwd不明)");
  if (path === home) {
    return "~";
  }
  return path.startsWith(`${home}/`) ? `~/${path.slice(home.length + 1)}` : path;
}

function displayDate(timestamp) {
  const date = new Date(Number(timestamp) * 1_000);
  if (Number.isNaN(date.getTime())) {
    return "日時不明";
  }
  return new Intl.DateTimeFormat("ja-JP", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(date);
}

function threadTitle(thread) {
  return shorten(
    sanitize(thread.name || thread.preview, "(タイトルなし)"),
    100,
  );
}

function formatThreadRow(thread) {
  return [
    displayDate(thread.updatedAt),
    threadTitle(thread),
    shorten(displayPath(thread.cwd), 80),
    thread.id,
  ].join("\t");
}

async function ask(question) {
  const prompt = createPrompt({
    input: process.stdin,
    output: process.stderr,
  });
  try {
    return (await prompt.question(question)).trim();
  } finally {
    prompt.close();
  }
}

function selectThreads(threads) {
  const rows = threads.map(formatThreadRow);
  const result = spawnSync(
    "fzf",
    [
      "--multi",
      "--delimiter=\t",
      "--with-nth=1,2,3",
      "--prompt=削除するセッション > ",
      "--header=Tabで複数選択 / Enterで確定 / Escで中止（古い順）",
      "--height=80%",
      "--layout=reverse",
      "--border",
    ],
    {
      input: `${rows.join("\n")}\n`,
      encoding: "utf8",
      stdio: ["pipe", "pipe", "inherit"],
    },
  );

  if (result.error?.code === "ENOENT") {
    throw new Error("fzf is required for interactive cleanup");
  }
  if (result.status === 130 || result.status === 1) {
    return [];
  }
  if (result.status !== 0) {
    throw new Error(`fzf exited with status ${result.status}`);
  }

  return result.stdout
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((row) => row.split("\t").at(-1))
    .filter(Boolean);
}

function ensureRemoteControl(codexBinary) {
  const result = spawnSync(codexBinary, ["remote-control", "start"], {
    encoding: "utf8",
  });
  if (result.status !== 0) {
    throw new Error(
      `Remote Control could not start: ${sanitize(result.stderr || result.stdout)}`,
    );
  }
}

async function deleteThreads(codexBinary, threadIds) {
  const invalidThreadIds = threadIds.filter(
    (threadId) =>
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
        threadId,
      ),
  );
  if (invalidThreadIds.length > 0) {
    throw new Error(`invalid thread ID: ${invalidThreadIds.join(", ")}`);
  }

  ensureRemoteControl(codexBinary);
  const deleted = [];
  const failed = [];

  for (const threadId of threadIds) {
    const result = spawnSync(
      codexBinary,
      ["--remote", "unix://", "delete", threadId, "--force"],
      { encoding: "utf8" },
    );
    if (result.status === 0) {
      deleted.push(threadId);
    } else {
      failed.push({
        threadId,
        message: sanitize(result.stderr || result.stdout, "unknown error"),
      });
    }
  }

  if (deleted.length > 0) {
    const remaining = await listActiveThreads(codexBinary, {
      stateDbOnly: false,
    });
    const remainingIds = new Set(remaining.map((thread) => thread.id));
    const stillVisible = deleted.filter((threadId) => remainingIds.has(threadId));
    if (stillVisible.length > 0) {
      for (const threadId of stillVisible) {
        failed.push({
          threadId,
          message: "delete command succeeded, but thread/list still returns it",
        });
      }
    }
  }

  return { deleted, failed };
}

async function markerIsRecent(intervalHours) {
  if (intervalHours === 0) {
    return false;
  }
  try {
    const metadata = await stat(stateMarker);
    return Date.now() - metadata.mtimeMs < intervalHours * 60 * 60 * 1_000;
  } catch (error) {
    if (error.code === "ENOENT") {
      return false;
    }
    throw error;
  }
}

async function touchPromptMarker() {
  await mkdir(dirname(stateMarker), { recursive: true });
  await writeFile(stateMarker, `${new Date().toISOString()}\n`, "utf8");
}

async function interactiveCleanup(codexBinary, initialThreads = null) {
  if (!process.stdin.isTTY || !process.stderr.isTTY) {
    throw new Error("interactive cleanup requires a TTY");
  }

  const threads =
    initialThreads ??
    (await listActiveThreads(codexBinary, {
      stateDbOnly: false,
    }));
  if (threads.length === 0) {
    console.error("Codexのアクティブなセッションはありません。");
    return;
  }

  const selectedIds = selectThreads(threads);
  if (selectedIds.length === 0) {
    console.error("セッション整理を中止しました。");
    return;
  }

  const selectedIdSet = new Set(selectedIds);
  const selectedThreads = threads.filter((thread) =>
    selectedIdSet.has(thread.id),
  );
  console.error("");
  for (const thread of selectedThreads) {
    console.error(
      `- ${displayDate(thread.updatedAt)}  ${threadTitle(thread)}  (${displayPath(thread.cwd)})`,
    );
  }
  console.error("");

  const answer = await ask(
    `選択した${selectedIds.length}件を完全削除します。よろしいですか？ [y/N] `,
  );
  if (!["y", "yes"].includes(answer.toLowerCase())) {
    console.error("削除を中止しました。");
    return;
  }

  const result = await deleteThreads(codexBinary, selectedIds);
  const failedIds = new Set(result.failed.map(({ threadId }) => threadId));
  const verifiedDeleted = result.deleted.filter(
    (threadId) => !failedIds.has(threadId),
  );

  if (verifiedDeleted.length > 0) {
    console.error(
      `✓ ${verifiedDeleted.length}件を削除し、セッション一覧からの消失を確認しました。`,
    );
  }
  for (const failure of result.failed) {
    console.error(`✗ ${failure.threadId}: ${failure.message}`);
  }
  if (result.failed.length > 0) {
    process.exitCode = 1;
  }
}

async function maybePrompt(codexBinary) {
  if (!process.stdin.isTTY || !process.stderr.isTTY) {
    return;
  }

  const threshold = parsePositiveInteger(
    process.env.CODEX_SESSION_CLEANUP_THRESHOLD,
    DEFAULT_THRESHOLD,
  );
  const intervalHours = parsePositiveInteger(
    process.env.CODEX_SESSION_CLEANUP_INTERVAL_HOURS,
    DEFAULT_INTERVAL_HOURS,
    { allowZero: true },
  );

  if (await markerIsRecent(intervalHours)) {
    return;
  }

  const fastThreads = await listActiveThreads(codexBinary, {
    stateDbOnly: true,
  });
  if (fastThreads.length < threshold) {
    return;
  }

  await touchPromptMarker();
  const answer = await ask(
    `Codexのアクティブなセッションが${fastThreads.length}件あります。整理しますか？ [y/N] `,
  );
  if (!["y", "yes"].includes(answer.toLowerCase())) {
    return;
  }

  await interactiveCleanup(codexBinary);
}

async function main() {
  const { mode, codexBinary, deleteIds, confirmed } = parseArguments(
    process.argv.slice(2),
  );

  switch (mode) {
    case "--help":
      printHelp();
      return;
    case "--count": {
      const threads = await listActiveThreads(codexBinary, {
        stateDbOnly: false,
      });
      console.log(threads.length);
      return;
    }
    case "--maybe-prompt":
      await maybePrompt(codexBinary);
      return;
    case "--interactive":
      await interactiveCleanup(codexBinary);
      return;
    case "--delete": {
      if (!confirmed || deleteIds.length === 0) {
        throw new Error("--delete requires at least one ID and --yes");
      }
      const result = await deleteThreads(codexBinary, deleteIds);
      if (result.failed.length > 0) {
        for (const failure of result.failed) {
          console.error(`✗ ${failure.threadId}: ${failure.message}`);
        }
        process.exitCode = 1;
        return;
      }
      console.log(
        `deleted=${result.deleted.length} verified_absent=${result.deleted.length}`,
      );
      return;
    }
    default:
      throw new Error(`Unsupported mode: ${mode}`);
  }
}

main().catch((error) => {
  console.error(`session cleanup failed: ${error.message}`);
  process.exitCode = 1;
});
