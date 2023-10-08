defmodule RedixPool.Helper do
  require Logger

  @moduledoc """
    wrapper for redix, using macro delegate_to_redix delegate call to redix
  """

  defmacro __using__(_opts) do
    quote do
      import RedixPool.Helper
    end
  end

  defmacro delegate_to_redix({func_name, _what, [pool_name | other_args] = args}) do
    {:__block__, [], quoted} =
      quote bind_quoted: [
              func_name: Macro.escape(func_name),
              pool_name: Macro.escape(pool_name),
              other_args: Macro.escape(other_args)
            ] do
        def unquote(func_name)(unquote(pool_name), unquote_splicing(other_args)) do
          Redix.unquote(func_name)(
            get_random_conn!(unquote(pool_name)),
            unquote_splicing(other_args)
          )
        end
      end

    {:__block__, [],
     [
       {:@, [context: __MODULE__, import: Kernel],
        [
          {:doc, [],
           [
             "get random conn and delegate to Redix, See Redix." <>
               to_string(func_name) <> "/" <> to_string(args |> length)
           ]}
        ]}
       | quoted
     ]}
  end
end
