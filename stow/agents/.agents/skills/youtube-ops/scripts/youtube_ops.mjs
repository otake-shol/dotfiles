#!/usr/bin/env node

import {
  constants as fsConstants,
  copyFile,
  mkdir,
  readFile,
  stat,
  writeFile,
} from "node:fs/promises";
import { dirname, isAbsolute, join, normalize, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const skillDirectory = dirname(scriptDirectory);
const assetDirectory = join(skillDirectory, "assets");

const statuses = [
  "seed",
  "researched",
  "outlined",
  "scripted",
  "visualized",
  "packaged",
  "approved",
  "published",
  "measured",
];
const gateNames = [
  "concept",
  "outline",
  "master_script",
  "thumbnail",
  "publish",
];
const claimKinds = new Set(["fact", "observation", "inference", "opinion"]);
const sourceKinds = new Set(["external", "local"]);
const learningValidityModes = new Set(["evergreen", "time_sensitive"]);

function usage() {
  process.stdout.write(`Usage:
  node scripts/youtube_ops.mjs init-channel <channel-directory>
  node scripts/youtube_ops.mjs init-episode <channel-directory> <slug> [YYYY-MM-DD]
  node scripts/youtube_ops.mjs validate-channel <channel-directory|channel.json>
  node scripts/youtube_ops.mjs validate <episode-directory|episode.json> [--publish]
`);
}

function fail(message) {
  process.stderr.write(`ERROR: ${message}\n`);
  process.exitCode = 1;
}

function isObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function localDate() {
  const parts = new Intl.DateTimeFormat("en", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(new Date());
  const values = Object.fromEntries(parts.map(({ type, value }) => [type, value]));
  return `${values.year}-${values.month}-${values.day}`;
}

function isValidDate(value) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }
  const parsed = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(parsed.valueOf()) && parsed.toISOString().slice(0, 10) === value;
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

async function copyExclusive(source, destination) {
  await copyFile(source, destination, fsConstants.COPYFILE_EXCL);
}

async function readJson(path) {
  try {
    return JSON.parse(await readFile(path, "utf8"));
  } catch (error) {
    throw new Error(`${path}をJSONとして読めません: ${error.message}`);
  }
}

function addRequiredString(errors, value, path) {
  if (!isNonEmptyString(value)) {
    errors.push(`${path}を空でない文字列にしてください`);
  }
}

function addNonEmptyArray(errors, value, path) {
  if (!Array.isArray(value) || value.length === 0) {
    errors.push(`${path}を1件以上の配列にしてください`);
  }
}

function collectUniqueIds(errors, items, path) {
  const ids = new Set();
  if (!Array.isArray(items)) {
    errors.push(`${path}を配列にしてください`);
    return ids;
  }
  items.forEach((item, index) => {
    const id = item?.id;
    if (!isNonEmptyString(id)) {
      errors.push(`${path}[${index}].idを空でない文字列にしてください`);
      return;
    }
    if (ids.has(id)) {
      errors.push(`${path}のid「${id}」が重複しています`);
    }
    ids.add(id);
  });
  return ids;
}

function isSafeRelativePath(value) {
  if (!isNonEmptyString(value) || isAbsolute(value)) {
    return false;
  }
  const normalized = normalize(value).replaceAll("\\", "/");
  return normalized !== ".." && !normalized.startsWith("../");
}

async function initChannel(args) {
  if (args.length !== 1) {
    usage();
    throw new Error("init-channelにはchannel-directoryが必要です");
  }

  const root = resolve(args[0]);
  const channelPath = join(root, "channel.json");
  const notesPath = join(root, "channel-notes.md");
  const correctionsPath = join(root, "logs", "corrections.jsonl");
  const protectedPaths = [channelPath, notesPath, correctionsPath];

  for (const path of protectedPaths) {
    if (await pathExists(path)) {
      throw new Error(`既存ファイルを保護するため初期化を中止しました: ${path}`);
    }
  }

  await mkdir(join(root, "episodes"), { recursive: true });
  await mkdir(join(root, "library", "visuals"), { recursive: true });
  await mkdir(join(root, "library", "characters"), { recursive: true });
  await mkdir(join(root, "library", "audio"), { recursive: true });
  await mkdir(join(root, "library", "prompts"), { recursive: true });
  await mkdir(join(root, "logs"), { recursive: true });

  await copyExclusive(join(assetDirectory, "channel.template.json"), channelPath);
  await copyExclusive(join(assetDirectory, "channel-notes.template.md"), notesPath);
  await writeFile(correctionsPath, "", { encoding: "utf8", flag: "wx" });

  process.stdout.write(`チャンネル作業場所を初期化しました: ${root}\n`);
  process.stdout.write("channel.jsonとchannel-notes.mdを埋めてからvalidate-channelを実行してください。\n");
}

async function initEpisode(args) {
  if (args.length < 2 || args.length > 3) {
    usage();
    throw new Error("init-episodeにはchannel-directory、slug、任意の日付が必要です");
  }

  const root = resolve(args[0]);
  const slug = args[1];
  const date = args[2] ?? localDate();

  if (!(await pathExists(join(root, "channel.json")))) {
    throw new Error(`${root}にchannel.jsonがありません`);
  }
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) {
    throw new Error("slugは小文字英数字をハイフンでつないでください");
  }
  if (!isValidDate(date)) {
    throw new Error("日付は実在するYYYY-MM-DD形式にしてください");
  }

  const id = `${date}-${slug}`;
  const episodeDirectory = join(root, "episodes", id);
  if (await pathExists(episodeDirectory)) {
    throw new Error(`既存episodeを保護するため初期化を中止しました: ${episodeDirectory}`);
  }

  await mkdir(episodeDirectory, { recursive: false });
  const rawTemplate = await readFile(join(assetDirectory, "episode.template.json"), "utf8");
  const episodeJson = rawTemplate
    .replaceAll("__ID__", id)
    .replaceAll("__DATE__", date)
    .replaceAll("__SLUG__", slug);
  await writeFile(join(episodeDirectory, "episode.json"), episodeJson, {
    encoding: "utf8",
    flag: "wx",
  });

  const markdownTemplates = ["brief", "research", "review", "performance"];
  for (const name of markdownTemplates) {
    await copyExclusive(
      join(assetDirectory, `${name}.template.md`),
      join(episodeDirectory, `${name}.md`),
    );
  }

  process.stdout.write(`episodeを初期化しました: ${episodeDirectory}\n`);
}

