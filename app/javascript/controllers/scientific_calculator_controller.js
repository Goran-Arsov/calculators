import { Controller } from "@hotwired/stimulus"

// Scientific calculator with tokenizer + shunting-yard + RPN evaluator.
// Mirrors app/calculators/math/scientific_calculator.rb for consistency.
export default class extends Controller {
  static targets = ["display", "expression", "history", "modeLabel", "memoryIndicator"]

  connect() {
    this.expression = ""
    this.lastResult = null
    this.memory = 0
    this.mode = "rad" // "rad" or "deg"
    this.isSecond = false
    this.render()
  }

  // --- Input handlers ---

  press(event) {
    const value = event.currentTarget.dataset.value
    const type = event.currentTarget.dataset.type

    switch (type) {
      case "digit":
      case "operator":
      case "paren":
      case "constant":
      case "function":
        this.expression += value
        break
      case "postfix":
        this.expression += value
        break
      case "clear":
        this.expression = ""
        this.lastResult = null
        this.displayTarget.textContent = "0"
        break
      case "clearEntry":
        this.expression = this.expression.slice(0, -1)
        break
      case "equals":
        this.evaluate()
        return
      case "toggleSign":
        this.expression = `-(${this.expression})`
        break
      case "percent":
        this.expression += "/100"
        break
      case "ans":
        if (this.lastResult !== null) this.expression += this.lastResult.toString()
        break
      case "mode":
        this.mode = this.mode === "rad" ? "deg" : "rad"
        break
      case "memoryClear":
        this.memory = 0
        break
      case "memoryRecall":
        this.expression += this.memory.toString()
        break
      case "memoryAdd":
        if (this.lastResult !== null) this.memory += this.lastResult
        break
      case "memorySubtract":
        if (this.lastResult !== null) this.memory -= this.lastResult
        break
    }

    this.render()
  }

  render() {
    if (this.hasExpressionTarget) {
      this.expressionTarget.textContent = this.expression || "\u00A0"
    }
    if (this.hasModeLabelTarget) {
      this.modeLabelTarget.textContent = this.mode.toUpperCase()
    }
    if (this.hasMemoryIndicatorTarget) {
      this.memoryIndicatorTarget.textContent = this.memory !== 0 ? "M" : ""
    }
  }

  evaluate() {
    if (!this.expression) return

    try {
      const tokens = this.tokenize(this.expression)
      const rpn = this.toRPN(tokens)
      const result = this.evaluateRPN(rpn)

      if (!isFinite(result)) throw new Error("Result is not finite")

      const formatted = this.formatResult(result)

      if (this.hasHistoryTarget) {
        this.historyTarget.textContent = `${this.expression} =`
      }
      this.displayTarget.textContent = formatted
      this.lastResult = result
      this.expression = formatted
    } catch (e) {
      this.displayTarget.textContent = "Error"
      this.expression = ""
      this.lastResult = null
    }

    this.render()
  }

  // --- Tokenizer ---
  tokenize(expr) {
    const s = expr.replace(/\s+/g, "")
    const tokens = []
    let i = 0

    while (i < s.length) {
      const c = s[i]

      if (/[\d.]/.test(c)) {
        const match = s.slice(i).match(/^\d*\.?\d+(?:[eE][+-]?\d+)?/)
        if (!match) throw new Error(`Invalid number at ${i}`)
        tokens.push({ type: "number", value: parseFloat(match[0]) })
        i += match[0].length
      } else if (/[a-zA-Z]/.test(c)) {
        const match = s.slice(i).match(/^[a-zA-Z]+/)
        const name = match[0].toLowerCase()
        if (["sin", "cos", "tan", "asin", "acos", "atan", "log", "ln", "sqrt", "exp", "abs"].includes(name)) {
          tokens.push({ type: "function", value: name })
        } else if (name === "pi") {
          tokens.push({ type: "number", value: Math.PI })
        } else if (name === "e") {
          tokens.push({ type: "number", value: Math.E })
        } else {
          throw new Error(`Unknown identifier: ${name}`)
        }
        i += match[0].length
      } else if ("+-*/^%".includes(c)) {
        if (c === "-" && this.unaryContext(tokens)) {
          tokens.push({ type: "operator", value: "neg", precedence: 4, rightAssoc: true, unary: true })
        } else if (c === "+" && this.unaryContext(tokens)) {
          // skip unary plus
        } else {
          tokens.push(this.operatorToken(c))
        }
        i++
      } else if (c === "(") {
        tokens.push({ type: "lparen" })
        i++
      } else if (c === ")") {
        tokens.push({ type: "rparen" })
        i++
      } else if (c === "!") {
        tokens.push({ type: "operator", value: "fact", precedence: 5, rightAssoc: false, postfix: true })
        i++
      } else {
        throw new Error(`Unexpected character: ${c}`)
      }
    }

    return tokens
  }

  unaryContext(tokens) {
    if (tokens.length === 0) return true
    const last = tokens[tokens.length - 1]
    if (last.type === "operator" && !last.postfix) return true
    if (last.type === "lparen") return true
    return false
  }

