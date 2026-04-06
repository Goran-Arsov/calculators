import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputMac",
    "resultError", "resultsContainer",
    "resultMac", "resultOui", "resultManufacturer",
    "resultUnicastMulticast", "resultGlobalLocal"
  ]

  static OUI_DATABASE = {
    "00:00:0C": "Cisco", "00:01:42": "Cisco", "FC:FB:FB": "Cisco",
    "00:1A:A0": "Dell", "00:14:22": "Dell",
    "00:50:56": "VMware", "00:0C:29": "VMware", "00:05:69": "VMware", "FE:FF:FF": "VMware (legacy)",
    "00:1C:42": "Parallels",
    "08:00:27": "Oracle VirtualBox",
    "00:03:FF": "Microsoft Hyper-V", "00:15:5D": "Microsoft Hyper-V",
    "AC:DE:48": "Apple", "A4:83:E7": "Apple", "F0:18:98": "Apple",
    "3C:22:FB": "Apple", "00:1B:63": "Apple", "00:25:00": "Apple",
    "00:26:BB": "Apple", "68:5B:35": "Apple", "A8:86:DD": "Apple",
    "7C:D1:C3": "Apple", "00:0D:93": "Apple", "00:23:12": "Apple", "00:25:BC": "Apple",
    "DC:A6:32": "Raspberry Pi", "B8:27:EB": "Raspberry Pi", "E4:5F:01": "Raspberry Pi",
    "00:1A:7D": "Cyber-i Networks",
    "3C:D0:F8": "Google", "F4:F5:E8": "Google", "94:EB:2C": "Google",
    "54:60:09": "Google", "A4:77:33": "Google",
    "B0:BE:76": "TP-Link", "50:C7:BF": "TP-Link", "EC:08:6B": "TP-Link",
    "30:B5:C2": "TP-Link", "14:CC:20": "TP-Link",
    "00:1E:58": "D-Link", "1C:7E:E5": "D-Link", "28:10:7B": "D-Link", "C0:A0:BB": "D-Link",
    "E0:46:9A": "Netgear", "A4:2B:8C": "Netgear", "6C:B0:CE": "Netgear", "30:46:9A": "Netgear",
    "00:24:D7": "Intel", "00:1B:21": "Intel", "3C:97:0E": "Intel",
    "68:05:CA": "Intel", "A0:36:9F": "Intel",
    "00:1A:2B": "Hewlett-Packard", "3C:D9:2B": "Hewlett-Packard", "00:21:5A": "Hewlett-Packard",
    "00:50:B6": "Belkin", "94:10:3E": "Belkin",
    "E8:4E:06": "Samsung", "8C:77:12": "Samsung", "00:26:37": "Samsung",
    "C4:73:1E": "Samsung", "FC:F1:36": "Samsung",
    "E8:6F:38": "Xiaomi", "28:6C:07": "Xiaomi", "64:B4:73": "Xiaomi",
    "00:E0:4C": "Realtek",
    "52:54:00": "QEMU/KVM",
    "02:42:AC": "Docker", "02:42:00": "Docker",
    "00:16:3E": "Xen"
  }

  lookup() {
    const raw = this.inputMacTarget.value.trim()

    if (!raw) {
      this.clearResults()
      return
    }

    const hex = raw.replace(/[:\-.]/g, "").toUpperCase()

    if (!/^[0-9A-F]{12}$/.test(hex)) {
      this.showError("Enter a valid MAC address (e.g. AA:BB:CC:DD:EE:FF, AA-BB-CC-DD-EE-FF, or AABBCCDDEEFF)")
      this.hideResults()
      return
    }

    this.hideError()
    this.showResults()

    const normalized = hex.match(/.{2}/g).join(":")
    const ouiPrefix = normalized.substring(0, 8)
    const firstByte = parseInt(hex.substring(0, 2), 16)

    const isMulticast = (firstByte & 0x01) === 1
    const isLocal = (firstByte & 0x02) === 2

    const manufacturer = this.constructor.OUI_DATABASE[ouiPrefix] || "Unknown"

    this.resultMacTarget.textContent = normalized
    this.resultOuiTarget.textContent = ouiPrefix

    this.resultManufacturerTarget.textContent = manufacturer
    if (manufacturer === "Unknown") {
      this.resultManufacturerTarget.className = "text-sm font-medium text-gray-500 dark:text-gray-400 italic"
    } else {
      this.resultManufacturerTarget.className = "text-sm font-bold text-blue-600 dark:text-blue-400"
    }

    this.resultUnicastMulticastTarget.textContent = isMulticast ? "Multicast" : "Unicast"
    this.resultUnicastMulticastTarget.className = isMulticast
      ? "px-3 py-1 text-xs font-semibold rounded-full bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
      : "px-3 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"

    this.resultGlobalLocalTarget.textContent = isLocal ? "Locally Administered" : "Globally Unique"
    this.resultGlobalLocalTarget.className = isLocal
      ? "px-3 py-1 text-xs font-semibold rounded-full bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"
      : "px-3 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
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
      `MAC Address: ${this.resultMacTarget.textContent}`,
      `OUI Prefix: ${this.resultOuiTarget.textContent}`,
      `Manufacturer: ${this.resultManufacturerTarget.textContent}`,
      `Type: ${this.resultUnicastMulticastTarget.textContent}`,
      `Administration: ${this.resultGlobalLocalTarget.textContent}`
    ]
    navigator.clipboard.writeText(parts.join("\n"))
  }
}
