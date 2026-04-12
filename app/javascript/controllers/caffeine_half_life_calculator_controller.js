import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["caffeineMg", "consumedAt", "sleepTime",
                     "remainingNow", "percentRemaining", "sleepSafeTime",
                     "caffeineAtBedtime", "sleepImpact", "timeline"]

  static HALF_LIFE = 5.0

  calculate() {
    const mg = parseFloat(this.caffeineMgTarget.value) || 0
    const consumedAt = this.consumedAtTarget.value
    const sleepTime = this.sleepTimeTarget.value

    if (mg <= 0 || !consumedAt) {
      this.clearResults()
      return
    }

    const now = new Date()
    const [consumedH, consumedM] = consumedAt.split(":").map(Number)
    const consumedDate = new Date(now)
    consumedDate.setHours(consumedH, consumedM, 0, 0)

    // If consumed time is in the future, assume yesterday
    if (consumedDate > now) {
      consumedDate.setDate(consumedDate.getDate() - 1)
    }

    const hoursElapsed = (now - consumedDate) / (1000 * 60 * 60)
    const remaining = mg * Math.pow(0.5, hoursElapsed / this.constructor.HALF_LIFE)
    const percent = (remaining / mg) * 100

    this.remainingNowTarget.textContent = `${remaining.toFixed(1)} mg`
    this.percentRemainingTarget.textContent = `${percent.toFixed(1)}%`

    // Sleep safe time (below 50 mg)
    const sleepThreshold = 50
    if (mg > sleepThreshold) {
      const hoursToSafe = this.constructor.HALF_LIFE * Math.log2(mg / sleepThreshold)
      const safeDate = new Date(consumedDate.getTime() + hoursToSafe * 60 * 60 * 1000)
      this.sleepSafeTimeTarget.textContent = `${String(safeDate.getHours()).padStart(2, "0")}:${String(safeDate.getMinutes()).padStart(2, "0")}`
    } else {
      this.sleepSafeTimeTarget.textContent = "Already below threshold"
    }

    // Caffeine at bedtime
    if (sleepTime) {
      const [sleepH, sleepM] = sleepTime.split(":").map(Number)
      const sleepDate = new Date(consumedDate)
      sleepDate.setHours(sleepH, sleepM, 0, 0)
      if (sleepDate <= consumedDate) {
        sleepDate.setDate(sleepDate.getDate() + 1)
      }
      const hoursToSleep = (sleepDate - consumedDate) / (1000 * 60 * 60)
      const atBedtime = mg * Math.pow(0.5, hoursToSleep / this.constructor.HALF_LIFE)
      this.caffeineAtBedtimeTarget.textContent = `${atBedtime.toFixed(1)} mg`
      this.sleepImpactTarget.textContent = this.sleepImpactLabel(atBedtime)
      this.sleepImpactTarget.className = this.sleepImpactClass(atBedtime)
    } else {
      this.caffeineAtBedtimeTarget.textContent = "—"
      this.sleepImpactTarget.textContent = "Enter sleep time"
    }

    // Build timeline
    this.buildTimeline(mg, consumedDate)
  }

  buildTimeline(mg, consumedDate) {
    let html = ""
    for (let h = 0; h <= 24; h += 2) {
      const remaining = mg * Math.pow(0.5, h / this.constructor.HALF_LIFE)
      const pct = (remaining / mg) * 100
      const time = new Date(consumedDate.getTime() + h * 60 * 60 * 1000)
      const timeStr = `${String(time.getHours()).padStart(2, "0")}:${String(time.getMinutes()).padStart(2, "0")}`
      const barWidth = Math.max(pct, 2)
      const color = remaining > 100 ? "bg-red-400" : remaining > 50 ? "bg-yellow-400" : "bg-green-400"
      html += `<div class="flex items-center gap-3 text-sm">
        <span class="w-14 text-right text-gray-500 dark:text-gray-400 font-mono">${timeStr}</span>
        <div class="flex-1 bg-gray-100 dark:bg-gray-800 rounded-full h-4 overflow-hidden">
          <div class="${color} h-full rounded-full transition-all duration-300" style="width:${barWidth}%"></div>
        </div>
        <span class="w-20 text-right font-semibold text-gray-700 dark:text-gray-300">${remaining.toFixed(0)} mg</span>
      </div>`
    }
    this.timelineTarget.innerHTML = html
  }

  sleepImpactLabel(mg) {
    if (mg < 20) return "Minimal - unlikely to affect sleep"
    if (mg < 50) return "Low - may slightly delay sleep onset"
    if (mg < 100) return "Moderate - likely to impair sleep quality"
    return "High - significant sleep disruption expected"
  }

  sleepImpactClass(mg) {
    const base = "text-sm font-semibold"
    if (mg < 20) return `${base} text-green-600 dark:text-green-400`
    if (mg < 50) return `${base} text-lime-600 dark:text-lime-400`
    if (mg < 100) return `${base} text-yellow-600 dark:text-yellow-400`
    return `${base} text-red-600 dark:text-red-400`
  }

  clearResults() {
    this.remainingNowTarget.textContent = "—"
    this.percentRemainingTarget.textContent = "—"
    this.sleepSafeTimeTarget.textContent = "—"
    this.caffeineAtBedtimeTarget.textContent = "—"
    this.sleepImpactTarget.textContent = "—"
    this.timelineTarget.innerHTML = ""
  }

  copy() {
    const text = [
      `Caffeine Remaining: ${this.remainingNowTarget.textContent}`,
      `Percent Remaining: ${this.percentRemainingTarget.textContent}`,
      `Sleep-Safe Time: ${this.sleepSafeTimeTarget.textContent}`,
      `At Bedtime: ${this.caffeineAtBedtimeTarget.textContent}`,
      `Sleep Impact: ${this.sleepImpactTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
