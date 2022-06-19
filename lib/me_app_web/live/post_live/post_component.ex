defmodule MeAppWeb.PostLive.PostComponent do
  use MeAppWeb, :live_component

  import MeAppWeb.PostLive.Index,
    only: [
      broadcast: 1
    ]

  import MeApp.Timeline,
    only: [
      inc_likes_count: 1,
      inc_reposts_count: 1
    ]

  @impl true
  def handle_event("inc-likes-count", _, socket) do
    {:ok, post} = inc_likes_count(socket.assigns.post.id)
    broadcast({:updated, post})

    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("inc-reposts-count", _, socket) do
    {:ok, post} = inc_reposts_count(socket.assigns.post.id)
    broadcast({:new, post})

    {:noreply, assign(socket, :post, post)}
  end

  def post_class(post) do
    hidden = if post.__meta__.state == :deleted, do: "hidden", else: ""

    "border-2 p-2 #{hidden}"
  end
end
