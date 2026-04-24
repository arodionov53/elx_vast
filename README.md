# ElxVAST - VAST 4.1 XML Validator for Elixir

A comprehensive Elixir library for validating VAST (Video Ad Serving Template) 4.1 XML documents according to the IAB VAST specification.

## Features

- **Complete VAST 4.1 Support**: Validates all VAST 4.1 elements and attributes
- **Schema-Based Validation**: Built from the official VAST 4.1 XSD schema
- **Detailed Error Messages**: Provides specific error information for failed validations
- **Type Safety**: Comprehensive data type validation (URIs, time formats, MIME types, etc.)
- **Element Validation**: Validates complex element relationships and requirements
- **Performance Optimized**: Uses SweetXml for efficient XML parsing

## Installation

Add `elx_vast` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elx_vast, "~> 0.1.0"},
    {:sweet_xml, "~> 0.7.4"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Usage

### Basic Validation

```elixir
# Validate VAST XML string
vast_xml = """
<?xml version="1.0" encoding="UTF-8"?>
<VAST version="4.1" xmlns="http://www.iab.com/VAST">
  <Ad id="12345">
    <InLine>
      <AdSystem version="1.0">Example Ad Server</AdSystem>
      <AdServingId>abc-123-def</AdServingId>
      <AdTitle>Sample Video Ad</AdTitle>
      <Impression><![CDATA[https://example.com/impression]]></Impression>
      <Creatives>
        <Creative>
          <UniversalAdId idRegistry="Ad-ID">sample-ad-id</UniversalAdId>
          <Linear>
            <Duration>00:00:30</Duration>
            <MediaFiles>
              <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                <![CDATA[https://example.com/video.mp4]]>
              </MediaFile>
            </MediaFiles>
          </Linear>
        </Creative>
      </Creatives>
    </InLine>
  </Ad>
</VAST>
"""

case ElxVast.validate(vast_xml) do
  {:ok, result} ->
    IO.puts("Valid VAST document!")
    IO.puts("Version: #{result.version}")
    IO.puts("Number of ads: #{length(result.ads)}")

  {:error, reason} ->
    IO.puts("Invalid VAST: #{reason}")
end
```

### File Validation

```elixir
# Validate VAST XML file
case ElxVast.validate_file("path/to/vast.xml") do
  {:ok, result} -> IO.puts("Valid VAST file: #{result.version}")
  {:error, reason} -> IO.puts("Invalid VAST file: #{reason}")
end
```

### Error-Only VAST Documents

```elixir
# VAST documents can contain only error elements when no ads are available
error_vast = """
<?xml version="1.0" encoding="UTF-8"?>
<VAST version="4.1" xmlns="http://www.iab.com/VAST">
  <Error><![CDATA[https://example.com/error?reason=no_fill]]></Error>
</VAST>
"""

{:ok, result} = ElxVast.validate(error_vast)
# This is valid - indicates no ads available
```

## Validation Rules

The validator enforces all VAST 4.1 specification rules including:

### Document Structure
- Root `<VAST>` element with required version attribute
- Must contain either `<Ad>` elements OR `<Error>` elements
- Proper XML namespace declaration

### Ad Elements
- Each `<Ad>` must contain exactly one `<InLine>` or `<Wrapper>`
- Required elements: `AdSystem`, `Impression`
- InLine ads require: `AdServingId`, `AdTitle`, `Creatives`
- Wrapper ads require: `VASTAdTagURI`

### Creative Elements
- InLine creatives require `UniversalAdId`
- Linear ads require `Duration` and `MediaFiles`
- MediaFile elements require: `delivery`, `type`, `width`, `height`

### Data Type Validation
- Time formats: `hh:mm:ss` or `hh:mm:ss.mmm`
- Offset formats: time or percentage (e.g., "25%")
- URI validation for all URL fields
- MIME type validation for media files
- Integer validation for dimensions and bitrates
- Enumerated values (delivery methods, event types, etc.)

### Tracking Events
- Valid event names: start, firstQuartile, midpoint, thirdQuartile, complete, etc.
- Progress events require offset attribute
- Proper URI format for tracking URLs

## API Reference

### Main Functions

#### `ElxVast.validate(xml_string)`
Validates a VAST XML string.

**Parameters:**
- `xml_string` - Binary string containing VAST XML

**Returns:**
- `{:ok, result}` - On successful validation
- `{:error, reason}` - On validation failure

#### `ElxVast.validate_file(file_path)`
Validates a VAST XML file.

**Parameters:**
- `file_path` - String path to XML file

**Returns:**
- `{:ok, result}` - On successful validation
- `{:error, reason}` - On validation failure or file read error

### Result Structure

Successful validation returns:

```elixir
%{
  version: "4.1",           # VAST version
  ads: [ad_elements],       # List of parsed Ad elements
  errors: [error_elements], # List of parsed Error elements  
  valid: true               # Validation status
}
```

### Type Validation Functions

The `ElxVast.Types` module provides individual type validators:

- `valid_time?/1` - Time format validation
- `valid_offset?/1` - Offset format validation  
- `valid_uri?/1` - URI format validation
- `valid_integer?/1` - Integer validation
- `valid_mime_type?/1` - MIME type validation
- `valid_currency?/1` - Currency code validation
- And many more...

## Examples

See the `examples/` directory for comprehensive usage examples:

```bash
# Run the usage examples
elixir examples/usage_example.exs
```

## Testing

Run the test suite:

```bash
mix test
```

Run with coverage:

```bash
mix test --cover
```

## VAST 4.1 Compliance

This validator implements the complete VAST 4.1 specification including:

- ✅ Root VAST element validation
- ✅ Ad element validation (InLine and Wrapper)
- ✅ Creative element validation (Linear, NonLinear, Companion)
- ✅ MediaFile validation with all attributes
- ✅ Tracking event validation
- ✅ Impression and error URL validation
- ✅ AdVerifications support
- ✅ Pricing model validation
- ✅ Category and survey validation
- ✅ Icon and extension support
- ✅ Complete data type validation

## Architecture

The validator is organized into several modules:

- **`ElxVast`** - Main validation entry point
- **`ElxVast.Types`** - Data type validation functions
- **`ElxVast.Validators`** - Complex validation logic
- **`ElxVast.Elements`** - Element-specific validation

This modular design makes the code maintainable and allows for easy extension.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## References

- [IAB VAST 4.1 Specification](https://iabtechlab.com/standards/vast/)
- [VAST 4.1 XSD Schema](https://github.com/InteractiveAdvertisingBureau/VAST/blob/main/vast4_1/vast_4.1.xsd)

## Project History

ElxVAST is a comprehensive VAST validator built from the official VAST 4.1 XSD schema. It provides production-ready validation with detailed error reporting for all aspects of VAST 4.1 compliance.

