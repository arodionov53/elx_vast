# Spec Delta

## Purpose

Controls which VAST specification versions the library accepts and ensures each document is validated according to the rules of its declared version.

## ADDED Requirements

### Requirement: Accept VAST 4.1, 4.2, and 4.3 version strings
The system SHALL accept VAST documents declaring version 4.1, 4.2, or 4.3 (including patch variants such as 4.1.0, 4.2.1, 4.3.0). The system SHALL reject documents declaring any version outside this set.

#### Scenario: VAST 4.3 document accepted
- **WHEN** a VAST XML document has `version="4.3"`
- **THEN** the system returns `{:ok, result}` with `result.version == "4.3"` and `result.valid == true`

#### Scenario: VAST 4.2 document accepted
- **WHEN** a VAST XML document has `version="4.2"`
- **THEN** the system returns `{:ok, result}` with `result.version == "4.2"` and `result.valid == true`

#### Scenario: VAST 4.1 document still accepted
- **WHEN** a VAST XML document has `version="4.1"`
- **THEN** the system returns `{:ok, result}` with `result.version == "4.1"` and `result.valid == true`

#### Scenario: VAST 4.3 patch version accepted
- **WHEN** a VAST XML document has `version="4.3.1"`
- **THEN** the system returns `{:ok, result}` with the declared version preserved

#### Scenario: Unsupported version rejected
- **WHEN** a VAST XML document has `version="3.0"` or `version="5.0"`
- **THEN** the system returns `{:error, message}` where the message indicates the version is invalid and lists accepted major versions

### Requirement: Version-aware error messages
The system SHALL include the full range of supported versions (4.1, 4.2, 4.3) in error messages when a document declares an unsupported version. Error messages SHALL NOT hardcode a single version.

#### Scenario: Error message lists supported versions
- **WHEN** a document with `version="2.0"` is validated
- **THEN** the error message mentions versions 4.1, 4.2, and 4.3 as supported

### Requirement: Backward-compatible result structure
The system SHALL return the same result map shape (`version`, `ads`, `errors`, `valid`) for all accepted versions. No fields SHALL be added or removed based on the declared version.

#### Scenario: Result shape identical across versions
- **WHEN** a valid VAST 4.3 document and a valid VAST 4.1 document are each validated
- **THEN** both result maps contain exactly the keys `version`, `ads`, `errors`, and `valid`
