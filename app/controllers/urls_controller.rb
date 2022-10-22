# frozen_string_literal: true

class UrlsController < ApplicationController
  before_action :find_url, only: [:visit]
  def index
    # recent 10 short urls
    @url = Url.new
    @urls = Url.all
  end

  def create
    @url = Url.new(url_params)
    @url.short_url = @url.generate_short_url
    @url.original_url = @url.sanitize
    if @url.save
      redirect_to urls_path
    else
      flash[:error] = @url.errors.full_messages
      redirect_to new_url_path
    end
  end

  def show
    @url = Url.find_by(short_url: params[:url])
  end

  def visit
    if @url.present?
      @url.clicks.create(browser: browser.name, platform: browser.platform.name)
      @url.update(clicks_count: @url.clicks_count + 1)
      redirect_to @url.original_url, status: :moved_permanently
    else
      flash[:notice] = 'You have enetered wrong shorten URL'
      redirect_to root_path
    end
  end

  private

  def find_url
    @url = Url.find_by(short_url: params[:short_url])
  end

  def url_params
    params.require(:url).permit(:original_url)
  end

  def browser
    @browser ||= Browser.new(
      request.headers['User-Agent'],
      accept_language: request.headers['Accept-Language']
    )
  end
end
