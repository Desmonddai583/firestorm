defmodule FirestormWeb.Feature.ThreadsTest do
  use FirestormWeb.FeatureCase, async: true
  alias Firestorm.Forums

  @otp_is_cool_parameters %{title: "OTP is cool", body: "Don't you think?"}

  test "creating a new thread", %{session: session} do
    import Page.Thread.{New, Show}
    import Page.Category.Show, only: [new_thread_link: 0]
    {:ok, [elixir]} = create_categories(["Elixir"])
    {:ok, user} = Forums.create_user(%{username: "knewter", email: "josh@dailydrip.com", name: "Josh Adams"})

    session
    |> log_in_as(user)
    |> visit(category_path(FirestormWeb.Endpoint, :show, elixir))
    |> click(new_thread_link())
    |> fill_in(title_field(), with: @otp_is_cool_parameters[:title])
    |> fill_in(body_field(), with: @otp_is_cool_parameters[:body])
    |> click(create_thread_button())
    |> assert_has(thread_title(@otp_is_cool_parameters[:title]))
  end

  test "creating a new thread when unauthenticated", %{session: session} do
    import Page.Layout
    import Page.Category.Show
    {:ok, [elixir]} = create_categories(["Elixir"])

    session
    |> visit(category_path(FirestormWeb.Endpoint, :show, elixir))
    |> click(new_thread_link())
    |> assert_has(error("You must be logged in to access this page."))
  end

  test "replying to a thread", %{session: session} do
    import Page.Thread.Show
    import Page.Post.New

    {:ok, [elixir]} = create_categories(["Elixir"])
    {:ok, user} = Forums.create_user(%{username: "knewter", email: "josh@dailydrip.com", name: "Josh Adams"})
    {:ok, otp_is_cool} = Forums.create_thread(elixir, user, @otp_is_cool_parameters)

    session
    |> log_in_as(user)
    |> visit(category_thread_path(FirestormWeb.Endpoint, :show, elixir, otp_is_cool))
    |> assert_has(thread_title(@otp_is_cool_parameters[:title]))
    |> click(reply_link())
    |> fill_in(body_field(), with: "I agree!")
    |> click(reply_button())
    |> assert_has(thread_title(@otp_is_cool_parameters[:title]))
    |> assert_has(post_item("I agree!"))
    |> assert_has(post_username("knewter", 1))
      # There is only one that matches this because we put the first post's
      # user info into the thread header.
  end

  test "watching a thread", %{session: session} do
    import Page.Thread.Show

    {:ok, [elixir]} = create_categories(["Elixir"])
    {:ok, user} = Forums.create_user(%{username: "knewter", email: "josh@dailydrip.com", name: "Josh Adams"})
    {:ok, otp_is_cool} = Forums.create_thread(elixir, user, @otp_is_cool_parameters)

    session
    |> log_in_as(user)
    |> visit(category_thread_path(FirestormWeb.Endpoint, :show, elixir, otp_is_cool))
    |> refute_has(watched_icon())
    |> click(watch_link())
    |> assert_has(watched_icon())
    |> click(watch_link()) # <-- unwatch it now
    |> refute_has(watched_icon()) # <-- ensure it unwatches
  end

  # We'll move this to a factories helper at some point
  def create_categories(titles) do
    categories =
      for title <- titles do
        {:ok, category} = Forums.create_category(%{title: title})
        category
      end
    {:ok, categories}
  end

  test "thread posts have oembeds rendered", %{session: session} do
    import Page.Thread.Show

    url = "https://www.youtube.com/watch?v=H686MDn4Lo8"
    {:ok, [elixir]} = create_categories(["Elixir"])
    {:ok, user} = Forums.create_user(%{username: "knewter", email: "josh@dailydrip.com", name: "Josh Adams"})
    {:ok, otp_is_cool} = Forums.create_thread(elixir, user, %{title: "Thread with oEmbed in the first post", body: "This is a cool video, check it out: #{url}"})

    # Pre-populate the OEmbed cache to return an oembed for this URL:
    LruCache.put(:oembed_cache, url, %OEmbed.Video{html: "lolno"})

    session
    |> log_in_as(user)
    |> visit(category_thread_path(FirestormWeb.Endpoint, :show, elixir, otp_is_cool))
    |> assert_has(oembed_for("https://www.youtube.com/watch?v=H686MDn4Lo8"))
  end
end