import { Controller } from "@hotwired/stimulus"

const WASTE_FACTOR = 1.10
const GRAVEL_BASE_DEPTH_FT = 0.5
const GRAVEL_BASE_WIDTH_FT = 2.0
const BACKFILL_DEPTH_FT = 1.0
const CUBIC_FT_PER_YARD = 27.0

export default class extends Controller {
  static targets = ["wallLength", "wallHeight", "blockHeight", "blockLength",
    "resultRows", "resultBlocksPerRow", "resultTotalBlocks", "resultCapBlocks",
    "resultGravelYards", "resultBackfillYards"]

  calculate() {
    const wallLength = parseFloat(this.wallLengthTarget.value) || 0
    const wallHeight = parseFloat(this.wallHeightTarget.value) || 0
    const blockHeight = parseFloat(this.blockHeightTarget.value) || 6
    const blockLength = parseFloat(this.blockLengthTarget.value) || 16

    if (wallLength <= 0 || wallHeight <= 0 || blockHeight <= 0 || blockLength <= 0) {
      this.resultRowsTarget.textContent = "0"
      this.resultBlocksPerRowTarget.textContent = "0"
      this.resultTotalBlocksTarget.textContent = "0"
      this.resultCapBlocksTarget.textContent = "0"
      this.resultGravelYardsTarget.textContent = "0.00 yd\u00B3"
      this.resultBackfillYardsTarget.textContent = "0.00 yd\u00B3"
      return
    }

    const rows = Math.ceil((wallHeight * 12) / blockHeight)
    const blocksPerRow = Math.ceil((wallLength * 12) / blockLength)
    const totalBlocksRaw = rows * blocksPerRow
    const totalBlocks = Math.ceil(totalBlocksRaw * WASTE_FACTOR)
    const capBlocks = blocksPerRow

    const gravelCubicFt = GRAVEL_BASE_DEPTH_FT * GRAVEL_BASE_WIDTH_FT * wallLength
    const gravelYards = (gravelCubicFt / CUBIC_FT_PER_YARD).toFixed(2)

    const backfillCubicFt = wallHeight * BACKFILL_DEPTH_FT * wallLength
    const backfillYards = (backfillCubicFt / CUBIC_FT_PER_YARD).toFixed(2)

    this.resultRowsTarget.textContent = rows
    this.resultBlocksPerRowTarget.textContent = blocksPerRow
    this.resultTotalBlocksTarget.textContent = totalBlocks
    this.resultCapBlocksTarget.textContent = capBlocks
    this.resultGravelYardsTarget.textContent = `${gravelYards} yd\u00B3`
    this.resultBackfillYardsTarget.textContent = `${backfillYards} yd\u00B3`
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
