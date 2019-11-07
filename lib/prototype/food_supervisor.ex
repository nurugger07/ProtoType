defmodule Prototype.FoodSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def generate_food(%{bounds: %{x: x, y: y}} = bounds)
  when is_integer(x) and x > 5 and is_integer(y) and y > 5 do
    DynamicSupervisor.start_child(__MODULE__, {Prototype.Food, bounds})
  end

  def generate_food(_) do
    raise "Boundaries are smaller than the minimum size {5, 5}"
  end

end
