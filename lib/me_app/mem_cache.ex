defmodule MeApp.MemCache do
  def put_a_post({:ok, post} = result) do
    Cachex.execute(:me_app, fn cache ->
      Cachex.del(cache, cache_key_list_posts())
      Cachex.put(cache, cache_key_one_post(post.id), post)
    end)

    result
  end

  def put_a_post(other), do: other

  def del_a_post({:ok, post} = result) do
    Cachex.execute(:me_app, fn cache ->
      Cachex.del(cache, cache_key_one_post(post.id))
      Cachex.del(cache, cache_key_list_posts())
    end)

    result
  end

  def del_a_post(other), do: other

  ## Use this to cache user input - in case of browser reload/lost connection
  def put_post_params(id, params) do
    Cachex.put(:me_app, cache_key_post_params(id), params)
    params
  end

  def get_post_params(id) do
    {_, val} = Cachex.get(:me_app, cache_key_post_params(id))
    val || %{}
  end

  def del_post_params(id) do
    Cachex.del(:me_app, cache_key_post_params(id))
  end

  def cache_key_list_posts(), do: "posts"

  def cache_key_one_post(id), do: "post:#{id}"

  def cache_key_post_params(id), do: "post-params:#{id}"
end
