import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "textInput", "morseInput", "resultOutput", "statusMessage"
  ]

  static values = { playing: { type: Boolean, default: false } }

  CHAR_TO_MORSE = {
    "A": ".-",    "B": "-...",  "C": "-.-.",  "D": "-..",
    "E": ".",     "F": "..-.",  "G": "--.",   "H": "....",
    "I": "..",    "J": ".---",  "K": "-.-",   "L": ".-..",
    "M": "--",    "N": "-.",    "O": "---",   "P": ".--.",
    "Q": "--.-",  "R": ".-.",   "S": "...",   "T": "-",
    "U": "..-",   "V": "...-",  "W": ".--",   "X": "-..-",
    "Y": "-.--",  "Z": "--..",
    "0": "-----", "1": ".----", "2": "..---", "3": "...--",
    "4": "....-", "5": ".....", "6": "-....", "7": "--...",
    "8": "---..", "9": "----.",
    ".": ".-.-.-", ",": "--..--", "?": "..--..", "'": ".----.",
    "!": "-.-.--", "/": "-..-.",  "(": "-.--.",  ")": "-.--.-",
    "&": ".-...",  ":": "---...", ";": "-.-.-.", "=": "-...-",
    "+": ".-.-.",  "-": "-....-", "_": "..--.-", "\"": ".-..-.",
    "$": "...-..-", "@": ".--.-."
  }

  connect() {
    this.MORSE_TO_CHAR = {}
    for (const [char, morse] of Object.entries(this.CHAR_TO_MORSE)) {
      this.MORSE_TO_CHAR[morse] = char
    }
    this.audioContext = null
    this.playingValue = false
  }

  textToMorse() {
    const text = this.textInputTarget.value
    if (!text.trim()) {
      this.morseInputTarget.value = ""
      this.showStatus("")
      return
    }

    const result = []
    const unknown = []

    for (const char of text.toUpperCase()) {
      if (char === " ") {
        result.push("/")
      } else if (this.CHAR_TO_MORSE[char]) {
        result.push(this.CHAR_TO_MORSE[char])
      } else {
        unknown.push(char)
      }
    }

    this.morseInputTarget.value = result.join(" ")

    if (unknown.length > 0) {
      this.showStatus(`Unknown characters skipped: ${[...new Set(unknown)].join(", ")}`, "warning")
    } else {
      this.showStatus("Converted to Morse code", "success")
    }
  }

  morseToText() {
    const morse = this.morseInputTarget.value
    if (!morse.trim()) {
      this.textInputTarget.value = ""
      this.showStatus("")
      return
    }

    const words = morse.trim().split(/\s*\/\s*/)
    const result = []
    const unknown = []

    for (const word of words) {
      const codes = word.trim().split(/\s+/)
      for (const code of codes) {
        if (!code) continue
        if (this.MORSE_TO_CHAR[code]) {
          result.push(this.MORSE_TO_CHAR[code])
        } else {
          unknown.push(code)
        }
      }
      result.push(" ")
    }

    this.textInputTarget.value = result.join("").trim()

    if (unknown.length > 0) {
      this.showStatus(`Unknown morse codes skipped: ${[...new Set(unknown)].join(", ")}`, "warning")
    } else {
      this.showStatus("Converted from Morse code", "success")
    }
  }

  async playAudio() {
    const morse = this.morseInputTarget.value
    if (!morse.trim() || this.playingValue) return

    this.playingValue = true
    this.showStatus("Playing Morse code audio...", "info")

    if (!this.audioContext) {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)()
    }

    const dotDuration = 0.08
    const dashDuration = dotDuration * 3
    const symbolGap = dotDuration
    const letterGap = dotDuration * 3
    const wordGap = dotDuration * 7
    const frequency = 700

    let currentTime = this.audioContext.currentTime + 0.05

    for (const char of morse) {
      if (char === ".") {
        this.playTone(currentTime, dotDuration, frequency)
        currentTime += dotDuration + symbolGap
      } else if (char === "-") {
        this.playTone(currentTime, dashDuration, frequency)
        currentTime += dashDuration + symbolGap
      } else if (char === "/") {
        currentTime += wordGap
      } else if (char === " ") {
        currentTime += letterGap
      }
    }

    const totalDuration = (currentTime - this.audioContext.currentTime) * 1000
    setTimeout(() => {
      this.playingValue = false
      this.showStatus("Playback complete", "success")
    }, totalDuration)
  }

  playTone(startTime, duration, frequency) {
    const oscillator = this.audioContext.createOscillator()
    const gainNode = this.audioContext.createGain()

    oscillator.connect(gainNode)
    gainNode.connect(this.audioContext.destination)

    oscillator.frequency.value = frequency
    oscillator.type = "sine"

    gainNode.gain.setValueAtTime(0, startTime)
    gainNode.gain.linearRampToValueAtTime(0.5, startTime + 0.005)
    gainNode.gain.setValueAtTime(0.5, startTime + duration - 0.005)
    gainNode.gain.linearRampToValueAtTime(0, startTime + duration)

    oscillator.start(startTime)
    oscillator.stop(startTime + duration)
  }

  copyText() {
    this.copyToClipboard(this.textInputTarget.value, "Text copied!")
  }

  copyMorse() {
    this.copyToClipboard(this.morseInputTarget.value, "Morse code copied!")
  }

  copyToClipboard(text, message) {
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      this.showStatus(message, "success")
    })
  }

  clearAll() {
    this.textInputTarget.value = ""
    this.morseInputTarget.value = ""
    this.showStatus("")
  }

  showStatus(message, type = "") {
    if (!this.hasStatusMessageTarget) return
    this.statusMessageTarget.textContent = message
    this.statusMessageTarget.classList.remove("text-green-600", "dark:text-green-400", "text-yellow-600", "dark:text-yellow-400", "text-blue-600", "dark:text-blue-400", "text-red-500", "dark:text-red-400")

    if (type === "success") {
      this.statusMessageTarget.classList.add("text-green-600", "dark:text-green-400")
    } else if (type === "warning") {
      this.statusMessageTarget.classList.add("text-yellow-600", "dark:text-yellow-400")
    } else if (type === "info") {
      this.statusMessageTarget.classList.add("text-blue-600", "dark:text-blue-400")
    }
  }
}
