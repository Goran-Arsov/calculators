# frozen_string_literal: true

# Builds the hash of translated strings that invoice generator Stimulus
# controllers (simple + detailed variants) read via a data-*-value attribute.
#
# Every string that would otherwise be hardcoded inside the JS controller
# (preview labels, PDF section headings, fallback placeholders) flows through
# this helper so it can be localized via i18n.
module InvoiceHelper
  def invoice_labels(key_prefix:)
    labels_key = "#{key_prefix}.labels"
    placeholders_key = "#{key_prefix}.placeholders"

    {
      invoiceHeading: t("#{key_prefix}.pdf.invoice", default: "INVOICE"),
      billTo: t("#{key_prefix}.pdf.bill_to", default: "Bill To"),
      description: t("#{key_prefix}.pdf.description", default: "Description"),
      qty: t("#{key_prefix}.pdf.qty", default: "Qty"),
      unitPrice: t("#{key_prefix}.pdf.unit_price", default: "Unit Price"),
      amount: t("#{key_prefix}.pdf.amount", default: "Amount"),
      subtotal: t("#{labels_key}.subtotal", default: "Subtotal"),
      tax: t("#{labels_key}.tax", default: "Tax"),
      discount: t("#{key_prefix}.pdf.discount", default: "Discount"),
      total: t("#{labels_key}.total", default: "Total"),
      notes: t("#{labels_key}.notes", default: "Notes"),
      terms: t("#{labels_key}.terms", default: "Terms & Conditions"),
      paymentDetails: t("#{key_prefix}.pdf.payment_details", default: "Payment Details"),
      iban: t("#{labels_key}.iban", default: "IBAN"),
      swift: t("#{labels_key}.swift", default: "SWIFT/BIC"),
      taxId: t("#{labels_key}.tax_id", default: "Tax ID"),
      date: t("#{key_prefix}.pdf.date", default: "Date"),
      dueDate: t("#{labels_key}.due_date", default: "Due Date"),
      invoiceNumber: t("#{labels_key}.invoice_number", default: "Invoice #"),
      noItems: t("#{key_prefix}.pdf.no_items", default: "No items added yet"),
      businessNameFallback: t("#{placeholders_key}.business_name", default: "Your Business Name"),
      clientNameFallback: t("#{placeholders_key}.client_name", default: "Client Name"),

      # Detailed invoice extras (ignored by the simple variant)
      item: t("#{key_prefix}.pdf.item", default: "Item"),
      code: t("#{key_prefix}.pdf.code", default: "Code"),
      measure: t("#{key_prefix}.pdf.measure", default: "Measure"),
      price: t("#{key_prefix}.pdf.price", default: "Price"),
      withTax: t("#{key_prefix}.pdf.with_tax", default: "w/ Tax"),
      discountShort: t("#{key_prefix}.pdf.discount_short", default: "Disc."),
      grandTotal: t("#{labels_key}.grand_total", default: "Grand Total"),
      totalTax: t("#{labels_key}.total_tax", default: "Total Tax"),
      totalDiscount: t("#{labels_key}.total_discount", default: "Total Discount")
    }
  end
end
