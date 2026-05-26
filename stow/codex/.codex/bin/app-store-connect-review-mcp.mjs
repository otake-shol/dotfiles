#!/usr/bin/env node

import { createReadStream } from "node:fs";
import { readFile } from "node:fs/promises";
import { basename } from "node:path";
import { createInterface } from "node:readline";
import { createSign, createHash } from "node:crypto";

const API_BASE = "https://api.appstoreconnect.apple.com";
const TOKEN_TTL_SECONDS = 20 * 60;
const TOKEN_REFRESH_SKEW_SECONDS = 60;

let cachedToken = null;
let cachedTokenExpiresAt = 0;

const tools = [
  {
    name: "asc_list_apps",
    description: "List apps visible to the App Store Connect API key.",
    inputSchema: {
      type: "object",
      properties: {
        limit: { type: "number", minimum: 1, maximum: 200, default: 50 },
      },
    },
  },
  {
    name: "asc_list_app_store_versions",
    description: "List App Store versions for an app.",
    inputSchema: {
      type: "object",
      required: ["appId"],
      properties: {
        appId: { type: "string" },
        platform: { type: "string", enum: ["IOS", "MAC_OS", "TV_OS", "VISION_OS"] },
        versionState: { type: "string" },
        limit: { type: "number", minimum: 1, maximum: 200, default: 50 },
      },
    },
  },
  {
    name: "asc_get_app_store_review_detail",
    description: "Read App Review contact, demo-account, and notes details for an App Store version.",
    inputSchema: {
      type: "object",
      required: ["appStoreVersionId"],
      properties: {
        appStoreVersionId: { type: "string" },
      },
    },
  },
  {
    name: "asc_create_app_store_review_detail",
    description: "Create App Review contact, demo-account, and notes details for an App Store version.",
    inputSchema: {
      type: "object",
      required: ["appStoreVersionId", "contactFirstName", "contactLastName", "contactPhone", "contactEmail", "demoAccountRequired"],
      properties: reviewDetailProperties({ includePassword: true }),
    },
  },
  {
    name: "asc_update_app_store_review_detail",
    description: "Update App Review contact, demo-account, and notes details.",
    inputSchema: {
      type: "object",
      required: ["reviewDetailId"],
      properties: {
        reviewDetailId: { type: "string" },
        ...reviewDetailProperties({ includeAppStoreVersion: false, includePassword: true }),
      },
    },
  },
  {
    name: "asc_create_app_store_review_attachment",
    description: "Create and upload an App Review attachment file for a review detail.",
    inputSchema: {
      type: "object",
      required: ["reviewDetailId", "filePath"],
      properties: {
        reviewDetailId: { type: "string" },
        filePath: { type: "string", description: "Absolute path to the attachment file." },
      },
    },
  },
];

function reviewDetailProperties({ includeAppStoreVersion = true, includePassword = false } = {}) {
  return {
    ...(includeAppStoreVersion ? { appStoreVersionId: { type: "string" } } : {}),
    contactFirstName: { type: "string" },
    contactLastName: { type: "string" },
    contactPhone: { type: "string" },
    contactEmail: { type: "string" },
    demoAccountRequired: { type: "boolean" },
    demoAccountName: { type: "string" },
    ...(includePassword ? { demoAccountPassword: { type: "string" } } : {}),
    notes: { type: "string" },
  };
}

function base64url(value) {
  return Buffer.from(value).toString("base64url");
}

async function getPrivateKey() {
  const p8Content = process.env.ASC_P8_CONTENT || process.env.APP_STORE_CONNECT_P8_CONTENT;
  if (p8Content) {
    return p8Content.replace(/\\n/g, "\n");
  }

  const keyPath =
    process.env.ASC_P8_PATH ||
    process.env.APP_STORE_CONNECT_P8_PATH ||
    process.env.APP_STORE_CONNECT_API_KEY_KEY_FILEPATH;
  if (!keyPath) {
    throw new Error("ASC_P8_PATH, APP_STORE_CONNECT_P8_PATH, or APP_STORE_CONNECT_API_KEY_KEY_FILEPATH is required");
  }
  return readFile(keyPath, "utf8");
}

