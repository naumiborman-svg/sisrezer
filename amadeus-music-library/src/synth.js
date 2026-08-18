export function midiToFreq(midi) {
  return 440 * 2 ** ((midi - 69) / 12);
}

export function stepToMidi(root, scale, step) {
  const octave = Math.floor(step / scale.length);
  const degree = ((step % scale.length) + scale.length) % scale.length;
  return root + scale[degree] + octave * 12;
}

export function beatDuration(bpm) {
  return 60 / bpm;
}

export function buildNotePlan(recipe, durationSec) {
  const bpm = recipe.bpm || 90;
  const beat = beatDuration(bpm);
  const stepLen = beat / 2;
  const pattern = recipe.arp?.length ? recipe.arp : [0, 2, 4, 2];
  const notes = [];
  let t = 0;
  let i = 0;
  while (t < durationSec) {
    const step = pattern[i % pattern.length];
    notes.push({
      at: t,
      dur: stepLen * 0.92,
      midi: stepToMidi(recipe.root, recipe.scale, step),
      kind: "arp",
    });
    if (recipe.leadChance && Math.abs(Math.sin(i * 12.9898 + recipe.root)) < recipe.leadChance) {
      notes.push({
        at: t,
        dur: stepLen * 2.4,
        midi: stepToMidi(recipe.root + 12, recipe.scale, step + 2),
        kind: "lead",
      });
    }
    t += stepLen;
    i += 1;
  }
  return { notes, beat, stepLen };
}

export function createWorldlineSynth(ctx) {
  let current = null;

  function stop() {
    if (!current) return;
    const { master, nodes, endTimer } = current;
    clearTimeout(endTimer);
    const now = ctx.currentTime;
    try {
      master.gain.cancelScheduledValues(now);
      master.gain.setValueAtTime(master.gain.value, now);
      master.gain.linearRampToValueAtTime(0.0001, now + 0.08);
    } catch {
      // Audio context may already be closing.
    }
    setTimeout(() => {
      for (const node of nodes) {
        try {
          node.stop?.();
        } catch {
          // already stopped
        }
        try {
          node.disconnect?.();
        } catch {
          // already disconnected
        }
      }
    }, 90);
    current = null;
  }

  function play(track, { volume = 0.82, onTime, onEnded } = {}) {
    stop();
    const recipe = track.recipe;
    const durationSec = track.durationSec || 60;
    const master = ctx.createGain();
    master.gain.value = 0.0001;
    const filter = ctx.createBiquadFilter();
    filter.type = "lowpass";
    filter.frequency.value = recipe.filterHz || 1200;
    filter.Q.value = 0.7;
    const analyser = ctx.createAnalyser();
    analyser.fftSize = 1024;
    master.connect(filter);
    filter.connect(analyser);
    analyser.connect(ctx.destination);

    const nodes = [master, filter];
    const now = ctx.currentTime;
    master.gain.linearRampToValueAtTime(volume * 0.55, now + 0.18);

    if (recipe.drone) {
      const drone = ctx.createOscillator();
      const gain = ctx.createGain();
      drone.type = "sine";
      drone.frequency.value = midiToFreq(recipe.root);
      gain.gain.value = 0.16;
      drone.connect(gain);
      gain.connect(master);
      drone.start(now);
      drone.stop(now + durationSec + 0.2);
      nodes.push(drone, gain);
    }

    if (recipe.pad) {
      for (const detune of [-11, 7]) {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "sawtooth";
        osc.frequency.value = midiToFreq(recipe.root + 12);
        osc.detune.value = detune;
        gain.gain.value = 0.045;
        osc.connect(gain);
        gain.connect(master);
        osc.start(now);
        osc.stop(now + durationSec + 0.2);
        nodes.push(osc, gain);
      }
    }

    const plan = buildNotePlan(recipe, durationSec);
    for (const note of plan.notes) {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = note.kind === "lead" ? "triangle" : "square";
      osc.frequency.value = midiToFreq(note.midi);
      const start = now + note.at;
      const end = start + note.dur;
      gain.gain.setValueAtTime(0.0001, start);
      gain.gain.linearRampToValueAtTime(note.kind === "lead" ? 0.09 : 0.07, start + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.0001, end);
      osc.connect(gain);
      gain.connect(master);
      osc.start(start);
      osc.stop(end + 0.02);
      nodes.push(osc, gain);
    }

    const kickEvery = recipe.kickEvery || 8;
    const hatEvery = recipe.hatEvery || 2;
    let beatIndex = 0;
    for (let t = 0; t < durationSec; t += plan.beat) {
      if (beatIndex % kickEvery === 0) {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = "sine";
        const start = now + t;
        osc.frequency.setValueAtTime(140, start);
        osc.frequency.exponentialRampToValueAtTime(42, start + 0.18);
        gain.gain.setValueAtTime(0.22, start);
        gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.2);
        osc.connect(gain);
        gain.connect(master);
        osc.start(start);
        osc.stop(start + 0.22);
        nodes.push(osc, gain);
      }
      if (beatIndex % hatEvery === 0) {
        const noise = ctx.createBufferSource();
        const buffer = ctx.createBuffer(1, Math.floor(ctx.sampleRate * 0.05), ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < data.length; i += 1) data[i] = (Math.random() * 2 - 1) * 0.4;
        noise.buffer = buffer;
        const gain = ctx.createGain();
        const hatFilter = ctx.createBiquadFilter();
        hatFilter.type = "highpass";
        hatFilter.frequency.value = 4000;
        gain.gain.value = 0.045;
        noise.connect(hatFilter);
        hatFilter.connect(gain);
        gain.connect(master);
        noise.start(now + t);
        nodes.push(noise, gain, hatFilter);
      }
      if (recipe.glitch && beatIndex % 3 === 0) {
        const blip = ctx.createOscillator();
        const gain = ctx.createGain();
        blip.type = "square";
        blip.frequency.value = 880 + (beatIndex % 5) * 110;
        const start = now + t + plan.stepLen * 0.5;
        gain.gain.setValueAtTime(0.05, start);
        gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.05);
        blip.connect(gain);
        gain.connect(master);
        blip.start(start);
        blip.stop(start + 0.06);
        nodes.push(blip, gain);
      }
      beatIndex += 1;
    }

    const startedAt = performance.now();
    const timer = setInterval(() => {
      const elapsed = (performance.now() - startedAt) / 1000;
      onTime?.(Math.min(elapsed, durationSec), durationSec);
    }, 200);

    const endTimer = setTimeout(() => {
      clearInterval(timer);
      stop();
      onEnded?.();
    }, durationSec * 1000);

    current = { master, nodes, endTimer, analyser, timer, durationSec };
    return { analyser, durationSec, stop };
  }

  function setVolume(volume) {
    if (!current) return;
    current.master.gain.setTargetAtTime(volume * 0.55, ctx.currentTime, 0.05);
  }

  function seek() {
    // Generated sessions are pattern-scheduled; seeking restarts from 0.
  }

  return {
    play,
    stop,
    setVolume,
    seek,
    getAnalyser() {
      return current?.analyser ?? null;
    },
  };
}
