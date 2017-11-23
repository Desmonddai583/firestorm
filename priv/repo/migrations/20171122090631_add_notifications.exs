defmodule Firestorm.Repo.Migrations.AddNotifications do
  use Ecto.Migration

  def change do
  	create table(:notifications) do
      add :body, :text
      add :user_id, references(:users)
      timestamps()
    end
  end
end
