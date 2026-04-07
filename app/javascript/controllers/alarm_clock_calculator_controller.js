import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Main page is just a landing page with a "Set Alarm" link.
    // All alarm logic lives on the active alarm page.
  }
}
