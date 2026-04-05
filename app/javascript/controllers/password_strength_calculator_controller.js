import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "password",
    "resultStrength", "resultScore", "resultEntropy",
    "resultLength", "resultPool", "resultCrackTime",
    "resultLower", "resultUpper", "resultDigits", "resultSymbols",
    "strengthBar"
  ]

  static GUESSES_PER_SECOND = 1e9

  calculate() {
    const pw = this.passwordTarget.value
    if (!pw) {
      this.clearResults()
      return
    }

    const hasLower = /[a-z]/.test(pw)
    const hasUpper = /[A-Z]/.test(pw)
    const hasDigits = /\d/.test(pw)
    const hasSymbols = /[^a-zA-Z0-9]/.test(pw)

    let pool = 0
    if (hasLower) pool += 26
    if (hasUpper) pool += 26
    if (hasDigits) pool += 10
    if (hasSymbols) pool += 33
    if (pool === 0) pool = 26

    const length = pw.length
    const entropy = length * Math.log2(pool)
    const combinations = Math.pow(pool, length)
    const secondsToCrack = combinations / this.constructor.GUESSES_PER_SECOND
    const crackTime = this.humanizeSeconds(secondsToCrack)

    let score = 0
    if (length >= 8) score++
    if (length >= 12) score++
    if (hasLower && hasUpper) score++
    if (hasDigits) score++
    if (hasSymbols) score++
    if (entropy >= 60) score++
    if (entropy >= 80) score++
    score = Math.min(score, 7)

    const labels = ["Very Weak", "Very Weak", "Weak", "Weak", "Fair", "Strong", "Very Strong", "Very Strong"]
    const colors = ["bg-red-500", "bg-red-500", "bg-orange-500", "bg-orange-500", "bg-yellow-500", "bg-green-500", "bg-emerald-500", "bg-emerald-600"]
    const strength = labels[score]

    this.resultStrengthTarget.textContent = strength
    this.resultScoreTarget.textContent = score + " / 7"
    this.resultEntropyTarget.textContent = entropy.toFixed(1) + " bits"
    this.resultLengthTarget.textContent = length
    this.resultPoolTarget.textContent = pool
    this.resultCrackTimeTarget.textContent = crackTime

    this.resultLowerTarget.textContent = hasLower ? "Yes" : "No"
    this.resultUpperTarget.textContent = hasUpper ? "Yes" : "No"
    this.resultDigitsTarget.textContent = hasDigits ? "Yes" : "No"
    this.resultSymbolsTarget.textContent = hasSymbols ? "Yes" : "No"

    if (this.hasStrengthBarTarget) {
      const pct = Math.round((score / 7) * 100)
      this.strengthBarTarget.style.width = pct + "%"
      this.strengthBarTarget.className = "h-2 rounded-full transition-all duration-300 " + colors[score]
    }
  }

  clearResults() {
    this.resultStrengthTarget.textContent = "--"
    this.resultScoreTarget.textContent = "-- / 7"
    this.resultEntropyTarget.textContent = "-- bits"
    this.resultLengthTarget.textContent = "--"
    this.resultPoolTarget.textContent = "--"
    this.resultCrackTimeTarget.textContent = "--"
    this.resultLowerTarget.textContent = "--"
    this.resultUpperTarget.textContent = "--"
    this.resultDigitsTarget.textContent = "--"
    this.resultSymbolsTarget.textContent = "--"
    if (this.hasStrengthBarTarget) {
      this.strengthBarTarget.style.width = "0%"
    }
  }

  humanizeSeconds(seconds) {
    if (seconds < 1) return "Instant"
    if (seconds < 60) return Math.round(seconds) + " seconds"
    if (seconds < 3600) return Math.round(seconds / 60) + " minutes"
    if (seconds < 86400) return Math.round(seconds / 3600) + " hours"
    if (seconds < 31557600) return Math.round(seconds / 86400) + " days"
    const years = seconds / 31557600
    if (years < 1000) return Math.round(years) + " years"
    if (years < 1e6) return Math.round(years / 1000) + " thousand years"
    if (years < 1e9) return Math.round(years / 1e6) + " million years"
    if (years < 1e12) return Math.round(years / 1e9) + " billion years"
    return "trillion+ years"
  }

  copy() {
    const strength = this.resultStrengthTarget.textContent
    const entropy = this.resultEntropyTarget.textContent
    const crack = this.resultCrackTimeTarget.textContent
    const length = this.resultLengthTarget.textContent
    const text = `Strength: ${strength}\nEntropy: ${entropy}\nLength: ${length}\nCrack Time: ${crack}`
    navigator.clipboard.writeText(text)
  }
}
