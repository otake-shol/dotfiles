"""Claude Code を仮想端末（pyte）で動かし、画面を HTML に描き出す（スライド用の撮影）。

使い方（教材用のファイルだけを置いた作業フォルダーで実行する）:
  python cc_capture.py --prompt "memo.txt を読んで、3行で要約して" --out cc.html [--cols 96] [--rows 30] [--timeout 90]

- 個人の CLAUDE.md・設定・メモリが写らないよう `claude --setting-sources project` で起動する。
- フォルダーを信頼するかの確認が出たら「はい」を選ぶ（↓ → Enter）。
- 返事の出力が6秒止まったら終わったとみなす。画面の文字は <out>.log にも残す。
- 出力の HTML は #t を Playwright で2倍に撮り、必要な行だけを切り出して使う。
"""
import argparse
import fcntl
import html
import os
import pty
import select
import struct
import termios
import time

import pyte

PALETTE = {
    "default": None, "black": "#1e1e1e", "red": "#e06c75", "green": "#98c379", "brown": "#d19a66",
    "yellow": "#e5c07b", "blue": "#61afef", "magenta": "#c678dd", "cyan": "#56b6c2", "white": "#dcdfe4",
    "brightblack": "#7f848e", "brightred": "#e06c75", "brightgreen": "#98c379", "brightyellow": "#e5c07b",
    "brightblue": "#61afef", "brightmagenta": "#c678dd", "brightcyan": "#56b6c2", "brightwhite": "#ffffff",
}


def color(name, default):
    """pyte の色名または16進の色を CSS の色にする。"""
    if name in PALETTE:
        return PALETTE[name] or default
    if len(name) == 6:
        return "#" + name
    return default


def render(screen, cols, rows):
    """画面を色つきの span に変換した HTML を返す。"""
    lines = []
    for y in range(rows):
        line = screen.buffer[y]
        out = []
        for x in range(cols):
            ch = line[x]
            if ch.data == "":  # 全角文字の2セル目
                continue
            fg = color(ch.fg, "#dcdfe4")
            bg = color(ch.bg, "transparent")
            if ch.reverse:
                fg, bg = (bg if bg != "transparent" else "#1e1e1e"), fg
            style = f"color:{fg};" + (f"background:{bg};" if bg != "transparent" else "")
            style += "font-weight:700;" if ch.bold else ""
            out.append(f'<span style="{style}">{html.escape(ch.data)}</span>')
        lines.append("".join(out))
    return (
        '<!doctype html><meta charset="utf-8"><style>'
        "body{margin:0;background:#1e1e1e}"
        "#t{display:inline-block;padding:20px 24px;background:#1e1e1e;"
        "font:16px/1.45 Menlo,'Hiragino Sans',monospace;white-space:pre}"
        f'</style><div id="t">{"<br>".join(lines)}</div>'
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--prompt", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--cols", type=int, default=96)
    parser.add_argument("--rows", type=int, default=30)
    parser.add_argument("--timeout", type=int, default=90)
    args = parser.parse_args()

    screen = pyte.Screen(args.cols, args.rows)
    stream = pyte.ByteStream(screen)
    pid, fd = pty.fork()
    if pid == 0:
        os.environ["TERM"] = "xterm-256color"
        os.environ["COLORTERM"] = "truecolor"
        os.execvp("claude", ["claude", "--setting-sources", "project"])
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", args.rows, args.cols, 0, 0))

    def pump(sec):
        """sec 秒のあいだ出力を読み、画面に反映する。変化があれば True。"""
        end = time.time() + sec
        changed = False
        while time.time() < end:
            ready, _, _ = select.select([fd], [], [], 0.1)
            if not ready:
                continue
            try:
                data = os.read(fd, 65536)
            except OSError:
                return changed
            stream.feed(data)
            if b"\x1b[6n" in data:  # カーソル位置の問い合わせに答える
                os.write(fd, f"\x1b[{screen.cursor.y + 1};{screen.cursor.x + 1}R".encode())
            changed = True
        return changed

    def text():
        return "\n".join(screen.display)

    with open(args.out + ".log", "w", encoding="utf-8") as log:
        pump(8)
        log.write("=== start\n" + text() + "\n")
        if "trust" in text().lower() or "信頼" in text():
            os.write(fd, b"\x1b[B")
            pump(1)
            os.write(fd, b"\r")
            pump(6)
            log.write("=== after trust\n" + text() + "\n")
        for ch in args.prompt:
            os.write(fd, ch.encode())
            pump(0.08)
        pump(1)
        os.write(fd, b"\r")
        start, idle = time.time(), 0
        while time.time() - start < args.timeout:
            if pump(1):
                idle = 0
            else:
                idle += 1
                if idle >= 6 and time.time() - start > 12:
                    break
        log.write("=== final\n" + text() + "\n")

    with open(args.out, "w", encoding="utf-8") as f:
        f.write(render(screen, args.cols, args.rows))
    os.write(fd, b"\x03")
    pump(0.5)
    os.write(fd, b"\x03")
    pump(1)


if __name__ == "__main__":
    main()
