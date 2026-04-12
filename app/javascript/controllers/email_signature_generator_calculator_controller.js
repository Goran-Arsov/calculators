import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fullName", "jobTitle", "company", "email", "phone",
    "website", "linkedin", "twitter", "template", "primaryColor",
    "output", "preview", "error"
  ]

  generate() {
    const name = this.fullNameTarget.value.trim()
    if (!name) { this.showError("Full name is required."); return }
    this.hideError()

    const data = {
      name,
      title: this.jobTitleTarget.value.trim(),
      company: this.companyTarget.value.trim(),
      email: this.emailTarget.value.trim(),
      phone: this.phoneTarget.value.trim(),
      website: this.websiteTarget.value.trim(),
      linkedin: this.linkedinTarget.value.trim(),
      twitter: this.twitterTarget.value.trim(),
      template: this.templateTarget.value,
      color: this.primaryColorTarget.value || "#2563EB"
    }

    const html = this.buildSignature(data)
    this.outputTarget.value = html
    if (this.hasPreviewTarget) this.previewTarget.innerHTML = html
  }

  buildSignature(d) {
    switch (d.template) {
      case "minimal": return this.minimal(d)
      case "modern": return this.modern(d)
      case "colorful": return this.colorful(d)
      default: return this.professional(d)
    }
  }

  professional(d) {
    let rows = `<tr><td style="font-size:18px;font-weight:bold;color:${d.color};padding-bottom:2px;">${d.name}</td></tr>`
    if (d.title || d.company) {
      const sub = [d.title, d.company].filter(x => x).join(" | ")
      rows += `<tr><td style="font-size:13px;color:#666;padding-bottom:8px;">${sub}</td></tr>`
    }
    if (d.email) rows += `<tr><td style="font-size:12px;color:#666;padding-bottom:2px;">Email: <a href="mailto:${d.email}" style="color:${d.color};text-decoration:none;">${d.email}</a></td></tr>`
    if (d.phone) rows += `<tr><td style="font-size:12px;color:#666;padding-bottom:2px;">Phone: ${d.phone}</td></tr>`
    if (d.website) rows += `<tr><td style="font-size:12px;color:#666;padding-bottom:2px;">Web: <a href="${this.ensureProtocol(d.website)}" style="color:${d.color};text-decoration:none;">${d.website}</a></td></tr>`
    const social = this.socialLinks(d)
    if (social) rows += `<tr><td style="padding-top:6px;">${social}</td></tr>`

    return `<table cellpadding="0" cellspacing="0" border="0" style="font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#333;"><tr><td style="padding-right:15px;border-right:3px solid ${d.color};"><table cellpadding="0" cellspacing="0" border="0">${rows}</table></td></tr></table>`
  }

  minimal(d) {
    let html = `<table cellpadding="0" cellspacing="0" border="0" style="font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;font-size:13px;color:#555;">`
    html += `<tr><td style="font-weight:600;font-size:14px;color:#111;">${d.name}</td></tr>`
    if (d.title || d.company) html += `<tr><td style="color:#888;">${[d.title, d.company].filter(x => x).join(", ")}</td></tr>`
    const contact = [d.email, d.phone].filter(x => x).join(" | ")
    if (contact) html += `<tr><td style="padding-top:4px;">${contact}</td></tr>`
    html += `</table>`
    return html
  }

  modern(d) {
    let html = `<table cellpadding="0" cellspacing="0" border="0" style="font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;font-size:14px;">`
    html += `<tr><td style="padding:15px;background-color:${d.color};border-radius:8px 8px 0 0;">`
    html += `<span style="font-size:20px;font-weight:bold;color:#FFF;">${d.name}</span>`
    if (d.title) html += `<br><span style="font-size:13px;color:rgba(255,255,255,0.8);">${d.title}</span>`
    if (d.company) html += `<br><span style="font-size:13px;color:rgba(255,255,255,0.8);">${d.company}</span>`
    html += `</td></tr>`
    html += `<tr><td style="padding:12px 15px;background-color:#f8f9fa;border-radius:0 0 8px 8px;font-size:12px;color:#555;">`
    const items = [d.email, d.phone, d.website].filter(x => x)
    if (items.length) html += items.join("<br>")
    const social = this.socialLinks(d)
    if (social) html += `<br>${social}`
    html += `</td></tr></table>`
    return html
  }

  colorful(d) {
    let html = `<table cellpadding="0" cellspacing="0" border="0" style="font-family:Georgia,'Times New Roman',serif;font-size:14px;color:#333;border-left:5px solid ${d.color};padding-left:15px;">`
    html += `<tr><td style="font-size:20px;font-weight:bold;color:${d.color};">${d.name}</td></tr>`
    if (d.title || d.company) html += `<tr><td style="font-size:14px;font-style:italic;color:#777;">${[d.title, d.company].filter(x => x).join(" at ")}</td></tr>`
    const items = [d.email, d.phone, d.website].filter(x => x)
    if (items.length) html += `<tr><td style="padding-top:8px;font-size:12px;">${items.join(" &bull; ")}</td></tr>`
    const social = this.socialLinks(d)
    if (social) html += `<tr><td style="padding-top:6px;">${social}</td></tr>`
    html += `</table>`
    return html
  }

  socialLinks(d) {
    const links = []
    if (d.linkedin) links.push(`<a href="${this.ensureProtocol(d.linkedin)}" style="color:${d.color};text-decoration:none;font-size:12px;">LinkedIn</a>`)
    if (d.twitter) links.push(`<a href="${this.ensureProtocol(d.twitter)}" style="color:${d.color};text-decoration:none;font-size:12px;">Twitter</a>`)
    return links.join(" | ")
  }

  ensureProtocol(url) {
    return url.startsWith("http://") || url.startsWith("https://") ? url : `https://${url}`
  }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  copy() {
    const text = this.outputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) { const o = btn.textContent; btn.textContent = "Copied!"; setTimeout(() => { btn.textContent = o }, 1500) }
    })
  }
}
