import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fromIngredient", "toIngredient", "amount",
    "results", "convertedAmount", "ratio", "note", "toOptions"
  ]

  static values = {
    substitutions: { type: Object, default: {} }
  }

  // Substitution data embedded in controller
  get subs() {
    return {
      butter: {
        oil: { ratio: 0.75, note: "Use 3/4 the amount of oil for butter." },
        applesauce: { ratio: 0.5, note: "Use half the amount of applesauce for butter. Reduces fat and adds moisture." },
        coconut_oil: { ratio: 1.0, note: "Coconut oil substitutes 1:1 for butter." },
        margarine: { ratio: 1.0, note: "Margarine substitutes 1:1 for butter." }
      },
      oil: {
        butter: { ratio: 1.33, note: "Use 1-1/3 the amount of butter for oil." },
        applesauce: { ratio: 1.0, note: "Applesauce substitutes 1:1 for oil in baking." }
      },
      all_purpose_flour: {
        cake_flour: { ratio: 1.125, note: "Use 1-1/8 cups cake flour per cup of all-purpose. Remove 2 tbsp per cup and replace with cornstarch." },
        bread_flour: { ratio: 1.0, note: "Bread flour substitutes 1:1 but produces chewier results." },
        whole_wheat_flour: { ratio: 0.75, note: "Replace only 75% to avoid dense results. Start with half whole wheat." },
        almond_flour: { ratio: 1.0, note: "1:1 ratio but add a binding agent (egg or xanthan gum). Results will be denser." },
        oat_flour: { ratio: 1.0, note: "Oat flour substitutes 1:1 for all-purpose flour." }
      },
      white_sugar: {
        brown_sugar: { ratio: 1.0, note: "Brown sugar substitutes 1:1. Pack firmly when measuring." },
        honey: { ratio: 0.75, note: "Use 3/4 the amount of honey. Reduce other liquids by 1/4 cup per cup of honey." },
        maple_syrup: { ratio: 0.75, note: "Use 3/4 the amount of maple syrup. Reduce other liquids by 3 tbsp per cup." },
        coconut_sugar: { ratio: 1.0, note: "Coconut sugar substitutes 1:1 for white sugar." }
      },
      egg: {
        flax_egg: { ratio: 1.0, note: "1 flax egg = 1 tbsp ground flaxseed + 3 tbsp water. Let sit 5 minutes." },
        chia_egg: { ratio: 1.0, note: "1 chia egg = 1 tbsp chia seeds + 3 tbsp water. Let sit 5 minutes." },
        applesauce_egg: { ratio: 1.0, note: "1/4 cup (60 mL) applesauce replaces 1 egg." },
        banana: { ratio: 1.0, note: "1/4 cup (about half a banana) mashed banana replaces 1 egg." },
        yogurt: { ratio: 1.0, note: "1/4 cup yogurt replaces 1 egg." }
      },
      buttermilk: {
        milk_vinegar: { ratio: 1.0, note: "1 cup milk + 1 tbsp vinegar or lemon juice. Let stand 5 minutes." },
        milk_cream_of_tartar: { ratio: 1.0, note: "1 cup milk + 1-3/4 tsp cream of tartar." },
        yogurt: { ratio: 1.0, note: "Thin yogurt with a little milk to buttermilk consistency." }
      }
    }
  }

  connect() {
    this.updateToOptions()
  }

  updateToOptions() {
    const from = this.fromIngredientTarget.value
    const toSelect = this.toOptionsTarget

    toSelect.innerHTML = '<option value="">Select substitute...</option>'

    if (from && this.subs[from]) {
      const labels = {
        oil: "Oil", butter: "Butter", applesauce: "Applesauce", coconut_oil: "Coconut Oil",
        margarine: "Margarine", cake_flour: "Cake Flour", bread_flour: "Bread Flour",
        whole_wheat_flour: "Whole Wheat Flour", almond_flour: "Almond Flour", oat_flour: "Oat Flour",
        brown_sugar: "Brown Sugar", honey: "Honey", maple_syrup: "Maple Syrup",
        coconut_sugar: "Coconut Sugar", flax_egg: "Flax Egg", chia_egg: "Chia Egg",
        applesauce_egg: "Applesauce", banana: "Banana", yogurt: "Yogurt",
        milk_vinegar: "Milk + Vinegar", milk_cream_of_tartar: "Milk + Cream of Tartar"
      }

      Object.keys(this.subs[from]).forEach(key => {
        const option = document.createElement("option")
        option.value = key
        option.textContent = labels[key] || key.replace(/_/g, " ")
        toSelect.appendChild(option)
      })
    }

    this.calculate()
  }

  calculate() {
    const from = this.fromIngredientTarget.value
    const to = this.toOptionsTarget.value
    const amount = parseFloat(this.amountTarget.value) || 0

    if (!from || !to || amount <= 0 || !this.subs[from] || !this.subs[from][to]) {
      this.resultsTarget.classList.add("hidden")
      return
    }

    const sub = this.subs[from][to]
    const converted = (amount * sub.ratio).toFixed(2)

    this.convertedAmountTarget.textContent = converted
    this.ratioTarget.textContent = sub.ratio + ":1"
    this.noteTarget.textContent = sub.note
    this.resultsTarget.classList.remove("hidden")
  }

  copy() {
    const from = this.fromIngredientTarget.value
    const to = this.toOptionsTarget.value
    const amount = this.amountTarget.value
    const converted = this.convertedAmountTarget.textContent
    const note = this.noteTarget.textContent
    const text = `Baking Substitution: ${amount} ${from.replace(/_/g, " ")} = ${converted} ${to.replace(/_/g, " ")}\n${note}`
    navigator.clipboard.writeText(text)
  }
}
