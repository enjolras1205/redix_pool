defmodule RedixPool do
  @moduledoc """
  A name-based pool implement built on Redix.
  """
  use Supervisor
  use RedixPool.Helper

  @pool_name_regex Regex.compile!("^.*\\.", "")

  @spec start_link(opts :: list()) :: :ignore | {:error, any} | {:ok, pid}
  @doc """
    start a redix name based pool.
    redix_param refer to Redix.start_link

  ## Examples
  iex(2)> {:ok, p} = RedixPool.start_link([pool_name: :test, pool_size: 16, redix_param: [host: "127.0.0.1"]])
  {:ok, #PID<0.433.0>}
  iex(3)> RedixPool.command(:test, ["GET", "K"], [])
  {:ok, nil}
  """
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, strategy: :one_for_one)
  end

  @impl true
  def init(opts) do
    pool_size = Keyword.get(opts, :pool_size) || get_recommend_pool_size!()
    pool_name = Keyword.get(opts, :pool_name) || :default_redix_pool
    redix_param = Keyword.get(opts, :redix_param, [])

    children =
      for index <- 1..pool_size do
        redix_param =
          case redix_param do
            uri when is_binary(uri) ->
              {uri, [name: get_conn_name!(pool_name, index)]}

            opts when is_list(opts) ->
              [{:name, get_conn_name!(pool_name, index)} | opts]
          end

        Supervisor.child_spec({Redix, redix_param}, id: {Redix, index})
      end

    :persistent_term.put({__MODULE__, pool_name}, pool_size)
    Supervisor.init(children, strategy: :one_for_one)
  end

  delegate_to_redix(pipeline(pool_name, commands, opts))
  delegate_to_redix(pipeline!(pool_name, commands, opts))
  delegate_to_redix(noreply_pipeline(pool_name, commands, opts))
  delegate_to_redix(noreply_pipeline!(pool_name, commands, opts))
  delegate_to_redix(command(pool_name, command, opts))
  delegate_to_redix(command!(pool_name, command, opts))
  delegate_to_redix(noreply_command(pool_name, command, opts))
  delegate_to_redix(noreply_command!(pool_name, command, opts))
  delegate_to_redix(transaction_pipeline(pool_name, commands, opts))
  delegate_to_redix(transaction_pipeline!(pool_name, commands, opts))

  @doc """
  get_conn_name by pool_name an pool_index
  """
  @spec get_conn_name!(pool_name :: atom(), index :: integer()) :: atom
  def get_conn_name!(pool_name, index) do
    :"#{index}.#{pool_name}"
  end

  @doc """
  get_conn_pool_name by conn_name, can be use for log and metric.
  see Redix.Telemetry.Example for usage.
  """
  @spec get_conn_pool_name!(conn_name :: atom()) :: String.t()
  def get_conn_pool_name!(conn_name) do
    conn_name = to_string(conn_name)
    Regex.replace(@pool_name_regex, conn_name, "", global: false)
  end

  defp get_random_conn!(pool_name) do
    pool_idx = :rand.uniform(:persistent_term.get({__MODULE__, pool_name}))
    get_conn_name!(pool_name, pool_idx)
  end

  defp get_recommend_pool_size!() do
    :erlang.system_info(:schedulers)
  end
end
