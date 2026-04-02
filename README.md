# yasashii-dotfiles

ターミナルを、やさしくする。

## これは何？

エンジニアではない方（PM、デザイナー、ビジネス職など）がターミナルを使うとき、
覚えることが多すぎて困ったことはありませんか？

yasashii-dotfiles は、ターミナルの設定をまるごと「やさしく」書き換えるパックです。
新しいツールを覚える必要はありません。いつものコマンドが、裏側で見やすく、安全になります。

## インストール

```sh
curl -fsSL https://raw.githubusercontent.com/esh2n/yasashii-dotfiles/main/install.sh | bash
```

必要なツールは自動でインストールされます。
最後にテーマ・言語・文字サイズを選ぶ画面が出ます。

## 何が変わるの？

**見た目が変わります**
- フォルダやファイルにアイコンと色がつきます
- Git の状態が「ファイルの変更: 2件」のように表示されます
- 3つのテーマ（🌙 Dark / ☀️ Light / 🌸 Sakura）から選べます

**使いやすくなります**
- 入力中にコマンドの候補がうっすら表示されます（→キーで確定）
- 打ち間違えたコマンドを自動で修正提案してくれます
- ファイルを `rm` で消してもゴミ箱に入るので取り戻せます
- 長い処理が終わったら通知が来ます

**Git がやさしくなります**
- `git` と打つだけでメニューが出ます（コマンドを覚えなくて大丈夫です）
- メニューには「状態を見る」「変更を記録する」「クラウドに送る」などが並びます
- 各項目の横に本来のコマンド名も書いてあるので、自然に覚えられます
- `wt` でワークツリー（同じプロジェクトを別フォルダで開く機能）も管理できます

**困ったときのヘルプがあります**
- `tips` と打つとよく使うコマンドの一覧が出ます
- プロンプトの右端にも「tips でコマンド一覧」と常に表示されています
- エラーが起きたとき、日本語で何が起きたか教えてくれます

**Claude Code にも対応しています**
- ステータスバーにモデル名・コンテキスト使用率・コストが表示されます
- 用語が日本語で表示されます（「記憶の範囲」「文字量」など）
- Everything Claude Code (ECC) の全機能が使えます

## ショートカット

| キー | できること |
|------|-----------|
| Ctrl+] | プロジェクト一覧から選んで移動 |
| Ctrl+G | 最近使ったフォルダに移動 |
| Ctrl+F | ファイルを名前で探す |
| Ctrl+R | 過去に打ったコマンドを検索 |
| Ctrl+H | プロンプトの表示内容の説明 |
| ↑ ↓ | 入力中の文字で履歴を絞り込み |
| Alt+← → | 単語単位でカーソル移動 |

## テーマを変える

```sh
yasashii
```

これだけで設定画面が開きます。

## アンインストール

```sh
~/.yasashii/uninstall.sh
```

## 対応言語

日本語 · English · 中文 · 한국어

## 必要なもの

- macOS
- Homebrew（なければ自動でインストールされます）

---

# yasashii-dotfiles (English)

Make the terminal gentle.

## What is this?

If you're not an engineer — maybe a PM, designer, or in a business role —
the terminal can feel overwhelming.

yasashii-dotfiles replaces your terminal settings with friendlier ones.
You don't need to learn new tools. Your existing commands become safer and easier to read.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/esh2n/yasashii-dotfiles/main/install.sh | bash
```

Everything is installed automatically.
A setup wizard will ask you to pick a language, theme, and font size.

## What changes?

**It looks better**
- Files and folders get icons and colors
- Git status shows "files changed: 2" instead of cryptic symbols
- Choose from 3 themes (🌙 Dark / ☀️ Light / 🌸 Sakura)

**It's easier to use**
- Command suggestions appear as you type (press → to accept)
- Mistyped commands get corrected automatically
- Deleted files go to trash instead of disappearing forever
- You get notified when long-running commands finish

**Git becomes friendly**
- Just type `git` to see a menu (no commands to memorize)
- Menu items like "See status", "Record changes", "Send to cloud"
- Real command names shown next to each item so you learn naturally
- `wt` manages worktrees (opening the same project in separate folders)

**Help is always there**
- Type `tips` for a quick command reference
- The prompt always shows "type tips for commands" on the right
- Error messages explain what happened in your language

**Claude Code ready**
- Status bar shows model, context usage, and cost
- Technical terms translated to your language
- Full Everything Claude Code (ECC) integration

## Shortcuts

| Key | What it does |
|-----|-------------|
| Ctrl+] | Jump to a project |
| Ctrl+G | Jump to a recent folder |
| Ctrl+F | Find a file by name |
| Ctrl+R | Search command history |
| Ctrl+H | Explain the prompt |
| ↑ ↓ | Filter history by what you typed |
| Alt+← → | Move cursor by word |

## Change theme

```sh
yasashii
```

That's it.

## Uninstall

```sh
~/.yasashii/uninstall.sh
```

## Languages

Japanese · English · Chinese · Korean

## Requirements

- macOS
- Homebrew (installed automatically if missing)
