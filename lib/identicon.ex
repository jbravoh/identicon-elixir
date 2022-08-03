defmodule Identicon do
  def main(input) do
    # pipe each function to pass value to each
    input
    |> hash_input
    |> pick_colour
    |> build_grid

    # |>
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    # [77, 15, 239]
    [first, second | _tail] = row
    # [77, 15, 239, 15, 17]
    row ++ [second, first]
  end

  # patten match to get first three values
  def pick_colour(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    # show all properties from the existing struct and a tuple of {r,g,b}
    %Identicon.Image{image | colour: {r, g, b}}
  end

  def hash_input(input) do
    # create hash and assign to hex
    hex =
      :crypto.hash(:md5, input)
      # get list of hash numbers
      |> :binary.bin_to_list()

    # Pass hex to struct
    %Identicon.Image{hex: hex}
  end
end
