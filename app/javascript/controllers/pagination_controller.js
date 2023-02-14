import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static values = {
    url: String,
    classification: String,
    page: Number,
  };

  //sleep(ms) {
  //  return new Promise(res => setTimeout(res,ms))
  //}
  //await this.sleep(1000);
  //console.log("done");
  //this.fetching = false;

  initialize() {
    this.scroll = this.scroll.bind(this);
    this.pageValue = this.pageValue || 1;
    this.fetching = false;
  }

  connect() {
    document.addEventListener("turbo:frame-load", () => {
      console.log("turbo:frame-load");
    });
  }

  scroll() {
    if (this.scrollReachedEnd && !this.fetching) {
      this.fetching = true;
      this._fetchNewPage()
    }
  }

  async _fetchNewPage() {
    const url = new URL(this.urlValue, location.origin);
    if (this.classificationValue) {
      url.searchParams.set('classification', this.classificationValue);
    }
    url.searchParams.set('page', this.pageValue);
    
    await get(url.toString(), {
      responseKind: 'turbo-stream'
    });

    this.pageValue += 1;
    this.fetching = false;
  }
 
  get scrollReachedEnd() {
    const { scrollHeight, scrollTop, clientHeight } = document.documentElement;
    const distanceFromBottom = scrollHeight - scrollTop - clientHeight;
    return distanceFromBottom < 300;
  }
}
