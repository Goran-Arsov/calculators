import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "resultKeywordCount", "resultLineCount", "resultStatus"]

  static keywords = [
    "SELECT", "FROM", "WHERE", "JOIN", "ON", "AND", "OR", "INSERT", "UPDATE",
    "DELETE", "CREATE", "ALTER", "DROP", "GROUP BY", "ORDER BY", "HAVING",
    "LIMIT", "OFFSET", "UNION", "INTO", "VALUES", "SET", "AS", "IN", "NOT",
    "NULL", "IS", "BETWEEN", "LIKE", "EXISTS", "CASE", "WHEN", "THEN", "ELSE",
    "END", "LEFT", "RIGHT", "INNER", "OUTER", "FULL", "CROSS", "DISTINCT",
    "COUNT", "SUM", "AVG", "MIN", "MAX", "WITH", "RECURSIVE"
  ]

  static newlineBefore = [
    "SELECT", "FROM", "WHERE", "INNER JOIN", "LEFT JOIN", "RIGHT JOIN",
    "FULL JOIN", "CROSS JOIN", "JOIN", "GROUP BY", "ORDER BY", "HAVING",
    "LIMIT", "UNION"
  ]

  static indentKeywords = ["AND", "OR", "ON", "SET", "VALUES", "INTO"]

  format() {
    const sql = this.inputTarget.value
    if (!sql || !sql.trim()) {
      this.clearResults()
      return
    }

    try {
      const formatted = this.formatSql(sql)
      this.outputTarget.value = formatted
      this.resultStatusTarget.textContent = "Formatted"
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.resultKeywordCountTarget.textContent = this.countKeywords(sql)
      this.resultLineCountTarget.textContent = formatted.split("\n").length
    } catch (e) {
      this.resultStatusTarget.textContent = "Error: " + e.message
      this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
      this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
    }
  }

  formatSql(sql) {
    // Normalize whitespace
    let result = sql.replace(/\s+/g, " ").trim()

    // Uppercase keywords (multi-word first)
    const sortedKeywords = [...this.constructor.keywords].sort((a, b) => b.length - a.length)
    sortedKeywords.forEach(keyword => {
      const pattern = new RegExp("\\b" + keyword.replace(/ /g, "\\s+") + "\\b", "gi")
      result = result.replace(pattern, keyword)
    })

    // Add newlines before major clauses (multi-word first)
    const sortedClauses = [...this.constructor.newlineBefore].sort((a, b) => b.length - a.length)
    sortedClauses.forEach(clause => {
      const pattern = new RegExp("\\s+(?=" + clause.replace(/ /g, "\\s+") + "\\b)", "gi")
      result = result.replace(pattern, "\n")
    })

    // Indent sub-clauses
    const lines = result.split("\n")
    const formatted = lines.map(line => {
      const trimmed = line.trim()
      const shouldIndent = this.constructor.indentKeywords.some(kw =>
        trimmed.startsWith(kw + " ") || trimmed === kw
      )
      return shouldIndent ? "  " + trimmed : trimmed
    })

    return formatted.join("\n")
  }

  countKeywords(sql) {
    let count = 0
    const sortedKeywords = [...this.constructor.keywords].sort((a, b) => b.length - a.length)
    sortedKeywords.forEach(keyword => {
      const pattern = new RegExp("\\b" + keyword.replace(/ /g, "\\s+") + "\\b", "gi")
      const matches = sql.match(pattern)
      if (matches) count += matches.length
    })
    return count
  }

  clearResults() {
    this.outputTarget.value = ""
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultKeywordCountTarget.textContent = "\u2014"
    this.resultLineCountTarget.textContent = "\u2014"
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
