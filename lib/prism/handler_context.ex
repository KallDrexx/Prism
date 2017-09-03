defmodule Prism.HandlerContext do
  @type t :: %__MODULE__{
    parent_pid: pid | nil,
    child_pid: pid | nil,
    state: any
  }

  defstruct parent_pid: nil,
            child_pid: nil,
            state: nil
end
