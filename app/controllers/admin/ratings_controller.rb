# frozen_string_literal: true

module Admin
  class RatingsController < BaseController
    skip_before_action :authenticate_admin, only: [ :login, :submit_login ]
    rate_limit to: 5, within: 1.minute, by: -> { request.remote_ip }, only: :submit_login,
               with: -> { redirect_to admin_login_path, alert: "Too many attempts. Try again later." }

    def login
      redirect_to admin_ratings_path if admin_signed_in?
    end

    def submit_login
      if params[:token].present? && ActiveSupport::SecurityUtils.secure_compare(params[:token], admin_token)
        session[:admin_authenticated] = true
        redirect_to admin_ratings_path, notice: "Logged in successfully."
      else
        redirect_to admin_login_path, alert: "Invalid token."
      end
    end

    def logout
      session.delete(:admin_authenticated)
      redirect_to admin_login_path, notice: "Logged out."
    end

    def index
      ratings_data = CalculatorRating
        .with_score
        .group(:calculator_slug)
        .select(
          "calculator_slug",
          "ROUND(AVG(score)::numeric, 1) AS avg_score",
          "COUNT(*) AS total_count",
          "MAX(created_at) AS latest_rating"
        )

      # Apply filters
      @min_stars = params[:min_stars].present? ? params[:min_stars].to_f : nil
      @max_stars = params[:max_stars].present? ? params[:max_stars].to_f : nil

      if @min_stars
        ratings_data = ratings_data.having("AVG(score) >= ?", @min_stars)
      end
      if @max_stars
        ratings_data = ratings_data.having("AVG(score) <= ?", @max_stars)
      end

      # Sort
      @sort = params[:sort] || "avg_score"
      @direction = params[:direction] || "asc"

      @ratings = case @sort
      when "avg_score"
        ratings_data.order(Arel.sql("AVG(score) #{@direction == 'desc' ? 'DESC' : 'ASC'}"))
      when "total_count"
        ratings_data.order(Arel.sql("COUNT(*) #{@direction == 'desc' ? 'DESC' : 'ASC'}"))
      when "latest_rating"
        ratings_data.order(Arel.sql("MAX(created_at) #{@direction == 'desc' ? 'DESC' : 'ASC'}"))
      when "slug"
        ratings_data.order(Arel.sql("calculator_slug #{@direction == 'desc' ? 'DESC' : 'ASC'}"))
      else
        ratings_data.order(Arel.sql("AVG(score) ASC"))
      end

      @total_ratings = CalculatorRating.with_score.count
      @total_calculators = CalculatorRating.with_score.distinct.count(:calculator_slug)
      @overall_avg = CalculatorRating.with_score.average(:score)&.round(1) || 0.0
    end

    private

    def admin_signed_in?
      session[:admin_authenticated] == true
    end

    def admin_token
      ENV.fetch("ADMIN_TOKEN") { raise "ADMIN_TOKEN environment variable is required" }
    end
  end
end
