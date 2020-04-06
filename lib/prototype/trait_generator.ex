defmodule Prototype.TraitGenerator do
  @range 0..255

  def trait(parent1, parent2)do
    avg = avg(parent2, parent1)
    {_, parent_traits} = Enum.map_reduce(0..10, [], fn(n, acc) -> {n, acc ++ [parent1, parent2]} end)

    Enum.random([avg, avg, mutation()] ++ parent_traits)
  end

  defp mutation do
    Enum.random(@range)
  end

  defp avg(val1, val2) do
    val1
    |> Kernel.+(val2)
    |> div(2)
    |> round()
  end
end
