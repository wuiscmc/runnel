defmodule Runnel.NikeFetcher do
  use GenServer
  require Logger
  import Supervisor.Spec

  def start_link(opts \\ []) do
    {:ok, _pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  def init(state) do
    children = [
      supervisor(Task.Supervisor, [[name: Runnel.NikeRunTaskSupervisor]]),
    ]

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one)

    schedule_poll(1_000)
    {:ok, state}
  end

  def handle_info(:work, state) do
    credentials = Application.get_env(:runnel, Runnel.NikeFetcher)[:credentials]
    {:ok, token} = Runnel.Authenticator.login(credentials[:username], credentials[:password])
    Runnel.NikeService.fetch_new_runs(token)

    Logger.debug "scheduling again"

    schedule_poll(600_000)
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    Logger.debug "there was an issue, couldn't retrieve more runs"

    {:noreply, state}
  end

  defp schedule_poll(time) do
    Process.send_after(self(), :work, time)
  end
end
