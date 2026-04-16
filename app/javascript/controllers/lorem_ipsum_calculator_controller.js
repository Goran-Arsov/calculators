import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "count", "unit", "output", "startClassic", "includeHtml",
    "resultWordCount", "resultCharCount", "resultSentenceCount", "resultParagraphCount",
    "copyBtn"
  ]

  static CLASSIC_OPENING = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

  static WORDS = [
    "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do",
    "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "enim",
    "ad", "minim", "veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi",
    "aliquip", "ex", "ea", "commodo", "consequat", "duis", "aute", "irure", "in", "reprehenderit",
    "voluptate", "velit", "esse", "cillum", "fugiat", "nulla", "pariatur", "excepteur", "sint",
    "occaecat", "cupidatat", "non", "proident", "sunt", "culpa", "qui", "officia", "deserunt",
    "mollit", "anim", "id", "est", "laborum", "perspiciatis", "unde", "omnis", "iste", "natus",
    "error", "voluptatem", "accusantium", "doloremque", "laudantium", "totam", "rem", "aperiam",
    "eaque", "ipsa", "quae", "ab", "illo", "inventore", "veritatis", "quasi", "architecto",
    "beatae", "vitae", "dicta", "explicabo", "nemo", "ipsam", "quia", "voluptas", "aspernatur",
    "aut", "odit", "fugit", "consequuntur", "magni", "dolores", "eos", "ratione", "sequi",
    "nesciunt", "neque", "porro", "quisquam", "dolorem", "adipisci", "numquam", "eius", "modi",
    "tempora", "incidunt", "magnam", "aliquam", "quaerat", "voluptatibus", "maiores", "alias",
    "perferendis", "doloribus", "asperiores", "repellat", "temporibus", "quibusdam", "illum",
    "blanditiis", "praesentium", "voluptatum", "deleniti", "atque", "corrupti", "quos",
    "quas", "molestias", "excepturi", "occaecati", "cupiditate", "provident", "similique",
    "mollitia", "animi", "sapiente", "delectus", "rerum", "hic", "tenetur", "soluta",
    "nobis", "eligendi", "optio", "cumque", "nihil", "impedit", "quo", "minus", "maxime",
    "placeat", "facere", "possimus", "assumenda", "repellendus", "autem", "vel", "eum",
    "iure", "quod", "recusandae", "itaque", "earum", "harum", "necessitatibus", "saepe",
    "eveniet", "voluptates", "repudiandae", "pariatur", "distinctio", "nam", "libero",
    "tempore", "cum", "soluta", "debitis", "reiciendis", "dignissimos", "ducimus",
    "blanditiis", "praesentium", "accusamus", "facilis", "expedita", "deserunt",
    "recusandae", "fuga", "nostrum", "exercitationem", "ullam", "corporis", "suscipit",
    "laboriosam", "natus", "consequatur", "perspiciatis", "inventore", "veritatis"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const count = parseInt(this.countTarget.value) || 0
    const unit = this.unitTarget.value
    const startClassic = this.startClassicTarget.checked
    const includeHtml = this.includeHtmlTarget.checked

    if (count <= 0 || count > 100) {
      this.outputTarget.value = ""
      this.updateStats("", 0)
      return
    }

    let paragraphs = []
    const classicOpening = this.constructor.CLASSIC_OPENING

    switch (unit) {
      case "words": {
        let text = startClassic ? classicOpening + " " : ""
        const classicWordCount = startClassic ? classicOpening.split(/\s+/).length : 0
        const remaining = count - classicWordCount
        if (remaining > 0) {
          text += this.generateWords(remaining)
        } else if (startClassic) {
          text = classicOpening.split(/\s+/).slice(0, count).join(" ")
          if (!text.endsWith(".")) text += "."
        }
        this.setOutput(text.trim(), includeHtml, false)
        return
      }
      case "sentences": {
        let sentences = []
        if (startClassic) {
          const classicSentences = classicOpening.split(/\.\s*/).filter(s => s.length > 0).map(s => s.endsWith(".") ? s : s + ".")
          sentences.push(...classicSentences.slice(0, count))
        }
        while (sentences.length < count) {
          sentences.push(this.generateSentence())
        }
        const text = sentences.slice(0, count).join(" ")
        this.setOutput(text, includeHtml, false)
        return
      }
      case "paragraphs": {
        if (startClassic) {
          paragraphs.push(classicOpening)
        }
        while (paragraphs.length < count) {
          paragraphs.push(this.generateParagraph())
        }
        paragraphs = paragraphs.slice(0, count)
        this.setOutput(paragraphs.join("\n\n"), includeHtml, true)
        return
      }
    }
  }

  setOutput(text, includeHtml, isParagraphs) {
    let output = text
    if (includeHtml && isParagraphs) {
      const paras = text.split("\n\n")
      output = paras.map(p => `<p>${p}</p>`).join("\n\n")
    }
    this.outputTarget.value = output
    this.updateStats(text, 0)
  }

  updateStats(text) {
    const words = text.split(/\s+/).filter(w => w.length > 0)
    const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0)
    const paragraphs = text.split(/\n\n+/).filter(p => p.trim().length > 0)

    this.resultWordCountTarget.textContent = words.length.toLocaleString()
    this.resultCharCountTarget.textContent = text.length.toLocaleString()
    if (this.hasResultSentenceCountTarget) this.resultSentenceCountTarget.textContent = sentences.length.toLocaleString()
    if (this.hasResultParagraphCountTarget) this.resultParagraphCountTarget.textContent = paragraphs.length.toLocaleString()
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
    const wordCount = Math.floor(Math.random() * 10) + 7
    const words = this.generateWords(wordCount).split(" ")
    words[0] = words[0].charAt(0).toUpperCase() + words[0].slice(1)

    // Occasionally add a comma for more natural flow
    if (words.length > 6) {
      const commaPos = Math.floor(Math.random() * (words.length - 4)) + 2
      words[commaPos] = words[commaPos] + ","
    }

    return words.join(" ") + "."
  }

  generateParagraph() {
    const sentenceCount = Math.floor(Math.random() * 4) + 4
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
    if (!text) return
    navigator.clipboard.writeText(text)
    const btn = this.copyBtnTarget
    const original = btn.textContent
    btn.textContent = "Copied!"
    btn.classList.add("from-green-600", "to-green-700")
    btn.classList.remove("from-blue-600", "to-indigo-600")
    setTimeout(() => {
      btn.textContent = original
      btn.classList.remove("from-green-600", "to-green-700")
      btn.classList.add("from-blue-600", "to-indigo-600")
    }, 1500)
  }
}
