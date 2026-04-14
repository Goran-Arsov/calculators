import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, SQFT_TO_SQM } from "utils/units"

const JOIST_SPACING_FT = 16 / 12
const POST_SPACING_FT = 8
const SCREWS_PER_BOARD = 20
const SCREWS_PER_BOX = 350

export default class extends Controller {
  static targets = [
    "length", "width", "boardLength", "boardWidth", "pricePerBoard",
    "unitSystem", "lengthLabel", "widthLabel", "boardLengthLabel", "boardWidthLabel", "areaHeading",
    "resultArea", "resultBoards", "resultJoists", "resultPosts",
    "resultScrewBoxes", "resultCost"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.lengthTarget, FT_TO_M)
    convert(this.widthTarget, FT_TO_M)
    convert(this.boardLengthTarget, FT_TO_M)
    convert(this.boardWidthTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Deck Length (m)" : "Deck Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Deck Width (m)" : "Deck Width (ft)"
    this.boardLengthLabelTarget.textContent = metric ? "Board Length (m)" : "Board Length (ft)"
    this.boardWidthLabelTarget.textContent = metric ? "Board Width (cm)" : "Board Width (inches)"
    this.areaHeadingTarget.textContent = metric ? "Deck Area (m²)" : "Deck Area"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const boardLengthInput = parseFloat(this.boardLengthTarget.value) || (metric ? 12 * FT_TO_M : 12)
    const boardWidthInput = parseFloat(this.boardWidthTarget.value) || (metric ? 5.5 * IN_TO_CM : 5.5)
    const pricePerBoard = parseFloat(this.pricePerBoardTarget.value) || 0

    // Imperial math internally.
    const length = metric ? lengthInput / FT_TO_M : lengthInput
    const width = metric ? widthInput / FT_TO_M : widthInput
    const boardLength = metric ? boardLengthInput / FT_TO_M : boardLengthInput
    const boardWidth = metric ? boardWidthInput / IN_TO_CM : boardWidthInput

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

    if (metric) {
      const areaM2 = area * SQFT_TO_SQM
      this.resultAreaTarget.textContent = `${this.fmt(areaM2)} m²`
    } else {
      this.resultAreaTarget.textContent = `${this.fmt(area)} sq ft`
    }
    this.resultBoardsTarget.textContent = totalBoards
    this.resultJoistsTarget.textContent = numJoists
    this.resultPostsTarget.textContent = numPosts
    this.resultScrewBoxesTarget.textContent = screwBoxes
    this.resultCostTarget.textContent = this.currency(cost)
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    this.resultAreaTarget.textContent = metric ? "0 m²" : "0 sq ft"
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
