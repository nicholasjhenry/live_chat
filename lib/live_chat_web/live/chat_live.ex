defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView
  # Under the hood, this is a GenServer
  # When state is changed, the view is automatically updated

  # To functions we need to implement:
  # - mount/2
  # - render/1
  import Ecto.Changeset
  alias LiveChatWeb.ChatView

  def mount(%{user: user}, socket) do
    assigns = [
      changeset: message_changeset(),
      messages: [],
      user: user
    ]

    # pass the state on the socket
    {:ok, assign(socket, assigns)}
  end

  # has to be called assigns
  def render(assigns) do
    ChatView.render("chat.html", assigns)
  end

  def handle_event("send", %{"chat" => attrs}, socket) do
    attrs
    |> message_changeset
    |> case do
      %{valid?: true, changes: %{message: message}} ->
        chat_line = {socket.assigns.user, message}

        assigns = [
          messages: socket.assigns.messages ++ [chat_line],
          changeset: message_changeset()
        ]

        {:noreply, assign(socket, assigns)}

      %{valid?: false} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @types %{message: :string}

  defp message_changeset(attrs \\ %{}) do
    cast({%{}, @types}, attrs, [:message])
    |> validate_required([:message])
    |> update_change(:message, &String.trim/1)
    |> validate_required([:message])
  end
end
