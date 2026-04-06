import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "resultDescription", "resultNextRuns", "resultMinute",
    "resultHour", "resultDom", "resultMonth", "resultDow",
    "resultsContainer"
  ]

  static fieldRanges = {
    minute: [0, 59],
    hour: [0, 23],
    day_of_month: [1, 31],
    month: [1, 12],
    day_of_week: [0, 6]
  }

  static dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  static monthNames = ["", "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"]

  calculate() {
    const expression = this.inputTarget.value.trim()
    if (!expression) {
      this.clearResults()
      return
    }

    const parts = expression.split(/\s+/)
    if (parts.length !== 5) {
      this.showError("Expected 5 fields (minute hour day-of-month month day-of-week), got " + parts.length)
      return
    }

    const fieldNames = ["minute", "hour", "day_of_month", "month", "day_of_week"]
    const parsed = {}

    for (let i = 0; i < 5; i++) {
      const name = fieldNames[i]
      const range = this.constructor.fieldRanges[name]
      try {
        parsed[name] = this.parseField(parts[i], range[0], range[1], name)
      } catch (e) {
        this.showError(e.message)
        return
      }
    }

    this.resultsContainerTarget.classList.remove("hidden")

    // Description
    this.resultDescriptionTarget.textContent = this.buildDescription(parsed)

    // Field breakdowns
    this.resultMinuteTarget.textContent = this.describeField(parts[0], parsed.minute, "minute")
    this.resultHourTarget.textContent = this.describeField(parts[1], parsed.hour, "hour")
    this.resultDomTarget.textContent = this.describeField(parts[2], parsed.day_of_month, "day of month")
    this.resultMonthTarget.textContent = this.describeField(parts[3], parsed.month, "month")
    this.resultDowTarget.textContent = this.describeField(parts[4], parsed.day_of_week, "day of week")

    // Next runs
    const nextRuns = this.calculateNextRuns(parsed, 5)
    this.resultNextRunsTarget.innerHTML = nextRuns.map(d =>
      `<li class="py-1.5 border-b border-gray-100 dark:border-gray-700 last:border-0 font-mono text-sm">${this.formatDate(d)}</li>`
    ).join("")
  }

  parseField(field, min, max, name) {
    const values = new Set()

    field.split(",").forEach(part => {
      if (part === "*") {
        for (let i = min; i <= max; i++) values.add(i)
      } else if (part.match(/^\*\/(\d+)$/)) {
        const step = parseInt(RegExp.$1)
        if (step <= 0) throw new Error(`Invalid step '${step}' in ${name}`)
        for (let i = min; i <= max; i += step) values.add(i)
      } else if (part.match(/^(\d+)-(\d+)\/(\d+)$/)) {
        const start = parseInt(RegExp.$1)
        const end = parseInt(RegExp.$2)
        const step = parseInt(RegExp.$3)
        if (start < min || end > max) throw new Error(`Range ${start}-${end} out of bounds for ${name}`)
        for (let i = start; i <= end; i += step) values.add(i)
      } else if (part.match(/^(\d+)-(\d+)$/)) {
        const start = parseInt(RegExp.$1)
        const end = parseInt(RegExp.$2)
        if (start < min || end > max) throw new Error(`Range ${start}-${end} out of bounds for ${name}`)
        for (let i = start; i <= end; i++) values.add(i)
      } else if (part.match(/^\d+$/)) {
        const val = parseInt(part)
        if (val < min || val > max) throw new Error(`Value ${val} out of bounds for ${name} (${min}-${max})`)
        values.add(val)
      } else {
        throw new Error(`Invalid syntax '${part}' in ${name} field`)
      }
    })

    return [...values].sort((a, b) => a - b)
  }

  buildDescription(parsed) {
    const allMinutes = parsed.minute.length === 60
    const allHours = parsed.hour.length === 24
    const allDom = parsed.day_of_month.length === 31
    const allMonths = parsed.month.length === 12
    const allDow = parsed.day_of_week.length === 7

    if (allMinutes && allHours && allDom && allMonths && allDow) {
      return "Every minute"
    }

    if (parsed.minute.length > 1 && allHours && allDom && allMonths && allDow) {
      const step = this.detectStep(parsed.minute, 0, 59)
      if (step) return `Every ${step} minutes`
    }

    const parts = []

    if (parsed.minute.length === 1 && parsed.hour.length === 1) {
      parts.push("At " + this.formatTime(parsed.hour[0], parsed.minute[0]))
    } else if (parsed.minute.length === 1 && allHours) {
      parts.push(`At minute ${parsed.minute[0]} of every hour`)
    } else if (allMinutes && parsed.hour.length === 1) {
      parts.push(`Every minute during ${this.formatHour(parsed.hour[0])}`)
    } else if (allMinutes) {
      parts.push("Every minute")
    } else {
      parts.push(`At minute ${parsed.minute.join(", ")}`)
      if (!allHours) parts.push(`during hour ${parsed.hour.join(", ")}`)
    }

    if (!allDow) {
      const dayNames = parsed.day_of_week.map(d => this.constructor.dayNames[d])
      parts.push(`on ${dayNames.join(", ")}`)
    }

    if (!allDom) {
      parts.push(`on day ${parsed.day_of_month.join(", ")} of the month`)
    }

    if (!allMonths) {
      const monthNames = parsed.month.map(m => this.constructor.monthNames[m])
      parts.push(`in ${monthNames.join(", ")}`)
    }

    return parts.join(" ")
  }

  detectStep(values, min, max) {
    if (values.length < 2) return null
    const diffs = []
    for (let i = 1; i < values.length; i++) {
      diffs.push(values[i] - values[i - 1])
    }
    const unique = [...new Set(diffs)]
    if (unique.length !== 1) return null
    const step = unique[0]
    const expected = []
    for (let i = min; i <= max; i += step) expected.push(i)
    if (JSON.stringify(values) === JSON.stringify(expected)) return step
    return null
  }

  formatTime(hour, minute) {
    const period = hour >= 12 ? "PM" : "AM"
    let displayHour = hour % 12
    if (displayHour === 0) displayHour = 12
    return `${displayHour}:${String(minute).padStart(2, "0")} ${period}`
  }

  formatHour(hour) {
    const period = hour >= 12 ? "PM" : "AM"
    let displayHour = hour % 12
    if (displayHour === 0) displayHour = 12
    return `${displayHour} ${period}`
  }

  describeField(raw, values, name) {
    if (raw === "*") return `Every ${name}`
    if (raw.startsWith("*/")) return `Every ${raw.slice(2)} ${name}s`
    if (raw.includes("-")) return `${name.charAt(0).toUpperCase() + name.slice(1)}s ${raw}`
    if (raw.includes(",")) return `${name.charAt(0).toUpperCase() + name.slice(1)}s ${values.join(", ")}`

    let label = String(values[0])
    if (name === "day of week") label = this.constructor.dayNames[values[0]] || label
    if (name === "month") label = this.constructor.monthNames[values[0]] || label
    return `${name.charAt(0).toUpperCase() + name.slice(1)} ${label}`
  }

  calculateNextRuns(parsed, count) {
    const runs = []
    const now = new Date()
    let candidate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes() + 1, 0)
    const maxIterations = 525960

    for (let i = 0; i < maxIterations && runs.length < count; i++) {
      if (this.matches(candidate, parsed)) {
        runs.push(new Date(candidate))
      }
      candidate = new Date(candidate.getTime() + 60000)
    }

    return runs
  }

  matches(date, parsed) {
    if (!parsed.minute.includes(date.getMinutes())) return false
    if (!parsed.hour.includes(date.getHours())) return false
    if (!parsed.month.includes(date.getMonth() + 1)) return false

    const domMatch = parsed.day_of_month.includes(date.getDate())
    const dowMatch = parsed.day_of_week.includes(date.getDay())

    const domRestricted = parsed.day_of_month.length !== 31
    const dowRestricted = parsed.day_of_week.length !== 7

    if (domRestricted && dowRestricted) return domMatch || dowMatch
    return domMatch && dowMatch
  }

  formatDate(date) {
    const days = this.constructor.dayNames
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    const day = days[date.getDay()]
    const month = months[date.getMonth()]
    const d = date.getDate()
    const year = date.getFullYear()
    const h = String(date.getHours()).padStart(2, "0")
    const m = String(date.getMinutes()).padStart(2, "0")
    return `${day}, ${month} ${d}, ${year} ${h}:${m}`
  }

  setPreset(event) {
    this.inputTarget.value = event.currentTarget.dataset.cron
    this.calculate()
  }

  showError(message) {
    this.resultsContainerTarget.classList.remove("hidden")
    this.resultDescriptionTarget.textContent = message
    this.resultDescriptionTarget.classList.add("text-red-500", "dark:text-red-400")
    this.resultNextRunsTarget.innerHTML = ""
    this.resultMinuteTarget.textContent = "\u2014"
    this.resultHourTarget.textContent = "\u2014"
    this.resultDomTarget.textContent = "\u2014"
    this.resultMonthTarget.textContent = "\u2014"
    this.resultDowTarget.textContent = "\u2014"
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultDescriptionTarget.textContent = ""
    this.resultDescriptionTarget.classList.remove("text-red-500", "dark:text-red-400")
    this.resultNextRunsTarget.innerHTML = ""
    this.resultMinuteTarget.textContent = "\u2014"
    this.resultHourTarget.textContent = "\u2014"
    this.resultDomTarget.textContent = "\u2014"
    this.resultMonthTarget.textContent = "\u2014"
    this.resultDowTarget.textContent = "\u2014"
  }

  copy() {
    const desc = this.resultDescriptionTarget.textContent
    const runs = this.resultNextRunsTarget.textContent
    navigator.clipboard.writeText(`${desc}\n\nNext runs:\n${runs}`)
  }
}
