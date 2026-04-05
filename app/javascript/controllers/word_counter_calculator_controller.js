import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "resultWords", "resultCharacters", "resultCharactersNoSpaces",
    "resultSentences", "resultParagraphs",
    "resultReadingTime", "resultSpeakingTime"
  ]

  static READING_WPM = 238
  static SPEAKING_WPM = 150

  calculate() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    const words = text.split(/\s+/).filter(w => w.length > 0)
    const sentences = (text.match(/[.!?]+/g) || []).length
    const paragraphs = text.split(/\n\s*\n/).filter(p => p.trim().length > 0).length || (words.length > 0 ? 1 : 0)

    this.resultWordsTarget.textContent = words.length.toLocaleString()
    this.resultCharactersTarget.textContent = text.length.toLocaleString()
    this.resultCharactersNoSpacesTarget.textContent = text.replace(/\s/g, "").length.toLocaleString()
    this.resultSentencesTarget.textContent = sentences.toLocaleString()
    this.resultParagraphsTarget.textContent = paragraphs.toLocaleString()
    this.resultReadingTimeTarget.textContent = Math.ceil(words.length / this.constructor.READING_WPM) + " min"
    this.resultSpeakingTimeTarget.textContent = Math.ceil(words.length / this.constructor.SPEAKING_WPM) + " min"
  }

  clearResults() {
    const targets = [
      "resultWords", "resultCharacters", "resultCharactersNoSpaces",
      "resultSentences", "resultParagraphs",
      "resultReadingTime", "resultSpeakingTime"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Words: ${this.resultWordsTarget.textContent}`,
      `Characters: ${this.resultCharactersTarget.textContent}`,
      `Characters (no spaces): ${this.resultCharactersNoSpacesTarget.textContent}`,
      `Sentences: ${this.resultSentencesTarget.textContent}`,
      `Paragraphs: ${this.resultParagraphsTarget.textContent}`,
      `Reading Time: ${this.resultReadingTimeTarget.textContent}`,
      `Speaking Time: ${this.resultSpeakingTimeTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
