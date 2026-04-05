import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "chevron"]

  toggle(event) {
    const button = event.currentTarget
    const panel = button.nextElementSibling
    const chevron = button.querySelector("[data-suite-stepper-target='chevron']")

    if (panel) {
      panel.classList.toggle("hidden")
      if (chevron) {
        chevron.classList.toggle("rotate-180")
      }
    }
  }
}
