defmodule Firestorm.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :text
      add :thread_id, references(:threads, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:posts, [:thread_id])
    create index(:posts, [:user_id])
  end
end
