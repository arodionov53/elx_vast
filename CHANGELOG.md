# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-04-24

### Added
- Initial release of ElxVAST
- Complete VAST 4.1 XML validation according to IAB specification
- Main validation functions: `ElxVast.validate/1` and `ElxVast.validate_file/1`
- Comprehensive data type validation (`ElxVast.Types`)
- Complex validation logic (`ElxVast.Validators`) 
- Element-specific validation (`ElxVast.Elements`)
- Support for InLine and Wrapper ad types
- Linear, NonLinear, and Companion creative validation
- MediaFile validation with all VAST 4.1 attributes
- Tracking event validation with proper offset handling
- Impression and error URL validation
- AdVerifications support
- Pricing model validation
- Category and survey validation
- Icon and extension support
- 35+ comprehensive test cases covering all functionality
- Usage examples and documentation
- MIT license
- Production-ready error handling and reporting

### Features
- ✅ Complete VAST 4.1 schema compliance
- ✅ Detailed error messages with specific validation failures
- ✅ Type-safe validation for all data formats
- ✅ Time format validation (hh:mm:ss and hh:mm:ss.mmm)
- ✅ Offset format validation (time and percentage)
- ✅ URI validation for all URL fields
- ✅ MIME type validation for media files
- ✅ Integer and decimal validation with proper ranges
- ✅ Enumerated value validation (delivery methods, event types, etc.)
- ✅ Performance-optimized XML parsing with SweetXml

[Unreleased]: https://github.com/arodionov53/elx_vast/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/arodionov53/elx_vast/releases/tag/v0.1.0