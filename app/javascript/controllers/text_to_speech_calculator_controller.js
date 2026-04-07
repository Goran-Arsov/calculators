import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "textInput",
    "voiceSelect",
    "rateSlider", "rateValue",
    "pitchSlider", "pitchValue",
    "volumeSlider", "volumeValue",
    "speakBtn", "pauseBtn", "resumeBtn", "stopBtn",
    "charCount", "wordCount"
  ]

  connect() {
    this.synth = window.speechSynthesis
    this.voices = []
    this.utterance = null

    // Populate voices (some browsers load them async)
    if (this.synth.onvoiceschanged !== undefined) {
      this.synth.onvoiceschanged = () => this.loadVoices()
    }
    this.loadVoices()
    this.updateCounts()
  }

  disconnect() {
    if (this.synth) {
      this.synth.cancel()
    }
  }

  loadVoices() {
    this.voices = this.synth.getVoices()
    if (!this.hasVoiceSelectTarget) return
    var select = this.voiceSelectTarget
    select.innerHTML = ""

    for (var i = 0; i < this.voices.length; i++) {
      var voice = this.voices[i]
      var option = document.createElement("option")
      option.value = i
      option.textContent = voice.name + " (" + voice.lang + ")"
      if (voice.default) option.selected = true
      select.appendChild(option)
    }
  }

  updateCounts() {
    var text = this.textInputTarget.value
    var charCount = text.length
    var words = text.trim().split(/\s+/).filter(function(w) { return w.length > 0 })
    var wordCount = words.length

    if (this.hasCharCountTarget) {
      this.charCountTarget.textContent = charCount
    }
    if (this.hasWordCountTarget) {
      this.wordCountTarget.textContent = wordCount
    }
  }

  updateRate() {
    if (this.hasRateValueTarget) {
      this.rateValueTarget.textContent = this.rateSliderTarget.value
    }
  }

  updatePitch() {
    if (this.hasPitchValueTarget) {
      this.pitchValueTarget.textContent = this.pitchSliderTarget.value
    }
  }

  updateVolume() {
    if (this.hasVolumeValueTarget) {
      this.volumeValueTarget.textContent = this.volumeSliderTarget.value
    }
  }

  speak() {
    var text = this.textInputTarget.value.trim()
    if (!text) return

    // Cancel any ongoing speech
    this.synth.cancel()

    this.utterance = new SpeechSynthesisUtterance(text)

    // Set voice
    var voiceIndex = parseInt(this.voiceSelectTarget.value)
    if (this.voices[voiceIndex]) {
      this.utterance.voice = this.voices[voiceIndex]
    }

    // Set rate, pitch, volume
    this.utterance.rate = parseFloat(this.rateSliderTarget.value) || 1
    this.utterance.pitch = parseFloat(this.pitchSliderTarget.value) || 1
    this.utterance.volume = parseFloat(this.volumeSliderTarget.value) || 1

    // Event handlers for button states
    this.utterance.onstart = () => {
      this.speakBtnTarget.classList.add("hidden")
      this.pauseBtnTarget.classList.remove("hidden")
      this.resumeBtnTarget.classList.add("hidden")
      this.stopBtnTarget.classList.remove("hidden")
    }

    this.utterance.onend = () => {
      this.resetButtons()
    }

    this.utterance.onerror = () => {
      this.resetButtons()
    }

    this.synth.speak(this.utterance)
  }

  pauseSpeech() {
    if (this.synth.speaking && !this.synth.paused) {
      this.synth.pause()
      this.pauseBtnTarget.classList.add("hidden")
      this.resumeBtnTarget.classList.remove("hidden")
    }
  }

  resumeSpeech() {
    if (this.synth.paused) {
      this.synth.resume()
      this.resumeBtnTarget.classList.add("hidden")
      this.pauseBtnTarget.classList.remove("hidden")
    }
  }

  stopSpeech() {
    this.synth.cancel()
    this.resetButtons()
  }

  resetButtons() {
    this.speakBtnTarget.classList.remove("hidden")
    this.pauseBtnTarget.classList.add("hidden")
    this.resumeBtnTarget.classList.add("hidden")
    this.stopBtnTarget.classList.add("hidden")
  }
}
