defmodule Firestorm.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :title, :string
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:threads, [:category_id])
  end
end
