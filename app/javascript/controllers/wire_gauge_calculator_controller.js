import { Controller } from "@hotwired/stimulus"

const AWG = {
  "0000":{d:11.684,a:107.22,r:0.1608,amp:302},"000":{d:10.405,a:85.029,r:0.2028,amp:239},
  "00":{d:9.266,a:67.431,r:0.2557,amp:190},"0":{d:8.251,a:53.475,r:0.3224,amp:150},
  "1":{d:7.348,a:42.408,r:0.4066,amp:119},"2":{d:6.544,a:33.631,r:0.5127,amp:94},
  "3":{d:5.827,a:26.670,r:0.6465,amp:75},"4":{d:5.189,a:21.151,r:0.8152,amp:60},
  "5":{d:4.621,a:16.773,r:1.028,amp:47},"6":{d:4.115,a:13.302,r:1.296,amp:37},
  "7":{d:3.665,a:10.549,r:1.634,amp:30},"8":{d:3.264,a:8.366,r:2.061,amp:24},
  "9":{d:2.906,a:6.632,r:2.599,amp:19},"10":{d:2.588,a:5.261,r:3.277,amp:15},
  "11":{d:2.305,a:4.172,r:4.132,amp:12},"12":{d:2.053,a:3.309,r:5.211,amp:9.3},
  "13":{d:1.828,a:2.624,r:6.571,amp:7.4},"14":{d:1.628,a:2.081,r:8.286,amp:5.9},
  "15":{d:1.450,a:1.650,r:10.45,amp:4.7},"16":{d:1.291,a:1.309,r:13.17,amp:3.7},
  "17":{d:1.150,a:1.038,r:16.61,amp:2.9},"18":{d:1.024,a:0.823,r:20.95,amp:2.3},
  "19":{d:0.912,a:0.653,r:26.42,amp:1.8},"20":{d:0.812,a:0.518,r:33.31,amp:1.5},
  "22":{d:0.644,a:0.326,r:52.96,amp:0.92},"24":{d:0.511,a:0.205,r:84.22,amp:0.577},
  "26":{d:0.405,a:0.129,r:133.9,amp:0.361},"28":{d:0.321,a:0.0810,r:212.9,amp:0.226},
  "30":{d:0.255,a:0.0510,r:338.6,amp:0.142},"32":{d:0.202,a:0.0320,r:538.3,amp:0.091},
  "34":{d:0.160,a:0.0201,r:856.0,amp:0.057},"36":{d:0.127,a:0.0127,r:1361.0,amp:0.036},
  "38":{d:0.101,a:0.00797,r:2164.0,amp:0.022},"40":{d:0.0799,a:0.00501,r:3441.0,amp:0.014}
}

export default class extends Controller {
  static targets = ["gauge", "diameter", "diameterIn", "area", "resistance", "resistanceFt", "ampacity"]

  lookup() {
    const g = this.gaugeTarget.value
    const data = AWG[g]
    if (!data) { this.clear(); return }

    this.diameterTarget.textContent = data.d + " mm"
    this.diameterInTarget.textContent = (data.d / 25.4).toFixed(4) + " in"
    this.areaTarget.textContent = data.a + " mm²"
    this.resistanceTarget.textContent = data.r + " Ω/km"
    this.resistanceFtTarget.textContent = (data.r * 0.3048).toFixed(4) + " Ω/1000ft"
    this.ampacityTarget.textContent = data.amp + " A"
  }

  clear() {
    for (const t of ["diameter","diameterIn","area","resistance","resistanceFt","ampacity"]) {
      this[t + "Target"].textContent = "—"
    }
  }

  copy() {
    const g = this.gaugeTarget.value
    const text = `AWG ${g}: ${this.diameterTarget.textContent}, ${this.areaTarget.textContent}, ${this.resistanceTarget.textContent}, ${this.ampacityTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
