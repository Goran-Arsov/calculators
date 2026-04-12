import { Controller } from "@hotwired/stimulus"

function fmt(n) {
  if (Math.abs(n) < 1e-12) return "0"
  if (n === Math.floor(n) && Math.abs(n) < 1e12) return n.toString()
  return parseFloat(n.toFixed(6)).toString()
}

function fmtVec(v) {
  return `\u27E8${v.map(fmt).join(", ")}\u27E9`
}

function magnitude(v) {
  return Math.sqrt(v.reduce((s, c) => s + c * c, 0))
}

function parseVec(str) {
  return str.split(",").map(s => parseFloat(s.trim())).filter(n => !isNaN(n))
}

export default class extends Controller {
  static targets = [
    "operation", "v1", "v2", "scalar",
    "result", "resultDetail", "error",
    "secondVector", "scalarInput", "angleInfo"
  ]

  connect() { this.updateVisibility() }

  updateVisibility() {
    const op = this.operationTarget.value
    const needsTwo = ["add", "subtract", "dot_product", "cross_product"].includes(op)
    const needsScalar = op === "scalar_multiply"

    if (this.hasSecondVectorTarget) this.secondVectorTarget.classList.toggle("hidden", !needsTwo)
    if (this.hasScalarInputTarget) this.scalarInputTarget.classList.toggle("hidden", !needsScalar)

    this.calculate()
  }

  calculate() {
    const op = this.operationTarget.value
    const v1 = parseVec(this.v1Target.value)
    this.errorTarget.textContent = ""

    if (v1.length < 2 || v1.length > 3) { this.clear(); return }

    try {
      let result
      switch (op) {
        case "add": case "subtract": case "dot_product": case "cross_product": {
          const v2 = parseVec(this.v2Target.value)
          if (v2.length < 2 || v2.length > 3) { this.clear(); return }
          if (v1.length !== v2.length) { this.errorTarget.textContent = "Vectors must have same dimensions"; this.clear(); return }
          if (op === "cross_product" && v1.length !== 3) { this.errorTarget.textContent = "Cross product requires 3D vectors"; this.clear(); return }
          result = this.twoVecOp(op, v1, v2)
          break
        }
        case "magnitude": {
          const mag = magnitude(v1)
          result = { main: fmt(mag), detail: `|${fmtVec(v1)}| = ${fmt(mag)}` }
          break
        }
        case "normalize": {
          const mag = magnitude(v1)
          if (mag === 0) { this.errorTarget.textContent = "Cannot normalize zero vector"; this.clear(); return }
          const norm = v1.map(c => c / mag)
          result = { main: fmtVec(norm), detail: `${fmtVec(v1)} / ${fmt(mag)} = ${fmtVec(norm)}` }
          break
        }
        case "scalar_multiply": {
          const s = parseFloat(this.scalarTarget.value) || 0
          const res = v1.map(c => c * s)
          result = { main: fmtVec(res), detail: `${fmt(s)} \u00D7 ${fmtVec(v1)} = ${fmtVec(res)}` }
          break
        }
        default: this.clear(); return
      }
      this.resultTarget.textContent = result.main
      if (this.hasResultDetailTarget) this.resultDetailTarget.textContent = result.detail || ""
      if (this.hasAngleInfoTarget) this.angleInfoTarget.textContent = result.angle || ""
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  twoVecOp(op, v1, v2) {
    switch (op) {
      case "add": {
        const r = v1.map((c, i) => c + v2[i])
        return { main: fmtVec(r), detail: `${fmtVec(v1)} + ${fmtVec(v2)} = ${fmtVec(r)}` }
      }
      case "subtract": {
        const r = v1.map((c, i) => c - v2[i])
        return { main: fmtVec(r), detail: `${fmtVec(v1)} - ${fmtVec(v2)} = ${fmtVec(r)}` }
      }
      case "dot_product": {
        const dot = v1.reduce((s, c, i) => s + c * v2[i], 0)
        const m1 = magnitude(v1), m2 = magnitude(v2)
        let angleStr = ""
        if (m1 > 0 && m2 > 0) {
          const cosT = Math.max(-1, Math.min(1, dot / (m1 * m2)))
          const angle = Math.acos(cosT) * 180 / Math.PI
          angleStr = `Angle: ${fmt(angle)}\u00B0`
        }
        return { main: fmt(dot), detail: `${fmtVec(v1)} \u00B7 ${fmtVec(v2)} = ${fmt(dot)}`, angle: angleStr }
      }
      case "cross_product": {
        const r = [
          v1[1] * v2[2] - v1[2] * v2[1],
          v1[2] * v2[0] - v1[0] * v2[2],
          v1[0] * v2[1] - v1[1] * v2[0]
        ]
        const mag = magnitude(r)
        return { main: fmtVec(r), detail: `${fmtVec(v1)} \u00D7 ${fmtVec(v2)} = ${fmtVec(r)}, |result| = ${fmt(mag)}` }
      }
    }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasResultDetailTarget) this.resultDetailTarget.textContent = ""
    if (this.hasAngleInfoTarget) this.angleInfoTarget.textContent = ""
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
