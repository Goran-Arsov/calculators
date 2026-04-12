import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textA", "textB", "output", "stats", "error"]

  compare() {
    const textA = this.textATarget.value
    const textB = this.textBTarget.value

    if (!textA.trim() && !textB.trim()) {
      this.showError("Please enter text in both fields to compare.")
      return
    }

    this.hideError()

    const linesA = textA.split("\n")
    const linesB = textB.split("\n")
    const diff = this.computeDiff(linesA, linesB)

    this.renderDiff(diff)
    this.renderStats(diff)
  }

  computeDiff(linesA, linesB) {
    const m = linesA.length
    const n = linesB.length

    // Build LCS table
    const table = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0))
    for (let i = 1; i <= m; i++) {
      for (let j = 1; j <= n; j++) {
        if (linesA[i - 1] === linesB[j - 1]) {
          table[i][j] = table[i - 1][j - 1] + 1
        } else {
          table[i][j] = Math.max(table[i - 1][j], table[i][j - 1])
        }
      }
    }

    // Backtrack
    const result = []
    let i = m, j = n
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && linesA[i - 1] === linesB[j - 1]) {
        result.unshift({ type: "unchanged", lineA: i, lineB: j, content: linesA[i - 1] })
        i--; j--
      } else if (j > 0 && (i === 0 || table[i][j - 1] >= table[i - 1][j])) {
        result.unshift({ type: "added", lineB: j, content: linesB[j - 1] })
        j--
      } else if (i > 0) {
        result.unshift({ type: "removed", lineA: i, content: linesA[i - 1] })
        i--
      }
    }

    return result
  }

  renderDiff(diff) {
    let html = '<div class="font-mono text-sm">'

    diff.forEach(entry => {
      const escaped = this.escapeHtml(entry.content)
      if (entry.type === "unchanged") {
        html += `<div class="flex"><span class="w-12 text-right pr-2 text-gray-400 select-none">${entry.lineA}</span><span class="w-12 text-right pr-2 text-gray-400 select-none">${entry.lineB}</span><span class="flex-1 px-2">${escaped}</span></div>`
      } else if (entry.type === "removed") {
        html += `<div class="flex bg-red-100 dark:bg-red-900/30"><span class="w-12 text-right pr-2 text-red-500 select-none">${entry.lineA}</span><span class="w-12 text-right pr-2 select-none"></span><span class="flex-1 px-2 text-red-700 dark:text-red-400">- ${escaped}</span></div>`
      } else if (entry.type === "added") {
        html += `<div class="flex bg-green-100 dark:bg-green-900/30"><span class="w-12 text-right pr-2 select-none"></span><span class="w-12 text-right pr-2 text-green-500 select-none">${entry.lineB}</span><span class="flex-1 px-2 text-green-700 dark:text-green-400">+ ${escaped}</span></div>`
      }
    })

    html += '</div>'
    this.outputTarget.innerHTML = html
  }

  renderStats(diff) {
    const added = diff.filter(d => d.type === "added").length
    const removed = diff.filter(d => d.type === "removed").length
    const unchanged = diff.filter(d => d.type === "unchanged").length

    this.statsTarget.innerHTML = `
      <span class="text-green-600 dark:text-green-400 font-semibold">+${added} added</span>
      <span class="mx-2 text-gray-400">|</span>
      <span class="text-red-600 dark:text-red-400 font-semibold">-${removed} removed</span>
      <span class="mx-2 text-gray-400">|</span>
      <span class="text-gray-600 dark:text-gray-400">${unchanged} unchanged</span>
    `
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  showError(msg) {
    this.errorTarget.textContent = msg
    this.errorTarget.classList.remove("hidden")
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }

  swap() {
    const temp = this.textATarget.value
    this.textATarget.value = this.textBTarget.value
    this.textBTarget.value = temp
    if (this.textATarget.value || this.textBTarget.value) this.compare()
  }

  clear() {
    this.textATarget.value = ""
    this.textBTarget.value = ""
    this.outputTarget.innerHTML = ""
    this.statsTarget.innerHTML = ""
    this.hideError()
  }

  copy() {
    const text = this.outputTarget.innerText
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
