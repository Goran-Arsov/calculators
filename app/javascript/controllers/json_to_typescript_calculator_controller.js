import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "rootName", "output",
    "resultInterfaceCount", "resultRootType"
  ]

  convert() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    try {
      const parsed = JSON.parse(text)
      const rootName = (this.rootNameTarget.value || "Root").trim() || "Root"
      this.interfaces = []
      this.generateInterface(rootName, parsed)

      const output = this.interfaces.reverse().map(i => i.code).join("\n\n")
      this.outputTarget.value = output
      this.resultInterfaceCountTarget.textContent = this.interfaces.length
      this.resultRootTypeTarget.textContent = Array.isArray(parsed) ? "Array" : "Object"
    } catch (e) {
      this.outputTarget.value = "Error: " + e.message
      this.resultInterfaceCountTarget.textContent = "\u2014"
      this.resultRootTypeTarget.textContent = "\u2014"
    }
  }

  generateInterface(name, value) {
    if (Array.isArray(value)) {
      if (value.length === 0) return "any[]"
      const elemType = this.inferType(this.singularize(name), value[0])
      return `${elemType}[]`
    }

    if (value && typeof value === "object") {
      const pName = this.pascalize(name)
      const lines = [`interface ${pName} {`]
      for (const [key, val] of Object.entries(value)) {
        const tsType = this.inferType(key, val)
        const safeKey = /^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(key) ? key : `"${key}"`
        lines.push(`  ${safeKey}: ${tsType};`)
      }
      lines.push("}")
      this.interfaces.push({ name: pName, code: lines.join("\n") })
      return pName
    }

    return this.inferPrimitive(value)
  }

  inferType(key, value) {
    if (Array.isArray(value)) {
      if (value.length === 0) return "any[]"
      if (value[0] && typeof value[0] === "object" && !Array.isArray(value[0])) {
        const elemName = this.singularize(key)
        this.generateInterface(elemName, value[0])
        return `${this.pascalize(elemName)}[]`
      }
      return `${this.inferPrimitive(value[0])}[]`
    }
    if (value && typeof value === "object") {
      return this.generateInterface(key, value)
    }
    return this.inferPrimitive(value)
  }

  inferPrimitive(value) {
    if (value === null || value === undefined) return "null"
    if (typeof value === "string") return "string"
    if (typeof value === "number") return "number"
    if (typeof value === "boolean") return "boolean"
    return "any"
  }

  pascalize(str) {
    return str.replace(/[-_\s]+/g, "_").split("_").map(s => s.charAt(0).toUpperCase() + s.slice(1)).join("")
  }

  singularize(str) {
    if (str.endsWith("ies")) return str.slice(0, -3) + "y"
    if (str.endsWith("ses")) return str.slice(0, -2)
    if (str.endsWith("s") && !str.endsWith("ss")) return str.slice(0, -1)
    return str
  }

  clearResults() {
    this.outputTarget.value = ""
    this.resultInterfaceCountTarget.textContent = "\u2014"
    this.resultRootTypeTarget.textContent = "\u2014"
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
