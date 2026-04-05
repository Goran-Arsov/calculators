import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["upCount", "downCount", "upButton", "downButton", "prompt"]
  static values = { slug: String }

  connect() {
    this.loadRatings()
    this.checkUserVote()
  }

  thumbsUp() {
    if (this.hasVoted()) return
    this.saveVote("up")
    this.incrementRating("up")
    this.updateUI()
    this.trackRating("up")
  }

  thumbsDown() {
    if (this.hasVoted()) return
    this.saveVote("down")
    this.incrementRating("down")
    this.updateUI()
    this.trackRating("down")
  }

  // Store individual user's vote
  hasVoted() {
    return localStorage.getItem(`rating_${this.slugValue}`) !== null
  }

  saveVote(direction) {
    localStorage.setItem(`rating_${this.slugValue}`, direction)
  }

  // Store aggregate counts in localStorage (simple client-side aggregation)
  loadRatings() {
    const data = this.getRatingData()
    this.upCountTarget.textContent = data.up
    this.downCountTarget.textContent = data.down
  }

  getRatingData() {
    const stored = localStorage.getItem(`ratings_${this.slugValue}`)
    return stored ? JSON.parse(stored) : { up: 0, down: 0 }
  }

  incrementRating(direction) {
    const data = this.getRatingData()
    data[direction]++
    localStorage.setItem(`ratings_${this.slugValue}`, JSON.stringify(data))
    this.upCountTarget.textContent = data.up
    this.downCountTarget.textContent = data.down
  }

  checkUserVote() {
    if (this.hasVoted()) {
      const vote = localStorage.getItem(`rating_${this.slugValue}`)
      // Disable buttons, highlight the voted one
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

  trackRating(direction) {
    if (typeof gtag === "function") {
      gtag("event", "calculator_rating", {
        calculator: this.slugValue,
        rating: direction
      })
    }
  }
}
