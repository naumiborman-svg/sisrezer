# Amadeus Music Library

A CRT-styled music library inspired by [Lucas1479/Amadeus](https://github.com/Lucas1479/Amadeus) — the real-time multimodal desktop agent whose source is still pending public audit.

The official repository ships project direction, architecture, and demo stills, not a playable audio catalog. This app fills that gap with three shelves:

1. **Worldline Sessions** — 12 original generative pieces synthesized in the browser (Web Audio). No copyrighted audio is bundled.
2. **Official Index** — metadata and VGMdb links for the *STEINS;GATE 0* Amadeus single / OST. Tracks are listed, not ripped.
3. **Local Imports** — drag-and-drop your own files. They stay in this browser session.

Visual language follows the Amadeus architecture diagrams: phosphor green, scanlines, and a divergence-meter readout.

## Run

```bash
cd amadeus-music-library
python3 -m http.server 4173 --bind 127.0.0.1
```

Open http://127.0.0.1:4173/

## Test

```bash
cd amadeus-music-library
node --test tests/*.test.js
```

## Controls

- Space play / pause
- ← → previous / next
- Double-click a row to play
- Drop audio files anywhere to import
- Star a session; create playlists from the sidebar

El Psy Kongroo.
