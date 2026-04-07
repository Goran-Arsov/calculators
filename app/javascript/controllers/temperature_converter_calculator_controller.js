import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["celsius", "fahrenheit", "kelvin", "formula"]

  convertFromCelsius() {
    const c = parseFloat(this.celsiusTarget.value)
    if (isNaN(c)) { this.clearAll(); return }

    const f = c * 9 / 5 + 32
    const k = c + 273.15

    this.fahrenheitTarget.value = this.fmt(f)
    this.kelvinTarget.value = this.fmt(k)
    this.showFormula("celsius", c, f, k)
  }

  convertFromFahrenheit() {
    const f = parseFloat(this.fahrenheitTarget.value)
    if (isNaN(f)) { this.clearAll(); return }

    const c = (f - 32) * 5 / 9
    const k = c + 273.15

    this.celsiusTarget.value = this.fmt(c)
    this.kelvinTarget.value = this.fmt(k)
    this.showFormula("fahrenheit", c, f, k)
  }

  convertFromKelvin() {
    const k = parseFloat(this.kelvinTarget.value)
    if (isNaN(k)) { this.clearAll(); return }

    const c = k - 273.15
    const f = c * 9 / 5 + 32

    this.celsiusTarget.value = this.fmt(c)
    this.fahrenheitTarget.value = this.fmt(f)
    this.showFormula("kelvin", c, f, k)
  }

  showFormula(source, c, f, k) {
    if (!this.hasFormulaTarget) return
    let lines = []
    if (source === "celsius") {
      lines.push(`${this.fmt(c)} °C × 9/5 + 32 = ${this.fmt(f)} °F`)
      lines.push(`${this.fmt(c)} °C + 273.15 = ${this.fmt(k)} K`)
    } else if (source === "fahrenheit") {
      lines.push(`(${this.fmt(f)} °F − 32) × 5/9 = ${this.fmt(c)} °C`)
      lines.push(`${this.fmt(c)} °C + 273.15 = ${this.fmt(k)} K`)
    } else {
      lines.push(`${this.fmt(k)} K − 273.15 = ${this.fmt(c)} °C`)
      lines.push(`${this.fmt(c)} °C × 9/5 + 32 = ${this.fmt(f)} °F`)
    }
    this.formulaTarget.innerHTML = lines.join("<br>")
  }

  clearAll() {
    if (this.hasFormulaTarget) this.formulaTarget.innerHTML = ""
  }

  fmt(n) {
    return parseFloat(n.toFixed(4))
  }

  copy() {
    const c = this.celsiusTarget.value
    const f = this.fahrenheitTarget.value
    const k = this.kelvinTarget.value
    if (!c && !f && !k) return
    const text = `Celsius: ${c} °C\nFahrenheit: ${f} °F\nKelvin: ${k} K`
    navigator.clipboard.writeText(text)
  }
}
