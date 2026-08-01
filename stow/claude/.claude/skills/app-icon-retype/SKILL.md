---
name: app-icon-retype
description: デザインソース（SVG / Figma）が無く完成 PNG しか存在しないアプリアイコンを、安全に改修する。文字だけの書体差し替え、焼き込み角丸の除去（フルブリード化）、色の差し替えなど。「アイコンの文字だけ変えたい」「アイコンを世界観に合わせたい」「アイコンの角に白い縁が出る」ときに使う。おたけ屋のコア Q ファミリー（資格試験アプリ）が主な対象だが、同じ条件の PNG なら汎用に使える。
---

# アプリアイコンの部分改修（PNG しか無い状態から）

完成 PNG から**一部だけを外して組み直す**。全面的に作り直すのではないので、
ASO 上の連続性（既存ユーザーがホーム画面で見失わないこと）を保ったまま改修できる。

参照実装: `otake-ya/projects/mobile/exam-apps/shindanshi-app`
（`docs/icon-design.md` と `scripts/retype-icon.sh`）

---

## 0. 先に確認する（省略しない）

**リポジトリに実物と違うアイコンが残っていることがある。** 参照実装では
`icon-512.png` が Q の無い旧デザインで、これを本物と誤認して 5 案も作り直した。

```bash
grep -n '"icon"\|adaptiveIcon\|splash\|favicon' app.json     # app.json が参照している実体を特定
magick identify assets/images/*.png                          # サイズ一覧
md5 -q assets/images/icon.png assets/images/adaptive-icon.png  # 同一ファイルか
```

**必ず app.json が指しているファイルを開いて目で見る。** そのうえで
「どこからも参照されていない画像」があれば、削除候補として報告する。

---

## 1. この手法が使えるか判定する

2 つとも満たす必要がある。満たさなければ作り直しを提案すること。

**(a) 地のグラデが縦方向のみか**（同じ y なら左右が同色か）

```bash
for y in 400 800 1200 1600; do
  printf "y=%-5s L:" "$y"; magick icon.png -format "%[pixel:p{60,$y}]" info:
  printf "  R:";           magick icon.png -format "%[pixel:p{1988,$y}]\n" info:
done
```

左右が一致するなら、**文字の無い列を横に引き伸ばすだけで背景を正確に復元できる**。
斜めグラデや放射グラデならこの手は使えない。

**(b) 消したい要素と残したい要素が空間的に分離しているか**

色は同じ（どちらも白）でも、座標で領域を限定できれば区別できる。
残したい要素（ロゴ）に掛からない矩形を選べるか、拡大して確認する。

---

## 2. 実測する（目分量で座標を決めない）

### 文字の bbox

```bash
magick icon.png -crop <w>x<h>+<x>+<y> +repage -colorspace gray -threshold 88% -format "%@\n" info:
```

crop のオフセットを足して絶対座標にする。行ごとに測り、**幅と中心**を記録する。

### 消去に使う列

ロゴ・文字・角丸のいずれにも掛からない x を探す。行によって使える x が違うので、
上部用と下部用で別の列を選んでよい。

```bash
for y in 120 400 1000 1600 1930; do printf "y=%-5s " "$y"; magick icon.png -format "%[pixel:p{250,$y}]\n" info:; done
```

全部「地の色」なら、その列が使える。

### 白を抜くときの許容差

地の色と白のユークリッド距離を最大値（`sqrt(3)*255`）で割る。
その値**未満**の fuzz なら、地には到達しない。参照実装では 51.6% だったので
`-fuzz 40%` を採った（アンチエイリアスは拾い、絵の白には届かない）。

---

## 3. 判断の枠組み — 何を変え、何を変えないか

**ASO リスクの本体には触れない。** 具体的には**ロゴのシルエット・地の色・レイアウト**。
ここを変えるなら、それは「部分改修」ではなく作り直しであり、順位変動のリスクを取る判断になる。
必ずユーザーに明示して合意を取ること。

変えてよいもの（見た目の変化が小さく、技術的な正しさが上がるもの）:

| | 内容 |
|---|---|
| 文字の書体 | アプリ内の見出し書体に合わせると、アイコンと中身が地続きになる |
| 焼き込み角丸 | §5。実害が出ていることが多い |
| プラットフォーム設定色 | `adaptiveIcon.backgroundColor` などがデザイントークン外の値になっていないか |

**ブランドマークとアプリ固有情報を分けて考える。** マルチアプリのブランドなら、
ブランドマークは全アプリ共通の資産なので**このアプリだけ変えない**。
書体を合わせる対象はアプリ固有の情報（試験名・サービス名）だけにする。

さらに、**ブランドマークの欧文がロゴシンボルと同じ書風で作られていることがある**。
その場合に書体を変えると、その 1 文字だけ浮く。並べて確認すること。

---

## 4. 文字の組み直し

**pointsize ではなく元 bbox の実寸に合わせる。** フォントごとに字面率が違うため、
pointsize を揃えても見た目の大きさは揃わない。

```bash
# 大きく組んで trim し、目標幅へ縮小する（アンチエイリアスを稼ぐ）
magick -background none -fill white -font "$FONT" -pointsize 600 \
  label:"$text" -trim +repage -resize "${w}x" body.png
```

`magick` は `-font` に **ttf のパスを直接渡せる**（fontconfig 登録は不要）。

