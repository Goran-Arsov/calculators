import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "clockTime", "clockSeconds", "clockDay", "alarmTime", "alarmDay",
    "reasonLabel", "reasonHr", "progressWrap", "progressLabel",
    "hour", "minute", "day", "reason",
    "startBtn", "cancelBtn", "muteBtn",
    "alarmOverlay", "reasonDisplay", "stopBtn"
  ]

  connect() {
    this.alarming = false
    this.running = false
    this.audioContext = null
    this.soundInterval = null
    this.bars = []
    this.muted = false

    // Parse URL params and pre-fill form
    var params = new URLSearchParams(window.location.search)
    this.hourTarget.value = params.get("hour") || "0"
    this.minuteTarget.value = params.get("minute") || "0"
    this.dayTarget.value = params.get("day") || "today"
    this.reasonTarget.value = params.get("reason") || ""

    // Show pre-filled alarm info
    this.updateLabel()

    // Start live clock
    this.updateClock()
    this.clockInterval = setInterval(() => this.updateClock(), 1000)

    document.title = "Alarm " + this.pad(parseInt(this.hourTarget.value)) + ":" + this.pad(parseInt(this.minuteTarget.value)) + " - Alarm Clock"

    if ("Notification" in window && Notification.permission === "default") {
      Notification.requestPermission()
    }
  }

  disconnect() {
    if (this.clockInterval) clearInterval(this.clockInterval)
    if (this.tickInterval) clearInterval(this.tickInterval)
    this.stopSound()
  }

  // User clicks "Start Alarm" — THIS is the user gesture that unlocks audio
  startAlarm() {
    var hour = parseInt(this.hourTarget.value) || 0
    var minute = parseInt(this.minuteTarget.value) || 0

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return

    var day = this.dayTarget.value
    this.targetTime = this.calculateTarget(hour, minute, day)
    this.setTime = new Date()

    if (!this.targetTime) return

    // Create AudioContext NOW — user just clicked, so this is a valid gesture
    var AudioCtx = window.AudioContext || window.webkitAudioContext
    this.audioContext = new AudioCtx()
    // Play silent blip to fully unlock
    var o = this.audioContext.createOscillator()
    var g = this.audioContext.createGain()
    o.connect(g); g.connect(this.audioContext.destination)
    g.gain.value = 0.001; o.start(); o.stop(this.audioContext.currentTime + 0.001)

    this.running = true
    this.buildProgressBars()
    this.updateLabel()

    // Show reason above alarm label
    var reason = this.reasonTarget.value.trim()
    if (reason && this.hasReasonLabelTarget) {
      this.reasonLabelTarget.textContent = reason
      this.reasonLabelTarget.classList.remove("hidden")
      if (this.hasReasonHrTarget) this.reasonHrTarget.classList.remove("hidden")
    }

    // Swap buttons
    this.startBtnTarget.classList.add("hidden")
    this.cancelBtnTarget.classList.remove("hidden")
    this.muteBtnTarget.classList.remove("hidden")

    document.title = "Alarm " + this.pad(hour) + ":" + this.pad(minute) + " - Active"

    // Start checking
    this.tick()
    this.tickInterval = setInterval(() => this.tick(), 1000)
  }

  calculateTarget(hour, minute, day) {
    var now = new Date()
    var target = new Date()
    target.setHours(hour, minute, 0, 0)

    if (day === "today") {
      if (target <= now) return null
    } else if (day === "tomorrow") {
      target.setDate(target.getDate() + 1)
    } else {
      var weekdays = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
      var idx = weekdays.indexOf(day)
      if (idx !== -1) {
        var diff = idx - now.getDay()
        if (diff < 0) diff += 7
        else if (diff === 0 && target <= now) diff = 7
        target.setDate(now.getDate() + diff)
      }
    }
    return target
  }

  updateLabel() {
    var hour = parseInt(this.hourTarget.value) || 0
    var minute = parseInt(this.minuteTarget.value) || 0
    var day = this.dayTarget.value
    var target = this.calculateTarget(hour, minute, day)
    if (!target) {
      this.alarmTimeTarget.textContent = "Set a valid alarm time"
      this.alarmDayTarget.textContent = ""
      return
    }
    var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    this.alarmTimeTarget.textContent = this.pad(target.getHours()) + ":" + this.pad(target.getMinutes())
    this.alarmDayTarget.textContent = dayNames[target.getDay()] + ", " + monthNames[target.getMonth()] + " " + target.getDate()
  }

  updateClock() {
    var now = new Date()
    var dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    this.clockTimeTarget.textContent = this.pad(now.getHours()) + ":" + this.pad(now.getMinutes())
    this.clockSecondsTarget.textContent = ":" + this.pad(now.getSeconds())
    this.clockDayTarget.textContent = dayNames[now.getDay()] + ", " + monthNames[now.getMonth()] + " " + now.getDate()
  }

  buildProgressBars() {
    var wrap = this.progressWrapTarget
    wrap.innerHTML = ""
    this.bars = []
    for (var i = 0; i < 100; i++) {
      var bar = document.createElement("div")
      bar.style.width = "100%"
      bar.style.height = "3px"
      bar.style.transition = "background-color 0.3s"
      bar.style.backgroundColor = "transparent"
      wrap.appendChild(bar)
      this.bars.push(bar)
    }
  }

  tick() {
    var now = new Date()
    if (this.alarming || !this.targetTime) return

    var totalMs = this.targetTime.getTime() - this.setTime.getTime()
    var elapsedMs = now.getTime() - this.setTime.getTime()
    if (totalMs > 0) {
      var pct = Math.min(100, Math.floor((elapsedMs / totalMs) * 100))
      var rem = 100 - pct
      for (var i = 0; i < 100; i++) {
        this.bars[i].style.backgroundColor = i < rem
          ? (rem > 50 ? "#22c55e" : rem > 20 ? "#eab308" : "#ef4444")
          : "#dcdfe4"
      }
      this.progressLabelTarget.textContent = rem + "% remaining"
    }

    if (now.getTime() >= this.targetTime.getTime()) {
      this.triggerAlarm()
    }
  }

  triggerAlarm() {
    this.alarming = true
    document.title = "ALARM!"

    var reason = this.reasonTarget.value.trim()
    if (reason && this.hasReasonDisplayTarget) {
      this.reasonDisplayTarget.textContent = reason
      this.reasonDisplayTarget.classList.remove("hidden")
    }

    // Show overlay with slow fade to red
    this.alarmOverlayTarget.classList.remove("hidden")
    this.alarmOverlayTarget.style.backgroundColor = "rgba(220, 38, 38, 0)"
    this.alarmOverlayTarget.style.transition = "background-color 10s ease-in"
    void this.alarmOverlayTarget.offsetWidth
    this.alarmOverlayTarget.style.backgroundColor = "#dc2626"

    this.colorTimeout = setTimeout(() => {
      this.alarmOverlayTarget.style.transition = "background-color 2s ease"
      this.colorToggle = true
      this.colorInterval = setInterval(() => {
        this.colorToggle = !this.colorToggle
        this.alarmOverlayTarget.style.backgroundColor = this.colorToggle ? "#dc2626" : "#ea580c"
      }, 10000)
    }, 10000)

    // Play 10 beeps initially, then 5 beeps every minute for 30 minutes
    if (!this.muted) this.playBeeps(20)
    this.reminderCount = 0
    this.reminderInterval = setInterval(() => {
      this.reminderCount++
      if (this.reminderCount > 30) {
        clearInterval(this.reminderInterval)
        this.reminderInterval = null
        return
      }
      if (!this.muted) this.playBeeps(10)
    }, 60000)

    if ("Notification" in window && Notification.permission === "granted") {
      new Notification("Alarm Clock", { body: reason || "Your alarm has gone off!", icon: "/favicon.ico" })
    }
  }

  playBeeps(count) {
    var ctx = this.audioContext
    if (!ctx) return
    if (ctx.state === "suspended") ctx.resume()
    for (var i = 0; i < count; i++) {
      try {
        var o = ctx.createOscillator()
        var g = ctx.createGain()
        o.connect(g); g.connect(ctx.destination)
        o.frequency.value = 880; o.type = "square"; g.gain.value = 0.3
        o.start(ctx.currentTime + i * 0.4)
        o.stop(ctx.currentTime + i * 0.4 + 0.15)
      } catch (e) {}
    }
  }

  stopSound() {
    if (this.reminderInterval) { clearInterval(this.reminderInterval); this.reminderInterval = null }
    if (this.audioContext) { try { this.audioContext.close() } catch (e) {} this.audioContext = null }
  }

  toggleMute() {
    this.muted = !this.muted
    this.muteBtnTarget.textContent = this.muted ? "Unmute" : "Mute"
  }

  stopAlarm() {
    this.stopSound()
    if (this.colorTimeout) { clearTimeout(this.colorTimeout); this.colorTimeout = null }
    if (this.colorInterval) { clearInterval(this.colorInterval); this.colorInterval = null }
    if (this.tickInterval) { clearInterval(this.tickInterval); this.tickInterval = null }

    this.alarmOverlayTarget.classList.add("hidden")
    this.alarmOverlayTarget.style.transition = ""
    this.alarmOverlayTarget.style.backgroundColor = ""

    this.alarming = false
    this.running = false
    this.targetTime = null
    this.progressLabelTarget.textContent = ""
    for (var i = 0; i < this.bars.length; i++) {
      this.bars[i].style.backgroundColor = "transparent"
    }
    this.alarmTimeTarget.textContent = "Alarm finished"
    this.alarmDayTarget.textContent = ""

    this.startBtnTarget.classList.remove("hidden")
    this.cancelBtnTarget.classList.add("hidden")
    document.title = "Alarm Finished"
  }

  cancel() {
    this.stopSound()
    if (this.tickInterval) { clearInterval(this.tickInterval); this.tickInterval = null }
    if (this.colorTimeout) { clearTimeout(this.colorTimeout); this.colorTimeout = null }
    if (this.colorInterval) { clearInterval(this.colorInterval); this.colorInterval = null }
    this.alarmOverlayTarget.classList.add("hidden")
    window.close()
  }

  pad(n) {
    return n < 10 ? "0" + n : "" + n
  }
}
