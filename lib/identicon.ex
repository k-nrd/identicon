defmodule Identicon do
  @moduledoc """
  `Identicon` generates user-specific icons given their name.
  """

  def main(input) do
    hashed = hash(input)

    color = pick_color(hashed)

    hashed
    |> build_grid
    |> filter_odds
    |> build_pixel_map
    |> draw_image(color)
    |> save_image(input)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  def draw_image(grid, color) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(grid, fn {top_left, bottom_right} ->
      :egd.filledRectangle(image, top_left, bottom_right, fill)
    end)

    :egd.render(image)
  end

  def build_pixel_map(grid) do
    Enum.map(grid, fn {_code, idx} ->
      x = rem(idx, 5) * 50
      y = div(idx, 5) * 50
      top_left = {x, y}
      bottom_right = {x + 50, y + 50}
      {top_left, bottom_right}
    end)
  end

  def filter_odds(grid) do
    Enum.filter(grid, fn {v, _i} -> rem(v, 2) == 0 end)
  end

  def mirror_row(list) do
    Enum.reverse(list, Enum.drop(list, 1))
  end

  def build_grid(hashed) do
    Enum.chunk_every(hashed, 3, 3, :discard)
    |> Enum.map(&mirror_row/1)
    |> List.flatten()
    |> Enum.with_index()
  end

  def pick_color([r, g, b | _tail]) do
    {r, g, b}
  end

  @doc """
  Hashes the input string with the an md5 algorithm.
  Returns an Identicon.Image struct containing the generated hex list.

  ## Examples

      iex> Identicon.hash("banana")
      %Identicon.Image{
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]
      }
  """
  def hash(input) do
    :crypto.hash(:md5, input)
    |> :binary.bin_to_list()
  end
end
