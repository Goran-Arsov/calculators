import { Controller } from "@hotwired/stimulus"

// --- Tokenizer & Parser (shared pattern with integral calculator) ---

const FUNCTIONS = new Set(["sin", "cos", "tan", "exp", "ln", "log", "sqrt", "abs"])

class ParseError extends Error {}

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
        this.consume()
        const arg = this.parseExpr()
        if (this.peek().type !== "rparen") throw new ParseError("missing )")
        this.consume()
        return ["func", tok.value, arg]
      }
      if (tok.value === "x") return ["var"]
      if (tok.value === "pi") return ["num", Math.PI]
      if (tok.value === "e") return ["num", Math.E]
      throw new ParseError(`unknown identifier '${tok.value}'`)
    }
    if (tok.type === "lparen") {
      this.consume()
      const node = this.parseExpr()
      if (this.peek().type !== "rparen") throw new ParseError("missing )")
      this.consume()
      return node
    }
    throw new ParseError("unexpected token")
  }
}

// --- Symbolic Differentiation ---

function isConst(node) {
  if (node[0] === "num") return true
  if (node[0] === "var") return false
  if (node[0] === "neg") return isConst(node[1])
  if (node[0] === "binop") return isConst(node[2]) && isConst(node[3])
  if (node[0] === "func") return isConst(node[2])
  return false
}

function diff(node) {
  switch (node[0]) {
    case "num": return ["num", 0]
    case "var": return ["num", 1]
    case "neg": return ["neg", diff(node[1])]
    case "binop": {
      const [, op, u, v] = node
      if (op === "+") return ["binop", "+", diff(u), diff(v)]
      if (op === "-") return ["binop", "-", diff(u), diff(v)]
      if (op === "*") return ["binop", "+", ["binop", "*", diff(u), v], ["binop", "*", u, diff(v)]]
      if (op === "/") return ["binop", "/", ["binop", "-", ["binop", "*", diff(u), v], ["binop", "*", u, diff(v)]], ["binop", "^", v, ["num", 2]]]
      if (op === "^") {
        if (isConst(v) && !isConst(u)) {
          return ["binop", "*", ["binop", "*", v, ["binop", "^", u, ["binop", "-", v, ["num", 1]]]], diff(u)]
        }
        if (isConst(u) && !isConst(v)) {
          return ["binop", "*", ["binop", "*", node, ["func", "ln", u]], diff(v)]
        }
        return ["binop", "*", node, ["binop", "+", ["binop", "*", diff(v), ["func", "ln", u]], ["binop", "*", v, ["binop", "/", diff(u), u]]]]
      }
    }
    break
    case "func": {
      const [, name, u] = node
      const du = diff(u)
      let inner
      if (name === "sin") inner = ["func", "cos", u]
      else if (name === "cos") inner = ["neg", ["func", "sin", u]]
      else if (name === "tan") inner = ["binop", "/", ["num", 1], ["binop", "^", ["func", "cos", u], ["num", 2]]]
      else if (name === "exp") inner = ["func", "exp", u]
      else if (name === "ln" || name === "log") inner = ["binop", "/", ["num", 1], u]
      else if (name === "sqrt") inner = ["binop", "/", ["num", 1], ["binop", "*", ["num", 2], ["func", "sqrt", u]]]
      else inner = ["num", 0]
      return ["binop", "*", inner, du]
    }
  }
  return ["num", 0]
}

// --- Simplifier ---

function simplify(node) {
  if (!node) return node
  switch (node[0]) {
    case "num": case "var": return node
    case "neg": {
      const inner = simplify(node[1])
      if (eq(inner, ["num", 0])) return ["num", 0]
      if (inner[0] === "num") return ["num", -inner[1]]
      return ["neg", inner]
    }
    case "binop": {
      const op = node[1]
      const l = simplify(node[2]), r = simplify(node[3])
      if (l[0] === "num" && r[0] === "num") {
        const v = evalConst(op, l[1], r[1])
        if (v !== null) return ["num", v]
      }
      if (op === "+") {
        if (eq(l, ["num", 0])) return r
        if (eq(r, ["num", 0])) return l
      }
      if (op === "-") {
        if (eq(l, ["num", 0])) return ["neg", r]
        if (eq(r, ["num", 0])) return l
        if (eq(l, r)) return ["num", 0]
      }
      if (op === "*") {
        if (eq(l, ["num", 0]) || eq(r, ["num", 0])) return ["num", 0]
        if (eq(l, ["num", 1])) return r
        if (eq(r, ["num", 1])) return l
        if (eq(l, ["num", -1])) return ["neg", r]
        if (eq(r, ["num", -1])) return ["neg", l]
      }
      if (op === "/") {
        if (eq(l, ["num", 0])) return ["num", 0]
        if (eq(r, ["num", 1])) return l
      }
      if (op === "^") {
        if (eq(r, ["num", 0])) return ["num", 1]
        if (eq(r, ["num", 1])) return l
        if (eq(l, ["num", 0])) return ["num", 0]
      }
      return ["binop", op, l, r]
    }
    case "func": return ["func", node[1], simplify(node[2])]
  }
  return node
}

function eq(a, b) { return JSON.stringify(a) === JSON.stringify(b) }

function evalConst(op, a, b) {
  if (op === "+") return a + b
  if (op === "-") return a - b
  if (op === "*") return a * b
  if (op === "/") return b === 0 ? null : a / b
  if (op === "^") return Math.pow(a, b)
  return null
}

// --- AST to string ---

function prec(op) {
  if (op === "+" || op === "-") return 1
  if (op === "*" || op === "/") return 2
  if (op === "^") return 3
  return 0
}

function toString(node) {
  if (!node) return ""
  switch (node[0]) {
    case "num": {
      const n = node[1]
      return n === Math.floor(n) ? n.toString() : n.toFixed(6).replace(/\.?0+$/, "")
    }
    case "var": return "x"
    case "neg": {
      const s = toString(node[1])
      return node[1][0] === "binop" ? `-(${s})` : `-${s}`
    }
    case "binop": {
      const [, op, left, right] = node
      let ls = toString(left), rs = toString(right)
      if (left[0] === "binop" && prec(left[1]) < prec(op)) ls = `(${ls})`
      if (right[0] === "binop" && (prec(right[1]) < prec(op) || (prec(right[1]) === prec(op) && (op === "-" || op === "/")))) rs = `(${rs})`
      return `${ls} ${op} ${rs}`
    }
    case "func": return `${node[1]}(${toString(node[2])})`
  }
  return ""
}

export default class extends Controller {
  static targets = ["expression", "result", "steps", "error"]

  calculate() {
    const expr = this.expressionTarget.value.trim()
    this.errorTarget.textContent = ""

    if (!expr) { this.clear(); return }

    try {
      const ast = new Parser(expr).parse()
      const rawDeriv = diff(ast)
      const simplified = simplify(rawDeriv)
      const result = toString(simplified)
      this.resultTarget.textContent = result
      if (this.hasStepsTarget) {
        this.stepsTarget.innerHTML =
          `<div class="text-xs text-gray-500 dark:text-gray-400 space-y-1">` +
          `<div>f(x) = ${toString(ast)}</div>` +
          `<div>f'(x) = ${result}</div></div>`
      }
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasStepsTarget) this.stepsTarget.innerHTML = ""
  }

  copy() {
    const result = this.resultTarget.textContent
    navigator.clipboard.writeText(`f'(x) = ${result}`)
  }
}
