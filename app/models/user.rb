class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    worker: 0,
    sales_manager: 1,
    project_manager: 2,
    production_manager: 3,
    director: 4,
    admin: 5
  }

  ROLE_TRANSLATIONS = {
    "worker" => "Исполнитель",
    "sales_manager" => "Менеджер по продажам",
    "project_manager" => "Руководитель проекта",
    "production_manager" => "Начальник производства",
    "director" => "Директор",
    "admin" => "Администратор"
  }.freeze

  def role_name
    ROLE_TRANSLATIONS[role] || role.humanize
  end

  def is_admin?
    admin? || director?
  end

  has_many :created_projects, class_name: "Project", foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :created_tasks, class_name: "Task", foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :assigned_tasks, class_name: "Task", foreign_key: :assignee_id, dependent: :nullify
  has_many :task_assignees, dependent: :destroy
  has_many :tasks_as_assignee, through: :task_assignees, source: :task
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :role, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.all_workers
    User.where(role: ["worker", "production_manager"])
  end
end
