defmodule Prototype.Calculators.Trajectory do
  @moduledoc false

  def calucate_path({x1, y1}, {x2, y2}, steps) do
    interval_X = (x2 - x1) / (steps + 1)
    interval_Y = (y2 - y1) / (steps + 1)

    Enum.map(1..steps, fn(n) ->
      {(x1 + interval_X * n), (y1 + interval_Y * n)}
    end)
  end
end
