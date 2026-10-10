#!/usr/bin/env node
import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join, resolve } from "node:path";

// Read-only discovery. Does not render, approve, update, or publish anything.
const [channelArg, questionId, extra] = process.argv.slice(2);
assert(channelArg && questionId && !extra, "Usage: inspect-set.mjs <channel-directory> <exam-subject-NNN>");
assert(/^exam-[a-z]+-\d{3}$/.test(questionId), "Specify subject and three-digit question number");
const channel = resolve(channelArg);
const read = path => JSON.parse(readFileSync(path, "utf8"));
const sha = path => createHash("sha256").update(readFileSync(path)).digest("hex");
const dirs = path => existsSync(path) ? readdirSync(path, { withFileTypes: true }).filter(x => x.isDirectory() && /^[a-z0-9-]+$/.test(x.name)).map(x => x.name).sort() : [];
const catalog = read(join(channel, "plans/curriculum/curriculum.json"));
const question = catalog.questions.find(q => q.question_id === questionId);
assert(question, `Question not found in curriculum: ${questionId}`);
const foundations = question.foundation_ids.map(id => {
  const item = catalog.foundations.find(f => f.id === id);
  assert(item, `Missing foundation: ${id}`);
  return { id, title: item.title, episode_id: item.existing_video?.episode_id ?? null, scope: item.existing_video?.scope ?? null, limitations: item.existing_video?.limitations ?? null, applicability: "needs_question_specific_review" };
});
const episodes = new Map();
for (const id of dirs(join(channel, "episodes"))) {
  const path = join(channel, "episodes", id, "episode.json");
  if (!existsSync(path)) continue;
  const episode = read(path);
  assert.equal(episode.id, id, `Episode ID mismatch: ${id}`);
  episodes.set(id, { episode, revision: sha(path) });
}
const applications = new Set([
  ...(question.application_video?.episode_id ? [question.application_video.episode_id] : []),
  ...[...episodes].filter(([_id, v]) => !["short", "foundation"].includes(v.episode.derivation?.kind) && v.episode.origin?.education_refs?.some(r => r.id === questionId)).map(([id]) => id)
]);
const selected = new Set([...applications, ...foundations.map(f => f.episode_id).filter(Boolean)]);
// Only follow registered derivation edges, never a numeric filename match.
for (let size = -1; size !== selected.size;) {
  size = selected.size;
  for (const [id, { episode }] of episodes) if (selected.has(episode.derivation?.source_episode_id)) selected.add(id);
}
const jobs = [];
for (const id of dirs(join(channel, ".studio/runs"))) {
  const path = join(channel, ".studio/runs", id, "job.json");
  if (!existsSync(path)) continue;
  const job = read(path);
  if (selected.has(job.episodeId)) jobs.push(job);
}
jobs.sort((a, b) => (a.createdAt ?? "").localeCompare(b.createdAt ?? "") || a.id.localeCompare(b.id));
function outputState(id, revision, mode, filename) {
  const relevant = jobs.filter(j => j.episodeId === id && j.mode === mode);
  const last = relevant.filter(j => j.status === "succeeded").at(-1);
  const path = last && join(channel, ".studio/runs", last.id, "episodes", id, "output", filename);
  const source = last && join(channel, ".studio/runs", last.id, "episodes", id, "episode.json");
  const snapshotMatches = mode !== "all" || Boolean(source && existsSync(source) && sha(source) === last.revision);
  const current = Boolean(last && last.revision === revision && existsSync(path) && snapshotMatches);
  const receiptPath = join(channel, ".studio/reviews", `${id}${mode === "x" ? "-x" : ""}.json`);
  const receipt = existsSync(receiptPath) ? read(receiptPath) : null;
  const reviewed = Boolean(current && receipt?.revision === revision && receipt?.job_id === last.id);
  return { state: !last ? "not_generated" : !existsSync(path) ? "missing_asset" : current ? "generated_current" : "stale_or_mismatched", job_id: last?.id ?? null, revision: last?.revision ?? null, human_review: reviewed ? "recorded_for_this_job" : "pending", latest_attempt: relevant.at(-1)?.status ?? null };
}
const records = [...selected].sort().map(id => {
  const data = episodes.get(id);
  if (!data) return { episode_id: id, state: "missing_episode" };
  const { episode, revision } = data;
  const parent = episode.derivation?.source_episode_id;
  const parentCurrent = parent ? episodes.get(parent)?.revision === episode.derivation.source_revision : null;
  const role = episode.derivation?.kind === "short" ? "short_candidate" : applications.has(id) ? "application" : "foundation_candidate";
  const xPath = join(channel, "episodes", id, "x-post.json");
  let x = { state: "not_created" };
  if (existsSync(xPath)) {
    const post = read(xPath), postRevision = sha(xPath);
    const sourceCurrent = post.source_episode_id === id && post.source_revision === revision;
    x = { ...outputState(id, postRevision, "x", "social-card.png"), post_revision: postRevision, source_current: sourceCurrent };
    if (!sourceCurrent) { x.state = "stale_source"; x.human_review = "pending"; }
  }
  return { episode_id: id, role, title: episode.topic.working_title, revision,
    derivation_source: parent ? { episode_id: parent, current: parentCurrent } : null,
    video: outputState(id, revision, "all", "video.mp4"),
    source_verification: "not_checked_against_current_app", x,
    publication: episode.publication?.url ? "url_recorded_unverified" : "not_recorded" };
});
const number = question.number;
const publicationDir = question.subject === "accounting" ? `set-${number}` : `set-${question.subject}-${number}`;
const next = [];
if (!records.some(r => r.role === "application")) next.push("Create or import the question-specific application episode");
for (const r of records) {
  if (r.state === "missing_episode") next.push(`Locate or create missing episode: ${r.episode_id}`);
  if (r.video && r.video.state !== "generated_current") next.push(`Inspect and complete video: ${r.episode_id} (${r.video.state})`);
  if (r.derivation_source?.current === false) next.push(`Review changed derivation source before reusing: ${r.episode_id}`);
}
next.push("Verify current app source revisions and foundation applicability before editing");
if (!records.some(r => r.role === "short_candidate")) next.push("If short-form expansion is requested, author one standalone question for Shorts/TikTok");
if (!records.some(r => r.x?.state !== "not_created" && r.x)) next.push("If X expansion is requested, draft text and one diagram from the selected short");
const result = { schema_version: 1, question: { id: questionId, title: question.title, subject: question.subject, curriculum_revision: question.source_revision, revision_scheme: catalog.revision_scheme, supplements: question.supplements, supplemental_review: question.supplemental_review }, foundations, episodes: records,
  publication_files: Object.fromEntries(["draft.json", "set.json"].map(name => [name, existsSync(join(channel, "publication", publicationDir, name))])),
  publication_directory: `publication/${publicationDir}`, next_actions: next,
  caveats: ["Candidates are not automatically approved for this question", "Current means episode/job/artifact consistency, not source accuracy or human approval", "Episode revisions are raw-byte SHA-256; curriculum uses its declared revision scheme"] };
console.log(JSON.stringify(result, null, 2));
