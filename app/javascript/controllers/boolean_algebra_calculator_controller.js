import { Controller } from "@hotwired/stimulus"

class ParseError extends Error {}

function tokenize(input) {
  const src = input.toUpperCase()
  const tokens = []
  let i = 0
  while (i < src.length) {
    const ch = src[i]
    if (ch === " " || ch === "\t") { i++; continue }
    if (ch === "(") { tokens.push({ type: "lparen" }); i++; continue }
    if (ch === ")") { tokens.push({ type: "rparen" }); i++; continue }
    if (ch === "!") { tokens.push({ type: "not" }); i++; continue }
    if (ch === "~") { tokens.push({ type: "not" }); i++; continue }
    if (ch === "'") { tokens.push({ type: "not_post" }); i++; continue }
    if (ch === "&") { i += src.slice(i, i + 2) === "&&" ? 2 : 1; tokens.push({ type: "and" }); continue }
    if (ch === "|") { i += src.slice(i, i + 2) === "||" ? 2 : 1; tokens.push({ type: "or" }); continue }
    if (ch === "^") { tokens.push({ type: "xor" }); i++; continue }
    if (ch === "0") { tokens.push({ type: "lit", value: false }); i++; continue }
    if (ch === "1") { tokens.push({ type: "lit", value: true }); i++; continue }
    if (src.slice(i, i + 3) === "AND") { tokens.push({ type: "and" }); i += 3; continue }
    if (src.slice(i, i + 2) === "OR" && (i + 2 >= src.length || !/[A-Z0-9_]/.test(src[i + 2]))) { tokens.push({ type: "or" }); i += 2; continue }
    if (src.slice(i, i + 3) === "XOR") { tokens.push({ type: "xor" }); i += 3; continue }
    if (src.slice(i, i + 3) === "NOT") { tokens.push({ type: "not" }); i += 3; continue }
    if (/[A-Z_]/.test(ch)) {
      let start = i
      while (i < src.length && /[A-Z0-9_]/.test(src[i])) i++
      tokens.push({ type: "var", value: src.slice(start, i) })
      continue
    }
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
    const n = this.parseOr()
    if (this.peek().type !== "eof") throw new ParseError("unexpected token")
    return n
  }
  parseOr() {
    let n = this.parseXor()
    while (this.peek().type === "or") { this.consume(); n = ["or", n, this.parseXor()] }
    return n
  }
  parseXor() {
    let n = this.parseAnd()
    while (this.peek().type === "xor") { this.consume(); n = ["xor", n, this.parseAnd()] }
    return n
  }
  parseAnd() {
    let n = this.parseNot()
    while (this.peek().type === "and") { this.consume(); n = ["and", n, this.parseNot()] }
    return n
  }
  parseNot() {
    if (this.peek().type === "not") { this.consume(); return ["not", this.parseNot()] }
    return this.parsePrimary()
  }
  parsePrimary() {
    const tok = this.peek()
    if (tok.type === "lit") { this.consume(); let n = ["lit", tok.value]; while (this.peek().type === "not_post") { this.consume(); n = ["not", n] } return n }
    if (tok.type === "var") { this.consume(); let n = ["var", tok.value]; while (this.peek().type === "not_post") { this.consume(); n = ["not", n] } return n }
    if (tok.type === "lparen") {
      this.consume(); const n = this.parseOr()
      if (this.peek().type !== "rparen") throw new ParseError("missing )")
      this.consume()
      let result = n
      while (this.peek().type === "not_post") { this.consume(); result = ["not", result] }
      return result
    }
    throw new ParseError("unexpected token")
  }
}

function evaluate(node, vars) {
  switch (node[0]) {
    case "lit": return node[1]
    case "var": return !!vars[node[1]]
    case "not": return !evaluate(node[1], vars)
    case "and": return evaluate(node[1], vars) && evaluate(node[2], vars)
    case "or": return evaluate(node[1], vars) || evaluate(node[2], vars)
    case "xor": return evaluate(node[1], vars) !== evaluate(node[2], vars)
  }
  return false
}

function extractVars(node) {
  if (node[0] === "var") return [node[1]]
  if (node[0] === "lit") return []
  if (node[0] === "not") return extractVars(node[1])
  return [...new Set([...extractVars(node[1]), ...extractVars(node[2])])]
}

