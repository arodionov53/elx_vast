# Tasks

## 1. Version Gate and Error Messages

- [x] 1.1 Update `@valid_versions` in `lib/elx_vast/validators.ex` to `@supported_versions ["4.1", "4.2", "4.3"]` and rewrite `valid_version?/1` to accept any version string starting with one of these prefixes. Verify by running `mix test` — existing tests pass (the 3.0 rejection test still passes, and the 4.1 acceptance test still passes).
- [x] 1.2 Update the error message in `lib/elx_vast.ex` `validate_root_element/1` to list all supported versions instead of hardcoding "4.1". Update the module doc to reference VAST 4.1–4.3. Verify by running `mix test` — the invalid-version test assertions match the new message format.
- [x] 1.3 Add test fixtures in `test/test_helper.exs`: `valid_minimal_inline_vast_43/0` (version="4.3") and `valid_minimal_inline_vast_42/0` (version="4.2"), mirroring the existing `valid_minimal_inline_vast/0` structure. Add tests in `test/elx_vast_test.exs` for: 4.3 accepted, 4.2 accepted, 4.1 still accepted, patch version 4.3.1 accepted, version 5.0 rejected with updated message, result shape identical across versions. Verify by running `mix test` — all new tests pass.

## 2. Expanded Enumerations in Types

- [x] 2.1 Add `"interactiveStart"` and `"interactiveEnd"` to the `valid_tracking_event?/1` guard clause list in `lib/elx_vast/types.ex`. Add corresponding unit tests in `test/elx_vast/types_test.exs` asserting both new events return `true` and an unknown event returns `false`. Verify by running `mix test test/elx_vast/types_test.exs` — new and existing tracking event tests pass.
- [x] 2.2 Expand `valid_verification_event?/1` in `lib/elx_vast/types.ex` to accept verification-specific events beyond `"verificationNotExecuted"` (keep the existing value, no removals). Add unit tests in `test/elx_vast/types_test.exs`. Verify by running `mix test test/elx_vast/types_test.exs` — verification event tests pass.

## 3. New Element Validators (ClosedCaptionFiles & InteractiveCreativeFile)

- [x] 3.1 Add `validate_optional_closed_caption_files/1` in `lib/elx_vast/elements.ex`. It SHALL: find `ClosedCaptionFiles` under Linear; if absent, return `:ok`; if present, require ≥1 `ClosedCaptionFile` child; validate each child's `language` (required, non-empty), `type` (required, valid MIME), and text content (required, valid URI). Call it from `validate_linear_inline/1`. Add tests in `test/elx_vast_test.exs` covering the three spec scenarios (valid, missing language, empty container). Verify by running `mix test` — all new tests pass and existing tests still pass.
- [x] 3.2 Add `validate_optional_interactive_creative_file/1` in `lib/elx_vast/elements.ex`. It SHALL: find `InteractiveCreativeFile` under Linear; if absent, return `:ok`; if present, validate `type` (required, valid MIME), optional `apiFramework` (non-empty string if present), and text content (required, valid URI). Call it from `validate_linear_inline/1`. Add tests covering valid and missing-type scenarios. Verify by running `mix test` — all new tests pass.

## 4. Verification Resource Attribute Validation

- [x] 4.1 Update `validate_js_resources/1` (or its per-resource helper) in `lib/elx_vast/elements.ex` to validate `apiFramework` as required (non-empty string) and `browserOptional` as optional boolean on each `JavaScriptResource`. Add tests for: valid attributes, missing apiFramework → error. Verify by running `mix test` — new tests pass and the existing `complex_valid_vast/0` fixture (which already includes these attributes) still validates successfully.
- [x] 4.2 Update `validate_exec_resources/1` (or its per-resource helper) in `lib/elx_vast/elements.ex` to validate `apiFramework` as required (non-empty string) and `type` as optional (non-empty string if present) on each `ExecutableResource`. Add tests for valid and missing-apiFramework scenarios. Verify by running `mix test` — new tests pass.

## 5. MediaFile Attribute Extension

- [x] 5.1 Add `mediaType` as an optional attribute in `validate_optional_media_attributes/1` in `lib/elx_vast/validators.ex` — validate as non-empty string when present. Add tests: MediaFile with `mediaType="2D"` passes, MediaFile without `mediaType` still passes. Verify by running `mix test` — all tests pass.

## 6. Documentation and Integration Verification

- [x] 6.1 Update `README.md` to reflect VAST 4.1–4.3 support: change the title/description, update the "Supported Validations" section to list new elements, and update any version references. Update `mix.exs` description. Verify by reading the updated README and confirming the version claims are accurate.
- [x] 6.2 Run `mix test` end-to-end and confirm zero failures. Run `mix benchmark` to ensure no performance regression in the validation pipeline. Verify by observing all tests pass and benchmark output shows no significant degradation.
