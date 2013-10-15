require 'ancor/extensions/mash'

module Providable
  extend ActiveSupport::Concern
  include Mongoid::Document

  included do
    field :provider_details, type: Hash, default: -> { {} }
    belongs_to :provider
  end
end
