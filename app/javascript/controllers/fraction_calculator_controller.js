import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["num1", "den1", "num2", "den2", "operation", "resultFraction", "resultDecimal"]

  connect() {
    if (prefillFromUrl(this, { num1: "num1", den1: "den1", num2: "num2", den2: "den2", operation: "operation" })) {
      this.calculate()
    }
  }

  calculate() {
    const num1 = parseInt(this.num1Target.value) || 0
    const den1 = parseInt(this.den1Target.value) || 0
    const num2 = parseInt(this.num2Target.value) || 0
    const den2 = parseInt(this.den2Target.value) || 0
    const op = this.operationTarget.value

    if (den1 === 0 || den2 === 0) {
      this.resultFractionTarget.textContent = "Denominator cannot be zero"
      this.resultDecimalTarget.textContent = ""
      return
    }

    if (op === "divide" && num2 === 0) {
      this.resultFractionTarget.textContent = "Cannot divide by zero"
      this.resultDecimalTarget.textContent = ""
      return
    }

    let rNum, rDen
    switch (op) {
      case "add":      rNum = num1 * den2 + num2 * den1; rDen = den1 * den2; break
      case "subtract": rNum = num1 * den2 - num2 * den1; rDen = den1 * den2; break
      case "multiply": rNum = num1 * num2; rDen = den1 * den2; break
      case "divide":   rNum = num1 * den2; rDen = den1 * num2; break
    }

    const g = this.gcd(Math.abs(rNum), Math.abs(rDen))
    rNum = rNum / g
    rDen = rDen / g
    if (rDen < 0) { rNum = -rNum; rDen = -rDen }

    this.resultFractionTarget.textContent = `${rNum}/${rDen}`
    this.resultDecimalTarget.textContent = `= ${(rNum / rDen).toFixed(6).replace(/\.?0+$/, "")}`
  }

  gcd(a, b) { return b === 0 ? a : this.gcd(b, a % b) }

  copy() {
    navigator.clipboard.writeText(`${this.resultFractionTarget.textContent} ${this.resultDecimalTarget.textContent}`)
  }
}
