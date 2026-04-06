# frozen_string_literal: true

module Everyday
  class ChmodCalculator
    attr_reader :errors

    COMMON_PERMISSIONS = {
      "777" => "Full access for everyone",
      "755" => "Standard directory / executable",
      "750" => "Owner full, group read/execute",
      "700" => "Owner full access only",
      "666" => "Read/write for everyone",
      "664" => "Owner/group read-write, other read",
      "644" => "Standard file (owner write, all read)",
      "640" => "Owner read-write, group read",
      "600" => "Owner read-write only",
      "555" => "Read/execute for everyone",
      "544" => "Owner read/execute, others read",
      "500" => "Owner read/execute only",
      "444" => "Read-only for everyone",
      "400" => "Owner read only",
      "000" => "No permissions"
    }.freeze

    def initialize(input:)
      @input = input.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if numeric_input?
        from_numeric(@input)
      else
        from_symbolic(@input)
      end
    end

    private

    def numeric_input?
      @input.match?(/\A[0-7]{3}\z/)
    end

    def symbolic_input?
      @input.match?(/\A[r-][w-][x-][r-][w-][x-][r-][w-][x-]\z/)
    end

    def from_numeric(numeric)
      digits = numeric.chars.map(&:to_i)
      owner = permission_breakdown(digits[0])
      group = permission_breakdown(digits[1])
      other = permission_breakdown(digits[2])

      symbolic = to_symbolic_string(digits[0], digits[1], digits[2])
      common_name = COMMON_PERMISSIONS[numeric]

      {
        valid: true,
        numeric: numeric,
        symbolic: symbolic,
        owner: owner,
        group: group,
        other: other,
        common_name: common_name
      }
    end

    def from_symbolic(symbolic)
      owner_digit = symbolic_to_digit(symbolic[0..2])
      group_digit = symbolic_to_digit(symbolic[3..5])
      other_digit = symbolic_to_digit(symbolic[6..8])

      numeric = "#{owner_digit}#{group_digit}#{other_digit}"
      common_name = COMMON_PERMISSIONS[numeric]

      {
        valid: true,
        numeric: numeric,
        symbolic: symbolic,
        owner: permission_breakdown(owner_digit),
        group: permission_breakdown(group_digit),
        other: permission_breakdown(other_digit),
        common_name: common_name
      }
    end

    def permission_breakdown(digit)
      {
        read: (digit & 4) != 0,
        write: (digit & 2) != 0,
        execute: (digit & 1) != 0
      }
    end

    def to_symbolic_string(owner, group, other)
      [ owner, group, other ].map { |d| digit_to_rwx(d) }.join
    end

    def digit_to_rwx(digit)
      r = (digit & 4) != 0 ? "r" : "-"
      w = (digit & 2) != 0 ? "w" : "-"
      x = (digit & 1) != 0 ? "x" : "-"
      "#{r}#{w}#{x}"
    end

    def symbolic_to_digit(rwx)
      digit = 0
      digit += 4 if rwx[0] == "r"
      digit += 2 if rwx[1] == "w"
      digit += 1 if rwx[2] == "x"
      digit
    end

    def validate!
      @errors << "Input cannot be empty" if @input.empty?
      return if @input.empty?

      unless numeric_input? || symbolic_input?
        @errors << "Input must be a 3-digit octal number (e.g. 755) or a 9-character symbolic string (e.g. rwxr-xr-x)"
      end
    end
  end
end
