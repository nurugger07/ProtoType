defmodule Prototype.Calculators.FittestMatch do

  def calculate_fitness(%{minimum_strength: strength}, %{fitness: :strength} = dna) do
    strength >= dna.minimum_strength
  end

  def calculate_fitness(%{minimum_stamina: stamina}, %{fitness: :stamina} = dna) do
    stamina >= dna.minimum_stamina
  end

  def calculate_fitness(mate, %{fitness: {:color, color}} = dna) do
    color == mate.color
  end

end
