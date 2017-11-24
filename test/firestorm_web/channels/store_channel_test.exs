defmodule FirestormWeb.StoreChannelTest do
  use FirestormWeb.ChannelCase
  alias FirestormWeb.StoreChannel
  alias FirestormWeb.Api.V1.FetchView
  alias Firestorm.Store.{ReplenishResponse, ReplenishRequest}
  alias Firestorm.Forums

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(StoreChannel, "store:fetch")

    {:ok, socket: socket}
  end

  # If someone sends in a ReplenishRequest that's not asking for anything, we'll
  # dutifully not send them anything.
  test "responds to an empty request", %{socket: socket} do
    request =
      empty_replenish_request()

    ref = push socket, "fetch", request
    assert_response ref, %ReplenishResponse{}
  end

  # If they ask for a category, we'll give it to them.
  test "responds with a category", %{socket: socket} do
    {:ok, elixir} = Forums.create_category(%{title: "Elixir"})

    request =
      empty_replenish_request()
      |> ReplenishRequest.request_category(elixir.id)

    ref = push socket, "fetch", request
    assert_response ref, %ReplenishResponse{categories: [elixir]}
  end

  # And so on for threads, posts, and users.
  test "responds with a thread", %{socket: socket} do
    {:ok, elixir} = Forums.create_category(%{title: "Elixir"})
    {:ok, bob} = Forums.create_user(%{email: "bob@example.com", name: "Bob Vladbob", username: "bob"})
    {:ok, otp_is_cool} = Forums.create_thread(elixir, bob, %{title: "OTP is cool", body: "Don't you think?"})

    request =
      empty_replenish_request()
      |> ReplenishRequest.request_thread(otp_is_cool.id)

    ref = push socket, "fetch", request
    assert_response ref, %ReplenishResponse{threads: [otp_is_cool]}
  end

  test "responds with a post", %{socket: socket} do
    {:ok, elixir} = Forums.create_category(%{title: "Elixir"})
    {:ok, bob} = Forums.create_user(%{email: "bob@example.com", name: "Bob Vladbob", username: "bob"})
    {:ok, otp_is_cool} = Forums.create_thread(elixir, bob, %{title: "OTP is cool", body: "Don't you think?"})
    {:ok, yup} = Forums.create_post(otp_is_cool, bob, %{body: "Yup"})

    request =
      empty_replenish_request()
      |> ReplenishRequest.request_post(yup.id)

    ref = push socket, "fetch", request
    assert_response ref, %ReplenishResponse{posts: [yup]}
  end

  test "responds with a user", %{socket: socket} do
    {:ok, bob} = Forums.create_user(%{email: "bob@example.com", name: "Bob Vladbob", username: "bob"})

    request =
      empty_replenish_request()
      |> ReplenishRequest.request_user(bob.id)

    ref = push socket, "fetch", request
    assert_response ref, %ReplenishResponse{users: [bob]}
  end

  def empty_replenish_request() do
    %ReplenishRequest{}
  end

  # And here's a little helper we wrote to reduce some boilerplate.
  def assert_response(ref, response) do
    expected = FetchView.render("index.json", response)
    assert_reply ref, :ok, ^expected
  end
end