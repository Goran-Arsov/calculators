# frozen_string_literal: true

module Everyday
  class SqlToNosqlCalculator
    attr_reader :errors

    SUPPORTED_TARGETS = %w[mongodb].freeze

    def initialize(sql:, target: "mongodb")
      @sql = sql.to_s.strip
      @target = target.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = convert_to_mongodb(@sql)

      {
        valid: true,
        original_sql: @sql,
        target: @target,
        converted: result[:query],
        explanation: result[:explanation]
      }
    end

    private

    def validate!
      @errors << "SQL query is required" if @sql.empty?
      @errors << "Unsupported target: #{@target}" unless SUPPORTED_TARGETS.include?(@target)
    end

    def convert_to_mongodb(sql)
      normalized = sql.gsub(/\s+/, " ").strip

      case normalized
      when /\ASELECT\s+(.*?)\s+FROM\s+(\w+)(?:\s+WHERE\s+(.*?))?(?:\s+ORDER\s+BY\s+(.*?))?(?:\s+LIMIT\s+(\d+))?\s*;?\z/i
        convert_select(Regexp.last_match)
      when /\AINSERT\s+INTO\s+(\w+)\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\)\s*;?\z/i
        convert_insert(Regexp.last_match)
      when /\AUPDATE\s+(\w+)\s+SET\s+(.*?)\s+WHERE\s+(.*?)\s*;?\z/i
        convert_update(Regexp.last_match)
      when /\ADELETE\s+FROM\s+(\w+)(?:\s+WHERE\s+(.*?))?\s*;?\z/i
        convert_delete(Regexp.last_match)
      when /\ACREATE\s+TABLE\s+(\w+)\s*\(([^)]+)\)\s*;?\z/i
        convert_create_table(Regexp.last_match)
      when /\ADROP\s+TABLE\s+(\w+)\s*;?\z/i
        convert_drop_table(Regexp.last_match)
      else
        { query: "// Could not automatically convert this query.\n// Please review the SQL and convert manually.", explanation: "The SQL pattern was not recognized. Supported patterns: SELECT, INSERT, UPDATE, DELETE, CREATE TABLE, DROP TABLE." }
      end
    end

    def convert_select(match)
      fields_str = match[1].strip
      table = match[2]
      where_str = match[3]
      order_str = match[4]
      limit_str = match[5]

      projection = parse_projection(fields_str)
      filter = where_str ? parse_where(where_str) : "{}"
      sort = order_str ? parse_order(order_str) : nil

      parts = ["db.#{table}.find(#{filter}"]
      parts[0] += ", #{projection}" unless projection == "{}"
      parts[0] += ")"
      parts << ".sort(#{sort})" if sort
      parts << ".limit(#{limit_str})" if limit_str

      query = parts.join("")
      explanation = "SELECT maps to db.collection.find() in MongoDB. WHERE becomes the query filter, field list becomes projection."

      { query: query, explanation: explanation }
    end

    def convert_insert(match)
      table = match[1]
      columns = match[2].split(",").map(&:strip)
      values = match[3].split(",").map { |v| clean_value(v.strip) }

      doc_parts = columns.zip(values).map { |col, val| "  #{col}: #{val}" }
      query = "db.#{table}.insertOne({\n#{doc_parts.join(",\n")}\n})"
      explanation = "INSERT INTO maps to db.collection.insertOne() in MongoDB. Column-value pairs become document fields."

      { query: query, explanation: explanation }
    end

    def convert_update(match)
      table = match[1]
      set_str = match[2]
      where_str = match[3]

      filter = parse_where(where_str)
      set_fields = parse_set_clause(set_str)

      query = "db.#{table}.updateMany(#{filter}, {\n  $set: #{set_fields}\n})"
      explanation = "UPDATE maps to db.collection.updateMany() with $set operator. WHERE becomes the filter document."

      { query: query, explanation: explanation }
    end

    def convert_delete(match)
      table = match[1]
      where_str = match[2]

      filter = where_str ? parse_where(where_str) : "{}"
      query = "db.#{table}.deleteMany(#{filter})"
      explanation = "DELETE FROM maps to db.collection.deleteMany(). WHERE becomes the filter. Without WHERE, all documents are deleted."

      { query: query, explanation: explanation }
    end

    def convert_create_table(match)
      table = match[1]
      query = "db.createCollection(\"#{table}\")"
      explanation = "CREATE TABLE maps to db.createCollection(). MongoDB is schema-less, so column definitions are not needed. Documents can have any structure."

      { query: query, explanation: explanation }
    end

    def convert_drop_table(match)
      table = match[1]
      query = "db.#{table}.drop()"
      explanation = "DROP TABLE maps to db.collection.drop() which removes the entire collection and its indexes."

      { query: query, explanation: explanation }
    end

    def parse_projection(fields_str)
      return "{}" if fields_str.strip == "*"

      fields = fields_str.split(",").map(&:strip)
      parts = fields.map { |f| "#{f}: 1" }
      "{ #{parts.join(', ')} }"
    end

    def parse_where(where_str)
      conditions = where_str.split(/\s+AND\s+/i)
      parts = conditions.map { |cond| parse_condition(cond.strip) }
      "{ #{parts.join(', ')} }"
    end

    def parse_condition(condition)
      if condition =~ /(\w+)\s*(>=|<=|!=|<>|>|<|=|LIKE)\s*(.+)/i
        field = Regexp.last_match(1)
        operator = Regexp.last_match(2).upcase
        value = clean_value(Regexp.last_match(3).strip)

        case operator
        when "="
          "#{field}: #{value}"
        when ">"
          "#{field}: { $gt: #{value} }"
        when ">="
          "#{field}: { $gte: #{value} }"
        when "<"
          "#{field}: { $lt: #{value} }"
        when "<="
          "#{field}: { $lte: #{value} }"
        when "!=", "<>"
          "#{field}: { $ne: #{value} }"
        when "LIKE"
          pattern = value.gsub(/^['"]|['"]$/, "").gsub("%", ".*")
          "#{field}: /#{pattern}/"
        else
          "#{field}: #{value}"
        end
      else
        "// #{condition}"
      end
    end

    def parse_order(order_str)
      parts = order_str.split(",").map do |part|
        tokens = part.strip.split(/\s+/)
        field = tokens[0]
        direction = tokens[1]&.upcase == "DESC" ? -1 : 1
        "#{field}: #{direction}"
      end
      "{ #{parts.join(', ')} }"
    end

    def parse_set_clause(set_str)
      pairs = set_str.split(",").map do |pair|
        field, value = pair.split("=", 2).map(&:strip)
        "    #{field}: #{clean_value(value)}"
      end
      "{\n#{pairs.join(",\n")}\n  }"
    end

    def clean_value(val)
      val = val.gsub(/^['"]|['"]$/, "")
      return val if val =~ /\A-?\d+(\.\d+)?\z/
      return "true" if val.casecmp("true").zero?
      return "false" if val.casecmp("false").zero?
      return "null" if val.casecmp("null").zero?

      "\"#{val}\""
    end
  end
end
