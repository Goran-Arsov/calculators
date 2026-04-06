import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "length", "lengthDisplay",
    "includeLowercase", "includeUppercase", "includeDigits", "includeSpecial",
    "resultOutput", "resultLength", "resultPoolSize", "resultEntropy"
  ]

  static LOWERCASE = "abcdefghijklmnopqrstuvwxyz"
  static UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  static DIGITS = "0123456789"
  static SPECIAL = "!@#$%^&*()-_=+[]{}|;:'\",.<>?/~`"

  connect() {
    this.updateLengthDisplay()
  }

  updateLengthDisplay() {
    if (this.hasLengthDisplayTarget) {
      this.lengthDisplayTarget.textContent = this.lengthTarget.value
    }
  }

  generate() {
    this.updateLengthDisplay()

    const length = parseInt(this.lengthTarget.value) || 12
    const useLower = this.includeLowercaseTarget.checked
    const useUpper = this.includeUppercaseTarget.checked
    const useDigits = this.includeDigitsTarget.checked
    const useSpecial = this.includeSpecialTarget.checked

    if (!useLower && !useUpper && !useDigits && !useSpecial) {
      this.resultOutputTarget.value = ""
      this.resultLengthTarget.textContent = "--"
      this.resultPoolSizeTarget.textContent = "--"
      this.resultEntropyTarget.textContent = "-- bits"
      return
    }

    let pool = ""
    const required = []

    if (useLower) {
      pool += this.constructor.LOWERCASE
      required.push(this.randomChar(this.constructor.LOWERCASE))
    }
    if (useUpper) {
      pool += this.constructor.UPPERCASE
      required.push(this.randomChar(this.constructor.UPPERCASE))
    }
    if (useDigits) {
      pool += this.constructor.DIGITS
      required.push(this.randomChar(this.constructor.DIGITS))
    }
    if (useSpecial) {
      pool += this.constructor.SPECIAL
      required.push(this.randomChar(this.constructor.SPECIAL))
    }

    const remaining = length - required.length
    const chars = [...required]
    for (let i = 0; i < remaining; i++) {
      chars.push(this.randomChar(pool))
    }

    // Shuffle using Fisher-Yates with crypto random
    for (let i = chars.length - 1; i > 0; i--) {
      const j = this.secureRandomInt(i + 1)
      ;[chars[i], chars[j]] = [chars[j], chars[i]]
    }

    const result = chars.join("")
    const poolSize = pool.length
    const entropy = (length * Math.log2(poolSize)).toFixed(1)

    this.resultOutputTarget.value = result
    this.resultLengthTarget.textContent = length
    this.resultPoolSizeTarget.textContent = poolSize
    this.resultEntropyTarget.textContent = entropy + " bits"
  }

  randomChar(source) {
    return source[this.secureRandomInt(source.length)]
  }

  secureRandomInt(max) {
    const array = new Uint32Array(1)
    crypto.getRandomValues(array)
    return array[0] % max
  }

  copy() {
    const text = this.resultOutputTarget.value
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }
}
