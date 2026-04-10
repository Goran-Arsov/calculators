import { Controller } from "@hotwired/stimulus"

const FUNCTIONS = new Set([
  "sin", "cos", "tan", "asin", "acos", "atan",
  "sinh", "cosh", "tanh",
  "ln", "log", "log10", "exp", "sqrt", "abs"
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
      let start = i
      let dot = false
      while (i < src.length && /[0-9.]/.test(src[i])) {
        if (src[i] === ".") {
          if (dot) throw new ParseError("invalid number")
          dot = true
        }
        i++
      }
      if (i < src.length && (src[i] === "e" || src[i] === "E")) {
        if (i + 1 < src.length && /[0-9+\-]/.test(src[i + 1])) {
          i++
          if (src[i] === "+" || src[i] === "-") i++
          while (i < src.length && /[0-9]/.test(src[i])) i++
        }
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
    if (ch === "(") { tokens.push({ type: "lparen", value: "(" }); i++; continue }
    if (ch === ")") { tokens.push({ type: "rparen", value: ")" }); i++; continue }
    if ("+-*/^".includes(ch)) { tokens.push({ type: "op", value: ch }); i++; continue }
    throw new ParseError(`unexpected character '${ch}'`)
  }
  tokens.push({ type: "eof", value: "" })
  return tokens
}

class Parser {
  constructor(input) {
    this.tokens = tokenize(input)
    this.pos = 0
  }

  peek() { return this.tokens[this.pos] }
  consume() { return this.tokens[this.pos++] }

  parse() {
    const node = this.parseExpression()
    if (this.peek().type !== "eof") throw new ParseError(`unexpected token '${this.peek().value}'`)
    return node
  }

  parseExpression() {
    let node = this.parseTerm()
    while (this.peek().type === "op" && (this.peek().value === "+" || this.peek().value === "-")) {
      const op = this.consume().value
      const right = this.parseTerm()
      node = ["binop", op, node, right]
    }
    return node
  }

  parseTerm() {
    let node = this.parseUnary()
    while (this.peek().type === "op" && (this.peek().value === "*" || this.peek().value === "/")) {
      const op = this.consume().value
      const right = this.parseUnary()
      node = ["binop", op, node, right]
    }
    return node
  }

  parseUnary() {
    if (this.peek().type === "op" && this.peek().value === "-") {
      this.consume()
      return ["neg", this.parseUnary()]
    }
    if (this.peek().type === "op" && this.peek().value === "+") {
      this.consume()
      return this.parseUnary()
    }
    return this.parsePower()
  }

  parsePower() {
    const base = this.parsePrimary()
    if (this.peek().type === "op" && this.peek().value === "^") {
      this.consume()
      const exp = this.parseUnary()
      return ["binop", "^", base, exp]
    }
    return base
  }

  parsePrimary() {
    const tok = this.peek()
    if (tok.type === "number") {
      this.consume()
      return ["num", parseFloat(tok.value)]
    }
    if (tok.type === "ident") {
      this.consume()
      const name = tok.value
      if (this.peek().type === "lparen") {
        if (!FUNCTIONS.has(name)) throw new ParseError(`unknown function '${name}'`)
        this.consume()
        const arg = this.parseExpression()
        if (this.peek().type !== "rparen") throw new ParseError("missing closing parenthesis")
        this.consume()
        return ["func", name, arg]
      }
      if (name === "x") return ["var"]
      if (name === "pi") return ["num", Math.PI]
      if (name === "e") return ["num", Math.E]
      throw new ParseError(`unknown identifier '${name}'`)
    }
    if (tok.type === "lparen") {
      this.consume()
      const node = this.parseExpression()
      if (this.peek().type !== "rparen") throw new ParseError("missing closing parenthesis")
      this.consume()
      return node
    }
    throw new ParseError(`unexpected token '${tok.value}'`)
  }
}

function evaluate(node, x) {
  switch (node[0]) {
    case "num": return node[1]
    case "var": return x
    case "neg": return -evaluate(node[1], x)
    case "binop": {
      const a = evaluate(node[2], x)
      const b = evaluate(node[3], x)
      switch (node[1]) {
        case "+": return a + b
        case "-": return a - b
        case "*": return a * b
        case "/":
          if (b === 0) throw new MathError("Division by zero in expression")
          return a / b
        case "^": return Math.pow(a, b)
      }
    }
    case "func": {
      const arg = evaluate(node[2], x)
      switch (node[1]) {
        case "sin": return Math.sin(arg)
        case "cos": return Math.cos(arg)
        case "tan": return Math.tan(arg)
        case "asin": return Math.asin(arg)
        case "acos": return Math.acos(arg)
        case "atan": return Math.atan(arg)
        case "sinh": return Math.sinh(arg)
        case "cosh": return Math.cosh(arg)
        case "tanh": return Math.tanh(arg)
        case "ln": return Math.log(arg)
        case "log": return Math.log(arg)
        case "log10": return Math.log10(arg)
        case "exp": return Math.exp(arg)
        case "sqrt": return Math.sqrt(arg)
        case "abs": return Math.abs(arg)
      }
    }
  }
}

export default class extends Controller {
  static targets = ["expression", "lower", "upper", "intervals", "result", "method", "error"]

  calculate() {
    const expr = this.expressionTarget.value.trim()
    const lower = parseFloat(this.lowerTarget.value)
    const upper = parseFloat(this.upperTarget.value)
    let n = parseInt(this.intervalsTarget.value, 10)

    this.errorTarget.textContent = ""

    if (!expr || isNaN(lower) || isNaN(upper)) {
      this.clear()
      return
    }
    if (isNaN(n) || n < 2) n = 1000
    if (n > 100000) n = 100000
    if (n % 2 !== 0) n += 1

    let ast
    try {
      ast = new Parser(expr).parse()
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = `Invalid expression: ${e.message}`
      return
    }

    let sign = 1
    let a = lower
    let b = upper
    if (a > b) { [a, b] = [b, a]; sign = -1 }

    const h = (b - a) / n

    try {
      let total = evaluate(ast, a) + evaluate(ast, b)
      for (let i = 1; i < n; i++) {
        const x = a + i * h
        const coeff = i % 2 === 1 ? 4 : 2
        total += coeff * evaluate(ast, x)
      }
      const result = sign * (h / 3) * total

      if (!isFinite(result)) {
        this.clear()
        this.errorTarget.textContent = "Function is undefined or diverges over the interval"
        return
      }

      this.resultTarget.textContent = this.fmt(result)
      this.methodTarget.textContent = `Simpson's rule, n = ${n}`
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  clear() {
    this.resultTarget.textContent = "—"
    this.methodTarget.textContent = ""
  }

  fmt(n) {
    if (Math.abs(n) >= 1e6 || (Math.abs(n) > 0 && Math.abs(n) < 1e-4)) {
      return n.toExponential(6)
    }
    const fixed = n.toFixed(6)
    return fixed.replace(/\.?0+$/, "")
  }

  copy() {
    const expr = this.expressionTarget.value
    const lower = this.lowerTarget.value
    const upper = this.upperTarget.value
    const result = this.resultTarget.textContent
    navigator.clipboard.writeText(`∫[${lower}, ${upper}] ${expr} dx = ${result}`)
  }
}
