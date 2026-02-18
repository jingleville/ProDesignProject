import { Controller } from "@hotwired/stimulus"
import Gantt from "frappe-gantt"

export default class extends Controller {
  static values = {
    tasks: Array
  }

  connect() {
    if (this.tasksValue.length === 0) return

    const tasks = this.tasksValue.map(task => ({
      id: task.id.toString(),
      name: task.name,
      start: task.start,
      end: task.end,
      progress: task.progress,
      dependencies: task.dependencies || ""
    }))

    this.gantt = new Gantt(this.element, tasks, {
      view_mode: "Day",
      language: "en",
      readonly: true
    })
  }

  disconnect() {
    if (this.gantt) {
      this.element.innerHTML = ""
    }
  }
}
