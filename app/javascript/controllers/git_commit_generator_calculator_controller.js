import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "commitType", "scope", "description", "body",
    "breakingCheckbox", "breakingDescription", "issueRef",
    "output", "error", "breakingGroup"
  ]

  static typeDescriptions = {
    feat: "A new feature",
    fix: "A bug fix",
    docs: "Documentation only changes",
    style: "Changes that do not affect meaning of code",
    refactor: "Code change that neither fixes a bug nor adds a feature",
    perf: "A code change that improves performance",
    test: "Adding missing or correcting existing tests",
    build: "Changes to build system or external dependencies",
    ci: "Changes to CI configuration files and scripts",
    chore: "Other changes that do not modify src or test files",
    revert: "Reverts a previous commit"
  }

  connect() {
    this.toggleBreaking()
  }

  toggleBreaking() {
    if (this.hasBreakingGroupTarget) {
      const show = this.breakingCheckboxTarget.checked
      this.breakingGroupTarget.classList.toggle("hidden", !show)
    }
  }

  generate() {
    const type = this.commitTypeTarget.value
    const scope = this.scopeTarget.value.trim()
    const desc = this.descriptionTarget.value.trim()
    const body = this.bodyTarget.value.trim()
    const breaking = this.breakingCheckboxTarget.checked
    const breakingDesc = this.breakingDescriptionTarget.value.trim()
    const issueRef = this.issueRefTarget.value.trim()

    // Validation
    const errors = []
    if (!type) errors.push("Select a commit type")
    if (!desc) errors.push("Description is required")
    if (desc.length > 100) errors.push("Description must be under 100 characters")
    if (desc.endsWith(".")) errors.push("Description should not end with a period")
    if (/^[A-Z]/.test(desc)) errors.push("Description should start with lowercase")
    if (breaking && !breakingDesc) errors.push("Breaking change description required")

    if (errors.length > 0) {
      this.showError(errors.join(". "))
      return
    }
    this.hideError()

    // Build message
    const lines = []
    let header = type
    if (scope) header += `(${scope})`
    if (breaking) header += "!"
    header += `: ${desc}`
    lines.push(header)

    if (body) { lines.push(""); lines.push(body) }

    const footerLines = []
    if (breaking && breakingDesc) footerLines.push(`BREAKING CHANGE: ${breakingDesc}`)
    if (issueRef) {
      issueRef.split(/[,\s]+/).filter(r => r).forEach(ref => {
        if (!ref.startsWith("#")) ref = `#${ref}`
        footerLines.push(`Refs: ${ref}`)
      })
    }
    if (footerLines.length > 0) { lines.push(""); lines.push(...footerLines) }

    this.outputTarget.value = lines.join("\n")
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
    this.scopeTarget.value = ""
    this.descriptionTarget.value = ""
    this.bodyTarget.value = ""
    this.breakingCheckboxTarget.checked = false
    this.breakingDescriptionTarget.value = ""
    this.issueRefTarget.value = ""
    this.outputTarget.value = ""
    this.toggleBreaking()
    this.hideError()
  }
}
