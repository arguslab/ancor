require 'ancor/extensions/mash'

module Providable
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    field :provider, type: Hashie::Mash, default: -> { Hashie::Mash.new }
  end
end
