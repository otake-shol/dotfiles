#!/usr/bin/env node

import { createHash } from "node:crypto";
import { readFile, stat } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";

const formulaSourcePath = "constants/cheatsheet-data.ts";
const figureRegistryPath = "assets/cheatsheet-figures/index.ts";

function usage() {
  process.stdout.write(`Usage:
  node scripts/learning_product.mjs inspect shindanshi-app <app-root> <concept-id>
  node scripts/learning_product.mjs validate shindanshi-app <episode-directory|episode.json> <app-root>
`);
}

function fail(message) {
  process.stderr.write(`ERROR: ${message}\n`);
  process.exitCode = 1;
}

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

async function pathExists(path) {
  try {
    await stat(path);
    return true;
  } catch (error) {
    if (error?.code === "ENOENT") {
      return false;
    }
    throw error;
  }
}

async function readJson(path) {
  try {
    return JSON.parse(await readFile(path, "utf8"));
  } catch (error) {
    throw new Error(`${path}をJSONとして読めません: ${error.message}`);
  }
}

function findObjectStart(source, markerIndex) {
  const start = source.lastIndexOf("{", markerIndex);
  if (start < 0) {
    throw new Error("論点オブジェクトの開始位置を検出できません");
  }
  return start;
}

function extractObjectBlock(source, conceptId) {
  const markers = [`id: "${conceptId}"`, `id: '${conceptId}'`];
  const markerIndex = markers
    .map((marker) => source.indexOf(marker))
    .filter((index) => index >= 0)
    .sort((a, b) => a - b)[0];
  if (markerIndex === undefined) {
    throw new Error(`論点ID「${conceptId}」が${formulaSourcePath}にありません`);
  }

  const start = findObjectStart(source, markerIndex);
  let depth = 0;
  let quote = null;
  let escaped = false;

  for (let index = start; index < source.length; index += 1) {
    const character = source[index];
    if (quote !== null) {
      if (escaped) {
        escaped = false;
      } else if (character === "\\") {
        escaped = true;
      } else if (character === quote) {
        quote = null;
      }
      continue;
    }
    if (character === '"' || character === "'" || character === "`") {
      quote = character;
      continue;
    }
    if (character === "{") {
      depth += 1;
    } else if (character === "}") {
      depth -= 1;
      if (depth === 0) {
        return source.slice(start, index + 1);
      }
    }
  }
  throw new Error(`論点ID「${conceptId}」のオブジェクト終端を検出できません`);
}

function extractStringField(block, field, required = true) {
  const match = block.match(new RegExp(`\\b${field}\\s*:\\s*["']([^"']+)["']`));
  if (!match && required) {
    throw new Error(`論点オブジェクトに${field}がありません`);
  }
  return match?.[1] ?? null;
}

function extractNumberField(block, field) {
  const match = block.match(new RegExp(`\\b${field}\\s*:\\s*(\\d+)`));
  return match ? Number(match[1]) : null;
}

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

async function validateCharacterContract(errors, channel, integration, appRoot) {
  if (!integration.character_id) {
    return;
  }

  const character = channel.characters?.find(
    (candidate) => candidate.id === integration.character_id,
  );
  if (!character) {
    errors.push(`character_id「${integration.character_id}」がchannel charactersにありません`);
    return;
  }

  if (integration.character_id === "q-guide" && channel.characters.length !== 1) {
    errors.push("CoreQ動画のキャラクターはキュー1体だけにしてください");
  }
  if (character.asset?.authority !== integration.content_authority) {
    errors.push("キュー原画のauthorityがcontent_authorityと一致しません");
  }
  if (!character.asset?.path || !character.asset?.revision) {
    errors.push("キュー原画のpathとrevisionがありません");
  } else {
    const assetPath = resolve(appRoot, character.asset.path);
    if (!assetPath.startsWith(`${appRoot}/`)) {
      errors.push("キュー原画のpathをアプリ内の相対パスにしてください");
    } else if (!(await pathExists(assetPath))) {
      errors.push(`キュー原画がありません: ${character.asset.path}`);
    } else {
      const actualRevision = `sha256:${sha256(await readFile(assetPath))}`;
      if (character.asset.revision !== actualRevision) {
        errors.push("キュー原画の参照ハッシュが現在のアプリ資産と一致しません");
      }
    }
  }

  if (character.presentation?.maximum_per_frame !== 1) {
    errors.push("キューは1画面1体にしてください");
  }
  const requiredExclusions = [
    "question_body",
    "formula",
    "explanation",
    "learning_diagram",
  ];
  const excluded = new Set(character.presentation?.excluded_placements ?? []);
  for (const placement of requiredExclusions) {
    if (!excluded.has(placement)) {
      errors.push(`キューのexcluded_placementsに${placement}を含めてください`);
    }
  }
}

async function inspectConcept(appRoot, conceptId) {
  const source = await readFile(join(appRoot, formulaSourcePath), "utf8");
  const block = extractObjectBlock(source, conceptId);
  return {
    id: extractStringField(block, "id"),
    subject: extractStringField(block, "subject"),
    category: extractStringField(block, "category"),
    name: extractStringField(block, "name"),
    importance: extractNumberField(block, "importance"),
    figure_id: extractStringField(block, "figureId", false),
    source: {
      kind: "local",
      path: formulaSourcePath,
      locator: `CHEATSHEET_FORMULAS[id=${conceptId}]`,
      revision: `sha256:${sha256(block)}`,
    },
  };
}