  operatorToken(op) {
    const map = {
      "+": { type: "operator", value: "+", precedence: 1, rightAssoc: false },
      "-": { type: "operator", value: "-", precedence: 1, rightAssoc: false },
      "*": { type: "operator", value: "*", precedence: 2, rightAssoc: false },
      "/": { type: "operator", value: "/", precedence: 2, rightAssoc: false },
      "%": { type: "operator", value: "%", precedence: 2, rightAssoc: false },
      "^": { type: "operator", value: "^", precedence: 3, rightAssoc: true }
    }
    return map[op]
  }

  // --- Shunting-yard ---
  toRPN(tokens) {
    const output = []
    const stack = []

    for (const tok of tokens) {
      if (tok.type === "number") {
        output.push(tok)
      } else if (tok.type === "function") {
        stack.push(tok)
      } else if (tok.type === "operator") {
        if (tok.postfix) {
          output.push(tok)
        } else {
          while (stack.length > 0) {
            const top = stack[stack.length - 1]
            if (top.type !== "operator") break
            if (!top.rightAssoc && top.precedence >= tok.precedence) {
              output.push(stack.pop())
            } else if (top.rightAssoc && top.precedence > tok.precedence) {
              output.push(stack.pop())
            } else {
              break
            }
          }
          stack.push(tok)
        }
      } else if (tok.type === "lparen") {
        stack.push(tok)
      } else if (tok.type === "rparen") {
        while (stack.length > 0 && stack[stack.length - 1].type !== "lparen") {
          output.push(stack.pop())
        }
        if (stack.length === 0) throw new Error("Mismatched parentheses")
        stack.pop()
        if (stack.length > 0 && stack[stack.length - 1].type === "function") {
          output.push(stack.pop())
        }
      }
    }

    while (stack.length > 0) {
      const top = stack.pop()
      if (top.type === "lparen") throw new Error("Mismatched parentheses")
      output.push(top)
    }

    return output
  }

  // --- RPN evaluator ---
  evaluateRPN(rpn) {
    const stack = []

    for (const tok of rpn) {
      if (tok.type === "number") {
        stack.push(tok.value)
      } else if (tok.type === "operator") {
        if (tok.value === "neg") {
          const a = stack.pop()
          stack.push(-a)
        } else if (tok.value === "fact") {
          const a = stack.pop()
          stack.push(this.factorial(a))
        } else {
          const b = stack.pop()
          const a = stack.pop()
          stack.push(this.applyOperator(tok.value, a, b))
        }
      } else if (tok.type === "function") {
        const a = stack.pop()
        stack.push(this.applyFunction(tok.value, a))
      }
    }

    if (stack.length !== 1) throw new Error("Invalid expression")
    return stack[0]
  }

  applyOperator(op, a, b) {
    switch (op) {
      case "+": return a + b
      case "-": return a - b
      case "*": return a * b
      case "/":
        if (b === 0) throw new Error("Division by zero")
        return a / b
      case "%":
        if (b === 0) throw new Error("Modulo by zero")
        return a % b
      case "^": return Math.pow(a, b)
    }
  }

  applyFunction(name, arg) {
    const toRad = (v) => this.mode === "deg" ? v * Math.PI / 180 : v
    const fromRad = (v) => this.mode === "deg" ? v * 180 / Math.PI : v

    switch (name) {
      case "sin": return Math.sin(toRad(arg))
      case "cos": return Math.cos(toRad(arg))
      case "tan": return Math.tan(toRad(arg))
      case "asin": return fromRad(Math.asin(arg))
      case "acos": return fromRad(Math.acos(arg))
      case "atan": return fromRad(Math.atan(arg))
      case "log": return Math.log10(arg)
      case "ln": return Math.log(arg)
      case "sqrt": return Math.sqrt(arg)
      case "exp": return Math.exp(arg)
      case "abs": return Math.abs(arg)
    }
  }

  factorial(n) {
    if (n < 0 || n !== Math.floor(n)) throw new Error("Factorial requires non-negative integer")
    if (n > 170) throw new Error("Factorial too large")
    let result = 1
    for (let i = 2; i <= n; i++) result *= i
    return result
  }

  formatResult(value) {
    if (Number.isInteger(value) && Math.abs(value) < 1e15) {
      return value.toString()
    }
    if (Math.abs(value) >= 1e15 || (Math.abs(value) < 1e-6 && value !== 0)) {
      return value.toExponential(10).replace(/\.?0+e/, "e")
    }
    // 10 significant digits, trim trailing zeros
    const precision = value.toPrecision(10)
    return parseFloat(precision).toString()
  }

  // --- Keyboard support ---
  handleKeydown(event) {
    // Don't hijack typing in form fields elsewhere on the page (e.g. the navbar search).
    const tag = event.target.tagName
    if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT" || event.target.isContentEditable) return

    const key = event.key

    if (/^[\d.+\-*/^%()]$/.test(key)) {
      this.expression += key
      this.render()
      event.preventDefault()
    } else if (key === "Enter" || key === "=") {
      this.evaluate()
      event.preventDefault()
    } else if (key === "Backspace") {
      this.expression = this.expression.slice(0, -1)
      this.render()
      event.preventDefault()
    } else if (key === "Escape") {
      this.expression = ""
      this.displayTarget.textContent = "0"
      this.render()
      event.preventDefault()
    }
  }
}
