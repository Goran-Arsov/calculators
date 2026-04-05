import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["upCount", "downCount", "upButton", "downButton", "prompt"]
  static values = { slug: String }

  connect() {
    this.fetchRatings()
    this.checkUserVote()
  }

  thumbsUp() {
    if (this.hasVoted()) return
    this.submitRating("up")
  }

  thumbsDown() {
    if (this.hasVoted()) return
    this.submitRating("down")
  }

  async submitRating(direction) {
    // Optimistic UI update
    this.saveVote(direction)
    this.updateUI()

    try {
      const response = await fetch(`/api/ratings/${encodeURIComponent(this.slugValue)}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ direction })
      })
      const data = await response.json()
      this.upCountTarget.textContent = data.up
      this.downCountTarget.textContent = data.down
    } catch (e) {
      // Server unavailable — keep optimistic update
    }

    if (typeof gtag === "function") {
      gtag("event", "calculator_rating", {
        calculator: this.slugValue,
        rating: direction
      })
    }
  }

  async fetchRatings() {
    try {
      const response = await fetch(`/api/ratings/${encodeURIComponent(this.slugValue)}`)
      const data = await response.json()
      this.upCountTarget.textContent = data.up
      this.downCountTarget.textContent = data.down
    } catch (e) {
      // Show zeros on failure
    }
  }

  hasVoted() {
    return localStorage.getItem(`rating_${this.slugValue}`) !== null
  }

  saveVote(direction) {
    localStorage.setItem(`rating_${this.slugValue}`, direction)
  }

  checkUserVote() {
    if (this.hasVoted()) {
      const vote = localStorage.getItem(`rating_${this.slugValue}`)
      this.upButtonTarget.disabled = true
      this.downButtonTarget.disabled = true
      if (vote === "up") this.upButtonTarget.classList.add("text-green-500")
      if (vote === "down") this.downButtonTarget.classList.add("text-red-500")
      if (this.hasPromptTarget) this.promptTarget.textContent = "Thanks for your feedback!"
    }
  }

  updateUI() {
    this.checkUserVote()
  }
}
