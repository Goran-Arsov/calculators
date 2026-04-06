import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["htmlInput", "markdownOutput", "resultInputLen", "resultOutputLen"]

  convert() {
    const html = this.htmlInputTarget.value
    if (!html.trim()) {
      this.markdownOutputTarget.value = ""
      this.resultInputLenTarget.textContent = "--"
      this.resultOutputLenTarget.textContent = "--"
      return
    }

    const md = this.htmlToMarkdown(html)
    this.markdownOutputTarget.value = md
    this.resultInputLenTarget.textContent = html.length
    this.resultOutputLenTarget.textContent = md.length
  }

  htmlToMarkdown(html) {
    const doc = new DOMParser().parseFromString(html, "text/html")
    const result = this.convertNode(doc.body)
    return result.replace(/\n{3,}/g, "\n\n").trim() + "\n"
  }

  convertNode(node) {
    let result = ""
    for (const child of node.childNodes) {
      if (child.nodeType === Node.TEXT_NODE) {
        result += child.textContent
      } else if (child.nodeType === Node.ELEMENT_NODE) {
        result += this.convertElement(child)
      }
    }
    return result
  }

  convertElement(el) {
    const tag = el.tagName.toLowerCase()
    const inner = () => this.convertNode(el).trim()

    switch (tag) {
      case "h1": return `\n# ${inner()}\n\n`
      case "h2": return `\n## ${inner()}\n\n`
      case "h3": return `\n### ${inner()}\n\n`
      case "h4": return `\n#### ${inner()}\n\n`
      case "h5": return `\n##### ${inner()}\n\n`
      case "h6": return `\n###### ${inner()}\n\n`
      case "p": return `\n${inner()}\n\n`
      case "br": return "  \n"
      case "hr": return "\n---\n\n"
      case "strong":
      case "b":
        return `**${inner()}**`
      case "em":
      case "i":
        return `*${inner()}*`
      case "del":
      case "s":
      case "strike":
        return `~~${inner()}~~`
      case "code":
        if (el.parentElement && el.parentElement.tagName.toLowerCase() === "pre") {
          return this.convertNode(el)
        }
        return `\`${inner()}\``
      case "pre": {
        const codeEl = el.querySelector("code")
        if (codeEl) {
          const lang = (codeEl.className || "").replace(/^language-/, "").trim()
          return `\n\`\`\`${lang}\n${this.convertNode(codeEl).trim()}\n\`\`\`\n\n`
        }
        return `\n\`\`\`\n${inner()}\n\`\`\`\n\n`
      }
      case "a": {
        const href = el.getAttribute("href") || ""
        return `[${inner()}](${href})`
      }
      case "img": {
        const alt = el.getAttribute("alt") || ""
        const src = el.getAttribute("src") || ""
        return `![${alt}](${src})`
      }
      case "ul": {
        const items = Array.from(el.querySelectorAll(":scope > li"))
          .map(li => `- ${this.convertNode(li).trim()}`)
        return `\n${items.join("\n")}\n\n`
      }
      case "ol": {
        const items = Array.from(el.querySelectorAll(":scope > li"))
          .map((li, idx) => `${idx + 1}. ${this.convertNode(li).trim()}`)
        return `\n${items.join("\n")}\n\n`
      }
      case "li":
        return this.convertNode(el)
      case "blockquote": {
        const lines = inner().split("\n")
        return `\n${lines.map(l => `> ${l}`).join("\n")}\n\n`
      }
      case "table":
        return this.convertTable(el)
      default:
        return this.convertNode(el)
    }
  }

  convertTable(table) {
    const rows = Array.from(table.querySelectorAll("tr"))
    if (rows.length === 0) return ""

    const mdRows = rows.map(tr => {
      const cells = Array.from(tr.querySelectorAll("th, td"))
        .map(cell => this.convertNode(cell).trim())
      return `| ${cells.join(" | ")} |`
    })

    if (mdRows.length > 1) {
      const colCount = rows[0].querySelectorAll("th, td").length
      const sep = `| ${Array(colCount).fill("---").join(" | ")} |`
      mdRows.splice(1, 0, sep)
    }

    return `\n${mdRows.join("\n")}\n\n`
  }

  copyMarkdown() {
    const text = this.markdownOutputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector('[data-action*="copyMarkdown"]')
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }
}
