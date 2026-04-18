// Rasterize an HTML string through the browser and wrap the bitmap in a
// multi-page jsPDF document. This sidesteps the base-PDF-font limitation
// (WinAnsiEncoding + Type 1 Helvetica) that produced mojibake for Cyrillic
// and any other non-WinAnsi script. All scripts now render through the
// browser's system fonts, which cover Unicode natively.

const DEFAULT_CSS = `
  * { box-sizing: border-box; }
  h1 { font-size: 22pt; font-weight: bold; margin: 0 0 10pt; }
  h2 { font-size: 18pt; font-weight: bold; margin: 14pt 0 6pt; }
  h3 { font-size: 15pt; font-weight: bold; margin: 12pt 0 5pt; }
  h4 { font-size: 13pt; font-weight: bold; margin: 10pt 0 4pt; }
  h5 { font-size: 12pt; font-weight: bold; margin: 10pt 0 4pt; }
  h6 { font-size: 11pt; font-weight: bold; margin: 10pt 0 4pt; }
  p { margin: 0 0 6pt; }
  ul, ol { margin: 0 0 6pt; padding-left: 20pt; }
  li { margin: 0 0 3pt; }
  blockquote { margin: 6pt 0 6pt 10pt; padding-left: 8pt; border-left: 2pt solid #bbb; color: #555; font-style: italic; }
  hr { border: none; border-top: 0.5pt solid #aaa; margin: 10pt 0; }
  code { font-family: "Courier New", monospace; background: #f0f0f0; padding: 1pt 3pt; border-radius: 2pt; font-size: 90%; }
  pre { background: #f0f0f0; padding: 8pt; border-radius: 3pt; margin: 8pt 0; white-space: pre-wrap; overflow-wrap: break-word; font-family: "Courier New", monospace; font-size: 9pt; }
  pre code { background: none; padding: 0; font-size: inherit; }
  table { border-collapse: collapse; width: 100%; font-size: 9pt; margin: 6pt 0; table-layout: fixed; word-wrap: break-word; }
  th { border: 0.5pt solid #333; padding: 5pt; background: #3366b2; color: #fff; text-align: left; font-weight: bold; }
  td { border: 0.5pt solid #ccc; padding: 5pt; vertical-align: top; }
  tbody tr:nth-child(even) { background: #f5f5f5; }
  a { color: #0066cc; text-decoration: none; }
  img { max-width: 100%; }
  del { text-decoration: line-through; }
`

export async function downloadHtmlAsPdf(bodyHtml, options = {}) {
  const {
    filename = "document.pdf",
    fontSize = 11,
    pageFormat = "a4",
    marginPt = 50,
    extraCss = ""
  } = options

  const [{ default: html2canvas }, { jsPDF }] = await Promise.all([
    import("html2canvas-pro"),
    import("jspdf")
  ])

  const pageWidthPt = pageFormat === "letter" ? 612 : 595.28

  const container = document.createElement("div")
  container.style.cssText = [
    "position: absolute",
    "left: -99999px",
    "top: 0",
    `width: ${pageWidthPt}pt`,
    `padding: ${marginPt}pt`,
    "background: #ffffff",
    "color: #000000",
    'font-family: Arial, Helvetica, "Liberation Sans", sans-serif',
    `font-size: ${fontSize}pt`,
    "line-height: 1.4",
    "word-wrap: break-word",
    "overflow-wrap: break-word"
  ].join(";")

  container.innerHTML = `<style>${DEFAULT_CSS}${extraCss}</style>${bodyHtml}`
  document.body.appendChild(container)

  let canvas
  try {
    canvas = await html2canvas(container, {
      scale: 2,
      backgroundColor: "#ffffff",
      useCORS: true,
      logging: false
    })
  } finally {
    container.remove()
  }

  const pdf = new jsPDF({ orientation: "portrait", unit: "pt", format: pageFormat })
  const pageWidth = pdf.internal.pageSize.getWidth()
  const pageHeight = pdf.internal.pageSize.getHeight()

  const imgWidth = pageWidth
  const imgHeight = (canvas.height * imgWidth) / canvas.width
  const imgData = canvas.toDataURL("image/jpeg", 0.92)

  if (imgHeight <= pageHeight) {
    pdf.addImage(imgData, "JPEG", 0, 0, imgWidth, imgHeight)
  } else {
    let remainingHeight = imgHeight
    let position = 0
    while (remainingHeight > 0) {
      pdf.addImage(imgData, "JPEG", 0, position, imgWidth, imgHeight)
      remainingHeight -= pageHeight
      position -= pageHeight
      if (remainingHeight > 0) pdf.addPage()
    }
  }

  pdf.save(filename)
}

export function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;")
}
