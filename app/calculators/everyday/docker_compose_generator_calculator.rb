# frozen_string_literal: true

module Everyday
  class DockerComposeGeneratorCalculator
    attr_reader :errors

    SUPPORTED_SERVICES = {
      "postgres" => {
        image: "postgres:16-alpine",
        ports: ["5432:5432"],
        environment: { "POSTGRES_USER" => "app", "POSTGRES_PASSWORD" => "password", "POSTGRES_DB" => "app_development" },
        volumes: ["postgres_data:/var/lib/postgresql/data"],
        healthcheck: { test: "pg_isready -U app", interval: "10s", timeout: "5s", retries: 5 }
      },
      "mysql" => {
        image: "mysql:8.0",
        ports: ["3306:3306"],
        environment: { "MYSQL_ROOT_PASSWORD" => "password", "MYSQL_DATABASE" => "app_development" },
        volumes: ["mysql_data:/var/lib/mysql"],
        healthcheck: { test: "mysqladmin ping -h localhost", interval: "10s", timeout: "5s", retries: 5 }
      },
      "redis" => {
        image: "redis:7-alpine",
        ports: ["6379:6379"],
        volumes: ["redis_data:/data"],
        healthcheck: { test: "redis-cli ping", interval: "10s", timeout: "5s", retries: 5 }
      },
      "mongodb" => {
        image: "mongo:7",
        ports: ["27017:27017"],
        environment: { "MONGO_INITDB_ROOT_USERNAME" => "root", "MONGO_INITDB_ROOT_PASSWORD" => "password" },
        volumes: ["mongo_data:/data/db"]
      },
      "nginx" => {
        image: "nginx:alpine",
        ports: ["80:80", "443:443"],
        volumes: ["./nginx.conf:/etc/nginx/nginx.conf:ro"]
      },
      "node" => {
        image: "node:20-alpine",
        ports: ["3000:3000"],
        volumes: [".:/app"],
        working_dir: "/app",
        command: "npm start"
      },
      "rails" => {
        image: "ruby:3.3-slim",
        ports: ["3000:3000"],
        volumes: [".:/app"],
        working_dir: "/app",
        command: "bundle exec rails server -b 0.0.0.0",
        depends_on: ["postgres", "redis"]
      },
      "elasticsearch" => {
        image: "elasticsearch:8.12.0",
        ports: ["9200:9200"],
        environment: { "discovery.type" => "single-node", "xpack.security.enabled" => "false", "ES_JAVA_OPTS" => "-Xms512m -Xmx512m" },
        volumes: ["es_data:/usr/share/elasticsearch/data"]
      },
      "rabbitmq" => {
        image: "rabbitmq:3-management-alpine",
        ports: ["5672:5672", "15672:15672"],
        environment: { "RABBITMQ_DEFAULT_USER" => "guest", "RABBITMQ_DEFAULT_PASS" => "guest" },
        volumes: ["rabbitmq_data:/var/lib/rabbitmq"]
      },
      "memcached" => {
        image: "memcached:alpine",
        ports: ["11211:11211"]
      },
      "mailhog" => {
        image: "mailhog/mailhog",
        ports: ["1025:1025", "8025:8025"]
      },
      "minio" => {
        image: "minio/minio",
        ports: ["9000:9000", "9001:9001"],
        environment: { "MINIO_ROOT_USER" => "minioadmin", "MINIO_ROOT_PASSWORD" => "minioadmin" },
        volumes: ["minio_data:/data"],
        command: "server /data --console-address ':9001'"
      }
    }.freeze

    def initialize(services:, project_name: "myapp", compose_version: "3.8")
      @services = normalize_services(services)
      @project_name = project_name.to_s.strip.presence || "myapp"
      @compose_version = compose_version.to_s.strip.presence || "3.8"
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      compose = build_compose

      {
        valid: true,
        compose: compose,
        services: @services,
        service_count: @services.size,
        project_name: @project_name
      }
    end

    private

    def normalize_services(services)
      case services
      when Array
        services.map(&:to_s).map(&:strip).reject(&:empty?).select { |s| SUPPORTED_SERVICES.key?(s) }
      when String
        services.split(/[,\n]/).map(&:strip).reject(&:empty?).select { |s| SUPPORTED_SERVICES.key?(s) }
      else
        []
      end
    end

    def validate!
      @errors << "At least one service must be selected" if @services.empty?
    end

    def build_compose
      lines = []
      volumes = []

      lines << "services:"

      @services.each do |service_name|
        config = SUPPORTED_SERVICES[service_name]
        lines << "  #{service_name}:"
        lines << "    image: #{config[:image]}"

        if config[:command]
          lines << "    command: #{config[:command]}"
        end

        if config[:working_dir]
          lines << "    working_dir: #{config[:working_dir]}"
        end

        if config[:ports]&.any?
          lines << "    ports:"
          config[:ports].each { |p| lines << "      - \"#{p}\"" }
        end

        if config[:environment]&.any?
          lines << "    environment:"
          config[:environment].each { |k, v| lines << "      #{k}: #{v}" }
        end

        if config[:volumes]&.any?
          lines << "    volumes:"
          config[:volumes].each do |vol|
            lines << "      - #{vol}"
            # Track named volumes
            if vol.match?(/\A\w+:/)
              vol_name = vol.split(":").first
              volumes << vol_name unless vol_name.start_with?(".")
            end
          end
        end

        if config[:depends_on]
          relevant_deps = config[:depends_on].select { |d| @services.include?(d) }
          if relevant_deps.any?
            lines << "    depends_on:"
            relevant_deps.each { |d| lines << "      - #{d}" }
          end
        end

        if config[:healthcheck]
          lines << "    healthcheck:"
          lines << "      test: [\"CMD-SHELL\", \"#{config[:healthcheck][:test]}\"]"
          lines << "      interval: #{config[:healthcheck][:interval]}"
          lines << "      timeout: #{config[:healthcheck][:timeout]}"
          lines << "      retries: #{config[:healthcheck][:retries]}"
        end

        lines << "    restart: unless-stopped"
        lines << ""
      end

      if volumes.uniq.any?
        lines << "volumes:"
        volumes.uniq.each { |v| lines << "  #{v}:" }
        lines << ""
      end

      lines.join("\n")
    end
  end
end
