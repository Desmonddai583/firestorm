defmodule Firestorm.Forums.Slugs.TitleSlug do
  # In order to facilitate `use`ing the module, we need to define a macro called
  # `__using__`. We accept a single argument, the module that we want to use for
  # the uniqueness check. We'll use this later.
  defmacro __using__(module) do
    # We'll `quote` because we want to just emit normal code
    quote do
      use EctoAutoslugField.Slug, from: :title, to: :slug
      alias Firestorm.Repo
      import Ecto.Query

      def build_slug(sources) do
        base_slug = super(sources)
        get_unused_slug(base_slug, 0)
      end

      def get_unused_slug(base_slug, number) do
        slug = get_slug(base_slug, number)
        if slug_used?(slug) do
          get_unused_slug(base_slug, number + 1)
        else
          slug
        end
      end

      def slug_used?(slug) do
        # We'll `unquote` the module name we captured when we `use`d this module
        unquote(module)
        |> where(slug: ^slug)
        |> Repo.one
      end

      def get_slug(base_slug, 0), do: base_slug
      def get_slug(base_slug, number) do
        "#{base_slug}-#{number}"
      end
    end
  end
end