class Task
  include Mongoid::Document

  field :type, type: String
  field :parameters, type: Hash
end