function simplify(node) {
  if (!node) return node
  switch (node[0]) {
    case "lit": case "var": return node
    case "not": {
      const inner = simplify(node[1])
      if (inner[0] === "not") return inner[1]
      if (inner[0] === "lit") return ["lit", !inner[1]]
      return ["not", inner]
    }
    case "and": {
      const l = simplify(node[1]), r = simplify(node[2])
      if (JSON.stringify(l) === JSON.stringify(["lit", true])) return r
      if (JSON.stringify(r) === JSON.stringify(["lit", true])) return l
      if (JSON.stringify(l) === JSON.stringify(["lit", false]) || JSON.stringify(r) === JSON.stringify(["lit", false])) return ["lit", false]
      if (JSON.stringify(l) === JSON.stringify(r)) return l
      if ((l[0] === "not" && JSON.stringify(l[1]) === JSON.stringify(r)) ||
          (r[0] === "not" && JSON.stringify(r[1]) === JSON.stringify(l))) return ["lit", false]
      return ["and", l, r]
    }
    case "or": {
      const l = simplify(node[1]), r = simplify(node[2])
      if (JSON.stringify(l) === JSON.stringify(["lit", false])) return r
      if (JSON.stringify(r) === JSON.stringify(["lit", false])) return l
      if (JSON.stringify(l) === JSON.stringify(["lit", true]) || JSON.stringify(r) === JSON.stringify(["lit", true])) return ["lit", true]
      if (JSON.stringify(l) === JSON.stringify(r)) return l
      if ((l[0] === "not" && JSON.stringify(l[1]) === JSON.stringify(r)) ||
          (r[0] === "not" && JSON.stringify(r[1]) === JSON.stringify(l))) return ["lit", true]
      return ["or", l, r]
    }
    case "xor": {
      const l = simplify(node[1]), r = simplify(node[2])
      if (JSON.stringify(l) === JSON.stringify(["lit", false])) return r
      if (JSON.stringify(r) === JSON.stringify(["lit", false])) return l
      if (JSON.stringify(l) === JSON.stringify(r)) return ["lit", false]
      return ["xor", l, r]
    }
  }
  return node
}

function astToString(node) {
  switch (node[0]) {
    case "lit": return node[1] ? "1" : "0"
    case "var": return node[1]
    case "not": {
      const inner = astToString(node[1])
      return (node[1][0] === "var" || node[1][0] === "lit") ? `NOT ${inner}` : `NOT (${inner})`
    }
    case "and": return `${wrapLower(node[1], "and")} AND ${wrapLower(node[2], "and")}`
    case "or": return `${wrapLower(node[1], "or")} OR ${wrapLower(node[2], "or")}`
    case "xor": return `${wrapLower(node[1], "xor")} XOR ${wrapLower(node[2], "xor")}`
  }
  return ""
}

function wrapLower(node, parentOp) {
  const prec = { not: 4, and: 3, xor: 2, or: 1, lit: 5, var: 5 }
  const s = astToString(node)
  return (prec[node[0]] || 0) < (prec[parentOp] || 0) ? `(${s})` : s
}

export default class extends Controller {
  static targets = ["expression", "result", "truthTable", "error"]

  calculate() {
    const expr = this.expressionTarget.value.trim()
    this.errorTarget.textContent = ""

    if (!expr) { this.clear(); return }

    try {
      const ast = new Parser(expr).parse()
      const simplified = simplify(ast)
      this.resultTarget.textContent = astToString(simplified)

      if (this.hasTruthTableTarget) {
        const vars = extractVars(ast).sort()
        if (vars.length > 8) {
          this.truthTableTarget.innerHTML = "<p class='text-sm text-gray-500'>Too many variables for truth table (max 8)</p>"
          return
        }
        const combos = 1 << vars.length
        let html = "<table class='w-full text-sm'><thead><tr>"
        vars.forEach(v => { html += `<th class='px-2 py-1 text-left font-medium'>${v}</th>` })
        html += `<th class='px-2 py-1 text-left font-medium'>Result</th></tr></thead><tbody>`
        for (let i = 0; i < combos; i++) {
          const assignment = {}
          vars.forEach((v, j) => { assignment[v] = ((i >> (vars.length - 1 - j)) & 1) === 1 })
          const result = evaluate(ast, assignment)
          html += "<tr>"
          vars.forEach(v => { html += `<td class='px-2 py-1'>${assignment[v] ? "1" : "0"}</td>` })
          html += `<td class='px-2 py-1 font-semibold ${result ? "text-green-600" : "text-red-500"}'>${result ? "1" : "0"}</td></tr>`
        }
        html += "</tbody></table>"
        this.truthTableTarget.innerHTML = html
      }
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  clear() {
    this.resultTarget.textContent = "\u2014"
    if (this.hasTruthTableTarget) this.truthTableTarget.innerHTML = ""
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
