defmodule RedixPoolTest do
  use ExUnit.Case
  require Logger
  @pool_name :a_redix_pool

  setup_all do
    child_spec =
      RedixPool.child_spec(pool_name: @pool_name, pool_size: 2, redix_param: [host: "127.0.0.1"])

    Redix.Telemetry.Example.attach_default_handler()

    {:ok, _} = start_supervised(child_spec)

    {:ok, redix_conn} = Redix.start_link()
    Redix.command!(redix_conn, ["FLUSHDB"])

    on_exit(fn ->
      clean_resp =
        Redix.pipeline!(
          redix_conn,
          [["DEL", "Q"], ["DEL", "W"], ["DEL", "E"]]
        )

      Logger.info("on_exit_clean_resp:#{inspect(clean_resp)}")
    end)

    :ok
  end

  test "command" do
    {:ok, _} =
      RedixPool.command(
        @pool_name,
        ["SET", "Q", "QQ"],
        []
      )

    {:ok, "QQ"} = RedixPool.command(@pool_name, ["GET", "Q"], [])

    "OK" =
      RedixPool.command!(
        @pool_name,
        ["SET", "Q", "QQQ"],
        []
      )

    "QQQ" = RedixPool.command!(@pool_name, ["GET", "Q"], [])
    :ok = RedixPool.noreply_command(@pool_name, ["SET", "Q", "1"], [])
    "1" = RedixPool.command!(@pool_name, ["GET", "Q"], [])
    :ok = RedixPool.noreply_command!(@pool_name, ["SET", "Q", "2"], [])
    "2" = RedixPool.command!(@pool_name, ["GET", "Q"], [])
  end

  test "pipeline" do
    {:ok, ["OK", "1"]} =
      RedixPool.pipeline(@pool_name, [["SET", "W", "1"], ["GET", "W"]], [])

    ["OK", "1"] = RedixPool.pipeline!(@pool_name, [["SET", "W", "1"], ["GET", "W"]], [])

    :ok = RedixPool.noreply_pipeline(@pool_name, [["SET", "W", "2"]], [])
    "2" = RedixPool.command!(@pool_name, ["GET", "W"], [])
    :ok = RedixPool.noreply_pipeline!(@pool_name, [["SET", "W", "3"]], [])
    "3" = RedixPool.command!(@pool_name, ["GET", "W"], [])
  end

  test "transaction" do
    {:ok, ["OK", "1"]} =
      RedixPool.transaction_pipeline(
        @pool_name,
        [["SET", "E", "1"], ["GET", "E"]],
        []
      )

    ["OK", "2"] =
      RedixPool.transaction_pipeline!(
        @pool_name,
        [["SET", "E", "2"], ["GET", "E"]],
        []
      )
  end

  test "redix start link with uri" do
    pool_name = :test_uri

    {:ok, _} =
      RedixPool.start_link(
        pool_name: pool_name,
        redix_param: "redis://127.0.0.1:6379"
      )

    {:ok, nil} = RedixPool.command(pool_name, ["GET", "R"], [])
  end
end
