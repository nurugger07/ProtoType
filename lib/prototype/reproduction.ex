defmodule Prototype.Reproduction do
  @moduledoc false

  alias Prototype.OrganismGenerator

  def spawn(organism1, organism2) do
    :timer.sleep(organism1.minimum_reproduction_time)

    child = %{
      fitness: organism1.fitness,
      color: Enum.random([organism1.color, organism2.color]),
      strength: avg(organism1.minimum_strength, organism2.minimum_strength),
      stamina: avg(organism1.minimum_stamina, organism2.minimum_stamina),
      speed: avg(organism1.minimum_speed, organism2.minimum_speed),
      reproduction_time: avg(organism1.minimum_reproduction_time, organism2.minimum_reproduction_time),
      x: coordinate(organism1.x),
      y: coordinate(organism1.y)
    }

    OrganismGenerator.spawn(child)
  end

  defp avg(val1, val2) do
    val1
    |> Kernel.+(val2)
    |> div(2)
    |> round()
  end

  def coordinate(n) when n <= 5, do: n + 1
  def coordinate(n), do: n - 1
end
