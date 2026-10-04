---
# 見本デッキ: 全レイアウト（L01〜L18）と N01 の書き方。人物・数値・出典はすべて架空。
# 書き出し: scripts/build.sh assets/sample-deck.md <出力先>
marp: true
theme: story-slides
lang: ja
paginate: true
title: レビュー待ちを減らして実現する週次リリース（見本）
---

<!-- _class: l01 -->

# レビュー待ちを減らして<br>実現する週次リリース

<p class="subtitle">開発プロセス改善の提案　2026年10月2日</p>
<p class="compact">山田 花子｜決済基盤チーム エンジニア</p>

<!-- 表紙では提案の結論を一言で伝える。 -->

---

<!--
_class: l17
_header: 自己紹介
-->

# 決済基盤のリリース運用を<br>3年担った立場からの提案

<p class="name">山田 花子<small class="reading">（はなこ）</small></p>
<p class="affil">決済基盤チーム<br>エンジニア</p>

<ul class="points">
<li>リリース手順の自動化を担当</li>
<li>レビュー待ちの計測を開始</li>
<li>週次リリースを2チームで試行</li>
</ul>

<!-- 決済基盤チームでリリース運用を3年担当しています。今日はレビュー待ちを計測して分かったことと、週次リリースへ移る提案をします。（出典: 見本） -->

---

<!--
_class: l08
_header: 進め方
-->

# 計測・削減・週次化の<br>3段階で進める移行

<ol class="steps">
<li><b>現状を測る</b><span>依頼から承認までの待ちを2週間記録</span></li>
<li><b>待ちを減らす</b><span>依頼の出し方と担当の決め方を変更</span></li>
<li><b>週次で出す</b><span>毎週水曜に小さく出して結果を振り返る</span></li>
</ol>

<p class="band">最初の2週間で効果を測り、続けるかを判断します</p>

---

<!-- _class: l03 -->

<header class="n01"><ol><li class="active">現状を測る</li><li>待ちを減らす</li><li>週次で出す</li></ol></header>
<p class="number">01</p>

# 現状の計測

<p class="question">待ちはどの工程で生まれているのか</p>
<p class="period">第1週〜第2週</p>

---

<!-- _class: l02 -->

<header class="n01"><ol><li class="active">現状を測る</li><li>待ちを減らす</li><li>週次で出す</li></ol></header>

# 修正が利用者に届くまで<br>平均12日かかる現状

隔週リリースのため、直した不具合も次のリリース日まで届きません。

<div class="kpis">
<p class="kpi"><span class="fig">12</span><span class="unit">日</span><span class="label">修正が届くまでの平均</span></p>
<p class="kpi"><span class="fig">2</span><span class="unit">週ごと</span><span class="label">リリースの間隔</span></p>
</div>

<p class="exception">大きな修正ほど次のリリースへ持ち越され、待ちがさらに延びる</p>

<!--
_footer: 出典: 見本用の架空データ（2026年9月の2週間を想定）
-->

---

<!-- _class: l10 -->

<header class="n01"><ol><li class="active">現状を測る</li><li>待ちを減らす</li><li>週次で出す</li></ol></header>

# 待ちの8割を占める<br>レビュー依頼後の放置

<div class="bars">
<div class="bar hl"><span class="label">依頼後の放置</span><span class="track"><i style="--v: 100%"></i></span><span class="value">4.8日</span></div>
<div class="bar"><span class="label">修正の往復</span><span class="track"><i style="--v: 15%"></i></span><span class="value">0.7日</span></div>
<div class="bar"><span class="label">承認後の待ち</span><span class="track"><i style="--v: 10%"></i></span><span class="value">0.5日</span></div>
</div>

<p class="annotation">依頼後の放置だけで4.8日（待ち全体の8割）</p>

<!--
_footer: 出典: 見本用の架空データ（工程ごとの待ちの平均、2026年9月の2週間を想定）
-->

<!-- 数値の出典は発表メモにも残す。見本用の架空データ。 -->

---

<!-- _class: l07 -->

<header class="n01"><ol><li class="active">現状を測る</li><li>待ちを減らす</li><li>週次で出す</li></ol></header>

# 1日1回のまとめ依頼が生む<br>待ちの連鎖

<div class="causal">
<div class="cause"><b>原因</b>依頼を1日1回まとめて出す</div>
<div class="mechanism"><b>変換</b>待ちが次の作業の待ちを生む</div>
<ul>
<li>修正が届くまで平均12日</li>
<li>リリース前に確認が集中</li>
<li class="exception">大きな変更ほど後回し</li>
</ul>
</div>

