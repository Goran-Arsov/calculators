import { Controller } from "@hotwired/stimulus"

function parseSet(input) {
  if (!input || !input.trim()) return []
  const clean = input.trim().replace(/^\{|\}$/g, "")
  return [...new Set(clean.split(",").map(s => s.trim()).filter(s => s.length > 0))]
}

function fmtSet(arr) {
  return `{${[...arr].sort().join(", ")}}`
}

function powerSet(arr) {
  const result = [[]]
  for (const el of arr) {
    const len = result.length
    for (let i = 0; i < len; i++) result.push([...result[i], el])
  }
  return result
}

export default class extends Controller {
  static targets = [
    "setA", "setB", "universalSet",
    "union", "intersection", "differenceAB", "differenceBA",
    "symmetricDifference", "cardinalityA", "cardinalityB",
    "powerSetA", "powerSetSize",
    "complementA", "complementB",
    "isSubsetAB", "isSubsetBA", "areDisjoint", "areEqual",
    "error"
  ]

  calculate() {
    this.errorTarget.textContent = ""
    const a = parseSet(this.setATarget.value)
    const b = parseSet(this.setBTarget.value)
    const u = parseSet(this.hasUniversalSetTarget ? this.universalSetTarget.value : "")

    if (a.length === 0 && b.length === 0) { this.clear(); return }

    try {
      // Union
      const union = [...new Set([...a, ...b])]
      if (this.hasUnionTarget) this.unionTarget.textContent = fmtSet(union)

      // Intersection
      const inter = a.filter(x => b.includes(x))
      if (this.hasIntersectionTarget) this.intersectionTarget.textContent = fmtSet(inter)

      // A - B
      const diffAB = a.filter(x => !b.includes(x))
      if (this.hasDifferenceABTarget) this.differenceABTarget.textContent = fmtSet(diffAB)

      // B - A
      const diffBA = b.filter(x => !a.includes(x))
      if (this.hasDifferenceBATarget) this.differenceBATarget.textContent = fmtSet(diffBA)

      // Symmetric difference
      const symDiff = [...diffAB, ...diffBA]
      if (this.hasSymmetricDifferenceTarget) this.symmetricDifferenceTarget.textContent = fmtSet(symDiff)

      // Cardinalities
      if (this.hasCardinalityATarget) this.cardinalityATarget.textContent = `|A| = ${a.length}`
      if (this.hasCardinalityBTarget) this.cardinalityBTarget.textContent = `|B| = ${b.length}`

      // Power set
      if (this.hasPowerSetATarget) {
        if (a.length <= 10) {
          const ps = powerSet(a)
          this.powerSetATarget.textContent = `{${ps.map(s => fmtSet(s)).join(", ")}}`
          if (this.hasPowerSetSizeTarget) this.powerSetSizeTarget.textContent = `|P(A)| = 2^${a.length} = ${ps.length}`
        } else {
          this.powerSetATarget.textContent = `Too large (2^${a.length} = ${Math.pow(2, a.length)} subsets)`
          if (this.hasPowerSetSizeTarget) this.powerSetSizeTarget.textContent = `|P(A)| = 2^${a.length}`
        }
      }

      // Complement
      if (u.length > 0) {
        if (this.hasComplementATarget) this.complementATarget.textContent = fmtSet(u.filter(x => !a.includes(x)))
        if (this.hasComplementBTarget) this.complementBTarget.textContent = fmtSet(u.filter(x => !b.includes(x)))
      } else {
        if (this.hasComplementATarget) this.complementATarget.textContent = "Define universal set"
        if (this.hasComplementBTarget) this.complementBTarget.textContent = "Define universal set"
      }

      // Properties
      if (this.hasIsSubsetABTarget) this.isSubsetABTarget.textContent = a.every(x => b.includes(x)) ? "Yes" : "No"
      if (this.hasIsSubsetBATarget) this.isSubsetBATarget.textContent = b.every(x => a.includes(x)) ? "Yes" : "No"
      if (this.hasAreDisjointTarget) this.areDisjointTarget.textContent = inter.length === 0 ? "Yes" : "No"
      if (this.hasAreEqualTarget) this.areEqualTarget.textContent = JSON.stringify([...a].sort()) === JSON.stringify([...b].sort()) ? "Yes" : "No"
    } catch (e) {
      this.clear()
      this.errorTarget.textContent = e.message
    }
  }

  clear() {
    const targets = [
      "union", "intersection", "differenceAB", "differenceBA",
      "symmetricDifference", "cardinalityA", "cardinalityB",
      "powerSetA", "powerSetSize", "complementA", "complementB",
      "isSubsetAB", "isSubsetBA", "areDisjoint", "areEqual"
    ]
    targets.forEach(t => {
      const hasMethod = `has${t.charAt(0).toUpperCase() + t.slice(1)}Target`
      if (this[hasMethod]) this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const parts = []
    if (this.hasUnionTarget) parts.push(`Union: ${this.unionTarget.textContent}`)
    if (this.hasIntersectionTarget) parts.push(`Intersection: ${this.intersectionTarget.textContent}`)
    if (this.hasDifferenceABTarget) parts.push(`A-B: ${this.differenceABTarget.textContent}`)
    if (this.hasDifferenceBATarget) parts.push(`B-A: ${this.differenceBATarget.textContent}`)
    navigator.clipboard.writeText(parts.join("\n"))
  }
}
