import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["services", "projectName", "output", "error", "serviceCount"]

  static serviceConfigs = {
    postgres: {
      image: "postgres:16-alpine", ports: ["5432:5432"],
      environment: { POSTGRES_USER: "app", POSTGRES_PASSWORD: "password", POSTGRES_DB: "app_development" },
      volumes: ["postgres_data:/var/lib/postgresql/data"],
      healthcheck: { test: "pg_isready -U app", interval: "10s", timeout: "5s", retries: 5 }
    },
    mysql: {
      image: "mysql:8.0", ports: ["3306:3306"],
      environment: { MYSQL_ROOT_PASSWORD: "password", MYSQL_DATABASE: "app_development" },
      volumes: ["mysql_data:/var/lib/mysql"],
      healthcheck: { test: "mysqladmin ping -h localhost", interval: "10s", timeout: "5s", retries: 5 }
    },
    redis: {
      image: "redis:7-alpine", ports: ["6379:6379"],
      volumes: ["redis_data:/data"],
      healthcheck: { test: "redis-cli ping", interval: "10s", timeout: "5s", retries: 5 }
    },
    mongodb: {
      image: "mongo:7", ports: ["27017:27017"],
      environment: { MONGO_INITDB_ROOT_USERNAME: "root", MONGO_INITDB_ROOT_PASSWORD: "password" },
      volumes: ["mongo_data:/data/db"]
    },
    nginx: { image: "nginx:alpine", ports: ["80:80", "443:443"], volumes: ["./nginx.conf:/etc/nginx/nginx.conf:ro"] },
    node: { image: "node:20-alpine", ports: ["3000:3000"], volumes: [".:/app"], working_dir: "/app", command: "npm start" },
    rails: {
      image: "ruby:3.3-slim", ports: ["3000:3000"], volumes: [".:/app"], working_dir: "/app",
      command: "bundle exec rails server -b 0.0.0.0", depends_on: ["postgres", "redis"]
    },
    elasticsearch: {
      image: "elasticsearch:8.12.0", ports: ["9200:9200"],
      environment: { "discovery.type": "single-node", "xpack.security.enabled": "false", ES_JAVA_OPTS: "-Xms512m -Xmx512m" },
      volumes: ["es_data:/usr/share/elasticsearch/data"]
    },
    rabbitmq: {
      image: "rabbitmq:3-management-alpine", ports: ["5672:5672", "15672:15672"],
      environment: { RABBITMQ_DEFAULT_USER: "guest", RABBITMQ_DEFAULT_PASS: "guest" },
      volumes: ["rabbitmq_data:/var/lib/rabbitmq"]
    },
    memcached: { image: "memcached:alpine", ports: ["11211:11211"] },
    mailhog: { image: "mailhog/mailhog", ports: ["1025:1025", "8025:8025"] },
    minio: {
      image: "minio/minio", ports: ["9000:9000", "9001:9001"],
      environment: { MINIO_ROOT_USER: "minioadmin", MINIO_ROOT_PASSWORD: "minioadmin" },
      volumes: ["minio_data:/data"], command: "server /data --console-address ':9001'"
    }
  }

  generate() {
    const checkboxes = this.servicesTargets || this.element.querySelectorAll("[data-service-checkbox]")
    const selected = []
    this.element.querySelectorAll("[data-service-checkbox]:checked").forEach(cb => selected.push(cb.value))

    if (selected.length === 0) { this.showError("Select at least one service."); return }
    this.hideError()

    const lines = []
    const volumes = []

    lines.push("services:")

    selected.forEach(name => {
      const cfg = this.constructor.serviceConfigs[name]
      if (!cfg) return
      lines.push(`  ${name}:`)
      lines.push(`    image: ${cfg.image}`)
      if (cfg.command) lines.push(`    command: ${cfg.command}`)
      if (cfg.working_dir) lines.push(`    working_dir: ${cfg.working_dir}`)
      if (cfg.ports?.length) {
        lines.push("    ports:")
        cfg.ports.forEach(p => lines.push(`      - "${p}"`))
      }
      if (cfg.environment) {
        lines.push("    environment:")
        Object.entries(cfg.environment).forEach(([k, v]) => lines.push(`      ${k}: ${v}`))
      }
      if (cfg.volumes?.length) {
        lines.push("    volumes:")
        cfg.volumes.forEach(v => {
          lines.push(`      - ${v}`)
          if (/^\w+:/.test(v) && !v.startsWith(".")) volumes.push(v.split(":")[0])
        })
      }
      if (cfg.depends_on) {
        const deps = cfg.depends_on.filter(d => selected.includes(d))
        if (deps.length) { lines.push("    depends_on:"); deps.forEach(d => lines.push(`      - ${d}`)) }
      }
      if (cfg.healthcheck) {
        lines.push("    healthcheck:")
        lines.push(`      test: ["CMD-SHELL", "${cfg.healthcheck.test}"]`)
        lines.push(`      interval: ${cfg.healthcheck.interval}`)
        lines.push(`      timeout: ${cfg.healthcheck.timeout}`)
        lines.push(`      retries: ${cfg.healthcheck.retries}`)
      }
      lines.push("    restart: unless-stopped")
      lines.push("")
    })

    const uniqueVolumes = [...new Set(volumes)]
    if (uniqueVolumes.length) {
      lines.push("volumes:")
      uniqueVolumes.forEach(v => lines.push(`  ${v}:`))
      lines.push("")
    }

    this.outputTarget.value = lines.join("\n")
    this.serviceCountTarget.textContent = `${selected.length} service${selected.length > 1 ? "s" : ""}`
  }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  copy() {
    const text = this.outputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) { const o = btn.textContent; btn.textContent = "Copied!"; setTimeout(() => { btn.textContent = o }, 1500) }
    })
  }
}
