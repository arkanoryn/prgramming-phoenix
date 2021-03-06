defmodule Rumbl.VideoChannel do
  use Rumbl.Web, :channel

  def join("videos:" <> video_id, _params, socket) do
    {:ok, assign(socket, :video_id, String.to_integer(video_id))}
  end

  def handle_in(event, params, socket) do
    user = Repo.get(Rumbl.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in(event, params, user, socket) do
    changeset = user
                |> build_assoc(:annotations, video_id: socket.assigns.video_id)
                |> Rumbl.Annotation.changeset(params)

    case Repo.insert(changeset) do
      {:ok, annotation} ->
      broadcast! socket, "new annotation", %{
        id: annotation.id,
        user: Rumbl.UserView.render("user.json", %{user: user}),
        body: annotation.body,
        at: annotation.at
      } {:reply, :ok, socket}

       {:error, changeset} -> {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
