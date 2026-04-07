import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hours", "minutes", "seconds",
    "reason",
    "display",
    "startBtn", "pauseBtn", "resetBtn", "stopAlarmBtn",
    "status",
    "alarmOverlay",
    "reasonDisplay",
    "progressContainer", "progressLabel"
  ]

  connect() {
    this.totalSeconds = 0
    this.initialTotalSeconds = 0
    this.interval = null
    this.running = false
    this.audioContext = null
    this.alarmSoundInterval = null
    this.flashInterval = null
    this.originalTitle = document.title

    this.buildProgressBars()
    this.updateDisplay(0)
    this.pauseBtnTarget.classList.add("hidden")
    this.stopAlarmBtnTarget.classList.add("hidden")

    // Request notification permission (non-blocking)
    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission()
    }
  }

  disconnect() {
    this.stopAlarm()
    if (this.interval) clearInterval(this.interval)
    document.title = this.originalTitle
  }

  start() {
    if (!this.running) {
      // Starting fresh or resuming
      if (this.totalSeconds <= 0) {
        // Read from inputs
        var h = parseInt(this.hoursTarget.value) || 0
        var m = parseInt(this.minutesTarget.value) || 0
        var s = parseInt(this.secondsTarget.value) || 0
        this.totalSeconds = h * 3600 + m * 60 + s
      }

      if (this.totalSeconds <= 0) return

      this.initialTotalSeconds = this.totalSeconds
      this.updateProgress()
      this.running = true
      this.statusTarget.textContent = "Running"
      this.statusTarget.classList.remove("text-red-600", "dark:text-red-400", "animate-pulse")
      this.statusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.startBtnTarget.classList.add("hidden")
      this.pauseBtnTarget.classList.remove("hidden")

      this.interval = setInterval(() => {
        this.totalSeconds--
        this.updateDisplay(this.totalSeconds)
        this.updateProgress()

        if (this.totalSeconds <= 0) {
          clearInterval(this.interval)
          this.interval = null
          this.running = false
          this.triggerAlarm()
        }
      }, 1000)
    }
  }

  pause() {
    if (this.running) {
      clearInterval(this.interval)
      this.interval = null
      this.running = false
      this.statusTarget.textContent = "Paused"
      this.statusTarget.classList.remove("text-green-600", "dark:text-green-400")
      this.statusTarget.classList.add("text-yellow-600", "dark:text-yellow-400")
      this.pauseBtnTarget.classList.add("hidden")
      this.startBtnTarget.classList.remove("hidden")
      this.startBtnTarget.textContent = "Resume"
    }
  }

  reset() {
    if (this.interval) clearInterval(this.interval)
    this.interval = null
    this.running = false
    this.totalSeconds = 0
    this.initialTotalSeconds = 0
    this.stopAlarm()
    this.updateDisplay(0)
    this.resetProgress()
    this.hoursTarget.value = ""
    this.minutesTarget.value = ""
    this.secondsTarget.value = ""
    if (this.hasReasonTarget) this.reasonTarget.value = ""
    this.statusTarget.textContent = "Ready"
    this.statusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-yellow-600", "dark:text-yellow-400", "text-red-600", "dark:text-red-400", "animate-pulse")
    this.statusTarget.classList.add("text-gray-500", "dark:text-gray-400")
    this.startBtnTarget.classList.remove("hidden")
    this.startBtnTarget.textContent = "Start"
    this.pauseBtnTarget.classList.add("hidden")
    this.stopAlarmBtnTarget.classList.add("hidden")
    document.title = this.originalTitle
  }

  triggerAlarm() {
    // Show overlay
    this.alarmOverlayTarget.classList.remove("hidden")

    // Start flashing
    var flashOn = true
    this.flashInterval = setInterval(() => {
      this.alarmOverlayTarget.style.backgroundColor = flashOn ? "#dc2626" : "#ffffff"
      flashOn = !flashOn
    }, 300)

    // Start alarm sound
    this.playAlarmSound()

    // Update status
    var reasonText = this.hasReasonTarget ? this.reasonTarget.value.trim() : ""
    this.statusTarget.textContent = "ALARM!"
    this.statusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-yellow-600", "dark:text-yellow-400", "text-gray-500", "dark:text-gray-400")
    this.statusTarget.classList.add("text-red-600", "dark:text-red-400", "animate-pulse")

    // Show reason on overlay
    if (reasonText && this.hasReasonDisplayTarget) {
      this.reasonDisplayTarget.textContent = reasonText
    }

    // Show stop button, hide others
    this.stopAlarmBtnTarget.classList.remove("hidden")
    this.startBtnTarget.classList.add("hidden")
    this.pauseBtnTarget.classList.add("hidden")

    // Update page title
    document.title = "ALARM! - Alarm Timer"

    // Browser notification
    if ("Notification" in window && Notification.permission === "granted") {
      var notifBody = reasonText ? reasonText : "Your alarm timer has finished!"
      new Notification("Alarm Timer", { body: notifBody, icon: "/favicon.ico" })
    }

    // Auto-stop after 20 seconds, then reminder beeps every 30 seconds
    this.autoStopTimeout = setTimeout(() => {
      this.stopAlarm()
      this.startReminderBeeps()
    }, 20000)
  }

  startReminderBeeps() {
    this.reminderCount = 0
    this.reminderInterval = setInterval(() => {
      this.reminderCount++
      this.playBeeps(4)
      if (this.reminderCount >= 10) {
        clearInterval(this.reminderInterval)
        this.reminderInterval = null
      }
    }, 30000)
  }

  playBeeps(count) {
    var ctx = new (window.AudioContext || window.webkitAudioContext)()
    for (var i = 0; i < count; i++) {
      var osc = ctx.createOscillator()
      var gain = ctx.createGain()
      osc.connect(gain)
      gain.connect(ctx.destination)
      osc.frequency.value = 880
      osc.type = "square"
      gain.gain.value = 0.3
      osc.start(ctx.currentTime + i * 0.3)
      osc.stop(ctx.currentTime + i * 0.3 + 0.15)
    }
    // Close context after beeps finish
    setTimeout(function() { ctx.close() }, count * 300 + 200)
  }

  playAlarmSound() {
    var ctx = new (window.AudioContext || window.webkitAudioContext)()
    this.audioContext = ctx
    this.alarmSoundInterval = setInterval(function() {
      var osc = ctx.createOscillator()
      var gain = ctx.createGain()
      osc.connect(gain)
      gain.connect(ctx.destination)
      osc.frequency.value = 880
      osc.type = "square"
      gain.gain.value = 0.3
      osc.start()
      osc.stop(ctx.currentTime + 0.15)
    }, 400)
  }

  stopAlarm() {
    // Stop auto-stop timeout
    if (this.autoStopTimeout) {
      clearTimeout(this.autoStopTimeout)
      this.autoStopTimeout = null
    }

    // Stop reminder beeps
    if (this.reminderInterval) {
      clearInterval(this.reminderInterval)
      this.reminderInterval = null
    }

    // Stop flashing
    if (this.flashInterval) {
      clearInterval(this.flashInterval)
      this.flashInterval = null
    }

    // Stop sound
    if (this.alarmSoundInterval) {
      clearInterval(this.alarmSoundInterval)
      this.alarmSoundInterval = null
    }

    // Close AudioContext
    if (this.audioContext) {
      this.audioContext.close()
      this.audioContext = null
    }

    // Hide overlay
    this.alarmOverlayTarget.classList.add("hidden")
    this.alarmOverlayTarget.style.backgroundColor = ""

    // Clear reason display
    if (this.hasReasonDisplayTarget) {
      this.reasonDisplayTarget.textContent = ""
    }

    // Reset status
    this.statusTarget.textContent = "Ready"
    this.statusTarget.classList.remove("text-red-600", "dark:text-red-400", "animate-pulse")
    this.statusTarget.classList.add("text-gray-500", "dark:text-gray-400")

    // Reset buttons
    this.stopAlarmBtnTarget.classList.add("hidden")
    this.startBtnTarget.classList.remove("hidden")
    this.startBtnTarget.textContent = "Start"

    document.title = this.originalTitle
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
    if (!this.bars || this.initialTotalSeconds <= 0) return
    var elapsed = this.initialTotalSeconds - this.totalSeconds
    var pct = Math.min(100, Math.floor((elapsed / this.initialTotalSeconds) * 100))
    var remaining = 100 - pct

    // bars[0] is at the bottom (flex-col-reverse), bars[99] is at the top
    // We want bars to disappear from the top down
    for (var i = 0; i < 100; i++) {
      if (i < remaining) {
        // Still remaining — colored
        if (remaining > 50) {
          this.bars[i].style.backgroundColor = "#22c55e"
        } else if (remaining > 20) {
          this.bars[i].style.backgroundColor = "#eab308"
        } else {
          this.bars[i].style.backgroundColor = "#ef4444"
        }
      } else {
        // Elapsed — gone
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

  updateDisplay(seconds) {
    var h = Math.floor(seconds / 3600)
    var m = Math.floor((seconds % 3600) / 60)
    var s = seconds % 60
    var formatted = this.pad(h) + ":" + this.pad(m) + ":" + this.pad(s)
    this.displayTarget.textContent = formatted

    // Update page title with countdown when running
    if (seconds > 0) {
      var shortFormatted = h > 0
        ? this.pad(h) + ":" + this.pad(m) + ":" + this.pad(s)
        : this.pad(m) + ":" + this.pad(s)
      document.title = shortFormatted + " - Alarm Timer"
    } else if (!this.running) {
      document.title = this.originalTitle
    }
  }

  pad(n) {
    return n < 10 ? "0" + n : "" + n
  }
}
