# RedixPool
A name-based pool implement built on [redix](https://github.com/whatyouhide/redix) refer to [redix-real-world-usage](https://hexdocs.pm/redix/real-world-usage.html)

## Usage
start by child_spec:
```elixir
# see Redix.start_link for redix_param.
child_spec = RedixPool.child_spec(pool_name: :test, redix_param: [host: "127.0.0.1"])
{:ok, _} = Supervisor.start_child(YourSupervisor, child_spec)
# use pool_name instead of conn, see Redix.command for usage.
RedixPool.command(:test, ["GET", "K"], [])
```

start by start_link:
```elixir
# see Redix.start_link for redix_param.
{:ok, _} = RedixPool.start_link([pool_name: :test, redix_param: [host: "127.0.0.1"]])
# use pool_name instead of conn, see Redix.command for usage.
RedixPool.command(:test, ["GET", "K"], [])
```