<p class="band">依頼の粒度を小さくすれば連鎖の起点が消える</p>

---

<!-- _class: l03 -->

<header class="n01"><ol><li>現状を測る</li><li class="active">待ちを減らす</li><li>週次で出す</li></ol></header>
<p class="number">02</p>

# 待ちの削減

<p class="question">依頼の出し方と担当の決め方をどう変えるか</p>
<p class="period">第2週〜第3週</p>

---

<!-- _class: l06 -->

<header class="n01"><ol><li>現状を測る</li><li class="active">待ちを減らす</li><li>週次で出す</li></ol></header>

# 依頼の出し方の変更だけで<br>半減する待ち

<div class="contrast">
<div>

### 今

- 1日1回まとめて依頼
- 担当は依頼者が指名
- 気づくのは翌朝

</div>
<div class="hl">

### 提案後

- 完成したらすぐ依頼
- 当番が2時間以内に着手
- 待ちはボードで共有

</div>
</div>

<p class="band">決め手は依頼の粒度と最初の応答の速さ</p>

---

<!-- _class: l15 -->

<header class="n01"><ol><li>現状を測る</li><li class="active">待ちを減らす</li><li>週次で出す</li></ol></header>

# 小さく頻繁に出すための<br>当番制レビュー

<div class="wwh">
<div><b>WHY</b><p>小さな変更を早く届けたい</p></div>
<div><b>WHAT</b><p>レビュー当番を1日1人決める</p></div>
<div><b>HOW</b><p>当番表をボードに置き、依頼は完成時に1件ずつ出す</p></div>
</div>

---

<!--
_class: l16
_header: 問題1｜レビュー依頼が埋もれる
-->

<header class="n01"><ol><li>現状を測る</li><li class="active">待ちを減らす</li><li>週次で出す</li></ol></header>

# 埋もれる依頼を<br>当番が拾い上げる仕組み

<div class="pr">
<div class="problem"><b>問題</b><p>依頼がチャットに流れ、気づくのは翌朝</p></div>
<div class="response"><b>対応</b><p>当番を1日1人決め、2時間以内に着手</p></div>
<div class="effect"><b>効果</b><p>放置が4.8日から1.9日へ</p><small>残るコスト: 当番の日は自分の実装が半日止まる</small></div>
</div>

<!--
_footer: 出典: 見本用の架空データ（先行チームの4週間を想定）
-->

---

<!-- _class: l13 -->

<header class="n01"><ol><li>現状を測る</li><li class="active">待ちを減らす</li><li>週次で出す</li></ol></header>

# 変更の中心は<br>レビュー待ちの工程

<ol class="rail">
<li><b>実装</b></li>
<li class="active"><b>レビュー待ち</b><span>当番制で短縮</span></li>
<li><b>レビュー</b></li>
<li><b>修正</b></li>
<li><b>リリース</b></li>
</ol>

<div class="detail">

- ほかの工程の手順は変えない
- 待ちの長さは毎日ボードで見える状態にする

</div>

---

<!-- _class: l03 -->

<header class="n01"><ol><li>現状を測る</li><li>待ちを減らす</li><li class="active">週次で出す</li></ol></header>
<p class="number">03</p>

# 週次リリースへの移行

<p class="question">毎週出すために何を決めておくか</p>
<p class="period">第3週〜第4週</p>

---

<!-- _class: l05 -->

<header class="n01"><ol><li>現状を測る</li><li>待ちを減らす</li><li class="active">週次で出す</li></ol></header>

# 4週間で週次リリースへ<br>移る段取り

<ol class="rail">
<li><b>第1週</b><span>待ちを計測</span></li>
<li><b>第2週</b><span>当番制を開始</span></li>
<li class="active" style="flex-grow: 1.6"><b>第3週</b><span>週次リリースを試行</span></li>
<li><b>第4週</b><span>続けるかを判断</span></li>
</ol>

<p class="band">4週目に続けるか戻すかを判断します</p>

---

<!-- _class: l11 -->

<header class="n01"><ol><li>現状を測る</li><li>待ちを減らす</li><li class="active">週次で出す</li></ol></header>

# 開発とレビューの2本の流れを<br>つなぐ毎週の振り返り

<div class="lanes">
<div class="lane main"><b>開発</b><ol><li>実装</li><li>依頼</li><li>修正</li><li class="active">リリース</li></ol></div>
<div class="lane"><b>レビュー当番</b><ol><li>受付</li><li>確認</li><li>承認</li></ol></div>
</div>

