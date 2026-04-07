import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title", "description", "keywords", "author", "viewport", "robots",
    "ogTitle", "ogDescription", "ogImage", "ogUrl", "twitterCard",
    "titleCount", "descCount", "titleIndicator", "descIndicator",
    "htmlOutput"
  ]

  connect() {
    this.generate()
  }

  generate() {
    var title = this.titleTarget.value.trim()
    var description = this.descriptionTarget.value.trim()
    var keywords = this.keywordsTarget.value.trim()
    var author = this.authorTarget.value.trim()
    var viewport = this.viewportTarget.value.trim()
    var robots = this.robotsTarget.value.trim()
    var ogTitle = this.ogTitleTarget.value.trim() || title
    var ogDesc = this.ogDescriptionTarget.value.trim() || description
    var ogImage = this.ogImageTarget.value.trim()
    var ogUrl = this.ogUrlTarget.value.trim()
    var twitterCard = this.twitterCardTarget.value

    // Update character counts
    this.titleCountTarget.textContent = title.length + "/60"
    this.descCountTarget.textContent = description.length + "/160"

    // Title indicator
    if (title.length === 0) {
      this.titleIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-gray-300"
    } else if (title.length <= 60) {
      this.titleIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-green-500"
    } else if (title.length <= 70) {
      this.titleIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-yellow-500"
    } else {
      this.titleIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-red-500"
    }

    // Description indicator
    if (description.length === 0) {
      this.descIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-gray-300"
    } else if (description.length <= 160) {
      this.descIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-green-500"
    } else if (description.length <= 180) {
      this.descIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-yellow-500"
    } else {
      this.descIndicatorTarget.className = "inline-block w-3 h-3 rounded-full bg-red-500"
    }

    // Build HTML
    var lines = []
    if (title) lines.push("<title>" + this.escape(title) + "</title>")
    if (description) lines.push('<meta name="description" content="' + this.escape(description) + '">')
    if (keywords) lines.push('<meta name="keywords" content="' + this.escape(keywords) + '">')
    if (author) lines.push('<meta name="author" content="' + this.escape(author) + '">')
    if (viewport) lines.push('<meta name="viewport" content="' + this.escape(viewport) + '">')
    if (robots) lines.push('<meta name="robots" content="' + this.escape(robots) + '">')

    lines.push("")
    lines.push("<!-- Open Graph -->")
    lines.push('<meta property="og:title" content="' + this.escape(ogTitle) + '">')
    if (ogDesc) lines.push('<meta property="og:description" content="' + this.escape(ogDesc) + '">')
    if (ogImage) lines.push('<meta property="og:image" content="' + this.escape(ogImage) + '">')
    if (ogUrl) lines.push('<meta property="og:url" content="' + this.escape(ogUrl) + '">')
    lines.push('<meta property="og:type" content="website">')

    lines.push("")
    lines.push("<!-- Twitter Card -->")
    lines.push('<meta name="twitter:card" content="' + this.escape(twitterCard) + '">')
    lines.push('<meta name="twitter:title" content="' + this.escape(ogTitle) + '">')
    if (ogDesc) lines.push('<meta name="twitter:description" content="' + this.escape(ogDesc) + '">')
    if (ogImage) lines.push('<meta name="twitter:image" content="' + this.escape(ogImage) + '">')

    this.htmlOutputTarget.textContent = lines.join("\n")
  }

  escape(text) {
    return text.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }

  copy() {
    navigator.clipboard.writeText(this.htmlOutputTarget.textContent)
    this.element.querySelector("[data-copy-btn]").textContent = "Copied!"
    var self = this
    setTimeout(function() { self.element.querySelector("[data-copy-btn]").textContent = "Copy HTML" }, 2000)
  }
}
