defmodule MeApp.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MeApp.Timeline` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        likes_count: 42,
        photo_urls: [],
        reposts_count: 42,
        username: "some username"
      })
      |> MeApp.Timeline.create_post()

    post
  end
end
