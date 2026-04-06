# frozen_string_literal: true

module Everyday
  class PortReferenceCalculator
    attr_reader :errors

    PORTS = [
      { port: 20,    service: "FTP Data",        protocol: "TCP",  category: "file_transfer", description: "File Transfer Protocol data channel for transferring files between client and server." },
      { port: 21,    service: "FTP Control",     protocol: "TCP",  category: "file_transfer", description: "File Transfer Protocol control channel for issuing commands and receiving responses." },
      { port: 22,    service: "SSH",             protocol: "TCP",  category: "remote_access", description: "Secure Shell for encrypted remote login, command execution, and file transfers." },
      { port: 23,    service: "Telnet",          protocol: "TCP",  category: "remote_access", description: "Unencrypted text-based remote terminal access protocol." },
      { port: 25,    service: "SMTP",            protocol: "TCP",  category: "email",         description: "Simple Mail Transfer Protocol for sending outgoing email between mail servers." },
      { port: 53,    service: "DNS",             protocol: "Both", category: "network",       description: "Domain Name System for resolving domain names to IP addresses." },
      { port: 67,    service: "DHCP Server",     protocol: "UDP",  category: "network",       description: "Dynamic Host Configuration Protocol server port for assigning IP addresses." },
      { port: 68,    service: "DHCP Client",     protocol: "UDP",  category: "network",       description: "Dynamic Host Configuration Protocol client port for receiving IP configuration." },
      { port: 69,    service: "TFTP",            protocol: "UDP",  category: "file_transfer", description: "Trivial File Transfer Protocol for simple, lightweight file transfers." },
      { port: 80,    service: "HTTP",            protocol: "TCP",  category: "web",           description: "Hypertext Transfer Protocol for serving unencrypted web pages and APIs." },
      { port: 88,    service: "Kerberos",        protocol: "Both", category: "security",      description: "Kerberos network authentication protocol for secure identity verification." },
      { port: 110,   service: "POP3",            protocol: "TCP",  category: "email",         description: "Post Office Protocol v3 for retrieving email from a mail server." },
      { port: 119,   service: "NNTP",            protocol: "TCP",  category: "messaging",     description: "Network News Transfer Protocol for reading and posting Usenet articles." },
      { port: 123,   service: "NTP",             protocol: "UDP",  category: "network",       description: "Network Time Protocol for synchronizing clocks across networked devices." },
      { port: 135,   service: "MS RPC",          protocol: "TCP",  category: "network",       description: "Microsoft Remote Procedure Call endpoint mapper for Windows services." },
      { port: 137,   service: "NetBIOS Name",    protocol: "UDP",  category: "network",       description: "NetBIOS Name Service for name registration and resolution on local networks." },
      { port: 138,   service: "NetBIOS Datagram", protocol: "UDP", category: "network",       description: "NetBIOS Datagram Service for connectionless communication on local networks." },
      { port: 139,   service: "NetBIOS Session", protocol: "TCP",  category: "network",       description: "NetBIOS Session Service for connection-oriented communication and file sharing." },
      { port: 143,   service: "IMAP",            protocol: "TCP",  category: "email",         description: "Internet Message Access Protocol for managing email on a remote server." },
      { port: 161,   service: "SNMP",            protocol: "UDP",  category: "monitoring",    description: "Simple Network Management Protocol for monitoring and managing network devices." },
      { port: 162,   service: "SNMP Trap",       protocol: "UDP",  category: "monitoring",    description: "SNMP Trap for receiving asynchronous alerts from managed network devices." },
      { port: 179,   service: "BGP",             protocol: "TCP",  category: "network",       description: "Border Gateway Protocol for exchanging routing information between autonomous systems." },
      { port: 194,   service: "IRC",             protocol: "TCP",  category: "messaging",     description: "Internet Relay Chat for real-time text communication in channels." },
      { port: 389,   service: "LDAP",            protocol: "TCP",  category: "security",      description: "Lightweight Directory Access Protocol for accessing directory services." },
      { port: 443,   service: "HTTPS",           protocol: "TCP",  category: "web",           description: "HTTP Secure using TLS encryption for serving encrypted web pages and APIs." },
      { port: 445,   service: "SMB",             protocol: "TCP",  category: "file_transfer", description: "Server Message Block for Windows file sharing, printer sharing, and IPC." },
      { port: 465,   service: "SMTPS",           protocol: "TCP",  category: "email",         description: "SMTP over TLS for sending encrypted outgoing email." },
      { port: 514,   service: "Syslog",          protocol: "UDP",  category: "monitoring",    description: "Syslog for centralized collection of system log messages." },
      { port: 515,   service: "LPD",             protocol: "TCP",  category: "network",       description: "Line Printer Daemon for submitting print jobs to remote printers." },
      { port: 520,   service: "RIP",             protocol: "UDP",  category: "network",       description: "Routing Information Protocol for exchanging routing tables between routers." },
      { port: 543,   service: "Klogin",          protocol: "TCP",  category: "remote_access", description: "Kerberos-authenticated remote login service." },
      { port: 544,   service: "Kshell",          protocol: "TCP",  category: "remote_access", description: "Kerberos-authenticated remote shell service." },
      { port: 548,   service: "AFP",             protocol: "TCP",  category: "file_transfer", description: "Apple Filing Protocol for macOS file sharing." },
      { port: 554,   service: "RTSP",            protocol: "Both", category: "streaming",     description: "Real Time Streaming Protocol for controlling media streaming sessions." },
      { port: 587,   service: "SMTP Submission", protocol: "TCP",  category: "email",         description: "Mail submission port for clients sending outgoing email through an MTA." },
      { port: 631,   service: "IPP",             protocol: "TCP",  category: "network",       description: "Internet Printing Protocol for managing print jobs and printer queues." },
      { port: 636,   service: "LDAPS",           protocol: "TCP",  category: "security",      description: "LDAP over TLS for encrypted directory service access." },
      { port: 873,   service: "rsync",           protocol: "TCP",  category: "file_transfer", description: "rsync daemon for efficient file synchronization and transfer." },
      { port: 993,   service: "IMAPS",           protocol: "TCP",  category: "email",         description: "IMAP over TLS for encrypted email retrieval and management." },
      { port: 995,   service: "POP3S",           protocol: "TCP",  category: "email",         description: "POP3 over TLS for encrypted email retrieval." },
      { port: 1080,  service: "SOCKS Proxy",     protocol: "TCP",  category: "network",       description: "SOCKS proxy protocol for routing network traffic through a proxy server." },
      { port: 1194,  service: "OpenVPN",         protocol: "Both", category: "security",      description: "OpenVPN for creating encrypted virtual private network tunnels." },
      { port: 1433,  service: "MSSQL",           protocol: "TCP",  category: "database",      description: "Microsoft SQL Server default instance for database connections." },
      { port: 1434,  service: "MSSQL Browser",   protocol: "UDP",  category: "database",      description: "Microsoft SQL Server Browser service for discovering database instances." },
      { port: 1521,  service: "Oracle DB",       protocol: "TCP",  category: "database",      description: "Oracle Database TNS listener for database client connections." },
      { port: 1723,  service: "PPTP",            protocol: "TCP",  category: "security",      description: "Point-to-Point Tunneling Protocol for VPN connections." },
      { port: 1883,  service: "MQTT",            protocol: "TCP",  category: "messaging",     description: "Message Queuing Telemetry Transport for lightweight IoT messaging." },
      { port: 2049,  service: "NFS",             protocol: "Both", category: "file_transfer", description: "Network File System for sharing files over a network." },
      { port: 2181,  service: "ZooKeeper",       protocol: "TCP",  category: "messaging",     description: "Apache ZooKeeper client port for distributed coordination services." },
      { port: 2375,  service: "Docker",          protocol: "TCP",  category: "devops",        description: "Docker daemon API unencrypted port for container management." },
      { port: 2376,  service: "Docker TLS",      protocol: "TCP",  category: "devops",        description: "Docker daemon API encrypted port for secure container management." },
      { port: 2379,  service: "etcd Client",     protocol: "TCP",  category: "devops",        description: "etcd client communication port for distributed key-value store." },
      { port: 2380,  service: "etcd Peer",       protocol: "TCP",  category: "devops",        description: "etcd peer communication port for cluster coordination." },
      { port: 3000,  service: "Dev Server",      protocol: "TCP",  category: "web",           description: "Common development server port used by Rails, Node.js, and Grafana." },
      { port: 3306,  service: "MySQL",           protocol: "TCP",  category: "database",      description: "MySQL and MariaDB default port for database client connections." },
      { port: 3389,  service: "RDP",             protocol: "TCP",  category: "remote_access", description: "Remote Desktop Protocol for graphical remote access to Windows systems." },
      { port: 4222,  service: "NATS",            protocol: "TCP",  category: "messaging",     description: "NATS messaging system client port for high-performance messaging." },
      { port: 4443,  service: "Kubernetes API",  protocol: "TCP",  category: "devops",        description: "Common alternative port for Kubernetes API server." },
      { port: 5000,  service: "Docker Registry", protocol: "TCP",  category: "devops",        description: "Docker Registry HTTP API for storing and distributing container images." },
      { port: 5432,  service: "PostgreSQL",      protocol: "TCP",  category: "database",      description: "PostgreSQL default port for database client connections." },
      { port: 5672,  service: "RabbitMQ",        protocol: "TCP",  category: "messaging",     description: "RabbitMQ AMQP port for message broker client connections." },
      { port: 5900,  service: "VNC",             protocol: "TCP",  category: "remote_access", description: "Virtual Network Computing for graphical remote desktop sharing." },
      { port: 5984,  service: "CouchDB",         protocol: "TCP",  category: "database",      description: "Apache CouchDB HTTP API for document database access." },
      { port: 6379,  service: "Redis",           protocol: "TCP",  category: "database",      description: "Redis in-memory data store default port for cache and message broker." },
      { port: 6443,  service: "Kubernetes API",  protocol: "TCP",  category: "devops",        description: "Kubernetes API server default secure port for cluster management." },
      { port: 6660,  service: "IRC Alt",         protocol: "TCP",  category: "messaging",     description: "Alternative IRC port range start for relay chat connections." },
      { port: 6667,  service: "IRC",             protocol: "TCP",  category: "messaging",     description: "Standard IRC port for unencrypted relay chat connections." },
      { port: 6697,  service: "IRC TLS",         protocol: "TCP",  category: "messaging",     description: "IRC over TLS for encrypted relay chat connections." },
      { port: 7474,  service: "Neo4j",           protocol: "TCP",  category: "database",      description: "Neo4j graph database HTTP browser and REST API interface." },
      { port: 8000,  service: "HTTP Alt",        protocol: "TCP",  category: "web",           description: "Common alternative HTTP port used by development servers and Django." },
      { port: 8080,  service: "HTTP Proxy",      protocol: "TCP",  category: "web",           description: "Common alternative HTTP port used by proxies, Tomcat, and Jenkins." },
      { port: 8443,  service: "HTTPS Alt",       protocol: "TCP",  category: "web",           description: "Common alternative HTTPS port used by application servers." },
      { port: 8761,  service: "Eureka",          protocol: "TCP",  category: "devops",        description: "Netflix Eureka service discovery server for microservices." },
      { port: 8883,  service: "MQTT TLS",        protocol: "TCP",  category: "messaging",     description: "MQTT over TLS for encrypted IoT messaging." },
      { port: 8888,  service: "Jupyter",         protocol: "TCP",  category: "web",           description: "Jupyter Notebook default port for interactive computing interface." },
      { port: 9000,  service: "SonarQube",       protocol: "TCP",  category: "devops",        description: "SonarQube default port for code quality analysis platform." },
      { port: 9042,  service: "Cassandra",       protocol: "TCP",  category: "database",      description: "Apache Cassandra CQL native transport port for database connections." },
      { port: 9090,  service: "Prometheus",      protocol: "TCP",  category: "monitoring",    description: "Prometheus monitoring server default port for metrics collection." },
      { port: 9092,  service: "Kafka",           protocol: "TCP",  category: "messaging",     description: "Apache Kafka broker default port for distributed event streaming." },
      { port: 9200,  service: "Elasticsearch",   protocol: "TCP",  category: "database",      description: "Elasticsearch HTTP API port for search and analytics engine." },
      { port: 9300,  service: "Elasticsearch Transport", protocol: "TCP", category: "database", description: "Elasticsearch node-to-node transport port for cluster communication." },
      { port: 9418,  service: "Git",             protocol: "TCP",  category: "devops",        description: "Git protocol for unauthenticated read-only repository access." },
      { port: 9443,  service: "WSS Alt",         protocol: "TCP",  category: "web",           description: "Alternative secure WebSocket port used by various services." },
      { port: 9600,  service: "Logstash",        protocol: "TCP",  category: "monitoring",    description: "Logstash monitoring API port for log processing pipeline status." },
      { port: 10000, service: "Webmin",          protocol: "TCP",  category: "web",           description: "Webmin web-based system administration interface." },
      { port: 11211, service: "Memcached",       protocol: "Both", category: "database",      description: "Memcached distributed memory caching system default port." },
      { port: 15672, service: "RabbitMQ Mgmt",   protocol: "TCP",  category: "messaging",     description: "RabbitMQ management UI and HTTP API for broker administration." },
      { port: 27017, service: "MongoDB",         protocol: "TCP",  category: "database",      description: "MongoDB default port for document database client connections." },
      { port: 27018, service: "MongoDB Shard",   protocol: "TCP",  category: "database",      description: "MongoDB shard server port for distributed database clustering." },
      { port: 27019, service: "MongoDB Config",  protocol: "TCP",  category: "database",      description: "MongoDB config server port for cluster metadata storage." },
      { port: 28017, service: "MongoDB Web",     protocol: "TCP",  category: "database",      description: "MongoDB HTTP status interface for basic server monitoring." },
      { port: 33060, service: "MySQL X",         protocol: "TCP",  category: "database",      description: "MySQL X Protocol port for document store and async connections." },
      { port: 43,    service: "WHOIS",           protocol: "TCP",  category: "network",       description: "WHOIS protocol for querying domain registration information." },
      { port: 50000, service: "DB2",             protocol: "TCP",  category: "database",      description: "IBM DB2 default port for relational database connections." },
      { port: 5601,  service: "Kibana",          protocol: "TCP",  category: "monitoring",    description: "Kibana visualization dashboard for Elasticsearch data." },
      { port: 8500,  service: "Consul",          protocol: "TCP",  category: "devops",        description: "HashiCorp Consul HTTP API for service discovery and configuration." },
      { port: 8200,  service: "Vault",           protocol: "TCP",  category: "security",      description: "HashiCorp Vault API port for secrets management." },
      { port: 4369,  service: "EPMD",            protocol: "TCP",  category: "messaging",     description: "Erlang Port Mapper Daemon for distributed Erlang node discovery." },
      { port: 1812,  service: "RADIUS Auth",     protocol: "UDP",  category: "security",      description: "RADIUS authentication port for network access control." },
      { port: 1813,  service: "RADIUS Acct",     protocol: "UDP",  category: "security",      description: "RADIUS accounting port for tracking network usage." }
    ].freeze

    CATEGORIES = PORTS.map { |p| p[:category] }.uniq.sort.freeze

    def initialize(query:)
      @query = query.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      matches = search_ports

      {
        valid: true,
        query: @query,
        results: matches,
        result_count: matches.size,
        categories: CATEGORIES
      }
    end

    private

    def search_ports
      return PORTS.sort_by { |p| p[:port] } if @query == "*"

      if @query.match?(/\A\d+\z/)
        port_number = @query.to_i
        PORTS.select { |p| p[:port] == port_number }.sort_by { |p| p[:port] }
      else
        term = @query.downcase
        PORTS.select do |p|
          p[:service].downcase.include?(term) ||
            p[:protocol].downcase.include?(term) ||
            p[:category].downcase.tr("_", " ").include?(term) ||
            p[:description].downcase.include?(term)
        end.sort_by { |p| p[:port] }
      end
    end

    def validate!
      @errors << "Search query cannot be empty" if @query.empty?
    end
  end
end
