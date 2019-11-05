defmodule PrototypeWeb.Live.PetriDish do
  use Phoenix.LiveView

  @organisms [
    %{name: "A", width: 20, height: 10, radius: 5, color: "red", x: 30, y: 60},
    %{name: "B", width: 10, height: 10, radius: 10, color: "orange", x: 20, y: 20},
    %{name: "C", width: 10, height: 10, radius: 10, color: "blue", x: 90, y: 40},
    %{name: "D", width: 10, height: 20, radius: 5, color: "blue", x: 140, y: 70},
    %{name: "E", width: 10, height: 10, radius: 10, color: "blue", x: 100, y: 110},
    %{name: "F", width: 10, height: 10, radius: 10, color: "blue", x: 140, y: 140},
    %{name: "G", width: 10, height: 10, radius: 10, color: "blue", x: 50, y: 120},
  ]

  @food [
    %{name: "F1", width: 5, height: 5, color: "green", x: 160, y: 50},
    %{name: "F1", width: 5, height: 5, color: "green", x: 200, y: 20},
  ]

  def mount(_, socket) do
    :timer.send_interval(100, self(), :move)
    {:ok, assign(socket, %{organisms: @organisms, food: @food, time: time() })}
  end

  def handle_info(:move, socket) do
    organisms = move_organisms((socket.assigns.organisms || @organisms))
    {:noreply, assign(socket, %{organisms: organisms, time: time()})}
  end

  def move_organisms(organisms) do
    Enum.map(organisms, fn(o) ->
      o
      |> Map.update(:x, 0, &(&1 + Enum.random(-5..5)))
      |> Map.update(:y, 0, &(&1 + Enum.random(-5..5)))
    end)
  end

  def time do
    DateTime.utc_now |> DateTime.to_string
  end


  def render(assigns) do
    PrototypeWeb.PetriDishView.render("index.html", assigns)
  end
end
