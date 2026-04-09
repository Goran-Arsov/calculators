import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalHours", "downtimeMinutes",
    "resultUptimePercent", "resultNines", "resultDowntimeMinutes", "resultUptimeMinutes",
    "resultsContainer", "slaTableBody"
  ]

  calculate() {
    const totalHours = parseFloat(this.totalHoursTarget.value) || 0
    const downtimeMinutes = parseFloat(this.downtimeMinutesTarget.value) || 0

    if (totalHours <= 0) {
      this.clearResults()
      return
    }

    if (downtimeMinutes < 0 || downtimeMinutes > totalHours * 60) {
      this.clearResults()
      return
    }

    const totalMinutes = totalHours * 60
    const uptimeMinutes = totalMinutes - downtimeMinutes
    const uptimePercent = (uptimeMinutes / totalMinutes) * 100

    let nines
    if (uptimePercent >= 99.999) {
      nines = "Five 9s (99.999%)"
    } else if (uptimePercent >= 99.99) {
      nines = "Four 9s (99.99%)"
    } else if (uptimePercent >= 99.9) {
      nines = "Three 9s (99.9%)"
    } else if (uptimePercent >= 99) {
      nines = "Two 9s (99%)"
    } else {
      nines = "Less than two 9s"
    }

    this.resultsContainerTarget.classList.remove("hidden")
    this.resultUptimePercentTarget.textContent = uptimePercent.toFixed(4) + "%"
    this.resultNinesTarget.textContent = nines
    this.resultDowntimeMinutesTarget.textContent = downtimeMinutes.toFixed(2) + " min"
    this.resultUptimeMinutesTarget.textContent = uptimeMinutes.toFixed(2) + " min"

    // Color the nines classification
    this.resultNinesTarget.classList.remove(
      "text-green-600", "dark:text-green-400",
      "text-yellow-600", "dark:text-yellow-400",
      "text-red-500", "dark:text-red-400"
    )
    if (uptimePercent >= 99.9) {
      this.resultNinesTarget.classList.add("text-green-600", "dark:text-green-400")
    } else if (uptimePercent >= 99) {
      this.resultNinesTarget.classList.add("text-yellow-600", "dark:text-yellow-400")
    } else {
      this.resultNinesTarget.classList.add("text-red-500", "dark:text-red-400")
    }

    // Update SLA reference table
    this.updateSlaTable()
  }

  updateSlaTable() {
    const HOURS_PER_MONTH = 720
    const HOURS_PER_YEAR = 8760
    const levels = [
      { label: "99%", pct: 99.0 },
      { label: "99.9%", pct: 99.9 },
      { label: "99.95%", pct: 99.95 },
      { label: "99.99%", pct: 99.99 },
      { label: "99.999%", pct: 99.999 }
    ]

    let html = ""
    levels.forEach(level => {
      const downtimeFraction = (100 - level.pct) / 100
      const monthlyMin = HOURS_PER_MONTH * 60 * downtimeFraction
      const yearlyMin = HOURS_PER_YEAR * 60 * downtimeFraction

      html += `<tr class="border-b border-gray-200 dark:border-gray-700">
        <td class="px-3 py-2 text-sm font-medium text-gray-900 dark:text-white">${level.label}</td>
        <td class="px-3 py-2 text-sm text-gray-600 dark:text-gray-400">${this.formatDuration(monthlyMin)}</td>
        <td class="px-3 py-2 text-sm text-gray-600 dark:text-gray-400">${this.formatDuration(yearlyMin)}</td>
      </tr>`
    })

    this.slaTableBodyTarget.innerHTML = html
  }

  formatDuration(minutes) {
    if (minutes < 1) {
      return (minutes * 60).toFixed(1) + "s"
    } else if (minutes < 60) {
      return minutes.toFixed(2) + " min"
    } else if (minutes < 1440) {
      return (minutes / 60).toFixed(2) + " hours"
    } else {
      return (minutes / 1440).toFixed(2) + " days"
    }
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultUptimePercentTarget.textContent = "\u2014"
    this.resultNinesTarget.textContent = "\u2014"
    this.resultNinesTarget.classList.remove(
      "text-green-600", "dark:text-green-400",
      "text-yellow-600", "dark:text-yellow-400",
      "text-red-500", "dark:text-red-400"
    )
    this.resultDowntimeMinutesTarget.textContent = "\u2014"
    this.resultUptimeMinutesTarget.textContent = "\u2014"
  }
}
