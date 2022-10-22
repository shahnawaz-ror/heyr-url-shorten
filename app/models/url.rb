# frozen_string_literal: true

class Url < ApplicationRecord
  has_many :clicks
  before_create :generate_short_url, :sanitize

  def generate_short_url
    loop do
      rand_short_url = ('A'..'Z').to_a.sample(5).join
      break rand_short_url unless Url.where(short_url: rand_short_url).present?
    end
  end

  def sanitize
    original_url.strip!
    sanitize_url = original_url.downcase.gsub(%r{(https?://)|(www\.)}, '')
    "http://#{sanitize_url}"
  end
end
