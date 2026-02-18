module Auditable
  extend ActiveSupport::Concern

  included do
    has_many :audit_logs, as: :auditable, dependent: :destroy

    after_update :log_changes
  end

  def log_changes
    return if previous_changes.except("updated_at").empty?
    return unless Current.user

    AuditLog.create!(
      auditable: self,
      user: Current.user,
      action: "update",
      changed_data: previous_changes.except("updated_at")
    )
  end
end
