import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "display",
    "phaseLabel", "sessionLabel",
    "workInput", "breakInput", "longBreakInput", "sessionsInput",
    "startBtn", "pauseBtn", "resetBtn", "skipBtn",
    "progressContainer", "progressLabel"
  ]

  connect() {
    this.running = false
    this.interval = null
    this.audioContext = null

    this.workMinutes = 25
    this.breakMinutes = 5
    this.longBreakMinutes = 15
    this.totalSessions = 4

    this.currentSession = 1
    this.phase = "work" // "work", "break", "long_break"
    this.remainingSeconds = this.workMinutes * 60
    this.phaseTotal = this.remainingSeconds

    this.buildProgressBars()
    this.updateDisplay()
    this.updatePhaseLabel()
    this.updateSessionLabel()
    this.pauseBtnTarget.classList.add("hidden")
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
    if (this.audioContext) {
      try { this.audioContext.close() } catch (e) {}
    }
  }

  start() {
    if (!this.running) {
      // Read settings on first start
      if (this.remainingSeconds === this.workMinutes * 60 && this.currentSession === 1 && this.phase === "work") {
        this.readSettings()
        this.remainingSeconds = this.workMinutes * 60
        this.phaseTotal = this.remainingSeconds
        this.updateDisplay()
        this.updatePhaseLabel()
        this.updateSessionLabel()
      }

      this.running = true
      this.startBtnTarget.classList.add("hidden")
      this.pauseBtnTarget.classList.remove("hidden")
      this.disableSettings(true)

      this.interval = setInterval(() => {
        this.remainingSeconds--
        this.updateDisplay()
        this.updateProgress()

        if (this.remainingSeconds <= 0) {
          this.playBeeps(5)
          this.advancePhase()
        }
      }, 1000)
    }
  }

  pause() {
    if (this.running) {
      this.running = false
      clearInterval(this.interval)
      this.interval = null
      this.pauseBtnTarget.classList.add("hidden")
      this.startBtnTarget.classList.remove("hidden")
      this.startBtnTarget.textContent = "Resume"
    }
  }

  reset() {
    this.running = false
    if (this.interval) clearInterval(this.interval)
    this.interval = null

    this.readSettings()
    this.currentSession = 1
    this.phase = "work"
    this.remainingSeconds = this.workMinutes * 60
    this.phaseTotal = this.remainingSeconds

    this.updateDisplay()
    this.updatePhaseLabel()
    this.updateSessionLabel()
    this.resetProgress()
    this.disableSettings(false)

    this.startBtnTarget.classList.remove("hidden")
    this.startBtnTarget.textContent = "Start"
    this.pauseBtnTarget.classList.add("hidden")
  }

  skip() {
    this.advancePhase()
  }

  advancePhase() {
    if (this.phase === "work") {
      if (this.currentSession >= this.totalSessions) {
        // Long break after completing all sessions
        this.phase = "long_break"
        this.remainingSeconds = this.longBreakMinutes * 60
      } else {
        // Short break
        this.phase = "break"
        this.remainingSeconds = this.breakMinutes * 60
      }
    } else if (this.phase === "break") {
      // Next work session
      this.currentSession++
      this.phase = "work"
      this.remainingSeconds = this.workMinutes * 60
    } else if (this.phase === "long_break") {
      // Cycle complete — restart
      this.currentSession = 1
      this.phase = "work"
      this.remainingSeconds = this.workMinutes * 60
    }

    this.phaseTotal = this.remainingSeconds
    this.updateDisplay()
    this.updatePhaseLabel()
    this.updateSessionLabel()
    this.resetProgress()
  }

  readSettings() {
    this.workMinutes = parseInt(this.workInputTarget.value) || 25
    this.breakMinutes = parseInt(this.breakInputTarget.value) || 5
    this.longBreakMinutes = parseInt(this.longBreakInputTarget.value) || 15
    this.totalSessions = parseInt(this.sessionsInputTarget.value) || 4
  }

  disableSettings(disabled) {
    this.workInputTarget.disabled = disabled
    this.breakInputTarget.disabled = disabled
    this.longBreakInputTarget.disabled = disabled
    this.sessionsInputTarget.disabled = disabled
  }

  updateDisplay() {
    var m = Math.floor(this.remainingSeconds / 60)
    var s = this.remainingSeconds % 60
    this.displayTarget.textContent = this.pad(m) + ":" + this.pad(s)
  }

  updatePhaseLabel() {
    var label = this.phaseLabelTarget
    label.classList.remove("text-red-600", "dark:text-red-400", "text-green-600", "dark:text-green-400", "text-blue-600", "dark:text-blue-400")

    if (this.phase === "work") {
      label.textContent = "Work"
      label.classList.add("text-red-600", "dark:text-red-400")
    } else if (this.phase === "break") {
      label.textContent = "Short Break"
      label.classList.add("text-green-600", "dark:text-green-400")
    } else {
      label.textContent = "Long Break"
      label.classList.add("text-blue-600", "dark:text-blue-400")
    }
  }

  updateSessionLabel() {
    this.sessionLabelTarget.textContent = this.currentSession + " / " + this.totalSessions
  }

  playBeeps(count) {
    var AudioCtx = window.AudioContext || window.webkitAudioContext
    if (!this.audioContext) this.audioContext = new AudioCtx()
    var ctx = this.audioContext
    if (ctx.state === "suspended") ctx.resume()
    for (var i = 0; i < count; i++) {
      try {
        var osc = ctx.createOscillator()
        var gain = ctx.createGain()
        osc.connect(gain)
        gain.connect(ctx.destination)
        osc.frequency.value = 880
        osc.type = "square"
        gain.gain.value = 0.3
        osc.start(ctx.currentTime + i * 0.4)
        osc.stop(ctx.currentTime + i * 0.4 + 0.15)
      } catch (e) {}
    }
  }

  buildProgressBars() {
    if (!this.hasProgressContainerTarget) return
    var container = this.progressContainerTarget
    container.innerHTML = ""
    this.bars = []
    for (var i = 0; i < 100; i++) {
      var bar = document.createElement("div")
      bar.className = "w-full transition-colors duration-300"
      bar.style.height = "3px"
      bar.style.backgroundColor = "transparent"
      container.appendChild(bar)
      this.bars.push(bar)
    }
  }

  updateProgress() {
    if (!this.bars || this.phaseTotal <= 0) return
    var elapsed = this.phaseTotal - this.remainingSeconds
    var pct = Math.min(100, Math.floor((elapsed / this.phaseTotal) * 100))
    var remaining = 100 - pct

    var color
    if (this.phase === "work") {
      color = "#ef4444"
    } else if (this.phase === "break") {
      color = "#22c55e"
    } else {
      color = "#3b82f6"
    }

    for (var i = 0; i < 100; i++) {
      if (i < remaining) {
        this.bars[i].style.backgroundColor = color
      } else {
        this.bars[i].style.backgroundColor = "#f3f4f6"
      }
    }

    if (this.hasProgressLabelTarget) {
      this.progressLabelTarget.textContent = remaining + "% remaining"
    }
  }

  resetProgress() {
    if (!this.bars) return
    for (var i = 0; i < 100; i++) {
      this.bars[i].style.backgroundColor = "transparent"
    }
    if (this.hasProgressLabelTarget) {
      this.progressLabelTarget.textContent = ""
    }
  }

  pad(n) {
    return n < 10 ? "0" + n : "" + n
  }
}
