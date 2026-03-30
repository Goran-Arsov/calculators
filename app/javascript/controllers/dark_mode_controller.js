import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const html = document.documentElement
    const isDark = html.classList.toggle("dark")
    localStorage.setItem("darkMode", isDark)
  }
}
