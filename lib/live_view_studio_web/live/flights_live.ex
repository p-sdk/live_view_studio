defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights
  alias LiveViewStudio.Airports

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        flight_number: "",
        flights: [],
        airport: "",
        airports: [],
        loading: false
      )
    {:ok, socket, temporary_assigns: [flights: []]}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Flight</h1>
    <div id="search">
      <form phx-submit="number-search">
        <input type="text" name="flight_number" value="<%= @flight_number %>"
               placeholder="Flight Number"
               autofocus autocomplete="off"
               <%= if @loading, do: "readonly" %> />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <form phx-submit="airport-search" phx-change="suggest-airport">
        <input type="text" name="airport" value="<%= @airport %>"
               placeholder="Airport"
               autocomplete="off" phx-debounce="500"
               list="airports"
               <%= if @loading, do: "readonly" %> />

        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <datalist id="airports">
        <%= for code <- @airports do %>
          <option value="<%= code %>"><%= code %></option>
        <% end %>
      </datalist>

      <%= if @loading do %>
        <div class="loader">Loading...</div>
      <% end %>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= format_time(flight.departure_time) %>
                </div>
                <div class="arrives">
                  Arrives: <%= format_time(flight.arrival_time) %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("number-search", %{"flight_number" => flight_number}, socket) do
    send(self(), {:run_number_search, flight_number})

    socket =
      assign(socket,
        flight_number: flight_number,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("suggest-airport", %{"airport" => prefix}, socket) do
    socket = assign(socket, airports: Airports.suggest(prefix))
    {:noreply, socket}
  end

  def handle_event("airport-search", %{"airport" => airport}, socket) do
    send(self(), {:run_airport_search, airport})

    socket =
      assign(socket,
        airport: airport,
        flights: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_info({:run_number_search, flight_number}, socket) do
    case Flights.search_by_number(flight_number) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights matching: \"#{flight_number}\"")
          |> assign(flights: [], loading: false)
        {:noreply, socket}

      flights ->
        socket =
          socket
          |> clear_flash
          |> assign(flights: flights, loading: false)
        {:noreply, socket}
    end
  end

  def handle_info({:run_airport_search, airport}, socket) do
    case Flights.search_by_airport(airport) do
      [] ->
        socket =
          socket
          |> put_flash(:info, "No flights matching: \"#{airport}\"")
          |> assign(flights: [], loading: false)
        {:noreply, socket}

      flights ->
        socket =
          socket
          |> clear_flash
          |> assign(flights: flights, loading: false)
        {:noreply, socket}
    end
  end

  defp format_time(time) do
    Timex.format!(time, "{Mshort} {D} at {h24}:{m}")
  end
end
