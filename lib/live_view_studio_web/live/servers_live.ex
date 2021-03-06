defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    if connected?(socket), do: Servers.subscribe()

    servers = Servers.list_servers()

    socket = assign(socket, servers: servers)

    {:ok, socket}
  end

  def handle_params(%{"name" => name}, _url, socket) do
    server = Servers.get_server_by_name(name)

    socket =
      assign(socket,
        selected_server: server,
        page_title: "What's up #{server.name}?"
      )

    {:noreply, socket}
  end

  def handle_params(_, _url, socket) do
    if socket.assigns.live_action == :new do
      socket =
        assign(socket,
          selected_server: nil,
          changeset: Servers.change_server(%Server{})
        )
      {:noreply, socket}
    else
      socket = assign(socket, selected_server: hd(socket.assigns.servers))
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~L"""
    <h1>Servers</h1>
    <%= live_patch "Add Server",
          to: Routes.servers_path(@socket, :new),
          class: "w-48 text-center -mt-4 mb-2 block underline" %>
    <div id="servers">
      <div class="sidebar">
        <nav>
          <%= for server <- @servers do %>
            <div>
              <%= live_patch link_body(server),
                    to: Routes.live_path(
                              @socket,
                              __MODULE__,
                              name: server.name
                        ),
                    class: if server == @selected_server, do: "active" %>
            </div>

          <% end %>
        </nav>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <%= f = form_for @changeset, "", phx_submit: "save", phx_change: "validate" %>
              <div class="field">
                <%= label f, :name %>
                <%= text_input f, :name, phx_debounce: 1000 %>
                <%= error_tag f, :name %>
              </div>
              <div class="field">
                <%= label f, :framework %>
                <%= text_input f, :framework, phx_debounce: 1000 %>
                <%= error_tag f, :framework %>
              </div>
              <div class="field">
                <%= label f, :size, "Size (MB)" %>
                <%= text_input f, :size, phx_debounce: 1000 %>
                <%= error_tag f, :size %>
              </div>
              <div class="field">
                <%= label f, :git_repo %>
                <%= text_input f, :git_repo, phx_debounce: 1000 %>
                <%= error_tag f, :git_repo %>
              </div>
              <%= submit "Save", phx_disable_with: "Saving..." %>
              <%= live_patch "Cancel",
                  to: Routes.live_path(@socket, __MODULE__),
                  class: "cancel" %>
            </form>
          <% else %>
            <div class="card">
              <div class="header">
                <h2><%= @selected_server.name %></h2>
                <button class="<%= @selected_server.status %>"
                  phx-click="toggle-status"
                  phx-value-id="<%= @selected_server.id %>"
                  phx-disable-with="Saving...">
                  <%= @selected_server.status %>
                </button>
              </div>
              <div class="body">
                <div class="row">
                  <div class="deploys">
                    <img src="/images/deploy.svg">
                    <span>
                      <%= @selected_server.deploy_count %> deploys
                    </span>
                  </div>
                  <span>
                    <%= @selected_server.size %> MB
                  </span>
                  <span>
                    <%= @selected_server.framework %>
                  </span>
                </div>
                <h3>Git Repo</h3>
                <div class="repo">
                  <%= @selected_server.git_repo %>
                </div>
                <h3>Last Commit</h3>
                <div class="commit">
                  <%= @selected_server.last_commit_id %>
                </div>
                <blockquote>
                  <%= @selected_server.last_commit_message %>
                </blockquote>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"server" => params}, socket) do
    case Servers.create_server(params) do
      {:ok, server} ->
        socket =
          socket
          |> push_patch(to: Routes.live_path(socket, __MODULE__, name: server.name))
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :changeset, changeset)
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(params)
      |> Map.put(:action, :insert)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end


  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    {:ok, _server} = Servers.toggle_status_server(server)
    {:noreply, socket}
  end

  def handle_info({:server_created, server}, socket) do
    socket = update(socket, :servers, &[server | &1])
    {:noreply, socket}
  end

  def handle_info({:server_updated, server}, socket) do
    socket =
      if server.id == socket.assigns.selected_server.id do
        assign(socket, selected_server: server)
      else
        socket
      end

    socket = assign(socket, servers: Servers.list_servers())

    {:noreply, socket}
  end

  defp link_body(server) do
    assigns = %{name: server.name, status: server.status}

    ~L"""
    <span class="status <%= @status %>"></span>
    <img src="/images/server.svg">
    <%= @name %>
    """
  end
end
