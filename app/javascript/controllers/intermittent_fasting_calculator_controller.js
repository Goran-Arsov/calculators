import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["method", "startTime", "methodName",
                     "fastingStart", "fastingEnd", "eatingStart", "eatingEnd",
                     "fastingHours", "eatingHours", "schedule"]

  static methods = {
    "16_8":  { fastingHours: 16, eatingHours: 8, name: "16:8 (Leangains)" },
    "18_6":  { fastingHours: 18, eatingHours: 6, name: "18:6" },
    "20_4":  { fastingHours: 20, eatingHours: 4, name: "20:4 (Warrior Diet)" },
    "14_10": { fastingHours: 14, eatingHours: 10, name: "14:10" },
    "omad":  { fastingHours: 23, eatingHours: 1, name: "OMAD (One Meal a Day)" }
  }

  calculate() {
    const method = this.methodTarget.value
    const startTime = this.startTimeTarget.value

    if (!startTime) {
      this.clearResults()
      return
    }

    const info = this.constructor.methods[method]
    if (!info) {
      this.clearResults()
      return
    }

    const [startH, startM] = startTime.split(":").map(Number)

    const fastingStart = { h: startH, m: startM }
    const fastingEnd = this.addHours(fastingStart, info.fastingHours)
    const eatingStart = { ...fastingEnd }
    const eatingEnd = this.addHours(eatingStart, info.eatingHours)

    this.methodNameTarget.textContent = info.name
    this.fastingStartTarget.textContent = this.fmtTime(fastingStart)
    this.fastingEndTarget.textContent = this.fmtTime(fastingEnd)
    this.eatingStartTarget.textContent = this.fmtTime(eatingStart)
    this.eatingEndTarget.textContent = this.fmtTime(eatingEnd)
    this.fastingHoursTarget.textContent = `${info.fastingHours} hours`
    this.eatingHoursTarget.textContent = `${info.eatingHours} hours`

    this.buildSchedule(fastingStart, fastingEnd, eatingStart, eatingEnd, info)
  }

  buildSchedule(fastingStart, fastingEnd, eatingStart, eatingEnd, info) {
    const items = []

    items.push(`<div class="flex items-start gap-3 py-2">
      <span class="text-sm font-semibold text-gray-500 dark:text-gray-400 w-20 shrink-0">${this.fmtTime(fastingStart)}</span>
      <div><span class="font-semibold text-gray-900 dark:text-white">Begin fasting</span>
      <p class="text-sm text-gray-500 dark:text-gray-400">Water, black coffee, and plain tea are allowed.</p></div>
    </div>`)

    const midFast = this.addHours(fastingStart, Math.floor(info.fastingHours / 2))
    items.push(`<div class="flex items-start gap-3 py-2">
      <span class="text-sm font-semibold text-gray-500 dark:text-gray-400 w-20 shrink-0">${this.fmtTime(midFast)}</span>
      <div><span class="font-semibold text-gray-900 dark:text-white">Mid-fast</span>
      <p class="text-sm text-gray-500 dark:text-gray-400">Halfway through your fast. Stay hydrated.</p></div>
    </div>`)

    items.push(`<div class="flex items-start gap-3 py-2">
      <span class="text-sm font-semibold text-gray-500 dark:text-gray-400 w-20 shrink-0">${this.fmtTime(eatingStart)}</span>
      <div><span class="font-semibold text-green-600 dark:text-green-400">Eating window opens</span>
      <p class="text-sm text-gray-500 dark:text-gray-400">Break your fast with a balanced meal.</p></div>
    </div>`)

    if (info.eatingHours > 2) {
      const lastMeal = this.addHours(eatingStart, info.eatingHours - 1)
      items.push(`<div class="flex items-start gap-3 py-2">
        <span class="text-sm font-semibold text-gray-500 dark:text-gray-400 w-20 shrink-0">${this.fmtTime(lastMeal)}</span>
        <div><span class="font-semibold text-yellow-600 dark:text-yellow-400">Last meal reminder</span>
        <p class="text-sm text-gray-500 dark:text-gray-400">Eating window closes in about 1 hour.</p></div>
      </div>`)
    }

    items.push(`<div class="flex items-start gap-3 py-2">
      <span class="text-sm font-semibold text-gray-500 dark:text-gray-400 w-20 shrink-0">${this.fmtTime(eatingEnd)}</span>
      <div><span class="font-semibold text-red-600 dark:text-red-400">Eating window closes</span>
      <p class="text-sm text-gray-500 dark:text-gray-400">Begin your next ${info.fastingHours}-hour fast.</p></div>
    </div>`)

    this.scheduleTarget.innerHTML = items.join('<hr class="border-gray-200 dark:border-gray-700">')
  }

  addHours(time, hours) {
    const totalMinutes = time.h * 60 + time.m + hours * 60
    return { h: Math.floor(totalMinutes / 60) % 24, m: totalMinutes % 60 }
  }

  fmtTime(time) {
    const period = time.h >= 12 ? "PM" : "AM"
    const displayH = time.h % 12 === 0 ? 12 : time.h % 12
    return `${displayH}:${String(time.m).padStart(2, "0")} ${period}`
  }

  clearResults() {
    const targets = ["methodName", "fastingStart", "fastingEnd", "eatingStart", "eatingEnd", "fastingHours", "eatingHours"]
    targets.forEach(t => this[`${t}Target`].textContent = "—")
    this.scheduleTarget.innerHTML = '<p class="text-gray-400 dark:text-gray-500 text-sm">Enter your start time to see your schedule</p>'
  }

  copy() {
    const text = [
      `Method: ${this.methodNameTarget.textContent}`,
      `Fasting: ${this.fastingStartTarget.textContent} – ${this.fastingEndTarget.textContent} (${this.fastingHoursTarget.textContent})`,
      `Eating: ${this.eatingStartTarget.textContent} – ${this.eatingEndTarget.textContent} (${this.eatingHoursTarget.textContent})`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
