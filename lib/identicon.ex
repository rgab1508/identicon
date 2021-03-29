defmodule Identicon do

  def main(str) do
    str
    |> hash_str
    |> pick_color
    |> build_grid
    |> filter_odd
    |> build_pixel_grid
    |> draw_image
    |> save_image(str)
  end

  def hash_str(str) do
    s = :crypto.hash(:md5, str)
    |> :binary.bin_to_list

    %Identicon.Image{seed: s}
  end

  def pick_color(image) do
    %Identicon.Image{seed: [r, g, b | _tail]} = image

    %Identicon.Image{image  | color: {r, g, b}}
  end

  def build_grid(image) do
    %Identicon.Image{seed: seed} = image

    grid = seed
    |> Enum.chunk_every(3)
    |> Enum.drop(-1)
    |> mirror_grid
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def filter_odd(image) do
    %Identicon.Image{grid: grid} = image
    new_grid = Enum.filter grid, fn({e, _ind}) ->
      rem(e, 2) == 0
    end

    %Identicon.Image{image | grid: new_grid}
  end

  def build_pixel_grid(image) do
    %Identicon.Image{grid: grid} = image
    pixel_map = Enum.map grid, fn({_e, ind}) ->
      x = rem(ind, 5) * 50
      y = div(ind, 5) * 50
      tl = {x, y}
      br = {x+50, y+50}

      {tl, br}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    img = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.map pixel_map, fn({tl, br}) ->
      :egd.filledRectangle(img, tl, br, fill)
    end

    :egd.render(img)
  end

  def save_image(image, str) do
    File.write("#{str}.png", image)
  end

  defp mirror_grid(seed) do
    for s <- seed do
      [a, b | _tail] = s
      s ++ [a, b]
    end
  end

end
