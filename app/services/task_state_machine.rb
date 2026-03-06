class TaskStateMachine
  class InvalidTransition < StandardError; end

  TRANSITIONS = {
    "draft"                => %w[awaiting_approval cancelled],
    "awaiting_approval"    => %w[approved cancelled],
    "approved"             => %w[in_progress cancelled],
    "in_progress"          => %w[pending_confirmation cancelled],
    "pending_confirmation" => %w[completed in_progress]
  }.freeze

  def initialize(task, actor:)
    @task = task
    @actor = actor
  end

  def submit!
    transition_to!("awaiting_approval")
  end

  def approve!
    transition_to!("approved") do
      @task.approved_by = @actor
      @task.approved_at = Time.current
    end
  end

  def cancel!
    transition_to!("cancelled")
  end

  def start!
    transition_to!("in_progress") do
      @task.actual_start_at = Time.current
    end
  end

  def complete!
    transition_to!("pending_confirmation") do
      @task.actual_due_at = Time.current
    end
  end

  def confirm!
    transition_to!("completed")
  end

  def reject_completion!
    transition_to!("in_progress")
  end

  private

  def transition_to!(new_status)
    allowed = TRANSITIONS[@task.status] || []
    unless allowed.include?(new_status)
      raise InvalidTransition, "Cannot transition from #{@task.status} to #{new_status}"
    end

    yield if block_given?
    @task.status = new_status
    @task.save!
  end
end
