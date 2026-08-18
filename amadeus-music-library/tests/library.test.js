import { test } from "node:test";
import assert from "node:assert/strict";
import {
  addToPlaylist,
  createLocalTrack,
  createPlaylist,
  deletePlaylist,
  emptyLibraryState,
  isAudioFile,
  loadLibraryState,
  memoryStorage,
  removeFromPlaylist,
  saveLibraryState,
  toggleFavorite,
  tracksForPlaylist,
} from "../src/library.js";

test("favorites and playlists persist through storage", () => {
  const storage = memoryStorage();
  let state = emptyLibraryState();
  state = toggleFavorite(state, "wl-el-psy");
  const created = createPlaylist(state, "Lab mix");
  state = addToPlaylist(created.state, created.playlist.id, "wl-el-psy");
  saveLibraryState(state, storage);

  const loaded = loadLibraryState(storage);
  assert.deepEqual(loaded.favorites, ["wl-el-psy"]);
  assert.equal(loaded.playlists[0].name, "Lab mix");
  assert.deepEqual(
    tracksForPlaylist(loaded.playlists[0], [{ id: "wl-el-psy", title: "El Psy Kongroo" }]).map((track) => track.title),
    ["El Psy Kongroo"],
  );

  state = removeFromPlaylist(loaded, loaded.playlists[0].id, "wl-el-psy");
  state = deletePlaylist(state, state.playlists[0].id);
  assert.equal(state.playlists.length, 0);
});

test("local track helpers accept audio files only", () => {
  assert.equal(isAudioFile({ type: "audio/mpeg", name: "x.mp3" }), true);
  assert.equal(isAudioFile({ type: "", name: "lab.flac" }), true);
  assert.equal(isAudioFile({ type: "image/png", name: "art.png" }), false);
  const track = createLocalTrack(
    { name: "Reading Steiner.wav", type: "audio/wav", size: 2048 },
    { id: "local-1", objectUrl: "blob:1" },
  );
  assert.equal(track.title, "Reading Steiner");
  assert.equal(track.kind, "local");
  assert.equal(track.playable, true);
});
