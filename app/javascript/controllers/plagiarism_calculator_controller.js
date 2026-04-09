import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "text1", "text2",
    "resultSimilarity", "resultMatchingPhrases",
    "resultTotalPhrases1", "resultTotalPhrases2",
    "similarityBar"
  ]

  static MAX_WORDS = 10000

  calculate() {
    const text1 = this.text1Target.value
    const text2 = this.text2Target.value

    if (!text1.trim() || !text2.trim()) {
      this.clearResults()
      return
    }

    const wordCount1 = text1.split(/\s+/).filter(w => w).length
    const wordCount2 = text2.split(/\s+/).filter(w => w).length
    if (wordCount1 > this.constructor.MAX_WORDS || wordCount2 > this.constructor.MAX_WORDS) {
      this.resultSimilarityTarget.textContent = `Limit: ${this.constructor.MAX_WORDS.toLocaleString()} words per text`
      return
    }

    const words1 = this.normalize(text1)
    const words2 = this.normalize(text2)

    const ngrams1 = this.generateNgrams(words1, 3)
    const ngrams2 = this.generateNgrams(words2, 3)

    const set1 = new Set(ngrams1)
    const set2 = new Set(ngrams2)

    const intersection = new Set([...set1].filter(x => set2.has(x)))
    const union = new Set([...set1, ...set2])

    const similarity = union.size === 0 ? 0 : (intersection.size / union.size) * 100

    this.resultSimilarityTarget.textContent = similarity.toFixed(2) + "%"
    this.resultMatchingPhrasesTarget.textContent = intersection.size
    this.resultTotalPhrases1Target.textContent = set1.size
    this.resultTotalPhrases2Target.textContent = set2.size

    if (this.hasSimilarityBarTarget) {
      this.similarityBarTarget.style.width = Math.min(similarity, 100).toFixed(1) + "%"
      this.similarityBarTarget.className = this.similarityBarTarget.className.replace(/bg-\w+-\d+/g, "")
      if (similarity >= 70) {
        this.similarityBarTarget.classList.add("bg-red-500")
      } else if (similarity >= 40) {
        this.similarityBarTarget.classList.add("bg-yellow-500")
      } else {
        this.similarityBarTarget.classList.add("bg-green-500")
      }
    }
  }

  normalize(text) {
    return text.toLowerCase().replace(/[^a-z0-9\s]/g, "").split(/\s+/).filter(w => w)
  }

  generateNgrams(words, n) {
    if (words.length < n) return []
    const ngrams = []
    const seen = new Set()
    for (let i = 0; i <= words.length - n; i++) {
      const gram = words.slice(i, i + n).join(" ")
      if (!seen.has(gram)) {
        ngrams.push(gram)
        seen.add(gram)
      }
    }
    return ngrams
  }

  clearResults() {
    this.resultSimilarityTarget.textContent = "—"
    this.resultMatchingPhrasesTarget.textContent = "—"
    this.resultTotalPhrases1Target.textContent = "—"
    this.resultTotalPhrases2Target.textContent = "—"
    if (this.hasSimilarityBarTarget) {
      this.similarityBarTarget.style.width = "0%"
    }
  }

  copy() {
    const similarity = this.resultSimilarityTarget.textContent
    const matching = this.resultMatchingPhrasesTarget.textContent
    const total1 = this.resultTotalPhrases1Target.textContent
    const total2 = this.resultTotalPhrases2Target.textContent
    const text = `Similarity: ${similarity}\nMatching Phrases: ${matching}\nTotal Phrases (Text 1): ${total1}\nTotal Phrases (Text 2): ${total2}`
    navigator.clipboard.writeText(text)
  }
}
