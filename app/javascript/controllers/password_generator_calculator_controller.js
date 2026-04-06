import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "length", "lengthDisplay", "count", "countDisplay",
    "includeLowercase", "includeUppercase", "includeDigits", "includeSymbols",
    "mode", "passwordList", "passphraseOutput",
    "resultPoolSize", "resultEntropy",
    "passwordSection", "passphraseSection",
    "passphraseWordCount", "passphraseWordCountDisplay", "passphraseSeparator"
  ]

  static LOWERCASE = "abcdefghijklmnopqrstuvwxyz"
  static UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  static DIGITS = "0123456789"
  static SYMBOLS = "!@#$%^&*()-_=+[]{}|;:'\",.<>?/~`"

  static WORD_LIST = [
    "anchor", "apple", "arrow", "basket", "beacon", "blank", "bloom", "board",
    "bottle", "brave", "bread", "brick", "bridge", "bright", "broad", "broken",
    "brush", "cabin", "calm", "candle", "canvas", "castle", "cedar", "chain",
    "chair", "chalk", "charm", "chase", "cherry", "child", "cider", "circle",
    "cliff", "clock", "cloud", "coast", "coral", "corner", "craft", "crane",
    "creek", "crown", "crush", "curve", "dance", "delta", "depth", "desert",
    "dream", "drift", "eagle", "earth", "ember", "equal", "event", "extra",
    "fable", "faith", "feast", "field", "flame", "flash", "flour", "focus",
    "forge", "frost", "fruit", "ghost", "giant", "glade", "glass", "globe",
    "grace", "grain", "grape", "grass", "green", "grove", "guard", "guide",
    "happy", "haven", "heart", "hedge", "house", "human", "ivory", "jewel",
    "judge", "juice", "kneel", "knife", "knock", "label", "lance", "latch",
    "lemon", "light", "linen", "lodge", "lunar", "maple", "march", "marsh",
    "medal", "melon", "metal", "might", "minor", "mirth", "moist", "month",
    "moose", "mount", "music", "noble", "north", "novel", "ocean", "olive",
    "orbit", "otter", "outer", "panel", "paper", "pearl", "penny", "phase",
    "piano", "pilot", "plain", "plant", "plumb", "point", "polar", "pond",
    "power", "press", "pride", "prize", "proof", "pulse", "queen", "quest",
    "quick", "quiet", "quote", "ranch", "rapid", "raven", "reach", "realm",
    "ridge", "river", "robin", "royal", "ruler", "saint", "scale", "scene",
    "scout", "shade", "sheep", "shelf", "shell", "shine", "shore", "sigma",
    "silk", "slate", "slope", "smile", "smoke", "snake", "solar", "south",
    "space", "spark", "spear", "spice", "spine", "spoke", "spray", "stage",
    "stamp", "steam", "steel", "stone", "storm", "stove", "straw", "sugar",
    "sweep", "swift", "sword", "table", "tiger", "toast", "token", "tower",
    "trace", "trail", "train", "trend", "tribe", "trout", "trunk", "tulip",
    "ultra", "unity", "upper", "urban", "valid", "vapor", "vault", "verse",
    "vigor", "vivid", "voice", "watch", "water", "whale", "wheel", "whole",
    "width", "world", "worth", "wound", "wrist", "youth", "zebra", "blend"
  ]

  connect() {
    this.updateLengthDisplay()
    this.updateCountDisplay()
    if (this.hasPassphraseWordCountDisplayTarget) {
      this.updatePassphraseWordCountDisplay()
    }
  }

  updateLengthDisplay() {
    if (this.hasLengthDisplayTarget) {
      this.lengthDisplayTarget.textContent = this.lengthTarget.value
    }
  }

  updateCountDisplay() {
    if (this.hasCountDisplayTarget) {
      this.countDisplayTarget.textContent = this.countTarget.value
    }
  }

  updatePassphraseWordCountDisplay() {
    if (this.hasPassphraseWordCountDisplayTarget) {
      this.passphraseWordCountDisplayTarget.textContent = this.passphraseWordCountTarget.value
    }
  }

  switchMode(event) {
    const mode = event.currentTarget.value
    if (mode === "password") {
      this.passwordSectionTarget.classList.remove("hidden")
      this.passphraseSectionTarget.classList.add("hidden")
    } else {
      this.passwordSectionTarget.classList.add("hidden")
      this.passphraseSectionTarget.classList.remove("hidden")
    }
  }

  generate() {
    this.updateLengthDisplay()
    this.updateCountDisplay()

    const length = parseInt(this.lengthTarget.value) || 16
    const count = parseInt(this.countTarget.value) || 1
    const useLower = this.includeLowercaseTarget.checked
    const useUpper = this.includeUppercaseTarget.checked
    const useDigits = this.includeDigitsTarget.checked
    const useSymbols = this.includeSymbolsTarget.checked

    if (!useLower && !useUpper && !useDigits && !useSymbols) {
      this.passwordListTarget.innerHTML = '<p class="text-red-500 text-sm">Select at least one character type.</p>'
      this.resultPoolSizeTarget.textContent = "--"
      this.resultEntropyTarget.textContent = "-- bits"
      return
    }

    let pool = ""
    const required = []

    if (useLower) {
      pool += this.constructor.LOWERCASE
      required.push("lower")
    }
    if (useUpper) {
      pool += this.constructor.UPPERCASE
      required.push("upper")
    }
    if (useDigits) {
      pool += this.constructor.DIGITS
      required.push("digits")
    }
    if (useSymbols) {
      pool += this.constructor.SYMBOLS
      required.push("symbols")
    }

    const passwords = []
    for (let i = 0; i < count; i++) {
      passwords.push(this.generateOne(pool, length, useLower, useUpper, useDigits, useSymbols))
    }

    const poolSize = pool.length
    const entropy = (length * Math.log2(poolSize)).toFixed(1)

    this.resultPoolSizeTarget.textContent = poolSize
    this.resultEntropyTarget.textContent = entropy + " bits"

    this.passwordListTarget.innerHTML = passwords.map((pw, i) =>
      `<div class="flex items-center gap-2 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-3">
        <code class="flex-1 font-mono text-sm text-gray-900 dark:text-white break-all" data-pw-index="${i}">${this.escapeHtml(pw)}</code>
        <button data-action="click->password-generator-calculator#copyOne" data-pw-value="${this.escapeAttr(pw)}"
                class="shrink-0 px-3 py-1.5 text-xs font-medium text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 rounded-lg hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-colors">
          Copy
        </button>
      </div>`
    ).join("")
  }

  generatePassphrase() {
    this.updatePassphraseWordCountDisplay()

    const wordCount = parseInt(this.passphraseWordCountTarget.value) || 4
    const separator = this.passphraseSeparatorTarget.value || "-"
    const words = this.constructor.WORD_LIST
    const selected = []

    for (let i = 0; i < wordCount; i++) {
      const index = this.secureRandomInt(words.length)
      selected.push(words[index])
    }

    const passphrase = selected.join(separator)
    const entropy = (wordCount * Math.log2(words.length)).toFixed(1)

    this.passphraseOutputTarget.innerHTML =
      `<div class="flex items-center gap-2 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-3">
        <code class="flex-1 font-mono text-sm text-gray-900 dark:text-white break-all">${this.escapeHtml(passphrase)}</code>
        <button data-action="click->password-generator-calculator#copyOne" data-pw-value="${this.escapeAttr(passphrase)}"
                class="shrink-0 px-3 py-1.5 text-xs font-medium text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 rounded-lg hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-colors">
          Copy
        </button>
      </div>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-2">Entropy: ${entropy} bits (${wordCount} words from ${words.length}-word list)</p>`
  }

  generateOne(pool, length, useLower, useUpper, useDigits, useSymbols) {
    const required = []
    if (useLower) required.push(this.randomChar(this.constructor.LOWERCASE))
    if (useUpper) required.push(this.randomChar(this.constructor.UPPERCASE))
    if (useDigits) required.push(this.randomChar(this.constructor.DIGITS))
    if (useSymbols) required.push(this.randomChar(this.constructor.SYMBOLS))

    const remaining = length - required.length
    const chars = [...required]
    for (let i = 0; i < remaining; i++) {
      chars.push(this.randomChar(pool))
    }

    for (let i = chars.length - 1; i > 0; i--) {
      const j = this.secureRandomInt(i + 1)
      ;[chars[i], chars[j]] = [chars[j], chars[i]]
    }

    return chars.join("")
  }

  randomChar(source) {
    return source[this.secureRandomInt(source.length)]
  }

  secureRandomInt(max) {
    const array = new Uint32Array(1)
    crypto.getRandomValues(array)
    return array[0] % max
  }

  copyOne(event) {
    const value = event.currentTarget.dataset.pwValue
    if (!value) return
    navigator.clipboard.writeText(value).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 1500)
    })
  }

  copy() {
    const codes = this.passwordListTarget.querySelectorAll("code")
    const text = Array.from(codes).map(el => el.textContent).join("\n")
    if (!text) return
    navigator.clipboard.writeText(text)
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  escapeAttr(str) {
    return str.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/'/g, "&#39;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }
}
