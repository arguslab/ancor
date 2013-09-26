class Task
  include Mongoid::Document

  field :class_name, type: String
  field :parameters, type: Array

  field :parent_id, type: String

  def children
    Task.where(parent_id: id).all
  end
end