async function resolveEpisodePath(input) {
  const target = resolve(input);
  const targetStat = await stat(target);
  return targetStat.isDirectory() ? join(target, "episode.json") : target;
}

function matchingLocalSource(episode, conceptId) {
  return episode.sources?.find(
    (source) =>
      source.kind === "local" &&
      source.path === formulaSourcePath &&
      source.locator === `CHEATSHEET_FORMULAS[id=${conceptId}]`,
  );
}

function validateDeepLink(errors, deepLink, integration, target) {
  let parsed;
  try {
    parsed = new URL(deepLink);
  } catch {
    errors.push("learning_target.entry.app_deep_linkをURLとして解釈できません");
    return;
  }
  if (parsed.protocol !== `${integration.app_scheme}:`) {
    errors.push(`Deep Linkのschemeを${integration.app_scheme}にしてください`);
  }
  const route = `/${parsed.hostname}${parsed.pathname}`.replace(/\/$/, "");
  if (route !== "/cheatsheet/formulas") {
    errors.push("CoreQのDeep Linkは/cheatsheet/formulasへ着地させてください");
  }
  if (parsed.searchParams.get("subject") !== target.subject_id) {
    errors.push("Deep Linkのsubjectがlearning_target.subject_idと一致しません");
  }
  if (parsed.searchParams.get("focus") !== target.concept_ids[0]) {
    errors.push("Deep Linkのfocusが先頭のconcept_idと一致しません");
  }
}

async function validateShindanshi(episodeInput, appRootInput) {
  const episodePath = await resolveEpisodePath(episodeInput);
  const episode = await readJson(episodePath);
  const channelPath = join(dirname(dirname(dirname(episodePath))), "channel.json");
  const channel = await readJson(channelPath);
  const appRoot = resolve(appRootInput);
  const errors = [];
  const target = episode.learning_target;

  if (!isObject(target)) {
    errors.push("episode.jsonにlearning_targetがありません");
  }
  const integration = channel.integrations?.find(
    (candidate) => candidate.id === target?.integration_id,
  );
  if (!integration) {
    errors.push("learning_targetに対応するchannel integrationがありません");
  } else if (integration.adapter !== "shindanshi-app") {
    errors.push("channel integrationのadapterがshindanshi-appではありません");
  }

  if (integration?.adapter === "shindanshi-app") {
    await validateCharacterContract(errors, channel, integration, appRoot);
  }

  if (errors.length === 0) {
    const concepts = [];
    for (const conceptId of target.concept_ids) {
      try {
        const concept = await inspectConcept(appRoot, conceptId);
        concepts.push(concept);
        if (concept.subject !== target.subject_id) {
          errors.push(`論点ID「${conceptId}」の科目が${target.subject_id}ではありません`);
        }
        const source = matchingLocalSource(episode, conceptId);
        if (!source) {
          errors.push(`論点ID「${conceptId}」に対応するlocal sourceがありません`);
        } else if (source.revision !== concept.source.revision) {
          errors.push(`論点ID「${conceptId}」の参照ハッシュが現在の教材と一致しません`);
        }
      } catch (error) {
        errors.push(error.message);
      }
    }

    const expectedFigureIds = new Set(
      concepts.map((concept) => concept.figure_id).filter(Boolean),
    );
    const targetFigureIds = new Set(target.visual_asset_ids);
    for (const figureId of expectedFigureIds) {
      if (!targetFigureIds.has(figureId)) {
        errors.push(`論点が参照する図解ID「${figureId}」がvisual_asset_idsにありません`);
      }
    }

    const registry = await readFile(join(appRoot, figureRegistryPath), "utf8");
    for (const figureId of targetFigureIds) {
      const figurePath = join(appRoot, "assets", "cheatsheet-figures", `${figureId}.svg`);
      if (!(await pathExists(figurePath))) {
        errors.push(`図解ファイルがありません: assets/cheatsheet-figures/${figureId}.svg`);
      }
      if (!registry.includes(`"${figureId}":`)) {
        errors.push(`図解ID「${figureId}」が${figureRegistryPath}にありません`);
      }
    }

    validateDeepLink(errors, target.entry.app_deep_link, integration, target);
    const appConfig = await readJson(join(appRoot, "app.json"));
    if (appConfig?.expo?.scheme !== integration.app_scheme) {
      errors.push("channel integrationのapp_schemeがapp.jsonと一致しません");
    }
  }

  if (errors.length > 0) {
    process.stderr.write(`NG: ${episodePath}\n`);
    for (const error of errors) {
      process.stderr.write(`- ${error}\n`);
    }
    process.exitCode = 1;
    return;
  }
  process.stdout.write(`OK: ${episodePath}\n`);
}

async function main() {
  const [command, adapter, ...args] = process.argv.slice(2);
  if (!command || command === "help" || command === "--help" || command === "-h") {
    usage();
    return;
  }
  if (adapter !== "shindanshi-app") {
    throw new Error(`未対応の学習プロダクトアダプターです: ${adapter ?? ""}`);
  }
  if (command === "inspect" && args.length === 2) {
    const result = await inspectConcept(resolve(args[0]), args[1]);
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    return;
  }
  if (command === "validate" && args.length === 2) {
    await validateShindanshi(args[0], args[1]);
    return;
  }
  usage();
  throw new Error("引数が正しくありません");
}

main().catch((error) => fail(error.message));
