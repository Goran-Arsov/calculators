// CalcWise Service Worker — offline calculator support
const CACHE_NAME = "calcwise-v1"
const STATIC_ASSETS = [
  "/",
  "/manifest.json",
  "/icon.svg",
  "/icon.png"
]

// Install — cache static assets
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS))
  )
  self.skipWaiting()
})

// Activate — clean old caches
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  )
  self.clients.claim()
})

// Fetch — network-first for HTML, cache-first for assets
self.addEventListener("fetch", (event) => {
  const { request } = event
  const url = new URL(request.url)

  // Skip non-GET and cross-origin
  if (request.method !== "GET" || url.origin !== self.location.origin) return

  // Skip embed and API routes
  if (url.pathname.startsWith("/embed/") || url.pathname === "/up") return

  // HTML pages: network-first with offline fallback
  if (request.headers.get("Accept")?.includes("text/html")) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Cache successful HTML responses for offline use
          if (response.ok) {
            const clone = response.clone()
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(request, clone)
              // Limit HTML cache to 50 pages
              cache.keys().then((keys) => {
                const htmlKeys = keys.filter((k) => !k.url.match(/\.(js|css|png|jpg|svg|ico|woff2?|json)$/))
                if (htmlKeys.length > 50) {
                  htmlKeys.slice(0, htmlKeys.length - 50).forEach((k) => cache.delete(k))
                }
              })
            })
          }
          return response
        })
        .catch(() => caches.match(request).then((cached) => cached || caches.match("/")))
    )
    return
  }

  // Static assets: cache-first
  if (url.pathname.match(/\.(js|css|png|jpg|svg|ico|woff2?)$/)) {
    event.respondWith(
      caches.match(request).then((cached) =>
        cached || fetch(request).then((response) => {
          if (response.ok) {
            const clone = response.clone()
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone))
          }
          return response
        })
      )
    )
    return
  }
})
