// Reads URL search params and fills matching Stimulus targets.
// Usage: import { prefillFromUrl } from "utils/url_prefill"
// In connect(): prefillFromUrl(this, { principal: "principal", rate: "rate", years: "years" })
export function prefillFromUrl(controller, paramMap) {
  const params = new URLSearchParams(window.location.search)
  let filled = false

  for (const [paramName, targetName] of Object.entries(paramMap)) {
    const value = params.get(paramName)
    if (value === null) continue

    try {
      const target = controller[`${targetName}Target`]
      if (target && 'value' in target) {
        target.value = value
        filled = true
      }
    } catch (e) {
      // Target not found, skip
    }
  }

  return filled
}
