import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileInput", "dropZone", "imagePreview", "dataUriOutput", "base64Input",
    "resultFileName", "resultFileSize", "resultMimeType", "resultBase64Length",
    "reverseInput", "reversePreview"
  ]

  connect() {
    const dropZone = this.dropZoneTarget
    dropZone.addEventListener("dragover", (e) => {
      e.preventDefault()
      dropZone.classList.add("border-blue-500", "bg-blue-50", "dark:bg-blue-900/20")
    })
    dropZone.addEventListener("dragleave", (e) => {
      e.preventDefault()
      dropZone.classList.remove("border-blue-500", "bg-blue-50", "dark:bg-blue-900/20")
    })
    dropZone.addEventListener("drop", (e) => {
      e.preventDefault()
      dropZone.classList.remove("border-blue-500", "bg-blue-50", "dark:bg-blue-900/20")
      const files = e.dataTransfer.files
      if (files.length > 0) {
        this.processFile(files[0])
      }
    })
  }

  onFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.processFile(file)
    }
  }

  processFile(file) {
    if (!file.type.startsWith("image/")) {
      this.showError("Please select an image file")
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      const dataUri = e.target.result
      const base64Only = dataUri.split(",")[1]

      // Show preview
      this.imagePreviewTarget.innerHTML = `<img src="${dataUri}" alt="Preview" class="max-w-full max-h-64 mx-auto rounded-lg">`

      // Show data URI
      this.dataUriOutputTarget.value = dataUri

      // Show stats
      this.resultFileNameTarget.textContent = file.name
      this.resultFileSizeTarget.textContent = this.humanFileSize(file.size)
      this.resultMimeTypeTarget.textContent = file.type
      this.resultBase64LengthTarget.textContent = base64Only.length.toLocaleString() + " chars"
    }
    reader.readAsDataURL(file)
  }

  copyDataUri() {
    const text = this.dataUriOutputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      this.flashButton("[data-action*='copyDataUri']", "Copied!")
    })
  }

  copyBase64Only() {
    const dataUri = this.dataUriOutputTarget.value
    if (!dataUri) return
    const base64Only = dataUri.includes(",") ? dataUri.split(",")[1] : dataUri
    navigator.clipboard.writeText(base64Only).then(() => {
      this.flashButton("[data-action*='copyBase64Only']", "Copied!")
    })
  }

  decodeDataUri() {
    const input = this.reverseInputTarget.value.trim()
    if (!input) {
      this.reversePreviewTarget.innerHTML = '<p class="text-gray-400 text-center py-4">Paste a data URI above to see the decoded image</p>'
      return
    }

    let dataUri = input
    if (!input.startsWith("data:")) {
      // Assume it is raw base64 for a PNG
      dataUri = "data:image/png;base64," + input
    }

    try {
      this.reversePreviewTarget.innerHTML = `<img src="${dataUri}" alt="Decoded image" class="max-w-full max-h-64 mx-auto rounded-lg" onerror="this.parentElement.innerHTML='<p class=\\'text-red-500 text-center py-4\\'>Invalid image data</p>'">`
    } catch (e) {
      this.reversePreviewTarget.innerHTML = '<p class="text-red-500 text-center py-4">Invalid data URI format</p>'
    }
  }

  showError(message) {
    this.imagePreviewTarget.innerHTML = `<p class="text-red-500 text-center py-4">${message}</p>`
    this.dataUriOutputTarget.value = ""
    this.resultFileNameTarget.textContent = "\u2014"
    this.resultFileSizeTarget.textContent = "\u2014"
    this.resultMimeTypeTarget.textContent = "\u2014"
    this.resultBase64LengthTarget.textContent = "\u2014"
  }

  humanFileSize(bytes) {
    if (bytes < 1024) return bytes + " B"
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB"
    return (bytes / (1024 * 1024)).toFixed(1) + " MB"
  }

  flashButton(selector, message) {
    const btn = this.element.querySelector(selector)
    if (btn) {
      const original = btn.textContent
      btn.textContent = message
      setTimeout(() => { btn.textContent = original }, 1500)
    }
  }
}
