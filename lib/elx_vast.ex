defmodule ElxVast do
  @moduledoc """
  VAST 4.1 XML Validator based on IAB VAST specification.

  ElxVast provides validation functionality for VAST (Video Ad Serving Template)
  XML documents according to version 4.1 of the specification.

  ## Features

  - Complete VAST 4.1 schema validation
  - Detailed error reporting with specific validation failures
  - Type-safe validation for all data formats
  - Support for InLine and Wrapper ad types
  - Comprehensive tracking event validation
  - MediaFile and creative validation

  ## Usage

      # Validate VAST XML string
      {:ok, result} = ElxVast.validate(vast_xml_string)

      # Validate VAST XML file
      {:ok, result} = ElxVast.validate_file("path/to/vast.xml")

      # Handle validation errors
      {:error, reason} = ElxVast.validate(invalid_xml)
  """

  import SweetXml
  alias ElxVast.{Elements, Validators}

  @doc """
  Validates a VAST XML document.

  ## Parameters
    - xml_content: String containing the VAST XML document

  ## Returns
    - {:ok, validated_data} on success
    - {:error, reason} on validation failure

  ## Examples
      iex> {:ok, result} = ElxVast.validate("<VAST version='4.1'><Error>https://example.com/error</Error></VAST>"); result.version
      "4.1"

      iex> ElxVast.validate("<invalid>xml</invalid>")
      {:error, "Missing root VAST element"}
  """
  def validate(xml_content) when is_binary(xml_content) do
    try do
      xml_content
      |> parse_xml()
      |> validate_root_element()
      |> validate_structure()
    rescue
      error -> {:error, "XML parsing error: #{inspect(error)}"}
    catch
      :exit, reason -> {:error, "XML processing failed: #{inspect(reason)}"}
    end
  end

  def validate(_), do: {:error, "Input must be a binary string"}

  @doc """
  Validates a VAST XML file.

  ## Parameters
    - file_path: Path to the VAST XML file

  ## Returns
    - {:ok, validated_data} on success
    - {:error, reason} on validation failure
  """
  def validate_file(file_path) do
    case File.read(file_path) do
      {:ok, content} -> validate(content)
      {:error, reason} -> {:error, "File read error: #{inspect(reason)}"}
    end
  end

  # Private functions

  defp parse_xml(xml_content) do
    xml_content |> SweetXml.parse(namespace_conformant: true, quiet: true)
  end

  defp validate_root_element(xml_doc) do
    case xpath(xml_doc, ~x"//VAST") do
      nil ->
        {:error, "Missing root VAST element"}

      vast_element ->
        version = vast_element |> xpath(~x"./@version"s)

        cond do
          is_nil(version) or version == "" ->
            {:error, "Missing required version attribute"}

          not Validators.valid_version?(version) ->
            {:error, "Invalid version: #{version}. Expected version 4.1 or compatible"}

          true ->
            {:ok, {xml_doc, version}}
        end
    end
  end

  defp validate_structure({:ok, {xml_doc, version}}) do
    vast_content = analyze_vast_content(xml_doc)

    case vast_content do
      {:error, reason} ->
        {:error, reason}

      {:ok, content} ->
        with :ok <- validate_content_rules(content),
             :ok <- validate_ads(xml_doc, content.ads),
             :ok <- validate_errors(xml_doc, content.errors) do
          {:ok, %{
            version: version,
            ads: content.ads,
            errors: content.errors,
            valid: true
          }}
        end
    end
  end

  defp validate_structure({:error, reason}), do: {:error, reason}

  defp analyze_vast_content(xml_doc) do
    ads = xml_doc |> xpath(~x"//VAST/Ad"l)
    errors = xml_doc |> xpath(~x"//VAST/Error"l)

    ad_count = length(ads)
    error_count = length(errors)

    content = %{
      ads: ads,
      errors: errors,
      ad_count: ad_count,
      error_count: error_count
    }

    {:ok, content}
  end

  defp validate_content_rules(%{ad_count: 0, error_count: 0}) do
    {:error, "VAST document must contain either Ad elements or Error elements"}
  end

  defp validate_content_rules(_content), do: :ok

  defp validate_ads(_xml_doc, []), do: :ok

  defp validate_ads(_xml_doc, ads) do
    ads
    |> Enum.with_index()
    |> Enum.reduce_while(:ok, fn {ad, index}, :ok ->
      case Elements.validate_ad(ad, index) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, "Ad #{index + 1}: #{reason}"}}
      end
    end)
  end

  defp validate_errors(_xml_doc, []), do: :ok

  defp validate_errors(_xml_doc, errors) do
    errors
    |> Enum.with_index()
    |> Enum.reduce_while(:ok, fn {error, index}, :ok ->
      case Elements.validate_error(error, index) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, "Error #{index + 1}: #{reason}"}}
      end
    end)
  end
end
