class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    executor: 0,
    sales_manager: 1,
    project_manager: 2,
    production_head: 3,
    director: 4,
    admin: 5
  }

  has_many :created_projects, class_name: "Project", foreign_key: :creator_id, dependent: :restrict_with_error
  has_many :created_tasks, class_name: "Task", foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :role, presence: true

  ROLE_TRANSLATIONS = {
    "executor"         => "Исполнитель",
    "sales_manager"    => "Менеджер по продажам",
    "project_manager"  => "Менеджер проекта",
    "production_head"  => "Руководитель производства",
    "director"         => "Директор",
    "admin"            => "Администратор"
  }.freeze

  def full_name
    "#{first_name} #{last_name}"
  end

  def role_name
    ROLE_TRANSLATIONS[role] || role
  end

  def is_admin?
    admin? || director?
  end

  def self.executors
    where(role: :executor)
  end
end
