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
    policy.script_src  :self, :https, :unsafe_inline, :unsafe_eval,
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

  # Report violations without enforcing — enable this first to find issues,
  # then switch to enforcing mode once clean.
  config.content_security_policy_report_only = true
end
