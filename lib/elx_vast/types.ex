defmodule ElxVast.Types do
  @moduledoc """
  Type validation functions for VAST 4.1 data types.

  This module contains validation functions for various data types
  defined in the VAST 4.1 XSD schema.
  """

  @doc """
  Validates time format (hh:mm:ss or hh:mm:ss.mmm).
  """
  def valid_time?(time_string) when is_binary(time_string) do
    # Pattern: hh:mm:ss or hh:mm:ss.mmm (hh: 00-23, mm: 00-59, ss: 00-59)
    time_pattern = ~r/^([01]\d|2[0-3]):[0-5]\d:[0-5]\d(\.\d{3})?$/
    Regex.match?(time_pattern, time_string)
  end

  def valid_time?(_), do: false

  @doc """
  Validates offset format (time or percentage).
  Accepts formats like "00:00:15", "00:00:15.000", "25%", "100%"
  """
  def valid_offset?(offset_string) when is_binary(offset_string) do
    # Pattern from XSD: (\d{2}:[0-5]\d:[0-5]\d(\.\d\d\d)?|1?\d?\d(\.?\d)*%)
    # Time format (use same validation as valid_time) or percentage
    cond do
      String.ends_with?(offset_string, "%") ->
        # Extract percentage value and validate
        percentage_str = String.trim_trailing(offset_string, "%")
        case Float.parse(percentage_str) do
          {percentage, ""} when percentage >= 0 and percentage <= 100 -> true
          _ ->
            case Integer.parse(percentage_str) do
              {percentage, ""} when percentage >= 0 and percentage <= 100 -> true
              _ -> false
            end
        end

      true ->
        # Validate as time format
        valid_time?(offset_string)
    end
  end

  def valid_offset?(_), do: false

  @doc """
  Validates URI format.
  """
  def valid_uri?(uri_string) when is_binary(uri_string) do
    # Basic URI validation - you might want to use a more robust URI library
    uri_pattern = ~r/^https?:\/\/.+|^\/\/.+|^\/.*|^[a-zA-Z][a-zA-Z\d+.-]*:/
    Regex.match?(uri_pattern, uri_string) or uri_string == "about:blank"
  end

  def valid_uri?(_), do: false

  @doc """
  Validates integer values.
  """
  def valid_integer?(value) when is_binary(value) do
    case Integer.parse(value) do
      {_integer, ""} -> true
      _ -> false
    end
  end

  def valid_integer?(value) when is_integer(value), do: true
  def valid_integer?(_), do: false

  @doc """
  Validates positive integer values.
  """
  def valid_positive_integer?(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} when integer > 0 -> true
      _ -> false
    end
  end

  def valid_positive_integer?(value) when is_integer(value), do: value > 0
  def valid_positive_integer?(_), do: false

  @doc """
  Validates decimal values.
  """
  def valid_decimal?(value) when is_binary(value) do
    case Float.parse(value) do
      {_float, ""} -> true
      _ ->
        case Integer.parse(value) do
          {_integer, ""} -> true
          _ -> false
        end
    end
  end

  def valid_decimal?(value) when is_number(value), do: true
  def valid_decimal?(_), do: false

  @doc """
  Validates boolean values.
  """
  def valid_boolean?(value) when value in ["true", "false", "1", "0"], do: true
  def valid_boolean?(value) when is_boolean(value), do: true
  def valid_boolean?(_), do: false

  @doc """
  Validates MIME type format.
  """
  def valid_mime_type?(mime_type) when is_binary(mime_type) do
    # Basic MIME type pattern: type/subtype
    mime_pattern = ~r/^[a-zA-Z][a-zA-Z0-9!#$&\-\^]*\/[a-zA-Z0-9!#$&\-\^]+$/
    Regex.match?(mime_pattern, mime_type)
  end

  def valid_mime_type?(_), do: false

  @doc """
  Validates currency code (3-letter ISO-4217).
  """
  def valid_currency?(currency) when is_binary(currency) do
    currency_pattern = ~r/^[a-zA-Z]{3}$/
    Regex.match?(currency_pattern, currency)
  end

  def valid_currency?(_), do: false

  @doc """
  Validates position values (numeric or keywords).
  """
  def valid_x_position?(position) when position in ["left", "right"], do: true
  def valid_x_position?(position) when is_binary(position) do
    position_pattern = ~r/^[0-9]*$/
    Regex.match?(position_pattern, position)
  end
  def valid_x_position?(_), do: false

  def valid_y_position?(position) when position in ["top", "bottom"], do: true
  def valid_y_position?(position) when is_binary(position) do
    position_pattern = ~r/^[0-9]*$/
    Regex.match?(position_pattern, position)
  end
  def valid_y_position?(_), do: false

  @doc """
  Validates enumerated values for different VAST elements.
  """
  def valid_ad_type?(ad_type) when ad_type in ["video", "audio", "hybrid"], do: true
  def valid_ad_type?(_), do: false

  def valid_delivery_method?(delivery) when delivery in ["streaming", "progressive"], do: true
  def valid_delivery_method?(_), do: false

  def valid_pricing_model?(model) when model in ["CPC", "CPM", "CPE", "CPV", "cpc", "cpm", "cpe", "cpv"], do: true
  def valid_pricing_model?(_), do: false

  def valid_companion_required?(required) when required in ["all", "any", "none"], do: true
  def valid_companion_required?(_), do: false

  def valid_rendering_mode?(mode) when mode in ["default", "end-card", "concurrent"], do: true
  def valid_rendering_mode?(_), do: false

  @doc """
  Validates tracking event names.
  """
  def valid_tracking_event?(event) when event in [
    "mute", "unmute", "pause", "resume", "rewind", "skip",
    "playerExpand", "playerCollapse", "loaded", "start",
    "firstQuartile", "midpoint", "thirdQuartile", "complete",
    "progress", "closeLinear", "creativeView", "acceptInvitation",
    "adExpand", "adCollapse", "minimize", "close",
    "overlayViewDuration", "otherAdInteraction"
  ], do: true
  def valid_tracking_event?(_), do: false

  @doc """
  Validates verification tracking event names.
  """
  def valid_verification_event?(event) when event == "verificationNotExecuted", do: true
  def valid_verification_event?(_), do: false
end