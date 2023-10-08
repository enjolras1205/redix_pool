defmodule Redix.Telemetry.Example do
  require Logger

  @spec attach_default_handler() :: :ok | {:error, :already_exists}
  def attach_default_handler() do
    events = [
      [:redix, :pipeline, :start],
      [:redix, :pipeline, :stop],
      [:redix, :disconnection],
      [:redix, :connection],
      [:redix, :failed_connection]
    ]

    :telemetry.attach_many(
      "redix-default-telemetry-handler",
      events,
      &__MODULE__.handle_event/4,
      :no_config
    )
  end

  @spec handle_event([atom()], map(), map(), term()) :: :ok
  def handle_event(redix_event, measurements, metadata, _) do
    pool_name = get_conn_pool_name!(metadata)

    Logger.info(%{
      event: redix_event,
      pool_name: pool_name,
      measurements: measurements,
      metadata: inspect(metadata)
    })
  end

  defp get_conn_pool_name!(%{connection_name: connection_name}) do
    RedixPool.get_conn_pool_name!(connection_name)
  end
end
