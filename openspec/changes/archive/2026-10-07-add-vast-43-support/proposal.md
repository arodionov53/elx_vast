# Proposal

## Why

ElxVast currently only validates VAST 4.1 documents. The IAB VAST specification has evolved through 4.2 and 4.3, introducing new elements (ClosedCaptionFiles, InteractiveCreativeFile), expanded verification tracking, and additional media file attributes. Adopting VAST 4.3 keeps the library relevant for ad-tech integrations that have moved beyond 4.1.

## What Changes

- **Version acceptance**: Accept VAST 4.2 and 4.3 documents in addition to 4.1. Validation rules are applied per the declared version — a 4.1 document is still validated against 4.1 rules.
- **New elements under Linear**: Validate `ClosedCaptionFiles` (with child `ClosedCaptionFile` elements) and `InteractiveCreativeFile` elements introduced in VAST 4.2/4.3.
- **Expanded tracking events**: Add new tracking event names defined in 4.2/4.3 (e.g., `interactiveStart`, `interactiveEnd`).
- **Expanded verification events**: Add verification tracking events beyond the current sole `verificationNotExecuted`.
- **Verification element attributes**: Validate `JavaScriptResource` attributes (`apiFramework`, `browserOptional`) and `ExecutableResource` attributes (`apiFramework`, `type`) that exist in fixtures but are currently unchecked.
- **MediaFile attribute additions**: Support new optional MediaFile attributes introduced in 4.2/4.3 (e.g., `mediaType`).
- **Updated error messages and documentation**: Replace hardcoded "4.1" references with version-aware messaging.

## Capabilities

### New Capabilities
- `vast-version-support`: Version acceptance logic and version-aware validation dispatch — determines which VAST versions the library accepts and routes documents to the correct validation ruleset.
- `vast-43-elements`: Validation of VAST 4.2/4.3-specific elements (ClosedCaptionFiles, InteractiveCreativeFile) and expanded enumerations (tracking events, verification events, media file attributes).

### Modified Capabilities
<!-- No existing specs to modify — this is a greenfield OpenSpec setup. -->

## Impact

- **Code**: All four library modules change — `elx_vast.ex` (version messaging), `validators.ex` (version gate + new attribute validators), `elements.ex` (new element validators), `types.ex` (expanded enumerations).
- **Tests**: New fixtures for 4.2/4.3 documents, new test cases for every added element and enumeration, updated version-acceptance tests.
- **API**: `ElxVast.validate/1` return map is unchanged (version, ads, errors, valid). The only externally visible change is accepting a wider range of version strings and validating the new elements/attributes within those documents.
- **Dependencies**: No new dependencies required.
