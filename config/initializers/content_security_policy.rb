# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data, "fonts.gstatic.com"
    policy.img_src     :self, :https, :data, "pagead2.googlesyndication.com", "www.googletagmanager.com"
    policy.object_src  :none
    policy.script_src  :self, :https, :unsafe_eval,
                       "pagead2.googlesyndication.com",
                       "adservice.google.com",
                       "www.googletagmanager.com",
                       "www.google-analytics.com",
                       "partner.googleadservices.com",
                       "tpc.googlesyndication.com",
                       "www.google.com"
    policy.style_src   :self, :https, :unsafe_inline, "fonts.googleapis.com"
    policy.frame_src   :self, "googleads.g.doubleclick.net",
                       "tpc.googlesyndication.com",
                       "www.google.com"
    policy.connect_src :self, :https,
                       "pagead2.googlesyndication.com",
                       "www.google-analytics.com",
                       "www.googletagmanager.com",
                       "adservice.google.com"
  end

  # Generate nonces for inline scripts — replaces :unsafe_inline in script-src.
  # Each request gets a unique nonce; inline <script> tags must include
  # nonce="<%= content_security_policy_nonce %>" to be allowed.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report-only by default; set CSP_ENFORCE=true to switch to enforcement mode.
  config.content_security_policy_report_only = !ENV.fetch("CSP_ENFORCE", "false").then { |v| v == "true" }
end
