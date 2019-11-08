defmodule Prototype.Calculators.Trajectory do
  @moduledoc false

  def calculate_path(_, nil, _), do: []
  def calculate_path(%{x: x1, y: y1}, %{x: x2, y: y2}, steps) do
    interval_X = (x2 - x1) / (steps + 1)
    interval_Y = (y2 - y1) / (steps + 1)

    Enum.map(1..steps, fn(n) ->
      x = round(x1 + interval_X * n)
      y = round(y1 + interval_Y * n)

      {x, y}
    end)
  end
end
