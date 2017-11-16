defmodule Firestorm.Markdown.EmojiReplacer do
  @moduledoc """
  EmojiReplacer will run on a string and return the string with any emoji marks
  (i.e. :poop:) replaced with their emoji counterpart.
  """

  # A RegEx to match any emoji mark
  @emoji_regex ~r{:([a-z]+):}

  # We'll use Regex.replace to replace any marks with their corresponding
  # unicode, if one exists with the provided short_name.
  def run(body) do
    @emoji_regex
    |> Regex.replace(body, &emojify_short_name/2)
  end

  # If the second argument to Regex.replace is a function, it should have arity
  # N, where N is "number of captures plus one", since the whole match is
  # provided as the first argument.
  #
  # In our case, that means we need an arity-2 function, to receive both the
  # whole matched string as well as the inner match, which is our short_name
  def emojify_short_name(whole_match, short_name) do
    # We'll check to see if an emoji exists with the provided short name.
    case Exmoji.from_short_name(short_name) do
      # If it doesn't, we'll change nothing
      nil -> whole_match
      # If it does, we'll replace the whole match with the unicode character for
      # the matched emoji
      emoji -> Exmoji.EmojiChar.render(emoji)
    end
  end
end