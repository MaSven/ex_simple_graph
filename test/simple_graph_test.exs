defmodule SimpleGraphTest do
  use ExUnit.Case
  doctest SimpleGraph

  test "greets the world" do
    assert SimpleGraph.hello() == :world
  end
end
