import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "language", "output",
    "resultMethod", "resultUrl", "resultHeaders", "resultHasBody"
  ]

  convert() {
    const curl = this.inputTarget.value
    if (!curl || !curl.trim()) {
      this.clearResults()
      return
    }

    try {
      const parsed = this.parseCurl(curl)
      const language = this.languageTarget.value
      const code = this.generateCode(parsed, language)

      this.outputTarget.value = code
      this.resultMethodTarget.textContent = parsed.method
      this.resultUrlTarget.textContent = parsed.url ? (parsed.url.length > 50 ? parsed.url.substring(0, 50) + "..." : parsed.url) : "\u2014"
      this.resultHeadersTarget.textContent = Object.keys(parsed.headers).length
      this.resultHasBodyTarget.textContent = parsed.data ? "Yes" : "No"
    } catch (e) {
      this.outputTarget.value = "Error: " + e.message
      this.clearStats()
    }
  }

  parseCurl(input) {
    let cmd = input.replace(/\\\n\s*/g, " ").trim()
    cmd = cmd.replace(/^curl\s+/, "")

    const result = { method: "GET", url: "", headers: {}, data: null, user: null }
    const tokens = this.shellSplit(cmd)

    let i = 0
    while (i < tokens.length) {
      const token = tokens[i]
      switch (token) {
        case "-X": case "--request":
          result.method = (tokens[i + 1] || "GET").toUpperCase()
          i += 2; break
        case "-H": case "--header":
          if (tokens[i + 1] && tokens[i + 1].includes(":")) {
            const [key, ...rest] = tokens[i + 1].split(":")
            result.headers[key.trim()] = rest.join(":").trim()
          }
          i += 2; break
        case "-d": case "--data": case "--data-raw": case "--data-binary":
          result.data = tokens[i + 1]
          if (result.method === "GET") result.method = "POST"
          i += 2; break
        case "-u": case "--user":
          result.user = tokens[i + 1]
          i += 2; break
        default:
          if (token.startsWith("-")) { i += 2 }
          else {
            if (!result.url) result.url = token.replace(/^['"]|['"]$/g, "")
            i += 1
          }
      }
    }
    return result
  }

  shellSplit(line) {
    const tokens = []
    let current = ""
    let inSingle = false, inDouble = false, escaped = false

    for (const c of line) {
      if (escaped) { current += c; escaped = false; continue }
      if (c === "\\") { escaped = true; continue }
      if (c === "'" && !inDouble) { inSingle = !inSingle; continue }
      if (c === '"' && !inSingle) { inDouble = !inDouble; continue }
      if (/\s/.test(c) && !inSingle && !inDouble) {
        if (current) { tokens.push(current); current = "" }
        continue
      }
      current += c
    }
    if (current) tokens.push(current)
    return tokens
  }

  generateCode(p, lang) {
    switch (lang) {
      case "python": return this.genPython(p)
      case "javascript": return this.genJavascript(p)
      case "ruby": return this.genRuby(p)
      case "php": return this.genPhp(p)
      default: return this.genPython(p)
    }
  }

  genPython(p) {
    let lines = ["import requests", ""]
    const headers = Object.entries(p.headers)
    if (headers.length) {
      lines.push("headers = {")
      headers.forEach(([k, v]) => lines.push(`    "${k}": "${v}",`))
      lines.push("}")
      lines.push("")
    }
    const args = [`"${p.url}"`]
    if (headers.length) args.push("headers=headers")
    if (p.data) args.push(`data='${p.data}'`)
    if (p.user) {
      const [u, pw] = p.user.split(":", 2)
      args.push(`auth=("${u}", "${pw || ""}")`)
    }
    lines.push(`response = requests.${p.method.toLowerCase()}(${args.join(", ")})`)
    lines.push("print(response.status_code)")
    lines.push("print(response.text)")
    return lines.join("\n")
  }

  genJavascript(p) {
    let lines = []
    const headers = Object.entries(p.headers)
    if (p.data || headers.length || p.method !== "GET") {
      lines.push("const options = {")
      lines.push(`  method: '${p.method}',`)
      if (headers.length) {
        lines.push("  headers: {")
        headers.forEach(([k, v]) => lines.push(`    '${k}': '${v}',`))
        lines.push("  },")
      }
      if (p.data) lines.push(`  body: '${p.data}',`)
      lines.push("};", "")
      lines.push(`const response = await fetch('${p.url}', options);`)
    } else {
      lines.push(`const response = await fetch('${p.url}');`)
    }
    lines.push("const data = await response.text();")
    lines.push("console.log(data);")
    return lines.join("\n")
  }

  genRuby(p) {
    let lines = ["require 'net/http'", "require 'uri'", ""]
    lines.push(`uri = URI.parse('${p.url}')`)
    lines.push("http = Net::HTTP.new(uri.host, uri.port)")
    if (p.url.startsWith("https")) lines.push("http.use_ssl = true")
    lines.push("")
    const klassMap = { POST: "Post", PUT: "Put", PATCH: "Patch", DELETE: "Delete" }
    const klass = klassMap[p.method] || "Get"
    lines.push(`request = Net::HTTP::${klass}.new(uri.request_uri)`)
    Object.entries(p.headers).forEach(([k, v]) => lines.push(`request['${k}'] = '${v}'`))
    if (p.data) lines.push(`request.body = '${p.data}'`)
    if (p.user) {
      const [u, pw] = p.user.split(":", 2)
      lines.push(`request.basic_auth('${u}', '${pw || ""}')`)
    }
    lines.push("", "response = http.request(request)")
    lines.push("puts response.code")
    lines.push("puts response.body")
    return lines.join("\n")
  }

  genPhp(p) {
    let lines = ["<?php", ""]
    lines.push("$ch = curl_init();")
    lines.push(`curl_setopt($ch, CURLOPT_URL, '${p.url}');`)
    lines.push("curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);")
    if (p.method !== "GET") lines.push(`curl_setopt($ch, CURLOPT_CUSTOMREQUEST, '${p.method}');`)
    const headers = Object.entries(p.headers)
    if (headers.length) {
      lines.push("curl_setopt($ch, CURLOPT_HTTPHEADER, [")
      headers.forEach(([k, v]) => lines.push(`    '${k}: ${v}',`))
      lines.push("]);")
    }
    if (p.data) lines.push(`curl_setopt($ch, CURLOPT_POSTFIELDS, '${p.data}');`)
    if (p.user) lines.push(`curl_setopt($ch, CURLOPT_USERPWD, '${p.user}');`)
    lines.push("", "$response = curl_exec($ch);")
    lines.push("curl_close($ch);")
    lines.push("echo $response;")
    return lines.join("\n")
  }

  clearStats() {
    this.resultMethodTarget.textContent = "\u2014"
    this.resultUrlTarget.textContent = "\u2014"
    this.resultHeadersTarget.textContent = "\u2014"
    this.resultHasBodyTarget.textContent = "\u2014"
  }

  clearResults() {
    this.outputTarget.value = ""
    this.clearStats()
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
