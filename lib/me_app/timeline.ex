defmodule MeApp.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false

  import MeApp.MemCache,
    only: [
      cache_key_list_posts: 0,
      put_a_post: 1,
      del_a_post: 1,
      cache_key_one_post: 1
    ]

  alias MeApp.Repo
  alias MeApp.Timeline.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    {_, posts} =
      Cachex.fetch(:me_app, cache_key_list_posts(), fn ->
        posts =
          Repo.all(
            from p in Post,
              order_by: [desc: p.id]
          )

        {:commit, posts}
      end)

    posts
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Cachex.fetch(:me_app, cache_key_one_post(id), fn ->
      case Repo.get(Post, id) do
        nil ->
          {:ignore, nil}

        post ->
          {:commit, post}
      end
    end)
    |> case do
      {_, nil} ->
        raise Ecto.NoResultsError

      {_, post} ->
        post
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs, after_save \\ &{:ok, &1}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
    |> put_a_post()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs, after_save \\ &{:ok, &1}) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
    |> put_a_post()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
    |> del_a_post()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc ~S"""
  Increment likes count by 1

  ## Examples

        iex> inc_likes_count(id)
        {:ok, %Post{}}

  """
  def inc_likes_count(id) do
    {1, [post]} =
      from(
        p in Post,
        where: p.id == ^id,
        select: p
      )
      |> Repo.update_all(inc: [likes_count: 1])

    put_a_post({:ok, post})
  end

  @doc ~S"""
  Increment reposts count by 1

  ## Examples

        iex> inc_reposts_count(id)
        {:ok, %Post{}}

  """
  def inc_reposts_count(id) do
    {1, [post]} =
      from(
        p in Post,
        where: p.id == ^id,
        select: p
      )
      |> Repo.update_all(inc: [reposts_count: 1])

    put_a_post({:ok, post})
  end

  defp after_save({:ok, post}, after_save) do
    {:ok, _post} = after_save.(post)
  end

  defp after_save(other, _after_save_fn), do: other
end
