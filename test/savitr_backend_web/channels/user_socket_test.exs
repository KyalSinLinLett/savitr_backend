defmodule SavitrBackendWeb.UserSocketTest do
  use SavitrBackendWeb.ChannelCase, async: true
  alias SavitrBackendWeb.UserSocket
  alias SavitrBackend.{User, Guardian}

  test "fail to authenticate without token" do
    assert :error = connect(UserSocket, %{})
  end

  test "fail to authenticate with invalid token" do
    assert :error = connect(UserSocket, %{"token" => "abcdef"})
  end

  test "authenticate and assign user ID with valid token" do
    {:ok, user} = User.get_or_create("+9532234234", "rider")
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert socket.assigns.current_user.id == user.id
  end
end
