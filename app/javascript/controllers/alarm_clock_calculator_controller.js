import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hour", "minute",
    "day",
    "reason",
    "display",
    "alarmTimeDisplay",
    "startBtn", "cancelBtn", "stopAlarmBtn",
    "status",
    "alarmOverlay",
    "reasonDisplay",
    "progressContainer", "progressLabel"
  ]

  connect() {
    this.targetTime = null
    this.audioContext = null
    this.alarmSoundInterval = null
    this.flashInterval = null
    this.originalTitle = document.title
    this.alarmActive = false

    this.alarmSetTime = null
    this.buildProgressBars()

    // Start live clock
    this.updateClock()
    this.clockInterval = setInterval(() => {
      this.updateClock()
      if (this.targetTime && !this.alarmActive) {
        this.updateProgress()
        this.checkAlarm()
      }
    }, 1000)

    this.cancelBtnTarget.classList.add("hidden")
    this.stopAlarmBtnTarget.classList.add("hidden")

    // Set default hour/minute to current time + 1 minute
    var now = new Date()
    this.hourTarget.value = now.getHours()
    this.minuteTarget.value = now.getMinutes()

    // Request notification permission (non-blocking)
    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission()
    }
  }

  disconnect() {
    this.stopAlarm()
    if (this.clockInterval) clearInterval(this.clockInterval)
    document.title = this.originalTitle
  }

  updateClock() {
    var now = new Date()
    var h = this.pad(now.getHours())
    var m = this.pad(now.getMinutes())
    var s = this.pad(now.getSeconds())
    this.displayTarget.textContent = h + ":" + m + ":" + s
  }

  setAlarm() {
    var hour = parseInt(this.hourTarget.value) || 0
    var minute = parseInt(this.minuteTarget.value) || 0

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      this.statusTarget.textContent = "Invalid time. Hour: 0-23, Minute: 0-59."
      this.statusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-gray-500", "dark:text-gray-400")
      this.statusTarget.classList.add("text-red-600", "dark:text-red-400")
      return
    }

    var dayValue = this.dayTarget.value
    var now = new Date()
    var target = new Date()

    target.setHours(hour, minute, 0, 0)

    if (dayValue === "today") {
      // Already set to today
      if (target <= now) {
        this.statusTarget.textContent = "This time has already passed today."
        this.statusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-gray-500", "dark:text-gray-400")
        this.statusTarget.classList.add("text-red-600", "dark:text-red-400")
        return
      }
    } else if (dayValue === "tomorrow") {
      target.setDate(target.getDate() + 1)
    } else {
      // Weekday name
      var weekdays = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
      var targetDayIndex = weekdays.indexOf(dayValue)
      if (targetDayIndex !== -1) {
        var currentDay = now.getDay()
        var daysAhead = targetDayIndex - currentDay
        if (daysAhead < 0) {
          daysAhead += 7
        } else if (daysAhead === 0) {
          // Same weekday - check if time has passed
          if (target <= now) {
            daysAhead = 7 // Next week
          }
        }
        target.setDate(now.getDate() + daysAhead)
      }
    }

    this.targetTime = target
    this.alarmSetTime = new Date()
    this.updateProgress()

    // Format display
    var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var displayDay = dayNames[target.getDay()] + ", " + monthNames[target.getMonth()] + " " + target.getDate()
    var displayTime = this.pad(hour) + ":" + this.pad(minute)

    this.alarmTimeDisplayTarget.textContent = "Alarm set for " + displayTime + " on " + displayDay
    this.alarmTimeDisplayTarget.classList.remove("hidden")

    this.statusTarget.textContent = "Alarm active"
    this.statusTarget.classList.remove("text-red-600", "dark:text-red-400", "text-gray-500", "dark:text-gray-400", "animate-pulse")
    this.statusTarget.classList.add("text-green-600", "dark:text-green-400")

    this.startBtnTarget.classList.add("hidden")
    this.cancelBtnTarget.classList.remove("hidden")

    document.title = "Alarm " + displayTime + " - Alarm Clock"
  }

  checkAlarm() {
    var now = new Date()
    if (now.getHours() === this.targetTime.getHours() &&
        now.getMinutes() === this.targetTime.getMinutes() &&
        now.getSeconds() === 0 &&
        now.getDate() === this.targetTime.getDate() &&
        now.getMonth() === this.targetTime.getMonth() &&
        now.getFullYear() === this.targetTime.getFullYear()) {
      this.triggerAlarm()
    }
  }

  triggerAlarm() {
    this.alarmActive = true

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
    this.cancelBtnTarget.classList.add("hidden")

    // Update page title
    document.title = "ALARM! - Alarm Clock"

    // Browser notification
    if ("Notification" in window && Notification.permission === "granted") {
      var notifBody = reasonText ? reasonText : "Your alarm clock has gone off!"
      new Notification("Alarm Clock", { body: notifBody, icon: "/favicon.ico" })
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

    // Reset target time
    this.targetTime = null
    this.alarmSetTime = null
    this.alarmActive = false
    this.resetProgress()

    // Reset status
    this.statusTarget.textContent = "Ready"
    this.statusTarget.classList.remove("text-red-600", "dark:text-red-400", "animate-pulse", "text-green-600", "dark:text-green-400")
    this.statusTarget.classList.add("text-gray-500", "dark:text-gray-400")

    // Hide alarm time display
    this.alarmTimeDisplayTarget.classList.add("hidden")
    this.alarmTimeDisplayTarget.textContent = ""

    // Reset buttons
    this.stopAlarmBtnTarget.classList.add("hidden")
    this.cancelBtnTarget.classList.add("hidden")
    this.startBtnTarget.classList.remove("hidden")

    document.title = this.originalTitle
  }

  cancelAlarm() {
    this.targetTime = null
    this.alarmSetTime = null
    this.alarmActive = false
    this.resetProgress()

    // Reset status
    this.statusTarget.textContent = "Ready"
    this.statusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-600", "dark:text-red-400", "animate-pulse")
    this.statusTarget.classList.add("text-gray-500", "dark:text-gray-400")

    // Hide alarm time display
    this.alarmTimeDisplayTarget.classList.add("hidden")
    this.alarmTimeDisplayTarget.textContent = ""

    // Reset buttons
    this.cancelBtnTarget.classList.add("hidden")
    this.startBtnTarget.classList.remove("hidden")

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
    if (!this.bars || !this.alarmSetTime || !this.targetTime) return
    var now = new Date()
    var totalMs = this.targetTime.getTime() - this.alarmSetTime.getTime()
    var elapsedMs = now.getTime() - this.alarmSetTime.getTime()
    if (totalMs <= 0) return

    var pct = Math.min(100, Math.floor((elapsedMs / totalMs) * 100))
    var remaining = 100 - pct

    for (var i = 0; i < 100; i++) {
      if (i < remaining) {
        if (remaining > 50) {
          this.bars[i].style.backgroundColor = "#22c55e"
        } else if (remaining > 20) {
          this.bars[i].style.backgroundColor = "#eab308"
        } else {
          this.bars[i].style.backgroundColor = "#ef4444"
        }
        this.bars[i].style.height = "3px"
      } else {
        this.bars[i].style.backgroundColor = "#d1d5db"
        this.bars[i].style.height = "1px"
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
