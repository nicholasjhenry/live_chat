defmodule LiveChatWeb.ChatLive do
  use Phoenix.LiveView
  # Under the hood, this is a GenServer

  # To functions we need to implement:
  # - mount/2
  # - render/1

  def mount(_params, socket) do
    send(self(), :count)

    # pass the state on the socket
    {:ok, assign(socket, :count, 0)}
  end

  # has to be called assigns
  def render(assigns) do
    ~L"""
    Count: <%= @count %>
    """
  end

  # handle the :count message
  def handle_info(:count, socket) do
    Process.send_after(self(), :count, 1_000)

    count = socket.assigns.count + 1

    {:noreply, assign(socket, :count, count)}
  end
end
