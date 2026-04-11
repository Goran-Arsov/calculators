import { Controller } from "@hotwired/stimulus"

const R_KM = 6371.0088

export default class extends Controller {
  static targets = ["vertices", "resultCount", "resultKm2", "resultMi2", "resultHa", "resultAcre", "resultPerimeter"]

  connect() {
    this.calculate()
  }

  calculate() {
    const vertices = this.parseVertices(this.verticesTarget.value)
    if (vertices.length < 3) {
      this.clear()
      this.resultCountTarget.textContent = vertices.length
      return
    }

    const validRange = vertices.every(v =>
      Math.abs(v.lat) <= 90 && Math.abs(v.lon) <= 180
    )
    if (!validRange) {
      this.clear()
      this.resultCountTarget.textContent = vertices.length
      return
    }

    const areaKm2 = Math.abs(this.sphericalArea(vertices))
    const perimeterKm = this.sphericalPerimeter(vertices)

    this.resultCountTarget.textContent = vertices.length
    this.resultKm2Target.textContent = areaKm2.toLocaleString(undefined, { maximumFractionDigits: 4 })
    this.resultMi2Target.textContent = (areaKm2 / 2.58999).toLocaleString(undefined, { maximumFractionDigits: 4 })
    this.resultHaTarget.textContent = (areaKm2 * 100).toLocaleString(undefined, { maximumFractionDigits: 3 })
    this.resultAcreTarget.textContent = (areaKm2 * 247.105).toLocaleString(undefined, { maximumFractionDigits: 3 })
    this.resultPerimeterTarget.textContent = `${perimeterKm.toFixed(3)} km / ${(perimeterKm * 0.621371).toFixed(3)} mi`
  }

  parseVertices(text) {
    return text.split(/\r?\n/).map(line => {
      const parts = line.trim().split(/[,\s]+/).filter(Boolean)
      if (parts.length < 2) return null
      const lat = parseFloat(parts[0])
      const lon = parseFloat(parts[1])
      if (!Number.isFinite(lat) || !Number.isFinite(lon)) return null
      return { lat, lon }
    }).filter(Boolean)
  }

  sphericalArea(vertices) {
    const toRad = (d) => (d * Math.PI) / 180
    let total = 0
    const n = vertices.length
    for (let i = 0; i < n; i++) {
      const a = vertices[i]
      const b = vertices[(i + 1) % n]
      total += toRad(b.lon - a.lon) *
               (2 + Math.sin(toRad(a.lat)) + Math.sin(toRad(b.lat)))
    }
    return Math.abs(total * R_KM ** 2 / 2)
  }

  sphericalPerimeter(vertices) {
    let total = 0
    const n = vertices.length
    for (let i = 0; i < n; i++) {
      const a = vertices[i]
      const b = vertices[(i + 1) % n]
      total += this.haversine(a.lat, a.lon, b.lat, b.lon)
    }
    return total
  }

  haversine(lat1, lon1, lat2, lon2) {
    const toRad = (d) => (d * Math.PI) / 180
    const phi1 = toRad(lat1)
    const phi2 = toRad(lat2)
    const dPhi = toRad(lat2 - lat1)
    const dLambda = toRad(lon2 - lon1)
    const a = Math.sin(dPhi / 2) ** 2 + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dLambda / 2) ** 2
    return 2 * R_KM * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }

  clear() {
    this.resultCountTarget.textContent = "0"
    this.resultKm2Target.textContent = "0"
    this.resultMi2Target.textContent = "0"
    this.resultHaTarget.textContent = "0"
    this.resultAcreTarget.textContent = "0"
    this.resultPerimeterTarget.textContent = "0 km"
  }

  copy() {
    const text = `Polygon Area:\nVertices: ${this.resultCountTarget.textContent}\nArea: ${this.resultKm2Target.textContent} km² (${this.resultMi2Target.textContent} mi²)\nPerimeter: ${this.resultPerimeterTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
