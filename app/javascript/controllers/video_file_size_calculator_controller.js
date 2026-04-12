import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "bitrate", "duration", "durationUnit", "codec", "frameRate", "audioBitrate",
    "resultFileSize", "resultFileSizeGb", "resultVideoSize", "resultAudioSize",
    "resultTotalFrames", "resultCodec", "resultDuration"
  ]

  calculate() {
    const bitrateMbps = parseFloat(this.bitrateTarget.value) || 0
    const durationInput = parseFloat(this.durationTarget.value) || 0
    const durationUnit = this.durationUnitTarget.value
    const frameRate = parseFloat(this.frameRateTarget.value) || 30
    const audioBitrateKbps = parseFloat(this.audioBitrateTarget.value) || 320

    if (bitrateMbps <= 0 || durationInput <= 0) {
      this.clearResults()
      return
    }

    // Convert duration to seconds
    let durationSeconds
    switch (durationUnit) {
      case "minutes": durationSeconds = durationInput * 60; break
      case "hours": durationSeconds = durationInput * 3600; break
      default: durationSeconds = durationInput
    }

    const videoBits = bitrateMbps * 1000000 * durationSeconds
    const audioBits = audioBitrateKbps * 1000 * durationSeconds
    const totalBits = videoBits + audioBits
    const totalBytes = totalBits / 8

    const sizeMb = totalBytes / (1024 * 1024)
    const sizeGb = totalBytes / (1024 * 1024 * 1024)

    this.resultFileSizeTarget.textContent = `${sizeMb.toFixed(1)} MB`
    this.resultFileSizeGbTarget.textContent = `${sizeGb.toFixed(2)} GB`
    this.resultVideoSizeTarget.textContent = `${(videoBits / 8 / (1024 * 1024)).toFixed(1)} MB`
    this.resultAudioSizeTarget.textContent = `${(audioBits / 8 / (1024 * 1024)).toFixed(1)} MB`
    this.resultTotalFramesTarget.textContent = Math.round(frameRate * durationSeconds).toLocaleString()
    this.resultDurationTarget.textContent = this.formatDuration(durationSeconds)
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
    this.resultFileSizeTarget.textContent = "—"
    this.resultFileSizeGbTarget.textContent = "—"
    this.resultVideoSizeTarget.textContent = "—"
    this.resultAudioSizeTarget.textContent = "—"
    this.resultTotalFramesTarget.textContent = "—"
    this.resultDurationTarget.textContent = "—"
  }

  copy() {
    const text = `Video File Size Estimate:\nTotal: ${this.resultFileSizeTarget.textContent} (${this.resultFileSizeGbTarget.textContent})\nVideo: ${this.resultVideoSizeTarget.textContent}\nAudio: ${this.resultAudioSizeTarget.textContent}\nFrames: ${this.resultTotalFramesTarget.textContent}\nDuration: ${this.resultDurationTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
