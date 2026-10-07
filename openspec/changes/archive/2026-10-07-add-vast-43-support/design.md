# Design

## Context

See proposal.md — Why. The codebase has four modules: `ElxVast` (entry point), `ElxVast.Validators` (version gate, attribute validators), `ElxVast.Elements` (element-level structural validators), and `ElxVast.Types` (format/enum validators). All version-specific logic is currently inlined — there is no version-dispatch layer, no XSD files, and no per-version modules.

Key observations from the existing code:
- `Validators.valid_version?/1` uses `@valid_versions ["4.1", "4.1.0", "4.1.1", "4.1.2"]` and a `String.starts_with?(version, "4.1")` fallback — the single gate.
- `ElxVast.validate_root_element/1` has a hardcoded error message referencing "4.1".
- `Types` holds all enumeration lists (tracking events, verification events, ad types, delivery methods, etc.).
- `Elements` validates the structural tree but `NonLinearAds` and `CompanionAds` are stubs.
- New 4.2/4.3 elements (`ClosedCaptionFiles`, `InteractiveCreativeFile`) are completely absent.
- `JavaScriptResource`/`ExecutableResource` attributes exist in test fixtures but are not validated.

## Goals / Non-Goals

**Goals:**
- Accept VAST 4.1, 4.2, and 4.3 documents
- Validate 4.2/4.3-specific elements and expanded enumerations
- Keep existing 4.1 validation behavior unchanged
- Maintain the same public API surface

**Non-Goals:**
- Version-branched validation (running different rule sets per version) — all documents get the superset of rules. A valid 4.1 document is also valid under the 4.3 superset since 4.3 only adds optional elements.
- VAST 2.x or 3.x support
- Fleshing out `NonLinearAds`/`CompanionAds` stubs (orthogonal to this change)
- XSD-based validation or bundling XSD files

## Decisions

### 1. Superset validation instead of version-branched rules

**Decision**: Validate all documents against the 4.3 superset rather than dispatching to version-specific rule sets.

**Rationale**: VAST 4.2 and 4.3 are backward-compatible with 4.1 — they add optional elements and attributes but do not remove or redefine existing ones. A 4.1 document that passes 4.1 rules will also pass 4.3 rules because the new elements are optional. This avoids the complexity of maintaining parallel validation paths.

**Alternative considered**: Per-version modules (`ElxVast.V41`, `ElxVast.V43`) — rejected because the versions share >95% of their rules, and branching would duplicate nearly all validation logic.

### 2. Widen the version gate with an explicit list

**Decision**: Replace the `String.starts_with?(version, "4.1")` approach with a module attribute listing supported major-minor prefixes: `@supported_versions ["4.1", "4.2", "4.3"]`. Accept any version string that starts with one of these prefixes (covering patch variants like 4.3.1).

**Rationale**: Explicit list is self-documenting and easy to extend. The starts-with approach still handles patch versions naturally.

**Alternative considered**: A single `String.starts_with?(version, "4.")` catch-all — rejected because it would accept 4.0 and hypothetical future 4.9 without intentional opt-in.

### 3. Add new element validators alongside existing ones in Elements

**Decision**: Add `validate_optional_closed_caption_files/1` and `validate_optional_interactive_creative_file/1` in `ElxVast.Elements`, called from `validate_linear_inline/1`. Follow the existing pattern of `validate_optional_*` functions.

**Rationale**: Matches the established code style. Each new element gets its own validator function, called optionally from the parent element validator.

### 4. Expand enumerations in Types

**Decision**: Add new event names to the `valid_tracking_event?/1` guard clause list and expand `valid_verification_event?/1` in `Types`.

**Rationale**: All enum lists live in `Types` — this is the established pattern. No structural change needed.

### 5. Validate verification resource attributes in Elements

**Decision**: Add attribute validation for `JavaScriptResource` (`apiFramework` required, `browserOptional` optional boolean) and `ExecutableResource` (`apiFramework` required, `type` optional string) inside the existing `validate_js_resources/1` and `validate_exec_resources/1` functions in `Elements`.

**Rationale**: These attributes already appear in test fixtures but are unchecked. Formalizing them is a bug fix as much as a feature.

## Risks / Trade-offs

- **[Risk] Superset validation is too lenient for 4.1-only consumers** → Mitigation: This matches how most VAST validators behave in practice. The library's purpose is to validate structure, not enforce minimum-version compliance. If needed later, version-branched strictness can be layered on.
- **[Risk] New required attributes on verification resources may break existing valid documents** → Mitigation: The test fixtures already include these attributes, suggesting real-world documents do too. Add the validation but verify against the existing test suite that no regressions occur.
- **[Risk] Incomplete 4.3 coverage** → Mitigation: The spec covers the most impactful additions. Lesser changes (e.g., new Companion sub-elements) are explicitly out of scope and can be added incrementally without breaking changes.
