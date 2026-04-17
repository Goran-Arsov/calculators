require "test_helper"

class InvoiceHelperTest < ActionView::TestCase
  include InvoiceHelper

  EXPECTED_KEYS = %i[
    invoiceHeading billTo description qty unitPrice amount
    subtotal tax discount total notes terms paymentDetails
    iban swift taxId date dueDate invoiceNumber noItems
    businessNameFallback clientNameFallback invoiceNumberPrefix
    rowUnitPlaceholder rowItemCodePlaceholder
    item code measure price withTax discountShort
    grandTotal totalTax totalDiscount
  ].freeze

  test "returns a hash keyed by camelCase label names" do
    labels = invoice_labels(key_prefix: "finance.calculators.invoice_generator")

    assert_kind_of Hash, labels
    assert_equal EXPECTED_KEYS.sort, labels.keys.sort
  end

  test "falls back to English defaults when translation keys are missing" do
    labels = invoice_labels(key_prefix: "finance.calculators.nonexistent_key_xyz")

    assert_equal "INVOICE", labels[:invoiceHeading]
    assert_equal "Bill To", labels[:billTo]
    assert_equal "Description", labels[:description]
    assert_equal "Qty", labels[:qty]
    assert_equal "Unit Price", labels[:unitPrice]
    assert_equal "Total", labels[:total]
    assert_equal "INV", labels[:invoiceNumberPrefix]
    assert_equal "Your Business Name", labels[:businessNameFallback]
  end

  test "all values are strings" do
    labels = invoice_labels(key_prefix: "finance.calculators.invoice_generator")

    labels.each do |key, value|
      assert_kind_of String, value, "expected string for #{key}"
      refute_empty value, "expected non-empty string for #{key}"
    end
  end

  test "output is serializable to JSON for the Stimulus data attribute" do
    labels = invoice_labels(key_prefix: "finance.calculators.invoice_generator")

    assert_nothing_raised { labels.to_json }
  end
end
