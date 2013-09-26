module Ancor
  module Provisioning
    module Provider
      extend self

      attr_accessor :compute
      attr_accessor :network
      attr_accessor :object_store
    end
  end
end
