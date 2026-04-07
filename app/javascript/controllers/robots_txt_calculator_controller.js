import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "userAgent", "disallowPaths", "allowPaths", "sitemapUrl", "output",
    "testRobots", "testUrl", "testResult"
  ]

  generate() {
    const agent = this.userAgentTarget.value.trim() || "*"
    const disallows = this.disallowPathsTarget.value.split("\n").map(s => s.trim()).filter(Boolean)
    const allows = this.allowPathsTarget.value.split("\n").map(s => s.trim()).filter(Boolean)
    const sitemap = this.sitemapUrlTarget.value.trim()

    let lines = [`User-agent: ${agent}`]
    disallows.forEach(p => lines.push(`Disallow: ${p}`))
    allows.forEach(p => lines.push(`Allow: ${p}`))
    if (!disallows.length && !allows.length) lines.push("Allow: /")
    if (sitemap) { lines.push(""); lines.push(`Sitemap: ${sitemap}`) }

    this.outputTarget.value = lines.join("\n") + "\n"
  }

  test() {
    const robots = this.testRobotsTarget.value
    const url = this.testUrlTarget.value.trim()

    if (!robots || !url) {
      this.testResultTarget.innerHTML = '<span class="text-gray-500">Enter robots.txt content and a URL to test.</span>'
      return
    }

    const path = this.extractPath(url)
    const rules = this.parseRobots(robots)
    const results = []

    for (const [agent, directives] of Object.entries(rules)) {
      const allowed = this.evaluate(directives, path)
      results.push({ agent, allowed })
    }

    if (results.length === 0) {
      results.push({ agent: "*", allowed: true })
    }

    let html = results.map(r => {
      const icon = r.allowed
        ? '<span class="text-green-600 font-bold">ALLOWED</span>'
        : '<span class="text-red-500 font-bold">BLOCKED</span>'
      return `<div class="flex justify-between py-2 border-b border-gray-200 dark:border-gray-700"><span class="font-mono text-sm">${r.agent}</span>${icon}</div>`
    }).join("")

    this.testResultTarget.innerHTML = `<div class="text-sm text-gray-500 mb-2">Testing path: <code class="font-mono">${path}</code></div>${html}`
  }

  extractPath(url) {
    if (url.startsWith("/")) return url
    try {
      const u = new URL(url)
      return u.pathname || "/"
    } catch { return url }
  }

  parseRobots(content) {
    const rules = {}
    let currentAgent = null

    for (const line of content.split("\n")) {
      const clean = line.replace(/#.*/, "").trim()
      if (!clean) continue
      if (clean.startsWith("User-agent:")) {
        currentAgent = clean.replace("User-agent:", "").trim()
        if (!rules[currentAgent]) rules[currentAgent] = []
      } else if (currentAgent) {
        if (clean.startsWith("Disallow:")) {
          const path = clean.replace("Disallow:", "").trim()
          if (path) rules[currentAgent].push({ type: "disallow", path })
        } else if (clean.startsWith("Allow:")) {
          const path = clean.replace("Allow:", "").trim()
          if (path) rules[currentAgent].push({ type: "allow", path })
        }
      }
    }
    return rules
  }

  evaluate(directives, path) {
    let bestMatch = null
    let bestLength = -1

    for (const d of directives) {
      if (this.pathMatches(d.path, path)) {
        if (d.path.length > bestLength || (d.path.length === bestLength && d.type === "allow")) {
          bestMatch = d
          bestLength = d.path.length
        }
      }
    }
    return !bestMatch || bestMatch.type === "allow"
  }

  pathMatches(pattern, path) {
    if (pattern.includes("*")) {
      const regex = new RegExp("^" + pattern.replace(/\*/g, ".*").replace(/\$/g, "$"))
      return regex.test(path)
    }
    return path.startsWith(pattern)
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
