import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "count", "unit", "output",
    "resultWordCount"
  ]

  static WORDS = [
    "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do",
    "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "enim",
    "ad", "minim", "veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi",
    "aliquip", "ex", "ea", "commodo", "consequat", "duis", "aute", "irure", "in", "reprehenderit",
    "voluptate", "velit", "esse", "cillum", "fugiat", "nulla", "pariatur", "excepteur", "sint",
    "occaecat", "cupidatat", "non", "proident", "sunt", "culpa", "qui", "officia", "deserunt",
    "mollit", "anim", "id", "est", "laborum", "perspiciatis", "unde", "omnis", "iste", "natus",
    "error", "voluptatem", "accusantium", "totam", "rem", "aperiam", "eaque", "ipsa", "quae",
    "ab", "illo", "inventore", "veritatis", "quasi", "architecto", "beatae", "vitae", "dicta",
    "explicabo", "nemo", "ipsam", "quia", "voluptas", "aspernatur", "aut", "odit", "fugit",
    "consequuntur", "magni", "dolores", "eos", "ratione", "sequi", "nesciunt", "neque", "porro",
    "quisquam", "dolorem", "adipisci", "numquam", "eius", "modi", "tempora", "incidunt", "magnam",
    "aliquam", "quaerat"
  ]

  calculate() {
    const count = parseInt(this.countTarget.value) || 0
    const unit = this.unitTarget.value

    if (count <= 0 || count > 100) {
      this.outputTarget.value = ""
      this.resultWordCountTarget.textContent = "\u2014"
      return
    }

    let text = ""
    switch (unit) {
      case "words":
        text = this.generateWords(count)
        break
      case "sentences":
        text = Array.from({ length: count }, () => this.generateSentence()).join(" ")
        break
      case "paragraphs":
        text = Array.from({ length: count }, () => this.generateParagraph()).join("\n\n")
        break
    }

    this.outputTarget.value = text
    const wordCount = text.split(/\s+/).filter(w => w.length > 0).length
    this.resultWordCountTarget.textContent = wordCount.toLocaleString()
  }

  generateWords(n) {
    const words = this.constructor.WORDS
    const result = []
    while (result.length < n) {
      result.push(...this.shuffleArray([...words]))
    }
    return result.slice(0, n).join(" ")
  }

  generateSentence() {
    const wordCount = Math.floor(Math.random() * 9) + 8
    const words = this.generateWords(wordCount).split(" ")
    words[0] = words[0].charAt(0).toUpperCase() + words[0].slice(1)
    return words.join(" ") + "."
  }

  generateParagraph() {
    const sentenceCount = Math.floor(Math.random() * 5) + 4
    return Array.from({ length: sentenceCount }, () => this.generateSentence()).join(" ")
  }

  shuffleArray(arr) {
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]]
    }
    return arr
  }

  copy() {
    const text = this.outputTarget.value
    if (text) {
      navigator.clipboard.writeText(text)
    }
  }
}
