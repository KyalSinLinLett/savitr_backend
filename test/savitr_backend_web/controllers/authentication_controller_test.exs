defmodule SavitrBackendWeb.AuthenticationControllerTest do
  use SavitrBackendWeb.ConnCase

  describe "POST /api/authenticate" do

    test "return OK with token", %{conn: conn} do
      body =
        conn
        |> post("/api/authenticate", %{
          "phone" => "+959847583929",
          "type" => "rider"
        })
        |> json_response(200)

      %{"id" => user_id, "token" => token, "type" => "rider"} = body

      assert {:ok, _} = SavitrBackend.Guardian.decode_and_verify(token, %{"sub" => user_id})
    end

    test "creates user", %{conn: conn} do
      body =
        conn
        |> post("/api/authenticate", %{
          "phone" => "+959847583922",
          "type" => "rider"
        })
        |> json_response(200)

      %{"id" => user_id} = body

      assert [%{id: new_user_id}] = SavitrBackend.User |> SavitrBackend.Repo.all()
      assert new_user_id == user_id
    end

    test "returns 400 with wrong user type", %{conn: conn} do
      conn
      |> post("/api/authenticate", %{
        "phone" => "+959847583921",
        "type" => "something"
      })
      |> json_response(400)
    end

  end
end
