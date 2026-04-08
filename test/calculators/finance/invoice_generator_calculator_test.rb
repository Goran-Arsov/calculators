require "test_helper"

class Finance::InvoiceGeneratorCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "single line item without tax or discount" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Widget", quantity: 5, unit_price: 10.0 } ]
    ).call

    assert result[:valid]
    assert_equal 50.0, result[:subtotal]
    assert_equal 0.0, result[:tax_amount]
    assert_equal 0.0, result[:discount_amount]
    assert_equal 50.0, result[:total]
    assert_equal 1, result[:line_items].length
    assert_equal 50.0, result[:line_items][0][:amount]
  end

  test "multiple line items" do
    items = [
      { description: "Widget A", quantity: 2, unit_price: 25.0 },
      { description: "Widget B", quantity: 3, unit_price: 15.0 },
      { description: "Widget C", quantity: 1, unit_price: 100.0 }
    ]
    result = Finance::InvoiceGeneratorCalculator.new(line_items: items).call

    assert result[:valid]
    assert_equal 195.0, result[:subtotal]
    assert_equal 195.0, result[:total]
    assert_equal 50.0, result[:line_items][0][:amount]
    assert_equal 45.0, result[:line_items][1][:amount]
    assert_equal 100.0, result[:line_items][2][:amount]
  end

  test "with tax rate" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Service", quantity: 1, unit_price: 200.0 } ],
      tax_rate: 10
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:subtotal]
    assert_equal 20.0, result[:tax_amount]
    assert_equal 220.0, result[:total]
  end

  test "with percent discount" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Product", quantity: 4, unit_price: 50.0 } ],
      discount: 10,
      discount_type: "percent"
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:subtotal]
    assert_equal 20.0, result[:discount_amount]
    assert_equal 180.0, result[:total]
  end

  test "with flat discount" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Product", quantity: 4, unit_price: 50.0 } ],
      discount: 30,
      discount_type: "flat"
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:subtotal]
    assert_equal 30.0, result[:discount_amount]
    assert_equal 170.0, result[:total]
  end

  test "with tax and percent discount" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 10, unit_price: 20.0 } ],
      tax_rate: 8.5,
      discount: 5,
      discount_type: "percent"
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:subtotal]
    assert_equal 17.0, result[:tax_amount]
    assert_equal 10.0, result[:discount_amount]
    assert_equal 207.0, result[:total]
  end

  test "zero tax rate" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: 100.0 } ],
      tax_rate: 0
    ).call

    assert result[:valid]
    assert_equal 0.0, result[:tax_amount]
    assert_equal 100.0, result[:total]
  end

  test "zero discount" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: 100.0 } ],
      discount: 0
    ).call

    assert result[:valid]
    assert_equal 0.0, result[:discount_amount]
    assert_equal 100.0, result[:total]
  end

  # --- Validation errors ---

  test "error when line items is empty" do
    result = Finance::InvoiceGeneratorCalculator.new(line_items: []).call
    refute result[:valid]
    assert_includes result[:errors], "At least one line item is required"
  end

  test "error when quantity is zero" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 0, unit_price: 10.0 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: quantity must be greater than 0"
  end

  test "error when quantity is negative" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: -2, unit_price: 10.0 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: quantity must be greater than 0"
  end

  test "error when unit price is negative" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: -5.0 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: unit price must be 0 or greater"
  end

  test "allows zero unit price" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Free item", quantity: 1, unit_price: 0 } ]
    ).call
    assert result[:valid]
    assert_equal 0.0, result[:subtotal]
  end

  test "error when tax rate exceeds 100" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: 50.0 } ],
      tax_rate: 101
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Tax rate must be between 0 and 100"
  end

  test "error when tax rate is negative" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: 50.0 } ],
      tax_rate: -5
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Tax rate must be between 0 and 100"
  end

  test "error when discount is negative" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: 50.0 } ],
      discount: -10
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Discount must be 0 or greater"
  end

  # --- Edge cases ---

  test "very large numbers" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Big ticket", quantity: 1_000_000, unit_price: 999_999.99 } ],
      tax_rate: 20
    ).call
    assert result[:valid]
    assert_equal 999_999_990_000.0, result[:subtotal]
    assert_equal 199_999_998_000.0, result[:tax_amount]
    assert_equal 1_199_999_988_000.0, result[:total]
  end

  test "multiple validation errors at once" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [
        { description: "A", quantity: -1, unit_price: -5 },
        { description: "B", quantity: 0, unit_price: 10 }
      ],
      tax_rate: 150,
      discount: -10
    ).call
    refute result[:valid]
    assert result[:errors].length >= 4
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: 10.0 } ]
    )
    assert_equal [], calc.errors
  end

  test "decimal quantities" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Hours worked", quantity: 7.5, unit_price: 80.0 } ]
    ).call
    assert result[:valid]
    assert_equal 600.0, result[:subtotal]
  end

  test "tax rate at boundary 100" do
    result = Finance::InvoiceGeneratorCalculator.new(
      line_items: [ { description: "Item", quantity: 1, unit_price: 100.0 } ],
      tax_rate: 100
    ).call
    assert result[:valid]
    assert_equal 100.0, result[:tax_amount]
    assert_equal 200.0, result[:total]
  end
end
