defmodule SavitrBackend.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias SavitrBackend.User

  schema "users" do
    field :phone, :string
    field :type, :string

    timestamps()
  end

  @doc """
  Create if user does not exist, else get user by phone and type
  """
  def get_or_create(phone, type) do
    case SavitrBackend.Repo.get_by(User, phone: phone, type: type) do
      nil ->
        %User{phone: phone, type: type}
        |> SavitrBackend.Repo.insert()

      user ->
        {:ok, user}
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:type, :phone])
    |> validate_required([:type, :phone])
  end
end
