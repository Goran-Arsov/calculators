import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, SQFT_TO_SQM } from "utils/units"

const ROLL_WIDTH_IN = 20.5
const ROLL_LENGTH_FT = 33.0
const DOOR_AREA_SQFT = 21
const WINDOW_AREA_SQFT = 15

export default class extends Controller {
  static targets = [
    "length", "width", "height", "doors", "windows", "patternRepeat",
    "unitSystem", "lengthLabel", "widthLabel", "heightLabel", "patternLabel",
    "resultWallArea", "resultCoverable", "resultStrips",
    "resultStripsPerRoll", "resultRolls"
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
    convert(this.heightTarget, FT_TO_M)
    convert(this.patternRepeatTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Room Length (m)" : "Room Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Room Width (m)" : "Room Width (ft)"
    this.heightLabelTarget.textContent = metric ? "Wall Height (m)" : "Wall Height (ft)"
    this.patternLabelTarget.textContent = metric ? "Pattern Repeat (cm, 0 for none)" : "Pattern Repeat (inches, 0 for none)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const rawLength = parseFloat(this.lengthTarget.value) || 0
    const rawWidth = parseFloat(this.widthTarget.value) || 0
    const rawHeight = parseFloat(this.heightTarget.value) || 0
    const doors = parseInt(this.doorsTarget.value) || 0
    const windows = parseInt(this.windowsTarget.value) || 0
    const rawRepeat = parseFloat(this.patternRepeatTarget.value) || 0

    if (rawLength <= 0 || rawWidth <= 0 || rawHeight <= 0) {
      this.clearResults()
      return
    }

    // Canonical: feet and inches
    const length = metric ? rawLength / FT_TO_M : rawLength
    const width = metric ? rawWidth / FT_TO_M : rawWidth
    const height = metric ? rawHeight / FT_TO_M : rawHeight
    const patternRepeat = metric ? rawRepeat / IN_TO_CM : rawRepeat

    const perimeter = 2 * (length + width)
    const wallArea = perimeter * height
    const openingArea = (doors * DOOR_AREA_SQFT) + (windows * WINDOW_AREA_SQFT)
    const coverableArea = Math.max(wallArea - openingArea, 0)

    const rollWidthFt = ROLL_WIDTH_IN / 12
    let stripsPerRoll

    if (patternRepeat > 0) {
      const patternRepeatFt = patternRepeat / 12
      const stripsPerHeight = Math.ceil(height / patternRepeatFt)
      const adjustedHeight = stripsPerHeight * patternRepeatFt
      stripsPerRoll = Math.max(Math.floor(ROLL_LENGTH_FT / adjustedHeight), 1)
    } else {
      stripsPerRoll = Math.max(Math.floor(ROLL_LENGTH_FT / height), 1)
    }

    const totalStrips = Math.ceil(perimeter / rollWidthFt)
    const savedStrips = doors + windows
    const netStrips = Math.max(totalStrips - savedStrips, 1)
    const rollsNeeded = Math.ceil(netStrips / stripsPerRoll)

    if (metric) {
      this.resultWallAreaTarget.textContent = `${this.fmt(wallArea * SQFT_TO_SQM)} m²`
      this.resultCoverableTarget.textContent = `${this.fmt(coverableArea * SQFT_TO_SQM)} m²`
    } else {
      this.resultWallAreaTarget.textContent = `${this.fmt(wallArea)} sq ft`
      this.resultCoverableTarget.textContent = `${this.fmt(coverableArea)} sq ft`
    }
    this.resultStripsTarget.textContent = totalStrips
    this.resultStripsPerRollTarget.textContent = stripsPerRoll
    this.resultRollsTarget.textContent = rollsNeeded
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? "m²" : "sq ft"
    this.resultWallAreaTarget.textContent = `0 ${unit}`
    this.resultCoverableTarget.textContent = `0 ${unit}`
    this.resultStripsTarget.textContent = "0"
    this.resultStripsPerRollTarget.textContent = "0"
    this.resultRollsTarget.textContent = "0"
  }

  copy() {
    const text = `Wallpaper Estimate:\nWall Area: ${this.resultWallAreaTarget.textContent}\nCoverable Area: ${this.resultCoverableTarget.textContent}\nTotal Strips: ${this.resultStripsTarget.textContent}\nStrips per Roll: ${this.resultStripsPerRollTarget.textContent}\nRolls Needed: ${this.resultRollsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
