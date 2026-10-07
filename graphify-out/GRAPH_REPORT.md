# Graph Report - elx_vast  (2026-10-07)

## Corpus Check
- 31 files · ~41,822 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 267 nodes · 431 edges · 26 communities (17 shown, 9 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 16 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Type Validators & Core API
- VAST 4.3 Element Specs
- OpenSpec Workflow Commands
- Media & Attribute Validators
- Element Structure Validators
- Benchmark Mix Task
- Benchmark Module
- Design Decisions Archive
- Ad & InLine Validation
- Creative & Linear Validation
- Main Validation Pipeline
- Ad Verification Validation
- Video Click Validation
- Mix Project Config
- Test Fixtures
- InLine Optional Elements
- Verification Resources
- Performance Docs
- Size Analysis Benchmarks
- Type Validation Benchmarks
- Validation Benchmarks
- OpenSpec Config

## God Nodes (most connected - your core abstractions)
1. `ElxVast.Elements` - 72 edges
2. `ElxVast.Validators` - 24 edges
3. `ElxVast.Types` - 23 edges
4. `Mix.Tasks.Benchmark` - 16 edges
5. `VastBenchmark` - 16 edges
6. `ElxVast Library` - 16 edges
7. `run_benchmarks()` - 15 edges
8. `create_samples()` - 10 edges
9. `ElxVast` - 10 edges
10. `add-vast-43-support Proposal Document` - 10 edges

## Surprising Connections (you probably didn't know these)
- `ClosedCaptionFiles element` --semantically_similar_to--> `Requirement: Validate ClosedCaptionFiles element`  [INFERRED] [semantically similar]
  README.md → openspec/specs/vast-43-elements/spec.md
- `InteractiveCreativeFile element` --semantically_similar_to--> `Requirement: Validate InteractiveCreativeFile element`  [INFERRED] [semantically similar]
  README.md → openspec/specs/vast-43-elements/spec.md
- `JavaScriptResource attribute validation` --semantically_similar_to--> `Requirement: Validate JavaScriptResource attributes`  [INFERRED] [semantically similar]
  README.md → openspec/specs/vast-43-elements/spec.md
- `ExecutableResource attribute validation` --semantically_similar_to--> `Requirement: Validate ExecutableResource attributes`  [INFERRED] [semantically similar]
  README.md → openspec/specs/vast-43-elements/spec.md
- `Task Group 6: Documentation and Integration Verification` --references--> `ElxVast Library`  [EXTRACTED]
  openspec/changes/archive/2026-10-07-add-vast-43-support/tasks.md → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **ElxVAST Benchmark System** — benchmark_readme_validation_benchmarks, benchmark_readme_type_validation_benchmarks, benchmark_readme_size_analysis_benchmarks, benchmark_performance_summary_benchee [EXTRACTED 1.00]
- **ElxVAST Performance Design** — benchmark_performance_summary_early_validation, benchmark_performance_summary_linear_scaling, benchmark_performance_summary_validation_path [EXTRACTED 1.00]
- **add-vast-43-support OpenSpec Change Artifacts** — openspec_changes_archive_2026_10_07_add_vast_43_support_openspec_changes_archive_2026_10_07_add_vast_43_support_meta, openspec_changes_archive_2026_10_07_add_vast_43_support_proposal_doc, openspec_changes_archive_2026_10_07_add_vast_43_support_design_doc, openspec_changes_archive_2026_10_07_add_vast_43_support_tasks_doc, openspec_changes_archive_2026_10_07_add_vast_43_support_specs_vast_43_elements_spec_delta, openspec_changes_archive_2026_10_07_add_vast_43_support_specs_vast_version_support_spec_delta [EXTRACTED 1.00]
- **VAST 4.3 Elements Requirements Implementing vast-43-elements Capability** — openspec_specs_vast_43_elements_spec_closed_caption_files_req, openspec_specs_vast_43_elements_spec_interactive_creative_file_req, openspec_specs_vast_43_elements_spec_tracking_events_req, openspec_specs_vast_43_elements_spec_verification_events_req, openspec_specs_vast_43_elements_spec_js_resource_req, openspec_specs_vast_43_elements_spec_exec_resource_req, openspec_specs_vast_43_elements_spec_mediatype_req, openspec_specs_vast_43_elements_spec_capability [EXTRACTED 1.00]
- **Design Decisions Realizing add-vast-43-support Proposal** — openspec_changes_archive_2026_10_07_add_vast_43_support_design_decision_superset_validation, openspec_changes_archive_2026_10_07_add_vast_43_support_design_decision_widen_version_gate, openspec_changes_archive_2026_10_07_add_vast_43_support_design_decision_new_element_validators, openspec_changes_archive_2026_10_07_add_vast_43_support_design_decision_expand_enumerations, openspec_changes_archive_2026_10_07_add_vast_43_support_design_decision_verification_resource_attrs, openspec_changes_archive_2026_10_07_add_vast_43_support_proposal_doc [INFERRED 0.85]
- **OPSX OpenSpec Workflow Family** — claude_commands_opsx_apply_opsx_apply_command, claude_commands_opsx_archive_opsx_archive_command, claude_commands_opsx_explore_opsx_explore_command, claude_commands_opsx_propose_opsx_propose_command, claude_commands_opsx_sync_opsx_sync_command, claude_commands_opsx_update_opsx_update_command, claude_skills_openspec_apply_change_skill_openspec_apply_change_skill, claude_skills_openspec_archive_change_skill_openspec_archive_change_skill, claude_skills_openspec_explore_skill_openspec_explore_skill, claude_skills_openspec_propose_skill_openspec_propose_skill, claude_skills_openspec_sync_specs_skill_openspec_sync_specs_skill, claude_skills_openspec_update_change_skill_openspec_update_change_skill [EXTRACTED 1.00]
- **Shared Store Selection and Project Check protocol** — claude_commands_opsx_apply_opsx_apply_command, claude_commands_opsx_archive_opsx_archive_command, claude_commands_opsx_explore_opsx_explore_command, claude_commands_opsx_propose_opsx_propose_command, claude_commands_opsx_sync_opsx_sync_command, claude_commands_opsx_update_opsx_update_command, claude_skills_openspec_apply_change_skill_openspec_apply_change_skill, claude_skills_openspec_archive_change_skill_openspec_archive_change_skill, claude_skills_openspec_explore_skill_openspec_explore_skill, claude_skills_openspec_propose_skill_openspec_propose_skill, claude_skills_openspec_sync_specs_skill_openspec_sync_specs_skill, claude_skills_openspec_update_change_skill_openspec_update_change_skill, concept_store_selection, concept_project_check [EXTRACTED 1.00]

## Communities (26 total, 9 thin omitted)

### Community 0 - "Type Validators & Core API"
Cohesion: 0.06
Nodes (12): ElxVast.Types, valid_offset?(), valid_time?(), add-vast-43-support Tasks Document, Task Group 6: Documentation and Integration Verification, Task Group 3: New Element Validators, Task Group 2: Expanded Enumerations in Types, Task Group 5: MediaFile Attribute Extension (+4 more)

### Community 1 - "VAST 4.3 Element Specs"
Cohesion: 0.09
Nodes (24): ElxVAST v0.1.0 Release, vast-43-elements Spec Delta (change), vast-43-elements Capability Spec, Requirement: Validate ClosedCaptionFiles element, Requirement: Validate ExecutableResource attributes, Requirement: Validate InteractiveCreativeFile element, Requirement: Validate JavaScriptResource attributes, Requirement: New optional MediaFile attribute mediaType (+16 more)

### Community 2 - "OpenSpec Workflow Commands"
Cohesion: 0.18
Nodes (18): OPSX: Apply (slash command), OPSX: Archive (slash command), OPSX: Explore (slash command), OPSX: Propose (slash command), OPSX: Sync (slash command), OPSX: Update (slash command), openspec-apply-change SKILL, openspec-archive-change SKILL (+10 more)

### Community 3 - "Media & Attribute Validators"
Cohesion: 0.16
Nodes (18): ElxVast.Validators, validate_bitrate_consistency(), validate_bitrate_range(), validate_currency(), validate_delivery_method(), validate_dimension(), validate_event_name(), validate_event_offset() (+10 more)

### Community 4 - "Element Structure Validators"
Cohesion: 0.20
Nodes (18): ElxVast.Elements, validate_cc_file_uri(), validate_cc_mime_type(), validate_closed_caption_file(), validate_closed_caption_files_element(), validate_duration_element(), validate_icf_mime_type(), validate_icf_uri() (+10 more)

### Community 5 - "Benchmark Mix Task"
Cohesion: 0.23
Nodes (16): Mix.Tasks.Benchmark, complex_inline_vast(), create_multi_ad_vast(), create_samples(), format_bytes(), invalid_empty(), invalid_no_version(), malformed_xml() (+8 more)

### Community 6 - "Benchmark Module"
Cohesion: 0.23
Nodes (16): VastBenchmark, cleanup_temp_files(), complex_inline_vast(), create_temp_files(), invalid_empty_vast(), invalid_no_version(), invalid_wrong_version(), large_vast_document() (+8 more)

### Community 7 - "Design Decisions Archive"
Cohesion: 0.17
Nodes (11): add-vast-43-support Design Document, ElxVast.Elements module (design.md reference), ElxVast.Types module (design.md reference), ElxVast.Validators module (design.md reference), add-vast-43-support Change Metadata, add-vast-43-support Proposal Document, vast-version-support Spec Delta (change), Requirement: Accept VAST 4.1, 4.2, and 4.3 version strings (+3 more)

### Community 8 - "Ad & InLine Validation"
Cohesion: 0.20
Nodes (12): validate_ad(), validate_ad_attributes(), validate_ad_content(), validate_creatives(), validate_creatives_element(), validate_impression(), validate_impressions(), validate_inline() (+4 more)

### Community 9 - "Creative & Linear Validation"
Cohesion: 0.20
Nodes (10): validate_creative(), validate_creative_companions(), validate_creative_linear(), validate_creative_nonlinear(), validate_linear_tracking_events(), validate_linear_video_clicks_wrapper(), validate_linear_wrapper(), validate_tracking_events_element() (+2 more)

### Community 10 - "Main Validation Pipeline"
Cohesion: 0.38
Nodes (10): ElxVast, analyze_vast_content(), parse_xml(), validate(), validate_ads(), validate_content_rules(), validate_errors(), validate_file() (+2 more)

### Community 11 - "Ad Verification Validation"
Cohesion: 0.25
Nodes (8): validate_ad_verifications(), validate_optional_ad_verifications(), validate_tracking_uri(), validate_verification(), validate_verification_event_name(), validate_verification_tracking_event(), validate_verification_tracking_events(), validate_verification_tracking_events_element()

### Community 12 - "Video Click Validation"
Cohesion: 0.25
Nodes (8): validate_click_through(), validate_click_through_element(), validate_click_tracking_element(), validate_click_tracking_elements(), validate_custom_click_element(), validate_custom_click_elements(), validate_video_clicks_base(), validate_video_clicks_inline()

### Community 13 - "Mix Project Config"
Cohesion: 0.36
Nodes (5): ElxVast.MixProject, deps(), description(), package(), project()

### Community 15 - "InLine Optional Elements"
Cohesion: 0.29
Nodes (7): validate_category(), validate_inline_optional_elements(), validate_optional_categories(), validate_optional_expires(), validate_optional_pricing(), validate_optional_survey(), validate_survey()

### Community 16 - "Verification Resources"
Cohesion: 0.29
Nodes (7): validate_exec_resource(), validate_exec_resource_uri(), validate_exec_resources(), validate_js_resource(), validate_js_resource_uri(), validate_js_resources(), validate_verification_resources()

### Community 17 - "Performance Docs"
Cohesion: 0.67
Nodes (3): Benchee Library, ElxVAST Performance Summary, ElxVAST Benchmark Guide

## Knowledge Gaps
- **28 isolated node(s):** `Size Analysis Benchmarks`, `Benchee Library`, `Type Validation Benchmarks`, `Validation Benchmarks`, `ElxVAST Performance Summary` (+23 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 66 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **9 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ElxVast.Elements` connect `Element Structure Validators` to `Type Validators & Core API`, `Ad & InLine Validation`, `Creative & Linear Validation`, `Ad Verification Validation`, `Video Click Validation`, `InLine Optional Elements`, `Verification Resources`?**
  _High betweenness centrality (0.285) - this node is a cross-community bridge._
- **What connects `Size Analysis Benchmarks`, `Benchee Library`, `Type Validation Benchmarks` to the rest of the system?**
  _28 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Type Validators & Core API` be split into smaller, more focused modules?**
  _Cohesion score 0.06456456456456457 - nodes in this community are weakly interconnected._
- **Why does `add-vast-43-support Tasks Document` connect `Type Validators & Core API` to `Design Decisions Archive`?**
  _High betweenness centrality (0.169) - this node is a cross-community bridge._
- **Should `VAST 4.3 Element Specs` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._