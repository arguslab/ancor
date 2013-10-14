require 'hashie'

module Ancor
  module Extensions
    module Mash
      extend ActiveSupport::Concern

      def mongoize
        to_hash
      end

      module ClassMethods
        def demongoize(object)
          new object
        end

        def mongoize(object)
          case object
          when Hashie::Mash then object.mongoize
          else object
          end
        end

        def evolve(object)
          case object
          when Hashie::Mash then object.mongoize
          else object
          end
        end
      end # ClassMethods
    end # Mash
  end # Extensions
end

class Hashie::Mash
  include Ancor::Extensions::Mash
end
