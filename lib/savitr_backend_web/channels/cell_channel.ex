defmodule SavitrBackendWeb.CellChannel do
  use SavitrBackendWeb, :channel
  require Logger

  intercept ["ride:requested"]

  @impl true
  def join("cell:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("cell" <> geohash, %{"position" => position}, socket) do
    Logger.info("cell:#{inspect(geohash)} JOINED CELL CHANNEL")
    send(self(), {:after_join, position})
    {:ok, %{}, socket}
  end

  def handle_info({:after_join, position}, socket) do
    user = socket.assigns[:current_user]

    if user.type == "driver" do
      SavitrBackendWeb.Presence.track(socket, user.id, %{
        lat: position["lat"],
        lng: position["lng"]
      })
    end

    push(socket, "presence_state", SavitrBackendWeb.Presence.list(socket))

    {:noreply, socket}
  end

  def handle_in("ride:request", %{"position" => position}, socket) do
    case SavitrBackend.RideRequest.create(socket.assigns[:current_user], position) do
      {:ok, request} ->
        Logger.info(request)
        broadcast!(socket, "ride:requested", %{
          request_id: request.id,
          position: position
        })

        {:reply, :ok, socket}

      {:error, _changeset} ->
        {:reply, {:error, :insert_error}, socket}
    end
  end

  def handle_in("ride:accept_request", %{"request_id" => request_id}, socket) do
    case SavitrBackend.Repo.get(SavitrBackend.RideRequest, request_id) do
      nil ->
        {:reply, :error, socket}

      request ->
        case SavitrBackend.Ride.create(
               request.rider_id,
               socket.assigns[:current_user].id,
               %{"lat" => request.lat, "lng" => request.lng}
             ) do
          {:ok, ride} ->
            Logger.info("created RIDE")
            # broadcast to rider and driver about the created ride
            SavitrBackendWeb.Endpoint.broadcast("user:#{ride.driver_id}", "ride:created", %{
              ride_id: ride.id
            })

            SavitrBackendWeb.Endpoint.broadcast("user:#{ride.rider_id}", "ride:created", %{
              ride_id: ride.id
            })

            {:reply, :ok, socket}

          {:error, _changeset} ->
            {:reply, :error, socket}
        end
    end
  end

  def handle_out("ride:requested", payload, socket) do
    if socket.assigns[:current_user].type == "driver" do
      Logger.info("RIDE REQUESTED>>>")
      push(socket, "ride:requested", payload)
    end

    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (cell:lobby).
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
