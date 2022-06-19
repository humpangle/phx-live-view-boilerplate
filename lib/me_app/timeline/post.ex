defmodule MeApp.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :username, :string, default: "Amy James"
    field :body, :string
    field :likes_count, :integer, default: 0
    field :reposts_count, :integer, default: 0
    field :photo_urls, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :username,
      :body,
      :likes_count,
      :reposts_count,
      :photo_urls
    ])
    |> validate_required([:body])
    |> validate_length(:body, min: 2, max: 20_000)
  end
end
