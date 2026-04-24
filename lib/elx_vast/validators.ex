defmodule ElxVast.Validators do
  @moduledoc """
  Higher-level validation functions for VAST 4.1 documents.

  This module contains validation logic that combines multiple checks
  and handles complex validation scenarios.
  """

  import SweetXml
  alias ElxVast.Types

  @valid_versions ["4.1", "4.1.0", "4.1.1", "4.1.2"]

  @doc """
  Validates VAST version number.
  """
  def valid_version?(version) when version in @valid_versions, do: true
  def valid_version?(version) when is_binary(version) do
    # Allow versions that start with 4.1
    String.starts_with?(version, "4.1")
  end
  def valid_version?(_), do: false

  @doc """
  Validates required attributes are present and non-empty.
  """
  def validate_required_attribute(element, attr_name) do
    case xpath(element, ~x"./@#{attr_name}"s) do
      nil -> {:error, "Missing required attribute: #{attr_name}"}
      "" -> {:error, "Empty required attribute: #{attr_name}"}
      value -> {:ok, value}
    end
  end

  @doc """
  Validates optional attributes when present.
  """
  def validate_optional_attribute(element, attr_name, validator_func) do
    case xpath(element, ~x"./@#{attr_name}"s) do
      nil -> :ok
      "" -> :ok
      value ->
        if validator_func.(value) do
          :ok
        else
          {:error, "Invalid #{attr_name} attribute value: #{value}"}
        end
    end
  end

  @doc """
  Validates element content when required.
  """
  def validate_required_content(element, content_path, content_name) do
    case xpath(element, content_path) do
      nil -> {:error, "Missing required element: #{content_name}"}
      "" -> {:error, "Empty required element: #{content_name}"}
      value -> {:ok, value}
    end
  end

  @doc """
  Validates MediaFile attributes comprehensively.
  """
  def validate_media_file_attributes(media_file) do
    with {:ok, _delivery} <- validate_required_attribute(media_file, "delivery"),
         {:ok, delivery_value} <- validate_required_attribute(media_file, "delivery"),
         :ok <- validate_delivery_method(delivery_value),
         {:ok, _type} <- validate_required_attribute(media_file, "type"),
         {:ok, type_value} <- validate_required_attribute(media_file, "type"),
         :ok <- validate_mime_type(type_value),
         {:ok, _width} <- validate_required_attribute(media_file, "width"),
         {:ok, width_value} <- validate_required_attribute(media_file, "width"),
         :ok <- validate_dimension(width_value, "width"),
         {:ok, _height} <- validate_required_attribute(media_file, "height"),
         {:ok, height_value} <- validate_required_attribute(media_file, "height"),
         :ok <- validate_dimension(height_value, "height"),
         :ok <- validate_optional_media_attributes(media_file) do
      :ok
    end
  end

  defp validate_delivery_method(delivery) do
    if Types.valid_delivery_method?(delivery) do
      :ok
    else
      {:error, "Invalid delivery method: #{delivery}"}
    end
  end

  defp validate_mime_type(mime_type) do
    if Types.valid_mime_type?(mime_type) do
      :ok
    else
      {:error, "Invalid MIME type: #{mime_type}"}
    end
  end

  defp validate_dimension(dimension, dimension_name) do
    if Types.valid_integer?(dimension) do
      case Integer.parse(dimension) do
        {int_val, ""} when int_val >= 0 -> :ok
        _ -> {:error, "Invalid #{dimension_name}: must be non-negative integer"}
      end
    else
      {:error, "Invalid #{dimension_name}: #{dimension}"}
    end
  end

  defp validate_optional_media_attributes(media_file) do
    with :ok <- validate_optional_attribute(media_file, "codec", &is_binary/1),
         :ok <- validate_optional_attribute(media_file, "bitrate", &Types.valid_positive_integer?/1),
         :ok <- validate_optional_attribute(media_file, "minBitrate", &Types.valid_positive_integer?/1),
         :ok <- validate_optional_attribute(media_file, "maxBitrate", &Types.valid_positive_integer?/1),
         :ok <- validate_optional_attribute(media_file, "scalable", &Types.valid_boolean?/1),
         :ok <- validate_optional_attribute(media_file, "maintainAspectRatio", &Types.valid_boolean?/1),
         :ok <- validate_optional_attribute(media_file, "fileSize", &Types.valid_positive_integer?/1),
         :ok <- validate_optional_attribute(media_file, "apiFramework", &is_binary/1),
         :ok <- validate_bitrate_consistency(media_file) do
      :ok
    end
  end

  defp validate_bitrate_consistency(media_file) do
    bitrate = xpath(media_file, ~x"./@bitrate"s)
    min_bitrate = xpath(media_file, ~x"./@minBitrate"s)
    max_bitrate = xpath(media_file, ~x"./@maxBitrate"s)

    cond do
      not is_nil(bitrate) and (not is_nil(min_bitrate) or not is_nil(max_bitrate)) ->
        {:error, "Cannot specify both bitrate and minBitrate/maxBitrate"}

      not is_nil(min_bitrate) and is_nil(max_bitrate) ->
        {:error, "minBitrate requires maxBitrate to be specified"}

      not is_nil(max_bitrate) and is_nil(min_bitrate) ->
        {:error, "maxBitrate requires minBitrate to be specified"}

      not is_nil(min_bitrate) and not is_nil(max_bitrate) ->
        validate_bitrate_range(min_bitrate, max_bitrate)

      true ->
        :ok
    end
  end

  defp validate_bitrate_range(min_bitrate, max_bitrate) do
    with {min_val, ""} <- Integer.parse(min_bitrate),
         {max_val, ""} <- Integer.parse(max_bitrate) do
      if min_val <= max_val do
        :ok
      else
        {:error, "minBitrate must be less than or equal to maxBitrate"}
      end
    else
      _ -> {:error, "Invalid bitrate values"}
    end
  end

  @doc """
  Validates duration format for Linear ads.
  """
  def validate_duration(duration_value) do
    if Types.valid_time?(duration_value) do
      :ok
    else
      {:error, "Invalid duration format: #{duration_value}. Expected hh:mm:ss or hh:mm:ss.mmm"}
    end
  end

  @doc """
  Validates pricing element structure.
  """
  def validate_pricing(pricing_element) do
    with {:ok, model} <- validate_required_attribute(pricing_element, "model"),
         :ok <- validate_pricing_model(model),
         {:ok, currency} <- validate_required_attribute(pricing_element, "currency"),
         :ok <- validate_currency(currency),
         {:ok, _price_value} <- validate_pricing_content(pricing_element) do
      :ok
    end
  end

  defp validate_pricing_model(model) do
    if Types.valid_pricing_model?(model) do
      :ok
    else
      {:error, "Invalid pricing model: #{model}"}
    end
  end

  defp validate_currency(currency) do
    if Types.valid_currency?(currency) do
      :ok
    else
      {:error, "Invalid currency code: #{currency}. Expected 3-letter ISO-4217 code"}
    end
  end

  defp validate_pricing_content(pricing_element) do
    case xpath(pricing_element, ~x"./text()"s) do
      nil -> {:error, "Missing pricing value"}
      "" -> {:error, "Empty pricing value"}
      value ->
        if Types.valid_decimal?(value) do
          {:ok, value}
        else
          {:error, "Invalid pricing value: #{value}"}
        end
    end
  end

  @doc """
  Validates tracking events.
  """
  def validate_tracking_event(tracking_element) do
    with {:ok, event_name} <- validate_required_attribute(tracking_element, "event"),
         :ok <- validate_event_name(event_name),
         :ok <- validate_event_offset(tracking_element, event_name),
         {:ok, _uri} <- validate_tracking_uri(tracking_element) do
      :ok
    end
  end

  defp validate_event_name(event_name) do
    if Types.valid_tracking_event?(event_name) do
      :ok
    else
      {:error, "Invalid tracking event: #{event_name}"}
    end
  end

  defp validate_event_offset(tracking_element, event_name) do
    offset = xpath(tracking_element, ~x"./@offset"s)

    case {event_name, offset} do
      {"progress", nil} ->
        {:error, "progress event requires offset attribute"}

      {"progress", offset_value} ->
        if Types.valid_offset?(offset_value) do
          :ok
        else
          {:error, "Invalid offset format: #{offset_value}"}
        end

      {_, nil} ->
        :ok

      {_, offset_value} ->
        if Types.valid_offset?(offset_value) do
          :ok
        else
          {:error, "Invalid offset format: #{offset_value}"}
        end
    end
  end

  defp validate_tracking_uri(tracking_element) do
    case xpath(tracking_element, ~x"./text()"s) do
      nil -> {:error, "Missing tracking URI"}
      "" -> {:error, "Empty tracking URI"}
      uri ->
        if Types.valid_uri?(uri) do
          {:ok, uri}
        else
          {:error, "Invalid tracking URI: #{uri}"}
        end
    end
  end
end