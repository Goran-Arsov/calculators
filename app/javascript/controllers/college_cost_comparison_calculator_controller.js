import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "collegeAName", "collegeATuition", "collegeARoomBoard", "collegeAFees", "collegeAAid",
    "collegeBName", "collegeBTuition", "collegeBRoomBoard", "collegeBFees", "collegeBAid",
    "years", "annualInflation",
    "collegeANetAnnual", "collegeATotal",
    "collegeBNetAnnual", "collegeBTotal",
    "difference", "cheaper"
  ]

  calculate() {
    const aTuition = parseFloat(this.collegeATuitionTarget.value) || 0
    const aRoomBoard = parseFloat(this.collegeARoomBoardTarget.value) || 0
    const aFees = parseFloat(this.collegeAFeesTarget.value) || 0
    const aAid = parseFloat(this.collegeAAidTarget.value) || 0
    const bTuition = parseFloat(this.collegeBTuitionTarget.value) || 0
    const bRoomBoard = parseFloat(this.collegeBRoomBoardTarget.value) || 0
    const bFees = parseFloat(this.collegeBFeesTarget.value) || 0
    const bAid = parseFloat(this.collegeBAidTarget.value) || 0
    const years = parseInt(this.yearsTarget.value) || 4
    const inflation = (parseFloat(this.annualInflationTarget.value) || 0) / 100

    if (aTuition <= 0 || bTuition <= 0) {
      this.clearResults()
      return
    }

    const calcCollege = (tuition, roomBoard, fees, aid) => {
      let total = 0
      let firstYearNet = 0
      for (let y = 0; y < years; y++) {
        const factor = Math.pow(1 + inflation, y)
        const gross = (tuition + roomBoard + fees) * factor
        const net = Math.max(gross - aid, 0)
        if (y === 0) firstYearNet = net
        total += net
      }
      return { annual: firstYearNet, total }
    }

    const a = calcCollege(aTuition, aRoomBoard, aFees, aAid)
    const b = calcCollege(bTuition, bRoomBoard, bFees, bAid)
    const diff = Math.abs(a.total - b.total)
    const aName = this.collegeANameTarget.value || "College A"
    const bName = this.collegeBNameTarget.value || "College B"
    const cheaper = a.total <= b.total ? aName : bName

    this.collegeANetAnnualTarget.textContent = this.formatCurrency(a.annual)
    this.collegeATotalTarget.textContent = this.formatCurrency(a.total)
    this.collegeBNetAnnualTarget.textContent = this.formatCurrency(b.annual)
    this.collegeBTotalTarget.textContent = this.formatCurrency(b.total)
    this.differenceTarget.textContent = this.formatCurrency(diff)
    this.cheaperTarget.textContent = cheaper
  }

  clearResults() {
    this.collegeANetAnnualTarget.textContent = "$0.00"
    this.collegeATotalTarget.textContent = "$0.00"
    this.collegeBNetAnnualTarget.textContent = "$0.00"
    this.collegeBTotalTarget.textContent = "$0.00"
    this.differenceTarget.textContent = "$0.00"
    this.cheaperTarget.textContent = "N/A"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `College Cost Comparison Results\nCollege A Annual: ${this.collegeANetAnnualTarget.textContent} | Total: ${this.collegeATotalTarget.textContent}\nCollege B Annual: ${this.collegeBNetAnnualTarget.textContent} | Total: ${this.collegeBTotalTarget.textContent}\nDifference: ${this.differenceTarget.textContent}\nCheaper: ${this.cheaperTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
