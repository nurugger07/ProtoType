defmodule PrototypeWeb.Live.PetriDish do
  @moduledoc """

  The live view petri dish used to render the objects in the dish to the UI

  """
  use Phoenix.LiveView

  alias Prototype.PetriDish

  def mount(_, socket) do
    :timer.send_interval(100, self(), :redraw)
    {:ok, assign(socket, %{objects: [], time: time() })}
  end

  def handle_info(:redraw, socket) do
    {:noreply, assign(socket, %{objects: PetriDish.all(), time: time()})}
  end

  def time do
    DateTime.utc_now |> DateTime.to_string
  end

  def render(assigns) do
    PrototypeWeb.PetriDishView.render("index.html", assigns)
  end
end
