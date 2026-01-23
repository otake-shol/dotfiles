# dotfiles 将来の検討項目

> 最終更新: 2026-01-24

実装済み項目は削除済み。将来検討可能な項目のみ記載。

---

## 将来検討可能なCLIツール

| ツール | 用途 | 見送り理由 |
|--------|------|-----------|
| just | コマンドランナー | 既存aliasで十分 |
| git-lfs | 大容量ファイル管理 | 使用機会なし |
| navi | チートシート | tldrで十分 |
| lazydocker | Docker TUI | OrbStack GUIで十分 |
| xh | HTTPクライアント | HTTPieで十分 |
| mcfly | AI履歴検索 | atuinで十分 |
| broot | ファイルエクスプローラー | yaziで十分 |
| viddy | watch代替 | watchexecで十分 |
| bottom | リソースモニター | procs/btopで十分 |
| grex | 正規表現生成 | 頻度低い |
| age | 暗号化 | 1Password CLIで代替可 |
| ast-grep | 構造検索 | 頻度低い |

## 将来検討可能なGUIアプリ

| アプリ | 用途 | 見送り理由 |
|--------|------|-----------|
| Karabiner-Elements | キーボードカスタマイズ | Vim不使用 |
| Notion | ナレッジベース | 使用予定なし |
| Obsidian | ローカルノート | 使用予定なし |
| IINA | 動画プレーヤー | 開発環境に不要 |
| Keka | 圧縮/展開 | 7z/RAR不使用 |

## 将来検討可能な自動化

| 項目 | 内容 | 見送り理由 |
|------|------|-----------|
| 定期更新スクリプト | brew/omz/asdf一括更新 | brewupで十分 |
| shellcheck(ローカル) | シェルスクリプトlint | CIで検出可能 |
| ngrok | ローカル公開 | Webhook不使用 |

---

## 参考リンク

- [Modern Unix](https://github.com/ibraheemdev/modern-unix)
- [Awesome macOS](https://github.com/iCHAIT/awesome-macOS)
