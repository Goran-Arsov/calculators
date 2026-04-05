import { Controller } from "@hotwired/stimulus"

// Generic SVG chart controller for calculator visualizations.
// Supports: donut, bar, gauge, and stacked-bar chart types.
//
// Usage:
//   <div data-controller="chart" data-chart-type-value="donut">
//     <div data-chart-target="canvas"></div>
//   </div>
//
// Call from another controller:
//   this.dispatch("update", { detail: { type: "donut", data: [...] } })
//
// Or dispatch a custom event on the chart element:
//   chartElement.dispatchEvent(new CustomEvent("chart:update", {
//     detail: { type: "donut", data: [...], options: {} }
//   }))

export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    type: { type: String, default: "donut" },
    width: { type: Number, default: 280 },
    height: { type: Number, default: 280 }
  }

  connect() {
    this.element.addEventListener("chart:update", (e) => this.render(e.detail))
  }

  render(detail) {
    const { type, data, options } = detail
    const chartType = type || this.typeValue

    switch (chartType) {
      case "donut": this.#renderDonut(data, options); break
      case "bar": this.#renderBar(data, options); break
      case "gauge": this.#renderGauge(data, options); break
      case "stacked-bar": this.#renderStackedBar(data, options); break
      default: break
    }
  }

  #renderDonut(segments, options = {}) {
    const w = this.widthValue, h = this.heightValue
    const cx = w / 2, cy = h / 2
    const outerR = Math.min(cx, cy) - 10
    const innerR = outerR * 0.6
    const total = segments.reduce((sum, s) => sum + s.value, 0)
    if (total === 0) return

    let currentAngle = -Math.PI / 2
    const paths = segments.map(seg => {
      const angle = (seg.value / total) * 2 * Math.PI
      const x1o = cx + outerR * Math.cos(currentAngle)
      const y1o = cy + outerR * Math.sin(currentAngle)
      const x2o = cx + outerR * Math.cos(currentAngle + angle)
      const y2o = cy + outerR * Math.sin(currentAngle + angle)
      const x1i = cx + innerR * Math.cos(currentAngle + angle)
      const y1i = cy + innerR * Math.sin(currentAngle + angle)
      const x2i = cx + innerR * Math.cos(currentAngle)
      const y2i = cy + innerR * Math.sin(currentAngle)
      const largeArc = angle > Math.PI ? 1 : 0

      const d = `M${x1o},${y1o} A${outerR},${outerR} 0 ${largeArc},1 ${x2o},${y2o} L${x1i},${y1i} A${innerR},${innerR} 0 ${largeArc},0 ${x2i},${y2i} Z`
      currentAngle += angle
      return `<path d="${d}" fill="${seg.color}" class="transition-opacity hover:opacity-80"><title>${seg.label}: ${seg.value.toLocaleString()}</title></path>`
    })

    // Center text
    const centerText = options.centerText || ""
    const centerSub = options.centerSub || ""

    this.canvasTarget.innerHTML = `
      <svg viewBox="0 0 ${w} ${h}" class="w-full max-w-[${w}px] mx-auto">
        ${paths.join("")}
        <text x="${cx}" y="${cy - 8}" text-anchor="middle" class="fill-gray-900 dark:fill-white text-lg font-bold">${centerText}</text>
        <text x="${cx}" y="${cy + 14}" text-anchor="middle" class="fill-gray-500 dark:fill-gray-400 text-xs">${centerSub}</text>
      </svg>
      <div class="flex flex-wrap justify-center gap-4 mt-3">
        ${segments.map(s => `<div class="flex items-center gap-1.5 text-xs text-gray-600 dark:text-gray-400"><div class="w-3 h-3 rounded-full" style="background:${s.color}"></div>${s.label}</div>`).join("")}
      </div>`
  }

  #renderBar(bars, options = {}) {
    const w = this.widthValue, h = this.heightValue
    const padding = { top: 20, right: 20, bottom: 40, left: 60 }
    const chartW = w - padding.left - padding.right
    const chartH = h - padding.top - padding.bottom
    const maxVal = Math.max(...bars.map(b => b.value)) * 1.1

    const barWidth = Math.min(40, chartW / bars.length - 8)
    const barGap = (chartW - barWidth * bars.length) / (bars.length + 1)

    const barsSvg = bars.map((bar, i) => {
      const x = padding.left + barGap + i * (barWidth + barGap)
      const barH = (bar.value / maxVal) * chartH
      const y = padding.top + chartH - barH
      return `
        <rect x="${x}" y="${y}" width="${barWidth}" height="${barH}" rx="4" fill="${bar.color || '#3b82f6'}" class="transition-opacity hover:opacity-80">
          <title>${bar.label}: ${bar.value.toLocaleString()}</title>
        </rect>
        <text x="${x + barWidth / 2}" y="${h - 8}" text-anchor="middle" class="fill-gray-500 dark:fill-gray-400" style="font-size:10px">${bar.label}</text>`
    }).join("")

    // Y-axis labels
    const yLabels = [0, maxVal * 0.25, maxVal * 0.5, maxVal * 0.75, maxVal].map(v => {
      const y = padding.top + chartH - (v / maxVal) * chartH
      return `<text x="${padding.left - 8}" y="${y + 4}" text-anchor="end" class="fill-gray-400 dark:fill-gray-500" style="font-size:10px">${this.#formatNum(v)}</text>
              <line x1="${padding.left}" y1="${y}" x2="${w - padding.right}" y2="${y}" stroke="currentColor" class="text-gray-200 dark:text-gray-700" stroke-dasharray="4,4"/>`
    }).join("")

    this.canvasTarget.innerHTML = `<svg viewBox="0 0 ${w} ${h}" class="w-full">${yLabels}${barsSvg}</svg>`
  }

  #renderGauge(data, options = {}) {
    const w = 280, h = 180
    const cx = w / 2, cy = 160
    const r = 120
    const { value, min = 0, max = 100, zones = [] } = data

    // Draw zone arcs
    const zonePaths = zones.map(zone => {
      const startAngle = Math.PI + ((zone.from - min) / (max - min)) * Math.PI
      const endAngle = Math.PI + ((zone.to - min) / (max - min)) * Math.PI
      const x1 = cx + r * Math.cos(startAngle)
      const y1 = cy + r * Math.sin(startAngle)
      const x2 = cx + r * Math.cos(endAngle)
      const y2 = cy + r * Math.sin(endAngle)
      const largeArc = endAngle - startAngle > Math.PI ? 1 : 0
      return `<path d="M${x1},${y1} A${r},${r} 0 ${largeArc},1 ${x2},${y2}" stroke="${zone.color}" stroke-width="16" fill="none" stroke-linecap="round"/>`
    }).join("")

    // Needle
    const clampedVal = Math.max(min, Math.min(max, value))
    const needleAngle = Math.PI + ((clampedVal - min) / (max - min)) * Math.PI
    const nx = cx + (r - 30) * Math.cos(needleAngle)
    const ny = cy + (r - 30) * Math.sin(needleAngle)

    this.canvasTarget.innerHTML = `
      <svg viewBox="0 0 ${w} ${h}" class="w-full max-w-[280px] mx-auto">
        ${zonePaths}
        <line x1="${cx}" y1="${cy}" x2="${nx}" y2="${ny}" stroke="currentColor" class="text-gray-900 dark:text-white" stroke-width="3" stroke-linecap="round"/>
        <circle cx="${cx}" cy="${cy}" r="6" class="fill-gray-900 dark:fill-white"/>
        <text x="${cx}" y="${cy - 20}" text-anchor="middle" class="fill-gray-900 dark:fill-white text-2xl font-bold">${value}</text>
        <text x="${cx}" y="${cy - 4}" text-anchor="middle" class="fill-gray-500 dark:fill-gray-400 text-xs">${options.label || ''}</text>
      </svg>
      <div class="flex justify-center gap-4 mt-2">
        ${zones.map(z => `<div class="flex items-center gap-1 text-xs text-gray-500 dark:text-gray-400"><div class="w-2.5 h-2.5 rounded-full" style="background:${z.color}"></div>${z.label}</div>`).join("")}
      </div>`
  }

  #renderStackedBar(data, options = {}) {
    const w = this.widthValue, h = 40
    const total = data.reduce((sum, d) => sum + d.value, 0)
    if (total === 0) return

    let x = 0
    const bars = data.map(d => {
      const barW = (d.value / total) * w
      const bar = `<rect x="${x}" y="0" width="${barW}" height="${h}" fill="${d.color}" rx="${x === 0 ? 8 : 0}"><title>${d.label}: ${d.value.toLocaleString()}</title></rect>`
      x += barW
      return bar
    }).join("")

    this.canvasTarget.innerHTML = `
      <svg viewBox="0 0 ${w} ${h}" class="w-full rounded-xl overflow-hidden">${bars}</svg>
      <div class="flex flex-wrap justify-between mt-2">
        ${data.map(d => `<div class="flex items-center gap-1.5 text-xs text-gray-600 dark:text-gray-400"><div class="w-3 h-3 rounded-full" style="background:${d.color}"></div>${d.label}: ${((d.value / total) * 100).toFixed(1)}%</div>`).join("")}
      </div>`
  }

  #formatNum(n) {
    if (n >= 1000000) return (n / 1000000).toFixed(1) + "M"
    if (n >= 1000) return (n / 1000).toFixed(1) + "K"
    return Math.round(n).toString()
  }
}
