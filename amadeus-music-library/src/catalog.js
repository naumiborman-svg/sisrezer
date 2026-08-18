/** Official Steins;Gate 0 / Amadeus soundtrack metadata. No audio is bundled. */
export const OFFICIAL_INDEX = [
  {
    id: "official-amadeus-op",
    title: "Amadeus",
    artist: "Kanako Ito",
    album: "Amadeus",
    year: 2015,
    catalogNo: "FVCG-1354",
    durationSec: 238,
    role: "STEINS;GATE 0 visual novel opening",
    links: {
      vgmdb: "https://vgmdb.net/album/54230",
      generasia: "https://www.generasia.com/wiki/Amadeus_(Ito_Kanako)",
    },
  },
  {
    id: "official-ignis",
    title: "Ignis",
    artist: "Kanako Ito",
    album: "Amadeus",
    year: 2015,
    catalogNo: "FVCG-1354",
    durationSec: 306,
    role: "Coupling track on the Amadeus single",
    links: {
      vgmdb: "https://vgmdb.net/album/54230",
    },
  },
  {
    id: "official-aion-hichou",
    title: "Aion Hichou no Amadeus ~ Makise Kurisu",
    artist: "Asami Imai",
    album: "Amadeus",
    year: 2015,
    catalogNo: "FVCG-1354",
    durationSec: 312,
    role: "Monologue drama track",
    links: {
      vgmdb: "https://vgmdb.net/album/54230",
    },
  },
  {
    id: "official-gate-of-steiner-0",
    title: "GATE OF STEINER",
    artist: "Takeshi Abo",
    album: "STEINS;GATE 0 O.S.T",
    year: 2015,
    catalogNo: "FVCG-1355",
    durationSec: 0,
    role: "Series motif / STEINS;GATE 0 OST",
    links: {
      vgmdb: "https://vgmdb.net/album/54229",
    },
  },
  {
    id: "official-amadeus-system",
    title: "Amadeus",
    artist: "Takeshi Abo",
    album: "STEINS;GATE 0 O.S.T",
    year: 2015,
    catalogNo: "FVCG-1355",
    durationSec: 0,
    role: "Amadeus system motif",
    links: {
      vgmdb: "https://vgmdb.net/album/54229",
    },
  },
];

const SCALES = {
  minor: [0, 2, 3, 5, 7, 8, 10],
  harmonicMinor: [0, 2, 3, 5, 7, 8, 11],
  dorian: [0, 2, 3, 5, 7, 9, 10],
  pentatonic: [0, 3, 5, 7, 10],
  major: [0, 2, 4, 5, 7, 9, 11],
};

function generated(partial) {
  return {
    kind: "generated",
    artist: "Worldline Synth",
    album: "Amadeus Library · Lab Sessions",
    year: 2026,
    ...partial,
    recipe: {
      scale: SCALES[partial.recipe.scaleName],
      ...partial.recipe,
    },
  };
}

