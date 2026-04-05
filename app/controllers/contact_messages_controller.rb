class ContactMessagesController < ApplicationController
  rate_limit to: 5, within: 1.hour, by: -> { request.remote_ip }, with: -> { redirect_to contact_path, alert: "Too many messages. Please try again later." }

  def create
    @message = ContactMessage.new(contact_params)
    @message.ip_address = request.remote_ip

    if @message.save
      redirect_to contact_path, notice: "Thank you! Your message has been sent. We'll respond within 1-2 business days."
    else
      redirect_to contact_path, alert: "Please fill in all fields correctly and try again."
    end
  end

  private

  def contact_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