### 太さの補正

書体を替えると線の太さが変わる。**元と同じ幅で組むと弱く／強く見える**ことがあるので、
倍率を掛けて調整する。丸ゴシック Bold は細めなので、参照実装では **1.07** を採った。
判断は原寸・ホーム相当・検索結果相当の **3 サイズで並べて**行う。

### 縦位置

bbox 中心で揃えると崩れる場合がある。元の書体に長いディセンダ（`Q` の尻尾など）が
あると bbox が下に伸びており、中心を合わせると和文が下がる。
**和文の字面が元と同じ位置に来るように**オフセットを足す。

### 影

元に影があれば再現する。本体の前に、色を潰してぼかしたものをオフセットして置く。

```bash
magick body.png -fill "#08316B" -colorize 100 -blur 0x7 \
  -channel A -evaluate multiply 0.5 +channel shadow.png
```

---

## 5. 焼き込み角丸の除去（フルブリード化）

**アプリアイコンは正方形フルブリードで渡し、角丸は OS に任せるのが正しい。**
焼き込み角丸の半径が OS のマスク半径（iOS は 22.37%）より**大きい**と、
マスク後も角に白いリムが残る。

判定は目視が早い。マスクを当てて角を拡大する。

```bash
magick -size 400x400 xc:none -draw "roundrectangle 0,0,399,399,89,89" -alpha extract m.png
magick icon.png -resize 400x400 m.png -alpha off -compose CopyOpacity -composite \
  -compose over -background '#C9D6E8' -flatten -crop 130x130+0+0 +repage -scale 320x320 corner.png
```

除去の手順:

```bash
# 1. 絵に掛からない列から縦グラデを取り出し、角丸に掛かる範囲は端の色で延長して全面に伸ばす
magick icon.png -crop 1x1810+250+120 +repage \
  -virtual-pixel edge -set option:distort:viewport 1x2048-0-120 -distort SRT 0 +repage \
  -resize 2048x2048\! grad.png

# 2. 四隅から白を floodfill で抜く（角丸半径を測る必要がない）
magick icon.png -alpha set -fuzz 40% \
  -fill none -floodfill +0+0 white -fill none -floodfill +2047+0 white \
  -fill none -floodfill +0+2047 white -fill none -floodfill +2047+2047 white clear.png

# 3. 重ねる
magick grad.png clear.png -composite fullbleed.png
```

**スプラッシュ画像には適用しない。** 角の外が透明で、背景色の上に縮小配置される
前提のものは、角丸のままが正しい。フルブリードにすると四角いブロックになる。

---

## 6. 検証（全部通す）

```bash
# 1. スクリプトが出荷物を完全再現するか。0 でなければ手作業が混入している
magick compare -metric AE <再生成> assets/images/icon.png null:

# 2. 触らないと決めた領域が本当に無傷か（元画像と同じ矩形を切って比較）
magick compare -metric AE \( orig.png -crop WxH+X+Y +repage \) \( new.png -crop WxH+X+Y +repage \) null:

# 3. 復元した背景が元の色と一致するか（複数の y で）
magick new.png -format "%[pixel:p{100,800}]" info:

# 4. floodfill の影響範囲。四隅の角丸ぶん＝数%。大きすぎたら絵を削っている
magick clear.png -alpha extract -format "%[fx:100*(1-mean)]" info:
```

**目視は実グリッドで行う。** 単体で見ても分からない。

```bash
xcrun simctl terminate booted <bundle-id>     # ホーム画面へ戻す
xcrun simctl io booted screenshot home.png
# 186px にリサイズ＋角丸マスクし、既存アイコンの真下のグリッド位置に合成する
```

現行の真下に置くと差分が一目で分かる。同ブランドの兄弟アプリが並んでいれば、
**ファミリーの中で浮いていないか**も同時に確認できる。

---

## 7. 罠

| 罠 | 対処 |
|---|---|
| **`-compose CopyOpacity` が後続の `-flatten` にも効く** | マスク適用後に `-compose over` へ戻す。戻さないと画像が背景色一色になる |
| **`-channel A -morphology Erode` はアルファを壊す** | 境界のアンチエイリアス除去に使わない。`-fuzz` を上げて floodfill する |
| **`-crop 1xN` + `-trim` で bbox が取れない** | 四隅の微妙な色が残り trim されない。角丸半径は測らず floodfill で処理する |
| **`cp` が対話モードで止まる** | `command cp -f` を使う |
| **Playwright MCP は `file:` を開けない** | 比較ボードは `python3 -m http.server` 経由で配信する |
| **スクリプトが冪等でない** | 組み直した文字が消去領域からはみ出ると、二度流して残骸が出る。元 PNG は git 履歴から取り、ヘッダにその旨を書く |

---

## 8. 記録する

改修したら必ず残す。**次に触る人（自分を含む）が実測をやり直さずに済むこと**が目的。

- `docs/icon-design.md` … 何を変え・何を変えなかったか＋その理由、実測値、再現手順、検証手順
- `scripts/retype-icon.sh` … 実装。座標をハードコードしてよいが、**測り方をコメントに書く**
- デザインシステムの文書に既存の決定（「アイコンは変更しない」等）があれば、
  **取り消し線＋改訂日＋理由**で更新する。消さずに残す