async function createJwt() {
  const keyId =
    process.env.ASC_KID ||
    process.env.APP_STORE_CONNECT_KEY_ID ||
    process.env.APP_STORE_CONNECT_API_KEY_KEY_ID;
  const issuerId =
    process.env.ASC_ISSUER_ID ||
    process.env.APP_STORE_CONNECT_ISSUER_ID ||
    process.env.APP_STORE_CONNECT_API_KEY_ISSUER_ID;
  if (!keyId || !issuerId) {
    throw new Error("ASC_KID/ASC_ISSUER_ID or APP_STORE_CONNECT_API_KEY_KEY_ID/APP_STORE_CONNECT_API_KEY_ISSUER_ID are required");
  }

  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedTokenExpiresAt - TOKEN_REFRESH_SKEW_SECONDS > now) {
    return cachedToken;
  }

  const header = { alg: "ES256", kid: keyId, typ: "JWT" };
  const payload = {
    iss: issuerId,
    iat: now,
    exp: now + TOKEN_TTL_SECONDS,
    aud: "appstoreconnect-v1",
  };

  const signingInput = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
  const privateKey = await getPrivateKey();
  const signer = createSign("SHA256");
  signer.update(signingInput);
  signer.end();
  const signature = signer.sign({ key: privateKey, dsaEncoding: "ieee-p1363" });

  cachedToken = `${signingInput}.${signature.toString("base64url")}`;
  cachedTokenExpiresAt = payload.exp;
  return cachedToken;
}

async function request(path, { method = "GET", body, headers = {} } = {}) {
  const token = await createJwt();
  const response = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: "application/json",
      ...(body ? { "Content-Type": "application/json" } : {}),
      ...headers,
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  const text = await response.text();
  const payload = text ? JSON.parse(text) : null;
  if (!response.ok) {
    throw new Error(`App Store Connect API ${response.status}: ${JSON.stringify(payload)}`);
  }
  return payload;
}

function buildQuery(params) {
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && value !== "") {
      query.set(key, String(value));
    }
  }
  const text = query.toString();
  return text ? `?${text}` : "";
}

function relationship(type, id) {
  return { data: { type, id } };
}

function reviewDetailAttributes(args) {
  const allowed = [
    "contactFirstName",
    "contactLastName",
    "contactPhone",
    "contactEmail",
    "demoAccountRequired",
    "demoAccountName",
    "demoAccountPassword",
    "notes",
  ];
  return Object.fromEntries(
    allowed
      .filter((key) => args[key] !== undefined)
      .map((key) => [key, args[key]]),
  );
}

async function uploadAttachmentAsset(attachment, filePath) {
  const operations = attachment?.data?.attributes?.uploadOperations;
  if (!Array.isArray(operations) || operations.length === 0) {
    throw new Error("No upload operations returned for App Review attachment");
  }

  const file = await readFile(filePath);
  for (const operation of operations) {
    const headers = Object.fromEntries((operation.requestHeaders ?? []).map((item) => [item.name, item.value]));
    const offset = operation.offset ?? 0;
    const length = operation.length ?? file.length;
    const uploadResponse = await fetch(operation.url, {
      method: operation.method,
      headers,
      body: file.subarray(offset, offset + length),
    });
    if (!uploadResponse.ok) {
      throw new Error(`Attachment upload failed ${uploadResponse.status}: ${await uploadResponse.text()}`);
    }
  }
}

async function checksum(filePath, algorithm) {
  const hash = createHash(algorithm);
  await new Promise((resolve, reject) => {
    createReadStream(filePath)
      .on("data", (chunk) => hash.update(chunk))
      .on("error", reject)
      .on("end", resolve);
  });
  return hash.digest("hex");
}

