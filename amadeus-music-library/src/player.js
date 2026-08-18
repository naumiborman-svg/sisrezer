export const REPEAT = {
  OFF: "off",
  ALL: "all",
  ONE: "one",
};

export function createPlayer({ backend, onChange } = {}) {
  const state = {
    queue: [],
    index: -1,
    playing: false,
    shuffle: false,
    repeat: REPEAT.OFF,
    volume: 0.82,
    muted: false,
    currentTime: 0,
    duration: 0,
    error: null,
  };

  const listeners = new Set();
  if (onChange) listeners.add(onChange);

  function emit() {
    const snapshot = getState();
    for (const listener of listeners) listener(snapshot);
  }

  function getState() {
    return {
      ...state,
      current: state.queue[state.index] ?? null,
    };
  }

  function setQueue(tracks, startId) {
    state.queue = [...tracks];
    if (startId) {
      const found = state.queue.findIndex((track) => track.id === startId);
      state.index = found >= 0 ? found : state.queue.length ? 0 : -1;
    } else {
      state.index = state.queue.length ? 0 : -1;
    }
    emit();
    return getState();
  }

  function applyVolume() {
    backend?.setVolume?.(state.muted ? 0 : state.volume);
  }

  async function playCurrent() {
    const track = state.queue[state.index];
    state.error = null;
    if (!track) {
      state.playing = false;
      emit();
      return getState();
    }
    if (track.kind === "official" || track.playable === false) {
      state.playing = false;
      state.error = "Official index entries are metadata only.";
      emit();
      return getState();
    }
    state.playing = true;
    state.currentTime = 0;
    state.duration = track.durationSec || 0;
    emit();
    try {
      await backend?.play?.(track, {
        volume: state.muted ? 0 : state.volume,
        onTime: (currentTime, duration) => {
          state.currentTime = currentTime;
          if (duration) state.duration = duration;
          emit();
        },
        onEnded: () => {
          void next({ fromEnded: true });
        },
      });
    } catch (error) {
      state.playing = false;
      state.error = error instanceof Error ? error.message : String(error);
      emit();
    }
    return getState();
  }

  async function play(trackOrId, queue = state.queue) {
    if (Array.isArray(queue) && queue.length) {
      state.queue = [...queue];
    }
    if (trackOrId && typeof trackOrId === "object") {
      const existing = state.queue.findIndex((track) => track.id === trackOrId.id);
      if (existing >= 0) {
        state.index = existing;
      } else {
        state.queue.push(trackOrId);
        state.index = state.queue.length - 1;
      }
    } else if (trackOrId) {
      const found = state.queue.findIndex((track) => track.id === trackOrId);
      if (found < 0) {
        state.error = `Track not in queue: ${trackOrId}`;
        emit();
        return getState();
      }
      state.index = found;
    }
    return playCurrent();
  }

  function pause() {
    state.playing = false;
    backend?.pause?.();
    emit();
    return getState();
  }

  function resume() {
    if (!state.queue[state.index]) return getState();
    state.playing = true;
    backend?.resume?.();
    emit();
    return getState();
  }

  function toggle() {
    return state.playing ? pause() : state.currentTime > 0 ? resume() : playCurrent();
  }

  function pickNextIndex({ fromEnded } = {}) {
    if (!state.queue.length) return -1;
    if (state.repeat === REPEAT.ONE && fromEnded) return state.index;
    if (state.shuffle) {
      if (state.queue.length === 1) return state.index;
      let nextIndex = state.index;
      while (nextIndex === state.index) {
        nextIndex = Math.floor(Math.random() * state.queue.length);
      }
      return nextIndex;
    }
    const upcoming = state.index + 1;
    if (upcoming < state.queue.length) return upcoming;
    if (state.repeat === REPEAT.ALL) return 0;
    return -1;
  }

  async function next(options) {
    const nextIndex = pickNextIndex(options);
    if (nextIndex < 0) {
      state.playing = false;
      backend?.stop?.();
      emit();
      return getState();
    }
    state.index = nextIndex;
    return playCurrent();
  }

  async function previous() {
    if (state.currentTime > 3) {
      backend?.seek?.(0);
      state.currentTime = 0;
      emit();
      return getState();
    }
    if (!state.queue.length) return getState();
    state.index = (state.index - 1 + state.queue.length) % state.queue.length;
    return playCurrent();
  }

  function seek(seconds) {
    const duration = state.duration || state.queue[state.index]?.durationSec || 0;
    state.currentTime = Math.min(Math.max(0, seconds), duration);
    backend?.seek?.(state.currentTime);
    emit();
    return getState();
  }

  function setVolume(volume) {
    state.volume = Math.min(1, Math.max(0, volume));
    if (state.volume > 0) state.muted = false;
    applyVolume();
    emit();
    return getState();
  }

  function toggleMute() {
    state.muted = !state.muted;
    applyVolume();
    emit();
    return getState();
  }

  function toggleShuffle() {
    state.shuffle = !state.shuffle;
    emit();
    return getState();
  }

  function cycleRepeat() {
    state.repeat =
      state.repeat === REPEAT.OFF ? REPEAT.ALL : state.repeat === REPEAT.ALL ? REPEAT.ONE : REPEAT.OFF;
    emit();
    return getState();
  }

  return {
    getState,
    subscribe(listener) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
    setQueue,
    play,
    pause,
    resume,
    toggle,
    next,
    previous,
    seek,
    setVolume,
    toggleMute,
    toggleShuffle,
    cycleRepeat,
  };
}
