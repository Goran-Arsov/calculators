class NewsletterSubscriptionsController < ApplicationController
  rate_limit to: 5, within: 1.hour, by: -> { request.remote_ip }, with: -> { head :too_many_requests }

  def create
    subscriber = NewsletterSubscriber.find_or_initialize_by(email: subscriber_params[:email]&.downcase&.strip)
    subscriber.ip_address = request.remote_ip

    if subscriber.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: "You're subscribed! Check your inbox." }
        format.json { render json: { success: true, message: "You're subscribed!" } }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: "Please enter a valid email address." }
        format.json { render json: { success: false, message: "Please enter a valid email." }, status: :unprocessable_entity }
      end
    end
  end

  private

  def subscriber_params
    params.require(:newsletter_subscriber).permit(:email)
  end
end
