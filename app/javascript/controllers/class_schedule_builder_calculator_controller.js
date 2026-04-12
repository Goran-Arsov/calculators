import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "classesContainer", "classTemplate",
    "totalClasses", "totalCredits", "totalHours",
    "conflictsList", "conflictsSection",
    "gapsList", "gapsSection",
    "earliestStart", "latestEnd"
  ]

  connect() {
    if (this.classesContainerTarget.children.length === 0) {
      this.addRow()
    }
  }

  addRow() {
    const index = this.classesContainerTarget.children.length
    const row = document.createElement("div")
    row.classList.add("p-4", "bg-gray-50", "dark:bg-gray-800/50", "rounded-xl", "space-y-3", "border", "border-gray-200/60", "dark:border-gray-700/60")
    row.dataset.classIndex = index
    row.innerHTML = `
      <div class="flex justify-between items-center">
        <span class="text-sm font-semibold text-gray-700 dark:text-gray-300">Class ${index + 1}</span>
        <button type="button" data-action="click->class-schedule-builder-calculator#removeRow" class="text-red-500 hover:text-red-700 text-xs font-medium">Remove</button>
      </div>
      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Class Name</label>
          <input type="text" data-field="name" class="w-full text-sm" placeholder="e.g. Calculus I" data-action="input->class-schedule-builder-calculator#calculate">
        </div>
        <div>
          <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Day</label>
          <select data-field="day" class="w-full text-sm" data-action="change->class-schedule-builder-calculator#calculate">
            <option value="monday">Monday</option>
            <option value="tuesday">Tuesday</option>
            <option value="wednesday">Wednesday</option>
            <option value="thursday">Thursday</option>
            <option value="friday">Friday</option>
            <option value="saturday">Saturday</option>
            <option value="sunday">Sunday</option>
          </select>
        </div>
        <div>
          <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Start Time</label>
          <input type="time" data-field="start_time" class="w-full text-sm" value="09:00" data-action="input->class-schedule-builder-calculator#calculate">
        </div>
        <div>
          <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">End Time</label>
          <input type="time" data-field="end_time" class="w-full text-sm" value="10:00" data-action="input->class-schedule-builder-calculator#calculate">
        </div>
        <div>
          <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Credits</label>
          <input type="number" data-field="credits" class="w-full text-sm" value="3" min="1" max="6" data-action="input->class-schedule-builder-calculator#calculate">
        </div>
        <div>
          <label class="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">Location</label>
          <input type="text" data-field="location" class="w-full text-sm" placeholder="Room 101" data-action="input->class-schedule-builder-calculator#calculate">
        </div>
      </div>
    `
    this.classesContainerTarget.appendChild(row)
    this.calculate()
  }

  removeRow(event) {
    const row = event.target.closest("[data-class-index]")
    if (row && this.classesContainerTarget.children.length > 1) {
      row.remove()
      this.renumberRows()
      this.calculate()
    }
  }

  renumberRows() {
    Array.from(this.classesContainerTarget.children).forEach((row, i) => {
      row.dataset.classIndex = i
      row.querySelector("span").textContent = `Class ${i + 1}`
    })
  }

  calculate() {
    const classes = this.getClasses()

    if (classes.length === 0) {
      this.clearResults()
      return
    }

    const valid = classes.filter(c => c.name && c.end_minutes > c.start_minutes && c.credits > 0)
    if (valid.length === 0) {
      this.clearResults()
      return
    }

    const totalCredits = valid.reduce((sum, c) => sum + c.credits, 0)
    const totalHours = valid.reduce((sum, c) => sum + (c.end_minutes - c.start_minutes) / 60, 0)

    // Detect conflicts
    const conflicts = []
    const byDay = this.groupByDay(valid)

    for (const [day, dayClasses] of Object.entries(byDay)) {
      const sorted = dayClasses.sort((a, b) => a.start_minutes - b.start_minutes)
      for (let i = 0; i < sorted.length - 1; i++) {
        if (sorted[i].end_minutes > sorted[i + 1].start_minutes) {
          const overlap = sorted[i].end_minutes - sorted[i + 1].start_minutes
          conflicts.push(`${day}: ${sorted[i].name} overlaps with ${sorted[i + 1].name} by ${overlap} min`)
        }
      }
    }

    // Detect gaps
    const gaps = []
    for (const [day, dayClasses] of Object.entries(byDay)) {
      const sorted = dayClasses.sort((a, b) => a.start_minutes - b.start_minutes)
      for (let i = 0; i < sorted.length - 1; i++) {
        const gap = sorted[i + 1].start_minutes - sorted[i].end_minutes
        if (gap > 0) {
          gaps.push(`${day}: ${gap} min gap between ${sorted[i].name} and ${sorted[i + 1].name}`)
        }
      }
    }

    const earliest = valid.reduce((min, c) => Math.min(min, c.start_minutes), Infinity)
    const latest = valid.reduce((max, c) => Math.max(max, c.end_minutes), 0)

    this.totalClassesTarget.textContent = valid.length
    this.totalCreditsTarget.textContent = totalCredits
    this.totalHoursTarget.textContent = totalHours.toFixed(1) + " hrs/week"
    this.earliestStartTarget.textContent = this.formatTime(earliest)
    this.latestEndTarget.textContent = this.formatTime(latest)

    if (conflicts.length > 0) {
      this.conflictsSectionTarget.classList.remove("hidden")
      this.conflictsListTarget.innerHTML = conflicts.map(c => `<li class="text-red-600 dark:text-red-400 text-sm">${c}</li>`).join("")
    } else {
      this.conflictsSectionTarget.classList.add("hidden")
    }

    if (gaps.length > 0) {
      this.gapsSectionTarget.classList.remove("hidden")
      this.gapsListTarget.innerHTML = gaps.map(g => `<li class="text-amber-600 dark:text-amber-400 text-sm">${g}</li>`).join("")
    } else {
      this.gapsSectionTarget.classList.add("hidden")
    }
  }

  getClasses() {
    const rows = this.classesContainerTarget.children
    const classes = []
    for (const row of rows) {
      const name = row.querySelector("[data-field='name']")?.value || ""
      const day = row.querySelector("[data-field='day']")?.value || "monday"
      const startTime = row.querySelector("[data-field='start_time']")?.value || "09:00"
      const endTime = row.querySelector("[data-field='end_time']")?.value || "10:00"
      const credits = parseInt(row.querySelector("[data-field='credits']")?.value) || 0
      classes.push({
        name,
        day,
        start_minutes: this.timeToMinutes(startTime),
        end_minutes: this.timeToMinutes(endTime),
        credits
      })
    }
    return classes
  }

  timeToMinutes(time) {
    const [h, m] = time.split(":").map(Number)
    return h * 60 + (m || 0)
  }

  formatTime(minutes) {
    const h = Math.floor(minutes / 60)
    const m = minutes % 60
    const period = h >= 12 ? "PM" : "AM"
    const displayH = h > 12 ? h - 12 : (h === 0 ? 12 : h)
    return `${displayH}:${m.toString().padStart(2, "0")} ${period}`
  }

  groupByDay(classes) {
    const result = {}
    for (const c of classes) {
      const day = c.day.charAt(0).toUpperCase() + c.day.slice(1)
      if (!result[day]) result[day] = []
      result[day].push(c)
    }
    return result
  }

  clearResults() {
    this.totalClassesTarget.textContent = "0"
    this.totalCreditsTarget.textContent = "0"
    this.totalHoursTarget.textContent = "0 hrs/week"
    this.earliestStartTarget.textContent = "N/A"
    this.latestEndTarget.textContent = "N/A"
    this.conflictsSectionTarget.classList.add("hidden")
    this.gapsSectionTarget.classList.add("hidden")
  }

  copy() {
    const text = `Class Schedule Summary\nTotal Classes: ${this.totalClassesTarget.textContent}\nTotal Credits: ${this.totalCreditsTarget.textContent}\nTotal Hours: ${this.totalHoursTarget.textContent}\nEarliest Start: ${this.earliestStartTarget.textContent}\nLatest End: ${this.latestEndTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
