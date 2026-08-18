import { test } from "node:test";
import assert from "node:assert/strict";
import {
  GENERATED_SESSIONS,
  OFFICIAL_INDEX,
  allCatalogTracks,
  findTrack,
  formatDuration,
  generatedAsTracks,
  officialAsTracks,
  searchTracks,
  uniqueMoods,
} from "../src/catalog.js";

test("generated sessions are unique, playable, and have recipes", () => {
  const ids = new Set();
  for (const track of generatedAsTracks()) {
    assert.equal(track.kind, "generated");
    assert.equal(track.playable, true);
    assert.ok(track.recipe?.scale?.length);
    assert.ok(track.recipe.bpm > 0);
    assert.ok(track.durationSec > 0);
    assert.ok(!ids.has(track.id), `duplicate id ${track.id}`);
    ids.add(track.id);
  }
  assert.equal(GENERATED_SESSIONS.length, 12);
});

test("official index is metadata-only", () => {
  for (const track of officialAsTracks()) {
    assert.equal(track.kind, "official");
    assert.equal(track.playable, false);
    assert.ok(track.links.vgmdb.startsWith("https://"));
    assert.equal(track.recipe, undefined);
  }
  assert.ok(OFFICIAL_INDEX.some((item) => item.title === "Amadeus"));
});

test("catalog helpers search, format, and look up tracks", () => {
  const tracks = allCatalogTracks();
  assert.equal(tracks.length, GENERATED_SESSIONS.length + OFFICIAL_INDEX.length);
  assert.equal(findTrack("wl-el-psy")?.title, "El Psy Kongroo");
  assert.equal(findTrack("missing"), null);
  assert.equal(formatDuration(238), "3:58");
  assert.equal(formatDuration(5), "0:05");
  const hits = searchTracks(tracks, "divergence");
  assert.equal(hits[0].id, "wl-divergence");
  assert.ok(uniqueMoods(generatedAsTracks()).includes("ambient"));
});
