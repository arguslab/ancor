module Providable
  extend ActiveSupport::Concern
  include Mongoid::Document
  include Ancor::Extensions::IndifferentAccess

  included do
    field :provider_details, type: Hash, default: -> { {} }, pre_processed: true
    belongs_to :provider_endpoint
  end
end
