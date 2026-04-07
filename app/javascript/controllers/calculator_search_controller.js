import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "list"]
  static values = { calculators: Array }

  connect() {
    this.selectedIndex = -1
    this.handleClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  search() {
    const query = this.inputTarget.value.trim().toLowerCase()
    this.selectedIndex = -1

    if (query.length < 2) {
      this.hide()
      return
    }

    const matches = this.calculatorsValue.filter(c =>
      c.name.toLowerCase().includes(query) ||
      c.description.toLowerCase().includes(query) ||
      c.category.toLowerCase().includes(query)
    ).slice(0, 8)

    if (matches.length === 0) {
      this.listTarget.innerHTML = `<div class="px-4 py-3 text-sm text-gray-400 dark:text-gray-500">No calculators found</div>`
    } else {
      this.listTarget.innerHTML = matches.map((c, i) =>
        `<a href="${c.path}" class="search-option flex items-center gap-3 px-4 py-2.5 hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors cursor-pointer" data-index="${i}">
          <div class="w-8 h-8 bg-gradient-to-br from-blue-500 to-violet-600 rounded-lg flex items-center justify-center shrink-0">
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>
          </div>
          <div class="min-w-0">
            <div class="text-sm font-semibold text-gray-900 dark:text-white truncate">${c.name}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400 truncate">${c.category}</div>
          </div>
        </a>`
      ).join("")
    }

    this.show()
  }

  keydown(event) {
    const options = this.listTarget.querySelectorAll(".search-option")
    if (!options.length) return

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.selectedIndex = Math.min(this.selectedIndex + 1, options.length - 1)
      this.highlight(options)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
      this.highlight(options)
    } else if (event.key === "Enter") {
      event.preventDefault()
      if (this.dropdownTarget.classList.contains("hidden")) {
        this.search()
        var freshOptions = this.listTarget.querySelectorAll(".search-option")
        if (freshOptions.length > 0) freshOptions[0].click()
      } else if (this.selectedIndex >= 0 && options[this.selectedIndex]) {
        options[this.selectedIndex].click()
      } else if (options.length > 0) {
        options[0].click()
      }
    } else if (event.key === "Escape") {
      this.hide()
      this.inputTarget.blur()
    }
  }

  submitSearch() {
    const options = this.listTarget.querySelectorAll(".search-option")
    if (options.length > 0) {
      if (this.selectedIndex >= 0 && options[this.selectedIndex]) {
        options[this.selectedIndex].click()
      } else {
        options[0].click()
      }
    }
  }

  highlight(options) {
    options.forEach((opt, i) => {
      opt.classList.toggle("bg-blue-50", i === this.selectedIndex)
      opt.classList.toggle("dark:bg-blue-900/20", i === this.selectedIndex)
    })
  }

  show() { this.dropdownTarget.classList.remove("hidden") }
  hide() { this.dropdownTarget.classList.add("hidden") }

  clickOutside(event) {
    if (!this.element.contains(event.target)) this.hide()
  }
}
