// Unit conversion constants and helpers shared by all calculators that
// support a metric/imperial toggle. Convention: constants convert FROM
// the imperial unit TO the metric unit (e.g. FT_TO_M = 0.3048). Divide
// to go the other way.

export const FT_TO_M = 0.3048
export const IN_TO_CM = 2.54
export const YD_TO_M = 0.9144
export const MI_TO_KM = 1.609344
export const SQFT_TO_SQM = 0.09290304
export const SQYD_TO_SQM = 0.83612736
export const CUFT_TO_CUM = 0.028316846592
export const CUYD_TO_CUM = 0.764554857984
export const GAL_TO_L = 3.785411784
export const QT_TO_L = 0.946352946
export const OZFL_TO_ML = 29.5735295625
export const LB_TO_KG = 0.45359237
export const OZ_TO_G = 28.349523125
export const BTU_TO_W = 0.29307107
export const HP_TO_KW = 0.7456999
export const MPH_TO_KMH = 1.609344
export const PSI_TO_KPA = 6.89475729

export const fToC = (f) => (f - 32) * 5 / 9
export const cToF = (c) => c * 9 / 5 + 32

// Round a number to `n` decimal places, returning a Number (not a string).
export const round = (n, d = 2) => {
  const p = Math.pow(10, d)
  return Math.round(n * p) / p
}
