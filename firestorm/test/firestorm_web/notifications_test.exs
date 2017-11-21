defmodule FirestormWeb.NotificationsTest do
  use Firestorm.DataCase
  alias Firestorm.Forums
  use Bamboo.Test, shared: :true

  setup do
    {:ok, _} = FirestormWeb.Notifications.start_link()

    :ok
  end

  test "creating a post in a thread notifies everyone watching the thread" do
    {:ok, user} = Forums.create_user(%{username: "knewter", email: "josh@dailydrip.com", name: "Josh Adams"})
    # Create a new user
    {:ok, bob} = Forums.create_user(%{username: "bob", email: "bob@bob.com", name: "Bob Vladbob"})
    {:ok, elixir} = Forums.create_category(%{title: "Elixir"})
    # Have bob create the thread - he would have received a notification since
    # he posted in the thread under the old logic.
    {:ok, otp_is_cool} = Forums.create_thread(elixir, bob, %{title: "OTP is cool", body: "Don't you think?"})
    # Watch the thread from a user that hasn't posted in it.
    {:ok, _} = user |> Forums.watch(otp_is_cool)
    # Post in the thread as bob again
    {:ok, yup} = Forums.create_post(otp_is_cool, bob, %{body: "yup"})
    # The watching user receives an email
    assert_delivered_email FirestormWeb.Emails.thread_new_post_notification(user, otp_is_cool, yup)
    # The involved user doesn't since he's not watching
    refute_delivered_email FirestormWeb.Emails.thread_new_post_notification(bob, otp_is_cool, yup)
  end
end