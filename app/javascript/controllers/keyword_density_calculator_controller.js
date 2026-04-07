import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "textInput", "targetKeyword",
    "resultTotalWords", "resultUniqueWords",
    "wordsTable", "bigramsTable", "trigramsTable",
    "targetKeywordResult"
  ]

  static STOP_WORDS = new Set([
    "the", "a", "an", "is", "are", "was", "were", "am", "be", "been", "being",
    "and", "or", "but", "nor", "not", "so", "yet", "both", "either", "neither",
    "in", "on", "at", "to", "for", "of", "with", "by", "from", "as",
    "it", "its", "this", "that", "these", "those",
    "i", "me", "my", "we", "us", "our", "you", "your", "he", "him", "his", "she", "her", "they", "them", "their",
    "what", "which", "who", "whom", "whose", "when", "where", "why", "how",
    "do", "does", "did", "will", "would", "shall", "should", "can", "could", "may", "might", "must",
    "have", "has", "had", "having",
    "if", "then", "else", "than", "because", "since", "while", "although", "though",
    "about", "above", "after", "again", "against", "all", "also", "another", "any", "before",
    "between", "into", "through", "during", "each", "few", "more", "most", "other", "some", "such",
    "no", "only", "own", "same", "too", "very", "just", "over", "under"
  ])

  analyze() {
    const text = this.textInputTarget.value.trim()
    if (!text) {
      this.resultTotalWordsTarget.textContent = "0"
      this.resultUniqueWordsTarget.textContent = "0"
      this.wordsTableTarget.innerHTML = '<tr><td class="p-3 text-gray-400 dark:text-gray-500 text-center" colspan="3">Enter text and click Analyze</td></tr>'
      this.bigramsTableTarget.innerHTML = '<tr><td class="p-3 text-gray-400 dark:text-gray-500 text-center" colspan="3">No data yet</td></tr>'
      this.trigramsTableTarget.innerHTML = '<tr><td class="p-3 text-gray-400 dark:text-gray-500 text-center" colspan="3">No data yet</td></tr>'
      this.targetKeywordResultTarget.innerHTML = ""
      return
    }

    const words = text.toLowerCase().replace(/[^a-z0-9'\s-]/g, "").split(/\s+/).filter(w => w.length > 0)
    const totalWords = words.length
    const uniqueWords = new Set(words).size

    this.resultTotalWordsTarget.textContent = totalWords.toLocaleString()
    this.resultUniqueWordsTarget.textContent = uniqueWords.toLocaleString()

    const filtered = words.filter(w => !this.constructor.STOP_WORDS.has(w))

    // Single words
    const wordFreq = {}
    filtered.forEach(w => { wordFreq[w] = (wordFreq[w] || 0) + 1 })
    const topWords = Object.entries(wordFreq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 20)

    this.wordsTableTarget.innerHTML = topWords.map(([word, count]) => {
      const density = ((count / totalWords) * 100).toFixed(2)
      return `<tr class="border-b border-gray-100 dark:border-gray-700">
        <td class="p-2 text-sm text-gray-900 dark:text-white font-medium">${this._escapeHtml(word)}</td>
        <td class="p-2 text-sm text-gray-600 dark:text-gray-400 text-center">${count}</td>
        <td class="p-2 text-sm text-gray-600 dark:text-gray-400 text-center">${density}%</td>
      </tr>`
    }).join("") || '<tr><td class="p-3 text-gray-400 text-center" colspan="3">No words found</td></tr>'

    // Bigrams
    this.bigramsTableTarget.innerHTML = this._buildNgramRows(filtered, 2, totalWords)
    // Trigrams
    this.trigramsTableTarget.innerHTML = this._buildNgramRows(filtered, 3, totalWords)

    // Target keyword
    this._checkTargetKeyword(text, totalWords)
  }

  _buildNgramRows(words, n, total) {
    if (words.length < n) return '<tr><td class="p-3 text-gray-400 dark:text-gray-500 text-center" colspan="3">Not enough words</td></tr>'

    const freq = {}
    for (let i = 0; i <= words.length - n; i++) {
      const gram = words.slice(i, i + n).join(" ")
      freq[gram] = (freq[gram] || 0) + 1
    }

    const top = Object.entries(freq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)

    if (top.length === 0) return '<tr><td class="p-3 text-gray-400 dark:text-gray-500 text-center" colspan="3">No data</td></tr>'

    return top.map(([phrase, count]) => {
      const density = ((count / total) * 100).toFixed(2)
      return `<tr class="border-b border-gray-100 dark:border-gray-700">
        <td class="p-2 text-sm text-gray-900 dark:text-white font-medium">${this._escapeHtml(phrase)}</td>
        <td class="p-2 text-sm text-gray-600 dark:text-gray-400 text-center">${count}</td>
        <td class="p-2 text-sm text-gray-600 dark:text-gray-400 text-center">${density}%</td>
      </tr>`
    }).join("")
  }

  _checkTargetKeyword(text, totalWords) {
    if (!this.hasTargetKeywordTarget) return
    const keyword = this.targetKeywordTarget.value.trim().toLowerCase()
    if (!keyword) {
      this.targetKeywordResultTarget.innerHTML = ""
      return
    }

    const words = text.toLowerCase().split(/\s+/)
    let count = 0
    const kwWords = keyword.split(/\s+/)

    if (kwWords.length === 1) {
      count = words.filter(w => w.replace(/[^a-z0-9]/g, "") === keyword).length
    } else {
      for (let i = 0; i <= words.length - kwWords.length; i++) {
        const slice = words.slice(i, i + kwWords.length).map(w => w.replace(/[^a-z0-9]/g, ""))
        if (slice.join(" ") === kwWords.join(" ")) count++
      }
    }

    const density = totalWords > 0 ? ((count / totalWords) * 100).toFixed(2) : "0.00"
    let color = "text-green-600 dark:text-green-400"
    let label = "Good"
    if (parseFloat(density) === 0) { color = "text-red-600 dark:text-red-400"; label = "Not found" }
    else if (parseFloat(density) > 3) { color = "text-yellow-600 dark:text-yellow-400"; label = "High (possible keyword stuffing)" }
    else if (parseFloat(density) < 0.5) { color = "text-yellow-600 dark:text-yellow-400"; label = "Low" }

    this.targetKeywordResultTarget.innerHTML = `
      <div class="bg-gray-50 dark:bg-gray-800 rounded-xl p-4">
        <p class="text-sm text-gray-600 dark:text-gray-400">Target keyword: <strong class="text-gray-900 dark:text-white">"${this._escapeHtml(keyword)}"</strong></p>
        <p class="text-sm mt-1">Occurrences: <strong>${count}</strong> | Density: <strong class="${color}">${density}% (${label})</strong></p>
      </div>`
  }

  _escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
