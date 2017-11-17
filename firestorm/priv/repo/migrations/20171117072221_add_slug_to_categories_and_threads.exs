defmodule Firestorm.Repo.Migrations.AddSlugToCategoriesAndThreads do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :slug, :string
    end
    alter table(:threads) do
      add :slug, :string
    end
    create unique_index(:categories, [:slug])
    create unique_index(:threads, [:slug])
  end
end
