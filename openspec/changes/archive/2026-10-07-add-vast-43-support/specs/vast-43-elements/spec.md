# Spec Delta

## Purpose

Validates VAST 4.2/4.3-specific XML elements, attributes, and enumerations that extend the base 4.1 validation already present in the library.

## ADDED Requirements

### Requirement: Validate ClosedCaptionFiles element
The system SHALL validate `ClosedCaptionFiles` as an optional element under `Linear`. When present, it MUST contain at least one `ClosedCaptionFile` child. Each `ClosedCaptionFile` MUST have a `language` attribute (non-empty string) and a `type` attribute (valid MIME type), and MUST contain a URI as text content.

#### Scenario: Valid ClosedCaptionFiles accepted
- **WHEN** a VAST 4.3 Linear element contains a `ClosedCaptionFiles` element with one `ClosedCaptionFile` child having `language="en"`, `type="text/vtt"`, and a valid URI as content
- **THEN** validation succeeds

#### Scenario: ClosedCaptionFile missing language attribute
- **WHEN** a `ClosedCaptionFile` element omits the `language` attribute
- **THEN** validation fails with an error indicating the missing required attribute

#### Scenario: Empty ClosedCaptionFiles rejected
- **WHEN** a `ClosedCaptionFiles` element is present but contains no `ClosedCaptionFile` children
- **THEN** validation fails with an error indicating at least one child is required

### Requirement: Validate InteractiveCreativeFile element
The system SHALL validate `InteractiveCreativeFile` as an optional element under `Linear`. When present, it MUST contain a URI as text content and MUST have a `type` attribute (valid MIME type). The optional `apiFramework` attribute SHALL be validated as a non-empty string when present.

#### Scenario: Valid InteractiveCreativeFile accepted
- **WHEN** a Linear element contains an `InteractiveCreativeFile` with `type="text/html"` and a valid URI
- **THEN** validation succeeds

#### Scenario: InteractiveCreativeFile missing type attribute
- **WHEN** an `InteractiveCreativeFile` element omits the `type` attribute
- **THEN** validation fails with an error indicating the missing required attribute

### Requirement: Expanded tracking event names
The system SHALL accept all VAST 4.1 tracking events plus the following events introduced in 4.2/4.3: `interactiveStart`, `interactiveEnd`. Unrecognized event names SHALL cause a validation error.

#### Scenario: interactiveStart event accepted
- **WHEN** a TrackingEvents element contains a Tracking element with `event="interactiveStart"` and a valid URI
- **THEN** validation succeeds

#### Scenario: Unknown event rejected
- **WHEN** a Tracking element has `event="notARealEvent"`
- **THEN** validation fails with an error indicating an invalid tracking event name

### Requirement: Expanded verification tracking events
The system SHALL accept `verificationNotExecuted` plus additional verification-specific events defined in 4.2/4.3. At minimum, `verificationNotExecuted` SHALL remain valid.

#### Scenario: verificationNotExecuted still accepted
- **WHEN** a Verification TrackingEvents element contains a Tracking with `event="verificationNotExecuted"`
- **THEN** validation succeeds

### Requirement: Validate JavaScriptResource attributes
The system SHALL validate `apiFramework` as a required attribute on `JavaScriptResource` (non-empty string). The optional `browserOptional` attribute SHALL be validated as a boolean when present.

#### Scenario: JavaScriptResource with valid attributes
- **WHEN** a `JavaScriptResource` has `apiFramework="omid"`, `browserOptional="true"`, and a valid URI as content
- **THEN** validation succeeds

#### Scenario: JavaScriptResource missing apiFramework
- **WHEN** a `JavaScriptResource` omits the `apiFramework` attribute
- **THEN** validation fails with an error indicating the missing required attribute

### Requirement: Validate ExecutableResource attributes
The system SHALL validate `apiFramework` as a required attribute on `ExecutableResource` (non-empty string). The optional `type` attribute SHALL be validated as a non-empty string when present.

#### Scenario: ExecutableResource with valid attributes
- **WHEN** an `ExecutableResource` has `apiFramework="omid"` and a valid URI as content
- **THEN** validation succeeds

#### Scenario: ExecutableResource missing apiFramework
- **WHEN** an `ExecutableResource` omits the `apiFramework` attribute
- **THEN** validation fails with an error indicating the missing required attribute

### Requirement: New optional MediaFile attribute mediaType
The system SHALL validate `mediaType` as an optional attribute on `MediaFile`. When present, it MUST be a non-empty string. Existing required and optional attributes SHALL continue to be validated as before.

#### Scenario: MediaFile with mediaType accepted
- **WHEN** a `MediaFile` element includes `mediaType="2D"` alongside existing required attributes
- **THEN** validation succeeds

#### Scenario: MediaFile without mediaType still valid
- **WHEN** a `MediaFile` element omits `mediaType` but has all existing required attributes
- **THEN** validation succeeds
