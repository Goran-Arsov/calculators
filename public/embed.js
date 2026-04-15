/**
 * Calc Hammer Embed Loader
 *
 * Usage:
 *   <script src="https://calchammer.com/embed.js"
 *           data-calculator="mortgage"
 *           data-category="finance"
 *           data-theme="auto"
 *           data-values="principal=300000&rate=6.5&years=30">
 *   </script>
 *
 * Options (via data attributes):
 *   data-calculator  — Calculator slug, e.g. "mortgage-calculator" (required)
 *   data-category    — Category slug, e.g. "finance" (required)
 *   data-theme       — "light", "dark", or "auto" (default: "auto")
 *   data-values      — Pre-filled values as query string, e.g. "principal=300000&rate=6.5"
 *   data-width       — Container width, e.g. "100%" (default: "100%")
 *   data-max-width   — Max width, e.g. "600px" (default: none)
 *   data-border      — Show border: "true" or "false" (default: "true")
 */
;(function () {
  "use strict"

  var ORIGIN = (function () {
    var scripts = document.querySelectorAll("script[data-calculator]")
    var current = scripts[scripts.length - 1]
    if (current && current.src) {
      var a = document.createElement("a")
      a.href = current.src
      return a.origin
    }
    return "https://calchammer.com"
  })()

  function init(script) {
    var calculator = script.getAttribute("data-calculator")
    var category = script.getAttribute("data-category")
    if (!calculator || !category) {
      console.warn("[Calc Hammer] data-calculator and data-category are required.")
      return
    }

    var theme = script.getAttribute("data-theme") || "auto"
    var values = script.getAttribute("data-values") || ""
    var width = script.getAttribute("data-width") || "100%"
    var maxWidth = script.getAttribute("data-max-width") || ""
    var showBorder = script.getAttribute("data-border") !== "false"

    // Build embed URL
    var src = ORIGIN + "/embed/" + encodeURIComponent(category) + "/" + encodeURIComponent(calculator)
    var params = []
    if (theme && theme !== "auto") params.push("theme=" + theme)
    if (values) params.push(values)
    if (params.length) src += "?" + params.join("&")

    // Create container
    var container = document.createElement("div")
    container.className = "calchammer-embed"
    container.style.cssText =
      "width:" + width + ";" +
      (maxWidth ? "max-width:" + maxWidth + ";" : "") +
      "overflow:hidden;"

    // Create iframe
    var iframe = document.createElement("iframe")
    iframe.src = src
    iframe.title = calculator.replace(/-/g, " ").replace(/\b\w/g, function (c) { return c.toUpperCase() })
    iframe.style.cssText =
      "width:100%;border:none;display:block;overflow:hidden;" +
      "border-radius:12px;" +
      (showBorder ? "border:1px solid #e5e7eb;" : "") +
      "min-height:300px;transition:height 0.2s ease;"
    iframe.setAttribute("loading", "lazy")
    iframe.setAttribute("allow", "clipboard-write")
    iframe.setAttribute("sandbox", "allow-scripts allow-same-origin allow-popups allow-forms allow-clipboard-write")

    container.appendChild(iframe)

    // Branding link
    var link = document.createElement("a")
    link.href = ORIGIN + "/" + encodeURIComponent(category) + "/" + encodeURIComponent(calculator)
    link.target = "_blank"
    link.rel = "noopener"
    link.textContent = "Powered by Calc Hammer"
    link.style.cssText =
      "display:block;text-align:center;padding:6px 0;font-size:11px;" +
      "color:#9ca3af;text-decoration:none;font-family:system-ui,sans-serif;"
    link.onmouseover = function () { link.style.color = "#3b82f6" }
    link.onmouseout = function () { link.style.color = "#9ca3af" }
    container.appendChild(link)

    // Insert after the script tag
    script.parentNode.insertBefore(container, script.nextSibling)

    // Listen for height messages from the embed
    window.addEventListener("message", function (event) {
      if (event.origin !== ORIGIN) return
      var data = event.data
      if (data && data.type === "calchammer:resize" && data.height) {
        // Match by src to support multiple embeds on one page
        if (iframe.contentWindow === event.source) {
          iframe.style.height = data.height + "px"
        }
      }
    })

    // Auto theme detection
    if (theme === "auto" && window.matchMedia) {
      var mq = window.matchMedia("(prefers-color-scheme: dark)")
      function applyTheme(dark) {
        var url = new URL(iframe.src)
        url.searchParams.set("theme", dark ? "dark" : "light")
        iframe.src = url.toString()
      }
      // Only apply if system preference is dark (embed defaults to light)
      if (mq.matches) applyTheme(true)
      mq.addEventListener("change", function (e) { applyTheme(e.matches) })
    }
  }

  // Initialize all embed scripts on the page
  var scripts = document.querySelectorAll("script[data-calculator][data-category]")
  for (var i = 0; i < scripts.length; i++) {
    init(scripts[i])
  }
})()
