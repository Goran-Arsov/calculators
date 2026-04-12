import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "rateLimit", "windowSeconds", "currentUsage", "burstLimit",
    "resultRps", "resultRpm", "resultRph", "resultRpd",
    "resultRemaining", "resultUsage", "resultTimePerReq",
    "resultReset", "resultSafeRps", "resultBurst"
  ]

  calculate() {
    const rateLimit = parseInt(this.rateLimitTarget.value) || 0
    const windowSeconds = parseInt(this.windowSecondsTarget.value) || 0
    const currentUsage = parseInt(this.currentUsageTarget.value) || 0
    const burstLimit = this.hasBurstLimitTarget ? parseInt(this.burstLimitTarget.value) || 0 : 0

    if (rateLimit <= 0 || windowSeconds <= 0) return

    const rps = rateLimit / windowSeconds
    const rpm = rps * 60
    const rph = rps * 3600
    const rpd = rps * 86400

    const remaining = Math.max(rateLimit - currentUsage, 0)
    const usagePct = (currentUsage / rateLimit * 100).toFixed(1)
    const timePerReq = (windowSeconds / rateLimit * 1000).toFixed(2)
    const reset = currentUsage >= rateLimit ? windowSeconds : 0
    const safeRps = (rps * 0.8).toFixed(4)

    this.resultRpsTarget.textContent = rps.toFixed(4)
    this.resultRpmTarget.textContent = rpm.toFixed(2)
    this.resultRphTarget.textContent = rph.toFixed(2)
    this.resultRpdTarget.textContent = Math.round(rpd).toLocaleString()
    this.resultRemainingTarget.textContent = remaining.toLocaleString()
    this.resultUsageTarget.textContent = `${usagePct}%`
    this.resultTimePerReqTarget.textContent = `${timePerReq} ms`
    this.resultResetTarget.textContent = reset > 0 ? `${reset}s` : "Not needed"
    this.resultSafeRpsTarget.textContent = safeRps

    if (this.hasResultBurstTarget && burstLimit > 0) {
      this.resultBurstTarget.textContent = `${burstLimit} (${(burstLimit / rateLimit).toFixed(2)}x)`
      this.resultBurstTarget.closest("[data-burst-row]")?.classList.remove("hidden")
    }
  }

  copy() {
    const lines = [
      `Rate: ${this.resultRpsTarget.textContent} req/s`,
      `Per minute: ${this.resultRpmTarget.textContent}`,
      `Per hour: ${this.resultRphTarget.textContent}`,
      `Per day: ${this.resultRpdTarget.textContent}`,
      `Remaining: ${this.resultRemainingTarget.textContent}`,
      `Usage: ${this.resultUsageTarget.textContent}`,
      `Min interval: ${this.resultTimePerReqTarget.textContent}`,
      `Safe rate: ${this.resultSafeRpsTarget.textContent} req/s`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
