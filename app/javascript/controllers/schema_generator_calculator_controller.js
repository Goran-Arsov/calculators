import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "typeSelect", "fieldsContainer", "output", "validationResult"
  ]

  static values = { faqCount: { type: Number, default: 1 }, ingredientCount: { type: Number, default: 1 }, instructionCount: { type: Number, default: 1 } }

  connect() {
    this.renderFields()
  }

  changeType() {
    this.faqCountValue = 1
    this.ingredientCountValue = 1
    this.instructionCountValue = 1
    this.renderFields()
    this.outputTarget.value = ""
    this.validationResultTarget.innerHTML = ""
  }

  renderFields() {
    const type = this.typeSelectTarget.value
    let html = ""

    const inputClass = "w-full rounded-xl border-[1.5px] border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white p-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
    const labelClass = "block text-sm font-semibold text-gray-600 dark:text-gray-400 mb-1.5"

    switch (type) {
      case "article":
        html = `
          <div><label class="${labelClass}">Headline *</label><input type="text" data-field="headline" class="${inputClass}" placeholder="Article headline"></div>
          <div><label class="${labelClass}">Author *</label><input type="text" data-field="author" class="${inputClass}" placeholder="Author name"></div>
          <div><label class="${labelClass}">Date Published *</label><input type="date" data-field="datePublished" class="${inputClass}"></div>
          <div><label class="${labelClass}">Image URL</label><input type="text" data-field="image" class="${inputClass}" placeholder="https://example.com/image.jpg"></div>
          <div><label class="${labelClass}">Publisher</label><input type="text" data-field="publisher" class="${inputClass}" placeholder="Publisher name"></div>`
        break
      case "product":
        html = `
          <div><label class="${labelClass}">Product Name *</label><input type="text" data-field="name" class="${inputClass}" placeholder="Product name"></div>
          <div><label class="${labelClass}">Description *</label><input type="text" data-field="description" class="${inputClass}" placeholder="Product description"></div>
          <div><label class="${labelClass}">Image URL</label><input type="text" data-field="image" class="${inputClass}" placeholder="https://example.com/product.jpg"></div>
          <div class="grid grid-cols-2 gap-4">
            <div><label class="${labelClass}">Price *</label><input type="text" data-field="price" class="${inputClass}" placeholder="29.99"></div>
            <div><label class="${labelClass}">Currency *</label><input type="text" data-field="currency" class="${inputClass}" value="USD" placeholder="USD"></div>
          </div>
          <div><label class="${labelClass}">Availability</label>
            <select data-field="availability" class="${inputClass}">
              <option value="https://schema.org/InStock">In Stock</option>
              <option value="https://schema.org/OutOfStock">Out of Stock</option>
              <option value="https://schema.org/PreOrder">Pre-Order</option>
              <option value="https://schema.org/Discontinued">Discontinued</option>
            </select></div>
          <div><label class="${labelClass}">Brand</label><input type="text" data-field="brand" class="${inputClass}" placeholder="Brand name"></div>`
        break
      case "faq":
        html = this._buildFaqFields()
        break
      case "local_business":
        html = `
          <div><label class="${labelClass}">Business Name *</label><input type="text" data-field="name" class="${inputClass}" placeholder="Business name"></div>
          <div><label class="${labelClass}">Address *</label><input type="text" data-field="address" class="${inputClass}" placeholder="123 Main St, City, State ZIP"></div>
          <div><label class="${labelClass}">Phone *</label><input type="text" data-field="phone" class="${inputClass}" placeholder="+1-555-123-4567"></div>
          <div><label class="${labelClass}">Website URL</label><input type="text" data-field="url" class="${inputClass}" placeholder="https://example.com"></div>
          <div><label class="${labelClass}">Opening Hours</label><input type="text" data-field="openingHours" class="${inputClass}" placeholder="Mo-Fr 09:00-17:00"></div>`
        break
      case "event":
        html = `
          <div><label class="${labelClass}">Event Name *</label><input type="text" data-field="name" class="${inputClass}" placeholder="Event name"></div>
          <div class="grid grid-cols-2 gap-4">
            <div><label class="${labelClass}">Start Date *</label><input type="datetime-local" data-field="startDate" class="${inputClass}"></div>
            <div><label class="${labelClass}">End Date</label><input type="datetime-local" data-field="endDate" class="${inputClass}"></div>
          </div>
          <div><label class="${labelClass}">Location *</label><input type="text" data-field="location" class="${inputClass}" placeholder="Venue name or address"></div>
          <div><label class="${labelClass}">Description</label><input type="text" data-field="description" class="${inputClass}" placeholder="Event description"></div>`
        break
      case "recipe":
        html = `
          <div><label class="${labelClass}">Recipe Name *</label><input type="text" data-field="name" class="${inputClass}" placeholder="Recipe name"></div>
          <div class="grid grid-cols-2 gap-4">
            <div><label class="${labelClass}">Prep Time</label><input type="text" data-field="prepTime" class="${inputClass}" placeholder="PT15M"></div>
            <div><label class="${labelClass}">Cook Time</label><input type="text" data-field="cookTime" class="${inputClass}" placeholder="PT30M"></div>
          </div>
          <div>
            <label class="${labelClass}">Ingredients *</label>
            <div data-list="ingredients">${this._buildListItems("ingredients", this.ingredientCountValue)}</div>
            <button type="button" data-action="click->schema-generator-calculator#addIngredient" class="mt-2 text-xs px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors">+ Add Ingredient</button>
          </div>
          <div>
            <label class="${labelClass}">Instructions *</label>
            <div data-list="instructions">${this._buildListItems("instructions", this.instructionCountValue)}</div>
            <button type="button" data-action="click->schema-generator-calculator#addInstruction" class="mt-2 text-xs px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors">+ Add Step</button>
          </div>`
        break
    }

    this.fieldsContainerTarget.innerHTML = `<div class="space-y-4">${html}</div>`
  }

  _buildFaqFields() {
    const inputClass = "w-full rounded-xl border-[1.5px] border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white p-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
    const labelClass = "block text-sm font-semibold text-gray-600 dark:text-gray-400 mb-1.5"
    let html = ""
    for (let i = 0; i < this.faqCountValue; i++) {
      html += `
        <div class="bg-gray-50 dark:bg-gray-800 rounded-xl p-4 space-y-3">
          <div class="flex justify-between items-center">
            <span class="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Q&A #${i + 1}</span>
            ${i > 0 ? `<button type="button" data-action="click->schema-generator-calculator#removeFaq" data-index="${i}" class="text-xs text-red-500 hover:text-red-700">Remove</button>` : ""}
          </div>
          <div><label class="${labelClass}">Question</label><input type="text" data-faq-question="${i}" class="${inputClass}" placeholder="Enter question"></div>
          <div><label class="${labelClass}">Answer</label><textarea data-faq-answer="${i}" class="${inputClass}" rows="2" placeholder="Enter answer"></textarea></div>
        </div>`
    }
    html += `<button type="button" data-action="click->schema-generator-calculator#addFaq" class="text-xs px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-lg hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors">+ Add Q&A</button>`
    return html
  }

  _buildListItems(name, count) {
    const inputClass = "w-full rounded-xl border-[1.5px] border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white p-3 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
    let html = ""
    for (let i = 0; i < count; i++) {
      html += `<div class="flex gap-2 mb-2">
        <input type="text" data-list-item="${name}" class="${inputClass}" placeholder="${name === 'ingredients' ? 'e.g. 2 cups flour' : 'Step ' + (i + 1)}">
        ${i > 0 ? `<button type="button" data-action="click->schema-generator-calculator#removeListItem" data-list-name="${name}" class="text-red-500 hover:text-red-700 text-xs px-2">X</button>` : ""}
      </div>`
    }
    return html
  }

  addFaq() {
    this.faqCountValue++
    // Save current values
    const saved = this._saveFaqValues()
    this.renderFields()
    this._restoreFaqValues(saved)
  }

  removeFaq(event) {
    if (this.faqCountValue > 1) {
      const idx = parseInt(event.currentTarget.dataset.index)
      const saved = this._saveFaqValues()
      saved.splice(idx, 1)
      this.faqCountValue--
      this.renderFields()
      this._restoreFaqValues(saved)
    }
  }

  addIngredient() {
    this.ingredientCountValue++
    this.renderFields()
  }

  addInstruction() {
    this.instructionCountValue++
    this.renderFields()
  }

  removeListItem(event) {
    const listName = event.currentTarget.dataset.listName
    const parent = event.currentTarget.closest("[class*='flex']")
    if (parent) parent.remove()
    if (listName === "ingredients") this.ingredientCountValue--
    if (listName === "instructions") this.instructionCountValue--
  }

  _saveFaqValues() {
    const saved = []
    for (let i = 0; i < this.faqCountValue; i++) {
      const q = this.element.querySelector(`[data-faq-question="${i}"]`)
      const a = this.element.querySelector(`[data-faq-answer="${i}"]`)
      saved.push({ question: q ? q.value : "", answer: a ? a.value : "" })
    }
    return saved
  }

  _restoreFaqValues(saved) {
    saved.forEach((pair, i) => {
      const q = this.element.querySelector(`[data-faq-question="${i}"]`)
      const a = this.element.querySelector(`[data-faq-answer="${i}"]`)
      if (q) q.value = pair.question
      if (a) a.value = pair.answer
    })
  }

  generate() {
    const type = this.typeSelectTarget.value
    let schema = {}

    switch (type) {
      case "article":
        schema = {
          "@context": "https://schema.org",
          "@type": "Article",
          "headline": this._fieldVal("headline"),
          "author": { "@type": "Person", "name": this._fieldVal("author") },
          "datePublished": this._fieldVal("datePublished")
        }
        if (this._fieldVal("image")) schema.image = this._fieldVal("image")
        if (this._fieldVal("publisher")) schema.publisher = { "@type": "Organization", "name": this._fieldVal("publisher") }
        break
      case "product":
        schema = {
          "@context": "https://schema.org",
          "@type": "Product",
          "name": this._fieldVal("name"),
          "description": this._fieldVal("description"),
          "offers": {
            "@type": "Offer",
            "price": this._fieldVal("price"),
            "priceCurrency": this._fieldVal("currency") || "USD",
            "availability": this._fieldVal("availability") || "https://schema.org/InStock"
          }
        }
        if (this._fieldVal("image")) schema.image = this._fieldVal("image")
        if (this._fieldVal("brand")) schema.brand = { "@type": "Brand", "name": this._fieldVal("brand") }
        break
      case "faq":
        const entries = []
        for (let i = 0; i < this.faqCountValue; i++) {
          const q = this.element.querySelector(`[data-faq-question="${i}"]`)
          const a = this.element.querySelector(`[data-faq-answer="${i}"]`)
          if (q && a && q.value.trim() && a.value.trim()) {
            entries.push({ "@type": "Question", "name": q.value.trim(), "acceptedAnswer": { "@type": "Answer", "text": a.value.trim() } })
          }
        }
        schema = { "@context": "https://schema.org", "@type": "FAQPage", "mainEntity": entries }
        break
      case "local_business":
        schema = {
          "@context": "https://schema.org",
          "@type": "LocalBusiness",
          "name": this._fieldVal("name"),
          "address": this._fieldVal("address"),
          "telephone": this._fieldVal("phone")
        }
        if (this._fieldVal("url")) schema.url = this._fieldVal("url")
        if (this._fieldVal("openingHours")) schema.openingHours = this._fieldVal("openingHours")
        break
      case "event":
        schema = {
          "@context": "https://schema.org",
          "@type": "Event",
          "name": this._fieldVal("name"),
          "startDate": this._fieldVal("startDate"),
          "location": { "@type": "Place", "name": this._fieldVal("location") }
        }
        if (this._fieldVal("endDate")) schema.endDate = this._fieldVal("endDate")
        if (this._fieldVal("description")) schema.description = this._fieldVal("description")
        break
      case "recipe":
        const ingredients = Array.from(this.element.querySelectorAll('[data-list-item="ingredients"]')).map(el => el.value.trim()).filter(v => v)
        const instructions = Array.from(this.element.querySelectorAll('[data-list-item="instructions"]')).map(el => el.value.trim()).filter(v => v)
        schema = {
          "@context": "https://schema.org",
          "@type": "Recipe",
          "name": this._fieldVal("name"),
          "recipeIngredient": ingredients,
          "recipeInstructions": instructions.map((step, i) => ({ "@type": "HowToStep", "position": i + 1, "text": step }))
        }
        if (this._fieldVal("prepTime")) schema.prepTime = this._fieldVal("prepTime")
        if (this._fieldVal("cookTime")) schema.cookTime = this._fieldVal("cookTime")
        break
    }

    this.outputTarget.value = JSON.stringify(schema, null, 2)
    this.validationResultTarget.innerHTML = ""
  }

  validate() {
    const output = this.outputTarget.value.trim()
    if (!output) {
      this.validationResultTarget.innerHTML = '<span class="text-yellow-600 dark:text-yellow-400 text-sm">Generate schema first before validating.</span>'
      return
    }

    try {
      const schema = JSON.parse(output)
      const issues = []

      if (!schema["@context"]) issues.push("Missing @context")
      if (!schema["@type"]) issues.push("Missing @type")

      const type = schema["@type"]
      if (type === "Article") {
        if (!schema.headline) issues.push("Missing headline")
        if (!schema.author) issues.push("Missing author")
        if (!schema.datePublished) issues.push("Missing datePublished")
      } else if (type === "Product") {
        if (!schema.name) issues.push("Missing name")
        if (!schema.offers || !schema.offers.price) issues.push("Missing price")
      } else if (type === "FAQPage") {
        if (!schema.mainEntity || schema.mainEntity.length === 0) issues.push("At least one Q&A is required")
      } else if (type === "LocalBusiness") {
        if (!schema.name) issues.push("Missing name")
        if (!schema.address) issues.push("Missing address")
        if (!schema.telephone) issues.push("Missing telephone")
      } else if (type === "Event") {
        if (!schema.name) issues.push("Missing name")
        if (!schema.startDate) issues.push("Missing startDate")
      } else if (type === "Recipe") {
        if (!schema.name) issues.push("Missing name")
        if (!schema.recipeIngredient || schema.recipeIngredient.length === 0) issues.push("Missing ingredients")
      }

      if (issues.length === 0) {
        this.validationResultTarget.innerHTML = '<div class="flex items-center gap-2 text-green-600 dark:text-green-400 text-sm"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/></svg>Valid! All required fields are present.</div>'
      } else {
        this.validationResultTarget.innerHTML = `<div class="text-red-600 dark:text-red-400 text-sm"><p class="font-semibold mb-1">Validation issues:</p><ul class="list-disc pl-5">${issues.map(i => `<li>${i}</li>`).join("")}</ul></div>`
      }
    } catch (e) {
      this.validationResultTarget.innerHTML = '<span class="text-red-600 dark:text-red-400 text-sm">Invalid JSON syntax.</span>'
    }
  }

  copy() {
    const text = this.outputTarget.value
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }

  _fieldVal(name) {
    const el = this.element.querySelector(`[data-field="${name}"]`)
    return el ? el.value.trim() : ""
  }
}
