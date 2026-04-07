import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hOffset", "vOffset", "blur", "spread", "color", "inset",
    "hOffsetValue", "vOffsetValue", "blurValue", "spreadValue",
    "preview", "cssOutput", "shadowsList"
  ]

  connect() {
    this.shadows = [
      { hOffset: 5, vOffset: 5, blur: 15, spread: 0, color: "#00000040", inset: false }
    ]
    this.currentIndex = 0
    this.renderShadowsList()
    this.loadShadow(0)
    this.generate()
  }

  updateHOffset() {
    var val = parseInt(this.hOffsetTarget.value) || 0
    this.hOffsetValueTarget.textContent = val + "px"
    this.shadows[this.currentIndex].hOffset = val
    this.generate()
  }

  updateVOffset() {
    var val = parseInt(this.vOffsetTarget.value) || 0
    this.vOffsetValueTarget.textContent = val + "px"
    this.shadows[this.currentIndex].vOffset = val
    this.generate()
  }

  updateBlur() {
    var val = parseInt(this.blurTarget.value) || 0
    this.blurValueTarget.textContent = val + "px"
    this.shadows[this.currentIndex].blur = val
    this.generate()
  }

  updateSpread() {
    var val = parseInt(this.spreadTarget.value) || 0
    this.spreadValueTarget.textContent = val + "px"
    this.shadows[this.currentIndex].spread = val
    this.generate()
  }

  updateColor() {
    this.shadows[this.currentIndex].color = this.colorTarget.value
    this.generate()
  }

  updateInset() {
    this.shadows[this.currentIndex].inset = this.insetTarget.checked
    this.generate()
  }

  addShadow() {
    this.shadows.push({ hOffset: 0, vOffset: 4, blur: 10, spread: 0, color: "#00000030", inset: false })
    this.currentIndex = this.shadows.length - 1
    this.loadShadow(this.currentIndex)
    this.renderShadowsList()
    this.generate()
  }

  removeShadow(event) {
    var index = parseInt(event.currentTarget.dataset.index)
    if (this.shadows.length <= 1) return
    this.shadows.splice(index, 1)
    if (this.currentIndex >= this.shadows.length) {
      this.currentIndex = this.shadows.length - 1
    }
    this.loadShadow(this.currentIndex)
    this.renderShadowsList()
    this.generate()
  }

  selectShadow(event) {
    var index = parseInt(event.currentTarget.dataset.index)
    this.currentIndex = index
    this.loadShadow(index)
    this.renderShadowsList()
  }

  loadShadow(index) {
    var s = this.shadows[index]
    this.hOffsetTarget.value = s.hOffset
    this.vOffsetTarget.value = s.vOffset
    this.blurTarget.value = s.blur
    this.spreadTarget.value = s.spread
    this.colorTarget.value = s.color.length === 7 ? s.color : s.color.substring(0, 7)
    this.insetTarget.checked = s.inset
    this.hOffsetValueTarget.textContent = s.hOffset + "px"
    this.vOffsetValueTarget.textContent = s.vOffset + "px"
    this.blurValueTarget.textContent = s.blur + "px"
    this.spreadValueTarget.textContent = s.spread + "px"
  }

  renderShadowsList() {
    if (!this.hasShadowsListTarget) return
    var html = ""
    for (var i = 0; i < this.shadows.length; i++) {
      var s = this.shadows[i]
      var active = i === this.currentIndex
      var label = (s.inset ? "inset " : "") + s.hOffset + "px " + s.vOffset + "px " + s.blur + "px " + s.spread + "px"
      html += '<div class="flex items-center gap-2 p-2 rounded-lg cursor-pointer ' +
        (active ? 'bg-blue-50 dark:bg-blue-900/30 border border-blue-200 dark:border-blue-700' : 'bg-gray-50 dark:bg-gray-800 hover:bg-gray-100 dark:hover:bg-gray-700') + '">'
      html += '<div class="w-4 h-4 rounded border border-gray-300 dark:border-gray-600" style="background-color: ' + s.color + '"></div>'
      html += '<span class="flex-1 text-xs font-mono text-gray-700 dark:text-gray-300" data-action="click->css-box-shadow-calculator#selectShadow" data-index="' + i + '">' + label + '</span>'
      if (this.shadows.length > 1) {
        html += '<button data-action="click->css-box-shadow-calculator#removeShadow" data-index="' + i + '" class="text-red-400 hover:text-red-600 text-xs">&times;</button>'
      }
      html += '</div>'
    }
    this.shadowsListTarget.innerHTML = html
  }

  generate() {
    var parts = []
    for (var i = 0; i < this.shadows.length; i++) {
      var s = this.shadows[i]
      var val = ""
      if (s.inset) val += "inset "
      val += s.hOffset + "px " + s.vOffset + "px " + s.blur + "px " + s.spread + "px " + s.color
      parts.push(val)
    }
    var cssValue = parts.join(",\n    ")
    var fullCss = "box-shadow: " + cssValue + ";"
    this.previewTarget.style.boxShadow = parts.join(", ")
    this.cssOutputTarget.textContent = fullCss
  }

  copy() {
    navigator.clipboard.writeText(this.cssOutputTarget.textContent)
    this.element.querySelector("[data-copy-btn]").textContent = "Copied!"
    var self = this
    setTimeout(function() { self.element.querySelector("[data-copy-btn]").textContent = "Copy CSS" }, 2000)
  }
}
