defmodule HandlerTest do
  use ExUnit.Case

  alias Prism.Handler, as: Handler
  
  test "Input flows through child handlers" do
    {:ok, handler1} = Handler.start_link(nil, Support.TestIncrementalHandler, nil)
    {:ok, handler2} = Handler.start_link(nil, Support.TestIncrementalHandler, nil)
    {:ok, handler3} = Handler.start_link(nil, Support.TestIncrementalHandler, nil)
    {:ok, handler4} = Handler.start_link(nil, Support.TestIncrementalHandler, nil)
    {:ok, handler5} = Handler.start_link(nil, Support.TestEndpointHandler, self())

    :ok = Handler.register_child(handler1, handler2)
    :ok = Handler.register_child(handler2, handler3)
    :ok = Handler.register_child(handler3, handler4)
    :ok = Handler.register_child(handler4, handler5)

    :ok = Handler.relay_input(handler1, 0)

    assert_receive {:input_received, 4}, 100
  end

  test "Output flows through parent handlers" do
    {:ok, handler1} = Handler.start_link(nil, Support.TestEndpointHandler, self())
    {:ok, handler2} = Handler.start_link(handler1, Support.TestIncrementalHandler, nil)
    {:ok, handler3} = Handler.start_link(handler2, Support.TestIncrementalHandler, nil)
    {:ok, handler4} = Handler.start_link(handler3, Support.TestIncrementalHandler, nil)
    {:ok, handler5} = Handler.start_link(handler4, Support.TestIncrementalHandler, nil)

    :ok = Handler.relay_output(handler5, 0)

    assert_receive {:output_received, 4}, 100
  end

end
