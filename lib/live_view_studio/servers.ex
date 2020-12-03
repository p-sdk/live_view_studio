defmodule LiveViewStudio.Servers do
  @moduledoc """
  The Servers context.
  """

  import Ecto.Query, warn: false
  alias LiveViewStudio.Repo

  alias LiveViewStudio.Servers.Server

  @topic inspect(__MODULE__)

  def subscribe() do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, @topic)
  end

  @doc """
  Returns the list of servers.

  ## Examples

      iex> list_servers()
      [%Server{}, ...]

  """
  def list_servers do
    Repo.all(from s in Server, order_by: [desc: s.id])
  end

  @doc """
  Gets a single server.

  Raises `Ecto.NoResultsError` if the Server does not exist.

  ## Examples

      iex> get_server!(123)
      %Server{}

      iex> get_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server!(id), do: Repo.get!(Server, id)

  def get_server_by_name(name), do: Repo.get_by(Server, name: name)

  @doc """
  Creates a server.

  ## Examples

      iex> create_server(%{field: value})
      {:ok, %Server{}}

      iex> create_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server(attrs \\ %{}) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:server_created)
  end

  @doc """
  Updates a server.

  ## Examples

      iex> update_server(server, %{field: new_value})
      {:ok, %Server{}}

      iex> update_server(server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
    |> broadcast(:server_updated)
  end

  @doc """
  Deletes a server.

  ## Examples

      iex> delete_server(server)
      {:ok, %Server{}}

      iex> delete_server(server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server(%Server{} = server) do
    Repo.delete(server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server changes.

  ## Examples

      iex> change_server(server)
      %Ecto.Changeset{data: %Server{}}

  """
  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end

  def toggle_status_server(%Server{} = server) do
    update_server(server, %{status: toggle_status(server.status)})
  end

  defp toggle_status("up"), do: "down"
  defp toggle_status("down"), do: "up"

  def broadcast({:ok, server}, event) do
    Phoenix.PubSub.broadcast(LiveViewStudio.PubSub, @topic, {event, server})
    {:ok, server}
  end

  def broadcast({:error, _reason} = error, _event), do: error
end