async function handleTool(name, args = {}) {
  switch (name) {
    case "asc_list_apps":
      return request(`/v1/apps${buildQuery({ limit: args.limit ?? 50 })}`);
    case "asc_list_app_store_versions":
      return request(
        `/v1/apps/${encodeURIComponent(args.appId)}/appStoreVersions${buildQuery({
          limit: args.limit ?? 50,
          "filter[platform]": args.platform,
          "filter[appStoreState]": args.versionState,
        })}`,
      );
    case "asc_get_app_store_review_detail":
      return request(
        `/v1/appStoreVersions/${encodeURIComponent(args.appStoreVersionId)}/appStoreReviewDetail${buildQuery({
          include: "appStoreReviewAttachments",
        })}`,
      );
    case "asc_create_app_store_review_detail":
      return request("/v1/appStoreReviewDetails", {
        method: "POST",
        body: {
          data: {
            type: "appStoreReviewDetails",
            attributes: reviewDetailAttributes(args),
            relationships: {
              appStoreVersion: relationship("appStoreVersions", args.appStoreVersionId),
            },
          },
        },
      });
    case "asc_update_app_store_review_detail":
      return request(`/v1/appStoreReviewDetails/${encodeURIComponent(args.reviewDetailId)}`, {
        method: "PATCH",
        body: {
          data: {
            type: "appStoreReviewDetails",
            id: args.reviewDetailId,
            attributes: reviewDetailAttributes(args),
          },
        },
      });
    case "asc_create_app_store_review_attachment": {
      const fileName = basename(args.filePath);
      const fileSize = (await (await import("node:fs/promises")).stat(args.filePath)).size;
      const sourceFileChecksum = await checksum(args.filePath, "md5");
      const attachment = await request("/v1/appStoreReviewAttachments", {
        method: "POST",
        body: {
          data: {
            type: "appStoreReviewAttachments",
            attributes: { fileName, fileSize },
            relationships: {
              appStoreReviewDetail: relationship("appStoreReviewDetails", args.reviewDetailId),
            },
          },
        },
      });
      await uploadAttachmentAsset(attachment, args.filePath);
      return request(`/v1/appStoreReviewAttachments/${encodeURIComponent(attachment.data.id)}`, {
        method: "PATCH",
        body: {
          data: {
            type: "appStoreReviewAttachments",
            id: attachment.data.id,
            attributes: { uploaded: true, sourceFileChecksum },
          },
        },
      });
    }
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

function respond(id, result) {
  process.stdout.write(`${JSON.stringify({ jsonrpc: "2.0", id, result })}\n`);
}

function respondError(id, error) {
  process.stdout.write(
    `${JSON.stringify({
      jsonrpc: "2.0",
      id,
      error: { code: -32000, message: redact(String(error?.message ?? error)) },
    })}\n`,
  );
}

function redact(text) {
  return text
    .replace(/Bearer\s+[A-Za-z0-9._-]+/g, "Bearer [REDACTED]")
    .replace(/-----BEGIN PRIVATE KEY-----[\s\S]*?-----END PRIVATE KEY-----/g, "[REDACTED_PRIVATE_KEY]");
}

async function handleMessage(message) {
  const { id, method, params } = message;
  try {
    if (method === "initialize") {
      respond(id, {
        protocolVersion: "2024-11-05",
        capabilities: { tools: {} },
        serverInfo: { name: "app-store-connect-review", version: "0.1.0" },
      });
      return;
    }
    if (method === "notifications/initialized") {
      return;
    }
    if (method === "tools/list") {
      respond(id, { tools });
      return;
    }
    if (method === "tools/call") {
      const result = await handleTool(params.name, params.arguments);
      respond(id, {
        content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
      });
      return;
    }
    respondError(id, new Error(`Unsupported method: ${method}`));
  } catch (error) {
    respondError(id, error);
  }
}

const lines = createInterface({ input: process.stdin });
lines.on("line", (line) => {
  if (!line.trim()) {
    return;
  }
  try {
    void handleMessage(JSON.parse(line));
  } catch (error) {
    respondError(null, error);
  }
});
