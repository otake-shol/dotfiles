# 撮影：実画面・録画・Claude Code・スマホ

撮ったものはすべて、履歴・アカウント名・メールアドレス・メモリ・個人のパス・組織名が写っていないかを1枚ずつ確かめる。
写っている確認用の画像は、使わなくてもその場で削除する。元の画面は `assets/src/` に残し、撮影条件を README の素材の出典に書く。

## Web版（claude.ai）

ユーザーのアカウントを使う場合は、撮影の前に許可を取る。

- シークレットチャット（`https://claude.ai/new?incognito`）で撮る。履歴とメモリが写らない。入力欄の枠が点線になることを発表者ノートに書く。
- Playwright MCP で、ログイン済みの状態（storageState）を写した新しいコンテキストを作り、1280×720・2倍・日本語で撮る。ヘッドレスの Chrome は Cloudflare の確認で止まるので使わない。
- Playwright MCP は作業ディレクトリの外に保存できない。作業ディレクトリの `.playwright-mcp/` に保存し、assets へ移したら削除する（コミットしない）。

`browser_run_code_unsafe` で実行するコードの例（入力前・入力後・返事・追加の注文・その返事を撮り、同時に録画する）：

```js
async (page) => {
  const state = await page.context().storageState();
  const ctx = await page.context().browser().newContext({
    storageState: state, viewport: { width: 1280, height: 720 }, deviceScaleFactor: 2, locale: 'ja-JP',
    recordVideo: { dir: '.playwright-mcp/video', size: { width: 1280, height: 720 } },
  });
  const p = await ctx.newPage();
  await p.goto('https://claude.ai/new?incognito');
  await p.waitForTimeout(4000);
  await p.screenshot({ path: '.playwright-mcp/web-01-empty.png' });
  await p.locator('[contenteditable="true"]').first().click();
  await p.keyboard.type('今日の晩ごはんの献立を3つ提案して', { delay: 120 });
  await p.waitForTimeout(800);
  await p.screenshot({ path: '.playwright-mcp/web-02-typed.png' });
  await p.keyboard.press('Enter');
  await p.waitForTimeout(25000);
  await p.screenshot({ path: '.playwright-mcp/web-03-reply.png' });
  await p.keyboard.type('もっと簡単に作れるものにして', { delay: 120 });
  await p.waitForTimeout(800);
  await p.screenshot({ path: '.playwright-mcp/web-04-followup.png' });
  await p.keyboard.press('Enter');
  await p.waitForTimeout(25000);
  await p.screenshot({ path: '.playwright-mcp/web-05-reply2.png' });
  const v = p.video();
  await ctx.close();
  return await v.path();
}
```

- 返事が長いと25秒で終わらないことがある。撮った画像で返事が止まっているかを確かめ、足りなければ待ち時間を延ばして撮り直す。
- 切り抜きは `sips --cropToHeightWidth <高さ> <幅> --cropOffset <上> <左>`（2倍の画素で指定）。入力欄は入力欄と送信ボタンだけ、返事は送った文と返事の冒頭だけにする。
- 入力欄に出るモデル名はプランで変わる。撮ったプランを発表者ノートと講師ガイドに書く。

## ログイン画面

未ログインの新しいコンテキスト（storageState を渡さない）で `https://claude.ai/login` を 1000×700・2倍で撮り、ログインの枠だけを切り抜く。
ログインの方法（Google・Apple・メールなど）は実画面と公式ヘルプの両方で確かめ、食い違いを README に書く。

## 録画（デモ動画）

上のコードの `recordVideo` で撮った WebM を、音なし・1.5倍速の MP4 にする。

```bash
ffmpeg -y -loglevel error -i .playwright-mcp/video/*.webm -filter:v "setpts=PTS/1.5" -an \
  -c:v libx264 -pix_fmt yuv420p -crf 23 -movflags +faststart assets/demo-web.mp4
cp .playwright-mcp/web-03-reply.png assets/demo-web-poster.png && sips -Z 1280 assets/demo-web-poster.png
```

スライドには poster つきの1本の `<video>` を置く。HTML版では自動で繰り返し再生され、PDFでは poster の静止画になる。
`@media print` などで画像と動画を出し分ける方法は Marp では効かない。

```html
<video class="shot" src="assets/demo-web.mp4" poster="assets/demo-web-poster.png" autoplay loop muted playsinline style="max-height:380px;" aria-label="（何をしている録画か・長さ・速さ）"></video>
```

- 40秒前後に収める。長くなる場合は操作を減らす。
- 講師ガイドに「ライブデモができないときに使う」「HTML版をブラウザーで開く」と書く。
- PDFで poster が出ることを `pdftoppm -f <ページ> -l <ページ> -png` で確かめる。

## Claude Code（端末）

`scripts/cc_capture.py` で、仮想端末（pyte）の中で Claude Code を動かし、画面をHTMLにする。tmux は不要。

```bash
python3 -m venv <scratchpad>/venv && <scratchpad>/venv/bin/pip -q install pyte
mkdir -p <scratchpad>/demo && cd <scratchpad>/demo   # 教材用のファイルだけを置いた作業フォルダー
<scratchpad>/venv/bin/python ~/.agents/skills/claude-training-deck/scripts/cc_capture.py \
  --prompt "memo.txt を読んで、3行で要約して" --out <scratchpad>/cc.html
```

- `--setting-sources project` で起動するので、個人の CLAUDE.md・設定・メモリは読み込まれない。作業フォルダーには教材用に作ったファイルだけを置く（参照実装は町内清掃のお知らせ）。
- 初回はフォルダーを信頼するかの確認が出る。スクリプトは「はい」を選んで進む。
- 出力のHTMLを Playwright で開き、`#t` を2倍で撮る。依頼から返事までの行だけを切り出し、起動時のロゴ・版・案内は落とす（元の画面は `assets/src/` に残す）。
- 版（`claude --version`）と撮った日を README に書く。

## スマホアプリ

アプリの画面は撮れないので、ユーザーに撮影を頼む。シークレットチャットで撮ってもらうと、履歴やアカウント名が写らない。頼む画面の例：

1. アプリを開いた直後の入力画面
2. お題を入力した状態（送信前）
3. 返事が表示された状態
4. 「＋」を押して添付の方法が出た状態（資料を渡す章がある場合）

受け取ったら、状態バーの時刻・電池・通知が写っていても問題ないかを確かめ、必要なら上端を切り抜く。
