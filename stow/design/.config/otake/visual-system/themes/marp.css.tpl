/*
 * @theme otake-visual
 * @auto-scaling true
 * @size 16:9 1280px 720px
 * Generated from OVS tokens.json.
 */

@import "default";

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

section {
  box-sizing: border-box;
  width: 1280px;
  height: 720px;
  padding: 56px 72px;
  color: var(--ovs-ink);
  background: var(--ovs-canvas);
  font-family: {{font.body}};
  font-size: 28px;
  line-height: 1.55;
}

section::before {
  position: absolute;
  inset: 0 auto 0 0;
  width: 10px;
  content: "";
  background: linear-gradient(
    180deg,
    var(--ovs-primary) 0 70%,
    var(--ovs-wine) 70% 100%
  );
}

h1,
h2,
h3 {
  color: var(--ovs-ink);
  font-family: {{font.heading}};
}

h1 {
  margin: 0 0 0.65em;
  font-size: 1.75em;
  line-height: 1.25;
}

h1::after {
  display: block;
  width: 96px;
  height: 7px;
  margin-top: 16px;
  content: "";
  background: var(--ovs-primary);
  border-radius: 999px;
}

h2 {
  color: var(--ovs-primary-dark);
  font-size: 1.35em;
}

h3 {
  color: var(--ovs-wine);
  font-size: 1.05em;
}

a {
  color: var(--ovs-primary-dark);
  text-decoration-thickness: 2px;
}

strong {
  color: var(--ovs-wine);
}

mark {
  padding: 0.08em 0.3em;
  color: var(--ovs-ink);
  background: {{color.yellow}};
  border-radius: {{radius.control}};
}

code {
  padding: 0.1em 0.35em;
  color: var(--ovs-primary-dark);
  background: var(--ovs-primary-wash);
  border-radius: 6px;
  font-family: {{font.mono}};
}

pre {
  padding: 0.8em 1em;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-ink);
  border-radius: {{radius.card}};
  box-shadow: {{shadow.x}} {{shadow.y}} 0 var(--ovs-ink);
}

pre code {
  padding: 0;
  color: var(--ovs-ink);
  background: transparent;
}

blockquote {
  padding: 0.75em 1em;
  color: var(--ovs-ink);
  background: var(--ovs-primary-wash);
  border: {{stroke.rule}} solid var(--ovs-ink);
  border-left: 10px solid var(--ovs-primary);
  border-radius: {{radius.card}};
}

table {
  width: 100%;
  overflow: hidden;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-ink);
  border-collapse: separate;
  border-spacing: 0;
  border-radius: {{radius.card}};
  box-shadow: {{shadow.smallX}} {{shadow.smallY}} 0 var(--ovs-ink);
}

th,
td {
  padding: 0.45em 0.65em;
  border-color: var(--ovs-rule);
}

th {
  color: var(--ovs-primary-dark);
  background: var(--ovs-primary-wash);
}

li::marker {
  color: var(--ovs-primary);
}

section.lead {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  padding-right: 26%;
  background:
    radial-gradient(circle at 90% 12%, var(--ovs-wine-wash) 0 70px, transparent 72px),
    radial-gradient(circle at 88% 10%, var(--ovs-primary-wash) 0 150px, transparent 152px),
    var(--ovs-canvas);
}

section.lead h1 {
  font-size: 2.15em;
}

section.invert {
  color: {{color.nightInk}};
  background: {{color.night}};
}

section.invert::before {
  background: linear-gradient(
    180deg,
    var(--ovs-primary) 0 70%,
    var(--ovs-wine) 70% 100%
  );
}

section.invert h1,
section.invert h2,
section.invert h3,
section.invert strong {
  color: {{color.nightInk}};
}

section.quote {
  display: flex;
  align-items: center;
  justify-content: center;
}

section.quote blockquote {
  max-width: 85%;
  font-family: {{font.heading}};
  font-size: 1.35em;
  text-align: center;
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
}

section.timeline .step,
section.metric .card {
  flex: 1;
  padding: 20px;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-ink);
  border-radius: {{radius.card}};
  box-shadow: {{shadow.smallX}} {{shadow.smallY}} 0 var(--ovs-ink);
}

section.timeline .date {
  display: inline-block;
  padding: 0.15em 0.65em;
  color: var(--ovs-surface);
  background: var(--ovs-primary);
  border-radius: {{radius.pill}};
  font-family: {{font.numeric}};
  font-size: 0.75em;
  font-weight: 700;
}

section.metric .value {
  color: var(--ovs-primary);
  font-family: {{font.numeric}};
  font-size: 2em;
  font-weight: 700;
}

section.metric .change {
  color: var(--ovs-mint);
  font-weight: 700;
}

.ovs-diagram {
  margin: 0;
  overflow: hidden;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-ink);
  border-radius: {{radius.card}};
  box-shadow: {{shadow.x}} {{shadow.y}} 0 var(--ovs-ink);
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

footer,
section::after {
  color: var(--ovs-ink-mute);
  font-size: 0.58em;
}
