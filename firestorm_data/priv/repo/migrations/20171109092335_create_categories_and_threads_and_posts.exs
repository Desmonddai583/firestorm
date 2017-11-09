defmodule FirestormData.Repo.Migrations.CreateCategoriesAndThreadsAndPosts do
  use Ecto.Migration

  def change do
  	# categories just have a title for now
    create table(:categories) do
      add :title, :string

      timestamps()
    end

    # threads belong to a category and have a title
    create table(:threads) do
      add :category_id, references(:categories)
      add :title, :string

      timestamps()
    end
    # We also add an index so we can find threads for a given category trivially
    create index(:threads, [:category_id])

    # posts belong to a thread and a user, and have a body
    create table(:posts) do
      add :thread_id, references(:threads)
      add :body, :text
      add :user_id, references(:users)

      timestamps()
    end
    # And we want to index posts by thread and user
    create index(:posts, [:thread_id])
    create index(:posts, [:user_id])
  end
end
