class Comment < ApplicationRecord
  serialize :mentions, coder: JSON

  belongs_to :task
  belongs_to :user

  validates :body, presence: true

  def mentions
    super || []
  end

  def mentioned_users
    return User.none if mentions.empty?

    User.where(id: mentions)
  end
end
