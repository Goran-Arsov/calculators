import { Controller } from "@hotwired/stimulus"

const ROLL_WIDTH_IN = 20.5
const ROLL_LENGTH_FT = 33.0
const DOOR_AREA_SQFT = 21
const WINDOW_AREA_SQFT = 15

export default class extends Controller {
  static targets = [
    "length", "width", "height", "doors", "windows", "patternRepeat",
    "resultWallArea", "resultCoverable", "resultStrips",
    "resultStripsPerRoll", "resultRolls"
  ]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const doors = parseInt(this.doorsTarget.value) || 0
    const windows = parseInt(this.windowsTarget.value) || 0
    const patternRepeat = parseFloat(this.patternRepeatTarget.value) || 0

    if (length <= 0 || width <= 0 || height <= 0) {
      this.clearResults()
      return
    }

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

    this.resultWallAreaTarget.textContent = `${this.fmt(wallArea)} sq ft`
    this.resultCoverableTarget.textContent = `${this.fmt(coverableArea)} sq ft`
    this.resultStripsTarget.textContent = totalStrips
    this.resultStripsPerRollTarget.textContent = stripsPerRoll
    this.resultRollsTarget.textContent = rollsNeeded
  }

  clearResults() {
    this.resultWallAreaTarget.textContent = "0 sq ft"
    this.resultCoverableTarget.textContent = "0 sq ft"
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
