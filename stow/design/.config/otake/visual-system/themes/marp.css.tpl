/* OVS components and legacy class adapters. Standard theme is prepended by build.mjs. */

:root {
  --ovs-canvas: {{color.canvas}};
  --ovs-surface: {{color.surface}};
  --ovs-sunken: {{color.sunken}};
  --ovs-ink: {{color.ink}};
  --ovs-ink-sub: {{color.inkSub}};
  --ovs-ink-mute: {{color.inkMute}};
  --ovs-rule: {{color.rule}};
  --ovs-primary: {{color.primary}};
  --ovs-primary-dark: {{color.primaryDark}};
  --ovs-primary-wash: {{color.primaryWash}};
  --ovs-wine: {{color.wine}};
  --ovs-wine-wash: {{color.wineWash}};
  --ovs-coral: {{color.coral}};
  --ovs-coral-wash: {{color.coralWash}};
  --ovs-mint: {{color.mint}};
  --ovs-mint-wash: {{color.mintWash}};
  --ovs-mango: {{color.mango}};
  --ovs-mango-wash: {{color.mangoWash}};
  --ovs-violet: {{color.violet}};
  --ovs-violet-wash: {{color.violetWash}};
}


section.lead {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  padding-right: 16%;
  background: var(--ovs-primary);
  color: var(--ovs-surface);
}

section.lead h1 {
  font-size: 52pt;
}

/* 表紙の発表情報。名前・肩書とイベント名・日付を左下に固定する */
section.lead .meta {
  position: absolute;
  left: 72px;
  bottom: 56px;
  color: var(--ovs-primary-wash);
  font-size: 0.78em;
  line-height: 1.6;
}

section.lead .meta p {
  margin: 0;
}

section.lead .meta strong {
  color: var(--ovs-surface);
}

/* 自己紹介。左に人物（.who）と連絡先（.links）、右に本文（.body）を置く */
section.profile {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  grid-template-rows: auto auto auto;
  grid-template-areas:
    "title title"
    "who body"
    "links body";
  align-content: center;
  column-gap: 48px;
  row-gap: 32px;
}

section.profile > h1 {
  grid-area: title;
  margin-bottom: 0.35em;
}

section.profile > .who,
section.profile > .links {
  display: flex;
  align-items: center;
  gap: 28px;
}

section.profile > .who {
  grid-area: who;
}

section.profile > .links {
  grid-area: links;
  color: var(--ovs-ink-sub);
  font-size: 0.8em;
  line-height: 1.5;
}

/* 顔写真は正方形の画像を円形に切り抜く。屋号マークなど切り抜かない画像は .who.is-mark にする */
section.profile > .who img {
  flex: none;
  box-sizing: border-box;
  width: 180px;
  height: 180px;
  object-fit: cover;
  border: {{stroke.rule}} solid var(--ovs-rule);
  border-radius: 50%;
}

section.profile > .who.is-mark img {
  width: 156px;
  height: 156px;
  object-fit: contain;
  border: 0;
  border-radius: 0;
}

section.profile > .who p {
  color: var(--ovs-ink-sub);
  font-size: 0.9em;
  line-height: 1.7;
}

section.profile > .links img {
  flex: none;
  box-sizing: content-box;
  width: 136px;
  height: 136px;
  padding: 8px;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-rule);
  border-radius: {{radius.control}};
}

section.profile > .who p,
section.profile > .links p {
  margin: 0;
}

section.profile > .who strong {
  color: var(--ovs-ink);
  font-family: {{font.heading}};
  font-size: 1.4em;
  letter-spacing: 0.04em;
}

/* 表示名の読み。表示名の直後に <small> で添える */
section.profile > .who small {
  color: var(--ovs-ink-mute);
  font-size: 0.8em;
  letter-spacing: 0.06em;
}

section.profile > .body {
  grid-area: body;
  align-self: center;
  padding: 28px 32px;
  font-size: 0.92em;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-rule);
  border-radius: {{radius.card}};
}

section.profile > .body li + li {
  margin-top: 0.35em;
}

/* 本題との接点など、項目の太字は色を増やさず本文色の太字にする */
section.profile > .body li strong {
  color: var(--ovs-ink);
}

section.profile > .body > :first-child {
  margin-top: 0;
}

section.profile > .body > :last-child {
  margin-bottom: 0;
}

section.invert {
  color: {{color.nightInk}};
  background: {{color.night}};
}

section.invert h1,
section.invert h2,
section.invert h3,
section.invert strong {
  color: {{color.nightInk}};
}

section.quote {
  margin: 0;
  padding: 56px 72px;
  border: 0;
  background: var(--ovs-canvas);
  display: flex;
  align-items: center;
  justify-content: center;
}

