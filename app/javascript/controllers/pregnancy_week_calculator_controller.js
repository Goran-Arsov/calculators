import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dueDate", "lmpDate", "inputMode",
                     "currentWeek", "trimester", "dueDateResult",
                     "daysRemaining", "percentComplete", "progressBar",
                     "babySize", "babySizeIcon"]

  static babySizes = [
    { week: 1, size: "Poppy seed", icon: "." },
    { week: 2, size: "Poppy seed", icon: "." },
    { week: 3, size: "Poppy seed", icon: "." },
    { week: 4, size: "Poppy seed", icon: "." },
    { week: 5, size: "Sesame seed", icon: "." },
    { week: 6, size: "Lentil", icon: "." },
    { week: 7, size: "Blueberry", icon: "." },
    { week: 8, size: "Raspberry", icon: "." },
    { week: 9, size: "Cherry", icon: "." },
    { week: 10, size: "Strawberry", icon: "." },
    { week: 11, size: "Lime", icon: "." },
    { week: 12, size: "Plum", icon: "." },
    { week: 13, size: "Lemon", icon: "." },
    { week: 14, size: "Nectarine", icon: "." },
    { week: 15, size: "Apple", icon: "." },
    { week: 16, size: "Avocado", icon: "." },
    { week: 17, size: "Pear", icon: "." },
    { week: 18, size: "Bell pepper", icon: "." },
    { week: 19, size: "Mango", icon: "." },
    { week: 20, size: "Banana", icon: "." },
    { week: 21, size: "Carrot", icon: "." },
    { week: 22, size: "Papaya", icon: "." },
    { week: 23, size: "Grapefruit", icon: "." },
    { week: 24, size: "Cantaloupe", icon: "." },
    { week: 25, size: "Cauliflower", icon: "." },
    { week: 26, size: "Lettuce head", icon: "." },
    { week: 27, size: "Rutabaga", icon: "." },
    { week: 28, size: "Eggplant", icon: "." },
    { week: 29, size: "Butternut squash", icon: "." },
    { week: 30, size: "Cabbage", icon: "." },
    { week: 31, size: "Coconut", icon: "." },
    { week: 32, size: "Jicama", icon: "." },
    { week: 33, size: "Pineapple", icon: "." },
    { week: 34, size: "Cantaloupe", icon: "." },
    { week: 35, size: "Honeydew", icon: "." },
    { week: 36, size: "Honeydew melon", icon: "." },
    { week: 37, size: "Winter melon", icon: "." },
    { week: 38, size: "Pumpkin", icon: "." },
    { week: 39, size: "Small watermelon", icon: "." },
    { week: 40, size: "Watermelon", icon: "." }
  ]

  connect() {
    this.updateInputVisibility()
  }

  toggleMode() {
    this.updateInputVisibility()
    this.calculate()
  }

  updateInputVisibility() {
    const mode = this.inputModeTarget.value
    const dueDateInput = this.dueDateTarget.closest("div.input-group")
    const lmpInput = this.lmpDateTarget.closest("div.input-group")

    if (mode === "due_date") {
      dueDateInput.classList.remove("hidden")
      lmpInput.classList.add("hidden")
    } else {
      dueDateInput.classList.add("hidden")
      lmpInput.classList.remove("hidden")
    }
  }

  calculate() {
    const mode = this.inputModeTarget.value
    let lmp

    if (mode === "due_date") {
      const dueDateValue = this.dueDateTarget.value
      if (!dueDateValue) { this.clearResults(); return }
      const dueDate = new Date(dueDateValue + "T00:00:00")
      lmp = new Date(dueDate)
      lmp.setDate(lmp.getDate() - 280)
    } else {
      const lmpValue = this.lmpDateTarget.value
      if (!lmpValue) { this.clearResults(); return }
      lmp = new Date(lmpValue + "T00:00:00")
    }

    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const dueDate = new Date(lmp)
    dueDate.setDate(dueDate.getDate() + 280)

    const diffMs = today - lmp
    const totalDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    const weeks = Math.floor(totalDays / 7)
    const days = totalDays % 7
    const daysRemaining = Math.max(0, Math.floor((dueDate - today) / (1000 * 60 * 60 * 24)))
    const percentComplete = Math.min(100, (totalDays / 280 * 100)).toFixed(1)

    let trimester
    if (weeks < 1) {
      trimester = "Pre-pregnancy"
    } else if (weeks <= 13) {
      trimester = "First Trimester (Weeks 1-13)"
    } else if (weeks <= 27) {
      trimester = "Second Trimester (Weeks 14-27)"
    } else if (weeks <= 40) {
      trimester = "Third Trimester (Weeks 28-40)"
    } else {
      trimester = "Past due date"
    }

    this.currentWeekTarget.textContent = totalDays >= 0
      ? `Week ${weeks}, Day ${days}`
      : "Not yet pregnant"
    this.trimesterTarget.textContent = trimester
    this.dueDateResultTarget.textContent = this.fmtDate(dueDate)
    this.daysRemainingTarget.textContent = `${daysRemaining} days`
    this.percentCompleteTarget.textContent = `${percentComplete}%`
    this.progressBarTarget.style.width = `${Math.min(100, percentComplete)}%`

    // Baby size comparison
    const clampedWeek = Math.max(1, Math.min(40, weeks))
    const sizeEntry = this.constructor.babySizes[clampedWeek - 1]
    if (sizeEntry && weeks >= 1 && weeks <= 40) {
      this.babySizeTarget.textContent = `Your baby is about the size of a ${sizeEntry.size.toLowerCase()}`
      this.babySizeTarget.closest(".baby-size-display").classList.remove("hidden")
    } else {
      this.babySizeTarget.closest(".baby-size-display").classList.add("hidden")
    }
  }

  clearResults() {
    this.currentWeekTarget.textContent = "\u2014"
    this.trimesterTarget.textContent = "\u2014"
    this.dueDateResultTarget.textContent = "\u2014"
    this.daysRemainingTarget.textContent = "\u2014"
    this.percentCompleteTarget.textContent = "\u2014"
    this.progressBarTarget.style.width = "0%"
    this.babySizeTarget.closest(".baby-size-display").classList.add("hidden")
  }

  fmtDate(date) {
    const options = { year: "numeric", month: "long", day: "numeric" }
    return date.toLocaleDateString("en-US", options)
  }

  copy() {
    const text = [
      `Current Week: ${this.currentWeekTarget.textContent}`,
      `Trimester: ${this.trimesterTarget.textContent}`,
      `Due Date: ${this.dueDateResultTarget.textContent}`,
      `Days Remaining: ${this.daysRemainingTarget.textContent}`,
      `Progress: ${this.percentCompleteTarget.textContent}`,
      this.babySizeTarget.textContent || ""
    ].filter(Boolean).join("\n")
    navigator.clipboard.writeText(text)
  }
}
