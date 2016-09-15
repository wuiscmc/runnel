defmodule Runnel.PageView do
  use Runnel.Web, :view

  defp group_runs_by_month(runs) do
    Enum.group_by(runs, fn(run) ->
      {{year, month, _}, _} = Ecto.DateTime.to_erl(run.start_time)
      {year, month}
    end)
    |> Enum.reverse
  end

  defp group_runs_by_month([]), do: []
end
