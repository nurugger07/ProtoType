defmodule Prototype.Organism do
  use GenServer, restart: :transient

  import Prototype.Organism.Actions

  alias Prototype.Organism

  defstruct [
    :id, # used to identify organisms
    :type, # defaults to organism
    :parents,
    :color, # using rgb colors
    :width,
    :height,
    :radius,
    :x, # X coordinate for current location
    :y, # Y coordinate for current location
    :minimum_life_expectancy, # in milliseconds. Determines when organism dies
    :minimum_reproduction_time, # in milliseconds when reached the organism looks to reproduce
    :current_reproduction_time,
    :minimum_speed, # Range from 1-10. Determines steps when moving.
    :current_speed,
    :minimum_stamina, # Range from 1-100. Determines when organism is hungry. If 0 then the organism dies
    :current_stamina, # Range from 1-100. Determines when organism is hungry. If 0 then the organism dies
    :minimum_strength, # Range from 1-100
    :current_strength, # Range from 1-100
    :fitness, # Preferred trait
    :status, # Moving (:move), Ready to Reproduce (:ready), Reproducing (:reproduce), Hungry (:hungry), Dead (:dead)
    :timer,
  ]

  def start_link(%Organism{} = dna) do
    GenServer.start_link(__MODULE__, dna, name: {:via, :global, dna.id})
  end

  def start_link(_) do
    raise "Invalid organism"
  end

  def init(dna) do
    {:ok, dna, {:continue, :spawn}}
  end

  @doc """
  When a wall is hit then this function is called to bounce the organism back
  """
  def bounce(organism) do
    with pid when is_pid(pid) <- :global.whereis_name(organism.id) do
      GenServer.cast(pid, {:bounce, organism})
    end
  end

  def handle_continue(:spawn, dna) do
    dna =
      dna
      |> new()
      |> set_timer()
      |> draw()

    {:noreply, dna}
  end

  def handle_cast({:bounce, %{x: x, y: y}}, dna) do
    {:noreply, Map.merge(dna, %{x: x, y: y})}
  end

  def handle_info(:move, dna) do
    dna = Map.merge(dna, %{
      current_stamina: dna.current_stamina - 1,
      current_strength: dna.current_strength - 1,
      current_reproduction_time: (dna.current_reproduction_time || (dna.minimum_reproduction_time * 2))  - 100
    })
    |> set_status()
    |> next_action()

    if dna.status == :dead do
      {:stop, :normal, dna}
    else
      draw(dna)
      {:noreply, dna}
    end
  end
end
