defmodule SavitrBackendWeb.UserChannel do
  use SavitrBackendWeb, :channel
  require Logger

  @impl true
  def join("user:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("user:" <> user_id, _params, socket) do
    id = socket.assigns[:current_user].id

    Logger.info(
      "inside USER JOIN callback #{inspect(id == user_id)} #{inspect(socket.assigns[:current_user])}"
    )

    if id == String.to_integer(user_id) do
      Logger.info("user:#{inspect(user_id)} JOINED USER CHANNEL")
      {:ok, socket}
    else
      {:error, :unauthorized}
    end
  end

  def handle_in("update_position", %{"lat" => lat, "lng" => lng}, socket) do
    user = socket.assigns[:current_user]

    SavitrBackendWeb.Presence.update(socket, user.id, %{
      lat: lat,
      lng: lng
    })

    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (user:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
