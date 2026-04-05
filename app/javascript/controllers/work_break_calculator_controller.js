import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "shiftHours", "breakThreshold", "breakDuration", "mealThreshold", "mealDuration",
    "resultTotalBreaks", "resultTotalBreakMinutes", "resultNetWorkHours",
    "resultNetWorkMinutes", "resultBreakSchedule"
  ]

  calculate() {
    const shiftHours = parseFloat(this.shiftHoursTarget.value) || 0
    const breakThreshold = parseFloat(this.breakThresholdTarget.value) || 6
    const breakDuration = parseFloat(this.breakDurationTarget.value) || 30
    const mealThreshold = parseFloat(this.mealThresholdTarget.value) || 10
    const mealDuration = parseFloat(this.mealDurationTarget.value) || 30

    if (shiftHours <= 0 || shiftHours > 24) {
      this.clearResults()
      return
    }

    const shiftMinutes = shiftHours * 60
    const breaks = []

    // Rest break at 4+ hours
    if (shiftMinutes >= 240) {
      breaks.push({ type: "Rest break", duration: 15, afterHours: 2.0, paid: true })
    }

    // Meal break based on threshold
    if (shiftHours >= breakThreshold) {
      const breakAfter = (breakThreshold / 2).toFixed(1)
      breaks.push({ type: "Meal break", duration: Math.round(breakDuration), afterHours: parseFloat(breakAfter), paid: false })
    }

    // Additional rest break at 8+ hours
    if (shiftMinutes >= 480) {
      breaks.push({ type: "Rest break", duration: 15, afterHours: 6.0, paid: true })
    }

    // Second meal break for extended shifts
    if (shiftHours >= mealThreshold) {
      breaks.push({ type: "Meal break", duration: Math.round(mealDuration), afterHours: parseFloat((mealThreshold * 0.8).toFixed(1)), paid: false })
    }

    breaks.sort((a, b) => a.afterHours - b.afterHours)

    const totalBreakMinutes = breaks.reduce((sum, b) => sum + b.duration, 0)
    const netWorkMinutes = Math.max(shiftMinutes - totalBreakMinutes, 0)
    const netWorkHours = (netWorkMinutes / 60).toFixed(2)

    this.resultTotalBreaksTarget.textContent = breaks.length
    this.resultTotalBreakMinutesTarget.textContent = totalBreakMinutes
    this.resultNetWorkHoursTarget.textContent = netWorkHours
    this.resultNetWorkMinutesTarget.textContent = Math.round(netWorkMinutes)

    // Build schedule HTML
    if (breaks.length > 0) {
      const scheduleHtml = breaks.map(b => {
        const paidLabel = b.paid ? '<span class="text-green-600 dark:text-green-400 text-xs ml-1">(paid)</span>' : '<span class="text-orange-600 dark:text-orange-400 text-xs ml-1">(unpaid)</span>'
        return `<div class="flex justify-between items-center py-1.5 border-b border-gray-100 dark:border-gray-700/50 last:border-0"><span class="text-sm text-gray-600 dark:text-gray-400">${b.type} after ${b.afterHours}h ${paidLabel}</span><span class="text-sm font-semibold text-gray-900 dark:text-white">${b.duration} min</span></div>`
      }).join("")
      this.resultBreakScheduleTarget.innerHTML = scheduleHtml
    } else {
      this.resultBreakScheduleTarget.innerHTML = '<span class="text-sm text-gray-500">No breaks required</span>'
    }
  }

  clearResults() {
    ;["resultTotalBreaks", "resultTotalBreakMinutes", "resultNetWorkHours", "resultNetWorkMinutes"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
    this.resultBreakScheduleTarget.innerHTML = ""
  }

  copy() {
    const text = `Total Breaks: ${this.resultTotalBreaksTarget.textContent}\nTotal Break Minutes: ${this.resultTotalBreakMinutesTarget.textContent}\nNet Work Hours: ${this.resultNetWorkHoursTarget.textContent}\nNet Work Minutes: ${this.resultNetWorkMinutesTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
