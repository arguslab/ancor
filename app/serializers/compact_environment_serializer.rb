class CompactEnvironmentSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :description, :locked

  def locked
    object.locked?
  end
end
