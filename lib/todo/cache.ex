# https://hexdocs.pm/elixir/Supervisor.html

defmodule Todo.Cache do
  def start_link() do
    IO.puts("starting cache")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server(name) do
    case DynamicSupervisor.start_child(__MODULE__, {Todo.Server, name}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end
end
