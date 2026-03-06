class ChangeLog < ApplicationRecord
  belongs_to :changed_by, class_name: "User"

  validates :entity_type, :entity_id, :field_name, :changed_at, presence: true
end
