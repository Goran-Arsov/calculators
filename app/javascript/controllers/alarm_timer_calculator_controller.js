import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hours", "minutes", "seconds",
    "reason",
    "display",
    "startBtn", "pauseBtn", "resetBtn", "stopAlarmBtn",
    "status",
    "alarmOverlay",
    "reasonDisplay"
  ]

  connect() {
    this.totalSeconds = 0
    this.interval = null
    this.running = false
    this.audioContext = null
    this.alarmSoundInterval = null
    this.flashInterval = null
    this.originalTitle = document.title

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

      this.running = true
      this.statusTarget.textContent = "Running"
      this.statusTarget.classList.remove("text-red-600", "dark:text-red-400", "animate-pulse")
      this.statusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.startBtnTarget.classList.add("hidden")
      this.pauseBtnTarget.classList.remove("hidden")

      this.interval = setInterval(() => {
        this.totalSeconds--
        this.updateDisplay(this.totalSeconds)

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
    this.stopAlarm()
    this.updateDisplay(0)
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
  }

  playAlarmSound() {
    var ctx = new (window.AudioContext || window.webkitAudioContext)()
    this.audioContext = ctx
    this.alarmSoundInterval = setInterval(function() {
      var osc = ctx.createOscillator()
      var gain = ctx.createGain()
      osc.connect(gain)
      gain.connect(ctx.destination)
      osc.frequency.value = 880  // A5 note, loud and attention-getting
      osc.type = "square"        // harsh, alarm-like tone
      gain.gain.value = 0.3
      osc.start()
      osc.stop(ctx.currentTime + 0.15) // short beep
    }, 400)  // beep every 400ms
  }

  stopAlarm() {
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
