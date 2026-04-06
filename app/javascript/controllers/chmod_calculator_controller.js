import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "ownerRead", "ownerWrite", "ownerExecute",
    "groupRead", "groupWrite", "groupExecute",
    "otherRead", "otherWrite", "otherExecute",
    "numericInput", "symbolicOutput",
    "resultNumeric", "resultSymbolic", "resultCommonName",
    "ownerSummary", "groupSummary", "otherSummary"
  ]

  static COMMON_PERMISSIONS = {
    "777": "Full access for everyone",
    "755": "Standard directory / executable",
    "750": "Owner full, group read/execute",
    "700": "Owner full access only",
    "666": "Read/write for everyone",
    "664": "Owner/group read-write, other read",
    "644": "Standard file (owner write, all read)",
    "640": "Owner read-write, group read",
    "600": "Owner read-write only",
    "555": "Read/execute for everyone",
    "544": "Owner read/execute, others read",
    "500": "Owner read/execute only",
    "444": "Read-only for everyone",
    "400": "Owner read only",
    "000": "No permissions"
  }

  connect() {
    this.updateFromCheckboxes()
  }

  toggleFromCheckbox() {
    this.updateFromCheckboxes()
  }

  updateFromCheckboxes() {
    const owner = this.digitFromChecks(this.ownerReadTarget.checked, this.ownerWriteTarget.checked, this.ownerExecuteTarget.checked)
    const group = this.digitFromChecks(this.groupReadTarget.checked, this.groupWriteTarget.checked, this.groupExecuteTarget.checked)
    const other = this.digitFromChecks(this.otherReadTarget.checked, this.otherWriteTarget.checked, this.otherExecuteTarget.checked)

    const numeric = `${owner}${group}${other}`
    const symbolic = this.toSymbolic(owner, group, other)

    this.numericInputTarget.value = numeric
    this.displayResults(numeric, symbolic, owner, group, other)
  }

  updateFromNumeric() {
    const val = this.numericInputTarget.value.trim()
    if (!/^[0-7]{3}$/.test(val)) {
      this.resultCommonNameTarget.textContent = "Enter a valid 3-digit octal (e.g. 755)"
      return
    }

    const digits = val.split("").map(Number)
    const owner = digits[0]
    const group = digits[1]
    const other = digits[2]

    this.ownerReadTarget.checked = (owner & 4) !== 0
    this.ownerWriteTarget.checked = (owner & 2) !== 0
    this.ownerExecuteTarget.checked = (owner & 1) !== 0
    this.groupReadTarget.checked = (group & 4) !== 0
    this.groupWriteTarget.checked = (group & 2) !== 0
    this.groupExecuteTarget.checked = (group & 1) !== 0
    this.otherReadTarget.checked = (other & 4) !== 0
    this.otherWriteTarget.checked = (other & 2) !== 0
    this.otherExecuteTarget.checked = (other & 1) !== 0

    const symbolic = this.toSymbolic(owner, group, other)
    this.displayResults(val, symbolic, owner, group, other)
  }

  displayResults(numeric, symbolic, owner, group, other) {
    this.resultNumericTarget.textContent = numeric
    this.resultSymbolicTarget.textContent = symbolic
    this.symbolicOutputTarget.textContent = symbolic

    const commonName = this.constructor.COMMON_PERMISSIONS[numeric]
    this.resultCommonNameTarget.textContent = commonName || "Custom permission"

    this.ownerSummaryTarget.textContent = this.summarize(owner)
    this.groupSummaryTarget.textContent = this.summarize(group)
    this.otherSummaryTarget.textContent = this.summarize(other)
  }

  digitFromChecks(r, w, x) {
    return (r ? 4 : 0) + (w ? 2 : 0) + (x ? 1 : 0)
  }

  toSymbolic(owner, group, other) {
    return this.digitToRwx(owner) + this.digitToRwx(group) + this.digitToRwx(other)
  }

  digitToRwx(d) {
    const r = (d & 4) ? "r" : "-"
    const w = (d & 2) ? "w" : "-"
    const x = (d & 1) ? "x" : "-"
    return r + w + x
  }

  summarize(digit) {
    const parts = []
    if (digit & 4) parts.push("Read")
    if (digit & 2) parts.push("Write")
    if (digit & 1) parts.push("Execute")
    return parts.length > 0 ? parts.join(", ") : "None"
  }

  copyNumeric() {
    const text = this.resultNumericTarget.textContent
    if (!text || text === "--") return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copyNumeric']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }

  copySymbolic() {
    const text = this.resultSymbolicTarget.textContent
    if (!text || text === "--") return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copySymbolic']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }

  copy() {
    const numeric = this.resultNumericTarget.textContent
    const symbolic = this.resultSymbolicTarget.textContent
    const common = this.resultCommonNameTarget.textContent
    const text = `chmod ${numeric} (${symbolic})\n${common}\nOwner: ${this.ownerSummaryTarget.textContent}\nGroup: ${this.groupSummaryTarget.textContent}\nOther: ${this.otherSummaryTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
