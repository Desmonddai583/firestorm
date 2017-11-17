defmodule FirestormWeb.Router do
  use FirestormWeb, :router

  pipeline :browser do
    plug Ueberauth
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug FirestormWeb.Plugs.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FirestormWeb do
    pipe_through :browser # Use the default browser stack

    get "/", CategoryController, :index
    resources "/users", UserController
    resources "/categories", CategoryController do
      get "/threads/:id/watch", ThreadController, :watch
      get "/threads/:id/unwatch", ThreadController, :unwatch
      
      resources "/threads", ThreadController do
        resources "/posts", PostController, only: [:new, :create]
      end
    end
  end

  scope "/auth", FirestormWeb do
    pipe_through :browser

    delete "/logout", AuthController, :delete
    get "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/api/v1", FirestormWeb.Api.V1 do
    pipe_through :api

    resources "/preview", PreviewController, only: [:create]
    resources "/upload_signature", UploadSignatureController, only: [:create]
  end

  scope "/inbound", FirestormWeb do
    pipe_through :api

    post "/sendgrid", InboundController, :sendgrid
  end
end
