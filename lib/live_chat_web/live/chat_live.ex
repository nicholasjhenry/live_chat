defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView
  # Under the hood, this is a GenServer
  # When state is changed, the view is automatically updated

  # To functions we need to implement:
  # - mount/2
  # - render/1

  def mount(%{user: user}, socket) do
    assigns = [
      user: user
    ]

    # pass the state on the socket
    {:ok, assign(socket, assigns)}
  end

  # has to be called assigns
  def render(assigns) do
    ~L"""
    <div class="fullscreen">Welcome to chat, <%= @user.name %>!</div>
    """
  end

  # handle the :count message
  def handle_info(:count, socket) do
    Process.send_after(self(), :count, 1_000)

    count = socket.assigns.count + 1

    {:noreply, assign(socket, :count, count)}
  end
end
