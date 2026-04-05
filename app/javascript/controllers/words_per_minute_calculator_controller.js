import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "wordCount", "timeMinutes", "timeSeconds",
    "resultWpm", "resultTotalMinutes", "resultCpm",
    "resultEmailTime", "resultBlogTime", "resultReportTime",
    "resultEssayTime", "resultNovelPageTime", "resultThesisTime"
  ]

  static commonLengths = {
    email: 200,
    blog: 1500,
    report: 3000,
    essay: 2000,
    novelPage: 250,
    thesis: 20000
  }

  calculate() {
    const wordCount = parseFloat(this.wordCountTarget.value) || 0
    const minutes = parseFloat(this.timeMinutesTarget.value) || 0
    const seconds = parseFloat(this.timeSecondsTarget.value) || 0
    const totalMinutes = minutes + seconds / 60

    if (wordCount <= 0 || totalMinutes <= 0) {
      this.clearResults()
      return
    }

    const wpm = wordCount / totalMinutes
    const cpm = wpm * 5

    this.resultWpmTarget.textContent = wpm.toFixed(1)
    this.resultTotalMinutesTarget.textContent = totalMinutes.toFixed(2) + " min"
    this.resultCpmTarget.textContent = Math.round(cpm)

    const lengths = this.constructor.commonLengths
    this.resultEmailTimeTarget.textContent = this.formatTime(lengths.email / wpm)
    this.resultBlogTimeTarget.textContent = this.formatTime(lengths.blog / wpm)
    this.resultReportTimeTarget.textContent = this.formatTime(lengths.report / wpm)
    this.resultEssayTimeTarget.textContent = this.formatTime(lengths.essay / wpm)
    this.resultNovelPageTimeTarget.textContent = this.formatTime(lengths.novelPage / wpm)
    this.resultThesisTimeTarget.textContent = this.formatTime(lengths.thesis / wpm)
  }

  clearResults() {
    const targets = [
      "resultWpm", "resultTotalMinutes", "resultCpm",
      "resultEmailTime", "resultBlogTime", "resultReportTime",
      "resultEssayTime", "resultNovelPageTime", "resultThesisTime"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  formatTime(minutes) {
    if (minutes < 1) return Math.round(minutes * 60) + " sec"
    if (minutes < 60) return minutes.toFixed(1) + " min"
    const hours = Math.floor(minutes / 60)
    const mins = Math.round(minutes % 60)
    return hours + "h " + mins + "m"
  }

  copy() {
    const text = [
      `Words Per Minute: ${this.resultWpmTarget.textContent}`,
      `Characters Per Minute: ${this.resultCpmTarget.textContent}`,
      `Total Time: ${this.resultTotalMinutesTarget.textContent}`,
      `Email (200 words): ${this.resultEmailTimeTarget.textContent}`,
      `Blog Post (1,500 words): ${this.resultBlogTimeTarget.textContent}`,
      `Report (3,000 words): ${this.resultReportTimeTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
