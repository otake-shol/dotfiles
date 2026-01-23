# Dotfiles Manager Agent

アプリケーションをdotfilesに追加する作業を自動化するClaude Code Agentです。

## 使い方

Claude Codeで以下のように指示するだけです：

```
Ice というアプリを dotfiles に追加して
```

```
htop を必須ツールとして追加
```

## 機能

- Brewfileへの追加
- docs/APPS.md への情報追加
- 必要に応じて設定ファイルのシンボリックリンク設定
- 変更の自動コミット

## 詳細

エージェントの詳細な動作仕様は以下を参照してください：

- [.claude/agents/dotfiles-manager.md](../../.claude/agents/dotfiles-manager.md)
