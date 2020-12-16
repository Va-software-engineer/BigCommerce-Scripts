class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_header_for_iframe

  # require to remove X-Frame-Options to load Rails app in iframe on Bigcommerce
  def set_header_for_iframe
    response.headers.delete "X-Frame-Options"
  end
end
