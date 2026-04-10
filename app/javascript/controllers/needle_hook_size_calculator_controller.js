import { Controller } from "@hotwired/stimulus"

const KNITTING_NEEDLES = [
  { metric_mm: 2.0,  us: "0",    uk: "14" },
  { metric_mm: 2.25, us: "1",    uk: "13" },
  { metric_mm: 2.75, us: "2",    uk: "12" },
  { metric_mm: 3.0,  us: "—",    uk: "11" },
  { metric_mm: 3.25, us: "3",    uk: "10" },
  { metric_mm: 3.5,  us: "4",    uk: "—" },
  { metric_mm: 3.75, us: "5",    uk: "9" },
  { metric_mm: 4.0,  us: "6",    uk: "8" },
  { metric_mm: 4.5,  us: "7",    uk: "7" },
  { metric_mm: 5.0,  us: "8",    uk: "6" },
  { metric_mm: 5.5,  us: "9",    uk: "5" },
  { metric_mm: 6.0,  us: "10",   uk: "4" },
  { metric_mm: 6.5,  us: "10.5", uk: "3" },
  { metric_mm: 7.0,  us: "—",    uk: "2" },
  { metric_mm: 7.5,  us: "—",    uk: "1" },
  { metric_mm: 8.0,  us: "11",   uk: "0" },
  { metric_mm: 9.0,  us: "13",   uk: "00" },
  { metric_mm: 10.0, us: "15",   uk: "000" },
  { metric_mm: 12.0, us: "17",   uk: "—" },
  { metric_mm: 15.0, us: "19",   uk: "—" },
  { metric_mm: 20.0, us: "36",   uk: "—" }
]

const CROCHET_HOOKS = [
  { metric_mm: 2.25, us: "B-1" },
  { metric_mm: 2.75, us: "C-2" },
  { metric_mm: 3.25, us: "D-3" },
  { metric_mm: 3.5,  us: "E-4" },
  { metric_mm: 3.75, us: "F-5" },
  { metric_mm: 4.0,  us: "G-6" },
  { metric_mm: 4.5,  us: "7" },
  { metric_mm: 5.0,  us: "H-8" },
  { metric_mm: 5.5,  us: "I-9" },
  { metric_mm: 6.0,  us: "J-10" },
  { metric_mm: 6.5,  us: "K-10.5" },
  { metric_mm: 8.0,  us: "L-11" },
  { metric_mm: 9.0,  us: "M/N-13" },
  { metric_mm: 10.0, us: "N/P-15" },
  { metric_mm: 11.5, us: "P-16" },
  { metric_mm: 15.0, us: "P/Q" },
  { metric_mm: 16.0, us: "Q" },
  { metric_mm: 19.0, us: "S" }
]

export default class extends Controller {
  static targets = [
    "type", "metricMm",
    "resultMetric", "resultUs", "resultUk", "resultExactMatch"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const mm = parseFloat(this.metricMmTarget.value) || 0
    if (mm <= 0 || mm > 30) {
      this.clearResults()
      return
    }

    const type = this.selectedType()
    const table = type === "knitting" ? KNITTING_NEEDLES : CROCHET_HOOKS
    const row = this.closest(table, mm)
    const exact = Math.abs(row.metric_mm - mm) <= 0.01

    this.resultMetricTarget.textContent = `${row.metric_mm} mm`
    this.resultUsTarget.textContent = row.us
    this.resultUkTarget.textContent = row.uk || "—"
    this.resultExactMatchTarget.textContent = exact ? "Yes" : "No"
  }

  clearResults() {
    this.resultMetricTarget.textContent = "0 mm"
    this.resultUsTarget.textContent = "—"
    this.resultUkTarget.textContent = "—"
    this.resultExactMatchTarget.textContent = "—"
  }

  selectedType() {
    const checked = this.typeTargets.find((el) => el.checked)
    return checked ? checked.value : "knitting"
  }

  closest(table, target) {
    let best = table[0]
    let bestDiff = Math.abs(best.metric_mm - target)
    for (let i = 1; i < table.length; i++) {
      const diff = Math.abs(table[i].metric_mm - target)
      if (diff < bestDiff) {
        best = table[i]
        bestDiff = diff
      }
    }
    return best
  }

  copy() {
    const text = `Needle/Hook Size:\nMetric: ${this.resultMetricTarget.textContent}\nUS: ${this.resultUsTarget.textContent}\nUK: ${this.resultUkTarget.textContent}\nExact Match: ${this.resultExactMatchTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
