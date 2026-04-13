import { Controller } from "@hotwired/stimulus"

// Copies the text in a clicked element's data-body attribute to the
// clipboard and shows a brief in-place "Copied!" label. Used on the admin
// notes index (one button per card) and on the admin note show page.
//
// Action name is `write` rather than `copy` so the global `#copy` click
// handler in application.js doesn't also insert its own "Copied!" sibling.
export default class extends Controller {
  async write(event) {
    const btn = event.currentTarget
    const body = btn.dataset.body
    if (body == null) return

    try {
      await navigator.clipboard.writeText(body)
    } catch (err) {
      console.error("[notes-clipboard] copy failed", err)
      return
    }

    const original = btn.dataset.originalLabel || btn.textContent
    btn.dataset.originalLabel = original
    btn.textContent = "Copied!"
    btn.classList.add("text-emerald-600", "dark:text-emerald-400")

    clearTimeout(btn.dataset.copyTimeoutId)
    const id = setTimeout(() => {
      btn.textContent = original
      btn.classList.remove("text-emerald-600", "dark:text-emerald-400")
      delete btn.dataset.copyTimeoutId
    }, 1500)
    btn.dataset.copyTimeoutId = id
  }
}
