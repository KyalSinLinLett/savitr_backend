defmodule SavitrBackendWeb.UserSocket do
  use Phoenix.Socket
  require Logger
  alias SavitrBackend.Guardian

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  # Uncomment the following line to define a "room:*" topic
  # pointing to the `SavitrBackendWeb.RoomChannel`:
  #
  # channel "room:*", SavitrBackendWeb.RoomChannel
  channel "cell:*", SavitrBackendWeb.CellChannel
  channel "user:*", SavitrBackendWeb.UserChannel
  #
  # To create a channel file, use the mix task:
  #
  #     mix phx.gen.channel Room
  #
  # See the [`Channels guide`](https://hexdocs.pm/phoenix/channels.html)
  # for further details.

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  def connect(%{"token" => token}, socket) do
    Logger.info("TOKEN RECEIVED::#{inspect(token)}")

    case Guardian.resource_from_token(token) do
      {:ok, user, _claims} ->
        Logger.info("AUTHENTICATION PASSED!")
        {:ok, assign(socket, :current_user, user)}

      _ ->
        Logger.info("AUTHENTICATION FAILED")
        :error
    end
  end

  def connect(_params, _socket), do: :error
  # @impl true
  # def connect(_params, socket, _connect_info) do
  #   {:ok, socket}
  # end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.SavitrBackendWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: socket.assigns[:current_user].id |> to_string()
end
