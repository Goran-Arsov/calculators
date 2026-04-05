module Api
  class RatingsController < ApplicationController
    skip_before_action :set_http_cache
    skip_forgery_protection

    def create
      ip_hash = Digest::SHA256.hexdigest("#{request.remote_ip}:#{Rails.application.secret_key_base}")

      rating = CalculatorRating.new(
        calculator_slug: params[:slug],
        direction: params[:direction],
        ip_hash: ip_hash
      )

      if rating.save
        counts = CalculatorRating.counts_for(params[:slug])
        render json: { success: true, up: counts[:up], down: counts[:down] }
      else
        counts = CalculatorRating.counts_for(params[:slug])
        render json: { success: false, errors: rating.errors.full_messages, up: counts[:up], down: counts[:down] }, status: :unprocessable_entity
      end
    end

    def show
      counts = CalculatorRating.counts_for(params[:slug])
      render json: { up: counts[:up], down: counts[:down] }
    end
  end
end
