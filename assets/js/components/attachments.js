// We'll bring in jQuery and the API
const $ = require("jquery");
import Api from "../api";

// We'll construct some selectors to find elements we want to affect.
const fileSelector = ".add-attachment input[type=file]";
const textAreaSelector = ".post-editor textarea";

// When we upload to S3, we need to construct a form to submit to their
// endpoint.
const uploadToS3 = (el, file, response) => {
  const data = response.jsonData.data;

  const $el = $(el);
  const $parent = $el.parent();
  let fd = new FormData();
  fd.append("key", data.key);
  fd.append("AWSAccessKeyId", data.aws_access_key_id);
  fd.append("acl", data.acl);
  fd.append("success_action_status", data.success_action_status);
  fd.append("policy", data.policy);
  fd.append("signature", data.signature);
  fd.append("Content-Type", data.content_type);
  fd.append("file", file);
  return $.ajax({
    type: "POST",
    url: data.action,
    data: fd,
    dataType: "xml",
    processData: false, // tell jQuery not to convert to form data
    contentType: false // tell jQuery not to set contentType
  });
};

// Once we upload the file, we'll receive the URL for it on S3. We'd like to
// inject some markdown that will either show it, if it's an image, or link to
// it if it isn't.
const makeMarkdown = (filename, mimeType, location) => {
  let val;
  switch (mimeType) {
    case "image/png":
    case "image/jpeg":
    case "image/jpg":
    case "image/gif":
      val = `![${filename}](${location})`;
      break;
    default:
      val = `[${filename}](${location})`;
      break;
  }
  return val;
};

// We'll write a quick function to append our markdown to the textarea using the
// makeMarkdown function.
const appendToTextArea = (filename, mimeType, xml) => {
  const uriEncodedLocation = $(xml).find("PostResponse Location").text();
  const location = decodeURIComponent(uriEncodedLocation);
  const $textArea = $(textAreaSelector);
  const fileMarkdown = makeMarkdown(filename, mimeType, location);
  $textArea.val(`${$textArea.val()}\n\n${fileMarkdown}`);
  $textArea.change();
};

// Finally, we'll build our only public function, which mounts on the
// fileselector and injects our behaviour.
const mount = () => {
  $(fileSelector).on("change", function() {
    const file = this.files[0];

    // Get an upload signature from the backend
    Api.UploadSignature
      .create(file.name, file.type)
      // Then upload it to S3
      .then(response => uploadToS3(this, file, response))
      // Then append it to the textarea
      .then(xml => appendToTextArea(file.name, file.type, xml));
  });
};

const Attachments = {
  mount
};

export default Attachments;