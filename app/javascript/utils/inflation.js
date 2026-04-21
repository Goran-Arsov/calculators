// Shared inflation adjustment utilities for calculator controllers.
// Import with: import { toRealValue, applyInflationToggle } from "utils/inflation"

export function toRealValue(nominal, annualRatePercent, years) {
  const rate = (parseFloat(annualRatePercent) || 0) / 100
  if (!Number.isFinite(nominal) || rate <= 0 || years <= 0) return nominal
  return nominal / Math.pow(1 + rate, years)
}

// Reads the inflation targets off a Stimulus controller, flips the visibility
// of its input and result containers, and returns { enabled, rate }.
// Safe to call on controllers that haven't wired every target.
export function applyInflationToggle(controller) {
  if (!controller.hasInflationEnabledTarget) return { enabled: false, rate: 0 }

  const enabled = controller.inflationEnabledTarget.checked
  if (controller.hasInflationFieldTarget) controller.inflationFieldTarget.hidden = !enabled
  if (controller.hasRealResultsTarget) controller.realResultsTarget.hidden = !enabled

  const rate = controller.hasInflationRateTarget
    ? (parseFloat(controller.inflationRateTarget.value) || 0)
    : 0

  return { enabled, rate }
}
