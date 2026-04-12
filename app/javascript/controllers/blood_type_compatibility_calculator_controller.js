import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bloodType",
                     "canDonateTo", "canReceiveFrom", "plasmaDonateTo",
                     "population", "specialNotes", "antigens", "antibodies", "rhFactor",
                     "compatMatrix"]

  static donationCompat = {
    "O-": ["A+","A-","B+","B-","AB+","AB-","O+","O-"],
    "O+": ["A+","B+","AB+","O+"],
    "A-": ["A+","A-","AB+","AB-"],
    "A+": ["A+","AB+"],
    "B-": ["B+","B-","AB+","AB-"],
    "B+": ["B+","AB+"],
    "AB-": ["AB+","AB-"],
    "AB+": ["AB+"]
  }

  static receivingCompat = {
    "O-": ["O-"],
    "O+": ["O-","O+"],
    "A-": ["O-","A-"],
    "A+": ["O-","O+","A-","A+"],
    "B-": ["O-","B-"],
    "B+": ["O-","O+","B-","B+"],
    "AB-": ["O-","A-","B-","AB-"],
    "AB+": ["O-","O+","A-","A+","B-","B+","AB-","AB+"]
  }

  static population = { "O+": 37.4, "O-": 6.6, "A+": 35.7, "A-": 6.3, "B+": 8.5, "B-": 1.5, "AB+": 3.4, "AB-": 0.6 }

  calculate() {
    const bt = this.bloodTypeTarget.value
    if (!bt) { this.clearResults(); return }

    const donateTo = this.constructor.donationCompat[bt] || []
    const receiveFrom = this.constructor.receivingCompat[bt] || []

    this.canDonateToTarget.innerHTML = this.formatBadges(donateTo, "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400")
    this.canReceiveFromTarget.innerHTML = this.formatBadges(receiveFrom, "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400")

    this.populationTarget.textContent = `${this.constructor.population[bt]}%`

    // Antigen info
    const hasA = bt.includes("A")
    const hasB = bt.includes("B")
    const isAB = bt.startsWith("AB")
    const rhPos = bt.includes("+")

    let antigens = []
    if (isAB) antigens.push("A", "B")
    else if (hasA) antigens.push("A")
    else if (hasB) antigens.push("B")
    if (rhPos) antigens.push("Rh(D)")
    this.antigensTarget.textContent = antigens.length ? antigens.join(", ") : "None (Type O)"

    let antibodies = []
    if (!hasA && !hasB && !isAB) antibodies.push("Anti-A", "Anti-B")
    else if (hasA && !hasB && !isAB) antibodies.push("Anti-B")
    else if (hasB && !hasA && !isAB) antibodies.push("Anti-A")
    this.antibodiesTarget.textContent = antibodies.length ? antibodies.join(", ") : "None (Type AB)"
    this.rhFactorTarget.textContent = rhPos ? "Positive" : "Negative"

    // Special notes
    let notes = []
    if (bt === "O-") notes.push("Universal red blood cell donor - can donate to all types.", "Only 6.6% of the population. Always in high demand.")
    if (bt === "O+") notes.push("Most common blood type. Can donate to any Rh-positive type.")
    if (bt === "AB+") notes.push("Universal recipient - can receive from any blood type.", "Universal plasma donor.")
    if (bt === "AB-") notes.push("Rarest common blood type (0.6%).", "Universal plasma donor for Rh-negative recipients.")
    this.specialNotesTarget.innerHTML = notes.length ? notes.map(n => `<li class="text-sm text-gray-600 dark:text-gray-400">${n}</li>`).join("") : ""

    this.buildMatrix(bt)
  }

  formatBadges(types, cls) {
    return types.map(t => `<span class="inline-block px-2.5 py-1 rounded-full text-sm font-semibold ${cls} mr-1.5 mb-1.5">${t}</span>`).join("")
  }

  buildMatrix(selectedType) {
    const types = ["O-","O+","A-","A+","B-","B+","AB-","AB+"]
    let html = '<table class="w-full text-xs"><thead><tr><th class="p-1"></th>'
    types.forEach(t => { html += `<th class="p-1 text-center ${t === selectedType ? 'bg-blue-100 dark:bg-blue-900/30' : ''}">${t}</th>` })
    html += '</tr></thead><tbody>'
    types.forEach(donor => {
      html += `<tr><td class="p-1 font-semibold ${donor === selectedType ? 'bg-blue-100 dark:bg-blue-900/30' : ''}">${donor}</td>`
      types.forEach(recipient => {
        const compat = (this.constructor.donationCompat[donor] || []).includes(recipient)
        const isSelected = donor === selectedType || recipient === selectedType
        const bg = compat ? "bg-green-100 dark:bg-green-900/20" : "bg-red-50 dark:bg-red-900/10"
        const highlight = isSelected ? "ring-1 ring-blue-300 dark:ring-blue-700" : ""
        html += `<td class="p-1 text-center ${bg} ${highlight}">${compat ? "\u2713" : "\u2717"}</td>`
      })
      html += '</tr>'
    })
    html += '</tbody></table>'
    this.compatMatrixTarget.innerHTML = html
  }

  clearResults() {
    this.canDonateToTarget.innerHTML = ""
    this.canReceiveFromTarget.innerHTML = ""
    this.populationTarget.textContent = "\u2014"
    this.antigensTarget.textContent = "\u2014"
    this.antibodiesTarget.textContent = "\u2014"
    this.rhFactorTarget.textContent = "\u2014"
    this.specialNotesTarget.innerHTML = ""
    this.compatMatrixTarget.innerHTML = ""
  }

  copy() {
    const bt = this.bloodTypeTarget.value
    const text = [
      `Blood Type: ${bt}`,
      `Can Donate To: ${(this.constructor.donationCompat[bt] || []).join(", ")}`,
      `Can Receive From: ${(this.constructor.receivingCompat[bt] || []).join(", ")}`,
      `Population: ${this.populationTarget.textContent}`,
      `Antigens: ${this.antigensTarget.textContent}`,
      `Antibodies: ${this.antibodiesTarget.textContent}`,
      `Rh Factor: ${this.rhFactorTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
