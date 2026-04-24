#!/usr/bin/env elixir

IO.puts("🎬 ElxVAST - VAST 4.1 XML Validator")
IO.puts("==================================")

IO.puts("\n📍 Current Directory: #{File.cwd!()}")

IO.puts("\n🏗️  Project Structure:")
IO.puts("  lib/elx_vast.ex              - Main validator module")
IO.puts("  lib/elx_vast/types.ex        - Data type validators")
IO.puts("  lib/elx_vast/validators.ex   - Complex validation logic")
IO.puts("  lib/elx_vast/elements.ex     - Element-specific validation")
IO.puts("  test/                        - Comprehensive test suite")
IO.puts("  examples/                    - Usage examples")

IO.puts("\n✨ Features:")
IO.puts("  ✅ Complete VAST 4.1 schema validation")
IO.puts("  ✅ Detailed error reporting")
IO.puts("  ✅ Type safety for all data formats")
IO.puts("  ✅ Support for InLine and Wrapper ads")
IO.puts("  ✅ MediaFile and creative validation")
IO.puts("  ✅ Tracking event validation")

IO.puts("\n🚀 Quick Start:")
IO.puts("  1. cd <project_directory>")
IO.puts("  2. mix deps.get")
IO.puts("  3. iex -S mix")
IO.puts("  4. ElxVast.validate(your_vast_xml)")

IO.puts("\n🧪 Testing:")
IO.puts("  mix test                         # Run all tests")
IO.puts("  elixir examples/usage_example.exs # Run examples")

IO.puts("\n📦 Ready for use in Elixir applications!")
IO.puts("===================================================")