import { Controller } from "@hotwired/stimulus"

const STATUS_COLORS = {
  draft: "#9ca3af",
  awaiting_production_approval: "#f59e0b",
  approved: "#6366f1",
  in_progress: "#3b82f6",
  active: "#3b82f6",
  completed: "#22c55e",
  rejected: "#ef4444",
  archived: "#6b7280"
}

const ROW_HEIGHT = 40
const PLANNED_BAR_HEIGHT = 28
const ACTUAL_BAR_HEIGHT = 16
const HEADER_HEIGHT_DAY = 44
const HEADER_HEIGHT_OTHER = 24
const PADDING_PX = 8

export default class extends Controller {
  static values = {
    items: Array,
    mode: { type: String, default: "week" }
  }
  static targets = ["nameColumn", "svgScroll", "dayBtn", "weekBtn", "monthBtn"]

  connect() {
    this._turboHandler = () => {
      if (this.hasSvgScrollTarget) this.svgScrollTarget.innerHTML = ""
    }
    document.addEventListener("turbo:before-cache", this._turboHandler)

    if (this.itemsValue.length === 0) return

    // Auto-select mode based on date span
    const { minDate, maxDate } = this._computeDateRange()
    const spanDays = (maxDate - minDate) / 86400000
    if (spanDays <= 45) {
      this.modeValue = "day"
    } else if (spanDays <= 180) {
      this.modeValue = "week"
    } else {
      this.modeValue = "month"
    }
    // modeValueChanged will call _render
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this._turboHandler)
  }

  switchMode(event) {
    this.modeValue = event.currentTarget.dataset.gantt2ModeParam
  }

  modeValueChanged() {
    if (this.itemsValue.length === 0) return
    this._updateModeButtons()
    this._render()
  }

  // ─── Date helpers ──────────────────────────────────────────────────────────

  _parseDate(str) {
    if (!str) return null
    const [y, m, d] = str.split("-").map(Number)
    return new Date(y, m - 1, d)
  }

  _dateToStr(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }

  _addDays(date, n) {
    const d = new Date(date)
    d.setDate(d.getDate() + n)
    return d
  }

  // ─── Core pipeline ─────────────────────────────────────────────────────────

  _computeDateRange() {
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    let minDate = today
    let maxDate = today

    for (const item of this.itemsValue) {
      for (const field of ["planned_start", "planned_end", "actual_start", "actual_end"]) {
        const d = this._parseDate(item[field])
        if (!d) continue
        if (d < minDate) minDate = d
        if (d > maxDate) maxDate = d
      }
    }

    // Add padding
    const mode = this.modeValue
    const padDays = mode === "day" ? 5 : mode === "week" ? 14 : 30
    minDate = this._addDays(minDate, -padDays)
    maxDate = this._addDays(maxDate, padDays)

    return { minDate, maxDate }
  }

  _computeLayout() {
    const mode = this.modeValue
    const pxPerDay = mode === "day" ? 40 : mode === "week" ? 20 : 6
    const headerHeight = mode === "day" ? HEADER_HEIGHT_DAY : HEADER_HEIGHT_OTHER
    const { minDate, maxDate } = this._computeDateRange()
    const totalDays = Math.ceil((maxDate - minDate) / 86400000)
    const svgWidth = totalDays * pxPerDay
    const svgHeight = headerHeight + this.itemsValue.length * ROW_HEIGHT

    return { pxPerDay, headerHeight, minDate, maxDate, totalDays, svgWidth, svgHeight }
  }

  _xForDate(date, minDate, pxPerDay) {
    const days = (date - minDate) / 86400000
    return days * pxPerDay
  }

  // ─── Render ────────────────────────────────────────────────────────────────

  _render() {
    const layout = this._computeLayout()
    this._renderNameColumn(layout)
    this._renderSVG(layout)
    requestAnimationFrame(() => this._scrollToToday(layout))
  }

  _renderNameColumn(layout) {
    if (!this.hasNameColumnTarget) return
    const { headerHeight } = layout

    let html = `<div style="height:${headerHeight}px; border-bottom:1px solid #e5e7eb; background:#f9fafb;"></div>`

    for (const item of this.itemsValue) {
      const name = this._escapeHtml(item.name)
      const url = item.url || "#"
      html += `
        <div style="height:${ROW_HEIGHT}px; display:flex; align-items:center; padding:0 8px;
                    border-bottom:1px solid #f3f4f6; overflow:hidden;">
          <a href="${url}" class="text-sm text-gray-800 hover:text-indigo-600 truncate"
             style="max-width:100%; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"
             title="${name}">
            ${name}
          </a>
        </div>`
    }

    this.nameColumnTarget.innerHTML = html
  }

  _renderSVG(layout) {
    if (!this.hasSvgScrollTarget) return
    const { pxPerDay, headerHeight, minDate, maxDate, totalDays, svgWidth, svgHeight } = layout
    const mode = this.modeValue
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const ns = "http://www.w3.org/2000/svg"
    const svg = document.createElementNS(ns, "svg")
    svg.setAttribute("width", svgWidth)
    svg.setAttribute("height", svgHeight)
    svg.setAttribute("xmlns", ns)

    // ── 1. Weekend shading (Day mode only) ──────────────────────────────────
    if (mode === "day") {
      for (let i = 0; i < totalDays; i++) {
        const d = this._addDays(minDate, i)
        const dow = d.getDay()
        if (dow === 0 || dow === 6) {
          const rect = document.createElementNS(ns, "rect")
          rect.setAttribute("x", i * pxPerDay)
          rect.setAttribute("y", 0)
          rect.setAttribute("width", pxPerDay)
          rect.setAttribute("height", svgHeight)
          rect.setAttribute("fill", "rgba(0,0,0,0.03)")
          svg.appendChild(rect)
        }
      }
    }

    // ── 2. Row stripes ───────────────────────────────────────────────────────
    for (let i = 0; i < this.itemsValue.length; i++) {
      const rect = document.createElementNS(ns, "rect")
      rect.setAttribute("x", 0)
      rect.setAttribute("y", headerHeight + i * ROW_HEIGHT)
      rect.setAttribute("width", svgWidth)
      rect.setAttribute("height", ROW_HEIGHT)
      rect.setAttribute("fill", i % 2 === 0 ? "#ffffff" : "#f9fafb")
      svg.appendChild(rect)
    }

    // ── 3. Grid lines & header ───────────────────────────────────────────────
    this._renderGridAndHeader(svg, layout, ns)

    // ── 4. Planned bars ──────────────────────────────────────────────────────
    for (let i = 0; i < this.itemsValue.length; i++) {
      const item = this.itemsValue[i]
      const ps = this._parseDate(item.planned_start)
      const pe = this._parseDate(item.planned_end)
      if (!ps || !pe) continue

      const x = this._xForDate(ps, minDate, pxPerDay)
      const w = Math.max(pxPerDay, this._xForDate(pe, minDate, pxPerDay) - x + pxPerDay)
      const y = headerHeight + i * ROW_HEIGHT + (ROW_HEIGHT - PLANNED_BAR_HEIGHT) / 2

      const rect = document.createElementNS(ns, "rect")
      rect.setAttribute("x", x)
      rect.setAttribute("y", y)
      rect.setAttribute("width", w)
      rect.setAttribute("height", PLANNED_BAR_HEIGHT)
      rect.setAttribute("rx", 4)
      rect.setAttribute("fill", "rgba(148,163,184,0.4)")
      svg.appendChild(rect)
    }

    // ── 5. Actual bars ───────────────────────────────────────────────────────
    for (let i = 0; i < this.itemsValue.length; i++) {
      const item = this.itemsValue[i]
      const as_ = this._parseDate(item.actual_start)
      const ae = this._parseDate(item.actual_end)
      if (!as_ || !ae) continue

      const x = this._xForDate(as_, minDate, pxPerDay)
      const w = Math.max(pxPerDay, this._xForDate(ae, minDate, pxPerDay) - x + pxPerDay)
      const y = headerHeight + i * ROW_HEIGHT + (ROW_HEIGHT - ACTUAL_BAR_HEIGHT) / 2

      const color = STATUS_COLORS[item.status] || STATUS_COLORS.draft
      const rect = document.createElementNS(ns, "rect")
      rect.setAttribute("x", x)
      rect.setAttribute("y", y)
      rect.setAttribute("width", w)
      rect.setAttribute("height", ACTUAL_BAR_HEIGHT)
      rect.setAttribute("rx", 3)
      rect.setAttribute("fill", color)
      svg.appendChild(rect)
    }

    // ── 6. Today marker ──────────────────────────────────────────────────────
    if (today >= minDate && today <= maxDate) {
      const x = this._xForDate(today, minDate, pxPerDay)
      const line = document.createElementNS(ns, "line")
      line.setAttribute("x1", x)
      line.setAttribute("y1", 0)
      line.setAttribute("x2", x)
      line.setAttribute("y2", svgHeight)
      line.setAttribute("stroke", "#ef4444")
      line.setAttribute("stroke-width", "1.5")
      line.setAttribute("stroke-dasharray", "4,3")
      svg.appendChild(line)
    }

    this.svgScrollTarget.innerHTML = ""
    this.svgScrollTarget.appendChild(svg)
  }

  _renderGridAndHeader(svg, layout, ns) {
    const { pxPerDay, headerHeight, minDate, maxDate, totalDays, svgWidth, svgHeight } = layout
    const mode = this.modeValue

    const MONTHS_RU = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн",
                       "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
    const DAYS_RU = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]

    // Header background
    const hdr = document.createElementNS(ns, "rect")
    hdr.setAttribute("x", 0)
    hdr.setAttribute("y", 0)
    hdr.setAttribute("width", svgWidth)
    hdr.setAttribute("height", headerHeight)
    hdr.setAttribute("fill", "#f9fafb")
    svg.appendChild(hdr)

    // Bottom border of header
    const hline = document.createElementNS(ns, "line")
    hline.setAttribute("x1", 0)
    hline.setAttribute("y1", headerHeight)
    hline.setAttribute("x2", svgWidth)
    hline.setAttribute("y2", headerHeight)
    hline.setAttribute("stroke", "#e5e7eb")
    hline.setAttribute("stroke-width", 1)
    svg.appendChild(hline)

    if (mode === "day") {
      // Two-row header: month row (top 20px) + day row (bottom 24px)
      const monthRowH = 20
      const dayRowH = 24

      // Month labels spanning
      let cur = new Date(minDate)
      while (cur <= maxDate) {
        const monthStart = new Date(cur.getFullYear(), cur.getMonth(), 1)
        const monthEnd = new Date(cur.getFullYear(), cur.getMonth() + 1, 0)

        const segStart = cur > monthStart ? cur : monthStart
        const segEnd = monthEnd < maxDate ? monthEnd : maxDate

        const x1 = this._xForDate(segStart, minDate, pxPerDay)
        const x2 = this._xForDate(this._addDays(segEnd, 1), minDate, pxPerDay)
        const label = `${MONTHS_RU[cur.getMonth()]} ${cur.getFullYear()}`

        const text = document.createElementNS(ns, "text")
        text.setAttribute("x", (x1 + x2) / 2)
        text.setAttribute("y", monthRowH / 2 + 5)
        text.setAttribute("text-anchor", "middle")
        text.setAttribute("font-size", "11")
        text.setAttribute("fill", "#6b7280")
        text.setAttribute("font-family", "system-ui, sans-serif")
        text.textContent = label
        svg.appendChild(text)

        // Advance to next month
        cur = new Date(cur.getFullYear(), cur.getMonth() + 1, 1)
      }

      // Day ticks and labels
      for (let i = 0; i < totalDays; i++) {
        const d = this._addDays(minDate, i)
        const x = i * pxPerDay

        // Vertical grid line
        const vline = document.createElementNS(ns, "line")
        vline.setAttribute("x1", x)
        vline.setAttribute("y1", monthRowH)
        vline.setAttribute("x2", x)
        vline.setAttribute("y2", svgHeight)
        vline.setAttribute("stroke", "#f3f4f6")
        vline.setAttribute("stroke-width", 1)
        svg.appendChild(vline)

        // Day number
        const dayText = document.createElementNS(ns, "text")
        dayText.setAttribute("x", x + pxPerDay / 2)
        dayText.setAttribute("y", monthRowH + 14)
        dayText.setAttribute("text-anchor", "middle")
        dayText.setAttribute("font-size", "10")
        dayText.setAttribute("fill", d.getDay() === 0 || d.getDay() === 6 ? "#d1d5db" : "#9ca3af")
        dayText.setAttribute("font-family", "system-ui, sans-serif")
        dayText.textContent = d.getDate()
        svg.appendChild(dayText)
      }

    } else if (mode === "week") {
      // One row: tick every 7 days, label "15 Янв"
      for (let i = 0; i < totalDays; i += 7) {
        const d = this._addDays(minDate, i)
        const x = i * pxPerDay

        const vline = document.createElementNS(ns, "line")
        vline.setAttribute("x1", x)
        vline.setAttribute("y1", 0)
        vline.setAttribute("x2", x)
        vline.setAttribute("y2", svgHeight)
        vline.setAttribute("stroke", "#f3f4f6")
        vline.setAttribute("stroke-width", 1)
        svg.appendChild(vline)

        const label = `${d.getDate()} ${MONTHS_RU[d.getMonth()]}`
        const text = document.createElementNS(ns, "text")
        text.setAttribute("x", x + PADDING_PX)
        text.setAttribute("y", headerHeight / 2 + 5)
        text.setAttribute("font-size", "11")
        text.setAttribute("fill", "#6b7280")
        text.setAttribute("font-family", "system-ui, sans-serif")
        text.textContent = label
        svg.appendChild(text)
      }

    } else {
      // Month mode: tick per month, label "Янв 2024"
      let cur = new Date(minDate.getFullYear(), minDate.getMonth(), 1)
      while (cur <= maxDate) {
        const x = this._xForDate(cur, minDate, pxPerDay)

        const vline = document.createElementNS(ns, "line")
        vline.setAttribute("x1", x)
        vline.setAttribute("y1", 0)
        vline.setAttribute("x2", x)
        vline.setAttribute("y2", svgHeight)
        vline.setAttribute("stroke", "#e5e7eb")
        vline.setAttribute("stroke-width", 1)
        svg.appendChild(vline)

        const label = `${MONTHS_RU[cur.getMonth()]} ${cur.getFullYear()}`
        const text = document.createElementNS(ns, "text")
        text.setAttribute("x", x + PADDING_PX)
        text.setAttribute("y", headerHeight / 2 + 5)
        text.setAttribute("font-size", "11")
        text.setAttribute("fill", "#6b7280")
        text.setAttribute("font-family", "system-ui, sans-serif")
        text.textContent = label
        svg.appendChild(text)

        cur = new Date(cur.getFullYear(), cur.getMonth() + 1, 1)
      }
    }
  }

  _scrollToToday(layout) {
    if (!this.hasSvgScrollTarget) return
    const { pxPerDay, minDate, svgWidth } = layout
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const todayX = this._xForDate(today, minDate, pxPerDay)
    const containerWidth = this.svgScrollTarget.clientWidth
    // Scroll so today appears at ~30% from left
    const scrollLeft = todayX - containerWidth * 0.3
    this.svgScrollTarget.scrollLeft = Math.max(0, scrollLeft)
  }

  _updateModeButtons() {
    const mode = this.modeValue
    const activeClass = ["bg-indigo-600", "text-white"]
    const inactiveClass = ["bg-white", "text-gray-700"]

    const btnMap = { day: "dayBtn", week: "weekBtn", month: "monthBtn" }
    for (const [m, target] of Object.entries(btnMap)) {
      const hasTarget = `has${target.charAt(0).toUpperCase() + target.slice(1)}Target`
      if (!this[hasTarget]) continue
      const btn = this[`${target}Target`]
      if (m === mode) {
        btn.classList.remove(...inactiveClass)
        btn.classList.add(...activeClass)
      } else {
        btn.classList.remove(...activeClass)
        btn.classList.add(...inactiveClass)
      }
    }
  }

  _escapeHtml(str) {
    return String(str)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
  }
}
