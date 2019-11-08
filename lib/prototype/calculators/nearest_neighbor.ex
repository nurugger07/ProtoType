defmodule Prototype.Calculators.NearestNeighbor do
  @moduledoc false


  @doc """

  calculate_distance/2

  √((x2 - x1)² + (x2 - x1)²)

  Determines the distance between two objects

  """
  def calculate_distance(%{x: x2, y: y2} = neighbor, %{x: x1, y: y1}) do
    x = x2
    |> Kernel.-(x1)
    |> (&(&1 * &1)).()

    y = y2
    |> Kernel.-(y1)
    |> (&(&1 * &1)).()

    distance =
      x
      |> Kernel.+(y)
      |> :math.sqrt()
      |> Float.round(5)

    {neighbor, distance}
  end

end
