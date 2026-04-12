# frozen_string_literal: true

module Everyday
  class InvoicePdfGeneratorCalculator
    attr_reader :errors

    def initialize(invoice_number:, date:, due_date:, from_name:, from_address: "",
                   to_name:, to_address: "", line_items: [], tax_rate: 0, notes: "", currency: "USD")
      @invoice_number = invoice_number.to_s.strip
      @date = date.to_s.strip
      @due_date = due_date.to_s.strip
      @from_name = from_name.to_s.strip
      @from_address = from_address.to_s.strip
      @to_name = to_name.to_s.strip
      @to_address = to_address.to_s.strip
      @line_items = normalize_line_items(line_items)
      @tax_rate = tax_rate.to_f
      @notes = notes.to_s.strip
      @currency = currency.to_s.strip.upcase.presence || "USD"
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      subtotal = @line_items.sum { |item| item[:quantity] * item[:unit_price] }
      tax_amount = subtotal * (@tax_rate / 100.0)
      total = subtotal + tax_amount

      formatted_items = @line_items.map do |item|
        line_total = item[:quantity] * item[:unit_price]
        item.merge(line_total: line_total.round(2))
      end

      invoice_text = generate_text_invoice(formatted_items, subtotal, tax_amount, total)

      {
        valid: true,
        invoice_text: invoice_text,
        invoice_number: @invoice_number,
        date: @date,
        due_date: @due_date,
        from_name: @from_name,
        to_name: @to_name,
        line_items: formatted_items,
        subtotal: subtotal.round(2),
        tax_rate: @tax_rate,
        tax_amount: tax_amount.round(2),
        total: total.round(2),
        currency: @currency,
        item_count: @line_items.size
      }
    end

    private

    def normalize_line_items(items)
      case items
      when Array
        items.select { |i| i.is_a?(Hash) }.map do |item|
          {
            description: item[:description].to_s.strip,
            quantity: item[:quantity].to_f,
            unit_price: item[:unit_price].to_f
          }
        end.reject { |item| item[:description].empty? }
      else
        []
      end
    end

    def validate!
      @errors << "Invoice number is required" if @invoice_number.empty?
      @errors << "Date is required" if @date.empty?
      @errors << "Due date is required" if @due_date.empty?
      @errors << "From name is required" if @from_name.empty?
      @errors << "To name is required" if @to_name.empty?
      @errors << "At least one line item is required" if @line_items.empty?
      @errors << "Tax rate cannot be negative" if @tax_rate.negative?

      @line_items.each_with_index do |item, i|
        @errors << "Item #{i + 1}: quantity must be positive" unless item[:quantity].positive?
        @errors << "Item #{i + 1}: unit price must be positive" unless item[:unit_price].positive?
      end
    end

    def generate_text_invoice(items, subtotal, tax_amount, total)
      currency_symbol = currency_symbol_for(@currency)
      separator = "=" * 60

      lines = []
      lines << separator
      lines << center_text("INVOICE", 60)
      lines << separator
      lines << ""
      lines << "Invoice #: #{@invoice_number}"
      lines << "Date:      #{@date}"
      lines << "Due Date:  #{@due_date}"
      lines << ""
      lines << "-" * 60
      lines << ""
      lines << "FROM:"
      lines << "  #{@from_name}"
      lines << "  #{@from_address}" if @from_address.present?
      lines << ""
      lines << "TO:"
      lines << "  #{@to_name}"
      lines << "  #{@to_address}" if @to_address.present?
      lines << ""
      lines << "-" * 60
      lines << ""
      lines << format("%-30s %8s %10s %10s", "Description", "Qty", "Price", "Total")
      lines << "-" * 60

      items.each do |item|
        lines << format("%-30s %8s %10s %10s",
          truncate_text(item[:description], 30),
          format_qty(item[:quantity]),
          "#{currency_symbol}#{format_number(item[:unit_price])}",
          "#{currency_symbol}#{format_number(item[:line_total])}")
      end

      lines << "-" * 60
      lines << format("%50s %10s", "Subtotal:", "#{currency_symbol}#{format_number(subtotal.round(2))}")

      if @tax_rate.positive?
        lines << format("%50s %10s", "Tax (#{@tax_rate}%):", "#{currency_symbol}#{format_number(tax_amount.round(2))}")
      end

      lines << format("%50s %10s", "TOTAL:", "#{currency_symbol}#{format_number(total.round(2))}")
      lines << separator

      if @notes.present?
        lines << ""
        lines << "Notes:"
        lines << @notes
      end

      lines << ""
      lines << center_text("Thank you for your business!", 60)
      lines << separator

      lines.join("\n")
    end

    def currency_symbol_for(currency)
      { "USD" => "$", "EUR" => "\u20AC", "GBP" => "\u00A3", "JPY" => "\u00A5", "CAD" => "CA$", "AUD" => "A$" }.fetch(currency, "$")
    end

    def center_text(text, width)
      padding = [(width - text.length) / 2, 0].max
      " " * padding + text
    end

    def truncate_text(text, max_length)
      return text if text.length <= max_length

      text[0...(max_length - 3)] + "..."
    end

    def format_number(number)
      format("%.2f", number)
    end

    def format_qty(qty)
      qty == qty.to_i.to_f ? qty.to_i.to_s : format("%.2f", qty)
    end
  end
end
