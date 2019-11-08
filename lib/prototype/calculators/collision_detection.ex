defmodule Prototype.Calculators.CollisionDetection do
  @moduledoc false

  def object_detected?(object1, object2) do
    distance = distance_between(object1, object2)

    r1 = div(object1.width, 2)
    r2 = div(object2.width, 2)

    distance < (r1 + r2)
  end

  defp distance_between(object1, object2) do
    dx = object1.x - object2.x
    dy = object1.y - object2.y

    :math.sqrt(dx * dx + dy * dy)
  end

  def wall_detected?(object, %{x: x, y: y} = bounds) do
    walls = [
      %{x: 0, y: 0},
      %{x: 0, y: y},
      %{x: x, y: 0},
      bounds
    ]

    check_walls(walls, object)
  end

  defp check_walls([], _object), do: false
  defp check_walls([w | walls], object) do
    distance = distance_between(w, object)
    radius = div(object.width, 2)

    if distance < radius do
      true
    else
      check_walls(walls, object)
    end
  end

end
