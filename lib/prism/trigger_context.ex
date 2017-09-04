defmodule Prism.TriggerContext do

  @type t :: %__MODULE__{
    adopter_state: any,
    handlers: [Prism.Trigger.handler]
  }

  defstruct adopter_state: nil,
            handlers: []

end
