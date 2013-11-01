module Ancor
  module Extensions
    # Inspired by mongoid-indifferent-access
    module IndifferentAccess
      extend ActiveSupport::Concern
      include Mongoid::Document

      module ClassMethods
        def field(name, options = {})
          field = super(name, options)

          if field.type == Hash
            getter_name = name.to_sym
            setter_name = "#{name}=".to_sym

            mash_define_getter getter_name, setter_name
            mash_define_setter setter_name

            descendants.each do |subclass|
              subclass.mash_define_getter getter_name, setter_name
              subclass.mash_define_setter setter_name
            end
          end

          field
        end

        def mash_define_getter(getter_name, setter_name)
          define_method(getter_name) do
            val = super()
            unless val.nil? || val.is_a?(Hashie::Mash)
              wrapped = Hashie::Mash.new val
              send(setter_name, wrapped) unless frozen?
              val = wrapped
            end

            val
          end
        end

        def mash_define_setter(setter_name)
          define_method(setter_name) do |val|
            unless val.nil? || val.is_a?(Hashie::Mash)
              val = Hashie::Mash.new val
            end

            super val
          end
        end
      end # ClassMethods
    end # IndifferentAccess
  end # Extensions
end
