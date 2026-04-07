import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "ogTitle", "ogDescription", "ogUrl", "ogImage", "ogType", "ogSiteName",
    "twitterCard", "twitterTitle", "twitterDescription", "twitterImage",
    "previewFacebook", "previewTwitter", "metaOutput",
    "resultScore", "resultTitleLength", "resultDescLength"
  ]

  preview() {
    const tags = {
      "og:title": this.ogTitleTarget.value,
      "og:description": this.ogDescriptionTarget.value,
      "og:url": this.ogUrlTarget.value,
      "og:image": this.ogImageTarget.value,
      "og:type": this.ogTypeTarget.value,
      "og:site_name": this.ogSiteNameTarget.value,
      "twitter:card": this.twitterCardTarget.value,
      "twitter:title": this.twitterTitleTarget.value || this.ogTitleTarget.value,
      "twitter:description": this.twitterDescriptionTarget.value || this.ogDescriptionTarget.value,
      "twitter:image": this.twitterImageTarget.value || this.ogImageTarget.value
    }

    // Facebook preview
    this.previewFacebookTarget.innerHTML = this.renderFacebookCard(tags)

    // Twitter preview
    this.previewTwitterTarget.innerHTML = this.renderTwitterCard(tags)

    // Meta HTML output
    this.metaOutputTarget.value = this.generateMetaHtml(tags)

    // Stats
    const required = ["og:title", "og:description", "og:url", "og:type"]
    const recommended = ["og:image", "og:site_name", "twitter:card", "twitter:title", "twitter:description", "twitter:image"]
    const total = required.length + recommended.length
    const filled = [...required, ...recommended].filter(k => tags[k] && tags[k].trim()).length
    const score = Math.round((filled / total) * 100)

    this.resultScoreTarget.textContent = score + "%"
    this.resultTitleLengthTarget.textContent = (tags["og:title"] || "").length
    this.resultDescLengthTarget.textContent = (tags["og:description"] || "").length
  }

  renderFacebookCard(tags) {
    const title = this.escapeHtml(tags["og:title"] || "Page Title")
    const desc = this.escapeHtml(tags["og:description"] || "Page description will appear here...")
    const url = this.escapeHtml(tags["og:url"] || "example.com")
    const siteName = this.escapeHtml(tags["og:site_name"] || "")
    const image = tags["og:image"]

    const domain = this.extractDomain(url)

    return `<div class="border border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden max-w-md">
      ${image ? `<div class="bg-gray-200 dark:bg-gray-700 h-52 flex items-center justify-center overflow-hidden"><img src="${this.escapeHtml(image)}" class="w-full h-full object-cover" onerror="this.parentElement.innerHTML='<span class=\\'text-gray-400 text-sm\\'>Image preview</span>'" /></div>` : `<div class="bg-gray-200 dark:bg-gray-700 h-52 flex items-center justify-center"><span class="text-gray-400 text-sm">No image set</span></div>`}
      <div class="p-3 bg-gray-50 dark:bg-gray-800">
        <p class="text-xs text-gray-500 uppercase">${domain}</p>
        <p class="font-semibold text-gray-900 dark:text-white text-sm mt-1 line-clamp-2">${title}</p>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-1 line-clamp-2">${desc}</p>
      </div>
    </div>`
  }

  renderTwitterCard(tags) {
    const title = this.escapeHtml(tags["twitter:title"] || tags["og:title"] || "Page Title")
    const desc = this.escapeHtml(tags["twitter:description"] || tags["og:description"] || "Page description...")
    const image = tags["twitter:image"] || tags["og:image"]
    const url = tags["og:url"] || ""
    const domain = this.extractDomain(url)

    return `<div class="border border-gray-300 dark:border-gray-600 rounded-2xl overflow-hidden max-w-md">
      ${image ? `<div class="bg-gray-200 dark:bg-gray-700 h-52 flex items-center justify-center overflow-hidden"><img src="${this.escapeHtml(image)}" class="w-full h-full object-cover" onerror="this.parentElement.innerHTML='<span class=\\'text-gray-400 text-sm\\'>Image preview</span>'" /></div>` : `<div class="bg-gray-200 dark:bg-gray-700 h-52 flex items-center justify-center"><span class="text-gray-400 text-sm">No image set</span></div>`}
      <div class="p-3 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
        <p class="text-xs text-gray-500">${domain}</p>
        <p class="font-bold text-gray-900 dark:text-white text-sm mt-0.5">${title}</p>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-0.5 line-clamp-2">${desc}</p>
      </div>
    </div>`
  }

  generateMetaHtml(tags) {
    const lines = []
    for (const [key, value] of Object.entries(tags)) {
      if (!value || !value.trim()) continue
      if (key.startsWith("twitter:")) {
        lines.push(`<meta name="${key}" content="${this.escapeHtml(value)}" />`)
      } else {
        lines.push(`<meta property="${key}" content="${this.escapeHtml(value)}" />`)
      }
    }
    return lines.join("\n")
  }

  extractDomain(url) {
    try {
      if (url.includes("://")) return new URL(url).hostname
      return url.split("/")[0] || "example.com"
    } catch { return "example.com" }
  }

  escapeHtml(str) {
    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;")
  }

  clearResults() {
    this.previewFacebookTarget.innerHTML = ""
    this.previewTwitterTarget.innerHTML = ""
    this.metaOutputTarget.value = ""
    this.resultScoreTarget.textContent = "\u2014"
    this.resultTitleLengthTarget.textContent = "\u2014"
    this.resultDescLengthTarget.textContent = "\u2014"
  }

  copyMeta() {
    navigator.clipboard.writeText(this.metaOutputTarget.value)
  }
}
