defmodule MeAppWeb.PostLive.FormComponent do
  use MeAppWeb, :live_component

  import MeAppWeb.PostLive.Index,
    only: [
      broadcast: 1
    ]

  import MeApp.Timeline

  import MeApp.MemCache,
    only: [
      get_post_params: 1,
      put_post_params: 2
    ]

  @impl true
  def mount(socket) do
    {
      :ok,
      allow_upload(socket, :photos,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 2,
        external: &presign_entry/2
      )
    }
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = change_post(post, get_post_params(post.id))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    post = socket.assigns.post

    put_post_params(post.id, post_params)

    changeset =
      post
      |> change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  defp save_post(socket, :edit, post_params) do
    post = socket.assigns.post

    socket
    |> put_photo_urls(post_params, post.photo_urls)
    |> then(fn params ->
      update_post(post, params, &save_to_storage(socket, &1))
    end)
    |> case do
      {:ok, post} ->
        broadcast({:updated, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    socket
    |> put_photo_urls(post_params)
    |> create_post(&save_to_storage(socket, &1))
    |> case do
      {:ok, post} ->
        broadcast({:new, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # Why are we saving the photo_urls before moving files to permanent storage?
  defp put_photo_urls(socket, params, photo_urls \\ []) do
    {completed, []} = uploaded_entries(socket, :photos)

    urls =
      for entry <- completed do
        # Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}")
        Path.join(s3_host(), filename(entry))
      end

    Map.put(params, "photo_urls", urls ++ photo_urls)
  end

  # move file binaries to disk/s3
  defp save_to_storage(socket, post) do
    consume_uploaded_entries(socket, :photos, fn _meta, _entry ->
      # filename = filename(entry)
      # dest = Path.join("priv/static/uploads", filename)
      # File.cp!(meta.path, dest)
      # {:ok, Routes.static_path(socket, "/uploads/#{filename}")}
      {:ok, ""}
    end)

    {:ok, post}
  end

  defp filename(entry), do: "#{entry.uuid}.#{ext(entry)}"

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp bucket(), do: System.fetch_env!("BUCKET_NAME")
  defp s3_host(), do: "//#{bucket()}.s3.amazonaws.com"

  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads
    key = filename(entry)

    config = %{
      scheme: "http://",
      host: "s3.amazonaws.com",
      region: "us-east-1",
      access_key_id: System.fetch_env!("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.fetch_env!("AWS_SECRET_ACCESS_KEY")
    }

    {:ok, fields} =
      SimpleS3Upload.sign_form_upload(
        config,
        bucket(),
        key: key,
        content_type: entry.client_type,
        max_file_size: uploads.photos.max_file_size,
        expires_in: :timer.hours(1)
      )

    meta = %{uploader: "S3", key: key, url: s3_host(), fields: fields}
    {:ok, meta, socket}
  end
end
