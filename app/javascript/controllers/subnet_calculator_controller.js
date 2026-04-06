import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputIp", "inputPrefix",
    "resultNetwork", "resultBroadcast", "resultSubnetMask", "resultWildcard",
    "resultFirstHost", "resultLastHost", "resultTotalHosts", "resultUsableHosts",
    "resultCidr", "resultIpClass", "resultPrivate", "resultBinaryMask",
    "resultError", "resultsContainer"
  ]

  calculate() {
    const ip = this.inputIpTarget.value.trim()
    const prefix = parseInt(this.inputPrefixTarget.value, 10)

    if (!ip) {
      this.clearResults()
      return
    }

    if (!this.isValidIp(ip)) {
      this.showError("Enter a valid IPv4 address (e.g. 192.168.1.0)")
      this.hideResults()
      return
    }

    if (isNaN(prefix) || prefix < 0 || prefix > 32) {
      this.showError("CIDR prefix must be between 0 and 32")
      this.hideResults()
      return
    }

    this.hideError()
    this.showResults()

    const ipInt = this.ipToInt(ip)
    const maskInt = this.prefixToMask(prefix)
    const wildcardInt = (~maskInt) >>> 0
    const networkInt = (ipInt & maskInt) >>> 0
    const broadcastInt = (networkInt | wildcardInt) >>> 0
    const totalHosts = Math.pow(2, 32 - prefix)
    const usableHosts = prefix >= 31 ? totalHosts : Math.max(totalHosts - 2, 0)

    this.resultNetworkTarget.textContent = this.intToIp(networkInt)
    this.resultBroadcastTarget.textContent = this.intToIp(broadcastInt)
    this.resultSubnetMaskTarget.textContent = this.intToIp(maskInt)
    this.resultWildcardTarget.textContent = this.intToIp(wildcardInt)
    this.resultFirstHostTarget.textContent = prefix >= 31
      ? this.intToIp(networkInt)
      : this.intToIp(networkInt + 1)
    this.resultLastHostTarget.textContent = prefix >= 31
      ? this.intToIp(broadcastInt)
      : this.intToIp(broadcastInt - 1)
    this.resultTotalHostsTarget.textContent = totalHosts.toLocaleString()
    this.resultUsableHostsTarget.textContent = usableHosts.toLocaleString()
    this.resultCidrTarget.textContent = `${this.intToIp(networkInt)}/${prefix}`
    this.resultIpClassTarget.textContent = this.ipClass(ip)
    this.resultPrivateTarget.textContent = this.isPrivate(ip) ? "Yes (Private)" : "No (Public)"
    this.resultBinaryMaskTarget.textContent = this.toBinaryMask(prefix)
  }

  isValidIp(ip) {
    const parts = ip.split(".")
    if (parts.length !== 4) return false
    return parts.every(p => {
      const n = parseInt(p, 10)
      return !isNaN(n) && n >= 0 && n <= 255 && p === String(n)
    })
  }

  ipToInt(ip) {
    const parts = ip.split(".").map(Number)
    return ((parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3]) >>> 0
  }

  intToIp(n) {
    return [
      (n >>> 24) & 255,
      (n >>> 16) & 255,
      (n >>> 8) & 255,
      n & 255
    ].join(".")
  }

  prefixToMask(prefix) {
    if (prefix === 0) return 0
    return (~0 << (32 - prefix)) >>> 0
  }

  ipClass(ip) {
    const first = parseInt(ip.split(".")[0], 10)
    if (first <= 127) return "A"
    if (first <= 191) return "B"
    if (first <= 223) return "C"
    if (first <= 239) return "D (Multicast)"
    return "E (Reserved)"
  }

  isPrivate(ip) {
    const parts = ip.split(".").map(Number)
    if (parts[0] === 10) return true
    if (parts[0] === 172 && parts[1] >= 16 && parts[1] <= 31) return true
    if (parts[0] === 192 && parts[1] === 168) return true
    return false
  }

  toBinaryMask(prefix) {
    const mask = "1".repeat(prefix).padEnd(32, "0")
    return `${mask.slice(0,8)}.${mask.slice(8,16)}.${mask.slice(16,24)}.${mask.slice(24,32)}`
  }

  showError(message) {
    this.resultErrorTarget.textContent = message
    this.resultErrorTarget.classList.remove("hidden")
  }

  hideError() {
    this.resultErrorTarget.textContent = ""
    this.resultErrorTarget.classList.add("hidden")
  }

  showResults() {
    this.resultsContainerTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsContainerTarget.classList.add("hidden")
  }

  clearResults() {
    this.hideError()
    this.hideResults()
  }

  copy() {
    const parts = [
      `Network: ${this.resultNetworkTarget.textContent}`,
      `Broadcast: ${this.resultBroadcastTarget.textContent}`,
      `Subnet Mask: ${this.resultSubnetMaskTarget.textContent}`,
      `Wildcard Mask: ${this.resultWildcardTarget.textContent}`,
      `First Host: ${this.resultFirstHostTarget.textContent}`,
      `Last Host: ${this.resultLastHostTarget.textContent}`,
      `Total Hosts: ${this.resultTotalHostsTarget.textContent}`,
      `Usable Hosts: ${this.resultUsableHostsTarget.textContent}`,
      `CIDR: ${this.resultCidrTarget.textContent}`,
      `Class: ${this.resultIpClassTarget.textContent}`,
      `Private: ${this.resultPrivateTarget.textContent}`
    ]
    navigator.clipboard.writeText(parts.join("\n"))
  }
}