async function resolveJsonPath(input, filename) {
  const target = resolve(input);
  const targetStat = await stat(target);
  return targetStat.isDirectory() ? join(target, filename) : target;
}

function validateChannelData(data) {
  const errors = [];
  let characterIds = new Set();
  if (data?.schema_version !== 1) {
    errors.push("schema_versionは1にしてください");
  }
  if (!isObject(data?.channel)) {
    errors.push("channelをオブジェクトにしてください");
  } else {
    addRequiredString(errors, data.channel.name, "channel.name");
    addRequiredString(errors, data.channel.promise, "channel.promise");
    addRequiredString(errors, data.channel.primary_language, "channel.primary_language");
    addNonEmptyArray(errors, data.channel.audiences, "channel.audiences");
    addNonEmptyArray(errors, data.channel.pillars, "channel.pillars");
  }
  if (!isObject(data?.editorial)) {
    errors.push("editorialをオブジェクトにしてください");
  } else {
    addNonEmptyArray(errors, data.editorial.voice, "editorial.voice");
    addNonEmptyArray(errors, data.editorial.title_rules, "editorial.title_rules");
    addNonEmptyArray(errors, data.editorial.source_policy, "editorial.source_policy");
  }
  if (!isObject(data?.visual_system)) {
    errors.push("visual_systemをオブジェクトにしてください");
  } else {
    addRequiredString(errors, data.visual_system.long_aspect_ratio, "visual_system.long_aspect_ratio");
    addRequiredString(errors, data.visual_system.short_aspect_ratio, "visual_system.short_aspect_ratio");
    addNonEmptyArray(errors, data.visual_system.template_ids, "visual_system.template_ids");
  }
  if (!Array.isArray(data?.characters)) {
    errors.push("charactersを配列にしてください");
  } else if (data.characters.length > 0) {
    characterIds = collectUniqueIds(errors, data.characters, "characters");
    data.characters.forEach((character, index) => {
      addRequiredString(errors, character?.role, `characters[${index}].role`);
      addNonEmptyArray(errors, character?.voice, `characters[${index}].voice`);
      if (character?.asset !== undefined) {
        if (!isObject(character.asset)) {
          errors.push(`characters[${index}].assetをオブジェクトにしてください`);
        } else {
          addRequiredString(errors, character.asset.authority, `characters[${index}].asset.authority`);
          addRequiredString(errors, character.asset.path, `characters[${index}].asset.path`);
          addRequiredString(errors, character.asset.revision, `characters[${index}].asset.revision`);
          if (isNonEmptyString(character.asset.path) && !isSafeRelativePath(character.asset.path)) {
            errors.push(`characters[${index}].asset.pathは安全な相対パスにしてください`);
          }
          if (
            isNonEmptyString(character.asset.revision) &&
            !/^sha256:[a-f0-9]{64}$/.test(character.asset.revision)
          ) {
            errors.push(`characters[${index}].asset.revisionはsha256:に64桁の小文字16進数を続けてください`);
          }
        }
      }
      if (character?.presentation !== undefined) {
        if (!isObject(character.presentation)) {
          errors.push(`characters[${index}].presentationをオブジェクトにしてください`);
        } else {
          if (!Number.isInteger(character.presentation.maximum_per_frame) || character.presentation.maximum_per_frame < 1) {
            errors.push(`characters[${index}].presentation.maximum_per_frameを1以上の整数にしてください`);
          }
          addNonEmptyArray(
            errors,
            character.presentation.visible_placements,
            `characters[${index}].presentation.visible_placements`,
          );
          addNonEmptyArray(
            errors,
            character.presentation.excluded_placements,
            `characters[${index}].presentation.excluded_placements`,
          );
          addNonEmptyArray(
            errors,
            character.presentation.transform_policy,
            `characters[${index}].presentation.transform_policy`,
          );
        }
      }
    });
  }
  if (data?.integrations !== undefined) {
    if (!Array.isArray(data.integrations)) {
      errors.push("integrationsを配列にしてください");
    } else {
      collectUniqueIds(errors, data.integrations, "integrations");
      data.integrations.forEach((integration, index) => {
        addRequiredString(errors, integration?.kind, `integrations[${index}].kind`);
        if (integration?.kind === "learning_product") {
          addRequiredString(errors, integration?.adapter, `integrations[${index}].adapter`);
          addRequiredString(errors, integration?.content_authority, `integrations[${index}].content_authority`);
          if (integration?.character_id !== undefined) {
            addRequiredString(errors, integration.character_id, `integrations[${index}].character_id`);
            if (isNonEmptyString(integration.character_id) && !characterIds.has(integration.character_id)) {
              errors.push(`integrations[${index}].character_id「${integration.character_id}」がcharactersにありません`);
            }
          }
          addRequiredString(errors, integration?.app_scheme, `integrations[${index}].app_scheme`);
          addRequiredString(errors, integration?.landing_base_url, `integrations[${index}].landing_base_url`);
          if (
            isNonEmptyString(integration?.landing_base_url) &&
            !/^https:\/\//.test(integration.landing_base_url)
          ) {
            errors.push(`integrations[${index}].landing_base_urlはhttps URLにしてください`);
          }
          addNonEmptyArray(
            errors,
            integration?.allowed_analytics_dimensions,
            `integrations[${index}].allowed_analytics_dimensions`,
          );
          addNonEmptyArray(
            errors,
            integration?.prohibited_analytics_dimensions,
            `integrations[${index}].prohibited_analytics_dimensions`,
          );
        }
      });
    }
  }
  if (!Array.isArray(data?.human_gates)) {
    errors.push("human_gatesを配列にしてください");
  } else {
    for (const gate of gateNames) {
      if (!data.human_gates.includes(gate)) {
        errors.push(`human_gatesに${gate}を含めてください`);
      }
    }
  }
  return errors;
}

