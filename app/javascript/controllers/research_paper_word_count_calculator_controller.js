import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "pageCount", "font", "spacing", "margins", "fontSize",
    "hasReferences", "referencePages", "referencePagesField",
    "estimatedWords", "wordsPerPage", "contentPages",
    "readingTime", "speakingTime", "estimatedParagraphs", "estimatedSentences"
  ]

  static wordsPerPage = {
    times_new_roman: { single: 500, "1.5": 375, double: 250 },
    arial: { single: 450, "1.5": 338, double: 225 },
    calibri: { single: 470, "1.5": 353, double: 235 },
    courier: { single: 420, "1.5": 315, double: 210 },
    georgia: { single: 470, "1.5": 353, double: 235 },
    verdana: { single: 400, "1.5": 300, double: 200 }
  }

  static marginFactors = { "1_inch": 1.0, "1.25_inch": 0.92, "1.5_inch": 0.84, "0.75_inch": 1.10 }
  static fontSizeFactors = { 10: 1.20, 11: 1.10, 12: 1.00, 13: 0.92, 14: 0.85 }

  calculate() {
    const pages = parseFloat(this.pageCountTarget.value) || 0
    const font = this.fontTarget.value || "times_new_roman"
    const spacing = this.spacingTarget.value || "double"
    const margins = this.marginsTarget.value || "1_inch"
    const fontSize = parseInt(this.fontSizeTarget.value) || 12
    const hasRefs = this.hasReferencesTarget.checked
    const refPages = parseFloat(this.referencePagesTarget.value) || 0

    // Toggle reference pages field
    if (this.hasReferencePagesFieldTarget) {
      this.referencePagesFieldTarget.classList.toggle("hidden", !hasRefs)
    }

    if (pages <= 0) {
      this.clearResults()
      return
    }

    const contentPages = hasRefs ? Math.max(pages - refPages, 0) : pages
    const baseWpp = this.constructor.wordsPerPage[font]?.[spacing] || 250
    const marginFactor = this.constructor.marginFactors[margins] || 1.0
    const sizeFactor = this.constructor.fontSizeFactors[fontSize] || 1.0

    const adjustedWpp = Math.round(baseWpp * marginFactor * sizeFactor)
    const estimatedWords = Math.round(contentPages * adjustedWpp)

    const readingTime = (estimatedWords / 238).toFixed(1)
    const speakingTime = (estimatedWords / 150).toFixed(1)
    const paragraphs = Math.round(estimatedWords / 150)
    const sentences = Math.round(estimatedWords / 20)

    this.estimatedWordsTarget.textContent = estimatedWords.toLocaleString()
    this.wordsPerPageTarget.textContent = adjustedWpp.toLocaleString()
    this.contentPagesTarget.textContent = contentPages.toFixed(1)
    this.readingTimeTarget.textContent = readingTime + " min"
    this.speakingTimeTarget.textContent = speakingTime + " min"
    this.estimatedParagraphsTarget.textContent = paragraphs
    this.estimatedSentencesTarget.textContent = sentences
  }

  clearResults() {
    this.estimatedWordsTarget.textContent = "0"
    this.wordsPerPageTarget.textContent = "0"
    this.contentPagesTarget.textContent = "0"
    this.readingTimeTarget.textContent = "0 min"
    this.speakingTimeTarget.textContent = "0 min"
    this.estimatedParagraphsTarget.textContent = "0"
    this.estimatedSentencesTarget.textContent = "0"
  }

  formatNumber(value) {
    return new Intl.NumberFormat("en-US").format(value)
  }

  copy() {
    const text = `Research Paper Word Count Estimate\nEstimated Words: ${this.estimatedWordsTarget.textContent}\nWords Per Page: ${this.wordsPerPageTarget.textContent}\nContent Pages: ${this.contentPagesTarget.textContent}\nReading Time: ${this.readingTimeTarget.textContent}\nSpeaking Time: ${this.speakingTimeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
