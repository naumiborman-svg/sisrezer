const STORAGE_KEY = "amadeus-library-v1";

export function emptyLibraryState() {
  return {
    favorites: [],
    playlists: [],
    volume: 0.82,
    lastTrackId: null,
    lastView: "sessions",
  };
}

export function loadLibraryState(storage = defaultStorage()) {
  try {
    const raw = storage.getItem(STORAGE_KEY);
    if (!raw) return emptyLibraryState();
    const parsed = JSON.parse(raw);
    return {
      ...emptyLibraryState(),
      ...parsed,
      favorites: Array.isArray(parsed.favorites) ? parsed.favorites : [],
      playlists: Array.isArray(parsed.playlists) ? parsed.playlists.map(normalizePlaylist) : [],
    };
  } catch {
    return emptyLibraryState();
  }
}

export function saveLibraryState(state, storage = defaultStorage()) {
  storage.setItem(
    STORAGE_KEY,
    JSON.stringify({
      favorites: state.favorites,
      playlists: state.playlists,
      volume: state.volume,
      lastTrackId: state.lastTrackId,
      lastView: state.lastView,
    }),
  );
}

function normalizePlaylist(playlist) {
  return {
    id: playlist.id,
    name: playlist.name || "Untitled",
    trackIds: Array.isArray(playlist.trackIds) ? playlist.trackIds : [],
  };
}

export function toggleFavorite(state, trackId) {
  const favorites = state.favorites.includes(trackId)
    ? state.favorites.filter((id) => id !== trackId)
    : [...state.favorites, trackId];
  return { ...state, favorites };
}

export function createPlaylist(state, name) {
  const playlist = {
    id: `pl-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
    name: name.trim() || "Untitled session",
    trackIds: [],
  };
  return { state: { ...state, playlists: [...state.playlists, playlist] }, playlist };
}

export function renamePlaylist(state, playlistId, name) {
  return {
    ...state,
    playlists: state.playlists.map((playlist) =>
      playlist.id === playlistId ? { ...playlist, name: name.trim() || playlist.name } : playlist,
    ),
  };
}

export function deletePlaylist(state, playlistId) {
  return {
    ...state,
    playlists: state.playlists.filter((playlist) => playlist.id !== playlistId),
  };
}

export function addToPlaylist(state, playlistId, trackId) {
  return {
    ...state,
    playlists: state.playlists.map((playlist) => {
      if (playlist.id !== playlistId || playlist.trackIds.includes(trackId)) return playlist;
      return { ...playlist, trackIds: [...playlist.trackIds, trackId] };
    }),
  };
}

export function removeFromPlaylist(state, playlistId, trackId) {
  return {
    ...state,
    playlists: state.playlists.map((playlist) =>
      playlist.id === playlistId
        ? { ...playlist, trackIds: playlist.trackIds.filter((id) => id !== trackId) }
        : playlist,
    ),
  };
}

export function tracksForPlaylist(playlist, catalog) {
  return playlist.trackIds.map((id) => catalog.find((track) => track.id === id)).filter(Boolean);
}

export function createLocalTrack(file, { id, objectUrl }) {
  return {
    kind: "local",
    id,
    title: stripExtension(file.name),
    artist: "Local import",
    album: "Imported files",
    year: new Date().getFullYear(),
    durationSec: 0,
    worldline: "local",
    mood: "import",
    blurb: file.name,
    playable: true,
    mime: file.type || "audio/*",
    objectUrl,
    size: file.size,
  };
}

function stripExtension(name) {
  return name.replace(/\.[^/.]+$/, "");
}

export function isAudioFile(file) {
  if (file.type.startsWith("audio/")) return true;
  return /\.(mp3|wav|ogg|flac|m4a|aac|webm)$/i.test(file.name);
}

function defaultStorage() {
  if (typeof localStorage !== "undefined") return localStorage;
  return memoryStorage();
}

export function memoryStorage() {
  const map = new Map();
  return {
    getItem(key) {
      return map.has(key) ? map.get(key) : null;
    },
    setItem(key, value) {
      map.set(key, String(value));
    },
    removeItem(key) {
      map.delete(key);
    },
  };
}
