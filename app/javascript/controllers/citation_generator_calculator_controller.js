import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sourceType", "authors", "title", "year", "publisher",
    "journalName", "volume", "issue", "pages", "url", "accessDate",
    "bookFields", "journalFields", "websiteFields",
    "resultApa", "resultMla", "resultChicago"
  ]

  connect() {
    this.toggleFields()
  }

  toggleFields() {
    const type = this.sourceTypeTarget.value
    this.bookFieldsTarget.classList.toggle("hidden", type !== "book")
    this.journalFieldsTarget.classList.toggle("hidden", type !== "journal")
    this.websiteFieldsTarget.classList.toggle("hidden", type !== "website")
    this.calculate()
  }

  calculate() {
    const authors = this.authorsTarget.value.trim()
    const title = this.titleTarget.value.trim()
    const year = this.yearTarget.value.trim()

    if (!authors || !title || !year) {
      this.resultApaTarget.textContent = "—"
      this.resultMlaTarget.textContent = "—"
      this.resultChicagoTarget.textContent = "—"
      return
    }

    const type = this.sourceTypeTarget.value
    const publisher = this.publisherTarget.value.trim()
    const journalName = this.journalNameTarget.value.trim()
    const volume = this.volumeTarget.value.trim()
    const issue = this.issueTarget.value.trim()
    const pages = this.pagesTarget.value.trim()
    const url = this.urlTarget.value.trim()
    const accessDate = this.accessDateTarget.value.trim()

    const authorList = authors.split(",").map(a => a.trim()).filter(a => a)

    this.resultApaTarget.textContent = this.generateApa(type, authorList, title, year, publisher, journalName, volume, issue, pages, url, accessDate)
    this.resultMlaTarget.textContent = this.generateMla(type, authorList, title, year, publisher, journalName, volume, issue, pages, url, accessDate)
    this.resultChicagoTarget.textContent = this.generateChicago(type, authorList, title, year, publisher, journalName, volume, issue, pages, url, accessDate)
  }

  formatAuthorApa(name) {
    const parts = name.trim().split(/\s+/)
    if (parts.length < 2) return name
    const last = parts[parts.length - 1]
    const initials = parts.slice(0, -1).map(p => p[0].toUpperCase() + ".").join(" ")
    return `${last}, ${initials}`
  }

  formatAuthorsApa(list) {
    const formatted = list.map(a => this.formatAuthorApa(a))
    if (formatted.length === 1) return formatted[0]
    if (formatted.length === 2) return `${formatted[0]} & ${formatted[1]}`
    return formatted.slice(0, -1).join(", ") + ", & " + formatted[formatted.length - 1]
  }

  formatAuthorMlaFirst(name) {
    const parts = name.trim().split(/\s+/)
    if (parts.length < 2) return name
    const last = parts[parts.length - 1]
    const first = parts.slice(0, -1).join(" ")
    return `${last}, ${first}`
  }

  formatAuthorsMla(list) {
    if (list.length === 1) return this.formatAuthorMlaFirst(list[0])
    if (list.length === 2) return `${this.formatAuthorMlaFirst(list[0])}, and ${list[1]}`
    return `${this.formatAuthorMlaFirst(list[0])}, et al.`
  }

  formatAuthorsChicago(list) {
    if (list.length === 1) return this.formatAuthorMlaFirst(list[0])
    if (list.length <= 3) {
      const formatted = [this.formatAuthorMlaFirst(list[0]), ...list.slice(1)]
      if (formatted.length === 2) return `${formatted[0]} and ${formatted[1]}`
      return formatted.slice(0, -1).join(", ") + ", and " + formatted[formatted.length - 1]
    }
    return `${this.formatAuthorMlaFirst(list[0])}, et al.`
  }

  generateApa(type, authors, title, year, publisher, journalName, volume, issue, pages, url, accessDate) {
    const a = this.formatAuthorsApa(authors)
    if (type === "book") {
      return `${a} (${year}). ${title}. ${publisher}.`
    } else if (type === "journal") {
      let s = `${a} (${year}). ${title}. ${journalName}`
      if (volume) s += `, ${volume}`
      if (issue) s += `(${issue})`
      if (pages) s += `, ${pages}`
      return s + "."
    } else {
      let s = `${a} (${year}). ${title}`
      if (accessDate) s += `. Retrieved ${accessDate},`
      s += ` from ${url}.`
      return s
    }
  }

  generateMla(type, authors, title, year, publisher, journalName, volume, issue, pages, url, accessDate) {
    const a = this.formatAuthorsMla(authors)
    if (type === "book") {
      return `${a}. ${title}. ${publisher}, ${year}.`
    } else if (type === "journal") {
      let s = `${a}. "${title}." ${journalName}`
      if (volume) s += `, vol. ${volume}`
      if (issue) s += `, no. ${issue}`
      s += `, ${year}`
      if (pages) s += `, pp. ${pages}`
      return s + "."
    } else {
      let s = `${a}. "${title}." Web, ${year}`
      s += `, ${url}`
      if (accessDate) s += `. Accessed ${accessDate}`
      return s + "."
    }
  }

  generateChicago(type, authors, title, year, publisher, journalName, volume, issue, pages, url, accessDate) {
    const a = this.formatAuthorsChicago(authors)
    if (type === "book") {
      return `${a}. ${title}. ${publisher}, ${year}.`
    } else if (type === "journal") {
      let s = `${a}. "${title}." ${journalName}`
      if (volume) s += ` ${volume}`
      if (issue) s += `, no. ${issue}`
      s += ` (${year})`
      if (pages) s += `: ${pages}`
      return s + "."
    } else {
      let s = `${a}. "${title}." ${year}.`
      s += ` ${url}`
      if (accessDate) s += `. Accessed ${accessDate}`
      return s + "."
    }
  }

  copy() {
    const apa = this.resultApaTarget.textContent
    const mla = this.resultMlaTarget.textContent
    const chicago = this.resultChicagoTarget.textContent
    const text = `APA 7th:\n${apa}\n\nMLA 9th:\n${mla}\n\nChicago:\n${chicago}`
    navigator.clipboard.writeText(text)
  }
}
