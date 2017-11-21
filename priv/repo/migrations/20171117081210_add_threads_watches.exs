defmodule Firestorm.Repo.Migrations.AddThreadsWatches do
  use Ecto.Migration

  def change do
  	create table(:threads_watches) do
      add :assoc_id, references(:threads)
      add :user_id, references(:users)
      timestamps()
    end
  end
end
