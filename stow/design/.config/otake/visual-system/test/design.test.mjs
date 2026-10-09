import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import test from "node:test";
import { rootDir } from "../scripts/core.mjs";

const tokens = JSON.parse(readFileSync(resolve(rootDir, "tokens.json"), "utf8"));
const storyCss = readFileSync(
  resolve(rootDir, "../../../.agents/skills/create-story-slides/assets/story-slides.css"),
  "utf8",
);
const properties = Object.fromEntries(
  [...storyCss.matchAll(/--([a-z-]+):\s*([^;]+);/g)].map((match) => [
    match[1], match[2].trim().replaceAll('"', "'").toLowerCase(),
  ]),
);

test("OVS colors and fonts stay aligned with the Standard slide profile", () => {
  const colors = {
    canvas: "warm-canvas", surface: "white", sunken: "pale-blue",
    ink: "ink", inkSub: "muted-ink", inkMute: "muted-ink", rule: "mist-gray",
    primary: "primary-blue", primaryDark: "deep-navy", primaryWash: "primary-soft",
    coral: "accent-orange", coralWash: "accent-soft", night: "deep-navy",
  };
  for (const [token, property] of Object.entries(colors)) {
    assert.equal(tokens.color[token].toLowerCase(), properties[property], token);
  }
  // Compatibility aliases must not reintroduce the former multicolor palette.
  const palette = new Set(Object.values(properties).filter((value) => /^#[0-9a-f]{6}$/.test(value)));
  for (const color of Object.values(tokens.color)) {
    assert.ok(palette.has(color.toLowerCase()), color);
  }
  for (const [token, property] of Object.entries({
    heading: "font-title", body: "font-body", numeric: "font-figure",
  })) {
    assert.equal(tokens.font[token].toLowerCase(), properties[property], token);
  }
});

test("OVS Marp output reuses the complete Standard theme", () => {
  const css = readFileSync(resolve(rootDir, "generated/marp.css"), "utf8");
  assert.ok(css.startsWith(storyCss.replace("@theme story-slides", "@theme otake-visual")));
  assert.equal((css.match(/@theme /g) ?? []).length, 1);
});