function validateEpisodeData(data, publishMode, channelData = null) {
  const errors = [];
  if (data?.schema_version !== 1) {
    errors.push("schema_versionは1にしてください");
  }
  addRequiredString(errors, data?.id, "id");
  if (!statuses.includes(data?.status)) {
    errors.push(`statusは${statuses.join("、")}のいずれかにしてください`);
  }
  if (!isValidDate(data?.created_at ?? "")) {
    errors.push("created_atをYYYY-MM-DD形式にしてください");
  }
  if (!isValidDate(data?.updated_at ?? "")) {
    errors.push("updated_atをYYYY-MM-DD形式にしてください");
  }

  if (!isObject(data?.topic)) {
    errors.push("topicをオブジェクトにしてください");
  } else {
    for (const field of [
      "slug",
      "working_title",
      "user_intent",
      "target_audience",
      "viewer_problem",
      "promise",
      "angle",
    ]) {
      addRequiredString(errors, data.topic[field], `topic.${field}`);
    }
  }

  const statusIndex = Math.max(statuses.indexOf(data?.status), publishMode ? statuses.indexOf("approved") : -1);
  let sourceIds = new Set();
  let sectionIds = new Set();
  let visualIds = new Set();
  const characterIds = new Set(channelData?.characters?.map((character) => character.id) ?? []);
  const templateIds = new Set(channelData?.visual_system?.template_ids ?? []);
  const integrationIds = new Map(
    channelData?.integrations?.map((integration) => [integration.id, integration]) ?? [],
  );

  if (data?.learning_target !== undefined && data.learning_target !== null) {
    const target = data.learning_target;
    if (!isObject(target)) {
      errors.push("learning_targetをオブジェクトまたはnullにしてください");
    } else {
      addRequiredString(errors, target.integration_id, "learning_target.integration_id");
      addRequiredString(errors, target.subject_id, "learning_target.subject_id");
      addNonEmptyArray(errors, target.concept_ids, "learning_target.concept_ids");
      if (!Array.isArray(target.visual_asset_ids)) {
        errors.push("learning_target.visual_asset_idsを配列にしてください");
      }

      const integration = integrationIds.get(target.integration_id);
      if (!integration) {
        errors.push(`learning_target.integration_id「${target.integration_id ?? ""}」がchannel.jsonにありません`);
      } else if (integration.kind !== "learning_product") {
        errors.push(`learning_target.integration_id「${target.integration_id}」はlearning_productではありません`);
      }

      if (!isObject(target.validity)) {
        errors.push("learning_target.validityをオブジェクトにしてください");
      } else {
        if (!learningValidityModes.has(target.validity.mode)) {
          errors.push("learning_target.validity.modeはevergreenまたはtime_sensitiveにしてください");
        }
        if (target.validity.mode === "time_sensitive") {
          addRequiredString(errors, target.validity.exam_year, "learning_target.validity.exam_year");
          if (!isValidDate(target.validity.review_by ?? "")) {
            errors.push("learning_target.validity.review_byをYYYY-MM-DD形式にしてください");
          }
        }
      }

      if (!isObject(target.entry)) {
        errors.push("learning_target.entryをオブジェクトにしてください");
      } else {
        addRequiredString(errors, target.entry.landing_path, "learning_target.entry.landing_path");
        addRequiredString(errors, target.entry.app_deep_link, "learning_target.entry.app_deep_link");
        if (isNonEmptyString(target.entry.landing_path) && !target.entry.landing_path.startsWith("/")) {
          errors.push("learning_target.entry.landing_pathは/で始めてください");
        }
        if (
          integration &&
          isNonEmptyString(target.entry.app_deep_link) &&
          !target.entry.app_deep_link.startsWith(`${integration.app_scheme}://`)
        ) {
          errors.push(`learning_target.entry.app_deep_linkは${integration.app_scheme}://で始めてください`);
        }
      }

      if (!isObject(target.practice)) {
        errors.push("learning_target.practiceをオブジェクトにしてください");
      } else {
        addRequiredString(errors, target.practice.mode, "learning_target.practice.mode");
        addRequiredString(errors, target.practice.cta, "learning_target.practice.cta");
      }

      if (!isObject(target.analytics)) {
        errors.push("learning_target.analyticsをオブジェクトにしてください");
      } else {
        addRequiredString(errors, target.analytics.source, "learning_target.analytics.source");
        addNonEmptyArray(errors, target.analytics.dimensions, "learning_target.analytics.dimensions");
        const allowed = new Set(integration?.allowed_analytics_dimensions ?? []);
        const prohibited = new Set(integration?.prohibited_analytics_dimensions ?? []);
        for (const dimension of target.analytics.dimensions ?? []) {
          if (allowed.size > 0 && !allowed.has(dimension)) {
            errors.push(`learning_target.analytics.dimensionsの「${dimension}」は許可されていません`);
          }
          if (prohibited.has(dimension)) {
            errors.push(`learning_target.analytics.dimensionsの「${dimension}」は禁止されています`);
          }
        }
      }
    }
  }

  if (statusIndex >= statuses.indexOf("researched")) {
    addNonEmptyArray(errors, data?.sources, "sources");
    addNonEmptyArray(errors, data?.claims, "claims");
    sourceIds = collectUniqueIds(errors, data?.sources, "sources");
    data?.sources?.forEach((source, index) => {
      addRequiredString(errors, source?.title, `sources[${index}].title`);
      addRequiredString(errors, source?.publisher, `sources[${index}].publisher`);
      addRequiredString(errors, source?.accessed_at, `sources[${index}].accessed_at`);
      const sourceKind = source?.kind ?? (isNonEmptyString(source?.url) ? "external" : "local");
      if (!sourceKinds.has(sourceKind)) {
        errors.push(`sources[${index}].kindはexternalまたはlocalにしてください`);
      } else if (sourceKind === "external") {
        addRequiredString(errors, source?.url, `sources[${index}].url`);
        if (isNonEmptyString(source?.url) && !/^https:\/\//.test(source.url)) {
          errors.push(`sources[${index}].urlはhttps URLにしてください`);
        }
      } else {
        addRequiredString(errors, source?.path, `sources[${index}].path`);
        addRequiredString(errors, source?.locator, `sources[${index}].locator`);
        addRequiredString(errors, source?.revision, `sources[${index}].revision`);
        if (isNonEmptyString(source?.path) && !isSafeRelativePath(source.path)) {
          errors.push(`sources[${index}].pathは安全な相対パスにしてください`);
        }
        if (isNonEmptyString(source?.revision) && !/^sha256:[a-f0-9]{64}$/.test(source.revision)) {
          errors.push(`sources[${index}].revisionはsha256:に64桁の小文字16進数を続けてください`);
        }
      }
    });

    collectUniqueIds(errors, data?.claims, "claims");
    data?.claims?.forEach((claim, index) => {
      addRequiredString(errors, claim?.text, `claims[${index}].text`);
      if (!claimKinds.has(claim?.kind)) {
        errors.push(`claims[${index}].kindはfact、observation、inference、opinionのいずれかにしてください`);
      }
      const claimSourceIds = Array.isArray(claim?.source_ids) ? claim.source_ids : [];
      if (claim?.kind === "fact" && claimSourceIds.length === 0) {
        errors.push(`claims[${index}]のfactにはsource_idsが必要です`);
      }
      for (const sourceId of claimSourceIds) {
        if (!sourceIds.has(sourceId)) {
          errors.push(`claims[${index}]が未知のsource ID「${sourceId}」を参照しています`);
        }
      }
    });
  }

  if (statusIndex >= statuses.indexOf("outlined")) {
    if (!Array.isArray(data?.outline) || data.outline.length < 3) {
      errors.push("outlineを3件以上にしてください");
    }
    sectionIds = collectUniqueIds(errors, data?.outline, "outline");
    data?.outline?.forEach((section, index) => {
      addRequiredString(errors, section?.title, `outline[${index}].title`);
      addRequiredString(errors, section?.purpose, `outline[${index}].purpose`);
    });

    if (data?.character_direction !== undefined) {
      const direction = data.character_direction;
      if (!isObject(direction)) {
        errors.push("character_directionをオブジェクトにしてください");
      } else {
        addRequiredString(errors, direction.character_id, "character_direction.character_id");
        addRequiredString(errors, direction.narration_mode, "character_direction.narration_mode");
        addRequiredString(errors, direction.voice_status, "character_direction.voice_status");
        addNonEmptyArray(errors, direction.visible_sections, "character_direction.visible_sections");
        if (!Array.isArray(direction.transition_sections)) {
          errors.push("character_direction.transition_sectionsを配列にしてください");
        }
        addNonEmptyArray(
          errors,
          direction.hidden_content_types,
          "character_direction.hidden_content_types",
        );
        if (characterIds.size > 0 && !characterIds.has(direction.character_id)) {
          errors.push(`character_direction.character_id「${direction.character_id ?? ""}」がcharactersにありません`);
        }
        for (const field of ["visible_sections", "transition_sections"]) {
          for (const sectionId of direction[field] ?? []) {
            if (!sectionIds.has(sectionId)) {
              errors.push(`character_direction.${field}が未知のsection ID「${sectionId}」を参照しています`);
            }
          }
        }
      }
    }
  }

  if (statusIndex >= statuses.indexOf("scripted")) {
    addNonEmptyArray(errors, data?.script?.lines, "script.lines");
    collectUniqueIds(errors, data?.script?.lines, "script.lines");
    data?.script?.lines?.forEach((line, index) => {
      addRequiredString(errors, line?.speaker, `script.lines[${index}].speaker`);
      addRequiredString(errors, line?.text, `script.lines[${index}].text`);
      if (characterIds.size > 0 && !characterIds.has(line?.speaker)) {
        errors.push(`script.lines[${index}]が未知のcharacter ID「${line?.speaker ?? ""}」を参照しています`);
      }
      if (!sectionIds.has(line?.section_id)) {
        errors.push(`script.lines[${index}]が未知のsection ID「${line?.section_id ?? ""}」を参照しています`);
      }
      const lineSourceIds = Array.isArray(line?.source_ids) ? line.source_ids : [];
      for (const sourceId of lineSourceIds) {
        if (!sourceIds.has(sourceId)) {
          errors.push(`script.lines[${index}]が未知のsource ID「${sourceId}」を参照しています`);
        }
      }
    });
  }

  if (statusIndex >= statuses.indexOf("visualized")) {
    addNonEmptyArray(errors, data?.visuals, "visuals");
    visualIds = collectUniqueIds(errors, data?.visuals, "visuals");
    data?.visuals?.forEach((visual, index) => {
      addRequiredString(errors, visual?.type, `visuals[${index}].type`);
      addRequiredString(errors, visual?.template_id, `visuals[${index}].template_id`);
      addRequiredString(errors, visual?.purpose, `visuals[${index}].purpose`);
      if (templateIds.size > 0 && !templateIds.has(visual?.template_id)) {
        errors.push(`visuals[${index}]が未知のtemplate ID「${visual?.template_id ?? ""}」を参照しています`);
      }
      if (visual?.qa_status !== "passed") {
        errors.push(`visuals[${index}].qa_statusをpassedにしてください`);
      }
      const visualSourceIds = Array.isArray(visual?.source_ids) ? visual.source_ids : [];
      for (const sourceId of visualSourceIds) {
        if (!sourceIds.has(sourceId)) {
          errors.push(`visuals[${index}]が未知のsource ID「${sourceId}」を参照しています`);
        }
      }
    });
    data?.script?.lines?.forEach((line, index) => {
      if (!visualIds.has(line?.visual_id)) {
        errors.push(`script.lines[${index}]が未知のvisual ID「${line?.visual_id ?? ""}」を参照しています`);
      }
    });
  }

  if (statusIndex >= statuses.indexOf("packaged")) {
    const longPackage = data?.packages?.long;
    if (!Array.isArray(longPackage?.title_candidates) || longPackage.title_candidates.length < 3) {
      errors.push("packages.long.title_candidatesを3件以上にしてください");
    }
    addRequiredString(errors, longPackage?.selected_title, "packages.long.selected_title");
    if (
      isNonEmptyString(longPackage?.selected_title) &&
      Array.isArray(longPackage?.title_candidates) &&
      !longPackage.title_candidates.includes(longPackage.selected_title)
    ) {
      errors.push("packages.long.selected_titleをtitle_candidatesから選んでください");
    }
    addRequiredString(errors, longPackage?.description, "packages.long.description");
    const copy = longPackage?.thumbnail?.copy;
    if (!Array.isArray(copy) || copy.length < 1 || copy.length > 2) {
      errors.push("packages.long.thumbnail.copyを1〜2件にしてください");
    }
    addRequiredString(errors, longPackage?.thumbnail?.layout_id, "packages.long.thumbnail.layout_id");
    if (longPackage?.thumbnail?.qa_status !== "passed") {
      errors.push("packages.long.thumbnail.qa_statusをpassedにしてください");
    }
    addNonEmptyArray(errors, data?.packages?.shorts, "packages.shorts");
    collectUniqueIds(errors, data?.packages?.shorts, "packages.shorts");
    data?.packages?.shorts?.forEach((short, index) => {
      addRequiredString(errors, short?.hook, `packages.shorts[${index}].hook`);
      addNonEmptyArray(errors, short?.script_lines, `packages.shorts[${index}].script_lines`);
      short?.script_lines?.forEach((line, lineIndex) => {
        addRequiredString(errors, line, `packages.shorts[${index}].script_lines[${lineIndex}]`);
      });
      addNonEmptyArray(errors, short?.visual_ids, `packages.shorts[${index}].visual_ids`);
      short?.visual_ids?.forEach((visualId) => {
        if (!visualIds.has(visualId)) {
          errors.push(`packages.shorts[${index}]が未知のvisual ID「${visualId}」を参照しています`);
        }
      });
      addRequiredString(errors, short?.cta, `packages.shorts[${index}].cta`);
    });
  }

  if (statusIndex >= statuses.indexOf("approved")) {
    if (!isObject(data?.human_gates)) {
      errors.push("human_gatesをオブジェクトにしてください");
    } else {
      for (const gate of gateNames) {
        if (data.human_gates[gate] !== "approved") {
          errors.push(`human_gates.${gate}をapprovedにしてください`);
        }
      }
    }
    data?.reviews?.forEach((review, reviewIndex) => {
      review?.findings?.forEach((finding, findingIndex) => {
        if (finding?.severity === "blocking" && finding?.resolved !== true) {
          errors.push(`reviews[${reviewIndex}].findings[${findingIndex}]に未解決のblocking指摘があります`);
        }
      });
    });
  }

  if (statusIndex >= statuses.indexOf("published") && !publishMode) {
    addRequiredString(errors, data?.publication?.url, "publication.url");
    addRequiredString(errors, data?.publication?.published_at, "publication.published_at");
    if (isNonEmptyString(data?.publication?.url) && !/^https:\/\//.test(data.publication.url)) {
      errors.push("publication.urlをhttps URLにしてください");
    }
  }

  if (statusIndex >= statuses.indexOf("measured") && !publishMode) {
    addRequiredString(errors, data?.metrics?.captured_at, "metrics.captured_at");
    addRequiredString(errors, data?.metrics?.window, "metrics.window");
    const metricNames = [
      "impressions",
      "click_through_rate",
      "retention_30_seconds",
      "average_view_duration_seconds",
      "average_percentage_viewed",
      "watch_time_hours",
      "subscriber_change",
    ];
    if (!metricNames.some((name) => typeof data?.metrics?.[name] === "number")) {
      errors.push("metricsへ数値指標を1件以上記録してください");
    }
  }

  return errors;
}

