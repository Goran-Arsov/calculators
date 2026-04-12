import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timezones", "businessStart", "businessEnd", "output", "overlapCount", "error"]

  static offsets = {
    UTC: 0, GMT: 0, EST: -5, EDT: -4, CST: -6, CDT: -5,
    MST: -7, MDT: -6, PST: -8, PDT: -7, AKST: -9, AKDT: -8,
    HST: -10, AST: -4, NST: -3.5, BRT: -3, ART: -3,
    CET: 1, CEST: 2, EET: 2, EEST: 3, MSK: 3, GST: 4,
    IST: 5.5, NPT: 5.75, BST: 6, ICT: 7, CST_ASIA: 8,
    HKT: 8, SGT: 8, JST: 9, KST: 9, ACST: 9.5,
    AEST: 10, AEDT: 11, NZST: 12, NZDT: 13
  }

  calculate() {
    const tzInput = this.timezonesTarget.value.trim().toUpperCase()
    const bizStart = parseInt(this.businessStartTarget.value) || 9
    const bizEnd = parseInt(this.businessEndTarget.value) || 17

    if (!tzInput) { this.showError("Enter at least two timezones."); return }

    const tzs = tzInput.split(/[,\n]+/).map(t => t.trim()).filter(t => t)
    if (tzs.length < 2) { this.showError("Enter at least two timezones."); return }

    const unknown = tzs.filter(tz => this.constructor.offsets[tz] === undefined)
    if (unknown.length > 0) { this.showError(`Unknown timezone(s): ${unknown.join(", ")}`); return }
    this.hideError()

    // Build schedule table
    let html = '<table class="w-full text-sm border-collapse">'
    html += '<thead><tr><th class="px-2 py-1 text-left border-b dark:border-gray-700">UTC</th>'
    tzs.forEach(tz => { html += `<th class="px-2 py-1 text-left border-b dark:border-gray-700">${tz}</th>` })
    html += '</tr></thead><tbody>'

    let overlapCount = 0

    for (let utcHour = 0; utcHour < 24; utcHour++) {
      const allBusiness = tzs.every(tz => {
        const offset = this.constructor.offsets[tz]
        const local = ((utcHour + offset) % 24 + 24) % 24
        return local >= bizStart && local < bizEnd
      })

      if (allBusiness) overlapCount++

      const rowClass = allBusiness
        ? "bg-green-100 dark:bg-green-900/30"
        : ""

      html += `<tr class="${rowClass}">`
      html += `<td class="px-2 py-1 border-b dark:border-gray-700 font-mono">${this.formatHour(utcHour)}</td>`

      tzs.forEach(tz => {
        const offset = this.constructor.offsets[tz]
        const local = ((utcHour + offset) % 24 + 24) % 24
        const isBiz = local >= bizStart && local < bizEnd
        const cellClass = isBiz ? "font-semibold text-green-700 dark:text-green-400" : "text-gray-500 dark:text-gray-400"
        html += `<td class="px-2 py-1 border-b dark:border-gray-700 font-mono ${cellClass}">${this.formatHour(local)}</td>`
      })

      html += '</tr>'
    }

    html += '</tbody></table>'

    this.outputTarget.innerHTML = html
    this.overlapCountTarget.textContent = overlapCount > 0
      ? `${overlapCount} overlapping hour${overlapCount > 1 ? "s" : ""} found`
      : "No overlapping business hours found"
  }

  formatHour(h) {
    const hour = Math.floor(h)
    const suffix = hour >= 12 ? "PM" : "AM"
    let display = hour % 12
    if (display === 0) display = 12
    return `${display}:00 ${suffix}`
  }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  copy() {
    const text = this.outputTarget.innerText
    if (!text) return
    navigator.clipboard.writeText(text)
  }
}
