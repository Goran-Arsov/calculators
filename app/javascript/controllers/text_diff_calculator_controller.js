import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputA", "inputB", "output",
    "resultAdditions", "resultRemovals", "resultUnchanged", "resultIdentical"
  ]

  calculate() {
    const textA = this.inputATarget.value
    const textB = this.inputBTarget.value

    if ((!textA || !textA.trim()) && (!textB || !textB.trim())) {
      this.clearResults()
      return
    }

    const linesA = textA.split("\n")
    const linesB = textB.split("\n")
    const diff = this.computeDiff(linesA, linesB)

    let additions = 0, removals = 0, unchanged = 0
    diff.forEach(d => {
      if (d.type === "added") additions++
      else if (d.type === "removed") removals++
      else unchanged++
    })

    this.resultAdditionsTarget.textContent = additions
    this.resultRemovalsTarget.textContent = removals
    this.resultUnchangedTarget.textContent = unchanged
    this.resultIdenticalTarget.textContent = textA === textB ? "Yes" : "No"

    this.renderDiff(diff)
  }

  computeDiff(linesA, linesB) {
    const lcs = this.lcs(linesA, linesB)
    const result = []
    let i = 0, j = 0, k = 0

    while (k < lcs.length) {
      while (i < linesA.length && linesA[i] !== lcs[k]) {
        result.push({ type: "removed", line: linesA[i] })
        i++
      }
      while (j < linesB.length && linesB[j] !== lcs[k]) {
        result.push({ type: "added", line: linesB[j] })
        j++
      }
      result.push({ type: "unchanged", line: lcs[k] })
      i++; j++; k++
    }

    while (i < linesA.length) {
      result.push({ type: "removed", line: linesA[i] })
      i++
    }
    while (j < linesB.length) {
      result.push({ type: "added", line: linesB[j] })
      j++
    }

    return result
  }

  lcs(a, b) {
    const m = a.length, n = b.length
    const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0))

    for (let i = 1; i <= m; i++) {
      for (let j = 1; j <= n; j++) {
        dp[i][j] = a[i - 1] === b[j - 1] ? dp[i - 1][j - 1] + 1 : Math.max(dp[i - 1][j], dp[i][j - 1])
      }
    }

    const result = []
    let i = m, j = n
    while (i > 0 && j > 0) {
      if (a[i - 1] === b[j - 1]) {
        result.unshift(a[i - 1])
        i--; j--
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--
      } else {
        j--
      }
    }
    return result
  }

  renderDiff(diff) {
    let html = ""
    diff.forEach(d => {
      const escaped = this.escapeHtml(d.line)
      if (d.type === "removed") {
        html += `<div class="bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-300 px-3 py-1 font-mono text-sm border-l-4 border-red-400">- ${escaped}</div>`
      } else if (d.type === "added") {
        html += `<div class="bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-300 px-3 py-1 font-mono text-sm border-l-4 border-green-400">+ ${escaped}</div>`
      } else {
        html += `<div class="text-gray-600 dark:text-gray-400 px-3 py-1 font-mono text-sm border-l-4 border-gray-200 dark:border-gray-700">&nbsp; ${escaped}</div>`
      }
    })
    this.outputTarget.innerHTML = html || '<div class="text-gray-400 p-4 text-center">Enter text in both fields to see the diff</div>'
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  clearResults() {
    this.resultAdditionsTarget.textContent = "\u2014"
    this.resultRemovalsTarget.textContent = "\u2014"
    this.resultUnchangedTarget.textContent = "\u2014"
    this.resultIdenticalTarget.textContent = "\u2014"
    this.outputTarget.innerHTML = '<div class="text-gray-400 p-4 text-center">Enter text in both fields to see the diff</div>'
  }

  copy() {
    const text = this.outputTarget.innerText
    if (text) {
      navigator.clipboard.writeText(text)
    }
  }
}
