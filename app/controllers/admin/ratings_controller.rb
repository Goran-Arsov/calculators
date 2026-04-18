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
      @min_stars = params[:min_stars].present? ? params[:min_stars].to_f : nil
      @max_stars = params[:max_stars].present? ? params[:max_stars].to_f : nil
      @sort      = params[:sort] || CalculatorRating::DEFAULT_ADMIN_SORT
      @direction = params[:direction] || "asc"

      @ratings = CalculatorRating
        .aggregated_by_calculator
        .with_avg_score_at_least(@min_stars)
        .with_avg_score_at_most(@max_stars)
        .ordered_by_aggregate(@sort, @direction)

      summary = CalculatorRating.admin_summary
      @total_ratings     = summary[:total_ratings]
      @total_calculators = summary[:total_calculators]
      @overall_avg       = summary[:overall_avg]
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
