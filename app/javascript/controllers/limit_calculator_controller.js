import { Controller } from "@hotwired/stimulus"

const FUNCTIONS = new Set([
  "sin", "cos", "tan", "asin", "acos", "atan",
  "sinh", "cosh", "tanh", "ln", "log", "log10", "exp", "sqrt", "abs"
])

class ParseError extends Error {}
class MathError extends Error {}

function tokenize(input) {
  const src = input.toLowerCase()
  const tokens = []
  let i = 0
  while (i < src.length) {
    const ch = src[i]
    if (ch === " " || ch === "\t") { i++; continue }
    if (/[0-9.]/.test(ch)) {
      let start = i, dot = false
      while (i < src.length && /[0-9.]/.test(src[i])) {
        if (src[i] === ".") { if (dot) throw new ParseError("invalid number"); dot = true }
        i++
      }
      tokens.push({ type: "number", value: src.slice(start, i) })
      continue
    }
    if (/[a-z]/.test(ch)) {
      let start = i
      while (i < src.length && /[a-z0-9_]/.test(src[i])) i++
      tokens.push({ type: "ident", value: src.slice(start, i) })
      continue
    }
    if (ch === "(") { tokens.push({ type: "lparen" }); i++; continue }
    if (ch === ")") { tokens.push({ type: "rparen" }); i++; continue }
    if ("+-*/^".includes(ch)) { tokens.push({ type: "op", value: ch }); i++; continue }
    throw new ParseError(`unexpected character '${ch}'`)
  }
  tokens.push({ type: "eof" })
  return tokens
}

class Parser {
  constructor(input) { this.tokens = tokenize(input); this.pos = 0 }
  peek() { return this.tokens[this.pos] || { type: "eof" } }
  consume() { return this.tokens[this.pos++] }
  parse() {
    const node = this.parseExpr()
    if (this.peek().type !== "eof") throw new ParseError("unexpected token")
    return node
  }
  parseExpr() {
    let node = this.parseTerm()
    while (this.peek().type === "op" && (this.peek().value === "+" || this.peek().value === "-")) {
      const op = this.consume().value; node = ["binop", op, node, this.parseTerm()]
    }
    return node
  }
  parseTerm() {
    let node = this.parseUnary()
    while (this.peek().type === "op" && (this.peek().value === "*" || this.peek().value === "/")) {
      const op = this.consume().value; node = ["binop", op, node, this.parseUnary()]
    }
    return node
  }
  parseUnary() {
    if (this.peek().type === "op" && this.peek().value === "-") { this.consume(); return ["neg", this.parseUnary()] }
    if (this.peek().type === "op" && this.peek().value === "+") { this.consume(); return this.parseUnary() }
    return this.parsePower()
  }
  parsePower() {
    const base = this.parsePrimary()
    if (this.peek().type === "op" && this.peek().value === "^") { this.consume(); return ["binop", "^", base, this.parseUnary()] }
    return base
  }
  parsePrimary() {
    const tok = this.peek()
    if (tok.type === "number") { this.consume(); return ["num", parseFloat(tok.value)] }
    if (tok.type === "ident") {
      this.consume()
      if (this.peek().type === "lparen") {
        if (!FUNCTIONS.has(tok.value)) throw new ParseError(`unknown function '${tok.value}'`)
        this.consume(); const arg = this.parseExpr()
        if (this.peek().type !== "rparen") throw new ParseError("missing )")
        this.consume(); return ["func", tok.value, arg]
      }
      if (tok.value === "x") return ["var"]
      if (tok.value === "pi") return ["num", Math.PI]
      if (tok.value === "e") return ["num", Math.E]
      throw new ParseError(`unknown identifier '${tok.value}'`)
    }
    if (tok.type === "lparen") {
      this.consume(); const node = this.parseExpr()
      if (this.peek().type !== "rparen") throw new ParseError("missing )")
      this.consume(); return node
    }
    throw new ParseError("unexpected token")
  }
}

function evaluate(node, x) {
  switch (node[0]) {
    case "num": return node[1]
    case "var": return x
    case "neg": return -evaluate(node[1], x)
    case "binop": {
      const a = evaluate(node[2], x), b = evaluate(node[3], x)
      switch (node[1]) {
        case "+": return a + b
        case "-": return a - b
        case "*": return a * b
        case "/": if (b === 0) throw new MathError("division by zero"); return a / b
        case "^": return Math.pow(a, b)
      }
    }
    break
    case "func": {
      const arg = evaluate(node[2], x)
      switch (node[1]) {
        case "sin": return Math.sin(arg); case "cos": return Math.cos(arg)
        case "tan": return Math.tan(arg); case "asin": return Math.asin(arg)
        case "acos": return Math.acos(arg); case "atan": return Math.atan(arg)
        case "sinh": return Math.sinh(arg); case "cosh": return Math.cosh(arg)
        case "tanh": return Math.tanh(arg); case "ln": case "log": return Math.log(arg)
        case "log10": return Math.log10(arg); case "exp": return Math.exp(arg)
        case "sqrt": return Math.sqrt(arg); case "abs": return Math.abs(arg)
      }
    }
  }
  return NaN
}

