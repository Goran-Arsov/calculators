import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "xmlInput", "jsonOutput",
    "resultStatus", "resultRootElement", "resultElements", "resultAttributes"
  ]

  connect() {
    this._debounceTimer = null
  }

  calculate() {
    clearTimeout(this._debounceTimer)
    this._debounceTimer = setTimeout(() => this.doConvert(), 300)
  }

  convert() {
    this.doConvert()
  }

  doConvert() {
    const xml = this.xmlInputTarget.value
    if (!xml || !xml.trim()) {
      this.clearResults()
      return
    }

    try {
      const parser = new DOMParser()
      const doc = parser.parseFromString(xml, "application/xml")
      const errorNode = doc.querySelector("parsererror")

      if (errorNode) {
        const errorText = errorNode.textContent.split("\n")[0]
        this.showError("Invalid XML: " + errorText)
        return
      }

      const root = doc.documentElement
      const hash = {}
      hash[root.nodeName] = this.elementToObject(root)

      const json = JSON.stringify(hash, null, 2)
      this.jsonOutputTarget.value = json

      const elementCount = this.countElements(root)
      const attributeCount = this.countAttributes(root)

      this.resultStatusTarget.textContent = "Valid XML"
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.resultRootElementTarget.textContent = root.nodeName
      this.resultElementsTarget.textContent = elementCount
      this.resultAttributesTarget.textContent = attributeCount
    } catch (e) {
      this.showError("Error: " + e.message)
    }
  }

  elementToObject(element) {
    const result = {}

    // Attributes with @ prefix
    for (let i = 0; i < element.attributes.length; i++) {
      const attr = element.attributes[i]
      result["@" + attr.name] = attr.value
    }

    // Group child elements by name
    const childrenByName = {}
    for (let i = 0; i < element.childNodes.length; i++) {
      const child = element.childNodes[i]
      if (child.nodeType === Node.ELEMENT_NODE) {
        if (!childrenByName[child.nodeName]) {
          childrenByName[child.nodeName] = []
        }
        childrenByName[child.nodeName].push(child)
      }
    }

    // Process children
    for (const name in childrenByName) {
      const children = childrenByName[name]
      if (children.length > 1) {
        result[name] = children.map(c => this.elementToObject(c))
      } else {
        result[name] = this.elementToObject(children[0])
      }
    }

    // Text content
    let text = ""
    for (let i = 0; i < element.childNodes.length; i++) {
      const child = element.childNodes[i]
      if (child.nodeType === Node.TEXT_NODE || child.nodeType === Node.CDATA_SECTION_NODE) {
        text += child.nodeValue
      }
    }
    text = text.trim()

    if (text.length > 0) {
      if (Object.keys(result).length === 0) {
        return text
      }
      result["#text"] = text
    }

    if (Object.keys(result).length === 0) {
      return ""
    }

    return result
  }

  countElements(element) {
    let count = 1
    for (let i = 0; i < element.childNodes.length; i++) {
      if (element.childNodes[i].nodeType === Node.ELEMENT_NODE) {
        count += this.countElements(element.childNodes[i])
      }
    }
    return count
  }

  countAttributes(element) {
    let count = element.attributes.length
    for (let i = 0; i < element.childNodes.length; i++) {
      if (element.childNodes[i].nodeType === Node.ELEMENT_NODE) {
        count += this.countAttributes(element.childNodes[i])
      }
    }
    return count
  }

  showError(message) {
    this.jsonOutputTarget.value = ""
    this.resultStatusTarget.textContent = message
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
    this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
    this.resultRootElementTarget.textContent = "\u2014"
    this.resultElementsTarget.textContent = "\u2014"
    this.resultAttributesTarget.textContent = "\u2014"
  }

  clearResults() {
    this.jsonOutputTarget.value = ""
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultRootElementTarget.textContent = "\u2014"
    this.resultElementsTarget.textContent = "\u2014"
    this.resultAttributesTarget.textContent = "\u2014"
  }

  copyOutput() {
    navigator.clipboard.writeText(this.jsonOutputTarget.value)
  }
}
