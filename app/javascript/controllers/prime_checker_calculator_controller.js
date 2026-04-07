import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "numberInput",
    "resultBadge", "resultFactors", "resultNearestBelow", "resultNearestAbove", "resultPrimeIndex",
    "primesGrid"
  ]

  connect() {
    this._renderPrimesGrid()
  }

  check() {
    const val = parseInt(this.numberInputTarget.value)
    if (isNaN(val) || val < 2) {
      this.resultBadgeTarget.innerHTML = '<span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400">Enter a number &ge; 2</span>'
      this.resultFactorsTarget.textContent = "\u2014"
      this.resultNearestBelowTarget.textContent = "\u2014"
      this.resultNearestAboveTarget.textContent = "\u2014"
      this.resultPrimeIndexTarget.textContent = "\u2014"
      return
    }

    if (val > 10000000000) {
      this.resultBadgeTarget.innerHTML = '<span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400">Number too large (max 10 billion)</span>'
      return
    }

    const isPrime = this._isPrime(val)

    if (isPrime) {
      this.resultBadgeTarget.innerHTML = `<span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400">${val.toLocaleString()} is Prime</span>`
      this.resultFactorsTarget.textContent = val.toLocaleString()
      const idx = this._primeIndex(val)
      this.resultPrimeIndexTarget.textContent = idx !== null ? `#${idx}` : "\u2014"
    } else {
      this.resultBadgeTarget.innerHTML = `<span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400">${val.toLocaleString()} is Not Prime</span>`
      const factors = this._factorize(val)
      this.resultFactorsTarget.textContent = factors.join(" \u00D7 ")
      this.resultPrimeIndexTarget.textContent = "\u2014"
    }

    const below = this._nearestPrimeBelow(val)
    const above = this._nearestPrimeAbove(val)
    this.resultNearestBelowTarget.textContent = below !== null ? below.toLocaleString() : "\u2014"
    this.resultNearestAboveTarget.textContent = above !== null ? above.toLocaleString() : "\u2014"
  }

  copyFactors() {
    const text = this.resultFactorsTarget.textContent
    if (!text || text === "\u2014") return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copyFactors']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }

  _isPrime(n) {
    if (n < 2) return false
    if (n < 4) return true
    if (n % 2 === 0) return false
    if (n % 3 === 0) return false
    for (let i = 5; i * i <= n; i += 6) {
      if (n % i === 0 || n % (i + 2) === 0) return false
    }
    return true
  }

  _factorize(n) {
    if (n < 2) return []
    const factors = []
    let d = 2
    let temp = n
    while (d * d <= temp) {
      while (temp % d === 0) {
        factors.push(d)
        temp = Math.floor(temp / d)
      }
      d++
    }
    if (temp > 1) factors.push(temp)
    return factors
  }

  _nearestPrimeBelow(n) {
    for (let c = n - 1; c >= 2; c--) {
      if (this._isPrime(c)) return c
    }
    return null
  }

  _nearestPrimeAbove(n) {
    const limit = n + 1000
    for (let c = n + 1; c <= limit; c++) {
      if (this._isPrime(c)) return c
    }
    return null
  }

  _primeIndex(n) {
    if (!this._isPrime(n)) return null
    if (n > 1000000) return null // Skip counting for very large primes
    let count = 0
    for (let i = 2; i <= n; i++) {
      if (this._isPrime(i)) count++
    }
    return count
  }

  _renderPrimesGrid() {
    const primes = []
    let c = 2
    while (primes.length < 100) {
      if (this._isPrime(c)) primes.push(c)
      c++
    }

    this.primesGridTarget.innerHTML = primes.map(p =>
      `<span class="inline-flex items-center justify-center w-10 h-8 text-xs font-mono bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 rounded">${p}</span>`
    ).join("")
  }
}
