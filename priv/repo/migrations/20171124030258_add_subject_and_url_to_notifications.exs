defmodule Firestorm.Repo.Migrations.AddSubjectAndUrlToNotifications do
  use Ecto.Migration

  def change do
  	alter table(:notifications) do
      add :subject, :string
      add :url, :string
    end
  end
end
