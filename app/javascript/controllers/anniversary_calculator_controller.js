import { Controller } from "@hotwired/stimulus"

const GIFTS = { 1:"Paper", 2:"Cotton", 3:"Leather", 4:"Fruit/Flowers", 5:"Wood", 6:"Candy/Iron", 7:"Wool/Copper", 8:"Bronze", 9:"Pottery", 10:"Tin/Aluminum", 15:"Crystal", 20:"China", 25:"Silver", 30:"Pearl", 40:"Ruby", 50:"Gold", 60:"Diamond", 75:"Diamond & Gold" }

export default class extends Controller {
  static targets = ["start", "resultYears", "resultMonths", "resultDays", "resultTotalDays", "resultNext", "resultGift"]

  connect() { this.calculate() }

  calculate() {
    const start = this.parseDate(this.startTarget.value)
    if (!start) { this.clear(); return }
    const today = new Date()
    if (start > today) { this.clear(); return }

    let years = today.getFullYear() - start.getFullYear()
    let months = today.getMonth() - start.getMonth()
    let days = today.getDate() - start.getDate()
    if (days < 0) {
      months -= 1
      const prev = new Date(today.getFullYear(), today.getMonth(), 0)
      days += prev.getDate()
    }
    if (months < 0) { years -= 1; months += 12 }

    const totalDays = Math.floor((today - start) / 86400000)

    let next = new Date(today.getFullYear(), start.getMonth(), start.getDate())
    if (next <= today) next = new Date(today.getFullYear() + 1, start.getMonth(), start.getDate())
    const daysUntilNext = Math.ceil((next - today) / 86400000)
    const upcomingYear = years + 1
    const gift = GIFTS[upcomingYear] || (Object.keys(GIFTS).reverse().map(Number).find(k => k <= upcomingYear) ? GIFTS[Object.keys(GIFTS).reverse().map(Number).find(k => k <= upcomingYear)] : "Your choice")

    this.resultYearsTarget.textContent = years
    this.resultMonthsTarget.textContent = months
    this.resultDaysTarget.textContent = days
    this.resultTotalDaysTarget.textContent = totalDays.toLocaleString()
    this.resultNextTarget.textContent = `${daysUntilNext} days (year ${upcomingYear})`
    this.resultGiftTarget.textContent = gift
  }

  parseDate(value) {
    if (!value) return null
    const d = new Date(value)
    return isNaN(d.getTime()) ? null : d
  }

  clear() {
    ["Years","Months","Days","TotalDays","Next","Gift"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Anniversary: ${this.resultYearsTarget.textContent}y ${this.resultMonthsTarget.textContent}m ${this.resultDaysTarget.textContent}d`)
  }
}
