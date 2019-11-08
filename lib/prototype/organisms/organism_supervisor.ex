defmodule Prototype.OrganismSupervisor do
  @moduledoc false

  use DynamicSupervisor

  alias Prototype.Organism

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def spawn_organism(%Organism{x: x, y: y} = organism)
  when is_integer(x) and x > 5 and is_integer(y) and y > 5 do
    DynamicSupervisor.start_child(__MODULE__, {Prototype.Organism, organism})
  end

  def spawn_organism(_) do
    raise "Boundaries are smaller than the minimum size {5, 5}"
  end

end
