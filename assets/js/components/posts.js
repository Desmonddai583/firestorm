const $ = require("jquery");

import Prism from "prismjs";
import Api from "../api";
import "prismjs/themes/prism-solarizedlight.css";
import "prismjs/components/prism-elixir";
import "prismjs/components/prism-erlang";
import "prismjs/components/prism-haml";
import "prismjs/components/prism-css";
import "prismjs/components/prism-scss";
import "prismjs/plugins/autolinker/prism-autolinker";
import "prismjs/plugins/autolinker/prism-autolinker.css";
import "prismjs/plugins/line-numbers/prism-line-numbers";
import "prismjs/plugins/line-numbers/prism-line-numbers.css";
import "prismjs/plugins/normalize-whitespace/prism-normalize-whitespace";
import "prismjs/plugins/toolbar/prism-toolbar";
import "prismjs/plugins/toolbar/prism-toolbar.css";

function decorate() {
  Prism.highlightAll();
}

function preview() {
  // We'll use jQuery to fetch the elements we need to interact with
  const textareaSelector = ".post-editor textarea";
  const previewContentSelector = ".post-preview .content";
  const $textarea = $(textareaSelector);
  const $previewContent = $(previewContentSelector);

  // We'll define a function that gets the value out of the post body textarea,
  // posts it to our API, and updates the preview content with the response HTML
  const updatePreview = () => {
    const body = $textarea.val();
    Api.Preview.create(body).then(response => {
      $previewContent.html(response.jsonData.data.html);
    });
  };

  // Finally, we'll wire up the textarea to fire the function each time its
  // value changes.
  $textarea.on("keyup change", updatePreview);
}

const Posts = {
  decorate,
  preview
};

export default Posts;