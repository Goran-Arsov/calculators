import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "resultTokenCount", "resultHasGroups", "resultHasQuantifiers"]

  static TOKEN_EXPLANATIONS = {
    ".": "Any character (except newline)",
    "\\d": "Any digit (0-9)",
    "\\D": "Any non-digit character",
    "\\w": "Any word character (letter, digit, or underscore)",
    "\\W": "Any non-word character",
    "\\s": "Any whitespace character (space, tab, newline)",
    "\\S": "Any non-whitespace character",
    "\\b": "Word boundary",
    "\\B": "Non-word boundary",
    "\\t": "Tab character",
    "\\n": "Newline character",
    "\\r": "Carriage return",
    "^": "Start of string (or line in multiline mode)",
    "$": "End of string (or line in multiline mode)"
  }

  explain() {
    const pattern = this.inputTarget.value
    if (!pattern || !pattern.trim()) {
      this.clearResults()
      return
    }

    const tokens = this.tokenize(pattern)
    const lines = tokens.map((t, i) => `${i + 1}. \`${t.token}\` \u2014 ${t.explanation}`)

    this.outputTarget.value = lines.join("\n")
    this.resultTokenCountTarget.textContent = tokens.length
    this.resultHasGroupsTarget.textContent = pattern.includes("(") ? "Yes" : "No"
    this.resultHasQuantifiersTarget.textContent = /[*+?]|\{\d/.test(pattern) ? "Yes" : "No"
  }

  tokenize(pattern) {
    const tokens = []
    let i = 0

    while (i < pattern.length) {
      const char = pattern[i]

      if (char === "\\") {
        if (i + 1 < pattern.length) {
          const escaped = pattern.substring(i, i + 2)
          const explanation = this.constructor.TOKEN_EXPLANATIONS[escaped]
          tokens.push({ token: escaped, explanation: explanation || `Escaped literal '${pattern[i + 1]}'` })
          i += 2
        } else {
          tokens.push({ token: "\\", explanation: "Backslash (incomplete escape)" })
          i++
        }
      } else if (char === "[") {
        let end = i + 1
        if (end < pattern.length && pattern[end] === "^") end++
        if (end < pattern.length && pattern[end] === "]") end++
        while (end < pattern.length && pattern[end] !== "]") {
          if (pattern[end] === "\\") end++
          end++
        }
        const charClass = pattern.substring(i, end + 1)
        const negated = charClass[1] === "^"
        tokens.push({ token: charClass, explanation: `${negated ? "Not matching" : "Match"} any character in the set` })
        i = end + 1
      } else if (char === "(") {
        if (pattern[i + 1] === "?" && pattern[i + 2] === ":") {
          tokens.push({ token: "(?:", explanation: "Non-capturing group" }); i += 3
        } else if (pattern[i + 1] === "?" && pattern[i + 2] === "=") {
          tokens.push({ token: "(?=", explanation: "Positive lookahead" }); i += 3
        } else if (pattern[i + 1] === "?" && pattern[i + 2] === "!") {
          tokens.push({ token: "(?!", explanation: "Negative lookahead" }); i += 3
        } else if (pattern[i + 1] === "?" && pattern[i + 2] === "<" && pattern[i + 3] === "=") {
          tokens.push({ token: "(?<=", explanation: "Positive lookbehind" }); i += 4
        } else if (pattern[i + 1] === "?" && pattern[i + 2] === "<" && pattern[i + 3] === "!") {
          tokens.push({ token: "(?<!", explanation: "Negative lookbehind" }); i += 4
        } else {
          tokens.push({ token: "(", explanation: "Capturing group" }); i++
        }
      } else if (char === ")") {
        tokens.push({ token: ")", explanation: "End of group" }); i++
      } else if (char === "{") {
        const end = pattern.indexOf("}", i)
        if (end !== -1) {
          const q = pattern.substring(i, end + 1)
          const inner = q.slice(1, -1)
          const parts = inner.split(",")
          let desc
          if (parts.length === 1) desc = `Exactly ${parts[0]} times`
          else if (!parts[1]) desc = `${parts[0]} or more times`
          else desc = `Between ${parts[0]} and ${parts[1]} times`
          tokens.push({ token: q, explanation: desc })
          i = end + 1
        } else {
          tokens.push({ token: "{", explanation: "Literal '{'" }); i++
        }
      } else if (char === "*") {
        if (pattern[i + 1] === "?") { tokens.push({ token: "*?", explanation: "Zero or more (lazy)" }); i += 2 }
        else { tokens.push({ token: "*", explanation: "Zero or more (greedy)" }); i++ }
      } else if (char === "+") {
        if (pattern[i + 1] === "?") { tokens.push({ token: "+?", explanation: "One or more (lazy)" }); i += 2 }
        else { tokens.push({ token: "+", explanation: "One or more (greedy)" }); i++ }
      } else if (char === "?") {
        tokens.push({ token: "?", explanation: "Optional (zero or one)" }); i++
      } else if (char === "|") {
        tokens.push({ token: "|", explanation: "OR \u2014 match either side" }); i++
      } else if (this.constructor.TOKEN_EXPLANATIONS[char]) {
        tokens.push({ token: char, explanation: this.constructor.TOKEN_EXPLANATIONS[char] }); i++
      } else {
        tokens.push({ token: char, explanation: `Literal '${char}'` }); i++
      }
    }
    return tokens
  }

  clearResults() {
    this.outputTarget.value = ""
    this.resultTokenCountTarget.textContent = "\u2014"
    this.resultHasGroupsTarget.textContent = "\u2014"
    this.resultHasQuantifiersTarget.textContent = "\u2014"
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
