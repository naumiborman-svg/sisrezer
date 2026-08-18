import { createWorldlineSynth } from "./synth.js";

export function createAudioBackend() {
  let ctx = null;
  let synth = null;
  let element = null;
  let mode = null;
  let endedHandler = null;

  function ensureContext() {
    if (!ctx) {
      const Ctor = window.AudioContext || window.webkitAudioContext;
      ctx = new Ctor();
      synth = createWorldlineSynth(ctx);
    }
    return ctx.resume();
  }

  function stopElement() {
    if (!element) return;
    element.pause();
    element.removeEventListener("ended", endedHandler);
    element.removeEventListener("timeupdate", element._amadeusTime);
    element = null;
  }

  return {
    async play(track, hooks) {
      await ensureContext();
      synth.stop();
      stopElement();
      mode = track.kind;

      if (track.kind === "generated") {
        synth.play(track, hooks);
        return;
      }

      if (!track.objectUrl) {
        throw new Error("Local track is missing audio data. Re-import the file.");
      }
      element = new Audio(track.objectUrl);
      element.volume = hooks.volume ?? 0.82;
      endedHandler = () => hooks.onEnded?.();
      element._amadeusTime = () => hooks.onTime?.(element.currentTime, element.duration || track.durationSec || 0);
      element.addEventListener("ended", endedHandler);
      element.addEventListener("timeupdate", element._amadeusTime);
      await element.play();
    },
    pause() {
      if (mode === "generated") {
        ctx?.suspend?.();
        return;
      }
      element?.pause();
    },
    resume() {
      if (mode === "generated") {
        ctx?.resume?.();
        return;
      }
      element?.play();
    },
    stop() {
      synth?.stop();
      stopElement();
      ctx?.resume?.();
    },
    setVolume(volume) {
      synth?.setVolume(volume);
      if (element) element.volume = volume;
    },
    seek(seconds) {
      if (element) element.currentTime = seconds;
    },
    getAnalyser() {
      return synth?.getAnalyser() ?? null;
    },
    getContext() {
      return ctx;
    },
  };
}
