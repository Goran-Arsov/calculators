module Api
  class RatingsController < ApplicationController
    skip_before_action :set_http_cache
    skip_forgery_protection

    rate_limit to: 10, within: 1.hour, by: -> { request.remote_ip }, only: :create,
              with: -> { render json: { success: false, error: "Too many ratings. Please try again later." }, status: :too_many_requests }

    def create
      score = params[:score].to_i
      unless score.between?(1, 5)
        return render json: { success: false, error: "Score must be between 1 and 5" }, status: :unprocessable_entity
      end

      ip_hash = Digest::SHA256.hexdigest("#{request.remote_ip}:#{Rails.application.secret_key_base}")
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

      expires_in 5.minutes, public: true
      render json: { average: stats[:average], count: stats[:count] }
    end
  end
end
