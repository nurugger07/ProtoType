defmodule Prototype.Organism.Actions do

  import Prototype.Calculators.CollisionDetection, only: [object_detected?: 2]
  import Prototype.Calculators.Trajectory, only: [calculate_path: 3]

  require Logger

  alias Prototype.{
    PetriDish,
    Calculators.NearestNeighbor,
    Calculators.FittestMatch,
    Reproduction,
  }

  def new(dna) do
    Map.merge(dna, %{status: :move, type: :organism})
  end

  def draw(dna) do
    PetriDish.draw(dna)
    dna
  end

  def next_action(%{status: :dead} = dna) do
    dna
    |> cancel_timer()
    |> PetriDish.remove()

    dna
  end

  def next_action(%{status: :hungry} = dna) do
    nearest_food = look_around(dna)

    # Is the food close enough to eat?
    if can_eat?(nearest_food, dna) do
      try do
        Prototype.Food.consumed(nearest_food)

        dna
        |> Map.put(:current_stamina, dna.current_stamina + (nearest_food.calories * 10))
        |> Map.put(:status, :move)
        |> next_action()
      rescue
        _ ->
          dna
          |> Map.put(:status, :move)
          |> next_action()
      end
    else
      with [{x, y}| _] <- calculate_path(dna, nearest_food, (10 - dna.minimum_speed)) do

        dna
        |> Map.merge(%{x: x, y: y})
        |> draw()
      else
        [] ->
          dna
          |> Map.put(:status, :move)
          |> next_action()
      end
    end
  end

  def next_action(%{status: :ready} = dna) do
    nearest_organism = look_around(dna)

    # Is the mate close enough to reproduce?
    if can_mate?(nearest_organism, dna) do
      Reproduction.spawn(nearest_organism, dna)

      dna
      |> Map.put(:current_reproduction_time, dna.minimum_reproduction_time * 2)
      |> Map.put(:status, :move)
      |> next_action()
    else
      with [{x, y}| _] <- calculate_path(dna, nearest_organism, (10 - dna.minimum_speed)) do

        dna
        |> Map.merge(%{x: x, y: y})
        |> draw()
      else
        [] ->
          dna
          |> Map.put(:status, :move)
          |> next_action()
      end
    end
  end

  def next_action(%{status: :move} = dna) do
    x = dna.x + Enum.random(-5..5)
    y = dna.y + Enum.random(-5..5)

    Map.merge(dna, %{x: x, y: y})
  end

  def look_around(%{status: :hungry} = dna) do
    {:ok, {nearest_food, _distance}} =
      PetriDish.all()
      |> Stream.filter(&(&1.type == :food))
      |> Task.async_stream(NearestNeighbor, :calculate_distance, [dna])
      |> Enum.sort(fn({:ok, {_, d1}}, {:ok, {_, d2}}) -> d1 <= d2 end)
      |> take_first()

    nearest_food
  end

  def look_around(%{status: :ready} = dna) do
    {:ok, {nearest_organism, _distance}} =
      PetriDish.all()
      |> Stream.filter(&(&1.type == :organism))
      |> Stream.filter(&(FittestMatch.calculate_fitness(&1, dna)))
      |> Task.async_stream(NearestNeighbor, :calculate_distance, [dna])
      |> Enum.sort(fn({:ok, {_, d1}}, {:ok, {_, d2}}) -> d1 <= d2 end)
      |> take_first()

    nearest_organism
  end

  def set_status(%{current_stamina: 0} = dna) do
    Map.put(dna, :status, :dead)
  end

  def set_status(%{current_stamina: stamina, minimum_stamina: min} = dna) when stamina <= min do
    Map.put(dna, :status, :hungry)
  end

  def set_status(%{current_reproduction_time: time, minimum_reproduction_time: min} = dna) when time <= min do
    Map.put(dna, :status, :ready)
  end

  def set_status(dna) do
    Map.put(dna, :status, :move)
  end

  def set_timer(%{minimum_speed: speed} = dna) do
    move_rate = speed * 100
    {:ok, tref} = :timer.send_interval(move_rate, :move)

    Map.put(dna, :timer, tref)
  end

  defp cancel_timer(%{timer: nil} = dna), do: dna
  defp cancel_timer(%{timer: tref} = dna) do
    with {:ok, :cancel} <- :timer.cancel(tref) do
      Map.put(dna, :timer, nil)
    else
      {:error, reason} ->
        Logger.error("Unable to cancel timer: #{reason}")
      dna
    end
  end

  def can_eat?(nil, _dna), do: false
  def can_eat?(%{id: id} = food, dna) do
    with pid when is_pid(pid) <- :global.whereis_name(id) do
      object_detected?(food, dna)
    else
      _ -> false
    end
  end

  def can_mate?(nil, _dna), do: false
  def can_mate?(%{id: id} = mate, dna) do
    with pid when is_pid(pid) <- :global.whereis_name(id) do
      object_detected?(mate, dna)
    else
      _ -> false
    end
  end

  defp take_first([]), do: {:ok, {nil, nil}}
  defp take_first(list), do: hd(list)
end
