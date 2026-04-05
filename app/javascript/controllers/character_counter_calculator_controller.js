import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "resultCharacters", "resultCharactersNoSpaces",
    "resultLetters", "resultDigits", "resultSpecial",
    "resultLines", "resultWords"
  ]

  calculate() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    const letters = (text.match(/[a-zA-Z\u00C0-\u024F\u1E00-\u1EFF]/g) || []).length
    const digits = (text.match(/\d/g) || []).length
    const noSpaces = text.replace(/\s/g, "").length
    const special = noSpaces - letters - digits
    const lines = text.split("\n").length
    const words = text.split(/\s+/).filter(w => w.length > 0).length

    this.resultCharactersTarget.textContent = text.length.toLocaleString()
    this.resultCharactersNoSpacesTarget.textContent = noSpaces.toLocaleString()
    this.resultLettersTarget.textContent = letters.toLocaleString()
    this.resultDigitsTarget.textContent = digits.toLocaleString()
    this.resultSpecialTarget.textContent = special.toLocaleString()
    this.resultLinesTarget.textContent = lines.toLocaleString()
    this.resultWordsTarget.textContent = words.toLocaleString()
  }

  clearResults() {
    const targets = [
      "resultCharacters", "resultCharactersNoSpaces",
      "resultLetters", "resultDigits", "resultSpecial",
      "resultLines", "resultWords"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Characters: ${this.resultCharactersTarget.textContent}`,
      `Characters (no spaces): ${this.resultCharactersNoSpacesTarget.textContent}`,
      `Letters: ${this.resultLettersTarget.textContent}`,
      `Digits: ${this.resultDigitsTarget.textContent}`,
      `Special Characters: ${this.resultSpecialTarget.textContent}`,
      `Lines: ${this.resultLinesTarget.textContent}`,
      `Words: ${this.resultWordsTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
