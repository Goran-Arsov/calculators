import { Controller } from "@hotwired/stimulus"

const CONVERSIONS = {
  // Length
  m_ft: { label: "Meters → Feet", factor: 3.28084, from: "m", to: "ft" },
  ft_m: { label: "Feet → Meters", factor: 0.3048, from: "ft", to: "m" },
  km_mi: { label: "Kilometers → Miles", factor: 0.621371, from: "km", to: "mi" },
  mi_km: { label: "Miles → Kilometers", factor: 1.60934, from: "mi", to: "km" },
  in_cm: { label: "Inches → Centimeters", factor: 2.54, from: "in", to: "cm" },
  cm_in: { label: "Centimeters → Inches", factor: 0.393701, from: "cm", to: "in" },
  m_yd: { label: "Meters → Yards", factor: 1.09361, from: "m", to: "yd" },
  yd_m: { label: "Yards → Meters", factor: 0.9144, from: "yd", to: "m" },
  // Weight
  kg_lb: { label: "Kilograms → Pounds", factor: 2.20462, from: "kg", to: "lb" },
  lb_kg: { label: "Pounds → Kilograms", factor: 0.453592, from: "lb", to: "kg" },
  g_oz: { label: "Grams → Ounces", factor: 0.035274, from: "g", to: "oz" },
  oz_g: { label: "Ounces → Grams", factor: 28.3495, from: "oz", to: "g" },
  // Speed
  kmh_mph: { label: "km/h → mph", factor: 0.621371, from: "km/h", to: "mph" },
  mph_kmh: { label: "mph → km/h", factor: 1.60934, from: "mph", to: "km/h" },
  ms_kmh: { label: "m/s → km/h", factor: 3.6, from: "m/s", to: "km/h" },
  kmh_ms: { label: "km/h → m/s", factor: 0.277778, from: "km/h", to: "m/s" },
  // Volume
  l_gal: { label: "Liters → Gallons (US)", factor: 0.264172, from: "L", to: "gal" },
  gal_l: { label: "Gallons (US) → Liters", factor: 3.78541, from: "gal", to: "L" },
  // Area
  sqm_sqft: { label: "m² → ft²", factor: 10.7639, from: "m²", to: "ft²" },
  sqft_sqm: { label: "ft² → m²", factor: 0.092903, from: "ft²", to: "m²" },
  ha_acre: { label: "Hectares → Acres", factor: 2.47105, from: "ha", to: "acre" },
  acre_ha: { label: "Acres → Hectares", factor: 0.404686, from: "acre", to: "ha" },
  // Temperature (special)
  c_f: { label: "°C → °F", temp: true, from: "°C", to: "°F" },
  f_c: { label: "°F → °C", temp: true, from: "°F", to: "°C" },
  c_k: { label: "°C → K", temp: true, from: "°C", to: "K" },
  k_c: { label: "K → °C", temp: true, from: "K", to: "°C" }
}

export default class extends Controller {
  static targets = ["conversion", "input", "result", "fromUnit", "toUnit"]

  convert() {
    const key = this.conversionTarget.value
    const val = parseFloat(this.inputTarget.value)
    const conv = CONVERSIONS[key]

    if (!conv || isNaN(val)) { this.resultTarget.textContent = "—"; return }

    let result
    if (conv.temp) {
      if (key === "c_f") result = val * 9 / 5 + 32
      else if (key === "f_c") result = (val - 32) * 5 / 9
      else if (key === "c_k") result = val + 273.15
      else if (key === "k_c") result = val - 273.15
    } else {
      result = val * conv.factor
    }

    this.resultTarget.textContent = this.fmt(result) + " " + conv.to
    this.fromUnitTarget.textContent = conv.from
    this.toUnitTarget.textContent = conv.to
  }

  updateLabels() {
    const conv = CONVERSIONS[this.conversionTarget.value]
    if (conv) {
      this.fromUnitTarget.textContent = conv.from
      this.toUnitTarget.textContent = conv.to
    }
    this.convert()
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
