# Create users for each role
admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "Isodon46!!"
  u.first_name = "Андрей"
  u.last_name = "Гаврик"
  u.role = :admin
end

director = User.find_or_create_by!(email: "gden@inbox.ru") do |u|
  u.password = "password123"
  u.first_name = "Ivan"
  u.last_name = "Director"
  u.role = :director
end

pm = User.find_or_create_by!(email: "pm@example.com") do |u|
  u.password = "password123"
  u.first_name = "Maria"
  u.last_name = "ProjectManager"
  u.role = :project_manager
end

prod_manager = User.find_or_create_by!(email: "production@example.com") do |u|
  u.password = "password123"
  u.first_name = "Sergey"
  u.last_name = "ProductionManager"
  u.role = :production_manager
end

sales = User.find_or_create_by!(email: "sales@example.com") do |u|
  u.password = "password123"
  u.first_name = "Elena"
  u.last_name = "SalesManager"
  u.role = :sales_manager
end

worker1 = User.find_or_create_by!(email: "worker1@example.com") do |u|
  u.password = "password123"
  u.first_name = "Alexey"
  u.last_name = "Worker"
  u.role = :worker
end

worker2 = User.find_or_create_by!(email: "worker2@example.com") do |u|
  u.password = "password123"
  u.first_name = "Dmitry"
  u.last_name = "Worker"
  u.role = :worker
end

# Create projects
project1 = Project.find_or_create_by!(name: "Website Redesign") do |p|
  p.description = "Complete redesign of the corporate website"
  p.status = :active
  p.created_by = pm
end

project2 = Project.find_or_create_by!(name: "Mobile App Development") do |p|
  p.description = "Develop a mobile application for clients"
  p.status = :active
  p.created_by = pm
end

project3 = Project.find_or_create_by!(name: "Server Migration") do |p|
  p.description = "Migrate to new server infrastructure"
  p.status = :draft
  p.created_by = pm
end

# Create tasks for project 1
task1 = Task.find_or_create_by!(title: "Design mockups", project: project1) do |t|
  t.description = "Create design mockups for all pages"
  t.created_by = pm
  t.assignee = worker1
  t.status = :completed
  t.preliminary_start_at = Date.current - 14.days
  t.preliminary_due_at = Date.current - 7.days
  t.approved_start_at = Date.current - 14.days
  t.approved_due_at = Date.current - 7.days
  t.completed_at = Date.current - 6.days
end

task2 = Task.find_or_create_by!(title: "Frontend development", project: project1) do |t|
  t.description = "Implement frontend based on approved mockups"
  t.created_by = pm
  t.assignee = worker1
  t.status = :in_progress
  t.preliminary_start_at = Date.current - 5.days
  t.preliminary_due_at = Date.current + 5.days
  t.approved_start_at = Date.current - 5.days
  t.approved_due_at = Date.current + 5.days
end

task3 = Task.find_or_create_by!(title: "Backend API", project: project1) do |t|
  t.description = "Develop backend API endpoints"
  t.created_by = pm
  t.assignee = worker2
  t.status = :in_progress
  t.preliminary_start_at = Date.current - 3.days
  t.preliminary_due_at = Date.current + 7.days
  t.approved_start_at = Date.current - 3.days
  t.approved_due_at = Date.current + 7.days
end

task4 = Task.find_or_create_by!(title: "Testing", project: project1) do |t|
  t.description = "QA testing of all features"
  t.created_by = pm
  t.status = :approved
  t.preliminary_start_at = Date.current + 6.days
  t.preliminary_due_at = Date.current + 12.days
  t.approved_start_at = Date.current + 6.days
  t.approved_due_at = Date.current + 12.days
end

# Create dependencies
TaskDependency.find_or_create_by!(task: task2, depends_on_task: task1)
TaskDependency.find_or_create_by!(task: task4, depends_on_task: task2)
TaskDependency.find_or_create_by!(task: task4, depends_on_task: task3)

# Tasks for project 2
task5 = Task.find_or_create_by!(title: "Requirements analysis", project: project2) do |t|
  t.description = "Analyze and document requirements"
  t.created_by = pm
  t.status = :awaiting_production_approval
  t.preliminary_start_at = Date.current
  t.preliminary_due_at = Date.current + 5.days
end

task6 = Task.find_or_create_by!(title: "UI/UX Design", project: project2) do |t|
  t.description = "Design the mobile app interface"
  t.created_by = pm
  t.status = :draft
  t.preliminary_start_at = Date.current + 6.days
  t.preliminary_due_at = Date.current + 15.days
end

puts "Seed data created successfully!"
puts "Login credentials (all passwords: password123):"
puts "  Admin:              admin@example.com"
puts "  Director:           director@example.com"
puts "  Project Manager:    pm@example.com"
puts "  Production Manager: production@example.com"
puts "  Sales Manager:      sales@example.com"
puts "  Worker 1:           worker1@example.com"
puts "  Worker 2:           worker2@example.com"
