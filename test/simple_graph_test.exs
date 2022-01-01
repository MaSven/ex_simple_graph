defmodule SimpleGraphTest do
  use ExUnit.Case, async: true

  alias SimpleGraph

  describe "With new graph" do
    setup %{} do
      graph_name = new_graph(%{})
      on_exit(fn -> Agent.stop(graph_name) end)
      %{graph_name: graph_name |> Atom.to_string(), graph_id: graph_name}
    end

    test "add first node", %{graph_name: graph_name, graph_id: graph_id} do
      node = SimpleGraph.Node.create_node("test_value")
      assert :ok = SimpleGraph.add_node(name: graph_id, node: node)

      node_id = node.id

      assert %SimpleGraph{
               id: graph_name,
               name: graph_name,
               nodes: %{
                 node_id => node
               }
             } == SimpleGraph.graph(graph_id)
    end

    test "add two nodes that point to each other", %{graph_name: graph_name, graph_id: graph_id} do
      node = SimpleGraph.Node.create_node("test_value1")
      node2 = SimpleGraph.Node.create_node("test_value2")
      assert :ok = SimpleGraph.add_node(name: graph_id, node: node)
      assert :ok = SimpleGraph.add_node(name: graph_id, node: node2)
      assert :ok = SimpleGraph.add_node(name: graph_id, node: node.id, outgoing: node2.id)

      node1_id = node.id
      node2_id = node2.id

      assert %SimpleGraph{
               id: ^graph_name,
               name: ^graph_name,
               nodes: %{
                 ^node1_id => node_first,
                 ^node2_id => node_second
               }
             } = SimpleGraph.graph(graph_id)

      assert node.id == node_first.id
      assert node2.id == node_second.id

      assert [
               node2.id
             ] == node_first.outgoing

      assert [
               node2.id
             ] == node_first.adjacent

      assert [
               node1_id
             ] == node_second.adjacent

      assert [
               node1_id
             ] == node_second.incoming
    end

    test "add incoming node", %{graph_name: graph_name, graph_id: graph_id} do
      node = SimpleGraph.Node.create_node("test_value_1")
      node2 = SimpleGraph.Node.create_node("test_value_2")
      assert :ok = SimpleGraph.add_node(name: graph_id, node: node)
      assert :ok = SimpleGraph.add_node(name: graph_id, node: node2)
      assert :ok = SimpleGraph.add_node(name: graph_id, node: node.id, incoming: node2.id)

      node1_id = node.id
      node2_id = node2.id

      assert %SimpleGraph{
               id: ^graph_name,
               name: ^graph_name,
               nodes: %{
                 ^node1_id => node_first,
                 ^node2_id => node_second
               }
             } = SimpleGraph.graph(graph_id)

      assert node.id == node_first.id
      assert node2.id == node_second.id

      assert [
               node2.id
             ] == node_first.incoming

      assert [
               node2.id
             ] == node_first.adjacent

      assert [
               node1_id
             ] == node_second.adjacent

      assert [
               node1_id
             ] == node_second.outgoing
    end
  end

  defp new_graph(_context) do
    graph_name = UUID.uuid4()
    test_graph = %SimpleGraph{id: graph_name, name: graph_name}
    Agent.start(fn -> test_graph end, name: graph_name |> String.to_atom())
    graph_name |> String.to_atom()
  end
end
