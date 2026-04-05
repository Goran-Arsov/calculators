import { Controller } from "@hotwired/stimulus"

const MATERIALS = {
  copper: 401, aluminum: 237, steel: 50.2, stainless_steel: 16.2,
  iron: 80.2, brass: 109, gold: 317, silver: 429,
  glass: 1.05, concrete: 1.7, brick: 0.72,
  wood_oak: 0.17, wood_pine: 0.12,
  fiberglass: 0.04, styrofoam: 0.033,
  air: 0.026, water: 0.607, custom: null
}

export default class extends Controller {
  static targets = [
    "material", "area", "thickness", "tempDifference", "customK",
    "customKGroup",
    "resultQ", "resultQBtu", "resultThermalResistance", "resultHeatFlux",
    "resultConductivity", "resultMaterial",
    "resultsContainer"
  ]

  connect() {
    this.toggleCustomK()
  }

  toggleCustomK() {
    const mat = this.materialTarget.value
    if (mat === "custom") {
      this.customKGroupTarget.classList.remove("hidden")
    } else {
      this.customKGroupTarget.classList.add("hidden")
    }
    this.calculate()
  }

  calculate() {
    const mat = this.materialTarget.value
    let k = MATERIALS[mat]
    if (mat === "custom") {
      k = parseFloat(this.customKTarget.value)
    }

    const area = parseFloat(this.areaTarget.value)
    const thickness = parseFloat(this.thicknessTarget.value)
    const dt = parseFloat(this.tempDifferenceTarget.value)

    if (!k || k <= 0 || isNaN(area) || area <= 0 || isNaN(thickness) || thickness <= 0 || isNaN(dt) || dt === 0) {
      this.clearResults()
      return
    }

    // Fourier's Law: Q = k * A * dT / d
    const q = k * area * dt / thickness
    const qBtu = q * 3.41214
    const thermalR = thickness / (k * area)
    const heatFlux = q / area

    this.resultsContainerTarget.classList.remove("hidden")
    this.resultQTarget.textContent = this.fmt(q) + " W"
    this.resultQBtuTarget.textContent = this.fmt(qBtu) + " BTU/hr"
    this.resultThermalResistanceTarget.textContent = this.fmt(thermalR) + " K/W"
    this.resultHeatFluxTarget.textContent = this.fmt(heatFlux) + " W/m\u00B2"
    this.resultConductivityTarget.textContent = this.fmt(k) + " W/(m\u00B7K)"
    this.resultMaterialTarget.textContent = mat === "custom" ? "Custom" : mat.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase())
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    if (abs >= 0.01) return n.toFixed(4).replace(/\.?0+$/, "")
    return n.toFixed(6).replace(/\.?0+$/, "")
  }

  copy() {
    const text = "Q = " + this.resultQTarget.textContent +
      " (" + this.resultQBtuTarget.textContent + ")" +
      " | R = " + this.resultThermalResistanceTarget.textContent +
      " | Flux = " + this.resultHeatFluxTarget.textContent
    navigator.clipboard.writeText(text)
  }
}
