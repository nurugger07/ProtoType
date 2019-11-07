defmodule Prototype.FoodGenerator do
  use GenServer

  require Logger

  alias Prototype.FoodSupervisor

  @initial_state %{
    max_count: 0, # Maximum amount of food generated each iteration
    timer: nil, # Holds the timer reference
    frequency: 10_000, # Time between intervals. Defaults to 10 secs
    delay: nil, # Include a delay between generating food
    bounds: %{x: 250, y: 250} # the bounds of the petri dish
  }

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
  Change the frequency of each itteration
  """
  def change_frequency(frequency) when is_integer(frequency) and frequency > 1000 do
    GenServer.cast(__MODULE__, {:change_frequency, frequency})
  end
  def change_frequency(_), do: {:error, :invalid_arg}

  @doc """
  Change the delay
  """
  def change_delay(delay) when is_integer(delay) do
    GenServer.cast(__MODULE__, {:change_delay, delay})
  end
  def change_delay(_), do: {:error, :invalid_arg}

  @doc """
  Change the bounds for generating food
  """
  def change_bounds(%{x: x, y: y} = bounds)
  when is_integer(x) and x > 5 and is_integer(y) and y > 5 do
    GenServer.cast(__MODULE__, {:change_bounds, bounds})
  end
  def change_bounds(_), do: {:error, :invalid_arg}

  def handle_info(:generate, state) do
    Enum.each(1..state.max_count, fn(_) ->
      call_to_generate_food(state)
    end)

    {:noreply, state}
  end

  def handle_cast({:begin_generation, max_count}, state) do
    {:ok, tref} = :timer.send_interval(state.frequency, :generate)

    new_state =
      state
      |> cancel_timer()
      |> Map.merge(%{
          max_count: max_count,
          timer: tref})

    {:noreply, new_state}
  end

  def handle_cast({:change_frequency, frequency}, state) do
    new_state =
      state
      |> cancel_timer()
      |> Map.merge(%{
          frequency: frequency,
          timer: :timer.send_interval(:generate, frequency)})

    {:noreply, new_state}
  end

  def handle_cast({:change_delay, delay}, state) do
    {:noreply, Map.put(state, :delay, delay)}
  end

  def handle_cast({:change_max_count, max_count}, state) do
    {:noreply, Map.put(state, :max_count, max_count)}
  end

  def handle_cast({:change_bounds, bounds}, state) do
    {:noreply, Map.put(state, :bounds, bounds)}
  end

  defp call_to_generate_food(state) do
    if state.delay do
      :timer.sleep(state.delay)
    end
    FoodSupervisor.generate_food(state)
  end

  defp cancel_timer(%{timer: nil} = state), do: state
  defp cancel_timer(%{timer: tref} = state) do
    with {:ok, :cancel} <- :timer.cancel(tref) do
      Map.put(state, :timer, nil)
    else
      {:error, reason} ->
        Logger.error("Unable to cancel timer: #{reason}")
        state
    end
  end
end
