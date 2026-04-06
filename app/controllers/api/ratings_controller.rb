module Api
  class RatingsController < ApplicationController
    skip_before_action :set_http_cache
    skip_forgery_protection

    def create
      ip_hash = Digest::SHA256.hexdigest("#{request.remote_ip}:#{Rails.application.secret_key_base}")
      score = params[:score].to_i
      direction = score >= 3 ? "up" : "down"

      rating = CalculatorRating.new(
        calculator_slug: params[:slug],
        direction: direction,
        score: score,
        ip_hash: ip_hash
      )

      if rating.save
        stats = CalculatorRating.star_stats_for(params[:slug])
        render json: { success: true, average: stats[:average], count: stats[:count] }
      else
        stats = CalculatorRating.star_stats_for(params[:slug])
        render json: { success: false, errors: rating.errors.full_messages, average: stats[:average], count: stats[:count] }, status: :unprocessable_entity
      end
    end

    def show
      stats = CalculatorRating.star_stats_for(params[:slug])
      render json: { average: stats[:average], count: stats[:count] }
    end
  end
end
