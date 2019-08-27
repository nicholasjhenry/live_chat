defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView
  # Under the hood, this is a GenServer
  # When state is changed, the view is automatically updated

  # To functions we need to implement:
  # - mount/2
  # - render/1
  import Ecto.Changeset
  alias LiveChatWeb.ChatView
  alias LiveChat.PubSub
  alias LiveChat.ChatServer, as: Chat
  alias LiveChat.Presence

  # called twice, 1. mounted, 2. connected
  def mount(%{user: user}, socket) do
    # No point in subscribing if not connnected
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PubSub, "lobby")

      {:ok, _} =
        Presence.track(self(), "lobby:presence", user.name, %{
          name: user.name,
          email: user.email,
          joined_at: :os.system_time(:seconds)
        })
    end

    assigns = [
      changeset: message_changeset(),
      messages: Chat.get_messages(),
      user: user,
      sidebar_open?: false
    ]

    # pass the state on the socket
    {:ok, assign(socket, assigns)}
  end

  # has to be called assigns
  def render(assigns) do
    ChatView.render("chat.html", assigns)
  end

  def handle_info({:messages, messages}, socket) do
    {:noreply, assign(socket, :messages, messages)}
  end

  def handle_event("show_online", _attrs, socket) do
    {:noreply, assign(socket, :sidebar_open?, !socket.assigns.sidebar_open?)}
  end

  def handle_event("send", %{"chat" => attrs}, socket) do
    attrs
    |> message_changeset
    |> case do
      %{valid?: true, changes: %{message: message}} ->
        Chat.new_message(socket.assigns.user, message)

        assigns = [
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
