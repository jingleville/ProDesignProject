class ProductionOverviewQuery
  ACTIVE_STATUSES = %w[approved in_progress].freeze

  def initialize(threshold: 10)
    @threshold = threshold
  end

  def call
    Task.where(status: ACTIVE_STATUSES)
        .where.not(assignee_id: nil)
        .group_by(&:assignee_id)
  end

  def summary
    call.transform_values(&:count)
  end

  def overloaded_executors
    counts = summary
    user_ids = counts.select { |_, count| count > @threshold }.keys
    User.where(id: user_ids)
  end
end
