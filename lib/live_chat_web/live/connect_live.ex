defmodule LiveChatWeb.ConnectLive do
  use Phoenix.LiveView
  import Ecto.Changeset
  # Hook up the LiveView channel to the view/template
  alias LiveChatWeb.ChatView

  # Initial state for the LiveView process
  def mount(_params, socket) do
    assigns = [
      changeset: join_changeset()
    ]

    {:ok, assign(socket, assigns)}
  end

  def render(%{name: _name} = assigns) do
    ~L"""
    <div class="fullscreen">
      Welcome, <%= @name %>!
    </div>
    """
  end

  def render(assigns) do
    ChatView.render("connect.html", assigns)
  end

  def handle_event("join", %{"user" => user}, socket) do
    user
    |> join_changeset()
    |> Map.put(:action, :errors)
    |> case do
      %{valid?: true, changes: %{name: name, email: email}} ->
        assigns = [
          name: name,
          email: email
        ]

        {:noreply, assign(socket, assigns)}

      %{valid?: false} = changeset ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @types %{
    name: :string,
    email: :string
  }

  defp join_changeset(attrs \\ %{}) do
    cast({%{}, @types}, attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/.+@.+/)
  end
end
