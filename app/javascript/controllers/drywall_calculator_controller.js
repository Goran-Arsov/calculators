import { Controller } from "@hotwired/stimulus"

const DOOR_AREA_SQFT = 21
const WINDOW_AREA_SQFT = 15
const WASTE_FACTOR = 1.10
const JOINT_COMPOUND_SQFT_PER_GALLON = 100
const TAPE_SQFT_PER_ROLL = 50

export default class extends Controller {
  static targets = ["roomLength", "roomWidth", "roomHeight", "numDoors", "numWindows", "sheetSize",
    "resultTotalWallArea", "resultNetArea", "resultSheetsNeeded", "resultJointCompound", "resultTapeRolls"]

  calculate() {
    const length = parseFloat(this.roomLengthTarget.value) || 0
    const width = parseFloat(this.roomWidthTarget.value) || 0
    const height = parseFloat(this.roomHeightTarget.value) || 0
    const doors = parseInt(this.numDoorsTarget.value) || 0
    const windows = parseInt(this.numWindowsTarget.value) || 0
    const sheetSize = parseInt(this.sheetSizeTarget.value) || 32

    const perimeter = 2 * (length + width)
    const totalWallArea = perimeter * height
    const openings = (doors * DOOR_AREA_SQFT) + (windows * WINDOW_AREA_SQFT)
    const netArea = Math.max(totalWallArea - openings, 0)

    const sheetsNeeded = netArea > 0 ? Math.ceil((netArea / sheetSize) * WASTE_FACTOR) : 0
    const jointCompound = netArea > 0 ? Math.ceil(netArea / JOINT_COMPOUND_SQFT_PER_GALLON) : 0
    const tapeRolls = netArea > 0 ? Math.ceil(netArea / TAPE_SQFT_PER_ROLL) : 0

    this.resultTotalWallAreaTarget.textContent = `${this.fmt(totalWallArea)} sq ft`
    this.resultNetAreaTarget.textContent = `${this.fmt(netArea)} sq ft`
    this.resultSheetsNeededTarget.textContent = sheetsNeeded
    this.resultJointCompoundTarget.textContent = jointCompound
    this.resultTapeRollsTarget.textContent = tapeRolls
  }

  copy() {
    const totalWallArea = this.resultTotalWallAreaTarget.textContent
    const netArea = this.resultNetAreaTarget.textContent
    const sheets = this.resultSheetsNeededTarget.textContent
    const compound = this.resultJointCompoundTarget.textContent
    const tape = this.resultTapeRollsTarget.textContent
    const text = `Drywall Estimate:\nTotal Wall Area: ${totalWallArea}\nNet Area: ${netArea}\nSheets Needed: ${sheets}\nJoint Compound: ${compound} gallons\nTape Rolls: ${tape}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
