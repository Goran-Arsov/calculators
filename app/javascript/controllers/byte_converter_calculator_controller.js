import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "value", "unit",
    "resultB", "resultKiB", "resultMiB", "resultGiB", "resultTiB", "resultPiB",
    "resultDecB", "resultDecKB", "resultDecMB", "resultDecGB", "resultDecTB", "resultDecPB"
  ]

  static binaryFactors = {
    B: 1,
    KiB: 1024,
    MiB: Math.pow(1024, 2),
    GiB: Math.pow(1024, 3),
    TiB: Math.pow(1024, 4),
    PiB: Math.pow(1024, 5)
  }

  static decimalFactors = {
    B: 1,
    KB: 1000,
    MB: Math.pow(1000, 2),
    GB: Math.pow(1000, 3),
    TB: Math.pow(1000, 4),
    PB: Math.pow(1000, 5)
  }

  // Input units use binary (1024) interpretation
  static inputFactors = {
    B: 1,
    KB: 1024,
    MB: Math.pow(1024, 2),
    GB: Math.pow(1024, 3),
    TB: Math.pow(1024, 4),
    PB: Math.pow(1024, 5)
  }

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const unit = this.unitTarget.value
    if (isNaN(val) || val < 0) { this.clearAll(); return }

    const bytes = val * this.constructor.inputFactors[unit]
    const bf = this.constructor.binaryFactors
    const df = this.constructor.decimalFactors

    // Binary column
    this.resultBTarget.textContent = this.fmt(bytes / bf.B)
    this.resultKiBTarget.textContent = this.fmt(bytes / bf.KiB)
    this.resultMiBTarget.textContent = this.fmt(bytes / bf.MiB)
    this.resultGiBTarget.textContent = this.fmt(bytes / bf.GiB)
    this.resultTiBTarget.textContent = this.fmt(bytes / bf.TiB)
    this.resultPiBTarget.textContent = this.fmt(bytes / bf.PiB)

    // Decimal column
    this.resultDecBTarget.textContent = this.fmt(bytes / df.B)
    this.resultDecKBTarget.textContent = this.fmt(bytes / df.KB)
    this.resultDecMBTarget.textContent = this.fmt(bytes / df.MB)
    this.resultDecGBTarget.textContent = this.fmt(bytes / df.GB)
    this.resultDecTBTarget.textContent = this.fmt(bytes / df.TB)
    this.resultDecPBTarget.textContent = this.fmt(bytes / df.PB)
  }

  clearAll() {
    const dash = "--"
    const targets = [
      "resultB", "resultKiB", "resultMiB", "resultGiB", "resultTiB", "resultPiB",
      "resultDecB", "resultDecKB", "resultDecMB", "resultDecGB", "resultDecTB", "resultDecPB"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = dash
      }
    })
  }

  fmt(n) {
    if (n === 0) return "0"
    if (Math.abs(n) >= 1) return parseFloat(n.toFixed(4))
    return parseFloat(n.toFixed(8))
  }

  copy() {
    const lines = [
      "Binary (1024-based):",
      `  B: ${this.resultBTarget.textContent}`,
      `  KiB: ${this.resultKiBTarget.textContent}`,
      `  MiB: ${this.resultMiBTarget.textContent}`,
      `  GiB: ${this.resultGiBTarget.textContent}`,
      `  TiB: ${this.resultTiBTarget.textContent}`,
      `  PiB: ${this.resultPiBTarget.textContent}`,
      "",
      "Decimal (1000-based):",
      `  B: ${this.resultDecBTarget.textContent}`,
      `  KB: ${this.resultDecKBTarget.textContent}`,
      `  MB: ${this.resultDecMBTarget.textContent}`,
      `  GB: ${this.resultDecGBTarget.textContent}`,
      `  TB: ${this.resultDecTBTarget.textContent}`,
      `  PB: ${this.resultDecPBTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
