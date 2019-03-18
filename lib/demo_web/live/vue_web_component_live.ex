defmodule DemoWeb.VueWebComponentLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <form phx-submit="set-location">
        <input name="location" placeholder="Location" value="<%= @location %>"/>
        <%= @weather %>
      </form>
      <div>[Phoenix State] Component value: <%= @val %></div>
      <my-custom-element msg="<%= @weather %>" phx-click="action" value="<%= @val %>"></my-custom-element>

      <div>[Phoenix State] Selected date: <%= @selDate %></div>
      <time-picker phx-click="timepicker" value="<%= @selDate %>"></time-picker>
    </div>
    """
  end

  def mount(_session, socket) do
    send(self(), {:put, "Austin"})
    {:ok, assign(socket, location: nil, weather: "...", val: "no value", selDate: "no value")}
  end

  def handle_event("set-location", %{"location" => location}, socket) do
    {:noreply, put_location(socket, location)}
  end

  def handle_event("action", value, socket) do
    IO.inspect(value)
    {:noreply, assign(socket, val: value)}
  end

  def handle_event("timepicker", value, socket) do
    IO.inspect(value)
    {:noreply, assign(socket, selDate: value)}
  end

  def handle_info({:put, location}, socket) do
    {:noreply, put_location(socket, location)}
  end

  defp put_location(socket, location) do
    assign(socket, location: location, weather: weather(location))
  end

  defp weather(local) do
    {:ok, {{_, 200, _}, _, body}} =
      :httpc.request(:get, {~c"http://wttr.in/#{local}?format=1", []}, [], [])
    IO.iodata_to_binary(body)
  end
end
