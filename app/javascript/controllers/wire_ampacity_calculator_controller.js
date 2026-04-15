import { Controller } from "@hotwired/stimulus"

const AMPACITY_CU = {
  "14":  { 60: 15,  75: 20,  90: 25 },
  "12":  { 60: 20,  75: 25,  90: 30 },
  "10":  { 60: 30,  75: 35,  90: 40 },
  "8":   { 60: 40,  75: 50,  90: 55 },
  "6":   { 60: 55,  75: 65,  90: 75 },
  "4":   { 60: 70,  75: 85,  90: 95 },
  "3":   { 60: 85,  75: 100, 90: 115 },
  "2":   { 60: 95,  75: 115, 90: 130 },
  "1":   { 60: 110, 75: 130, 90: 145 },
  "1/0": { 60: 125, 75: 150, 90: 170 },
  "2/0": { 60: 145, 75: 175, 90: 195 },
  "3/0": { 60: 165, 75: 200, 90: 225 },
  "4/0": { 60: 195, 75: 230, 90: 260 },
  "250": { 60: 215, 75: 255, 90: 290 },
  "350": { 60: 260, 75: 310, 90: 350 },
  "500": { 60: 320, 75: 380, 90: 430 }
}

const AMPACITY_AL = {
  "12":  { 60: 15,  75: 20,  90: 25 },
  "10":  { 60: 25,  75: 30,  90: 35 },
  "8":   { 60: 35,  75: 40,  90: 45 },
  "6":   { 60: 40,  75: 50,  90: 55 },
  "4":   { 60: 55,  75: 65,  90: 75 },
  "3":   { 60: 65,  75: 75,  90: 85 },
  "2":   { 60: 75,  75: 90,  90: 100 },
  "1":   { 60: 85,  75: 100, 90: 115 },
  "1/0": { 60: 100, 75: 120, 90: 135 },
  "2/0": { 60: 115, 75: 135, 90: 150 },
  "3/0": { 60: 130, 75: 155, 90: 175 },
  "4/0": { 60: 150, 75: 180, 90: 205 },
  "250": { 60: 170, 75: 205, 90: 230 },
  "350": { 60: 210, 75: 250, 90: 280 },
  "500": { 60: 260, 75: 310, 90: 350 }
}

const AMBIENT_CORRECTION = [
  [10, { 60: 1.29, 75: 1.20, 90: 1.15 }],
  [15, { 60: 1.22, 75: 1.15, 90: 1.12 }],
  [20, { 60: 1.15, 75: 1.11, 90: 1.08 }],
  [25, { 60: 1.08, 75: 1.05, 90: 1.04 }],
  [30, { 60: 1.00, 75: 1.00, 90: 1.00 }],
  [35, { 60: 0.91, 75: 0.94, 90: 0.96 }],
  [40, { 60: 0.82, 75: 0.88, 90: 0.91 }],
  [45, { 60: 0.71, 75: 0.82, 90: 0.87 }],
  [50, { 60: 0.58, 75: 0.75, 90: 0.82 }],
  [55, { 60: 0.41, 75: 0.67, 90: 0.76 }],
  [60, { 60: 0.00, 75: 0.58, 90: 0.71 }]
]

function bundleFactor(n) {
  if (n <= 3) return 1.0
  if (n <= 6) return 0.80
  if (n <= 9) return 0.70
  if (n <= 20) return 0.50
  if (n <= 30) return 0.45
  if (n <= 40) return 0.40
  return 0.35
}

const cToF = (c) => c * 9 / 5 + 32
const fToC = (f) => (f - 32) * 5 / 9

export default class extends Controller {
  static targets = [
    "awg", "material", "tempRating", "ambient", "count",
    "unitSystem", "ambientLabel",
    "resultBase", "resultAmbientFactor", "resultBundleFactor", "resultAdjusted"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const t = parseFloat(this.ambientTarget.value)
    if (Number.isFinite(t)) this.ambientTarget.value = (toMetric ? t : cToF(t)).toFixed(1)
    if (Number.isFinite(t) && this.unitSystemTarget.value === "imperial") {
      this.ambientTarget.value = cToF(t).toFixed(1)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.ambientLabelTarget.textContent = metric ? "Ambient temperature (°C)" : "Ambient temperature (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const awg = this.awgTarget.value
    const material = this.materialTarget.value
    const rating = parseInt(this.tempRatingTarget.value, 10)
    const ambientInput = parseFloat(this.ambientTarget.value)
    const count = parseInt(this.countTarget.value, 10) || 3

    const table = material === "al" ? AMPACITY_AL : AMPACITY_CU
    if (!table[awg] || ![60, 75, 90].includes(rating) || !Number.isFinite(ambientInput)) {
      this.clear()
      return
    }

    const ambientC = metric ? ambientInput : fToC(ambientInput)
    const base = table[awg][rating]

    let ambientFactor = 0.5
    for (const [upper, factors] of AMBIENT_CORRECTION) {
      if (ambientC <= upper) { ambientFactor = factors[rating]; break }
    }

    const bundle = bundleFactor(count)
    const adjusted = base * ambientFactor * bundle

    this.resultBaseTarget.textContent = `${base} A`
    this.resultAmbientFactorTarget.textContent = `×${ambientFactor.toFixed(3)}`
    this.resultBundleFactorTarget.textContent = `×${bundle.toFixed(3)}`
    this.resultAdjustedTarget.textContent = `${adjusted.toFixed(1)} A`
  }

  clear() {
    ["Base","AmbientFactor","BundleFactor","Adjusted"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Wire ampacity:",
      `Base ampacity (Table 310.16): ${this.resultBaseTarget.textContent}`,
      `Ambient correction: ${this.resultAmbientFactorTarget.textContent}`,
      `Bundle adjustment: ${this.resultBundleFactorTarget.textContent}`,
      `Adjusted ampacity: ${this.resultAdjustedTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
