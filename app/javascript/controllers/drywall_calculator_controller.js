import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM, GAL_TO_L } from "utils/units"

const DOOR_AREA_SQFT = 21
const WINDOW_AREA_SQFT = 15
const WASTE_FACTOR = 1.10
const JOINT_COMPOUND_SQFT_PER_GALLON = 100
const TAPE_SQFT_PER_ROLL = 50

export default class extends Controller {
  static targets = ["roomLength", "roomWidth", "roomHeight", "numDoors", "numWindows", "sheetSize",
    "unitSystem", "roomLengthLabel", "roomWidthLabel", "roomHeightLabel",
    "totalAreaHeading", "netAreaHeading", "jointCompoundHeading",
    "resultTotalWallArea", "resultNetArea", "resultSheetsNeeded", "resultJointCompound", "resultTapeRolls"]

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
    convert(this.roomLengthTarget, FT_TO_M)
    convert(this.roomWidthTarget, FT_TO_M)
    convert(this.roomHeightTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.roomLengthLabelTarget.textContent = metric ? "Room Length (m)" : "Room Length (ft)"
    this.roomWidthLabelTarget.textContent = metric ? "Room Width (m)" : "Room Width (ft)"
    this.roomHeightLabelTarget.textContent = metric ? "Room Height (m)" : "Room Height (ft)"
    this.totalAreaHeadingTarget.textContent = metric ? "Total Wall Area (m²)" : "Total Wall Area"
    this.netAreaHeadingTarget.textContent = metric ? "Net Area (m²)" : "Net Area"
    this.jointCompoundHeadingTarget.textContent = metric ? "Joint Compound (L)" : "Joint Compound (gal)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.roomLengthTarget.value) || 0
    const widthInput = parseFloat(this.roomWidthTarget.value) || 0
    const heightInput = parseFloat(this.roomHeightTarget.value) || 0
    const doors = parseInt(this.numDoorsTarget.value) || 0
    const windows = parseInt(this.numWindowsTarget.value) || 0
    const sheetSize = parseInt(this.sheetSizeTarget.value) || 32

    // Imperial math internally.
    const length = metric ? lengthInput / FT_TO_M : lengthInput
    const width = metric ? widthInput / FT_TO_M : widthInput
    const height = metric ? heightInput / FT_TO_M : heightInput

    const perimeter = 2 * (length + width)
    const totalWallArea = perimeter * height
    const openings = (doors * DOOR_AREA_SQFT) + (windows * WINDOW_AREA_SQFT)
    const netArea = Math.max(totalWallArea - openings, 0)

    const sheetsNeeded = netArea > 0 ? Math.ceil((netArea / sheetSize) * WASTE_FACTOR) : 0
    const jointCompoundGal = netArea > 0 ? Math.ceil(netArea / JOINT_COMPOUND_SQFT_PER_GALLON) : 0
    const tapeRolls = netArea > 0 ? Math.ceil(netArea / TAPE_SQFT_PER_ROLL) : 0

    if (metric) {
      const totalWallAreaM2 = totalWallArea * SQFT_TO_SQM
      const netAreaM2 = netArea * SQFT_TO_SQM
      const jointCompoundL = Math.ceil(jointCompoundGal * GAL_TO_L)
      this.resultTotalWallAreaTarget.textContent = `${this.fmt(totalWallAreaM2)} m²`
      this.resultNetAreaTarget.textContent = `${this.fmt(netAreaM2)} m²`
      this.resultJointCompoundTarget.textContent = jointCompoundL
    } else {
      this.resultTotalWallAreaTarget.textContent = `${this.fmt(totalWallArea)} sq ft`
      this.resultNetAreaTarget.textContent = `${this.fmt(netArea)} sq ft`
      this.resultJointCompoundTarget.textContent = jointCompoundGal
    }
    this.resultSheetsNeededTarget.textContent = sheetsNeeded
    this.resultTapeRollsTarget.textContent = tapeRolls
  }

  copy() {
    const totalWallArea = this.resultTotalWallAreaTarget.textContent
    const netArea = this.resultNetAreaTarget.textContent
    const sheets = this.resultSheetsNeededTarget.textContent
    const compound = this.resultJointCompoundTarget.textContent
    const tape = this.resultTapeRollsTarget.textContent
    const compoundUnit = this.jointCompoundHeadingTarget.textContent.includes("L") ? "liters" : "gallons"
    const text = `Drywall Estimate:\nTotal Wall Area: ${totalWallArea}\nNet Area: ${netArea}\nSheets Needed: ${sheets}\nJoint Compound: ${compound} ${compoundUnit}\nTape Rolls: ${tape}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
