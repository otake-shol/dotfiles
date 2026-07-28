/*
 * Otake Visual System document theme.
 * Generated from OVS tokens.json.
 */

:root {
  color-scheme: light;
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
  --ovs-mango: {{color.mango}};
  --ovs-mango-wash: {{color.mangoWash}};
}

* {
  box-sizing: border-box;
}

html {
  background: var(--ovs-canvas);
}

body {
  max-width: 960px;
  margin: 0 auto;
  padding: 64px 32px 96px;
  color: var(--ovs-ink);
  background: var(--ovs-canvas);
  font-family: {{font.body}};
  font-size: 18px;
  line-height: 1.8;
}

h1,
h2,
h3 {
  color: var(--ovs-ink);
  font-family: {{font.heading}};
  line-height: 1.35;
}

h1 {
  margin: 0 0 1.25em;
  font-size: 2.4rem;
}

h1::after {
  display: block;
  width: 96px;
  height: 7px;
  margin-top: 18px;
  content: "";
  background: var(--ovs-primary);
  border-radius: {{radius.pill}};
}

h2 {
  margin-top: 2.2em;
  color: var(--ovs-primary-dark);
  font-size: 1.65rem;
}

h3 {
  color: var(--ovs-wine);
}

a {
  color: var(--ovs-primary-dark);
  text-decoration-thickness: 2px;
}

strong {
  color: var(--ovs-wine);
}

code {
  padding: 0.12em 0.35em;
  color: var(--ovs-primary-dark);
  background: var(--ovs-primary-wash);
  border-radius: 6px;
  font-family: {{font.mono}};
}

pre,
blockquote,
table {
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-ink);
  border-radius: {{radius.card}};
  box-shadow: {{shadow.smallX}} {{shadow.smallY}} 0 var(--ovs-ink);
}

pre {
  padding: 1em 1.2em;
  overflow-x: auto;
}

pre code {
  padding: 0;
  color: var(--ovs-ink);
  background: transparent;
}

blockquote {
  margin-inline: 0;
  padding: 0.75em 1.2em;
  background: var(--ovs-primary-wash);
  border-left: 10px solid var(--ovs-primary);
}

table {
  width: 100%;
  overflow: hidden;
  border-collapse: separate;
  border-spacing: 0;
}

th,
td {
  padding: 0.55em 0.75em;
  border-color: var(--ovs-rule);
}

th {
  color: var(--ovs-primary-dark);
  background: var(--ovs-primary-wash);
}

.ovs-diagram {
  margin: 2.5em 0;
  overflow: hidden;
  background: var(--ovs-surface);
  border: {{stroke.rule}} solid var(--ovs-ink);
  border-radius: {{radius.card}};
  box-shadow: {{shadow.x}} {{shadow.y}} 0 var(--ovs-ink);
}

.ovs-diagram > img {
  display: block;
  width: 100%;
  max-height: 680px;
  padding: 28px;
  object-fit: contain;
  background: var(--ovs-canvas);
}

.ovs-diagram > figcaption {
  display: flex;
  gap: 20px;
  align-items: center;
  justify-content: space-between;
  padding: 12px 18px;
  color: var(--ovs-ink-sub);
  background: var(--ovs-sunken);
  border-top: {{stroke.hairline}} solid var(--ovs-rule);
  font-size: 0.78rem;
}

.ovs-diagram-meta {
  display: grid;
  gap: 2px;
}

.ovs-diagram-title {
  color: var(--ovs-ink);
  font-family: {{font.heading}};
  font-size: 0.92rem;
}

.ovs-brand {
  display: inline-flex;
  flex: none;
  gap: 8px;
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

@media (max-width: 640px) {
  body {
    padding: 36px 18px 64px;
  }

  .ovs-diagram > img {
    padding: 12px;
  }

  .ovs-diagram > figcaption {
    align-items: flex-start;
    flex-direction: column;
  }
}
