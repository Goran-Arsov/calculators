# frozen_string_literal: true

module Everyday
  class FakeDataGeneratorCalculator
    attr_reader :errors

    FIRST_NAMES = %w[
      James Mary Robert Patricia John Jennifer Michael Linda David Elizabeth
      William Barbara Richard Susan Joseph Jessica Thomas Sarah Charles Karen
      Christopher Lisa Daniel Nancy Matthew Betty Mark Sandra Donald Ashley
      Steven Emily Paul Kimberly Andrew Donna Joshua Michelle Kenneth Carol
      George Amanda Edward Dorothy Brian Melissa Ronald Deborah Timothy Stephanie
    ].freeze

    LAST_NAMES = %w[
      Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez
      Hernandez Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin
      Lee Perez Thompson White Harris Sanchez Clark Ramirez Lewis Robinson Walker
      Young Allen King Wright Scott Torres Nguyen Hill Flores Green Adams Nelson
      Baker Hall Rivera Campbell Mitchell Carter Roberts
    ].freeze

    CITIES = %w[
      New\ York Los\ Angeles Chicago Houston Phoenix Philadelphia San\ Antonio
      San\ Diego Dallas Austin Jacksonville San\ Francisco Columbus Charlotte
      Indianapolis Seattle Denver Washington Nashville Oklahoma\ City Portland
      Las\ Vegas Memphis Louisville Baltimore Milwaukee Albuquerque Tucson
      Fresno Sacramento Mesa Atlanta
    ].freeze

    COUNTRIES = %w[
      United\ States Canada United\ Kingdom Germany France Australia Japan
      Brazil India China Mexico Italy Spain Netherlands Sweden Norway Denmark
      Switzerland Austria Belgium Poland South\ Korea Argentina Colombia
      Chile New\ Zealand Ireland Portugal Finland Greece
    ].freeze

    COMPANIES = %w[
      Acme\ Corp TechVibe Quantum\ Labs SkyBridge Nexus\ Global Vertex\ IO
      Pinnacle\ Inc Horizon\ Digital Atlas\ Group Zenith\ Tech BluePeak
      CoreSync DataWave FusionPoint IgniteHub LaunchPad NovaEdge PulseTech
      RedShift SilverLine
    ].freeze

    JOB_TITLES = [
      "Software Engineer", "Product Manager", "Data Analyst", "UX Designer",
      "Marketing Manager", "Sales Representative", "DevOps Engineer",
      "Project Manager", "Business Analyst", "QA Engineer",
      "Frontend Developer", "Backend Developer", "Full Stack Developer",
      "System Administrator", "Database Administrator", "Network Engineer",
      "Technical Writer", "Scrum Master", "CTO", "VP of Engineering"
    ].freeze

    STREET_NAMES = %w[
      Main Oak Cedar Elm Maple Pine Birch Walnut Cherry Willow
      Park Lake Hill River Valley Spring Meadow Sunset Forest Highland
    ].freeze

    STREET_TYPES = %w[Street Avenue Boulevard Drive Lane Road Way Court Place Circle].freeze

    DOMAINS = %w[
      gmail.com yahoo.com outlook.com hotmail.com proton.me icloud.com
      mail.com fastmail.com zoho.com tutanota.com
    ].freeze

    SUPPORTED_FIELDS = %w[
      first_name last_name full_name email phone address city country
      company job_title username password uuid ip_address date url
    ].freeze

    MIN_COUNT = 1
    MAX_COUNT = 100

    def initialize(count:, fields:)
      @count = count.to_i
      @fields = Array(fields).map(&:to_s) & SUPPORTED_FIELDS
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      records = @count.times.map { generate_record }

      {
        valid: true,
        count: @count,
        fields: @fields,
        records: records
      }
    end

    private

    def validate!
      @errors << "Count must be between #{MIN_COUNT} and #{MAX_COUNT}" if @count < MIN_COUNT || @count > MAX_COUNT
      @errors << "At least one field must be selected" if @fields.empty?
    end

    def generate_record
      first = FIRST_NAMES.sample
      last = LAST_NAMES.sample
      record = {}

      @fields.each do |field|
        record[field] = case field
        when "first_name" then first
        when "last_name" then last
        when "full_name" then "#{first} #{last}"
        when "email" then generate_email(first, last)
        when "phone" then generate_phone
        when "address" then generate_address
        when "city" then CITIES.sample
        when "country" then COUNTRIES.sample
        when "company" then COMPANIES.sample
        when "job_title" then JOB_TITLES.sample
        when "username" then generate_username(first, last)
        when "password" then generate_password
        when "uuid" then generate_uuid
        when "ip_address" then generate_ip
        when "date" then generate_date
        when "url" then generate_url
        end
      end

      record
    end

    def generate_email(first, last)
      separators = [ ".", "_", "" ]
      sep = separators.sample
      num = rand(100) > 50 ? rand(1..999).to_s : ""
      "#{first.downcase}#{sep}#{last.downcase}#{num}@#{DOMAINS.sample}"
    end

    def generate_phone
      "+1-#{rand(200..999)}-#{rand(100..999)}-#{rand(1000..9999)}"
    end

    def generate_address
      "#{rand(100..9999)} #{STREET_NAMES.sample} #{STREET_TYPES.sample}"
    end

    def generate_username(first, last)
      styles = [
        "#{first.downcase}#{last.downcase[0..2]}#{rand(10..99)}",
        "#{first.downcase[0]}#{last.downcase}#{rand(1..999)}",
        "#{first.downcase}_#{last.downcase}"
      ]
      styles.sample
    end

    def generate_password
      chars = [ *("a".."z"), *("A".."Z"), *("0".."9"), *%w[! @ # $ % & *] ]
      (0...16).map { chars.sample }.join
    end

    def generate_uuid
      format("%08x-%04x-4%03x-%04x-%012x",
        rand(0xFFFFFFFF),
        rand(0xFFFF),
        rand(0xFFF),
        rand(0x3FFF) | 0x8000,
        rand(0xFFFFFFFFFFFF))
    end

    def generate_ip
      "#{rand(1..223)}.#{rand(0..255)}.#{rand(0..255)}.#{rand(1..254)}"
    end

    def generate_date
      days_ago = rand(0..3650)
      (Date.today - days_ago).iso8601
    end

    def generate_url
      words = %w[blog news docs api store shop portal app dashboard wiki]
      paths = %w[about contact products services help faq terms privacy]
      "https://#{words.sample}.example.com/#{paths.sample}"
    end
  end
end
