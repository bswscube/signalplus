class ApplicationController < ActionController::Base
  force_ssl if: :should_ssl?
  protect_from_forgery with: :exception
  after_action :flash_to_http_header
  before_action :set_paper_trail_whodunnit

  private

  def flash_to_http_header
    return unless request.xhr?
    return if flash.empty?
    response.headers['X-FlashMessages'] = flash.to_hash.to_json
    flash.discard  # don't want the flash to appear when you reload page
  end

  def should_ssl?
    Rails.env.production?
  end
end
