import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "eventDuration", "finalVideoSeconds", "playbackFps",
    "resultInterval", "resultTotalFrames", "resultVideoDuration",
    "resultEventDuration", "resultSpeedFactor",
    "resultStorageJpeg", "resultStorageRaw"
  ]

  calculate() {
    const eventMinutes = parseFloat(this.eventDurationTarget.value) || 0
    const videoSeconds = parseFloat(this.finalVideoSecondsTarget.value) || 0
    const fps = parseFloat(this.playbackFpsTarget.value) || 24

    if (eventMinutes <= 0 || videoSeconds <= 0 || fps <= 0) {
      this.clearResults()
      return
    }

    const totalFrames = Math.round(videoSeconds * fps)
    const eventSeconds = eventMinutes * 60
    const intervalSeconds = eventSeconds / totalFrames

    const speedFactor = eventSeconds / videoSeconds
    const storageJpegGb = (totalFrames * 8) / 1024  // ~8 MB per JPEG
    const storageRawGb = (totalFrames * 25) / 1024   // ~25 MB per RAW

    this.resultIntervalTarget.textContent = `${intervalSeconds.toFixed(1)}s`
    this.resultTotalFramesTarget.textContent = totalFrames.toLocaleString()
    this.resultVideoDurationTarget.textContent = this.formatDuration(videoSeconds)
    this.resultEventDurationTarget.textContent = this.formatDuration(eventSeconds)
    this.resultSpeedFactorTarget.textContent = `${speedFactor.toFixed(1)}x`
    this.resultStorageJpegTarget.textContent = `${storageJpegGb.toFixed(1)} GB`
    this.resultStorageRawTarget.textContent = `${storageRawGb.toFixed(1)} GB`
  }

  formatDuration(seconds) {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    const s = Math.floor(seconds % 60)
    if (h > 0) return `${h}h ${String(m).padStart(2, "0")}m ${String(s).padStart(2, "0")}s`
    if (m > 0) return `${m}m ${String(s).padStart(2, "0")}s`
    return `${s}s`
  }

  clearResults() {
    this.resultIntervalTarget.textContent = "—"
    this.resultTotalFramesTarget.textContent = "—"
    this.resultVideoDurationTarget.textContent = "—"
    this.resultEventDurationTarget.textContent = "—"
    this.resultSpeedFactorTarget.textContent = "—"
    this.resultStorageJpegTarget.textContent = "—"
    this.resultStorageRawTarget.textContent = "—"
  }

  copy() {
    const text = `Time-Lapse Interval Results:\nInterval: ${this.resultIntervalTarget.textContent}\nTotal Frames: ${this.resultTotalFramesTarget.textContent}\nVideo Duration: ${this.resultVideoDurationTarget.textContent}\nSpeed Factor: ${this.resultSpeedFactorTarget.textContent}\nStorage (JPEG): ${this.resultStorageJpegTarget.textContent}\nStorage (RAW): ${this.resultStorageRawTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
