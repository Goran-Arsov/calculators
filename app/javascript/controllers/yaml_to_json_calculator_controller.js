import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "yamlInput", "jsonInput",
    "resultStatus", "resultInputLines", "resultOutputLines", "resultDirection"
  ]

  connect() {
    this._debounceTimer = null
  }

  convertToJson() {
    const yaml = this.yamlInputTarget.value
    if (!yaml || !yaml.trim()) {
      this.clearResults()
      this.jsonInputTarget.value = ""
      return
    }

    try {
      const parsed = this.parseYaml(yaml)
      const json = JSON.stringify(parsed, null, 2)
      this.jsonInputTarget.value = json
      this.showSuccess("YAML to JSON", yaml.split("\n").length, json.split("\n").length)
    } catch (e) {
      this.showError("Invalid YAML: " + e.message)
      this.jsonInputTarget.value = ""
    }
  }

  convertToYaml() {
    const json = this.jsonInputTarget.value
    if (!json || !json.trim()) {
      this.clearResults()
      this.yamlInputTarget.value = ""
      return
    }

    try {
      const parsed = JSON.parse(json)
      const yaml = this.toYaml(parsed)
      this.yamlInputTarget.value = yaml
      this.showSuccess("JSON to YAML", json.split("\n").length, yaml.split("\n").length)
    } catch (e) {
      this.showError("Invalid JSON: " + e.message)
      this.yamlInputTarget.value = ""
    }
  }

  yamlChanged() {
    clearTimeout(this._debounceTimer)
    this._debounceTimer = setTimeout(() => this.convertToJson(), 400)
  }

  jsonChanged() {
    clearTimeout(this._debounceTimer)
    this._debounceTimer = setTimeout(() => this.convertToYaml(), 400)
  }

  swap() {
    const yamlVal = this.yamlInputTarget.value
    const jsonVal = this.jsonInputTarget.value
    this.yamlInputTarget.value = jsonVal
    this.jsonInputTarget.value = yamlVal
  }

  // --- Lightweight YAML parser ---
  parseYaml(text) {
    const lines = text.split("\n")
    // Remove document markers and blank/comment lines
    const filtered = lines.filter(l => {
      const trimmed = l.trim()
      return trimmed !== "---" && trimmed !== "..." && !trimmed.startsWith("#") && trimmed.length > 0
    })

    if (filtered.length === 0) return null

    // Check if the first non-empty line looks like a sequence item
    const firstTrimmed = filtered[0].trim()
    if (firstTrimmed.startsWith("- ") || firstTrimmed === "-") {
      return this.parseSequence(filtered, 0).value
    }

    // Check for flow syntax (JSON-like)
    if (firstTrimmed.startsWith("{") || firstTrimmed.startsWith("[")) {
      return JSON.parse(filtered.join("\n"))
    }

    return this.parseMapping(filtered, 0).value
  }

  parseMapping(lines, baseIndent) {
    const result = {}
    let i = 0

    while (i < lines.length) {
      const line = lines[i]
      const indent = line.search(/\S/)

      if (indent < baseIndent) break
      if (indent > baseIndent) break

      const trimmed = line.trim()

      // Skip comments
      if (trimmed.startsWith("#")) { i++; continue }

      const colonIndex = trimmed.indexOf(":")
      if (colonIndex === -1) { i++; continue }

      const key = trimmed.substring(0, colonIndex).trim()
      const afterColon = trimmed.substring(colonIndex + 1).trim()

      if (afterColon.length > 0 && !afterColon.startsWith("#")) {
        // Inline value
        result[key] = this.parseScalar(afterColon)
        i++
      } else {
        // Check for nested content
        const childLines = []
        let j = i + 1
        let childIndent = -1

        while (j < lines.length) {
          const childLine = lines[j]
          const ci = childLine.search(/\S/)
          if (ci <= baseIndent) break
          if (childIndent === -1) childIndent = ci
          if (ci < childIndent) break
          childLines.push(childLine)
          j++
        }

        if (childLines.length === 0) {
          result[key] = null
          i++
        } else {
          const firstChild = childLines[0].trim()
          if (firstChild.startsWith("- ") || firstChild === "-") {
            const parsed = this.parseSequence(childLines, childIndent)
            result[key] = parsed.value
          } else {
            const parsed = this.parseMapping(childLines, childIndent)
            result[key] = parsed.value
          }
          i = j
        }
      }
    }

    return { value: result, consumed: i }
  }

  parseSequence(lines, baseIndent) {
    const result = []
    let i = 0

    while (i < lines.length) {
      const line = lines[i]
      const indent = line.search(/\S/)
      const trimmed = line.trim()

      if (indent < baseIndent) break

      if (trimmed.startsWith("#")) { i++; continue }

      if (trimmed.startsWith("- ")) {
        const afterDash = trimmed.substring(2).trim()

        // Check if the item value itself contains a colon (mapping item)
        if (afterDash.includes(":") && !afterDash.startsWith('"') && !afterDash.startsWith("'")) {
          // Could be an inline mapping within a sequence item
          // First, check for nested lines
          const childLines = []
          let j = i + 1
          let childIndent = -1

          while (j < lines.length) {
            const childLine = lines[j]
            const ci = childLine.search(/\S/)
            if (ci <= indent) break
            if (childIndent === -1) childIndent = ci
            childLines.push(childLine)
            j++
          }

          if (childLines.length > 0) {
            // Multi-line mapping item: combine the inline part with children
            const inlineKey = afterDash.substring(0, afterDash.indexOf(":")).trim()
            const inlineVal = afterDash.substring(afterDash.indexOf(":") + 1).trim()
            const obj = {}
            obj[inlineKey] = inlineVal.length > 0 ? this.parseScalar(inlineVal) : null

            // Parse the rest as additional keys in same mapping
            if (childIndent === -1) childIndent = indent + 2
            const parsed = this.parseMapping(childLines, childIndent)
            Object.assign(obj, parsed.value)
            result.push(obj)
            i = j
          } else {
            // Single inline mapping: "- key: value"
            const colonIdx = afterDash.indexOf(":")
            const k = afterDash.substring(0, colonIdx).trim()
            const v = afterDash.substring(colonIdx + 1).trim()
            const obj = {}
            obj[k] = v.length > 0 ? this.parseScalar(v) : null
            result.push(obj)
            i++
          }
        } else {
          result.push(this.parseScalar(afterDash))
          i++
        }
      } else if (trimmed === "-") {
        // Dash only, value on next line(s)
        const childLines = []
        let j = i + 1
        let childIndent = -1

        while (j < lines.length) {
          const childLine = lines[j]
          const ci = childLine.search(/\S/)
          if (ci <= indent) break
          if (childIndent === -1) childIndent = ci
          childLines.push(childLine)
          j++
        }

        if (childLines.length === 0) {
          result.push(null)
          i++
        } else {
          const firstChild = childLines[0].trim()
          if (firstChild.startsWith("- ")) {
            const parsed = this.parseSequence(childLines, childIndent)
            result.push(parsed.value)
          } else {
            const parsed = this.parseMapping(childLines, childIndent)
            result.push(parsed.value)
          }
          i = j
        }
      } else {
        break
      }
    }

    return { value: result, consumed: i }
  }

  parseScalar(str) {
    if (!str || str.length === 0) return null

    // Quoted strings
    if ((str.startsWith('"') && str.endsWith('"')) || (str.startsWith("'") && str.endsWith("'"))) {
      return str.slice(1, -1)
    }

    // Flow sequences/mappings
    if (str.startsWith("[") || str.startsWith("{")) {
      try { return JSON.parse(str) } catch (_e) { return str }
    }

    // Booleans
    const lower = str.toLowerCase()
    if (lower === "true" || lower === "yes" || lower === "on") return true
    if (lower === "false" || lower === "no" || lower === "off") return false

    // Null
    if (lower === "null" || lower === "~") return null

    // Numbers
    if (/^-?\d+$/.test(str)) return parseInt(str, 10)
    if (/^-?\d*\.\d+$/.test(str)) return parseFloat(str)

    return str
  }

  // --- JSON to YAML generator ---
  toYaml(value, indent = 0) {
    const prefix = "  ".repeat(indent)

    if (value === null || value === undefined) return "null\n"
    if (typeof value === "boolean") return (value ? "true" : "false") + "\n"
    if (typeof value === "number") return String(value) + "\n"

    if (typeof value === "string") {
      if (value.includes("\n")) {
        const lines = value.split("\n")
        return "|\n" + lines.map(l => prefix + "  " + l).join("\n") + "\n"
      }
      if (/[:{}\[\],&*?|>!%#@`'"]/.test(value) || value.trim() !== value || value === "") {
        return '"' + value.replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '"\n'
      }
      // Check for values that could be misinterpreted
      const lower = value.toLowerCase()
      if (["true", "false", "yes", "no", "on", "off", "null"].includes(lower) || /^-?\d+(\.\d+)?$/.test(value)) {
        return '"' + value + '"\n'
      }
      return value + "\n"
    }

    if (Array.isArray(value)) {
      if (value.length === 0) return "[]\n"
      let result = "\n"
      for (const item of value) {
        if (item !== null && typeof item === "object" && !Array.isArray(item)) {
          const keys = Object.keys(item)
          if (keys.length > 0) {
            const firstKey = keys[0]
            const firstVal = this.toYaml(item[firstKey], indent + 1).trimEnd()
            result += prefix + "- " + firstKey + ": " + firstVal.trim() + "\n"
            for (let k = 1; k < keys.length; k++) {
              const val = this.toYaml(item[keys[k]], indent + 1).trimEnd()
              result += prefix + "  " + keys[k] + ": " + val.trim() + "\n"
            }
          } else {
            result += prefix + "- {}\n"
          }
        } else {
          result += prefix + "- " + this.toYaml(item, indent + 1).trimStart()
        }
      }
      return result
    }

    if (typeof value === "object") {
      const keys = Object.keys(value)
      if (keys.length === 0) return "{}\n"
      let result = "\n"
      for (const key of keys) {
        const val = value[key]
        if (val !== null && typeof val === "object") {
          result += prefix + key + ":" + this.toYaml(val, indent + 1)
        } else {
          result += prefix + key + ": " + this.toYaml(val, indent + 1).trim() + "\n"
        }
      }
      return result
    }

    return String(value) + "\n"
  }

  showSuccess(direction, inputLines, outputLines) {
    this.resultStatusTarget.textContent = "Valid"
    this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
    this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
    this.resultDirectionTarget.textContent = direction
    this.resultInputLinesTarget.textContent = inputLines
    this.resultOutputLinesTarget.textContent = outputLines
  }

  showError(message) {
    this.resultStatusTarget.textContent = message
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
    this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
    this.resultDirectionTarget.textContent = "\u2014"
    this.resultInputLinesTarget.textContent = "\u2014"
    this.resultOutputLinesTarget.textContent = "\u2014"
  }

  clearResults() {
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultDirectionTarget.textContent = "\u2014"
    this.resultInputLinesTarget.textContent = "\u2014"
    this.resultOutputLinesTarget.textContent = "\u2014"
  }

  copyYaml() {
    navigator.clipboard.writeText(this.yamlInputTarget.value)
  }

  copyJson() {
    navigator.clipboard.writeText(this.jsonInputTarget.value)
  }
}
