import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileSize", "fileUnit", "speed", "speedUnit",
    "resultTime", "resultSeconds", "resultFileMb", "resultSpeedMbps",
    "resultSpeed1min", "resultSpeed10min", "resultSpeed1hour"
  ]

  static sizeUnits = {
    "B":  1,
    "KB": 1024,
    "MB": 1048576,
    "GB": 1073741824,
    "TB": 1099511627776
  }

  static speedUnits = {
    "bps":  1,
    "Kbps": 1000,
    "Mbps": 1000000,
    "Gbps": 1000000000
  }

  calculate() {
    const fileSize = parseFloat(this.fileSizeTarget.value) || 0
    const fileUnit = this.fileUnitTarget.value
    const speed = parseFloat(this.speedTarget.value) || 0
    const speedUnit = this.speedUnitTarget.value

    if (fileSize <= 0 || speed <= 0) return

    const su = this.constructor.sizeUnits
    const spu = this.constructor.speedUnits

    const fileBytes = fileSize * (su[fileUnit] || 1)
    const fileBits = fileBytes * 8
    const speedBps = speed * (spu[speedUnit] || 1)

    const downloadSeconds = fileBits / speedBps
    const downloadTime = this.humanizeTime(downloadSeconds)

    const fileMb = fileBytes / 1048576
    const speedMbps = speedBps / 1000000

    const speed1min = (fileBits / 60) / 1000000
    const speed10min = (fileBits / 600) / 1000000
    const speed1hour = (fileBits / 3600) / 1000000

    this.resultTimeTarget.textContent = downloadTime
    this.resultSecondsTarget.textContent = downloadSeconds.toFixed(2) + "s"
    this.resultFileMbTarget.textContent = fileMb.toFixed(2) + " MB"
    this.resultSpeedMbpsTarget.textContent = speedMbps.toFixed(2) + " Mbps"
    this.resultSpeed1minTarget.textContent = speed1min.toFixed(2) + " Mbps"
    this.resultSpeed10minTarget.textContent = speed10min.toFixed(2) + " Mbps"
    this.resultSpeed1hourTarget.textContent = speed1hour.toFixed(4) + " Mbps"
  }

  humanizeTime(seconds) {
    if (seconds < 1) return "Less than 1 second"
    const parts = []
    if (seconds >= 3600) {
      const h = Math.floor(seconds / 3600)
      parts.push(h + "h")
      seconds %= 3600
    }
    if (seconds >= 60) {
      const m = Math.floor(seconds / 60)
      parts.push(m + "m")
      seconds %= 60
    }
    if (seconds >= 1) {
      parts.push(seconds.toFixed(1) + "s")
    }
    return parts.join(" ")
  }

  copy() {
    const time = this.resultTimeTarget.textContent
    const fileMb = this.resultFileMbTarget.textContent
    const speedMbps = this.resultSpeedMbpsTarget.textContent
    const text = `Download Time: ${time}\nFile Size: ${fileMb}\nSpeed: ${speedMbps}`
    navigator.clipboard.writeText(text)
  }
}
