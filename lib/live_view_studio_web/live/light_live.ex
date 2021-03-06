defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: 3000)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style="width: <%= @brightness %>%; background-color: <%= temp_color(@temp) %>">
          <%= @brightness %>%
        </span>
      </div>

      <button phx-click="off">
        <img src="images/light-off.svg">
      </button>

      <button phx-click="down">
        <img src="images/down.svg">
      </button>

      <button phx-click="up">
        <img src="images/up.svg">
      </button>

      <button phx-click="on">
        <img src="images/light-on.svg">
      </button>

      <button phx-click="random">
        Light Me Up!
      </button>

      <form phx-change="update">
        <input type="range" name="brightness"
               value="<%= @brightness %>"
               min="0" max="100" />
      </form>

      <form phx-change="set-temp">
        <%= for temp <- [3000, 4000, 5000] do %>
          <%= temp_radio_button(temp: temp, checked: temp == @temp) %>
        <% end %>
      </form>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)
    {:noreply, socket}
  end

  def handle_event("random", _, socket) do
    socket = assign(socket, :brightness, Enum.random(0..100))
    {:noreply, socket}
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    brightness = String.to_integer(brightness)
    socket = assign(socket, :brightness, brightness)
    {:noreply, socket}
  end

  def handle_event("set-temp", %{"temp" => temp}, socket) do
    socket = assign(socket, :temp, String.to_integer(temp))
    {:noreply, socket}
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"

  defp temp_radio_button(assigns) do
    assigns = Enum.into(assigns, %{})

    ~L"""
    <input type="radio" id="<%= @temp %>"
      name="temp" value="<%= @temp %>"
      <%= if @checked, do: "checked" %> />
    <label for="<%= @temp %>"><%= @temp %></label>
    """
  end
end
