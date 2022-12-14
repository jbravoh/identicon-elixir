defmodule Identicon do
  def main(input) do
    # pipe each function to pass value to each
    input
    |> hash_input
    |> pick_colour
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  # no longer reference image in destructuring as we no longer need access
  def draw_image(%Identicon.Image{colour: colour, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(colour)

    # modifying the existing image
    Enum.each(pixel_map, fn {start, stop} ->
      # returns a status code -> ok
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50
        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {code, _index} ->
        # return even numbers
        rem(code, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
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
