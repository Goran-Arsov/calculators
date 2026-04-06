import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputDomain", "inputRecordType",
    "resultError", "resultsContainer", "resultsBody", "resultDomain", "resultType",
    "loading"
  ]

  lookup() {
    const domain = this.inputDomainTarget.value.trim()
    const recordType = this.inputRecordTypeTarget.value

    if (!domain) {
      this.clearResults()
      return
    }

    if (!this.isValidDomain(domain)) {
      this.showError("Enter a valid domain name (e.g. example.com)")
      this.hideResults()
      return
    }

    this.hideError()
    this.showLoading()

    fetch(`https://dns.google/resolve?name=${encodeURIComponent(domain)}&type=${recordType}`)
      .then(response => {
        if (!response.ok) throw new Error("DNS query failed")
        return response.json()
      })
      .then(data => {
        this.hideLoading()
        this.displayResults(domain, recordType, data)
      })
      .catch(() => {
        this.hideLoading()
        this.showError("DNS lookup failed. Please check the domain and try again.")
        this.hideResults()
      })
  }

  displayResults(domain, recordType, data) {
    this.resultDomainTarget.textContent = domain
    this.resultTypeTarget.textContent = recordType

    const tbody = this.resultsBodyTarget
    tbody.innerHTML = ""

    // Handle DNS response status codes
    if (data.Status !== 0) {
      const statusMessages = {
        1: "Format Error - The server was unable to interpret the query.",
        2: "Server Failure - The server encountered an internal error.",
        3: "NXDOMAIN - The domain name does not exist.",
        5: "Refused - The server refused to answer the query."
      }
      const message = statusMessages[data.Status] || `DNS error (status code: ${data.Status})`
      this.showError(message)
      this.hideResults()
      return
    }

    if (!data.Answer || data.Answer.length === 0) {
      this.showError(`No ${recordType} records found for ${domain}`)
      this.hideResults()
      return
    }

    this.hideError()
    this.showResults()

    data.Answer.forEach(record => {
      const tr = document.createElement("tr")
      tr.className = "border-b border-gray-100 dark:border-gray-700 last:border-0"

      const typeName = this.recordTypeName(record.type)
      const formattedData = this.formatRecordData(record.data, typeName)
      const ttlFormatted = this.formatTTL(record.TTL)

      tr.innerHTML = `
        <td class="px-4 py-2.5 text-sm font-mono text-gray-900 dark:text-white">${record.name}</td>
        <td class="px-4 py-2.5 text-sm text-center">
          <span class="px-2 py-0.5 text-xs font-semibold rounded bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300">${typeName}</span>
        </td>
        <td class="px-4 py-2.5 text-sm font-mono text-gray-600 dark:text-gray-400" title="${record.TTL} seconds">${ttlFormatted}</td>
        <td class="px-4 py-2.5 text-sm font-mono text-gray-900 dark:text-white break-all">${this.escapeHtml(formattedData)}</td>
      `
      tbody.appendChild(tr)
    })
  }

  recordTypeName(typeCode) {
    const types = {
      1: "A", 2: "NS", 5: "CNAME", 6: "SOA", 15: "MX",
      16: "TXT", 28: "AAAA", 33: "SRV", 257: "CAA"
    }
    return types[typeCode] || String(typeCode)
  }

  formatRecordData(data, typeName) {
    if (typeName === "TXT" && data.startsWith('"') && data.endsWith('"')) {
      return data.slice(1, -1)
    }
    return data
  }

  formatTTL(seconds) {
    if (seconds < 60) return `${seconds}s`
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ${seconds % 60}s`
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    return `${hours}h ${minutes}m`
  }

  isValidDomain(domain) {
    return /^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$/.test(domain)
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
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

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
    this.hideResults()
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden")
  }

  clearResults() {
    this.hideError()
    this.hideResults()
    this.hideLoading()
  }

  copy() {
    const rows = this.resultsBodyTarget.querySelectorAll("tr")
    const lines = Array.from(rows).map(row => {
      const cells = row.querySelectorAll("td")
      return Array.from(cells).map(c => c.textContent.trim()).join("\t")
    })
    const header = "Name\tType\tTTL\tData"
    navigator.clipboard.writeText([header, ...lines].join("\n"))
  }
}
