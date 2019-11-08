defmodule PrototypeWeb.Live.PetriDish do
  @moduledoc """

  The live view petri dish used to render the objects in the dish to the UI

  """
  use Phoenix.LiveView

  alias Prototype.{
    PetriDish,
    OrganismGenerator,
    FoodGenerator
  }

  @food_count 10
  @organism_count 10
  @fitness :strength

  def mount(_, socket) do
    :timer.send_interval(100, self(), :redraw)

    assigns = %{
      objects: [],
      time: time(),
      max_food: @food_count,
      max_organism: @organism_count,
      fitness: @fitness,
      status: "Waiting to start..."
    }

    {:ok, assign(socket, assigns)}
  end

  def handle_info(:redraw, socket) do
    {:noreply, assign(socket, %{objects: PetriDish.all(), time: time()})}
  end

  def handle_event("update-settings", %{"_target" => ["organism-count"], "organism-count" => count}, socket) do
    assigns = %{
      max_organism: count,
      status: "Updating the seed organism count to #{count}"
    }
    {:noreply, assign(socket, Map.merge(socket.assigns, assigns))}
  end

  def handle_event("update-settings", %{"_target" => ["food-count"], "food-count" => count}, socket) do
    assigns = %{
      max_food: count,
      status: "Updating the max food count to #{count}"
    }
    {:noreply, assign(socket, Map.merge(socket.assigns, assigns))}
  end

  def handle_event("update-settings", %{"_target" => ["fitness"], "fitness" => fitness}, socket) do
    OrganismGenerator.change_fitness(fitness)

    assigns = %{
      fitness: fitness,
      status: "Updating the fitness to #{fitness}"
    }
    {:noreply, assign(socket, Map.merge(socket.assigns, assigns))}
  end

  def handle_event("generate-food", _value, socket) do
    socket.assigns.max_food
    |> convert_to_integer()
    |> FoodGenerator.begin_generation()

    {:noreply, socket}
  end

  def handle_event("generate-organisms", _value, socket) do
    socket.assigns.max_organism
    |> convert_to_integer()
    |> OrganismGenerator.begin_generation()
    {:noreply, socket}
  end

  def handle_event("clear-dish", _value, socket) do
    PetriDish.clear()
    {:noreply, assign(socket, Map.put(socket.assigns, :status, "Cleaning the petri dish..."))}
  end

  def time do
    DateTime.utc_now |> DateTime.to_string
  end

  def render(assigns) do
    PrototypeWeb.PetriDishView.render("index.html", assigns)
  end

  defp convert_to_integer(int) when is_integer(int), do: int
  defp convert_to_integer(int) when is_binary(int), do: String.to_integer(int)
end