function parseApproach(val) {
  const v = val.trim().toLowerCase()
  if (v === "infinity" || v === "inf" || v === "+inf") return Infinity
  if (v === "-infinity" || v === "-inf") return -Infinity
  if (v === "pi") return Math.PI
  if (v === "e") return Math.E
  return parseFloat(val)
}

function computeLimit(ast, target, side) {
  if (!isFinite(target)) {
    const sign = target > 0 ? 1 : -1
    const vals = []
    for (const n of [1e2, 1e4, 1e6, 1e8, 1e10]) {
      try { const v = evaluate(ast, sign * n); if (isFinite(v)) vals.push(v) } catch { continue }
    }
    if (vals.length < 3) return null
    const last = vals.slice(-3)
    if (last.every(v => closeEnough(v, last[last.length - 1]))) return last[last.length - 1]
    return null
  }

  const vals = []
  let eps = 1e-2
  while (eps >= 1e-12) {
    const x = side === "left" ? target - eps : target + eps
    try {
      const v = evaluate(ast, x)
      if (isFinite(v)) vals.push(v)
    } catch { /* skip */ }
    eps *= 0.1
  }
  if (vals.length < 2) return null
  const last = vals.slice(-3)
  if (last.every(v => closeEnough(v, last[last.length - 1]))) return last[last.length - 1]
  return null
}

function closeEnough(a, b) {
  if (a === b) return true
  const mag = Math.max(Math.abs(a), Math.abs(b), 1)
  return Math.abs(a - b) / mag < 1e-6
}

function fmt(n) {
  if (Math.abs(n) < 1e-12) return "0"
  if (n === Math.floor(n) && Math.abs(n) < 1e15) return n.toString()
  if (Math.abs(n) >= 1e6 || (Math.abs(n) > 0 && Math.abs(n) < 1e-4)) return n.toExponential(6)
  return n.toFixed(6).replace(/\.?0+$/, "")
}

export default class extends Controller {
  static targets = ["expression", "approach", "direction", "result", "leftLimit", "rightLimit", "error"]

  calculate() {
    const expr = this.expressionTarget.value.trim()
    const approachStr = this.approachTarget.value.trim()
    const direction = this.hasDirectionTarget ? this.directionTarget.value : "both"
    this.errorTarget.textContent = ""

    if (!expr || !approachStr) { this.clear(); return }

    const target = parseApproach(approachStr)
    if (isNaN(target)) { this.clear(); this.errorTarget.textContent = "Invalid approach value"; return }

    let ast
    try { ast = new Parser(expr).parse() } catch (e) { this.clear(); this.errorTarget.textContent = e.message; return }

    try {
      if (direction === "both") {
        const left = computeLimit(ast, target, "left")
        const right = computeLimit(ast, target, "right")
        if (this.hasLeftLimitTarget) this.leftLimitTarget.textContent = left !== null ? fmt(left) : "diverges"
        if (this.hasRightLimitTarget) this.rightLimitTarget.textContent = right !== null ? fmt(right) : "diverges"

        if (left !== null && right !== null && closeEnough(left, right)) {
          this.resultTarget.textContent = fmt((left + right) / 2)
        } else if (left !== null && right !== null) {
          this.resultTarget.textContent = "Does not exist (left \u2260 right)"
        } else {
          this.resultTarget.textContent = "Diverges"
        }
      } else {
        const val = computeLimit(ast, target, direction)
        this.resultTarget.textContent = val !== null ? fmt(val) : "Diverges"
        if (this.hasLeftLimitTarget) this.leftLimitTarget.textContent = "\u2014"
        if (this.hasRightLimitTarget) this.rightLimitTarget.textContent = "\u2014"
      }
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasLeftLimitTarget) this.leftLimitTarget.textContent = "\u2014"
    if (this.hasRightLimitTarget) this.rightLimitTarget.textContent = "\u2014"
  }

  copy() {
    const expr = this.expressionTarget.value
    const approach = this.approachTarget.value
    const result = this.resultTarget.textContent
    navigator.clipboard.writeText(`lim(x\u2192${approach}) ${expr} = ${result}`)
  }
}
