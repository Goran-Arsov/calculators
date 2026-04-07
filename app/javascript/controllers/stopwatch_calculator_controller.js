import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "display",
    "startBtn", "stopBtn", "resetBtn", "lapBtn",
    "lapList"
  ]

  connect() {
    this.running = false
    this.startTime = 0
    this.elapsed = 0
    this.interval = null
    this.lapCount = 0
    this.lastLapTime = 0
    this.updateDisplay(0)
  }

  disconnect() {
    if (this.interval) {
      cancelAnimationFrame(this.interval)
      this.interval = null
    }
  }

  start() {
    if (!this.running) {
      this.running = true
      this.startTime = performance.now() - this.elapsed
      this.tick()
      this.startBtnTarget.classList.add("hidden")
      this.stopBtnTarget.classList.remove("hidden")
      this.lapBtnTarget.removeAttribute("disabled")
    }
  }

  stop() {
    if (this.running) {
      this.running = false
      if (this.interval) {
        cancelAnimationFrame(this.interval)
        this.interval = null
      }
      this.stopBtnTarget.classList.add("hidden")
      this.startBtnTarget.classList.remove("hidden")
      this.startBtnTarget.textContent = "Resume"
    }
  }

  reset() {
    this.running = false
    if (this.interval) {
      cancelAnimationFrame(this.interval)
      this.interval = null
    }
    this.elapsed = 0
    this.lapCount = 0
    this.lastLapTime = 0
    this.updateDisplay(0)
    this.lapListTarget.innerHTML = ""
    this.startBtnTarget.classList.remove("hidden")
    this.startBtnTarget.textContent = "Start"
    this.stopBtnTarget.classList.add("hidden")
    this.lapBtnTarget.setAttribute("disabled", "true")
  }

  lap() {
    if (!this.running) return
    this.lapCount++
    var splitTime = this.elapsed - this.lastLapTime
    this.lastLapTime = this.elapsed

    var row = document.createElement("tr")
    row.className = "border-b border-gray-100 dark:border-gray-800"
    row.innerHTML =
      '<td class="py-2 px-3 text-sm font-medium text-gray-900 dark:text-white">' + this.lapCount + '</td>' +
      '<td class="py-2 px-3 text-sm font-mono text-gray-700 dark:text-gray-300">' + this.formatTime(splitTime) + '</td>' +
      '<td class="py-2 px-3 text-sm font-mono text-gray-700 dark:text-gray-300">' + this.formatTime(this.elapsed) + '</td>'

    this.lapListTarget.appendChild(row)
  }

  tick() {
    if (!this.running) return
    this.elapsed = performance.now() - this.startTime
    this.updateDisplay(this.elapsed)
    this.interval = requestAnimationFrame(() => this.tick())
  }

  updateDisplay(ms) {
    this.displayTarget.textContent = this.formatTime(ms)
  }

  formatTime(ms) {
    var totalMs = Math.floor(ms)
    var hours = Math.floor(totalMs / 3600000)
    var minutes = Math.floor((totalMs % 3600000) / 60000)
    var seconds = Math.floor((totalMs % 60000) / 1000)
    var millis = totalMs % 1000
    return this.pad(hours) + ":" + this.pad(minutes) + ":" + this.pad(seconds) + "." + this.pad3(millis)
  }

  pad(n) {
    return n < 10 ? "0" + n : "" + n
  }

  pad3(n) {
    if (n < 10) return "00" + n
    if (n < 100) return "0" + n
    return "" + n
  }
}
