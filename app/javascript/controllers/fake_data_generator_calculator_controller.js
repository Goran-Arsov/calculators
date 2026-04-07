import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "countInput", "fieldCheckboxes", "resultsTable", "resultsArea",
    "statusMessage", "copyArea"
  ]

  FIRST_NAMES = [
    "James","Mary","Robert","Patricia","John","Jennifer","Michael","Linda","David","Elizabeth",
    "William","Barbara","Richard","Susan","Joseph","Jessica","Thomas","Sarah","Charles","Karen",
    "Christopher","Lisa","Daniel","Nancy","Matthew","Betty","Mark","Sandra","Donald","Ashley",
    "Steven","Emily","Paul","Kimberly","Andrew","Donna","Joshua","Michelle","Kenneth","Carol",
    "George","Amanda","Edward","Dorothy","Brian","Melissa","Ronald","Deborah","Timothy","Stephanie"
  ]

  LAST_NAMES = [
    "Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez",
    "Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin",
    "Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson",
    "Walker","Young","Allen","King","Wright","Scott","Torres","Nguyen","Hill","Flores",
    "Green","Adams","Nelson","Baker","Hall","Rivera","Campbell","Mitchell","Carter","Roberts"
  ]

  CITIES = [
    "New York","Los Angeles","Chicago","Houston","Phoenix","Philadelphia","San Antonio",
    "San Diego","Dallas","Austin","Jacksonville","San Francisco","Columbus","Charlotte",
    "Indianapolis","Seattle","Denver","Washington","Nashville","Oklahoma City","Portland",
    "Las Vegas","Memphis","Louisville","Baltimore","Milwaukee","Albuquerque","Tucson",
    "Fresno","Sacramento"
  ]

  COUNTRIES = [
    "United States","Canada","United Kingdom","Germany","France","Australia","Japan",
    "Brazil","India","China","Mexico","Italy","Spain","Netherlands","Sweden","Norway",
    "Denmark","Switzerland","Austria","Belgium","Poland","South Korea","Argentina",
    "Colombia","Chile","New Zealand","Ireland","Portugal","Finland","Greece"
  ]

  COMPANIES = [
    "Acme Corp","TechVibe","Quantum Labs","SkyBridge","Nexus Global","Vertex IO",
    "Pinnacle Inc","Horizon Digital","Atlas Group","Zenith Tech","BluePeak",
    "CoreSync","DataWave","FusionPoint","IgniteHub","LaunchPad","NovaEdge",
    "PulseTech","RedShift","SilverLine"
  ]

  JOB_TITLES = [
    "Software Engineer","Product Manager","Data Analyst","UX Designer",
    "Marketing Manager","Sales Representative","DevOps Engineer",
    "Project Manager","Business Analyst","QA Engineer",
    "Frontend Developer","Backend Developer","Full Stack Developer",
    "System Administrator","Database Administrator","Network Engineer",
    "Technical Writer","Scrum Master","CTO","VP of Engineering"
  ]

  STREET_NAMES = [
    "Main","Oak","Cedar","Elm","Maple","Pine","Birch","Walnut","Cherry","Willow",
    "Park","Lake","Hill","River","Valley","Spring","Meadow","Sunset","Forest","Highland"
  ]

  STREET_TYPES = ["Street","Avenue","Boulevard","Drive","Lane","Road","Way","Court","Place","Circle"]

  DOMAINS = ["gmail.com","yahoo.com","outlook.com","hotmail.com","proton.me","icloud.com","mail.com","fastmail.com","zoho.com","tutanota.com"]

  connect() {
    this.records = []
  }

  generate() {
    const count = parseInt(this.countInputTarget.value, 10) || 10
    if (count < 1 || count > 100) {
      this.showStatus("Count must be between 1 and 100", "error")
      return
    }

    const fields = this.getSelectedFields()
    if (fields.length === 0) {
      this.showStatus("Select at least one field", "error")
      return
    }

    this.records = []
    for (let i = 0; i < count; i++) {
      this.records.push(this.generateRecord(fields))
    }

    this.renderTable(fields)
    this.showStatus(`Generated ${count} records with ${fields.length} fields`, "success")
    this.copyAreaTarget.classList.remove("hidden")
  }

  getSelectedFields() {
    const checkboxes = this.fieldCheckboxesTarget.querySelectorAll("input[type=checkbox]:checked")
    return Array.from(checkboxes).map(cb => cb.value)
  }

  generateRecord(fields) {
    const first = this.pick(this.FIRST_NAMES)
    const last = this.pick(this.LAST_NAMES)
    const record = {}

    for (const field of fields) {
      switch (field) {
        case "first_name": record[field] = first; break
        case "last_name": record[field] = last; break
        case "full_name": record[field] = `${first} ${last}`; break
        case "email": record[field] = this.genEmail(first, last); break
        case "phone": record[field] = this.genPhone(); break
        case "address": record[field] = this.genAddress(); break
        case "city": record[field] = this.pick(this.CITIES); break
        case "country": record[field] = this.pick(this.COUNTRIES); break
        case "company": record[field] = this.pick(this.COMPANIES); break
        case "job_title": record[field] = this.pick(this.JOB_TITLES); break
        case "username": record[field] = this.genUsername(first, last); break
        case "password": record[field] = this.genPassword(); break
        case "uuid": record[field] = this.genUuid(); break
        case "ip_address": record[field] = this.genIp(); break
        case "date": record[field] = this.genDate(); break
        case "url": record[field] = this.genUrl(); break
      }
    }
    return record
  }

  pick(arr) { return arr[Math.floor(Math.random() * arr.length)] }

  genEmail(first, last) {
    const seps = [".", "_", ""]
    const sep = this.pick(seps)
    const num = Math.random() > 0.5 ? Math.floor(Math.random() * 999) + 1 : ""
    return `${first.toLowerCase()}${sep}${last.toLowerCase()}${num}@${this.pick(this.DOMAINS)}`
  }

  genPhone() {
    const a = Math.floor(Math.random() * 800) + 200
    const b = Math.floor(Math.random() * 900) + 100
    const c = Math.floor(Math.random() * 9000) + 1000
    return `+1-${a}-${b}-${c}`
  }

  genAddress() {
    const num = Math.floor(Math.random() * 9900) + 100
    return `${num} ${this.pick(this.STREET_NAMES)} ${this.pick(this.STREET_TYPES)}`
  }

  genUsername(first, last) {
    const styles = [
      `${first.toLowerCase()}${last.substring(0,3).toLowerCase()}${Math.floor(Math.random()*90)+10}`,
      `${first[0].toLowerCase()}${last.toLowerCase()}${Math.floor(Math.random()*999)+1}`,
      `${first.toLowerCase()}_${last.toLowerCase()}`
    ]
    return this.pick(styles)
  }

  genPassword() {
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*"
    let pw = ""
    for (let i = 0; i < 16; i++) pw += chars[Math.floor(Math.random() * chars.length)]
    return pw
  }

  genUuid() {
    return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, c => {
      const r = Math.random() * 16 | 0
      return (c === "x" ? r : (r & 0x3 | 0x8)).toString(16)
    })
  }

  genIp() {
    return `${Math.floor(Math.random()*223)+1}.${Math.floor(Math.random()*256)}.${Math.floor(Math.random()*256)}.${Math.floor(Math.random()*254)+1}`
  }

  genDate() {
    const d = new Date()
    d.setDate(d.getDate() - Math.floor(Math.random() * 3650))
    return d.toISOString().split("T")[0]
  }

  genUrl() {
    const words = ["blog","news","docs","api","store","shop","portal","app","dashboard","wiki"]
    const paths = ["about","contact","products","services","help","faq","terms","privacy"]
    return `https://${this.pick(words)}.example.com/${this.pick(paths)}`
  }

  renderTable(fields) {
    const headerLabels = {
      first_name: "First Name", last_name: "Last Name", full_name: "Full Name",
      email: "Email", phone: "Phone", address: "Address", city: "City",
      country: "Country", company: "Company", job_title: "Job Title",
      username: "Username", password: "Password", uuid: "UUID",
      ip_address: "IP Address", date: "Date", url: "URL"
    }

    let html = '<div class="overflow-x-auto"><table class="w-full text-sm text-left">'
    html += '<thead class="bg-gray-100 dark:bg-gray-700"><tr>'
    html += '<th class="px-3 py-2 text-xs font-semibold text-gray-500 dark:text-gray-400">#</th>'
    for (const f of fields) {
      html += `<th class="px-3 py-2 text-xs font-semibold text-gray-500 dark:text-gray-400">${headerLabels[f] || f}</th>`
    }
    html += '</tr></thead><tbody>'

    for (let i = 0; i < this.records.length; i++) {
      const rowClass = i % 2 === 0 ? "bg-white dark:bg-gray-900" : "bg-gray-50 dark:bg-gray-800"
      html += `<tr class="${rowClass}">`
      html += `<td class="px-3 py-2 text-gray-400">${i + 1}</td>`
      for (const f of fields) {
        html += `<td class="px-3 py-2 text-gray-900 dark:text-white font-mono text-xs whitespace-nowrap">${this.escapeHtml(this.records[i][f] || "")}</td>`
      }
      html += '</tr>'
    }

    html += '</tbody></table></div>'
    this.resultsTableTarget.innerHTML = html
    this.resultsAreaTarget.classList.remove("hidden")
  }

  copyJson() {
    if (!this.records.length) return
    navigator.clipboard.writeText(JSON.stringify(this.records, null, 2)).then(() => {
      this.showStatus("JSON copied to clipboard!", "success")
    })
  }

  copyCsv() {
    if (!this.records.length) return
    navigator.clipboard.writeText(this.toCsv()).then(() => {
      this.showStatus("CSV copied to clipboard!", "success")
    })
  }

  downloadCsv() {
    if (!this.records.length) return
    const csv = this.toCsv()
    const blob = new Blob([csv], { type: "text/csv" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "fake-data.csv"
    a.click()
    URL.revokeObjectURL(url)
    this.showStatus("CSV downloaded!", "success")
  }

  toCsv() {
    if (!this.records.length) return ""
    const fields = Object.keys(this.records[0])
    const lines = [fields.join(",")]
    for (const rec of this.records) {
      const row = fields.map(f => {
        const val = (rec[f] || "").toString()
        return val.includes(",") || val.includes('"') ? `"${val.replace(/"/g, '""')}"` : val
      })
      lines.push(row.join(","))
    }
    return lines.join("\n")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  showStatus(message, type = "") {
    if (!this.hasStatusMessageTarget) return
    this.statusMessageTarget.textContent = message
    this.statusMessageTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")

    if (type === "success") {
      this.statusMessageTarget.classList.add("text-green-600", "dark:text-green-400")
    } else if (type === "error") {
      this.statusMessageTarget.classList.add("text-red-500", "dark:text-red-400")
    }
  }
}
