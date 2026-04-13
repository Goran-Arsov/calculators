# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/utils", under: "utils"
pin "qrcode-generator" # @2.0.4

# PDF generation for invoices — loaded dynamically on demand.
# html2canvas-pro supports modern CSS (oklch from Tailwind v4); plain html2canvas does not.
pin "jspdf", to: "https://cdn.jsdelivr.net/npm/jspdf@2.5.2/+esm"
pin "html2canvas-pro", to: "https://cdn.jsdelivr.net/npm/html2canvas-pro@1.5.8/+esm"
