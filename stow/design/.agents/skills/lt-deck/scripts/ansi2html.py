#!/usr/bin/env python3
"""ANSIの色付き端末出力を、スライド用の端末風HTMLに変換する。

使い方:
  python3 ansi2html.py <input.ansi> <output.html> [--font-size 15] [--split LINE:CHAR ...]

  --split 2:  は 2行目を、文字 CHAR の直前（直前のエスケープ列ごと）で2段に折り返す。
             スライドで1行が長すぎるときに使う。文字は出力のまま、改行位置だけ変わる。
  CHAR は1文字（例: Nerd Font のアイコン）か "sep=<文字列>"（その文字列で分割し文字列自体は捨てる）。

出力した HTML は Playwright などで #t 要素を deviceScaleFactor 2 で撮影する。
フォントは JetBrainsMono Nerd Font（無ければ monospace）。色は ANSI 16色＋256色の208（オレンジ）を近似する。
"""
import argparse
import html
import re

BASE = {30: '#3b3b3b', 31: '#f14c4c', 32: '#23d18b', 33: '#e5c07b', 34: '#3b8eea', 35: '#d670d6',
        36: '#29b8db', 37: '#cccccc', 90: '#666666', 91: '#ff6b6b', 92: '#5af78e', 93: '#f4f99d',
        94: '#6cb6ff', 95: '#ff6ac1', 96: '#9aedfe', 97: '#ffffff'}
C256 = {208: '#ff8700'}
SGR = re.compile(r'(\x1b\[[0-9;]*m)')


def convert(text):
    text = re.sub(r'\x1b\]8;;.*?\x07', '', text)  # OSC 8 リンクは外す
    out, st = [], {}

    def span(s):
        style = []
        if 'fg' in st:
            style.append('color:' + st['fg'])
        if st.get('bold'):
            style.append('font-weight:700')
        if st.get('dim'):
            style.append('opacity:.55')
        return f'<span style="{";".join(style)}">{html.escape(s)}</span>' if style else html.escape(s)

    for part in SGR.split(text):
        m = re.fullmatch(r'\x1b\[([0-9;]*)m', part)
        if not m:
            out.append(span(part))
            continue
        codes = [int(c) for c in m.group(1).split(';') if c] or [0]
        i = 0
        while i < len(codes):
            c = codes[i]
            if c == 0:
                st = {}
            elif c == 1:
                st['bold'] = True
            elif c == 2:
                st['dim'] = True
            elif c == 38 and codes[i + 1:i + 2] == [5]:
                st['fg'] = C256.get(codes[i + 2], '#ffffff')
                i += 2
            elif c in BASE:
                st['fg'] = BASE[c]
            i += 1
    return ''.join(out)


def split_line(line, spec):
    if spec.startswith('sep='):
        a, b = line.split(spec[4:], 1)
        return [a.rstrip(), b.lstrip()]
    idx = line.index(spec)
    j = idx
    while True:  # 直前に連なるエスケープ列ごと次の段へ送る
        m = re.search(r'\x1b\[[0-9;]*m$', line[:j])
        if not m:
            break
        j = m.start()
    return [line[:j].rstrip(), line[j:].lstrip()]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('input')
    ap.add_argument('output')
    ap.add_argument('--font-size', type=int, default=15)
    ap.add_argument('--split', action='append', default=[], help='LINE:CHAR（1始まりの行番号）')
    args = ap.parse_args()

    lines = open(args.input, encoding='utf-8').read().rstrip('\n').split('\n')
    splits = {}
    for s in args.split:
        n, ch = s.split(':', 1)
        splits[int(n)] = ch
    rows = []
    for n, line in enumerate(lines, 1):
        rows.extend(split_line(line, splits[n]) if n in splits else [line])
    body = '<br>'.join(convert(r) for r in rows)
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write('<!doctype html><meta charset="utf-8"><style>body{margin:0;background:#f0f0f0}'
                '.term{display:inline-block;background:#1e1e1e;color:#d4d4d4;padding:18px 24px;'
                'font-family:"JetBrainsMono Nerd Font",monospace;'
                f'font-size:{args.font_size}px;line-height:1.75;white-space:pre;border-radius:8px}}'
                f'</style><div class="term" id="t">{body}</div>')


if __name__ == '__main__':
    main()
