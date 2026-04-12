require "test_helper"

class Everyday::InvoicePdfGeneratorCalculatorTest < ActiveSupport::TestCase
  def valid_params
    {
      invoice_number: "INV-001",
      date: "2024-01-15",
      due_date: "2024-02-15",
      from_name: "Acme Corp",
      to_name: "Client Inc",
      line_items: [
        { description: "Web Development", quantity: 10, unit_price: 150.0 },
        { description: "Design", quantity: 5, unit_price: 100.0 }
      ]
    }
  end

  test "generates invoice with correct totals" do
    result = Everyday::InvoicePdfGeneratorCalculator.new(**valid_params).call
    assert_equal true, result[:valid]
    assert_equal 2000.0, result[:subtotal] # 10*150 + 5*100
    assert_equal 0.0, result[:tax_amount]
    assert_equal 2000.0, result[:total]
    assert_equal 2, result[:item_count]
  end

  test "calculates tax correctly" do
    result = Everyday::InvoicePdfGeneratorCalculator.new(**valid_params, tax_rate: 10).call
    assert_equal true, result[:valid]
    assert_equal 2000.0, result[:subtotal]
    assert_equal 200.0, result[:tax_amount]
    assert_equal 2200.0, result[:total]
  end

  test "generates formatted text invoice" do
    result = Everyday::InvoicePdfGeneratorCalculator.new(**valid_params).call
    assert_equal true, result[:valid]
    assert_includes result[:invoice_text], "INVOICE"
    assert_includes result[:invoice_text], "INV-001"
    assert_includes result[:invoice_text], "Acme Corp"
    assert_includes result[:invoice_text], "Client Inc"
    assert_includes result[:invoice_text], "Web Development"
  end

  test "includes from and to addresses" do
    result = Everyday::InvoicePdfGeneratorCalculator.new(
      **valid_params, from_address: "123 Main St", to_address: "456 Oak Ave"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:invoice_text], "123 Main St"
    assert_includes result[:invoice_text], "456 Oak Ave"
  end

  test "includes notes" do
    result = Everyday::InvoicePdfGeneratorCalculator.new(**valid_params, notes: "Net 30").call
    assert_equal true, result[:valid]
    assert_includes result[:invoice_text], "Net 30"
  end

  test "supports different currencies" do
    result = Everyday::InvoicePdfGeneratorCalculator.new(**valid_params, currency: "EUR").call
    assert_equal true, result[:valid]
    assert_equal "EUR", result[:currency]
  end

  test "error when invoice number is empty" do
    params = valid_params.merge(invoice_number: "")
    result = Everyday::InvoicePdfGeneratorCalculator.new(**params).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invoice number is required"
  end

  test "error when no line items" do
    params = valid_params.merge(line_items: [])
    result = Everyday::InvoicePdfGeneratorCalculator.new(**params).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one line item is required"
  end

  test "error when from name is empty" do
    params = valid_params.merge(from_name: "")
    result = Everyday::InvoicePdfGeneratorCalculator.new(**params).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "From name is required"
  end

  test "error when to name is empty" do
    params = valid_params.merge(to_name: "")
    result = Everyday::InvoicePdfGeneratorCalculator.new(**params).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "To name is required"
  end

  test "error for negative tax rate" do
    result = Everyday::InvoicePdfGeneratorCalculator.new(**valid_params, tax_rate: -5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Tax rate cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::InvoicePdfGeneratorCalculator.new(**valid_params)
    assert_equal [], calc.errors
  end
end
