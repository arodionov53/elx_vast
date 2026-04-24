#!/usr/bin/env elixir

# VAST Validator Usage Examples
# Run this script with: elixir examples/usage_example.exs

Mix.install([
  {:sweet_xml, "~> 0.7.4"}
])

# Load the validator modules
Code.require_file("lib/elx_vast.ex")
Code.require_file("lib/elx_vast/types.ex")
Code.require_file("lib/elx_vast/validators.ex")
Code.require_file("lib/elx_vast/elements.ex")

# Example 1: Valid VAST document
IO.puts("=== Example 1: Valid VAST Document ===")

valid_vast = """
<?xml version="1.0" encoding="UTF-8"?>
<VAST version="4.1" xmlns="http://www.iab.com/VAST">
  <Ad id="12345">
    <InLine>
      <AdSystem version="1.0">Example Ad Server</AdSystem>
      <AdServingId>abc-123-def</AdServingId>
      <AdTitle>Sample Video Ad</AdTitle>
      <Impression><![CDATA[https://example.com/impression?id=123]]></Impression>
      <Creatives>
        <Creative>
          <UniversalAdId idRegistry="Ad-ID">sample-ad-id</UniversalAdId>
          <Linear>
            <Duration>00:00:30</Duration>
            <MediaFiles>
              <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                <![CDATA[https://example.com/videos/sample.mp4]]>
              </MediaFile>
            </MediaFiles>
          </Linear>
        </Creative>
      </Creatives>
    </InLine>
  </Ad>
</VAST>
"""

case ElxVast.validate(valid_vast) do
  {:ok, result} ->
    IO.puts("✅ Validation successful!")
    IO.puts("Version: #{result.version}")
    IO.puts("Valid: #{result.valid}")
    IO.puts("Number of ads: #{length(result.ads)}")
    IO.puts("Number of errors: #{length(result.errors)}")

  {:error, reason} ->
    IO.puts("❌ Validation failed: #{reason}")
end

IO.puts("\n")

# Example 2: VAST with Error element (no ads available)
IO.puts("=== Example 2: VAST with Error Element ===")

error_vast = """
<?xml version="1.0" encoding="UTF-8"?>
<VAST version="4.1" xmlns="http://www.iab.com/VAST">
  <Error><![CDATA[https://example.com/error?reason=no_fill]]></Error>
</VAST>
"""

case ElxVast.validate(error_vast) do
  {:ok, result} ->
    IO.puts("✅ Error VAST validation successful!")
    IO.puts("Version: #{result.version}")
    IO.puts("This indicates no ads are available")

  {:error, reason} ->
    IO.puts("❌ Validation failed: #{reason}")
end

IO.puts("\n")

# Example 3: Invalid VAST (missing version)
IO.puts("=== Example 3: Invalid VAST Document ===")

invalid_vast = """
<?xml version="1.0" encoding="UTF-8"?>
<VAST xmlns="http://www.iab.com/VAST">
  <Ad id="12345">
    <InLine>
      <AdSystem>Test</AdSystem>
    </InLine>
  </Ad>
</VAST>
"""

case ElxVast.validate(invalid_vast) do
  {:ok, result} ->
    IO.puts("✅ Validation successful: #{inspect(result)}")

  {:error, reason} ->
    IO.puts("❌ Expected validation failure: #{reason}")
end

IO.puts("\n")

# Example 4: Complex VAST with wrapper
IO.puts("=== Example 4: VAST Wrapper Document ===")

wrapper_vast = """
<?xml version="1.0" encoding="UTF-8"?>
<VAST version="4.1" xmlns="http://www.iab.com/VAST">
  <Ad id="wrapper-ad">
    <Wrapper followAdditionalWrappers="true" allowMultipleAds="false">
      <AdSystem version="2.0">Wrapper System</AdSystem>
      <Impression><![CDATA[https://wrapper.example.com/impression]]></Impression>
      <VASTAdTagURI><![CDATA[https://adserver.example.com/vast?campaign=123]]></VASTAdTagURI>
      <Creatives>
        <Creative>
          <Linear>
            <TrackingEvents>
              <Tracking event="start"><![CDATA[https://wrapper.example.com/track/start]]></Tracking>
              <Tracking event="complete"><![CDATA[https://wrapper.example.com/track/complete]]></Tracking>
            </TrackingEvents>
          </Linear>
        </Creative>
      </Creatives>
    </Wrapper>
  </Ad>
</VAST>
"""

case ElxVast.validate(wrapper_vast) do
  {:ok, result} ->
    IO.puts("✅ Wrapper VAST validation successful!")
    IO.puts("Version: #{result.version}")

  {:error, reason} ->
    IO.puts("❌ Validation failed: #{reason}")
end

IO.puts("\n")

# Example 5: Test individual type validators
IO.puts("=== Example 5: Individual Type Validation ===")

alias ElxVast.Types

IO.puts("Time format validation:")
IO.puts("  '00:30:00' -> #{Types.valid_time?("00:30:00")}")
IO.puts("  '25:30:00' -> #{Types.valid_time?("25:30:00")}")

IO.puts("Offset format validation:")
IO.puts("  '50%' -> #{Types.valid_offset?("50%")}")
IO.puts("  '00:00:15' -> #{Types.valid_offset?("00:00:15")}")
IO.puts("  '150%' -> #{Types.valid_offset?("150%")}")

IO.puts("URI validation:")
IO.puts("  'https://example.com' -> #{Types.valid_uri?("https://example.com")}")
IO.puts("  'not-a-uri' -> #{Types.valid_uri?("not-a-uri")}")

IO.puts("MIME type validation:")
IO.puts("  'video/mp4' -> #{Types.valid_mime_type?("video/mp4")}")
IO.puts("  'invalid-mime' -> #{Types.valid_mime_type?("invalid-mime")}")

IO.puts("\n=== Validation Complete ===")