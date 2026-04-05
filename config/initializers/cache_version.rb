# Stable version string for ETag generation and fragment cache keys.
# Changes on every deploy, which automatically invalidates all cached content.
#
# Priority: CACHE_VERSION env var > REVISION file (set by Kamal/Capistrano) > git SHA > fallback
CACHE_VERSION = ENV.fetch("CACHE_VERSION") {
  revision_file = Rails.root.join("REVISION")
  if revision_file.exist?
    revision_file.read.strip
  else
    `git rev-parse --short HEAD 2>/dev/null`.strip.presence || "v1"
  end
}.freeze
