import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "price", "total"]

  calculate() {
    const quantity = parseFloat(this.quantityTarget.value) || 0
    const price = parseFloat(this.priceTarget.value) || 0
    this.totalTarget.textContent = (quantity * price).toFixed(2)
  }
}
