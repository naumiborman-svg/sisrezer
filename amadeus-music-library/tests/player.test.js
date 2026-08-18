import { test } from "node:test";
import assert from "node:assert/strict";
import { createPlayer, REPEAT } from "../src/player.js";
import { generatedAsTracks, officialAsTracks } from "../src/catalog.js";

function fakeBackend() {
  const calls = [];
  return {
    calls,
    play: async (track) => {
      calls.push(["play", track.id]);
    },
    pause: () => calls.push(["pause"]),
    resume: () => calls.push(["resume"]),
    stop: () => calls.push(["stop"]),
    seek: (seconds) => calls.push(["seek", seconds]),
    setVolume: (volume) => calls.push(["volume", volume]),
  };
}

test("player plays a generated queue and skips to next", async () => {
  const backend = fakeBackend();
  const tracks = generatedAsTracks().slice(0, 3);
  const player = createPlayer({ backend });
  player.setQueue(tracks);
  await player.play(tracks[0].id);
  assert.equal(player.getState().current.id, tracks[0].id);
  assert.equal(player.getState().playing, true);
  await player.next();
  assert.equal(player.getState().current.id, tracks[1].id);
  player.pause();
  assert.equal(player.getState().playing, false);
  assert.ok(backend.calls.some((call) => call[0] === "pause"));
});

test("official tracks are refused", async () => {
  const player = createPlayer({ backend: fakeBackend() });
  const official = officialAsTracks()[0];
  await player.play(official, [official]);
  assert.equal(player.getState().playing, false);
  assert.match(player.getState().error, /metadata only/i);
});

test("repeat, mute, volume, and previous-restart behave", async () => {
  const backend = fakeBackend();
  const tracks = generatedAsTracks().slice(0, 2);
  const player = createPlayer({ backend });
  await player.play(tracks[0], tracks);
  player.cycleRepeat();
  assert.equal(player.getState().repeat, REPEAT.ALL);
  player.cycleRepeat();
  assert.equal(player.getState().repeat, REPEAT.ONE);
  player.setVolume(0.4);
  assert.equal(player.getState().volume, 0.4);
  player.toggleMute();
  assert.equal(player.getState().muted, true);
  player.seek(12);
  await player.previous();
  assert.equal(player.getState().currentTime, 0);
  assert.ok(backend.calls.some((call) => call[0] === "seek" && call[1] === 0));
});

test("repeat one stays on the same track after ended", async () => {
  const backend = fakeBackend();
  const tracks = generatedAsTracks().slice(0, 2);
  const player = createPlayer({ backend });
  await player.play(tracks[0], tracks);
  player.cycleRepeat();
  player.cycleRepeat();
  await player.next({ fromEnded: true });
  assert.equal(player.getState().current.id, tracks[0].id);
});
