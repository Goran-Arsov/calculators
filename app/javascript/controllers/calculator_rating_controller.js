import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "average", "count", "prompt"]
  static values = { slug: String }

  connect() {
    this.fetchRatings()
    this.checkUserVote()
  }

  hover(event) {
    if (this.hasVoted()) return
    var score = parseInt(event.currentTarget.dataset.score)
    this.highlightStars(score)
  }

  unhover() {
    if (this.hasVoted()) return
    this.highlightStars(0)
  }

  rate(event) {
    if (this.hasVoted()) return
    var score = parseInt(event.currentTarget.dataset.score)
    this.submitRating(score)
  }

  async submitRating(score) {
    this.saveVote(score)
    this.highlightStars(score)
    this.lockStars()

    try {
      var response = await fetch("/api/ratings/" + encodeURIComponent(this.slugValue), {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ score: score })
      })
      var data = await response.json()
      this.averageTarget.textContent = data.average.toFixed(1)
      this.countTarget.textContent = data.count + (data.count === 1 ? " rating" : " ratings")
    } catch (e) {
      // Keep optimistic update
    }

    if (this.hasPromptTarget) {
      this.promptTarget.textContent = "Thanks for your feedback!"
    }

    if (typeof gtag === "function") {
      gtag("event", "calculator_rating", {
        calculator: this.slugValue,
        rating: score
      })
    }
  }

  async fetchRatings() {
    try {
      var response = await fetch("/api/ratings/" + encodeURIComponent(this.slugValue))
      var data = await response.json()
      this.averageTarget.textContent = data.average.toFixed(1)
      this.countTarget.textContent = data.count + (data.count === 1 ? " rating" : " ratings")
    } catch (e) {
      // Show defaults on failure
    }
  }

  highlightStars(score) {
    this.starTargets.forEach(function(star) {
      var starScore = parseInt(star.dataset.score)
      if (starScore <= score) {
        star.classList.remove("text-gray-300", "dark:text-gray-600")
        star.classList.add("text-yellow-400")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300", "dark:text-gray-600")
      }
    })
  }

  lockStars() {
    this.starTargets.forEach(function(star) {
      star.classList.add("cursor-default")
      star.classList.remove("cursor-pointer", "hover:scale-110")
    })
  }

  hasVoted() {
    return localStorage.getItem("rating_" + this.slugValue) !== null
  }

  saveVote(score) {
    localStorage.setItem("rating_" + this.slugValue, score.toString())
  }

  checkUserVote() {
    if (this.hasVoted()) {
      var score = parseInt(localStorage.getItem("rating_" + this.slugValue))
      this.highlightStars(score)
      this.lockStars()
      if (this.hasPromptTarget) {
        this.promptTarget.textContent = "Thanks for your feedback!"
      }
    }
  }
}
