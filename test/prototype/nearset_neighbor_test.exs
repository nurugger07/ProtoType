defmodule Prototype.NearestNeighborTest do
  use ExUnit.Case

  alias Prototype.Calculators.NearestNeighbor, as: C

  test "determine the distance between two points" do
    pointA = {1, 1}
    pointB = {4, 4}
    pointC = {4, 2}

    assert 4.24264 = C.calculate_distance(pointA, pointB)
    assert 3.16228 = C.calculate_distance(pointA, pointC)
  end

end
