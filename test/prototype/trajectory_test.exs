defmodule Prototype.Calculators.TrajectoryTest do
  use ExUnit.Case

  alias Prototype.Calculators.Trajectory, as: C

  test "determine the path on a line from pointA to pointB" do
    pointA = {1,1}
    pointB = {4,4}
    steps = 2

    assert [{2.0, 2.0}, {3.0, 3.0}] = C.calucate_path(pointA, pointB, steps)
  end
end
