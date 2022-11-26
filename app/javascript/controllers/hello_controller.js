import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("turbo:frame-load", () => {
      console.log("turbo:frame-load");
      twttr.widgets.load();
    });
  }
}
