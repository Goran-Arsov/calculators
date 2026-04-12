import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["operationType", "operationName", "typeName", "fields", "arguments", "output", "error"]

  connect() {
    this.argCount = 0
  }

  generate() {
    const opType = this.operationTypeTarget.value
    const opName = this.operationNameTarget.value.trim()
    const typeName = this.typeNameTarget.value.trim()
    const fieldsRaw = this.fieldsTarget.value.trim()

    if (!typeName) { this.showError("Type name is required."); return }
    if (!fieldsRaw) { this.showError("At least one field is required."); return }
    this.hideError()

    const fields = fieldsRaw.split(/[,\n]/).map(f => f.trim()).filter(f => f)
    const args = this.parseArguments()

    const lines = []
    let opLine = opType
    if (opName) opLine += ` ${opName}`
    lines.push(`${opLine} {`)

    if (args.length > 0) {
      const argsStr = args.map(a => `${a.name}: ${this.formatArgValue(a.value, a.type)}`).join(", ")
      lines.push(`  ${typeName}(${argsStr}) {`)
    } else {
      lines.push(`  ${typeName} {`)
    }

    fields.forEach(f => lines.push(`    ${f}`))
    lines.push("  }")
    lines.push("}")

    this.outputTarget.value = lines.join("\n")
  }

  parseArguments() {
    const text = this.argumentsTarget.value.trim()
    if (!text) return []

    return text.split("\n").map(line => {
      const parts = line.split(":").map(p => p.trim())
      if (parts.length < 2) return null
      return { name: parts[0], value: parts.slice(1).join(":").trim(), type: "string" }
    }).filter(a => a && a.name)
  }

  formatArgValue(value, type) {
    if (/^-?\d+$/.test(value)) return value
    if (/^-?\d+\.\d+$/.test(value)) return value
    if (value === "true" || value === "false") return value
    if (value === "null") return value
    if (value.startsWith("[") || value.startsWith("{")) return value
    return `"${value}"`
  }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  copy() {
    const text = this.outputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) { const o = btn.textContent; btn.textContent = "Copied!"; setTimeout(() => { btn.textContent = o }, 1500) }
    })
  }

  clear() {
    this.operationNameTarget.value = ""
    this.typeNameTarget.value = ""
    this.fieldsTarget.value = ""
    this.argumentsTarget.value = ""
    this.outputTarget.value = ""
    this.hideError()
  }
}
