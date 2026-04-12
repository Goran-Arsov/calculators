import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "weightUnit", "medication", "customDose", "customDosesPerDay",
                     "customMaxSingle", "customMaxDaily", "customFields",
                     "medName", "singleDose", "dailyDose", "dosesPerDay",
                     "maxSingle", "maxDaily", "cappedNote", "notes"]

  static medications = {
    ibuprofen: { name: "Ibuprofen", dosePerKg: 10, maxSingle: 400, maxDaily: 1200, dosesPerDay: 3, notes: "Take with food. Not for children under 6 months." },
    acetaminophen: { name: "Acetaminophen (Paracetamol)", dosePerKg: 15, maxSingle: 1000, maxDaily: 4000, dosesPerDay: 4, notes: "Do not exceed daily maximum. Avoid with liver disease." },
    amoxicillin: { name: "Amoxicillin", dosePerKg: 25, maxSingle: 500, maxDaily: 1500, dosesPerDay: 3, notes: "Complete the full course as prescribed." },
    cetirizine: { name: "Cetirizine (Zyrtec)", dosePerKg: 0.25, maxSingle: 10, maxDaily: 10, dosesPerDay: 1, notes: "May cause drowsiness." },
    diphenhydramine: { name: "Diphenhydramine (Benadryl)", dosePerKg: 1.25, maxSingle: 50, maxDaily: 300, dosesPerDay: 4, notes: "Causes drowsiness. Not recommended for children under 2." },
    custom: { name: "Custom Medication", dosePerKg: null, maxSingle: null, maxDaily: null, dosesPerDay: null, notes: "Consult a healthcare provider." }
  }

  connect() {
    this.toggleCustomFields()
  }

  toggleCustomFields() {
    const isCustom = this.medicationTarget.value === "custom"
    this.customFieldsTarget.classList.toggle("hidden", !isCustom)
    this.calculate()
  }

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const weightUnit = this.weightUnitTarget.value
    const medKey = this.medicationTarget.value

    if (weight <= 0) {
      this.clearResults()
      return
    }

    const weightKg = weightUnit === "lbs" ? weight * 0.453592 : weight
    const med = this.constructor.medications[medKey]
    if (!med) { this.clearResults(); return }

    let dosePerKg, dosesPerDay, maxSingle, maxDaily
    if (medKey === "custom") {
      dosePerKg = parseFloat(this.customDoseTarget.value) || 0
      dosesPerDay = parseInt(this.customDosesPerDayTarget.value) || 1
      maxSingle = parseFloat(this.customMaxSingleTarget.value) || null
      maxDaily = parseFloat(this.customMaxDailyTarget.value) || null
      if (dosePerKg <= 0) { this.clearResults(); return }
    } else {
      dosePerKg = med.dosePerKg
      dosesPerDay = med.dosesPerDay
      maxSingle = med.maxSingle
      maxDaily = med.maxDaily
    }

    const calculatedSingle = weightKg * dosePerKg
    const cappedSingle = maxSingle ? Math.min(calculatedSingle, maxSingle) : calculatedSingle
    const calculatedDaily = cappedSingle * dosesPerDay
    const cappedDaily = maxDaily ? Math.min(calculatedDaily, maxDaily) : calculatedDaily
    const isCapped = (maxSingle && calculatedSingle > maxSingle) || (maxDaily && calculatedDaily > maxDaily)

    this.medNameTarget.textContent = med.name
    this.singleDoseTarget.textContent = `${cappedSingle.toFixed(1)} mg`
    this.dosesPerDayTarget.textContent = `${dosesPerDay}x daily`
    this.dailyDoseTarget.textContent = `${cappedDaily.toFixed(1)} mg`
    this.maxSingleTarget.textContent = maxSingle ? `${maxSingle} mg` : "N/A"
    this.maxDailyTarget.textContent = maxDaily ? `${maxDaily} mg` : "N/A"
    this.notesTarget.textContent = medKey === "custom" ? "Consult a healthcare provider for proper dosing." : med.notes

    if (isCapped) {
      this.cappedNoteTarget.textContent = "Dose has been capped to maximum safe limits."
      this.cappedNoteTarget.classList.remove("hidden")
    } else {
      this.cappedNoteTarget.classList.add("hidden")
    }
  }

  clearResults() {
    this.medNameTarget.textContent = "—"
    this.singleDoseTarget.textContent = "—"
    this.dosesPerDayTarget.textContent = "—"
    this.dailyDoseTarget.textContent = "—"
    this.maxSingleTarget.textContent = "—"
    this.maxDailyTarget.textContent = "—"
    this.notesTarget.textContent = "—"
    this.cappedNoteTarget.classList.add("hidden")
  }

  copy() {
    const text = [
      `Medication: ${this.medNameTarget.textContent}`,
      `Single Dose: ${this.singleDoseTarget.textContent}`,
      `Frequency: ${this.dosesPerDayTarget.textContent}`,
      `Daily Total: ${this.dailyDoseTarget.textContent}`,
      `Max Single: ${this.maxSingleTarget.textContent}`,
      `Max Daily: ${this.maxDailyTarget.textContent}`,
      `Notes: ${this.notesTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
