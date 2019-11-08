defmodule Prototype.OrganismGenerator do
  use GenServer

  require Logger

  alias Prototype.{OrganismSupervisor, Organism}

  @initial_state %{
    max_count: 0, # Maximum amount of food generated each iteration
    delay: 500, # Include a delay between generating food
    fitness: :stamina,
    bounds: %{x: 500, y: 500} # the bounds of the petri dish
  }

  @colors [
    "black",
    "red",
    "maroon",
    "olive",
    "lime",
    "aqua",
    "teal",
    "blue",
    "navy",
    "fuchsia",
    "purple"
  ]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, @initial_state}
  end

  @doc """
  Begin generating food on a set frequency
  """
  def begin_generation(max_count) when is_integer(max_count) and max_count > 1 do
    GenServer.cast(__MODULE__, {:begin_generation, max_count})
  end
  def begin_generation(_), do: {:error, :invalid_arg}

  @doc """
  Changes the maximum amount of food generated per iteration
  """
  def change_max_count(max_count) when is_integer(max_count) and max_count > 1 do
    GenServer.cast(__MODULE__, {:change_max_count, max_count})
  end
  def change_max_count(_), do: {:error, :invalid_arg}

  @doc """
  Change the delay
  """
  def change_delay(delay) when is_integer(delay) do
    GenServer.cast(__MODULE__, {:change_delay, delay})
  end
  def change_delay(_), do: {:error, :invalid_arg}

  @doc """
  Change the fitness
  """
  def change_fitness(fitness) when is_integer(fitness) do
    GenServer.cast(__MODULE__, {:change_fitness, fitness})
  end
  def change_fitness(_), do: {:error, :invalid_arg}

  @doc """
  Change the bounds for generating food
  """
  def change_bounds(%{x: x, y: y} = bounds)
  when is_integer(x) and x > 5 and is_integer(y) and y > 5 do
    GenServer.cast(__MODULE__, {:change_bounds, bounds})
  end
  def change_bounds(_), do: {:error, :invalid_arg}

  @doc """
  Spawn one organism
  """
  def spawn(child) when is_map(child) do
    GenServer.cast(__MODULE__, {:spawn, child})
  end
  def spawn(_), do: {:error, :invalid_arg}

  def handle_cast({:begin_generation, max_count}, state) do

    Enum.each(1..max_count, fn(_) ->
      call_to_spawn(state)
    end)

    {:noreply, Map.put(state, :max_count, max_count)}
  end

  def handle_cast({:spawn, child}, state) do
    call_to_spawn(child)
    {:noreply, state}
  end

  def handle_cast({:change_delay, delay}, state) do
    {:noreply, Map.put(state, :delay, delay)}
  end

  def handle_cast({:change_fitness, fitness}, state) do
    {:noreply, Map.put(state, :fitness, fitness)}
  end

  def handle_cast({:change_max_count, max_count}, state) do
    {:noreply, Map.put(state, :max_count, max_count)}
  end

  def handle_cast({:change_bounds, bounds}, state) do
    {:noreply, Map.put(state, :bounds, bounds)}
  end

  defp call_to_spawn(%{bounds: %{x: x, y: y}} = state) do

    if state.delay do
      :timer.sleep(state.delay)
    end

    strength = Enum.random(1..100)
    stamina = Enum.random(1..100)

    organism = %Organism{
      id: UUID.uuid4(),
      fitness: state.fitness,
      status: :move,
      color: Enum.random(@colors),
      minimum_strength: strength,
      current_strength: strength + 25,
      minimum_stamina: stamina,
      current_stamina: stamina + 25,
      minimum_speed: Enum.random(3..10),
      minimum_reproduction_time: Enum.random(5_000..10_000),
      width: size(strength),
      height: size(strength),
      radius: size(strength),
      x: Enum.random(50..(x - 50)),
      y: Enum.random(50..(y - 50)),
    }

    OrganismSupervisor.spawn_organism(organism)
  end

  defp call_to_spawn(child) do
    organism = %Organism{
      id: UUID.uuid4(),
      fitness: child.fitness,
      status: :move,
      color: child.color,
      minimum_strength: child.strength,
      current_strength: child.strength + 25,
      minimum_stamina: child.stamina,
      current_stamina: child.stamina + 25,
      minimum_speed: child.speed,
      minimum_reproduction_time: child.reproduction_time,
      width: size(child.strength),
      height: size(child.strength),
      radius: size(child.strength),
      x: child.x,
      y: child.y
    }

    OrganismSupervisor.spawn_organism(organism)
  end

  defp size(strength) do
    cond do
      strength < 25 -> 5
      strength < 50 -> 10
      strength < 75 -> 15
      true -> 20
    end
  end
end
