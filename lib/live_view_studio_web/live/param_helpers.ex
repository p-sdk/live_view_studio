defmodule LiveViewStudioWeb.ParamHelpers do
  def param_or_first_permitted(params, key, permitted) do
    value = params[key]
    if value in permitted, do: value, else: hd(permitted)
  end

  def param_to_integer(nil, default_value), do: default_value

  def param_to_integer(param, default_value) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default_value
    end
  end
end
