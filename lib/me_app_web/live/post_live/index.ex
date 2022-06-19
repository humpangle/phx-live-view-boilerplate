defmodule MeAppWeb.PostLive.Index do
  use MeAppWeb, :live_view

  import MeApp.Timeline,
    only: [
      list_posts: 0,
      delete_post: 1,
      get_post!: 1
    ]

  import MeApp.MemCache,
    only: [
      del_post_params: 1
    ]

  alias MeApp.Timeline.Post

  @posts_topic "posts"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket),
      do:
        Phoenix.PubSub.subscribe(
          MeApp.PubSub,
          @posts_topic
        )

    {:ok, assign(socket, :posts, list_posts()),
     temporary_assigns: [
       posts: []
     ]}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = get_post!(id)
    {:ok, post} = delete_post(post)
    broadcast({:deleted, post})

    {:noreply, assign(socket, :posts, list_posts())}
  end

  def handle_event("show-new", _, socket) do
    del_post_params(nil)

    {:noreply,
     push_patch(
       socket,
       to: Routes.post_index_path(socket, :new)
     )}
  end

  def handle_event("show-edit", %{"id" => id}, socket) do
    del_post_params(id)

    {:noreply,
     push_patch(
       socket,
       to: Routes.post_index_path(socket, :edit, id)
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({_tag, post}, socket) do
    {:noreply, update(socket, :posts, &[post | &1])}
  end

  def broadcast({_tag, _payload} = msg),
    do:
      Phoenix.PubSub.broadcast(
        MeApp.PubSub,
        @posts_topic,
        msg
      )

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end
end
