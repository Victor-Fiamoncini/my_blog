import { Controller } from "@hotwired/stimulus"
import EasyMDE from "easymde"

export default class extends Controller {
  connect() {
    this.editor = new EasyMDE({
      element: this.element,
      autofocus: false,
      spellChecker: false,
      toolbar: ["bold", "italic", "heading", "|", "quote", "unordered-list", "ordered-list", "|", "link", "image", "|", "preview", "side-by-side", "fullscreen", "|", "guide"],
      renderingConfig: { singleLineBreaks: false },
      status: false,
      minHeight: "600px",
    });
  }

  disconnect() {
    if (this.editor) {
      this.editor.toTextArea();
      this.editor = null;
    }
  }
}
