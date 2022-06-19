defmodule MeApp.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :username, :string, null: false
      add :body, :text, null: false
      add :likes_count, :integer, default: 0
      add :reposts_count, :integer, default: 0
      add :photo_urls, {:array, :string}, default: []

      timestamps()
    end
  end
end
