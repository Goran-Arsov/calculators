import { Controller } from "@hotwired/stimulus"

const JOIST_SPACING_FT = 16 / 12
const POST_SPACING_FT = 8
const SCREWS_PER_BOARD = 20
const SCREWS_PER_BOX = 350

export default class extends Controller {
  static targets = [
    "length", "width", "boardLength", "boardWidth", "pricePerBoard",
    "resultArea", "resultBoards", "resultJoists", "resultPosts",
    "resultScrewBoxes", "resultCost"
  ]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const boardLength = parseFloat(this.boardLengthTarget.value) || 12
    const boardWidth = parseFloat(this.boardWidthTarget.value) || 5.5
    const pricePerBoard = parseFloat(this.pricePerBoardTarget.value) || 0

    if (length <= 0 || width <= 0) {
      this.clearResults()
      return
    }

    const area = length * width
    const boardWidthFt = boardWidth / 12
    const boardsAcross = Math.ceil(width / boardWidthFt)
    const boardRuns = Math.ceil(length / boardLength)
    const totalBoards = boardsAcross * boardRuns

    const numJoists = Math.ceil(length / JOIST_SPACING_FT) + 1
    const postsPerSide = Math.ceil(length / POST_SPACING_FT) + 1
    const numPosts = postsPerSide * 2

    const totalScrews = totalBoards * SCREWS_PER_BOARD
    const screwBoxes = Math.ceil(totalScrews / SCREWS_PER_BOX)

    const cost = totalBoards * pricePerBoard

    this.resultAreaTarget.textContent = `${this.fmt(area)} sq ft`
    this.resultBoardsTarget.textContent = totalBoards
    this.resultJoistsTarget.textContent = numJoists
    this.resultPostsTarget.textContent = numPosts
    this.resultScrewBoxesTarget.textContent = screwBoxes
    this.resultCostTarget.textContent = this.currency(cost)
  }

  clearResults() {
    this.resultAreaTarget.textContent = "0 sq ft"
    this.resultBoardsTarget.textContent = "0"
    this.resultJoistsTarget.textContent = "0"
    this.resultPostsTarget.textContent = "0"
    this.resultScrewBoxesTarget.textContent = "0"
    this.resultCostTarget.textContent = "$0.00"
  }

  copy() {
    const text = `Deck Estimate:\nDeck Area: ${this.resultAreaTarget.textContent}\nBoards: ${this.resultBoardsTarget.textContent}\nJoists: ${this.resultJoistsTarget.textContent}\nPosts: ${this.resultPostsTarget.textContent}\nScrew Boxes: ${this.resultScrewBoxesTarget.textContent}\nEstimated Cost: ${this.resultCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  currency(n) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n)
  }
}
