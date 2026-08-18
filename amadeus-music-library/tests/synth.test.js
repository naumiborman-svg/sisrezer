import { test } from "node:test";
import assert from "node:assert/strict";
import { GENERATED_SESSIONS } from "../src/catalog.js";
import { beatDuration, buildNotePlan, midiToFreq, stepToMidi } from "../src/synth.js";

test("tuning math matches concert pitch", () => {
  assert.equal(Math.round(midiToFreq(69)), 440);
  assert.equal(stepToMidi(60, [0, 2, 4, 5, 7, 9, 11], 0), 60);
  assert.equal(stepToMidi(60, [0, 2, 4, 5, 7, 9, 11], 7), 72);
  assert.equal(beatDuration(120), 0.5);
});

test("every generated recipe produces a note plan covering its duration", () => {
  for (const track of GENERATED_SESSIONS) {
    const plan = buildNotePlan(track.recipe, track.durationSec);
    assert.ok(plan.notes.length > 8, track.id);
    assert.ok(plan.notes.at(-1).at < track.durationSec);
    assert.ok(plan.notes.every((note) => Number.isFinite(note.midi)));
  }
});
