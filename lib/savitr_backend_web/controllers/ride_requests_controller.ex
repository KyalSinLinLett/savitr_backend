defmodule SavitrBackendWeb.RideRequestsController do
  use SavitrBackendWeb, :controller

  def create(
        conn,
        %{
          "geohash" => geohash,
          "position" => position
        } = params
      ) do
    rider = conn.assigns[:current_user]

    case SavitrBackend.RideRequest.create(rider, position) do
      {:ok, request} ->
        SavitrBackendWeb.Endpoint.broadcast("cell:#{geohash}", "ride:requested", %{
          request_id: request.id,
          position: position
        })

        conn |> json(%{"request" => request})

      {:error, reason} ->
        conn |> json(%{"error" => "Unable to request a ride"})
    end
  end
end