function printValidationResult(label, errors) {
  if (errors.length === 0) {
    process.stdout.write(`OK: ${label}\n`);
    return;
  }
  process.stderr.write(`NG: ${label}\n`);
  for (const error of errors) {
    process.stderr.write(`- ${error}\n`);
  }
  process.exitCode = 1;
}

async function validateChannel(args) {
  if (args.length !== 1) {
    usage();
    throw new Error("validate-channelにはchannel-directoryまたはchannel.jsonが必要です");
  }
  const path = await resolveJsonPath(args[0], "channel.json");
  const data = await readJson(path);
  printValidationResult(path, validateChannelData(data));
}

async function validateEpisode(args) {
  const publishMode = args.includes("--publish");
  const positional = args.filter((value) => value !== "--publish");
  if (positional.length !== 1 || args.some((value) => value.startsWith("--") && value !== "--publish")) {
    usage();
    throw new Error("validateにはepisode-directoryまたはepisode.jsonと任意の--publishが必要です");
  }
  const path = await resolveJsonPath(positional[0], "episode.json");
  const data = await readJson(path);
  const channelPath = join(dirname(dirname(dirname(path))), "channel.json");
  let channelData = null;
  const errors = [];
  if (await pathExists(channelPath)) {
    channelData = await readJson(channelPath);
    errors.push(...validateChannelData(channelData).map((error) => `channel.json: ${error}`));
  }
  errors.push(...validateEpisodeData(data, publishMode, channelData));
  printValidationResult(path, errors);
}

async function main() {
  const [command, ...args] = process.argv.slice(2);
  if (!command || command === "help" || command === "--help" || command === "-h") {
    usage();
    return;
  }

  switch (command) {
    case "init-channel":
      await initChannel(args);
      break;
    case "init-episode":
      await initEpisode(args);
      break;
    case "validate-channel":
      await validateChannel(args);
      break;
    case "validate":
      await validateEpisode(args);
      break;
    default:
      usage();
      throw new Error(`未知のcommandです: ${command}`);
  }
}

main().catch((error) => fail(error.message));