section.quote blockquote {
  max-width: 85%;
  font-family: {{font.heading}};
  font-size: 24pt;
  text-align: left;
}

section.columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  align-items: start;
}

section.columns h1,
section.columns h2 {
  grid-column: 1 / -1;
}

section.timeline .steps,
section.metric .cards {
  display: flex;
  gap: 20px;
  justify-content: space-between;
  margin-bottom: 40px;
}

section.timeline .step,
section.metric .card {
  flex: 1;
  padding: 20px;
  background: var(--ovs-sunken);
  border: 0;
  border-radius: {{radius.card}};
}

/* 例外・変化・行動の一か所だけに使う。本文色にはしない */
section.timeline .step.is-accent,
section.metric .card.is-accent {
  background: var(--ovs-coral-wash);
  border-left: 6px solid var(--ovs-coral);
}

section.timeline .date {
  display: inline-block;
  padding: 0.15em 0.65em;
  color: var(--ovs-surface);
  background: var(--ovs-primary);
  border-radius: {{radius.pill}};
  font-family: {{font.heading}};
  font-size: 16pt;
  font-weight: 700;
}

section.metric .value {
  color: var(--ovs-primary);
  font-family: {{font.numeric}};
  font-size: 2em;
  font-weight: 700;
}

section.metric .change {
  color: var(--ovs-primary-dark);
  font-weight: 700;
}

.ovs-diagram {
  margin: 0;
  overflow: hidden;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-rule);
  border-radius: {{radius.card}};
}

.ovs-diagram > img {
  display: block;
  width: 100%;
  max-height: 470px;
  padding: 18px;
  object-fit: contain;
  background: var(--ovs-canvas);
}

.ovs-diagram > figcaption {
  display: flex;
  gap: 18px;
  align-items: center;
  justify-content: space-between;
  padding: 8px 14px;
  color: var(--ovs-ink-sub);
  background: var(--ovs-sunken);
  border-top: {{stroke.hairline}} solid var(--ovs-rule);
  font-size: 14px;
  line-height: 1.35;
}

.ovs-diagram-meta {
  display: grid;
  gap: 1px;
}

.ovs-diagram-title {
  color: var(--ovs-ink);
  font-family: {{font.heading}};
  font-size: 16px;
}

.ovs-brand {
  display: inline-flex;
  flex: none;
  gap: 7px;
  align-items: center;
  color: var(--ovs-wine);
  font-family: {{font.numeric}};
  font-weight: 700;
  white-space: nowrap;
}

.ovs-marker {
  display: inline-grid;
  grid-template-columns: repeat(3, 5px);
  gap: 2px;
  padding: 3px;
  background: var(--ovs-ink);
  border-radius: 4px;
}

.ovs-marker > i {
  width: 5px;
  height: 10px;
  background: var(--ovs-primary);
  border-radius: 1px;
}

.ovs-marker > i:nth-child(2) {
  height: 7px;
  background: var(--ovs-mango);
}

.ovs-marker > i:nth-child(3) {
  background: var(--ovs-wine);
}

/* 色の面積配分。各spanの比率は style="flex: 数値" で指定する */
.ovs-balance {
  display: flex;
  height: 64px;
  margin: 8px 0 20px;
  overflow: hidden;
  border: {{stroke.rule}} solid var(--ovs-rule);
  border-radius: {{radius.control}};
}

.ovs-balance > .canvas { background: var(--ovs-canvas); }
.ovs-balance > .primary { background: var(--ovs-primary); }
.ovs-balance > .deep { background: var(--ovs-primary-dark); }
.ovs-balance > .soft { background: var(--ovs-primary-wash); }
.ovs-balance > .accent { background: var(--ovs-coral); }

/* Quotes and legacy navigation use the same Standard surface and type roles. */
blockquote {
  margin: 0 0 16px;
  padding: 16px 24px;
  border-left: 6px solid var(--ovs-primary);
  background: var(--ovs-sunken);
  color: var(--ovs-ink);
}

header:not(.n01) strong {
  color: var(--ovs-primary);
  text-decoration: underline;
  text-underline-offset: 4px;
}

section.lead > p,
section.lead > footer,
section.lead > header:not(.n01),
section.lead[data-marpit-pagination]::after,
section.invert > footer,
section.invert > header:not(.n01),
section.invert[data-marpit-pagination]::after {
  color: var(--ovs-primary-wash);
}

section.invert a,
section.invert header:not(.n01) strong {
  color: var(--ovs-surface);
}

section.metric .value .unit {
  font-family: {{font.heading}};
}
