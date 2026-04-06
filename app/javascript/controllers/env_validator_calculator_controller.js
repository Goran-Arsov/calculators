import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "fileInput",
    "results", "variablesTable", "issuesList",
    "totalVars", "errorCount", "warningCount", "sensitiveCount",
    "error"
  ]

  static sensitivePatterns = ["PASSWORD", "SECRET", "KEY", "TOKEN", "API_KEY", "PRIVATE", "CREDENTIAL", "AUTH"]

  loadFile(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      this.inputTarget.value = e.target.result
    }
    reader.readAsText(file)
  }

  validate() {
    const content = this.inputTarget.value.trim()

    if (!content) {
      this.errorTarget.textContent = "Paste .env content or upload a file"
      this.errorTarget.classList.remove("hidden")
      this.resultsTarget.classList.add("hidden")
      return
    }

    this.errorTarget.classList.add("hidden")

    const lines = content.split("\n")
    const variables = []
    const issues = []
    const keyOccurrences = {}
    let sensitiveCount = 0

    lines.forEach((rawLine, index) => {
      const lineNumber = index + 1
      const line = rawLine.trimEnd()

      // Skip empty lines
      if (line.trim() === "") return

      // Detect commented-out variables
      if (line.trim().startsWith("#")) {
        if (/^#\s*[A-Z_][A-Z0-9_]*=/.test(line.trim())) {
          issues.push({ line: lineNumber, type: "warning", message: `Commented-out variable detected` })
        }
        return
      }

      // Lines missing = sign
      if (!line.includes("=")) {
        issues.push({ line: lineNumber, type: "error", message: `Line missing '=' sign: ${line.trim()}` })
        return
      }

      const eqIndex = line.indexOf("=")
      const key = line.substring(0, eqIndex).trim()
      const value = line.substring(eqIndex + 1)
      const strippedValue = value.trim()

      // Track duplicates
      if (!keyOccurrences[key]) keyOccurrences[key] = []
      keyOccurrences[key].push(lineNumber)

      let status = "valid"
      const varIssues = []

      // Empty values
      const unquoted = /^["'].*["']$/.test(strippedValue) ? strippedValue.slice(1, -1) : strippedValue
      if (strippedValue === "" || unquoted === "") {
        varIssues.push("Empty value")
        issues.push({ line: lineNumber, type: "warning", message: `Empty value for key '${key}'` })
        status = "warning"
      }

      // Unquoted spaces
      if (strippedValue.includes(" ") && !/^["'].*["']$/.test(strippedValue)) {
        varIssues.push("Unquoted spaces")
        issues.push({ line: lineNumber, type: "warning", message: `Value contains unquoted spaces` })
        status = "warning"
      }

      // Sensitive keys
      const isSensitive = this.constructor.sensitivePatterns.some(pattern =>
        key.toUpperCase().includes(pattern)
      )
      if (isSensitive) {
        varIssues.push("Sensitive")
        issues.push({ line: lineNumber, type: "warning", message: `Potentially sensitive key '${key}'` })
        sensitiveCount++
      }

      variables.push({ key, value: strippedValue, line: lineNumber, status, sensitive: isSensitive, issues: varIssues })
    })

    // Detect duplicates
    let errorCount = 0
    Object.entries(keyOccurrences).forEach(([key, lines]) => {
      if (lines.length > 1) {
        lines.forEach(ln => {
          issues.push({ line: ln, type: "error", message: `Duplicate key '${key}' (also on line${lines.length > 2 ? "s" : ""} ${lines.filter(l => l !== ln).join(", ")})` })
          const v = variables.find(v => v.key === key && v.line === ln)
          if (v) v.status = "error"
          errorCount++
        })
      }
    })

    // Count errors from non-duplicate line errors
    errorCount += issues.filter(i => i.type === "error" && !i.message.startsWith("Duplicate")).length

    // Sort issues by line number
    issues.sort((a, b) => a.line - b.line)

    // Render results
    this.resultsTarget.classList.remove("hidden")
    this.totalVarsTarget.textContent = variables.length
    this.errorCountTarget.textContent = errorCount
    this.warningCountTarget.textContent = issues.filter(i => i.type === "warning").length
    this.sensitiveCountTarget.textContent = sensitiveCount

    // Render variables table
    if (variables.length > 0) {
      let tableHtml = '<table class="w-full text-sm"><thead><tr class="text-left border-b border-gray-200 dark:border-gray-700">' +
        '<th class="py-2 px-2 text-gray-500 dark:text-gray-400">Line</th>' +
        '<th class="py-2 px-2 text-gray-500 dark:text-gray-400">Key</th>' +
        '<th class="py-2 px-2 text-gray-500 dark:text-gray-400">Value</th>' +
        '<th class="py-2 px-2 text-gray-500 dark:text-gray-400">Status</th>' +
        '</tr></thead><tbody>'

      variables.forEach(v => {
        const statusColor = v.status === "error" ? "text-red-600 dark:text-red-400" :
          v.status === "warning" ? "text-yellow-600 dark:text-yellow-400" :
          "text-green-600 dark:text-green-400"
        const statusIcon = v.status === "error" ? "Error" :
          v.status === "warning" ? "Warning" : "Valid"
        const displayValue = v.sensitive ? "********" : this.escapeHtml(v.value || "(empty)")

        tableHtml += `<tr class="border-b border-gray-100 dark:border-gray-800">` +
          `<td class="py-1.5 px-2 font-mono text-gray-400">${v.line}</td>` +
          `<td class="py-1.5 px-2 font-mono font-medium text-gray-900 dark:text-white">${this.escapeHtml(v.key)}</td>` +
          `<td class="py-1.5 px-2 font-mono text-gray-600 dark:text-gray-400 max-w-xs truncate">${displayValue}</td>` +
          `<td class="py-1.5 px-2 ${statusColor} font-medium">${statusIcon}</td>` +
          `</tr>`
      })

      tableHtml += '</tbody></table>'
      this.variablesTableTarget.innerHTML = tableHtml
    } else {
      this.variablesTableTarget.innerHTML = '<p class="text-gray-400 text-sm">No variables found</p>'
    }

    // Render issues
    if (issues.length > 0) {
      let issuesHtml = '<ul class="space-y-1">'
      issues.forEach(issue => {
        const color = issue.type === "error"
          ? "bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-400 border-red-200 dark:border-red-800"
          : "bg-yellow-50 dark:bg-yellow-900/20 text-yellow-700 dark:text-yellow-400 border-yellow-200 dark:border-yellow-800"
        const label = issue.type === "error" ? "ERROR" : "WARN"
        issuesHtml += `<li class="px-3 py-1.5 rounded-lg border text-sm ${color}">` +
          `<span class="font-semibold">${label}</span> Line ${issue.line}: ${this.escapeHtml(issue.message)}</li>`
      })
      issuesHtml += '</ul>'
      this.issuesListTarget.innerHTML = issuesHtml
    } else {
      this.issuesListTarget.innerHTML = '<p class="text-green-600 dark:text-green-400 text-sm font-medium">No issues found. All variables look valid.</p>'
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
