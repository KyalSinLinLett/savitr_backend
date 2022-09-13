defmodule SavitrBackendWeb.CellChannelTest do
  use SavitrBackendWeb.ChannelCase, async: true
  alias SavitrBackend.User
  alias SavitrBackendWeb.{UserSocket, CellChannel}

  setup do
    {:ok, rider} = User.get_or_create("+92345235", "rider")

    {:ok, _, rider_socket} =
      UserSocket
      |> socket(rider.id, %{current_user: rider})
      |> subscribe_and_join(CellChannel, "cell:xyz", %{"position" => %{"lat" => 51.36577, "lng" => 0.6476747}})

    {:ok, driver} = User.get_or_create("+92345223435", "driver")

    {:ok, _, driver_socket} =
      UserSocket
      |> socket(driver.id, %{current_user: driver})
      |> subscribe_and_join(CellChannel, "cell:xyz", %{"position" => %{"lat" => 51.36577, "lng" => 0.6476747}})

    %{rider_socket: rider_socket, driver_socket: driver_socket, rider: rider, driver: driver}
  end

  test "accepts ride requests and create ride", %{
    driver_socket: driver_socket,
    rider: rider,
    driver: driver
  } do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = SavitrBackend.RideRequest.create(rider, position)

    ref = push(driver_socket, "ride:accept_request", %{request_id: request.id})
    assert_reply ref, :ok, %{}

    assert [ride] = SavitrBackend.Ride |> SavitrBackend.Repo.all()
    assert ride.driver_id == driver.id
    assert ride.rider_id == rider.id
  end

  test "fail to accept non existing ride request", %{
    driver_socket: driver_socket
  } do
    ref = push(driver_socket, "ride:accept_request", %{request_id: 123})
    assert_reply ref, :error, %{}
    assert [] = SavitrBackend.Ride |> SavitrBackend.Repo.all()
  end

  test "creates ride request", %{rider_socket: rider_socket} do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "ride:request", %{position: position})
    assert_reply ref, :ok, %{}

    [request] = SavitrBackend.RideRequest |> SavitrBackend.Repo.all()

    assert request.lat == position["lat"]
    assert request.lng == position["lng"]
  end

  test "broadcast ride request message", %{rider_socket: rider_socket} do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "ride:request", %{position: position})
    assert_reply ref, :ok, %{}

    [%{id: request_id}] = SavitrBackend.RideRequest |> SavitrBackend.Repo.all()

    assert_broadcast("ride:requested", %{request_id: request_id, position: position})
  end

  test "broadcast ride:created to both users", %{
    driver_socket: driver_socket,
    rider: rider,
    driver: driver
  } do
    Phoenix.PubSub.subscribe(SavitrBackend.PubSub, "user:#{rider.id}")
    Phoenix.PubSub.subscribe(SavitrBackend.PubSub, "user:#{driver.id}")

    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = SavitrBackend.RideRequest.create(rider, position)

    ref = push(driver_socket, "ride:accept_request", %{request_id: request.id})
    assert_reply ref, :ok, %{}

    [%{id: ride_id}] = SavitrBackend.Ride |> SavitrBackend.Repo.all()

    assert_receive %Phoenix.Socket.Broadcast{
      event: "ride:created",
      payload: %{ride_id: ride_id}
    }

    assert_receive %Phoenix.Socket.Broadcast{
      event: "ride:created",
      payload: %{ride_id: ride_id}
    }
  end

  # test "ping replies with status ok", %{socket: socket} do
  #   ref = push(socket, "ping", %{"hello" => "there"})
  #   assert_reply ref, :ok, %{"hello" => "there"}
  # end

  # test "shout broadcasts to cell:lobby", %{socket: socket} do
  #   push(socket, "shout", %{"hello" => "all"})
  #   assert_broadcast "shout", %{"hello" => "all"}
  # end

  # test "broadcasts are pushed to the client", %{socket: socket} do
  #   broadcast_from!(socket, "broadcast", %{"some" => "data"})
  #   assert_push "broadcast", %{"some" => "data"}
  # end
end
