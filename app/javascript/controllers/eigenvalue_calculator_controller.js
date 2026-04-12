import { Controller } from "@hotwired/stimulus"

function fmt(n) {
  if (Math.abs(n) < 1e-10) return "0"
  if (n === Math.floor(n) && Math.abs(n) < 1e12) return n.toString()
  return parseFloat(n.toFixed(6)).toString()
}

function fmtComplex(re, im) {
  re = Math.abs(re) < 1e-10 ? 0 : re
  im = Math.abs(im) < 1e-10 ? 0 : im
  if (im === 0) return fmt(re)
  const sign = im >= 0 ? "+" : "-"
  return `${fmt(re)} ${sign} ${fmt(Math.abs(im))}i`
}

function cbrt(x) { return x >= 0 ? Math.pow(x, 1 / 3) : -Math.pow(-x, 1 / 3) }

function solve2x2(matrix) {
  const [[a, b], [c, d]] = matrix
  const trace = a + d
  const det = a * d - b * c
  const disc = trace * trace - 4 * det

  let eigenvalues
  if (disc >= 0) {
    const sq = Math.sqrt(disc)
    eigenvalues = [{ real: (trace + sq) / 2, imag: 0 }, { real: (trace - sq) / 2, imag: 0 }]
  } else {
    const sq = Math.sqrt(-disc)
    eigenvalues = [{ real: trace / 2, imag: sq / 2 }, { real: trace / 2, imag: -sq / 2 }]
  }

  const eigenvectors = eigenvalues.map(lam => {
    if (lam.imag !== 0) return null
    const l = lam.real
    const r1 = a - l, r2 = b
    let vec
    if (Math.abs(r2) > 1e-12) vec = [-r2, r1]
    else if (Math.abs(c) > 1e-12) vec = [d - l, -c]
    else vec = [1, 0]
    const mag = Math.sqrt(vec[0] ** 2 + vec[1] ** 2)
    if (mag > 1e-12) vec = vec.map(v => v / mag)
    return vec
  })

  return { eigenvalues, eigenvectors, trace, det, disc }
}

function det3x3(m) {
  return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
    m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
    m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
}

function cross3(a, b) {
  return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]
}

function solveCubic(a, b, c, d) {
  const p = b / a, q = c / a, r = d / a
  const q2 = (3 * q - p * p) / 9
  const r2 = (9 * p * q - 27 * r - 2 * p * p * p) / 54
  const disc = q2 * q2 * q2 + r2 * r2

  if (disc >= 0) {
    const s = cbrt(r2 + Math.sqrt(disc))
    const t = cbrt(r2 - Math.sqrt(disc))
    const root1 = s + t - p / 3
    if (Math.abs(disc) < 1e-10) {
      const root2 = -(s + t) / 2 - p / 3
      return [{ real: root1, imag: 0 }, { real: root2, imag: 0 }, { real: root2, imag: 0 }]
    }
    const rePart = -(s + t) / 2 - p / 3
    const imPart = (s - t) * Math.sqrt(3) / 2
    return [{ real: root1, imag: 0 }, { real: rePart, imag: imPart }, { real: rePart, imag: -imPart }]
  } else {
    const theta = Math.acos(r2 / Math.sqrt(-(q2 * q2 * q2)))
    const mag = 2 * Math.sqrt(-q2)
    return [
      { real: mag * Math.cos(theta / 3) - p / 3, imag: 0 },
      { real: mag * Math.cos((theta + 2 * Math.PI) / 3) - p / 3, imag: 0 },
      { real: mag * Math.cos((theta + 4 * Math.PI) / 3) - p / 3, imag: 0 }
    ]
  }
}

