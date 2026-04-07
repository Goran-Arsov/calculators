import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "minInput", "maxInput", "countInput", "uniqueCheckbox",
    "resultNumbers", "resultStats",
    "sortAscBtn", "sortDescBtn"
  ]

  connect() {
    this.numbers = []
  }

  generate() {
    const min = parseInt(this.minInputTarget.value)
    const max = parseInt(this.maxInputTarget.value)
    const count = Math.min(1000, Math.max(1, parseInt(this.countInputTarget.value) || 1))
    const unique = this.uniqueCheckboxTarget.checked

    if (isNaN(min) || isNaN(max)) {
      this.resultNumbersTarget.innerHTML = '<p class="text-red-500 text-sm">Please enter valid min and max values.</p>'
      this.resultStatsTarget.innerHTML = ""
      return
    }

    if (min > max) {
      this.resultNumbersTarget.innerHTML = '<p class="text-red-500 text-sm">Min must be less than or equal to Max.</p>'
      this.resultStatsTarget.innerHTML = ""
      return
    }

    const range = max - min + 1

    if (unique && count > range) {
      this.resultNumbersTarget.innerHTML = `<p class="text-yellow-600 dark:text-yellow-400 text-sm">Cannot generate ${count} unique numbers from a range of ${range}. Generating ${range} instead.</p>`
    }

    const nums = []

    if (unique) {
      const actualCount = Math.min(count, range)
      const pool = []
      for (let i = min; i <= max; i++) pool.push(i)
      // Fisher-Yates shuffle
      for (let i = pool.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [pool[i], pool[j]] = [pool[j], pool[i]]
      }
      for (let i = 0; i < actualCount; i++) nums.push(pool[i])
    } else {
      for (let i = 0; i < count; i++) {
        nums.push(Math.floor(Math.random() * range) + min)
      }
    }

    this.numbers = nums
    this._renderNumbers(nums)
    this._renderStats(nums)
  }

  sortAsc() {
    if (this.numbers.length === 0) return
    this.numbers.sort((a, b) => a - b)
    this._renderNumbers(this.numbers)
  }

  sortDesc() {
    if (this.numbers.length === 0) return
    this.numbers.sort((a, b) => b - a)
    this._renderNumbers(this.numbers)
  }

  copyAll() {
    if (this.numbers.length === 0) return
    const text = this.numbers.join(", ")
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copyAll']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }

  _renderNumbers(nums) {
    if (nums.length === 1) {
      this.resultNumbersTarget.innerHTML = `<div class="text-center py-6"><span class="text-5xl font-bold text-blue-600 dark:text-blue-400">${nums[0].toLocaleString()}</span></div>`
    } else if (nums.length <= 100) {
      this.resultNumbersTarget.innerHTML = `<div class="flex flex-wrap gap-2">${nums.map(n =>
        `<span class="inline-flex items-center justify-center px-2 py-1 text-sm font-mono bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 rounded">${n.toLocaleString()}</span>`
      ).join("")}</div>`
    } else {
      this.resultNumbersTarget.innerHTML = `<div class="max-h-64 overflow-y-auto bg-gray-50 dark:bg-gray-800 rounded-xl p-3"><p class="text-sm font-mono text-gray-900 dark:text-white whitespace-pre-wrap">${nums.join(", ")}</p></div>`
    }
  }

  _renderStats(nums) {
    if (nums.length <= 1) {
      this.resultStatsTarget.innerHTML = ""
      return
    }

    const sorted = [...nums].sort((a, b) => a - b)
    const min = sorted[0]
    const max = sorted[sorted.length - 1]
    const sum = nums.reduce((a, b) => a + b, 0)
    const avg = (sum / nums.length).toFixed(2)
    const mid = Math.floor(sorted.length / 2)
    const median = sorted.length % 2 === 0 ? ((sorted[mid - 1] + sorted[mid]) / 2).toFixed(2) : sorted[mid]
    const hasDupes = new Set(nums).size !== nums.length

    this.resultStatsTarget.innerHTML = `
      <div class="grid grid-cols-2 md:grid-cols-5 gap-3">
        <div class="text-center"><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Count</span><span class="text-sm font-bold text-gray-900 dark:text-white">${nums.length}</span></div>
        <div class="text-center"><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Min</span><span class="text-sm font-bold text-gray-900 dark:text-white">${min.toLocaleString()}</span></div>
        <div class="text-center"><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Max</span><span class="text-sm font-bold text-gray-900 dark:text-white">${max.toLocaleString()}</span></div>
        <div class="text-center"><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Average</span><span class="text-sm font-bold text-gray-900 dark:text-white">${avg}</span></div>
        <div class="text-center"><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Median</span><span class="text-sm font-bold text-gray-900 dark:text-white">${median}</span></div>
      </div>
      ${hasDupes ? '<p class="text-xs text-yellow-600 dark:text-yellow-400 mt-2 text-center">Contains duplicate values</p>' : '<p class="text-xs text-green-600 dark:text-green-400 mt-2 text-center">All values are unique</p>'}
    `
  }
}
