// RATEL live-AI mic tap (L-2). Served as a PLAIN web asset (never bundled into
// main.dart.js — AudioWorklet modules must load standalone). Forwards each
// 128-sample Float32 frame of the 16 kHz capture context to the Dart side,
// which packs PCM16 and streams it up the Gemini Live socket.
class RatelMicProcessor extends AudioWorkletProcessor {
  process(inputs) {
    const ch = inputs[0] && inputs[0][0];
    if (ch && ch.length) this.port.postMessage(new Float32Array(ch));
    return true; // keep the tap alive for the session's lifetime
  }
}
registerProcessor('ratel-mic', RatelMicProcessor);
