import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "searchInput", "resultsBody", "resultCount",
    "categoryFilter", "activeCategory"
  ]

  static PORTS = [
    { port: 20, service: "FTP Data", protocol: "TCP", category: "file_transfer", description: "File Transfer Protocol data channel" },
    { port: 21, service: "FTP Control", protocol: "TCP", category: "file_transfer", description: "File Transfer Protocol control channel" },
    { port: 22, service: "SSH", protocol: "TCP", category: "remote_access", description: "Secure Shell for encrypted remote login" },
    { port: 23, service: "Telnet", protocol: "TCP", category: "remote_access", description: "Unencrypted text-based remote terminal access" },
    { port: 25, service: "SMTP", protocol: "TCP", category: "email", description: "Simple Mail Transfer Protocol for sending email" },
    { port: 43, service: "WHOIS", protocol: "TCP", category: "network", description: "WHOIS domain registration queries" },
    { port: 53, service: "DNS", protocol: "Both", category: "network", description: "Domain Name System for resolving domains" },
    { port: 67, service: "DHCP Server", protocol: "UDP", category: "network", description: "DHCP server port for assigning IPs" },
    { port: 68, service: "DHCP Client", protocol: "UDP", category: "network", description: "DHCP client port for receiving config" },
    { port: 69, service: "TFTP", protocol: "UDP", category: "file_transfer", description: "Trivial File Transfer Protocol" },
    { port: 80, service: "HTTP", protocol: "TCP", category: "web", description: "Hypertext Transfer Protocol for web pages" },
    { port: 88, service: "Kerberos", protocol: "Both", category: "security", description: "Kerberos network authentication" },
    { port: 110, service: "POP3", protocol: "TCP", category: "email", description: "Post Office Protocol v3 for email retrieval" },
    { port: 119, service: "NNTP", protocol: "TCP", category: "messaging", description: "Network News Transfer Protocol" },
    { port: 123, service: "NTP", protocol: "UDP", category: "network", description: "Network Time Protocol for clock sync" },
    { port: 135, service: "MS RPC", protocol: "TCP", category: "network", description: "Microsoft Remote Procedure Call" },
    { port: 137, service: "NetBIOS Name", protocol: "UDP", category: "network", description: "NetBIOS Name Service" },
    { port: 138, service: "NetBIOS Datagram", protocol: "UDP", category: "network", description: "NetBIOS Datagram Service" },
    { port: 139, service: "NetBIOS Session", protocol: "TCP", category: "network", description: "NetBIOS Session Service for file sharing" },
    { port: 143, service: "IMAP", protocol: "TCP", category: "email", description: "Internet Message Access Protocol for email" },
    { port: 161, service: "SNMP", protocol: "UDP", category: "monitoring", description: "Simple Network Management Protocol" },
    { port: 162, service: "SNMP Trap", protocol: "UDP", category: "monitoring", description: "SNMP Trap for async alerts" },
    { port: 179, service: "BGP", protocol: "TCP", category: "network", description: "Border Gateway Protocol for routing" },
    { port: 194, service: "IRC", protocol: "TCP", category: "messaging", description: "Internet Relay Chat" },
    { port: 389, service: "LDAP", protocol: "TCP", category: "security", description: "Lightweight Directory Access Protocol" },
    { port: 443, service: "HTTPS", protocol: "TCP", category: "web", description: "HTTP Secure using TLS encryption" },
    { port: 445, service: "SMB", protocol: "TCP", category: "file_transfer", description: "Server Message Block for file sharing" },
    { port: 465, service: "SMTPS", protocol: "TCP", category: "email", description: "SMTP over TLS for encrypted email" },
    { port: 514, service: "Syslog", protocol: "UDP", category: "monitoring", description: "Syslog for centralized logging" },
    { port: 515, service: "LPD", protocol: "TCP", category: "network", description: "Line Printer Daemon" },
    { port: 520, service: "RIP", protocol: "UDP", category: "network", description: "Routing Information Protocol" },
    { port: 548, service: "AFP", protocol: "TCP", category: "file_transfer", description: "Apple Filing Protocol for macOS sharing" },
    { port: 554, service: "RTSP", protocol: "Both", category: "streaming", description: "Real Time Streaming Protocol" },
    { port: 587, service: "SMTP Submission", protocol: "TCP", category: "email", description: "Mail submission port for clients" },
    { port: 631, service: "IPP", protocol: "TCP", category: "network", description: "Internet Printing Protocol" },
    { port: 636, service: "LDAPS", protocol: "TCP", category: "security", description: "LDAP over TLS for encrypted access" },
    { port: 873, service: "rsync", protocol: "TCP", category: "file_transfer", description: "rsync for file synchronization" },
    { port: 993, service: "IMAPS", protocol: "TCP", category: "email", description: "IMAP over TLS for encrypted email" },
    { port: 995, service: "POP3S", protocol: "TCP", category: "email", description: "POP3 over TLS for encrypted email" },
    { port: 1080, service: "SOCKS Proxy", protocol: "TCP", category: "network", description: "SOCKS proxy protocol" },
    { port: 1194, service: "OpenVPN", protocol: "Both", category: "security", description: "OpenVPN for encrypted VPN tunnels" },
    { port: 1433, service: "MSSQL", protocol: "TCP", category: "database", description: "Microsoft SQL Server" },
    { port: 1434, service: "MSSQL Browser", protocol: "UDP", category: "database", description: "MS SQL Server Browser service" },
    { port: 1521, service: "Oracle DB", protocol: "TCP", category: "database", description: "Oracle Database TNS listener" },
    { port: 1723, service: "PPTP", protocol: "TCP", category: "security", description: "Point-to-Point Tunneling Protocol" },
    { port: 1812, service: "RADIUS Auth", protocol: "UDP", category: "security", description: "RADIUS authentication" },
    { port: 1813, service: "RADIUS Acct", protocol: "UDP", category: "security", description: "RADIUS accounting" },
    { port: 1883, service: "MQTT", protocol: "TCP", category: "messaging", description: "MQTT for IoT messaging" },
    { port: 2049, service: "NFS", protocol: "Both", category: "file_transfer", description: "Network File System" },
    { port: 2181, service: "ZooKeeper", protocol: "TCP", category: "messaging", description: "Apache ZooKeeper client port" },
    { port: 2375, service: "Docker", protocol: "TCP", category: "devops", description: "Docker daemon API unencrypted" },
    { port: 2376, service: "Docker TLS", protocol: "TCP", category: "devops", description: "Docker daemon API encrypted" },
    { port: 2379, service: "etcd Client", protocol: "TCP", category: "devops", description: "etcd client communication" },
    { port: 2380, service: "etcd Peer", protocol: "TCP", category: "devops", description: "etcd peer communication" },
    { port: 3000, service: "Dev Server", protocol: "TCP", category: "web", description: "Common dev server (Rails, Node, Grafana)" },
    { port: 3306, service: "MySQL", protocol: "TCP", category: "database", description: "MySQL and MariaDB" },
    { port: 3389, service: "RDP", protocol: "TCP", category: "remote_access", description: "Remote Desktop Protocol" },
    { port: 4222, service: "NATS", protocol: "TCP", category: "messaging", description: "NATS messaging system" },
    { port: 4369, service: "EPMD", protocol: "TCP", category: "messaging", description: "Erlang Port Mapper Daemon" },
    { port: 4443, service: "Kubernetes API", protocol: "TCP", category: "devops", description: "Alternative K8s API server port" },
    { port: 5000, service: "Docker Registry", protocol: "TCP", category: "devops", description: "Docker Registry HTTP API" },
    { port: 5432, service: "PostgreSQL", protocol: "TCP", category: "database", description: "PostgreSQL database" },
    { port: 5601, service: "Kibana", protocol: "TCP", category: "monitoring", description: "Kibana visualization dashboard" },
    { port: 5672, service: "RabbitMQ", protocol: "TCP", category: "messaging", description: "RabbitMQ AMQP port" },
    { port: 5900, service: "VNC", protocol: "TCP", category: "remote_access", description: "Virtual Network Computing" },
    { port: 5984, service: "CouchDB", protocol: "TCP", category: "database", description: "Apache CouchDB HTTP API" },
    { port: 6379, service: "Redis", protocol: "TCP", category: "database", description: "Redis in-memory data store" },
    { port: 6443, service: "Kubernetes API", protocol: "TCP", category: "devops", description: "K8s API server default secure port" },
    { port: 6667, service: "IRC", protocol: "TCP", category: "messaging", description: "Standard IRC port" },
    { port: 6697, service: "IRC TLS", protocol: "TCP", category: "messaging", description: "IRC over TLS" },
    { port: 7474, service: "Neo4j", protocol: "TCP", category: "database", description: "Neo4j graph database" },
    { port: 8000, service: "HTTP Alt", protocol: "TCP", category: "web", description: "Alternative HTTP port (Django, dev)" },
    { port: 8080, service: "HTTP Proxy", protocol: "TCP", category: "web", description: "Alternative HTTP (proxies, Tomcat, Jenkins)" },
    { port: 8200, service: "Vault", protocol: "TCP", category: "security", description: "HashiCorp Vault API" },
    { port: 8443, service: "HTTPS Alt", protocol: "TCP", category: "web", description: "Alternative HTTPS port" },
    { port: 8500, service: "Consul", protocol: "TCP", category: "devops", description: "HashiCorp Consul HTTP API" },
    { port: 8761, service: "Eureka", protocol: "TCP", category: "devops", description: "Netflix Eureka service discovery" },
    { port: 8883, service: "MQTT TLS", protocol: "TCP", category: "messaging", description: "MQTT over TLS" },
    { port: 8888, service: "Jupyter", protocol: "TCP", category: "web", description: "Jupyter Notebook default port" },
    { port: 9000, service: "SonarQube", protocol: "TCP", category: "devops", description: "SonarQube code quality analysis" },
    { port: 9042, service: "Cassandra", protocol: "TCP", category: "database", description: "Apache Cassandra CQL" },
    { port: 9090, service: "Prometheus", protocol: "TCP", category: "monitoring", description: "Prometheus monitoring server" },
    { port: 9092, service: "Kafka", protocol: "TCP", category: "messaging", description: "Apache Kafka broker" },
    { port: 9200, service: "Elasticsearch", protocol: "TCP", category: "database", description: "Elasticsearch HTTP API" },
    { port: 9300, service: "ES Transport", protocol: "TCP", category: "database", description: "Elasticsearch node transport" },
    { port: 9418, service: "Git", protocol: "TCP", category: "devops", description: "Git protocol for repo access" },
    { port: 9600, service: "Logstash", protocol: "TCP", category: "monitoring", description: "Logstash monitoring API" },
    { port: 10000, service: "Webmin", protocol: "TCP", category: "web", description: "Webmin administration interface" },
    { port: 11211, service: "Memcached", protocol: "Both", category: "database", description: "Memcached distributed cache" },
    { port: 15672, service: "RabbitMQ Mgmt", protocol: "TCP", category: "messaging", description: "RabbitMQ management UI" },
    { port: 27017, service: "MongoDB", protocol: "TCP", category: "database", description: "MongoDB document database" },
    { port: 27018, service: "MongoDB Shard", protocol: "TCP", category: "database", description: "MongoDB shard server" },
    { port: 27019, service: "MongoDB Config", protocol: "TCP", category: "database", description: "MongoDB config server" },
    { port: 33060, service: "MySQL X", protocol: "TCP", category: "database", description: "MySQL X Protocol" },
    { port: 50000, service: "DB2", protocol: "TCP", category: "database", description: "IBM DB2 relational database" }
  ]

  static CATEGORIES = [
    { key: "all", label: "All" },
    { key: "web", label: "Web" },
    { key: "database", label: "Database" },
    { key: "email", label: "Email" },
    { key: "file_transfer", label: "File Transfer" },
    { key: "remote_access", label: "Remote Access" },
    { key: "network", label: "Network" },
    { key: "security", label: "Security" },
    { key: "messaging", label: "Messaging" },
    { key: "monitoring", label: "Monitoring" },
    { key: "devops", label: "DevOps" },
    { key: "streaming", label: "Streaming" }
  ]

  connect() {
    this.currentCategory = "all"
    this.search()
  }

  search() {
    const query = this.searchInputTarget.value.trim().toLowerCase()
    let results = this.constructor.PORTS

    if (this.currentCategory !== "all") {
      results = results.filter(p => p.category === this.currentCategory)
    }

    if (query) {
      if (/^\d+$/.test(query)) {
        const portNum = parseInt(query, 10)
        results = results.filter(p => p.port === portNum || p.port.toString().startsWith(query))
      } else {
        results = results.filter(p =>
          p.service.toLowerCase().includes(query) ||
          p.protocol.toLowerCase().includes(query) ||
          p.category.replace("_", " ").toLowerCase().includes(query) ||
          p.description.toLowerCase().includes(query)
        )
      }
    }

    this.renderResults(results)
    this.resultCountTarget.textContent = results.length.toString()
  }

  filterCategory(event) {
    const category = event.currentTarget.dataset.category
    this.currentCategory = category

    this.categoryFilterTargets.forEach(btn => {
      if (btn.dataset.category === category) {
        btn.classList.add("bg-blue-600", "text-white")
        btn.classList.remove("bg-gray-100", "dark:bg-gray-800", "text-gray-700", "dark:text-gray-300")
      } else {
        btn.classList.remove("bg-blue-600", "text-white")
        btn.classList.add("bg-gray-100", "dark:bg-gray-800", "text-gray-700", "dark:text-gray-300")
      }
    })

    this.search()
  }

  renderResults(results) {
    if (results.length === 0) {
      this.resultsBodyTarget.innerHTML = `
        <tr>
          <td colspan="5" class="px-4 py-8 text-center text-gray-500 dark:text-gray-400">
            No ports found matching your search.
          </td>
        </tr>`
      return
    }

    const categoryLabels = {
      "web": "Web",
      "database": "Database",
      "email": "Email",
      "file_transfer": "File Transfer",
      "remote_access": "Remote Access",
      "network": "Network",
      "security": "Security",
      "messaging": "Messaging",
      "monitoring": "Monitoring",
      "devops": "DevOps",
      "streaming": "Streaming"
    }

    const categoryColors = {
      "web": "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400",
      "database": "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400",
      "email": "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400",
      "file_transfer": "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400",
      "remote_access": "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400",
      "network": "bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300",
      "security": "bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-400",
      "messaging": "bg-teal-100 text-teal-700 dark:bg-teal-900/30 dark:text-teal-400",
      "monitoring": "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400",
      "devops": "bg-indigo-100 text-indigo-700 dark:bg-indigo-900/30 dark:text-indigo-400",
      "streaming": "bg-cyan-100 text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-400"
    }

    this.resultsBodyTarget.innerHTML = results.map(p => `
      <tr class="border-b border-gray-100 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800/50">
        <td class="px-4 py-3 font-mono font-bold text-blue-600 dark:text-blue-400">${p.port}</td>
        <td class="px-4 py-3 font-medium text-gray-900 dark:text-white">${p.service}</td>
        <td class="px-4 py-3 text-gray-600 dark:text-gray-400">${p.protocol}</td>
        <td class="px-4 py-3"><span class="text-xs font-medium px-2 py-1 rounded-full ${categoryColors[p.category] || ""}">${categoryLabels[p.category] || p.category}</span></td>
        <td class="px-4 py-3 text-sm text-gray-500 dark:text-gray-400">${p.description}</td>
      </tr>
    `).join("")
  }

  copy() {
    const rows = this.resultsBodyTarget.querySelectorAll("tr")
    const lines = Array.from(rows).map(row => {
      const cells = row.querySelectorAll("td")
      if (cells.length < 4) return null
      return `${cells[0].textContent.trim()}\t${cells[1].textContent.trim()}\t${cells[2].textContent.trim()}\t${cells[3].textContent.trim()}`
    }).filter(Boolean)
    if (lines.length === 0) return
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
