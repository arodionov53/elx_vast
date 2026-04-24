defmodule ElxVast.Elements do
  @moduledoc """
  Element-specific validation functions for VAST 4.1 elements.

  This module contains validation logic for individual VAST elements
  such as Ad, InLine, Wrapper, Creative, etc.
  """

  import SweetXml
  alias ElxVast.{Types, Validators}

  @doc """
  Validates an Ad element.
  """
  def validate_ad(ad_element, index) do
    with :ok <- validate_ad_attributes(ad_element),
         :ok <- validate_ad_content(ad_element, index) do
      :ok
    end
  end

  defp validate_ad_attributes(ad_element) do
    with :ok <- Validators.validate_optional_attribute(ad_element, "sequence", &Types.valid_integer?/1),
         :ok <- Validators.validate_optional_attribute(ad_element, "conditionalAd", &Types.valid_boolean?/1),
         :ok <- Validators.validate_optional_attribute(ad_element, "adType", &Types.valid_ad_type?/1) do
      :ok
    end
  end

  defp validate_ad_content(ad_element, _index) do
    inline_elements = xpath(ad_element, ~x"./InLine"l)
    wrapper_elements = xpath(ad_element, ~x"./Wrapper"l)

    case {length(inline_elements), length(wrapper_elements)} do
      {0, 0} ->
        {:error, "Ad must contain either InLine or Wrapper element"}

      {1, 0} ->
        validate_inline(hd(inline_elements))

      {0, 1} ->
        validate_wrapper(hd(wrapper_elements))

      _ ->
        {:error, "Ad must contain exactly one InLine or Wrapper element"}
    end
  end

  @doc """
  Validates an InLine element.
  """
  def validate_inline(inline_element) do
    with :ok <- validate_inline_required_elements(inline_element),
         :ok <- validate_inline_optional_elements(inline_element),
         :ok <- validate_creatives(inline_element, :inline) do
      :ok
    end
  end

  defp validate_inline_required_elements(inline_element) do
    with {:ok, _} <- Validators.validate_required_content(inline_element, ~x"./AdServingId/text()"s, "AdServingId"),
         {:ok, _} <- Validators.validate_required_content(inline_element, ~x"./AdTitle/text()"s, "AdTitle"),
         :ok <- validate_impressions(inline_element) do
      :ok
    end
  end

  defp validate_inline_optional_elements(inline_element) do
    with :ok <- validate_optional_pricing(inline_element),
         :ok <- validate_optional_categories(inline_element),
         :ok <- validate_optional_survey(inline_element),
         :ok <- validate_optional_expires(inline_element),
         :ok <- validate_optional_ad_verifications(inline_element) do
      :ok
    end
  end

  @doc """
  Validates a Wrapper element.
  """
  def validate_wrapper(wrapper_element) do
    with :ok <- validate_wrapper_required_elements(wrapper_element),
         :ok <- validate_wrapper_attributes(wrapper_element),
         :ok <- validate_impressions(wrapper_element),
         :ok <- validate_creatives(wrapper_element, :wrapper) do
      :ok
    end
  end

  defp validate_wrapper_required_elements(wrapper_element) do
    Validators.validate_required_content(wrapper_element, ~x"./VASTAdTagURI/text()"s, "VASTAdTagURI")
    |> case do
      {:ok, uri} ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid VASTAdTagURI: #{uri}"}
        end

      error ->
        error
    end
  end

  defp validate_wrapper_attributes(wrapper_element) do
    with :ok <- Validators.validate_optional_attribute(wrapper_element, "followAdditionalWrappers", &Types.valid_boolean?/1),
         :ok <- Validators.validate_optional_attribute(wrapper_element, "allowMultipleAds", &Types.valid_boolean?/1),
         :ok <- Validators.validate_optional_attribute(wrapper_element, "fallbackOnNoAd", &Types.valid_boolean?/1) do
      :ok
    end
  end

  defp validate_impressions(element) do
    impressions = xpath(element, ~x"./Impression"l)

    if length(impressions) == 0 do
      {:error, "At least one Impression element is required"}
    else
      impressions
      |> Enum.with_index()
      |> Enum.reduce_while(:ok, fn {impression, index}, :ok ->
        case validate_impression(impression, index) do
          :ok -> {:cont, :ok}
          error -> {:halt, error}
        end
      end)
    end
  end

  defp validate_impression(impression_element, _index) do
    case xpath(impression_element, ~x"./text()"s) do
      nil -> {:error, "Missing impression URI"}
      "" -> {:error, "Empty impression URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid impression URI: #{uri}"}
        end
    end
  end

  defp validate_optional_pricing(element) do
    case xpath(element, ~x"./Pricing") do
      nil -> :ok
      pricing -> Validators.validate_pricing(pricing)
    end
  end

  defp validate_optional_categories(element) do
    categories = xpath(element, ~x"./Category"l)

    categories
    |> Enum.reduce_while(:ok, fn category, :ok ->
      case validate_category(category) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_category(category_element) do
    Validators.validate_required_attribute(category_element, "authority")
    |> case do
      {:ok, authority} ->
        if Types.valid_uri?(authority) do
          :ok
        else
          {:error, "Invalid category authority URI: #{authority}"}
        end

      error ->
        error
    end
  end

  defp validate_optional_survey(element) do
    case xpath(element, ~x"./Survey") do
      nil -> :ok
      survey -> validate_survey(survey)
    end
  end

  defp validate_survey(survey_element) do
    case xpath(survey_element, ~x"./text()"s) do
      nil -> {:error, "Missing survey URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid survey URI: #{uri}"}
        end
    end
  end

  defp validate_optional_expires(element) do
    case xpath(element, ~x"./Expires/text()"s) do
      nil -> :ok
      "" -> :ok  # Empty expires element is allowed
      expires ->
        if Types.valid_positive_integer?(expires) do
          :ok
        else
          {:error, "Invalid expires value: #{expires}"}
        end
    end
  end

  defp validate_optional_ad_verifications(element) do
    case xpath(element, ~x"./AdVerifications") do
      nil -> :ok
      ad_verifications -> validate_ad_verifications(ad_verifications)
    end
  end

  defp validate_ad_verifications(ad_verifications_element) do
    verifications = xpath(ad_verifications_element, ~x"./Verification"l)

    verifications
    |> Enum.with_index()
    |> Enum.reduce_while(:ok, fn {verification, index}, :ok ->
      case validate_verification(verification, index) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_verification(verification_element, _index) do
    # Verify that at least one resource is provided
    js_resources = xpath(verification_element, ~x"./JavaScriptResource"l)
    exec_resources = xpath(verification_element, ~x"./ExecutableResource"l)

    if length(js_resources) == 0 and length(exec_resources) == 0 do
      {:error, "Verification must contain at least one JavaScriptResource or ExecutableResource"}
    else
      with :ok <- validate_verification_resources(js_resources, exec_resources),
           :ok <- validate_verification_tracking_events(verification_element) do
        :ok
      end
    end
  end

  defp validate_verification_resources(js_resources, exec_resources) do
    with :ok <- validate_js_resources(js_resources),
         :ok <- validate_exec_resources(exec_resources) do
      :ok
    end
  end

  defp validate_js_resources(js_resources) do
    js_resources
    |> Enum.reduce_while(:ok, fn resource, :ok ->
      case validate_js_resource(resource) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_js_resource(js_resource) do
    case xpath(js_resource, ~x"./text()"s) do
      nil -> {:error, "Missing JavaScriptResource URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid JavaScriptResource URI: #{uri}"}
        end
    end
  end

  defp validate_exec_resources(exec_resources) do
    exec_resources
    |> Enum.reduce_while(:ok, fn resource, :ok ->
      case validate_exec_resource(resource) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_exec_resource(exec_resource) do
    case xpath(exec_resource, ~x"./text()"s) do
      nil -> {:error, "Missing ExecutableResource URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid ExecutableResource URI: #{uri}"}
        end
    end
  end

  defp validate_verification_tracking_events(verification_element) do
    case xpath(verification_element, ~x"./TrackingEvents") do
      nil -> :ok
      tracking_events -> validate_verification_tracking_events_element(tracking_events)
    end
  end

  defp validate_verification_tracking_events_element(tracking_events_element) do
    tracking_elements = xpath(tracking_events_element, ~x"./Tracking"l)

    tracking_elements
    |> Enum.reduce_while(:ok, fn tracking, :ok ->
      case validate_verification_tracking_event(tracking) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_verification_tracking_event(tracking_element) do
    with {:ok, event_name} <- Validators.validate_required_attribute(tracking_element, "event"),
         :ok <- validate_verification_event_name(event_name),
         {:ok, _uri} <- validate_tracking_uri(tracking_element) do
      :ok
    end
  end

  defp validate_verification_event_name(event_name) do
    if Types.valid_verification_event?(event_name) do
      :ok
    else
      {:error, "Invalid verification tracking event: #{event_name}"}
    end
  end

  defp validate_tracking_uri(tracking_element) do
    case xpath(tracking_element, ~x"./text()"s) do
      nil -> {:error, "Missing tracking URI"}
      uri ->
        if Types.valid_uri?(uri) do
          {:ok, uri}
        else
          {:error, "Invalid tracking URI: #{uri}"}
        end
    end
  end

  defp validate_creatives(element, ad_type) do
    case xpath(element, ~x"./Creatives") do
      nil ->
        if ad_type == :inline do
          {:error, "InLine ad must contain Creatives element"}
        else
          :ok
        end

      creatives_element ->
        validate_creatives_element(creatives_element, ad_type)
    end
  end

  defp validate_creatives_element(creatives_element, ad_type) do
    creatives = xpath(creatives_element, ~x"./Creative"l)

    if length(creatives) == 0 and ad_type == :inline do
      {:error, "Creatives element must contain at least one Creative"}
    else
      creatives
      |> Enum.with_index()
      |> Enum.reduce_while(:ok, fn {creative, index}, :ok ->
        case validate_creative(creative, index, ad_type) do
          :ok -> {:cont, :ok}
          error -> {:halt, error}
        end
      end)
    end
  end

  defp validate_creative(creative_element, _index, ad_type) do
    # Check that creative contains at least one of: Linear, NonLinearAds, CompanionAds
    linear = xpath(creative_element, ~x"./Linear")
    nonlinear_ads = xpath(creative_element, ~x"./NonLinearAds")
    companion_ads = xpath(creative_element, ~x"./CompanionAds")

    if is_nil(linear) and is_nil(nonlinear_ads) and is_nil(companion_ads) do
      {:error, "Creative must contain at least one of: Linear, NonLinearAds, or CompanionAds"}
    else
      with :ok <- validate_creative_linear(linear, ad_type),
           :ok <- validate_creative_nonlinear(nonlinear_ads),
           :ok <- validate_creative_companions(companion_ads),
           :ok <- validate_universal_ad_id(creative_element, ad_type) do
        :ok
      end
    end
  end

  defp validate_creative_linear(nil, _ad_type), do: :ok

  defp validate_creative_linear(linear_element, ad_type) do
    case ad_type do
      :inline -> validate_linear_inline(linear_element)
      :wrapper -> validate_linear_wrapper(linear_element)
    end
  end

  defp validate_linear_inline(linear_element) do
    with {:ok, _} <- validate_duration_element(linear_element),
         :ok <- validate_media_files(linear_element),
         :ok <- validate_linear_tracking_events(linear_element),
         :ok <- validate_linear_video_clicks(linear_element) do
      :ok
    end
  end

  defp validate_linear_wrapper(linear_element) do
    with :ok <- validate_linear_tracking_events(linear_element),
         :ok <- validate_linear_video_clicks_wrapper(linear_element) do
      :ok
    end
  end

  defp validate_duration_element(linear_element) do
    Validators.validate_required_content(linear_element, ~x"./Duration/text()"s, "Duration")
    |> case do
      {:ok, duration} -> Validators.validate_duration(duration)
      error -> error
    end
  end

  defp validate_media_files(linear_element) do
    case xpath(linear_element, ~x"./MediaFiles") do
      nil -> {:error, "Linear creative must contain MediaFiles element"}
      media_files_element -> validate_media_files_element(media_files_element)
    end
  end

  defp validate_media_files_element(media_files_element) do
    media_files = xpath(media_files_element, ~x"./MediaFile"l)

    if length(media_files) == 0 do
      {:error, "MediaFiles must contain at least one MediaFile"}
    else
      media_files
      |> Enum.with_index()
      |> Enum.reduce_while(:ok, fn {media_file, index}, :ok ->
        case validate_media_file(media_file, index) do
          :ok -> {:cont, :ok}
          error -> {:halt, error}
        end
      end)
    end
  end

  defp validate_media_file(media_file, _index) do
    with {:ok, _uri} <- validate_media_file_uri(media_file),
         :ok <- Validators.validate_media_file_attributes(media_file) do
      :ok
    end
  end

  defp validate_media_file_uri(media_file) do
    case xpath(media_file, ~x"./text()"s) do
      nil -> {:error, "Missing MediaFile URI"}
      uri ->
        if Types.valid_uri?(uri) do
          {:ok, uri}
        else
          {:error, "Invalid MediaFile URI: #{uri}"}
        end
    end
  end

  defp validate_linear_tracking_events(linear_element) do
    case xpath(linear_element, ~x"./TrackingEvents") do
      nil -> :ok
      tracking_events -> validate_tracking_events_element(tracking_events)
    end
  end

  defp validate_tracking_events_element(tracking_events_element) do
    tracking_elements = xpath(tracking_events_element, ~x"./Tracking"l)

    tracking_elements
    |> Enum.reduce_while(:ok, fn tracking, :ok ->
      case Validators.validate_tracking_event(tracking) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_linear_video_clicks(linear_element) do
    case xpath(linear_element, ~x"./VideoClicks") do
      nil -> :ok
      video_clicks -> validate_video_clicks_inline(video_clicks)
    end
  end

  defp validate_linear_video_clicks_wrapper(linear_element) do
    case xpath(linear_element, ~x"./VideoClicks") do
      nil -> :ok
      video_clicks -> validate_video_clicks_base(video_clicks)
    end
  end

  defp validate_video_clicks_inline(video_clicks_element) do
    with :ok <- validate_video_clicks_base(video_clicks_element),
         :ok <- validate_click_through(video_clicks_element) do
      :ok
    end
  end

  defp validate_video_clicks_base(video_clicks_element) do
    click_tracking_elements = xpath(video_clicks_element, ~x"./ClickTracking"l)
    custom_click_elements = xpath(video_clicks_element, ~x"./CustomClick"l)

    with :ok <- validate_click_tracking_elements(click_tracking_elements),
         :ok <- validate_custom_click_elements(custom_click_elements) do
      :ok
    end
  end

  defp validate_click_through(video_clicks_element) do
    case xpath(video_clicks_element, ~x"./ClickThrough") do
      nil -> :ok
      click_through -> validate_click_through_element(click_through)
    end
  end

  defp validate_click_through_element(click_through_element) do
    case xpath(click_through_element, ~x"./text()"s) do
      nil -> {:error, "Missing ClickThrough URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid ClickThrough URI: #{uri}"}
        end
    end
  end

  defp validate_click_tracking_elements(click_tracking_elements) do
    click_tracking_elements
    |> Enum.reduce_while(:ok, fn click_tracking, :ok ->
      case validate_click_tracking_element(click_tracking) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_click_tracking_element(click_tracking_element) do
    case xpath(click_tracking_element, ~x"./text()"s) do
      nil -> {:error, "Missing ClickTracking URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid ClickTracking URI: #{uri}"}
        end
    end
  end

  defp validate_custom_click_elements(custom_click_elements) do
    custom_click_elements
    |> Enum.reduce_while(:ok, fn custom_click, :ok ->
      case validate_custom_click_element(custom_click) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_custom_click_element(custom_click_element) do
    case xpath(custom_click_element, ~x"./text()"s) do
      nil -> {:error, "Missing CustomClick URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid CustomClick URI: #{uri}"}
        end
    end
  end

  defp validate_creative_nonlinear(nil), do: :ok
  defp validate_creative_nonlinear(_nonlinear_ads_element) do
    # Simplified validation for NonLinearAds - you can expand this
    :ok
  end

  defp validate_creative_companions(nil), do: :ok
  defp validate_creative_companions(_companion_ads_element) do
    # Simplified validation for CompanionAds - you can expand this
    :ok
  end

  defp validate_universal_ad_id(creative_element, ad_type) do
    case xpath(creative_element, ~x"./UniversalAdId") do
      nil ->
        if ad_type == :inline do
          {:error, "InLine Creative must contain UniversalAdId element"}
        else
          :ok
        end

      universal_ad_id ->
        validate_universal_ad_id_element(universal_ad_id)
    end
  end

  defp validate_universal_ad_id_element(universal_ad_id_element) do
    with {:ok, _} <- Validators.validate_required_attribute(universal_ad_id_element, "idRegistry"),
         {:ok, _} <- Validators.validate_required_content(universal_ad_id_element, ~x"./text()"s, "UniversalAdId value") do
      :ok
    end
  end

  @doc """
  Validates an Error element.
  """
  def validate_error(error_element, _index) do
    case xpath(error_element, ~x"./text()"s) do
      nil -> {:error, "Missing error URI"}
      uri ->
        if Types.valid_uri?(uri) do
          :ok
        else
          {:error, "Invalid error URI: #{uri}"}
        end
    end
  end
end