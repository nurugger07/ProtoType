defmodule Prototype.Reproduction do
  @moduledoc false

  alias Prototype.OrganismGenerator

  import Prototype.TraitGenerator, only: [trait: 2]

  def spawn(organism1, organism2) do
    IO.inspect organism1, label: "Reproducing"
    :timer.sleep(organism1.minimum_reproduction_time)

    child = %{
      parents: %{parent1: organism1.id, parent2: organism2.id},
      fitness: organism1.fitness,
      color: mix_color(organism1, organism2),
      strength: trait(organism1.minimum_strength, organism2.minimum_strength),
      stamina: trait(organism1.minimum_stamina, organism2.minimum_stamina),
      speed: trait(organism1.minimum_speed, organism2.minimum_speed),
      reproduction_time: trait(organism1.minimum_reproduction_time, organism2.minimum_reproduction_time),
      x: coordinate(organism1.x),
      y: coordinate(organism1.y)
    }

    OrganismGenerator.spawn(child)
  end

  def mix_color(%{color: %{r: r1, g: g1, b: b1}}, %{color: %{r: r2, g: g2, b: b2}})  do
    %{
      r: trait(r1, r2),
      g: trait(g1, g2),
      b: trait(b1, b2),
    }
  end

  def coordinate(n) when n <= 5, do: n + 1
  def coordinate(n), do: n - 1
end
