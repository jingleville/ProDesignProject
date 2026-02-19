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

    const minDate = new Date(Math.min(...tasks.map(t => new Date(t.start))))
    const maxDate = new Date(Math.max(...tasks.map(t => new Date(t.end))))
    const spanDays = (maxDate - minDate) / 86400000

    const viewMode = spanDays <= 30 ? "Day" : spanDays <= 90 ? "Week" : "Month"

    this.gantt = new Gantt(this.element, tasks, {
      view_mode: viewMode,
      language: "en",
      readonly: true
    })

    this._scrollToStart(minDate, viewMode)
  }

  _scrollToStart(minDate, viewMode) {
    // Use setTimeout to ensure browser has finished layout after frappe-gantt renders
    setTimeout(() => {
      const paddingDays = viewMode === "Day" ? 3 : viewMode === "Week" ? 7 : 14
      const target = new Date(minDate)
      target.setDate(target.getDate() - paddingDays)

      // Determine gantt chart start from internal property or fall back to SVG structure
      let ganttStart = null
      if (this.gantt && this.gantt.gantt_start) {
        ganttStart = new Date(this.gantt.gantt_start)
      } else {
        // Fallback: use first task start minus one month buffer
        const earliest = new Date(minDate)
        earliest.setMonth(earliest.getMonth() - 1)
        ganttStart = earliest
      }

      const msPerDay = 86400000
      const daysDiff = (target - ganttStart) / msPerDay
      const pxPerDay = viewMode === "Day" ? 38 : viewMode === "Week" ? 20 : 4

      // Find the scrollable container (the element with overflow-x-auto)
      const scrollEl = this.element.closest("[class*='overflow']") || this.element
      scrollEl.scrollLeft = Math.max(0, daysDiff * pxPerDay)
    }, 50)
  }

  disconnect() {
    if (this.gantt) {
      this.element.innerHTML = ""
    }
  }
}