<p class="loop">毎週の振り返りで当番の負荷と待ちを見直す</p>

---

<!-- _class: l09 -->

<header class="n01"><ol><li>現状を測る</li><li>待ちを減らす</li><li class="active">週次で出す</li></ol></header>

# 先行チームで確かめた<br>当番制の効果

<div class="split">
<div>

- 4週間、当番制で運用
- 依頼は完成時に1件ずつ
- 振り返りで当番の負荷を調整

</div>
<div class="visual">
<div class="kpis">
<p class="kpi muted"><span class="fig">4.8</span><span class="unit">日</span><span class="label">導入前の放置</span></p>
<p class="kpi"><span class="fig">1.9</span><span class="unit">日</span><span class="label">4週目の放置</span></p>
</div>
</div>
</div>

<p class="band">待ちを減らす鍵は人を増やすことでなく最初の応答の速さ</p>

<!--
_footer: 出典: 見本用の架空データ（先行チームの4週間を想定）
-->

---

<!-- _class: l04 -->

<header class="n01"><ol><li>現状を測る</li><li>待ちを減らす</li><li class="active">週次で出す</li></ol></header>

# 待ちを見える化する<br>1枚のボード

<div class="split">
<div>

- 依頼・確認中・承認済みの3列
- 2日を超えた依頼は線で目立たせる
- 朝会で当番が上から片づける

</div>
<div class="visual">
<svg viewBox="0 0 520 330" width="520" height="330" role="img" aria-label="依頼・確認中・承認済みの3列に依頼カードを並べたボード">
<rect x="0" y="0" width="160" height="330" fill="#ECF2F9"/>
<rect x="180" y="0" width="160" height="330" fill="#ECF2F9"/>
<rect x="360" y="0" width="160" height="330" fill="#ECF2F9"/>
<text x="80" y="38" text-anchor="middle" font-family="Zen Maru Gothic" font-weight="700" font-size="22" fill="#123858">依頼</text>
<text x="260" y="38" text-anchor="middle" font-family="Zen Maru Gothic" font-weight="700" font-size="22" fill="#123858">確認中</text>
<text x="440" y="38" text-anchor="middle" font-family="Zen Maru Gothic" font-weight="700" font-size="22" fill="#123858">承認済み</text>
<rect x="16" y="64" width="128" height="64" fill="#FFFFFF" stroke="#E86A50" stroke-width="4"/>
<text x="80" y="104" text-anchor="middle" font-family="Noto Sans JP" font-size="22" fill="#123858">2日超</text>
<rect x="16" y="144" width="128" height="64" fill="#FFFFFF" stroke="#D5DDE6" stroke-width="2"/>
<rect x="196" y="64" width="128" height="64" fill="#2C63B4"/>
<text x="260" y="104" text-anchor="middle" font-family="Noto Sans JP" font-size="22" fill="#FFFFFF">当番</text>
<rect x="376" y="64" width="128" height="64" fill="#FFFFFF" stroke="#D5DDE6" stroke-width="2"/>
<rect x="376" y="144" width="128" height="64" fill="#FFFFFF" stroke="#D5DDE6" stroke-width="2"/>
<rect x="376" y="224" width="128" height="64" fill="#FFFFFF" stroke="#D5DDE6" stroke-width="2"/>
</svg>
</div>
</div>

---

<!-- _class: l14 -->

<header class="n01"><ol><li>現状を測る</li><li>待ちを減らす</li><li class="active">週次で出す</li></ol></header>

# 4週間で待ちは<br>半分になるか

先行チームでは放置が4.8日から1.9日まで減りました

---

<!-- _class: l12 -->

<header class="n01"><ol><li>現状を測る</li><li>待ちを減らす</li><li class="active">週次で出す</li></ol></header>

# 週次リリースへ移るための<br>3つの合意

<ol class="takeaways">
<li><b>当番制レビューを4週間試す</b><span>来週月曜から開始し、当番表はボードに置く</span></li>
<li><b>待ちを毎週ボードで共有する</b><span>放置が2日を超えた依頼は朝会で扱う</span></li>
<li><b>4週目に週次リリースへ移るか判断する</b><span>判断の材料は放置の日数と当番の負荷</span></li>
</ol>

---

<!-- _class: l18 -->

# ご清聴ありがとう<br>ございました

<p class="subtitle">ご質問・ご意見をお待ちしています</p>
<p class="compact">山田 花子｜決済基盤チーム エンジニア</p>
