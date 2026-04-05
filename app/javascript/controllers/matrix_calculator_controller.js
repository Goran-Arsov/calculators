import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["matrixA", "matrixB", "operation", "result"]

  calculate() {
    const aStr = this.matrixATarget.value.trim()
    const bStr = this.matrixBTarget.value.trim()
    const op = this.operationTarget.value

    if (!aStr) {
      this.clearResults()
      return
    }

    const matA = this.parseMatrix(aStr)
    if (!matA) {
      this.resultTarget.textContent = "Invalid Matrix A format"
      return
    }

    if (["determinant_a", "transpose_a"].includes(op)) {
      if (op === "determinant_a") {
        if (!this.isSquare(matA)) {
          this.resultTarget.textContent = "Matrix A must be square"
          return
        }
        const det = this.determinant(matA)
        this.resultTarget.textContent = this.fmt(det)
      } else {
        const t = this.transpose(matA)
        this.resultTarget.textContent = this.matrixToString(t)
      }
      return
    }

    const matB = this.parseMatrix(bStr)
    if (!matB) {
      this.resultTarget.textContent = bStr ? "Invalid Matrix B format" : "Enter Matrix B"
      return
    }

    if (["determinant_b", "transpose_b"].includes(op)) {
      if (op === "determinant_b") {
        if (!this.isSquare(matB)) {
          this.resultTarget.textContent = "Matrix B must be square"
          return
        }
        const det = this.determinant(matB)
        this.resultTarget.textContent = this.fmt(det)
      } else {
        const t = this.transpose(matB)
        this.resultTarget.textContent = this.matrixToString(t)
      }
      return
    }

    if (op === "add" || op === "subtract") {
      if (matA.length !== matB.length || matA[0].length !== matB[0].length) {
        this.resultTarget.textContent = "Matrices must have same dimensions"
        return
      }
      const res = matA.map((row, i) =>
        row.map((val, j) => op === "add" ? val + matB[i][j] : val - matB[i][j])
      )
      this.resultTarget.textContent = this.matrixToString(res)
    } else if (op === "multiply") {
      if (matA[0].length !== matB.length) {
        this.resultTarget.textContent = "Columns of A must equal rows of B"
        return
      }
      const rows = matA.length
      const cols = matB[0].length
      const res = Array.from({ length: rows }, () => Array(cols).fill(0))
      for (let i = 0; i < rows; i++) {
        for (let j = 0; j < cols; j++) {
          for (let k = 0; k < matA[0].length; k++) {
            res[i][j] += matA[i][k] * matB[k][j]
          }
        }
      }
      this.resultTarget.textContent = this.matrixToString(res)
    }
  }

  parseMatrix(str) {
    try {
      const rows = str.split(";").map(r => r.trim()).filter(r => r !== "")
      if (rows.length === 0) return null
      const matrix = rows.map(r => r.split(",").map(v => {
        const n = parseFloat(v.trim())
        if (isNaN(n)) throw new Error("NaN")
        return n
      }))
      const colCount = matrix[0].length
      if (!matrix.every(r => r.length === colCount)) return null
      return matrix
    } catch { return null }
  }

  isSquare(m) { return m.length === m[0].length }

  determinant(m) {
    const n = m.length
    if (n === 1) return m[0][0]
    if (n === 2) return m[0][0] * m[1][1] - m[0][1] * m[1][0]
    let det = 0
    for (let c = 0; c < n; c++) {
      const sub = m.slice(1).map(row => [...row.slice(0, c), ...row.slice(c + 1)])
      det += (c % 2 === 0 ? 1 : -1) * m[0][c] * this.determinant(sub)
    }
    return det
  }

  transpose(m) {
    return m[0].map((_, j) => m.map(row => row[j]))
  }

  matrixToString(m) {
    return m.map(row => row.map(v => this.fmt(v)).join(", ")).join(" ; ")
  }

  clearResults() {
    this.resultTarget.textContent = "—"
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const result = this.resultTarget.textContent
    navigator.clipboard.writeText(`Matrix Result: ${result}`)
  }
}
