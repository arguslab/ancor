# Author: Ian Unruh, Alexandru G. Bardas
# Copyright (C) 2013-2014 Argus Cybersecurity Lab, Kansas State University
#
# This file is part of ANCOR.
#
# ANCOR is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ANCOR is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with ANCOR.  If not, see <http://www.gnu.org/licenses/>.
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
