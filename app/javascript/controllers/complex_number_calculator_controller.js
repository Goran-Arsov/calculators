import { Controller } from "@hotwired/stimulus"

function fmt(n) {
  if (Math.abs(n) < 1e-12) return "0"
  if (n === Math.floor(n) && Math.abs(n) < 1e12) return n.toString()
  return parseFloat(n.toFixed(6)).toString()
}

function fmtComplex(re, im) {
  re = Math.abs(re) < 1e-12 ? 0 : re
  im = Math.abs(im) < 1e-12 ? 0 : im
  if (im === 0) return fmt(re)
  if (re === 0) {
    if (im === 1) return "i"
    if (im === -1) return "-i"
    return `${fmt(im)}i`
  }
  const sign = im >= 0 ? "+" : "-"
  const absIm = Math.abs(im)
  const imStr = absIm === 1 ? "i" : `${fmt(absIm)}i`
  return `${fmt(re)} ${sign} ${imStr}`
}

export default class extends Controller {
  static targets = [
    "operation", "real1", "imag1", "real2", "imag2",
    "polarR", "polarTheta",
    "result", "resultDetail", "error",
    "secondComplex", "polarInput"
  ]

  connect() { this.updateVisibility() }

  updateVisibility() {
    const op = this.operationTarget.value
    const needsTwo = ["add", "subtract", "multiply", "divide"].includes(op)
    const isPolar = op === "to_rectangular"

    if (this.hasSecondComplexTarget) this.secondComplexTarget.classList.toggle("hidden", !needsTwo)
    if (this.hasPolarInputTarget) this.polarInputTarget.classList.toggle("hidden", !isPolar)

    this.calculate()
  }

  calculate() {
    const op = this.operationTarget.value
    this.errorTarget.textContent = ""

    try {
      let result
      switch (op) {
        case "add": case "subtract": case "multiply": case "divide": {
          const r1 = parseFloat(this.real1Target.value) || 0
          const i1 = parseFloat(this.imag1Target.value) || 0
          const r2 = parseFloat(this.real2Target.value) || 0
          const i2 = parseFloat(this.imag2Target.value) || 0
          result = this.binaryOp(op, r1, i1, r2, i2)
          break
        }
        case "magnitude": {
          const r1 = parseFloat(this.real1Target.value) || 0
          const i1 = parseFloat(this.imag1Target.value) || 0
          const mag = Math.sqrt(r1 * r1 + i1 * i1)
          result = { main: fmt(mag), detail: `|${fmtComplex(r1, i1)}| = ${fmt(mag)}` }
          break
        }
        case "conjugate": {
          const r1 = parseFloat(this.real1Target.value) || 0
          const i1 = parseFloat(this.imag1Target.value) || 0
          result = { main: fmtComplex(r1, -i1), detail: `Conjugate of ${fmtComplex(r1, i1)}` }
          break
        }
        case "to_polar": {
          const r1 = parseFloat(this.real1Target.value) || 0
          const i1 = parseFloat(this.imag1Target.value) || 0
          const r = Math.sqrt(r1 * r1 + i1 * i1)
          const theta = Math.atan2(i1, r1) * 180 / Math.PI
          result = { main: `${fmt(r)} \u2220 ${fmt(theta)}\u00B0`, detail: `r = ${fmt(r)}, \u03B8 = ${fmt(theta)}\u00B0 (${fmt(theta * Math.PI / 180)} rad)` }
          break
        }
        case "to_rectangular": {
          const r = parseFloat(this.polarRTarget.value) || 0
          const theta = parseFloat(this.polarThetaTarget.value) || 0
          const re = r * Math.cos(theta * Math.PI / 180)
          const im = r * Math.sin(theta * Math.PI / 180)
          result = { main: fmtComplex(re, im), detail: `${fmt(r)} \u2220 ${fmt(theta)}\u00B0 = ${fmtComplex(re, im)}` }
          break
        }
        default:
          this.clear(); return
      }
      this.resultTarget.textContent = result.main
      if (this.hasResultDetailTarget) this.resultDetailTarget.textContent = result.detail || ""
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  binaryOp(op, r1, i1, r2, i2) {
    let re, im
    switch (op) {
      case "add": re = r1 + r2; im = i1 + i2; break
      case "subtract": re = r1 - r2; im = i1 - i2; break
      case "multiply": re = r1 * r2 - i1 * i2; im = r1 * i2 + i1 * r2; break
      case "divide": {
        const denom = r2 * r2 + i2 * i2
        if (denom === 0) throw new Error("Cannot divide by zero")
        re = (r1 * r2 + i1 * i2) / denom
        im = (i1 * r2 - r1 * i2) / denom
        break
      }
    }
    const z1 = fmtComplex(r1, i1), z2 = fmtComplex(r2, i2), zr = fmtComplex(re, im)
    const opSym = { add: "+", subtract: "-", multiply: "\u00D7", divide: "\u00F7" }[op]
    return { main: zr, detail: `(${z1}) ${opSym} (${z2}) = ${zr}` }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasResultDetailTarget) this.resultDetailTarget.textContent = ""
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
