import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "timestampInput", "datetimeInput", "currentTimestamp",
    "resultIso8601", "resultRfc2822", "resultUtc", "resultLocal",
    "resultDate", "resultTime", "resultDayOfWeek", "resultRelative",
    "resultMilliseconds", "resultPastFuture",
    "toTimestampResult", "toTimestampMillis"
  ]

  connect() {
    this.updateCurrentTimestamp()
    this.currentTimestampInterval = setInterval(() => this.updateCurrentTimestamp(), 1000)
  }

  disconnect() {
    if (this.currentTimestampInterval) {
      clearInterval(this.currentTimestampInterval)
    }
  }

  updateCurrentTimestamp() {
    const now = Math.floor(Date.now() / 1000)
    if (this.hasCurrentTimestampTarget) {
      this.currentTimestampTarget.textContent = now
    }
  }

  convertToDatetime() {
    const input = this.timestampInputTarget.value.trim()
    if (!input) {
      this.clearDatetimeResults()
      return
    }

    const timestamp = parseFloat(input)
    if (isNaN(timestamp)) {
      this.clearDatetimeResults()
      return
    }

    const date = new Date(timestamp * 1000)
    if (isNaN(date.getTime())) {
      this.clearDatetimeResults()
      return
    }

    this.resultIso8601Target.textContent = date.toISOString()
    this.resultRfc2822Target.textContent = date.toUTCString()
    this.resultUtcTarget.textContent = this.formatUtc(date)
    this.resultLocalTarget.textContent = this.formatLocal(date)
    this.resultDateTarget.textContent = this.formatDateOnly(date)
    this.resultTimeTarget.textContent = this.formatTimeOnly(date)
    this.resultDayOfWeekTarget.textContent = date.toLocaleDateString("en-US", { weekday: "long", timeZone: "UTC" })
    this.resultMillisecondsTarget.textContent = Math.floor(timestamp * 1000)

    const now = Date.now()
    const isPast = date.getTime() < now
    this.resultPastFutureTarget.textContent = isPast ? "Past" : "Future"
    this.resultPastFutureTarget.className = isPast
      ? "text-sm font-semibold text-amber-600 dark:text-amber-400"
      : "text-sm font-semibold text-emerald-600 dark:text-emerald-400"
    this.resultRelativeTarget.textContent = this.relativeTime(date)
  }

  convertToTimestamp() {
    const input = this.datetimeInputTarget.value
    if (!input) {
      this.clearTimestampResults()
      return
    }

    const date = new Date(input)
    if (isNaN(date.getTime())) {
      this.clearTimestampResults()
      return
    }

    const timestamp = Math.floor(date.getTime() / 1000)
    this.toTimestampResultTarget.textContent = timestamp
    this.toTimestampMillisTarget.textContent = date.getTime()
  }

  formatUtc(date) {
    return date.getUTCFullYear() + "-" +
      String(date.getUTCMonth() + 1).padStart(2, "0") + "-" +
      String(date.getUTCDate()).padStart(2, "0") + " " +
      String(date.getUTCHours()).padStart(2, "0") + ":" +
      String(date.getUTCMinutes()).padStart(2, "0") + ":" +
      String(date.getUTCSeconds()).padStart(2, "0") + " UTC"
  }

  formatLocal(date) {
    return date.toLocaleString("en-US", {
      year: "numeric", month: "long", day: "numeric",
      hour: "2-digit", minute: "2-digit", second: "2-digit",
      timeZoneName: "short"
    })
  }

  formatDateOnly(date) {
    return date.getUTCFullYear() + "-" +
      String(date.getUTCMonth() + 1).padStart(2, "0") + "-" +
      String(date.getUTCDate()).padStart(2, "0")
  }

  formatTimeOnly(date) {
    return String(date.getUTCHours()).padStart(2, "0") + ":" +
      String(date.getUTCMinutes()).padStart(2, "0") + ":" +
      String(date.getUTCSeconds()).padStart(2, "0")
  }

  relativeTime(date) {
    const now = Date.now()
    const diff = Math.abs(now - date.getTime()) / 1000
    const direction = date.getTime() < now ? "ago" : "from now"

    let description
    if (diff < 60) {
      description = `${Math.floor(diff)} seconds`
    } else if (diff < 3600) {
      const minutes = Math.floor(diff / 60)
      description = `${minutes} ${minutes === 1 ? "minute" : "minutes"}`
    } else if (diff < 86400) {
      const hours = Math.floor(diff / 3600)
      description = `${hours} ${hours === 1 ? "hour" : "hours"}`
    } else if (diff < 2592000) {
      const days = Math.floor(diff / 86400)
      description = `${days} ${days === 1 ? "day" : "days"}`
    } else if (diff < 31536000) {
      const months = Math.floor(diff / 2592000)
      description = `${months} ${months === 1 ? "month" : "months"}`
    } else {
      const years = Math.floor(diff / 31536000)
      description = `${years} ${years === 1 ? "year" : "years"}`
    }

    return `${description} ${direction}`
  }

  useCurrentTimestamp() {
    const now = Math.floor(Date.now() / 1000)
    this.timestampInputTarget.value = now
    this.convertToDatetime()
  }

  useCurrentDatetime() {
    const now = new Date()
    const local = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
    this.datetimeInputTarget.value = local.toISOString().slice(0, 16)
    this.convertToTimestamp()
  }

  clearDatetimeResults() {
    const targets = [
      "resultIso8601", "resultRfc2822", "resultUtc", "resultLocal",
      "resultDate", "resultTime", "resultDayOfWeek", "resultRelative",
      "resultMilliseconds", "resultPastFuture"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  clearTimestampResults() {
    if (this.hasToTimestampResultTarget) this.toTimestampResultTarget.textContent = "\u2014"
    if (this.hasToTimestampMillisTarget) this.toTimestampMillisTarget.textContent = "\u2014"
  }

  copyResult(event) {
    const targetName = event.params.target
    const el = this[`${targetName}Target`]
    if (el) {
      navigator.clipboard.writeText(el.textContent)
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 1500)
    }
  }

  copyCurrentTimestamp() {
    navigator.clipboard.writeText(this.currentTimestampTarget.textContent)
    const btn = event.currentTarget
    const original = btn.textContent
    btn.textContent = "Copied!"
    setTimeout(() => { btn.textContent = original }, 1500)
  }

  copy() {
    const lines = []
    const pairs = [
      ["ISO 8601", "resultIso8601"], ["RFC 2822", "resultRfc2822"],
      ["UTC", "resultUtc"], ["Local", "resultLocal"],
      ["Date", "resultDate"], ["Time", "resultTime"],
      ["Day of Week", "resultDayOfWeek"], ["Relative", "resultRelative"],
      ["Milliseconds", "resultMilliseconds"]
    ]
    pairs.forEach(([label, target]) => {
      if (this[`has${target.charAt(0).toUpperCase() + target.slice(1)}Target`]) {
        lines.push(`${label}: ${this[`${target}Target`].textContent}`)
      }
    })
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
