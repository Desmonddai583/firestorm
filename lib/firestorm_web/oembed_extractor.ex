defmodule FirestormWeb.OembedExtractor do
  # We're going to match all of the URLs.
  @url_regex ~r(https?://[^ $\n]*)

  def get_embeds(body) do
    # For every URL, we'll spin out a new task that will ultimately return a
    # 2-tuple containing the url in question and the oembed result for it.
    body
    |> get_urls_from_string()
    |> Task.async_stream(fn url -> {url, FirestormWeb.OEmbed.for(url)} end)
    # If OEmbed.for failed for the url, we'll just filter it out.
    |> Enum.filter(&successful_oembed?/1)
    # Then we have this awkward pattern match that turns the result into what we
    # want to return.
    |> Enum.map(fn {:ok, {url, {:ok, a}}} -> {url, a} end)
  end

  # We add a basic function to filter out failed embeds
  defp successful_oembed?({:ok, {_url, {:ok, _data}}}), do: true
  defp successful_oembed?(_x) do
    false
  end

  @doc """
  Gathers anything in the string that looks like a link into a list of links.
  """
  def get_urls_from_string(string) do
    Regex.scan(@url_regex, string)
    |> Enum.map(&hd/1)
  end
end