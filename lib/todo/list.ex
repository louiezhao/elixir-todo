defmodule Todo.List do
  defstruct auto_id: 1, name: nil, entries: %{}

  def new(name, entries \\ []) do
    Enum.reduce(entries, %Todo.List{name: name}, &add(&2, &1))
  end

  def entries(todo_list) do
    todo_list.entries
    |> Enum.map(fn {id, entry} -> Map.put(entry, :id, id) end)
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {id, entry} -> Map.put(entry, :id, id) end)
  end

  def add(todo_list, entry) do
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %Todo.List{
      todo_list
      | auto_id: todo_list.auto_id + 1,
        entries: new_entries
    }
  end

  def update(todo_list, id, updater) do
    if Map.has_key?(todo_list.entries, id) do
      new_entries = Map.update!(todo_list.entries, id, updater)
      %Todo.List{todo_list | entries: new_entries}
    else
      todo_list
    end
  end

  def update(todo_list, id, key, value) do
    if get_in(todo_list.entries, [id, key]) do
      new_entries = put_in(todo_list.entries, [id, key], value)
      %Todo.List{todo_list | entries: new_entries}
    else
      todo_list
    end
  end

  def delete(todo_list, id) do
    new_entries = Map.delete(todo_list.entries, id)
    %Todo.List{todo_list | entries: new_entries}
  end
end
