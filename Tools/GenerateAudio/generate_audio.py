#!/usr/bin/env python3
"""Generate original procedural audio assets for Cat Logic Mansion.

The files produced by this script are synthesized from math functions only:
oscillators, envelopes, filters, echo, and deterministic noise. No third-party
samples, loops, presets, or recordings are used.
"""

from __future__ import annotations

import math
import random
import wave
from pathlib import Path

RATE = 44_100
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "CatLogicMansion" / "GameData" / "Audio"


def clamp(value: float, minimum: float = -1.0, maximum: float = 1.0) -> float:
    return max(minimum, min(maximum, value))


def sine(freq: float, t: float) -> float:
    return math.sin(2.0 * math.pi * freq * t)


def triangle(freq: float, t: float) -> float:
    phase = (freq * t) % 1.0
    return 4.0 * abs(phase - 0.5) - 1.0


def smoothstep(x: float) -> float:
    x = clamp(x, 0.0, 1.0)
    return x * x * (3.0 - 2.0 * x)


def adsr(t: float, duration: float, attack: float, decay: float, sustain: float, release: float) -> float:
    if t < attack:
        return smoothstep(t / attack)

    if t < attack + decay:
        progress = (t - attack) / decay
        return 1.0 + (sustain - 1.0) * smoothstep(progress)

    if t > duration - release:
        progress = (duration - t) / release
        return sustain * smoothstep(progress)

    return sustain


def normalize(samples: list[float], peak: float) -> list[float]:
    maximum = max((abs(sample) for sample in samples), default=1.0)
    if maximum <= 0:
        return samples
    return [sample / maximum * peak for sample in samples]


def echo(samples: list[float], delay_ms: float, amount: float) -> list[float]:
    delay = int(RATE * delay_ms / 1000.0)
    result = samples[:]
    for index in range(delay, len(result)):
        result[index] += result[index - delay] * amount
    return result


def lowpass(samples: list[float], alpha: float) -> list[float]:
    result: list[float] = []
    previous = 0.0
    for sample in samples:
        previous += alpha * (sample - previous)
        result.append(previous)
    return result


def write_wav(name: str, samples: list[float]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    samples = [clamp(sample) for sample in samples]
    with wave.open(str(path), "w") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        frames = bytearray()
        for sample in samples:
            frames += int(sample * 32767).to_bytes(2, byteorder="little", signed=True)
        wav.writeframes(frames)


def render(duration: float, sample_at: callable) -> list[float]:
    frame_count = int(RATE * duration)
    return [sample_at(index / RATE) for index in range(frame_count)]


def make_move() -> list[float]:
    duration = 0.16

    def sample_at(t: float) -> float:
        env = adsr(t, duration, 0.008, 0.035, 0.38, 0.07)
        tap = triangle(460 + 120 * t, t) * 0.38
        bell = sine(880, t) * 0.10 + sine(1320, t) * 0.05
        return (tap + bell) * env

    return normalize(lowpass(render(duration, sample_at), 0.22), 0.36)


def make_blocked() -> list[float]:
    duration = 0.22
    rng = random.Random(7)
    noise = [rng.uniform(-1.0, 1.0) for _ in range(int(RATE * duration))]
    noise = lowpass(noise, 0.08)

    def sample_at(t: float) -> float:
        env = adsr(t, duration, 0.004, 0.055, 0.25, 0.10)
        thud = sine(110 - 20 * t, t) * 0.65 + sine(165, t) * 0.18
        texture = noise[min(int(t * RATE), len(noise) - 1)] * 0.16
        return (thud + texture) * env

    return normalize(render(duration, sample_at), 0.42)


def make_undo() -> list[float]:
    duration = 0.24

    def sample_at(t: float) -> float:
        env = adsr(t, duration, 0.006, 0.050, 0.40, 0.11)
        sweep = sine(620 - 900 * t, t) * 0.28
        shimmer = sine(930 - 500 * t, t) * 0.10
        return (sweep + shimmer) * env

    return normalize(echo(render(duration, sample_at), 54, 0.18), 0.34)


def make_clear() -> list[float]:
    duration = 1.35
    notes = [
        (0.00, 0.30, 523.25),
        (0.18, 0.34, 659.25),
        (0.38, 0.38, 783.99),
        (0.62, 0.50, 1046.50),
    ]

    def sample_at(t: float) -> float:
        value = 0.0
        for start, length, freq in notes:
            if start <= t <= start + length:
                local = t - start
                env = adsr(local, length, 0.015, 0.08, 0.62, 0.18)
                value += (sine(freq, local) * 0.32 + sine(freq * 2.0, local) * 0.06) * env
        pad = sine(261.63, t) * 0.05 + sine(392.00, t) * 0.04
        return value + pad * adsr(t, duration, 0.08, 0.20, 0.45, 0.42)

    return normalize(echo(render(duration, sample_at), 130, 0.22), 0.48)


def make_music() -> list[float]:
    duration = 12.0
    chords = [
        (0.0, [261.63, 329.63, 392.00]),
        (3.0, [293.66, 349.23, 440.00]),
        (6.0, [246.94, 329.63, 392.00]),
        (9.0, [261.63, 329.63, 392.00]),
    ]
    melody = [
        (0.4, 523.25),
        (1.4, 587.33),
        (2.2, 659.25),
        (3.5, 587.33),
        (4.6, 523.25),
        (6.3, 493.88),
        (7.2, 523.25),
        (8.6, 659.25),
        (10.2, 587.33),
        (11.0, 523.25),
    ]

    def chord_at(t: float) -> list[float]:
        active = chords[-1][1]
        for start, chord in chords:
            if t >= start:
                active = chord
        return active

    def sample_at(t: float) -> float:
        chord = chord_at(t)
        value = sum(sine(freq, t) * 0.060 + triangle(freq / 2.0, t) * 0.025 for freq in chord)
        value += sine(65.41, t) * 0.045
        for start, freq in melody:
            length = 0.85
            if start <= t <= start + length:
                local = t - start
                env = adsr(local, length, 0.05, 0.14, 0.38, 0.35)
                value += (sine(freq, local) * 0.085 + sine(freq * 2.0, local) * 0.018) * env
        return value

    samples = render(duration, sample_at)
    fade = int(RATE * 0.35)
    for index in range(fade):
        factor = smoothstep(index / fade)
        samples[index] *= factor
        samples[-index - 1] *= factor
    return normalize(echo(lowpass(samples, 0.18), 310, 0.18), 0.30)


def main() -> None:
    assets = {
        "move.wav": make_move(),
        "blocked.wav": make_blocked(),
        "undo.wav": make_undo(),
        "clear.wav": make_clear(),
        "mansion_loop.wav": make_music(),
    }
    for name, samples in assets.items():
        write_wav(name, samples)
        print(f"generated {OUT / name}")


if __name__ == "__main__":
    main()
