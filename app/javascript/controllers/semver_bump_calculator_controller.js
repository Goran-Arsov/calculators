import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "currentVersion", "bumpType", "preRelease", "buildMeta",
    "resultVersion", "resultMajor", "resultMinor", "resultPatch", "error"
  ]

  calculate() {
    const current = this.currentVersionTarget.value.trim()
    const bumpType = this.bumpTypeTarget.value
    const preRelease = this.preReleaseTarget.value.trim()
    const buildMeta = this.buildMetaTarget.value.trim()

    if (!current) { this.showError("Enter a current version."); return }

    const clean = current.replace(/^v/i, "")
    const match = clean.match(/^(\d+)\.(\d+)\.(\d+)/)
    if (!match) { this.showError("Version must be in major.minor.patch format (e.g., 1.2.3)."); return }
    this.hideError()

    let major = parseInt(match[1])
    let minor = parseInt(match[2])
    let patch = parseInt(match[3])

    switch (bumpType) {
      case "major": major++; minor = 0; patch = 0; break
      case "minor": minor++; patch = 0; break
      case "patch": patch++; break
    }

    let version = `${major}.${minor}.${patch}`
    if (preRelease) version += `-${preRelease}`
    if (buildMeta) version += `+${buildMeta}`

    this.resultVersionTarget.textContent = version
    this.resultMajorTarget.textContent = major
    this.resultMinorTarget.textContent = minor
    this.resultPatchTarget.textContent = patch
  }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  copy() {
    const text = this.resultVersionTarget.textContent
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) { const o = btn.textContent; btn.textContent = "Copied!"; setTimeout(() => { btn.textContent = o }, 1500) }
    })
  }
}
