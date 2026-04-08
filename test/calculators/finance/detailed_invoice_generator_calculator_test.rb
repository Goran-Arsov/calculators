require "test_helper"

class Finance::DetailedInvoiceGeneratorCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "single line item without tax or discount" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Widget", item_code: "W-001", unit: "pcs", quantity: 5, unit_price: 10.0, tax: 0, discount_type: "none" } ]
    ).call

    assert result[:valid]
    assert_equal 50.0, result[:subtotal]
    assert_equal 0.0, result[:total_tax]
    assert_equal 0.0, result[:total_discount]
    assert_equal 50.0, result[:grand_total]
    assert_equal 1, result[:line_items].length
    assert_equal 50.0, result[:line_items][0][:subtotal]
    assert_equal 50.0, result[:line_items][0][:price_with_tax]
    assert_equal 50.0, result[:line_items][0][:line_total]
  end

  test "single line item with tax" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Service", quantity: 1, unit_price: 200.0, tax: 20 } ]
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:subtotal]
    assert_equal 40.0, result[:total_tax]
    assert_equal 240.0, result[:grand_total]
    assert_equal 240.0, result[:line_items][0][:price_with_tax]
  end

  test "multiple line items with different tax rates" do
    items = [
      { item_name: "Food item", item_code: "F-01", unit: "kg", quantity: 2, unit_price: 25.0, tax: 5 },
      { item_name: "Electronics", item_code: "E-01", unit: "pcs", quantity: 1, unit_price: 100.0, tax: 20 }
    ]
    result = Finance::DetailedInvoiceGeneratorCalculator.new(line_items: items).call

    assert result[:valid]
    assert_equal 150.0, result[:subtotal]

    food = result[:line_items][0]
    assert_equal 50.0, food[:subtotal]
    assert_equal 2.5, food[:tax_amount]
    assert_equal 52.5, food[:price_with_tax]

    electronics = result[:line_items][1]
    assert_equal 100.0, electronics[:subtotal]
    assert_equal 20.0, electronics[:tax_amount]
    assert_equal 120.0, electronics[:price_with_tax]

    assert_equal 22.5, result[:total_tax]
    assert_equal 172.5, result[:grand_total]
  end

  test "line item with percent discount" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Product", quantity: 4, unit_price: 50.0, tax: 10, discount_type: "percent", discount_value: 10 } ]
    ).call

    assert result[:valid]
    item = result[:line_items][0]
    assert_equal 200.0, item[:subtotal]
    assert_equal 20.0, item[:tax_amount]
    assert_equal 220.0, item[:price_with_tax]
    assert_equal 22.0, item[:discount_amount]
    assert_equal 198.0, item[:line_total]
  end

  test "line item with flat discount" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Product", quantity: 2, unit_price: 100.0, tax: 0, discount_type: "flat", discount_value: 15 } ]
    ).call

    assert result[:valid]
    item = result[:line_items][0]
    assert_equal 200.0, item[:subtotal]
    assert_equal 200.0, item[:price_with_tax]
    assert_equal 15.0, item[:discount_amount]
    assert_equal 185.0, item[:line_total]
  end

  test "mixed items with different discounts and taxes" do
    items = [
      { item_name: "A", quantity: 10, unit_price: 20.0, tax: 10, discount_type: "percent", discount_value: 5 },
      { item_name: "B", quantity: 1, unit_price: 500.0, tax: 0, discount_type: "flat", discount_value: 50 },
      { item_name: "C", quantity: 3, unit_price: 30.0, tax: 20, discount_type: "none" }
    ]
    result = Finance::DetailedInvoiceGeneratorCalculator.new(line_items: items).call

    assert result[:valid]

    a = result[:line_items][0]
    assert_equal 200.0, a[:subtotal]
    assert_equal 20.0, a[:tax_amount]
    assert_equal 220.0, a[:price_with_tax]
    assert_equal 11.0, a[:discount_amount]
    assert_equal 209.0, a[:line_total]

    b = result[:line_items][1]
    assert_equal 500.0, b[:subtotal]
    assert_equal 0.0, b[:tax_amount]
    assert_equal 500.0, b[:price_with_tax]
    assert_equal 50.0, b[:discount_amount]
    assert_equal 450.0, b[:line_total]

    c = result[:line_items][2]
    assert_equal 90.0, c[:subtotal]
    assert_equal 18.0, c[:tax_amount]
    assert_equal 108.0, c[:price_with_tax]
    assert_equal 0.0, c[:discount_amount]
    assert_equal 108.0, c[:line_total]

    assert_equal 790.0, result[:subtotal]
    assert_equal 38.0, result[:total_tax]
    assert_equal 61.0, result[:total_discount]
    assert_equal 767.0, result[:grand_total]
  end

  test "preserves item metadata in output" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Bolt", item_code: "BLT-M8", unit: "pcs", quantity: 100, unit_price: 0.5, tax: 20, discount_type: "none" } ]
    ).call

    assert result[:valid]
    item = result[:line_items][0]
    assert_equal "Bolt", item[:item_name]
    assert_equal "BLT-M8", item[:item_code]
    assert_equal "pcs", item[:unit]
  end

  test "zero tax rate" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 100.0, tax: 0 } ]
    ).call

    assert result[:valid]
    assert_equal 0.0, result[:total_tax]
    assert_equal 100.0, result[:grand_total]
  end

  test "zero discount" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 100.0, tax: 10, discount_type: "percent", discount_value: 0 } ]
    ).call

    assert result[:valid]
    assert_equal 0.0, result[:total_discount]
    assert_equal 110.0, result[:grand_total]
  end

  # --- Validation errors ---

  test "error when line items is empty" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(line_items: []).call
    refute result[:valid]
    assert_includes result[:errors], "At least one line item is required"
  end

  test "error when quantity is zero" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 0, unit_price: 10.0, tax: 0 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: quantity must be greater than 0"
  end

  test "error when quantity is negative" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: -2, unit_price: 10.0, tax: 0 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: quantity must be greater than 0"
  end

  test "error when unit price is negative" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: -5.0, tax: 0 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: unit price must be 0 or greater"
  end

  test "allows zero unit price" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Free item", quantity: 1, unit_price: 0, tax: 0 } ]
    ).call
    assert result[:valid]
    assert_equal 0.0, result[:subtotal]
  end

  test "error when tax exceeds 100" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 50.0, tax: 101 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: tax must be between 0 and 100"
  end

  test "error when tax is negative" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 50.0, tax: -5 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: tax must be between 0 and 100"
  end

  test "error when discount value is negative" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 50.0, tax: 0, discount_type: "percent", discount_value: -10 } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: discount value must be 0 or greater"
  end

  test "error when discount type is invalid" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 50.0, tax: 0, discount_type: "bogus" } ]
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Line item 1: discount type must be percent, flat, or none"
  end

  # --- Edge cases ---

  test "very large numbers" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Big ticket", quantity: 1_000_000, unit_price: 999_999.99, tax: 20 } ]
    ).call
    assert result[:valid]
    assert_equal 999_999_990_000.0, result[:subtotal]
    assert_equal 199_999_998_000.0, result[:total_tax]
    assert_equal 1_199_999_988_000.0, result[:grand_total]
  end

  test "multiple validation errors at once" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [
        { item_name: "A", quantity: -1, unit_price: -5, tax: -1 },
        { item_name: "B", quantity: 0, unit_price: 10, tax: 101 }
      ]
    ).call
    refute result[:valid]
    assert result[:errors].length >= 4
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 10.0, tax: 0 } ]
    )
    assert_equal [], calc.errors
  end

  test "decimal quantities" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Hours worked", quantity: 7.5, unit_price: 80.0, tax: 0 } ]
    ).call
    assert result[:valid]
    assert_equal 600.0, result[:subtotal]
  end

  test "tax rate at boundary 100" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 1, unit_price: 100.0, tax: 100 } ]
    ).call
    assert result[:valid]
    assert_equal 100.0, result[:total_tax]
    assert_equal 200.0, result[:grand_total]
  end

  test "discount type defaults to none when not specified" do
    result = Finance::DetailedInvoiceGeneratorCalculator.new(
      line_items: [ { item_name: "Item", quantity: 2, unit_price: 50.0, tax: 10 } ]
    ).call
    assert result[:valid]
    assert_equal 0.0, result[:total_discount]
    assert_equal 110.0, result[:grand_total]
  end
end
