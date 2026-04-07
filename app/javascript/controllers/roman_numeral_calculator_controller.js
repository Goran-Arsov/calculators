import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "numberInput", "romanInput", "resultOutput", "statusMessage"
  ]

  ROMAN_VALUES = [
    ["M", 1000], ["CM", 900], ["D", 500], ["CD", 400],
    ["C", 100],  ["XC", 90],  ["L", 50],  ["XL", 40],
    ["X", 10],   ["IX", 9],   ["V", 5],   ["IV", 4],
    ["I", 1]
  ]

  VALID_ROMAN = /^(M{0,3})(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$/i

  numberToRoman() {
    const input = this.numberInputTarget.value.trim()
    if (!input) {
      this.romanInputTarget.value = ""
      this.showStatus("")
      return
    }

    const num = parseInt(input, 10)
    if (isNaN(num) || num < 1 || num > 3999) {
      this.romanInputTarget.value = ""
      this.showStatus("Enter a number between 1 and 3999", "error")
      return
    }

    let remaining = num
    let result = ""
    for (const [roman, value] of this.ROMAN_VALUES) {
      while (remaining >= value) {
        result += roman
        remaining -= value
      }
    }

    this.romanInputTarget.value = result
    this.showStatus(`${num} = ${result}`, "success")
  }

  romanToNumber() {
    const input = this.romanInputTarget.value.trim().toUpperCase()
    if (!input) {
      this.numberInputTarget.value = ""
      this.showStatus("")
      return
    }

    if (!this.VALID_ROMAN.test(input) || input === "") {
      this.numberInputTarget.value = ""
      this.showStatus("Invalid roman numeral format", "error")
      return
    }

    let total = 0
    let i = 0
    while (i < input.length) {
      if (i + 1 < input.length) {
        const twoChar = input.substring(i, i + 2)
        const match = this.ROMAN_VALUES.find(([r]) => r === twoChar)
        if (match) {
          total += match[1]
          i += 2
          continue
        }
      }
      const oneChar = input[i]
      const match = this.ROMAN_VALUES.find(([r]) => r === oneChar)
      if (match) total += match[1]
      i++
    }

    this.numberInputTarget.value = total
    this.showStatus(`${input} = ${total}`, "success")
  }

  copyNumber() {
    this.copyToClipboard(this.numberInputTarget.value, "Number copied!")
  }

  copyRoman() {
    this.copyToClipboard(this.romanInputTarget.value, "Roman numeral copied!")
  }

  copyToClipboard(text, message) {
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      this.showStatus(message, "success")
    })
  }

  clearAll() {
    this.numberInputTarget.value = ""
    this.romanInputTarget.value = ""
    this.showStatus("")
  }

  showStatus(message, type = "") {
    if (!this.hasStatusMessageTarget) return
    this.statusMessageTarget.textContent = message
    this.statusMessageTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")

    if (type === "success") {
      this.statusMessageTarget.classList.add("text-green-600", "dark:text-green-400")
    } else if (type === "error") {
      this.statusMessageTarget.classList.add("text-red-500", "dark:text-red-400")
    }
  }
}