function solve3x3(matrix) {
  const a = matrix
  const tr = a[0][0] + a[1][1] + a[2][2]
  const k = a[0][0] * a[1][1] - a[0][1] * a[1][0] +
    a[0][0] * a[2][2] - a[0][2] * a[2][0] +
    a[1][1] * a[2][2] - a[1][2] * a[2][1]
  const det = det3x3(a)

  const eigenvalues = solveCubic(1, -tr, k, -det)

  const eigenvectors = eigenvalues.map(lam => {
    if (lam.imag !== 0) return null
    const l = lam.real
    const m = a.map((row, i) => row.map((val, j) => i === j ? val - l : val))
    let best = null, bestMag = 0
    const pairs = [[0, 1], [0, 2], [1, 2]]
    for (const [i, j] of pairs) {
      const v = cross3(m[i], m[j])
      const mag = Math.sqrt(v[0] ** 2 + v[1] ** 2 + v[2] ** 2)
      if (mag > bestMag) { best = v; bestMag = mag }
    }
    if (bestMag > 1e-12) return best.map(c => c / bestMag)
    return [1, 0, 0]
  })

  return { eigenvalues, eigenvectors, trace: tr, det, disc: null }
}

export default class extends Controller {
  static targets = [
    "size", "matrix2x2", "matrix3x3",
    "a00", "a01", "a10", "a11",
    "b00", "b01", "b02", "b10", "b11", "b12", "b20", "b21", "b22",
    "result", "resultDetail", "charPoly", "error"
  ]

  connect() { this.updateVisibility() }

  updateVisibility() {
    const size = this.sizeTarget.value
    if (this.hasMatrix2x2Target) this.matrix2x2Target.classList.toggle("hidden", size !== "2")
    if (this.hasMatrix3x3Target) this.matrix3x3Target.classList.toggle("hidden", size !== "3")
    this.calculate()
  }

  calculate() {
    const size = this.sizeTarget.value
    this.errorTarget.textContent = ""

    try {
      let result
      if (size === "2") {
        const matrix = [
          [parseFloat(this.a00Target.value) || 0, parseFloat(this.a01Target.value) || 0],
          [parseFloat(this.a10Target.value) || 0, parseFloat(this.a11Target.value) || 0]
        ]
        result = solve2x2(matrix)
      } else {
        const matrix = [
          [parseFloat(this.b00Target.value) || 0, parseFloat(this.b01Target.value) || 0, parseFloat(this.b02Target.value) || 0],
          [parseFloat(this.b10Target.value) || 0, parseFloat(this.b11Target.value) || 0, parseFloat(this.b12Target.value) || 0],
          [parseFloat(this.b20Target.value) || 0, parseFloat(this.b21Target.value) || 0, parseFloat(this.b22Target.value) || 0]
        ]
        result = solve3x3(matrix)
      }

      const eigStrs = result.eigenvalues.map(ev =>
        ev.imag !== 0 ? fmtComplex(ev.real, ev.imag) : fmt(ev.real)
      )
      this.resultTarget.textContent = `\u03BB = ${eigStrs.join(", ")}`

      if (this.hasResultDetailTarget) {
        const lines = result.eigenvalues.map((ev, i) => {
          const evStr = ev.imag !== 0 ? fmtComplex(ev.real, ev.imag) : fmt(ev.real)
          const vec = result.eigenvectors[i]
          const vecStr = vec ? `[${vec.map(fmt).join(", ")}]` : "complex"
          return `\u03BB${i + 1} = ${evStr}, v${i + 1} = ${vecStr}`
        }).join("\n")
        this.resultDetailTarget.textContent = lines
      }

      if (this.hasCharPolyTarget) {
        if (size === "2") {
          this.charPolyTarget.textContent = `\u03BB\u00B2 - ${fmt(result.trace)}\u03BB + ${fmt(result.det)} = 0`
        } else {
          this.charPolyTarget.textContent = `Trace = ${fmt(result.trace)}, Det = ${fmt(result.det)}`
        }
      }
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasResultDetailTarget) this.resultDetailTarget.textContent = ""
    if (this.hasCharPolyTarget) this.charPolyTarget.textContent = ""
  }

  copy() {
    const text = this.resultTarget.textContent
    const detail = this.hasResultDetailTarget ? this.resultDetailTarget.textContent : ""
    navigator.clipboard.writeText(`${text}\n${detail}`)
  }
}