/** Original generative sessions. These play in-browser via Web Audio. */
export const GENERATED_SESSIONS = [
  generated({
    id: "wl-lab-night",
    title: "Lab Night",
    worldline: "1.130205",
    mood: "ambient",
    durationSec: 72,
    blurb: "Hum of CRT glass and a cooling tower after closing time.",
    recipe: {
      bpm: 70,
      root: 50,
      scaleName: "dorian",
      filterHz: 720,
      drone: true,
      pad: true,
      arp: [0, 2, 4, 2, 3, 4, 6, 4],
      kickEvery: 8,
      hatEvery: 2,
      leadChance: 0.08,
    },
  }),
  generated({
    id: "wl-divergence",
    title: "Divergence Meter",
    worldline: "1.048596",
    mood: "pulse",
    durationSec: 64,
    blurb: "Nixie ticks against a climbing minor arpeggio.",
    recipe: {
      bpm: 96,
      root: 57,
      scaleName: "harmonicMinor",
      filterHz: 1400,
      drone: true,
      pad: false,
      arp: [0, 1, 3, 4, 3, 1, 0, 7],
      kickEvery: 4,
      hatEvery: 1,
      leadChance: 0.12,
    },
  }),
  generated({
    id: "wl-reading-steiner",
    title: "Reading Steiner",
    worldline: "1.130238",
    mood: "tension",
    durationSec: 68,
    blurb: "A two-note headache that remembers a different attractor field.",
    recipe: {
      bpm: 80,
      root: 48,
      scaleName: "harmonicMinor",
      filterHz: 480,
      drone: true,
      pad: true,
      arp: [0, 0, 1, 0, 4, 1, 0, 1],
      kickEvery: 4,
      hatEvery: 4,
      leadChance: 0.04,
    },
  }),
  generated({
    id: "wl-future-gadget",
    title: "Future Gadget Lab",
    worldline: "1.129848",
    mood: "bright",
    durationSec: 56,
    blurb: "Workbench radios, Dr Pepper fizz, and an optimistic pentatonic.",
    recipe: {
      bpm: 110,
      root: 60,
      scaleName: "pentatonic",
      filterHz: 2200,
      drone: false,
      pad: true,
      arp: [0, 2, 4, 2, 3, 4, 2, 0],
      kickEvery: 4,
      hatEvery: 1,
      leadChance: 0.18,
    },
  }),
  generated({
    id: "wl-phone-microwave",
    title: "Phone Microwave",
    worldline: "0.571046",
    mood: "glitch",
    durationSec: 48,
    blurb: "Discharge clicks and a banana that should not be there.",
    recipe: {
      bpm: 128,
      root: 55,
      scaleName: "minor",
      filterHz: 2600,
      drone: false,
      pad: false,
      arp: [7, 0, 4, 0, 6, 0, 3, 1],
      kickEvery: 2,
      hatEvery: 1,
      leadChance: 0.22,
      glitch: true,
    },
  }),
  generated({
    id: "wl-alpha",
    title: "Worldline Alpha",
    worldline: "0.571024",
    mood: "warm",
    durationSec: 80,
    blurb: "A softer attractor. The same lab, a kinder night.",
    recipe: {
      bpm: 88,
      root: 53,
      scaleName: "major",
      filterHz: 1100,
      drone: true,
      pad: true,
      arp: [0, 2, 4, 5, 4, 2, 0, 2],
      kickEvery: 8,
      hatEvery: 2,
      leadChance: 0.1,
    },
  }),
  generated({
    id: "wl-beta",
    title: "Worldline Beta",
    worldline: "1.130212",
    mood: "dark",
    durationSec: 76,
    blurb: "Metal shutters, unanswered mail, a drone that will not resolve.",
    recipe: {
      bpm: 76,
      root: 46,
      scaleName: "minor",
      filterHz: 540,
      drone: true,
      pad: true,
      arp: [0, 3, 2, 0, 6, 3, 2, 1],
      kickEvery: 8,
      hatEvery: 4,
      leadChance: 0.06,
    },
  }),
  generated({
    id: "wl-skuld",
    title: "Operation Skuld",
    worldline: "1.048599",
    mood: "hope",
    durationSec: 70,
    blurb: "A plan spoken into a phone that has already been used.",
    recipe: {
      bpm: 100,
      root: 62,
      scaleName: "dorian",
      filterHz: 1800,
      drone: true,
      pad: true,
      arp: [0, 4, 6, 4, 7, 4, 6, 2],
      kickEvery: 4,
      hatEvery: 2,
      leadChance: 0.16,
    },
  }),
  generated({
    id: "wl-boot",
    title: "Amadeus System Boot",
    worldline: "1.129848",
    mood: "signal",
    durationSec: 52,
    blurb: "Handshake tones, then a voice model coming online.",
    recipe: {
      bpm: 90,
      root: 64,
      scaleName: "pentatonic",
      filterHz: 3200,
      drone: true,
      pad: false,
      arp: [0, 2, 4, 7, 4, 2, 0, 4],
      kickEvery: 16,
      hatEvery: 2,
      leadChance: 0.2,
    },
  }),
  generated({
    id: "wl-el-psy",
    title: "El Psy Kongroo",
    worldline: "1.048596",
    mood: "motif",
    durationSec: 60,
    blurb: "The phrase that closes a transmission.",
    recipe: {
      bpm: 120,
      root: 59,
      scaleName: "harmonicMinor",
      filterHz: 1600,
      drone: true,
      pad: true,
      arp: [0, 4, 7, 4, 3, 7, 8, 7],
      kickEvery: 4,
      hatEvery: 1,
      leadChance: 0.14,
    },
  }),
  generated({
    id: "wl-crt-after",
    title: "CRT After Hours",
    worldline: "1.130205",
    mood: "lofi",
    durationSec: 84,
    blurb: "Scanlines and a low-pass that never quite opens.",
    recipe: {
      bpm: 74,
      root: 51,
      scaleName: "dorian",
      filterHz: 420,
      drone: true,
      pad: true,
      arp: [0, 2, 3, 2],
      kickEvery: 8,
      hatEvery: 4,
      leadChance: 0.05,
    },
  }),
  generated({
    id: "wl-locus",
    title: "Locus Gateway",
    worldline: "1.048596",
    mood: "work",
    durationSec: 58,
    blurb: "Provider runtime heartbeat while a job streams in.",
    recipe: {
      bpm: 126,
      root: 58,
      scaleName: "minor",
      filterHz: 1900,
      drone: false,
      pad: true,
      arp: [0, 0, 3, 5, 7, 5, 3, 0],
      kickEvery: 4,
      hatEvery: 1,
      leadChance: 0.1,
    },
  }),
];

export function officialAsTracks() {
  return OFFICIAL_INDEX.map((item) => ({
    kind: "official",
    id: item.id,
    title: item.title,
    artist: item.artist,
    album: item.album,
    year: item.year,
    durationSec: item.durationSec,
    worldline: "index",
    mood: "catalog",
    blurb: item.role,
    catalogNo: item.catalogNo,
    links: item.links,
    playable: false,
  }));
}

export function generatedAsTracks() {
  return GENERATED_SESSIONS.map((track) => ({
    ...track,
    playable: true,
  }));
}

export function allCatalogTracks() {
  return [...generatedAsTracks(), ...officialAsTracks()];
}

export function findTrack(id, extra = []) {
  return [...allCatalogTracks(), ...extra].find((track) => track.id === id) ?? null;
}

export function formatDuration(seconds) {
  const value = Math.max(0, Math.round(Number(seconds) || 0));
  const minutes = Math.floor(value / 60);
  const rest = value % 60;
  return `${minutes}:${String(rest).padStart(2, "0")}`;
}

export function searchTracks(tracks, query) {
  const needle = String(query || "")
    .trim()
    .toLowerCase();
  if (!needle) return tracks;
  return tracks.filter((track) => {
    const hay = [track.title, track.artist, albumOf(track), track.mood, track.worldline, track.blurb]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();
    return hay.includes(needle);
  });
}

function albumOf(track) {
  return track.album || "";
}

export function uniqueMoods(tracks) {
  return [...new Set(tracks.map((track) => track.mood).filter(Boolean))];
}
