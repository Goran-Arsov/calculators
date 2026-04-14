import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, CUYD_TO_CUM } from "utils/units"

const WASTE_FACTOR = 1.10
const GRAVEL_BASE_DEPTH_FT = 0.5
const GRAVEL_BASE_WIDTH_FT = 2.0
const BACKFILL_DEPTH_FT = 1.0
const CUBIC_FT_PER_YARD = 27.0

export default class extends Controller {
  static targets = [
    "wallLength", "wallHeight", "blockHeight", "blockLength",
    "unitSystem", "wallLengthLabel", "wallHeightLabel", "blockHeightLabel", "blockLengthLabel",
    "gravelHeading", "backfillHeading",
    "resultRows", "resultBlocksPerRow", "resultTotalBlocks", "resultCapBlocks",
    "resultGravelYards", "resultBackfillYards"
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
    convert(this.wallLengthTarget, FT_TO_M)
    convert(this.wallHeightTarget, FT_TO_M)
    convert(this.blockHeightTarget, IN_TO_CM)
    convert(this.blockLengthTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.wallLengthLabelTarget.textContent = metric ? "Wall Length (m)" : "Wall Length (ft)"
    this.wallHeightLabelTarget.textContent = metric ? "Wall Height (m)" : "Wall Height (ft)"
    this.blockHeightLabelTarget.textContent = metric ? "Block Height (cm)" : "Block Height (inches)"
    this.blockLengthLabelTarget.textContent = metric ? "Block Length (cm)" : "Block Length (inches)"
    this.gravelHeadingTarget.textContent = "Gravel Base"
    this.backfillHeadingTarget.textContent = "Backfill"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const wallLength = parseFloat(this.wallLengthTarget.value) || 0
    const wallHeight = parseFloat(this.wallHeightTarget.value) || 0
    const blockHeight = parseFloat(this.blockHeightTarget.value) || (metric ? 15 : 6)
    const blockLength = parseFloat(this.blockLengthTarget.value) || (metric ? 40 : 16)

    if (wallLength <= 0 || wallHeight <= 0 || blockHeight <= 0 || blockLength <= 0) {
      this.resultRowsTarget.textContent = "0"
      this.resultBlocksPerRowTarget.textContent = "0"
      this.resultTotalBlocksTarget.textContent = "0"
      this.resultCapBlocksTarget.textContent = "0"
      this.resultGravelYardsTarget.textContent = metric ? "0.00 m³" : "0.00 yd\u00B3"
      this.resultBackfillYardsTarget.textContent = metric ? "0.00 m³" : "0.00 yd\u00B3"
      return
    }

    // Convert metric to imperial internally
    const wallLengthFt = metric ? wallLength / FT_TO_M : wallLength
    const wallHeightFt = metric ? wallHeight / FT_TO_M : wallHeight
    const blockHeightIn = metric ? blockHeight / IN_TO_CM : blockHeight
    const blockLengthIn = metric ? blockLength / IN_TO_CM : blockLength

    const rows = Math.ceil((wallHeightFt * 12) / blockHeightIn)
    const blocksPerRow = Math.ceil((wallLengthFt * 12) / blockLengthIn)
    const totalBlocksRaw = rows * blocksPerRow
    const totalBlocks = Math.ceil(totalBlocksRaw * WASTE_FACTOR)
    const capBlocks = blocksPerRow

    const gravelCubicFt = GRAVEL_BASE_DEPTH_FT * GRAVEL_BASE_WIDTH_FT * wallLengthFt
    const gravelYards = gravelCubicFt / CUBIC_FT_PER_YARD

    const backfillCubicFt = wallHeightFt * BACKFILL_DEPTH_FT * wallLengthFt
    const backfillYards = backfillCubicFt / CUBIC_FT_PER_YARD

    this.resultRowsTarget.textContent = rows
    this.resultBlocksPerRowTarget.textContent = blocksPerRow
    this.resultTotalBlocksTarget.textContent = totalBlocks
    this.resultCapBlocksTarget.textContent = capBlocks

    if (metric) {
      const gravelM3 = gravelYards * CUYD_TO_CUM
      const backfillM3 = backfillYards * CUYD_TO_CUM
      this.resultGravelYardsTarget.textContent = `${gravelM3.toFixed(2)} m³`
      this.resultBackfillYardsTarget.textContent = `${backfillM3.toFixed(2)} m³`
    } else {
      this.resultGravelYardsTarget.textContent = `${gravelYards.toFixed(2)} yd\u00B3`
      this.resultBackfillYardsTarget.textContent = `${backfillYards.toFixed(2)} yd\u00B3`
    }
  }

  copy() {
    const rows = this.resultRowsTarget.textContent
    const blocksPerRow = this.resultBlocksPerRowTarget.textContent
    const totalBlocks = this.resultTotalBlocksTarget.textContent
    const capBlocks = this.resultCapBlocksTarget.textContent
    const gravel = this.resultGravelYardsTarget.textContent
    const backfill = this.resultBackfillYardsTarget.textContent
    const text = `Retaining Wall Estimate:\nRows: ${rows}\nBlocks Per Row: ${blocksPerRow}\nTotal Blocks: ${totalBlocks}\nCap Blocks: ${capBlocks}\nGravel: ${gravel}\nBackfill: ${backfill}`
    navigator.clipboard.writeText(text)
  }
}
