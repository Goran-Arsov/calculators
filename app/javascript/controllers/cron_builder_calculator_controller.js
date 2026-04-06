import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "minuteMode", "minuteValue", "minuteStep",
    "hourMode", "hourValue", "hourStep",
    "domMode", "domValue", "domStep",
    "monthMode", "monthValues",
    "dowMode", "dowValues",
    "resultExpression", "resultDescription",
    "resultNextRuns"
  ]

  static dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  static monthNames = ["", "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"]

  build() {
    const minute = this.buildField("minute")
    const hour = this.buildField("hour")
    const dom = this.buildField("dom")
    const month = this.buildMonthField()
    const dow = this.buildDowField()

    const expression = `${minute} ${hour} ${dom} ${month} ${dow}`
    this.resultExpressionTarget.value = expression
    this.resultDescriptionTarget.textContent = this.describe(minute, hour, dom, month, dow)
    this.resultNextRunsTarget.innerHTML = this.computeNextRuns(expression)
  }

  buildField(name) {
    const mode = this[`${name}ModeTarget`].value

    switch (mode) {
      case "every": return "*"
      case "step": return `*/${this[`${name}StepTarget`].value || "1"}`
      case "specific": return this[`${name}ValueTarget`].value || "*"
      default: return "*"
    }
  }

  buildMonthField() {
    const mode = this.monthModeTarget.value
    if (mode === "every") return "*"

    const checked = Array.from(this.monthValuesTargets)
      .filter(cb => cb.checked)
      .map(cb => cb.value)

    return checked.length > 0 ? checked.join(",") : "*"
  }

  buildDowField() {
    const mode = this.dowModeTarget.value
    if (mode === "every") return "*"

    const checked = Array.from(this.dowValuesTargets)
      .filter(cb => cb.checked)
      .map(cb => cb.value)

    return checked.length > 0 ? checked.join(",") : "*"
  }

  describe(min, hour, dom, month, dow) {
    const pieces = []

    // Minute
    if (min === "*") pieces.push("Every minute")
    else if (min.startsWith("*/")) pieces.push(`Every ${min.slice(2)} minutes`)
    else pieces.push(`At minute ${min}`)

    // Hour
    if (hour === "*") pieces.push("of every hour")
    else if (hour.startsWith("*/")) pieces.push(`every ${hour.slice(2)} hours`)
    else pieces.push(`past hour ${hour}`)

    // Day of month
    if (dom !== "*") {
      if (dom.startsWith("*/")) pieces.push(`every ${dom.slice(2)} days`)
      else pieces.push(`on day ${dom}`)
    }

    // Month
    if (month !== "*") {
      const names = month.split(",").map(m => this.constructor.monthNames[parseInt(m)] || m).join(", ")
      pieces.push(`in ${names}`)
    }

    // Day of week
    if (dow !== "*") {
      const names = dow.split(",").map(d => this.constructor.dayNames[parseInt(d)] || d).join(", ")
      pieces.push(`on ${names}`)
    }

    return pieces.join(" ")
  }

  computeNextRuns(expression) {
    const parts = expression.split(" ")
    if (parts.length !== 5) return ""

    const runs = []
    const now = new Date()
    const check = new Date(now)
    check.setSeconds(0, 0)
    check.setMinutes(check.getMinutes() + 1)

    let iterations = 0
    const maxIterations = 525600 // 1 year in minutes

    while (runs.length < 5 && iterations < maxIterations) {
      if (this.matchesCron(check, parts)) {
        runs.push(new Date(check))
      }
      check.setMinutes(check.getMinutes() + 1)
      iterations++
    }

    if (runs.length === 0) return '<p class="text-gray-400 text-sm">No runs found in the next year</p>'

    return '<ul class="space-y-1">' +
      runs.map(d => `<li class="text-sm font-mono text-gray-700 dark:text-gray-300">${d.toLocaleString()}</li>`).join("") +
      '</ul>'
  }

  matchesCron(date, parts) {
    const [min, hour, dom, month, dow] = parts
    return this.matchesField(date.getMinutes(), min, 0, 59) &&
           this.matchesField(date.getHours(), hour, 0, 23) &&
           this.matchesField(date.getDate(), dom, 1, 31) &&
           this.matchesField(date.getMonth() + 1, month, 1, 12) &&
           this.matchesField(date.getDay(), dow, 0, 6)
  }

  matchesField(value, field, min, max) {
    if (field === "*") return true
    if (field.startsWith("*/")) {
      const step = parseInt(field.slice(2))
      return (value - min) % step === 0
    }
    return field.split(",").some(part => {
      if (part.includes("-")) {
        const [low, high] = part.split("-").map(Number)
        return value >= low && value <= high
      }
      if (part.includes("/")) {
        const [rangePart, step] = part.split("/")
        const [low, high] = rangePart.split("-").map(Number)
        return value >= low && value <= high && (value - low) % parseInt(step) === 0
      }
      return parseInt(part) === value
    })
  }

  preset(event) {
    const expr = event.currentTarget.dataset.expression
    const parts = expr.split(" ")

    // Reset all modes to "every" first, then apply
    this.minuteModeTarget.value = "every"
    this.hourModeTarget.value = "every"
    this.domModeTarget.value = "every"
    this.monthModeTarget.value = "every"
    this.dowModeTarget.value = "every"

    // Apply minute
    if (parts[0] === "*") { /* already every */ }
    else if (parts[0].startsWith("*/")) {
      this.minuteModeTarget.value = "step"
      this.minuteStepTarget.value = parts[0].slice(2)
    } else {
      this.minuteModeTarget.value = "specific"
      this.minuteValueTarget.value = parts[0]
    }

    // Apply hour
    if (parts[1] === "*") { /* already every */ }
    else if (parts[1].startsWith("*/")) {
      this.hourModeTarget.value = "step"
      this.hourStepTarget.value = parts[1].slice(2)
    } else {
      this.hourModeTarget.value = "specific"
      this.hourValueTarget.value = parts[1]
    }

    // Apply day of month
    if (parts[2] === "*") { /* already every */ }
    else if (parts[2].startsWith("*/")) {
      this.domModeTarget.value = "step"
      this.domStepTarget.value = parts[2].slice(2)
    } else {
      this.domModeTarget.value = "specific"
      this.domValueTarget.value = parts[2]
    }

    // Apply month
    if (parts[3] !== "*") {
      this.monthModeTarget.value = "specific"
      const months = parts[3].split(",").map(Number)
      this.monthValuesTargets.forEach(cb => { cb.checked = months.includes(parseInt(cb.value)) })
    } else {
      this.monthValuesTargets.forEach(cb => { cb.checked = false })
    }

    // Apply day of week
    if (parts[4] !== "*") {
      this.dowModeTarget.value = "specific"
      const days = parts[4].split(",").map(Number)
      this.dowValuesTargets.forEach(cb => { cb.checked = days.includes(parseInt(cb.value)) })
    } else {
      this.dowValuesTargets.forEach(cb => { cb.checked = false })
    }

    this.build()
  }

  copy() {
    const text = this.resultExpressionTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector('[data-action*="copy"]')
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }
}
