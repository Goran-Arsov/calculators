import { Controller } from "@hotwired/stimulus"

const FIXTURE_UNITS = {
  toilet: 4,
  sink: 1,
  shower: 2,
  bathtub: 2,
  dishwasher: 2,
  washing_machine: 2
}

const PIPE_SIZE_TABLE = [
  { min: 1, max: 6, size: '3/4"' },
  { min: 7, max: 15, size: '1"' },
  { min: 16, max: 30, size: '1-1/4"' },
  { min: 31, max: 50, size: '1-1/2"' }
]

export default class extends Controller {
  static targets = ["numToilets", "numSinks", "numShowers", "numBathtubs", "numDishwashers", "numWashingMachines",
    "resultTotalUnits", "resultMainPipe", "resultSupplyLine", "resultBreakdown"]

  calculate() {
    const toilets = parseInt(this.numToiletsTarget.value) || 0
    const sinks = parseInt(this.numSinksTarget.value) || 0
    const showers = parseInt(this.numShowersTarget.value) || 0
    const bathtubs = parseInt(this.numBathtubsTarget.value) || 0
    const dishwashers = parseInt(this.numDishwashersTarget.value) || 0
    const washingMachines = parseInt(this.numWashingMachinesTarget.value) || 0

    const toiletUnits = toilets * FIXTURE_UNITS.toilet
    const sinkUnits = sinks * FIXTURE_UNITS.sink
    const showerUnits = showers * FIXTURE_UNITS.shower
    const bathtubUnits = bathtubs * FIXTURE_UNITS.bathtub
    const dishwasherUnits = dishwashers * FIXTURE_UNITS.dishwasher
    const washingMachineUnits = washingMachines * FIXTURE_UNITS.washing_machine

    const totalUnits = toiletUnits + sinkUnits + showerUnits + bathtubUnits + dishwasherUnits + washingMachineUnits

    let mainPipe = '2"'
    for (const entry of PIPE_SIZE_TABLE) {
      if (totalUnits >= entry.min && totalUnits <= entry.max) {
        mainPipe = entry.size
        break
      }
    }

    const supplyLine = totalUnits >= 20 ? '1"' : '3/4"'

    this.resultTotalUnitsTarget.textContent = totalUnits
    this.resultMainPipeTarget.textContent = mainPipe
    this.resultSupplyLineTarget.textContent = supplyLine

    this.resultBreakdownTarget.innerHTML = `
      <div class="space-y-1 text-sm">
        <div class="flex justify-between"><span>Toilets (${toilets} x ${FIXTURE_UNITS.toilet})</span><span class="font-semibold">${toiletUnits}</span></div>
        <div class="flex justify-between"><span>Sinks (${sinks} x ${FIXTURE_UNITS.sink})</span><span class="font-semibold">${sinkUnits}</span></div>
        <div class="flex justify-between"><span>Showers (${showers} x ${FIXTURE_UNITS.shower})</span><span class="font-semibold">${showerUnits}</span></div>
        <div class="flex justify-between"><span>Bathtubs (${bathtubs} x ${FIXTURE_UNITS.bathtub})</span><span class="font-semibold">${bathtubUnits}</span></div>
        <div class="flex justify-between"><span>Dishwashers (${dishwashers} x ${FIXTURE_UNITS.dishwasher})</span><span class="font-semibold">${dishwasherUnits}</span></div>
        <div class="flex justify-between"><span>Washing Machines (${washingMachines} x ${FIXTURE_UNITS.washing_machine})</span><span class="font-semibold">${washingMachineUnits}</span></div>
      </div>
    `
  }

  copy() {
    const totalUnits = this.resultTotalUnitsTarget.textContent
    const mainPipe = this.resultMainPipeTarget.textContent
    const supplyLine = this.resultSupplyLineTarget.textContent
    const text = `Plumbing Estimate:\nTotal Fixture Units: ${totalUnits}\nRecommended Main Pipe: ${mainPipe}\nSupply Line Size: ${supplyLine}`
    navigator.clipboard.writeText(text)
  }
}
