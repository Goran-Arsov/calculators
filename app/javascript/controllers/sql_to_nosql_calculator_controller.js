import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sqlInput", "output", "explanation", "error"]

  convert() {
    const sql = this.sqlInputTarget.value.trim()

    if (!sql) {
      this.showError("Please enter a SQL query to convert.")
      return
    }

    this.hideError()

    try {
      const result = this.convertSQL(sql)
      this.outputTarget.value = result.query
      this.explanationTarget.textContent = result.explanation
    } catch (e) {
      this.showError("Could not parse the SQL query. Please check the syntax.")
    }
  }

  convertSQL(sql) {
    const normalized = sql.replace(/\s+/g, " ").trim()

    // SELECT
    let match = normalized.match(/^SELECT\s+(.+?)\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+?))?(?:\s+ORDER\s+BY\s+(.+?))?(?:\s+LIMIT\s+(\d+))?\s*;?$/i)
    if (match) return this.convertSelect(match)

    // INSERT
    match = normalized.match(/^INSERT\s+INTO\s+(\w+)\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\)\s*;?$/i)
    if (match) return this.convertInsert(match)

    // UPDATE
    match = normalized.match(/^UPDATE\s+(\w+)\s+SET\s+(.+?)\s+WHERE\s+(.+?)\s*;?$/i)
    if (match) return this.convertUpdate(match)

    // DELETE
    match = normalized.match(/^DELETE\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+?))?\s*;?$/i)
    if (match) return this.convertDelete(match)

    // CREATE TABLE
    match = normalized.match(/^CREATE\s+TABLE\s+(\w+)\s*\(([^)]+)\)\s*;?$/i)
    if (match) return { query: `db.createCollection("${match[1]}")`, explanation: "CREATE TABLE maps to db.createCollection(). MongoDB is schema-less." }

    // DROP TABLE
    match = normalized.match(/^DROP\s+TABLE\s+(\w+)\s*;?$/i)
    if (match) return { query: `db.${match[1]}.drop()`, explanation: "DROP TABLE maps to db.collection.drop()." }

    return { query: "// Could not automatically convert this query.", explanation: "Supported: SELECT, INSERT, UPDATE, DELETE, CREATE TABLE, DROP TABLE." }
  }

  convertSelect(match) {
    const fields = match[1].trim()
    const table = match[2]
    const where = match[3]
    const order = match[4]
    const limit = match[5]

    const projection = fields === "*" ? "" : `, { ${fields.split(",").map(f => `${f.trim()}: 1`).join(", ")} }`
    const filter = where ? this.parseWhere(where) : "{}"

    let query = `db.${table}.find(${filter}${projection})`
    if (order) query += `.sort(${this.parseOrder(order)})`
    if (limit) query += `.limit(${limit})`

    return { query, explanation: "SELECT maps to db.collection.find(). WHERE becomes the filter, fields become projection." }
  }

  convertInsert(match) {
    const table = match[1]
    const cols = match[2].split(",").map(c => c.trim())
    const vals = match[3].split(",").map(v => this.cleanValue(v.trim()))
    const doc = cols.map((c, i) => `  ${c}: ${vals[i]}`).join(",\n")
    return { query: `db.${table}.insertOne({\n${doc}\n})`, explanation: "INSERT INTO maps to db.collection.insertOne()." }
  }

  convertUpdate(match) {
    const table = match[1]
    const setParts = match[2].split(",").map(p => {
      const [f, v] = p.split("=").map(s => s.trim())
      return `    ${f}: ${this.cleanValue(v)}`
    }).join(",\n")
    const filter = this.parseWhere(match[3])
    return { query: `db.${table}.updateMany(${filter}, {\n  $set: {\n${setParts}\n  }\n})`, explanation: "UPDATE maps to db.collection.updateMany() with $set." }
  }

  convertDelete(match) {
    const table = match[1]
    const filter = match[2] ? this.parseWhere(match[2]) : "{}"
    return { query: `db.${table}.deleteMany(${filter})`, explanation: "DELETE FROM maps to db.collection.deleteMany()." }
  }

  parseWhere(str) {
    const conditions = str.split(/\s+AND\s+/i)
    const parts = conditions.map(c => this.parseCondition(c.trim()))
    return `{ ${parts.join(", ")} }`
  }

  parseCondition(cond) {
    const match = cond.match(/(\w+)\s*(>=|<=|!=|<>|>|<|=|LIKE)\s*(.+)/i)
    if (!match) return `// ${cond}`

    const field = match[1]
    const op = match[2].toUpperCase()
    const value = this.cleanValue(match[3].trim())

    switch (op) {
      case "=": return `${field}: ${value}`
      case ">": return `${field}: { $gt: ${value} }`
      case ">=": return `${field}: { $gte: ${value} }`
      case "<": return `${field}: { $lt: ${value} }`
      case "<=": return `${field}: { $lte: ${value} }`
      case "!=": case "<>": return `${field}: { $ne: ${value} }`
      case "LIKE": {
        const pattern = value.replace(/^["']|["']$/g, "").replace(/%/g, ".*")
        return `${field}: /${pattern}/`
      }
      default: return `${field}: ${value}`
    }
  }

  parseOrder(str) {
    const parts = str.split(",").map(p => {
      const tokens = p.trim().split(/\s+/)
      const dir = tokens[1] && tokens[1].toUpperCase() === "DESC" ? -1 : 1
      return `${tokens[0]}: ${dir}`
    })
    return `{ ${parts.join(", ")} }`
  }

  cleanValue(val) {
    val = val.replace(/^['"]|['"]$/g, "")
    if (/^-?\d+(\.\d+)?$/.test(val)) return val
    if (val.toLowerCase() === "true") return "true"
    if (val.toLowerCase() === "false") return "false"
    if (val.toLowerCase() === "null") return "null"
    return `"${val}"`
  }

  showError(msg) {
    this.errorTarget.textContent = msg
    this.errorTarget.classList.remove("hidden")
  }

  hideError() {
    this.errorTarget.classList.add("hidden")
  }

  copy() {
    const text = this.outputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) {
        const orig = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = orig }, 1500)
      }
    })
  }

  clear() {
    this.sqlInputTarget.value = ""
    this.outputTarget.value = ""
    this.explanationTarget.textContent = ""
    this.hideError()
  }
}
