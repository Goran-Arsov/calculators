import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["size", "system", "resultUS", "resultUK", "resultEU", "resultCM"]

  static sizeTable = [
    [3.5,  3.0,  35.5, 21.6],
    [4.0,  3.5,  36.0, 22.0],
    [4.5,  4.0,  36.5, 22.4],
    [5.0,  4.5,  37.0, 22.8],
    [5.5,  5.0,  37.5, 23.2],
    [6.0,  5.5,  38.0, 23.5],
    [6.5,  6.0,  38.5, 23.8],
    [7.0,  6.5,  39.0, 24.1],
    [7.5,  7.0,  40.0, 24.5],
    [8.0,  7.5,  40.5, 24.8],
    [8.5,  8.0,  41.0, 25.1],
    [9.0,  8.5,  42.0, 25.4],
    [9.5,  9.0,  42.5, 25.7],
    [10.0, 9.5,  43.0, 26.0],
    [10.5, 10.0, 43.5, 26.7],
    [11.0, 10.5, 44.0, 27.0],
    [11.5, 11.0, 44.5, 27.3],
    [12.0, 11.5, 45.0, 27.6],
    [12.5, 12.0, 45.5, 27.9],
    [13.0, 12.5, 46.0, 28.3],
    [14.0, 13.5, 47.0, 29.0],
    [15.0, 14.5, 48.5, 29.7]
  ]

  static systemIndex = { "US": 0, "UK": 1, "EU": 2, "CM": 3 }

  calculate() {
    const size = parseFloat(this.sizeTarget.value) || 0
    const system = this.systemTarget.value
    if (size <= 0) return

    const idx = this.constructor.systemIndex[system]
    if (idx === undefined) return

    const table = this.constructor.sizeTable
    let closest = table[0]
    let minDiff = Math.abs(table[0][idx] - size)

    for (let i = 1; i < table.length; i++) {
      const diff = Math.abs(table[i][idx] - size)
      if (diff < minDiff) {
        minDiff = diff
        closest = table[i]
      }
    }

    this.resultUSTarget.textContent = closest[0]
    this.resultUKTarget.textContent = closest[1]
    this.resultEUTarget.textContent = closest[2]
    this.resultCMTarget.textContent = closest[3] + " cm"
  }

  copy() {
    const us = this.resultUSTarget.textContent
    const uk = this.resultUKTarget.textContent
    const eu = this.resultEUTarget.textContent
    const cm = this.resultCMTarget.textContent
    const text = `US: ${us}\nUK: ${uk}\nEU: ${eu}\nLength: ${cm}`
    navigator.clipboard.writeText(text)
  }
}
