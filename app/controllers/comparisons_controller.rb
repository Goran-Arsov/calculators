class ComparisonsController < ApplicationController
  before_action :set_cache_headers

  def mortgage_terms; end      # 15 vs 30 year
  def bmi_vs_body_fat; end
  def stocks_vs_crypto; end
  def keto_vs_macros; end
  def simple_vs_compound; end

  private

  def set_cache_headers
    expires_in 1.hour, public: true
  end
end
