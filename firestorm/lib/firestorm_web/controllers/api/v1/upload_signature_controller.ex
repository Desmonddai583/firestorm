defmodule FirestormWeb.Api.V1.UploadSignatureController do
  use FirestormWeb, :controller

  # We'll accept an upload with a filename and mimetype, and sign it. If we sign
  # it successfully, we'll provide a capability to the frontend to upload this
  # file to our bucket.
  def create(conn, %{"upload" => %{"filename" => filename, "mimetype" => mimetype}}) do
    case Firestorm.Uploads.sign(filename, mimetype) do
      {:ok, signature} ->
        conn
        |> put_status(201)
        |> render("show.json", upload_signature: signature)

      {:error, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", errors: errors)
    end
  end
end