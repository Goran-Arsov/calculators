import { Controller } from "@hotwired/stimulus"

// Persists metric/imperial preference in localStorage and auto-selects on connect.
// Usage: <select data-controller="unit-preference" data-action="change->unit-preference#save">
export default class extends Controller {
  static values = { key: { type: String, default: "calchammer_unit_system" } }

  connect() {
    const saved = localStorage.getItem(this.keyValue)
    if (saved && this.element.querySelector(`option[value="${saved}"]`)) {
      this.element.value = saved
      this.element.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  save() {
    localStorage.setItem(this.keyValue, this.element.value)
  }
}
