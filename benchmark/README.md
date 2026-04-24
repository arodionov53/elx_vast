# ElxVAST Benchmarks

This directory contains comprehensive performance benchmarks for the ElxVAST library.

## Quick Start

```bash
# Install dependencies (includes Benchee)
mix deps.get

# Run all benchmarks
mix benchmark

# Run quick benchmarks (faster, less detailed)
mix benchmark --quick

# Run only validation benchmarks
mix benchmark --validation-only

# Run only type validation benchmarks  
mix benchmark --types-only
```

## Benchmark Categories

### 1. Validation Benchmarks
Tests the main `ElxVast.validate/1` function with various document types:

- **Minimal Error Document** - Simple VAST with only error element
- **Simple Inline Ad** - Basic InLine ad with single creative
- **Complex Inline Ad** - Full-featured InLine ad with tracking, companions
- **Wrapper Ad** - VAST wrapper document
- **Multiple Ads** - Document with multiple sequential ads
- **Invalid Documents** - Error path testing (missing version, malformed XML, etc.)

### 2. Type Validation Benchmarks
Tests individual type validators from `ElxVast.Types`:

- Time format validation (`valid_time?/1`)
- URI validation (`valid_uri?/1`) 
- Offset validation (`valid_offset?/1`)
- MIME type validation (`valid_mime_type?/1`)

### 3. Size Analysis Benchmarks
Tests performance scaling with document size:

- Single ad document
- 10 ads document  
- 50 ads document
- Document size reporting

## Results

Benchmark results are displayed in the console with detailed performance statistics including:

- **Iterations per second (ips)** - Throughput measurement
- **Average execution time** - Performance timing
- **Memory usage** - Memory consumption analysis
- **Comparison tables** - Relative performance between scenarios

Console output includes detailed statistics, comparisons, and memory usage analysis.

## Advanced Usage

### Standalone Benchmark Script

Run the comprehensive benchmark script directly:

```bash
elixir benchmark/vast_benchmark.exs
```

This script includes additional test cases and larger document sizes.

### Custom Benchmarks

Create custom benchmark scenarios by adding functions to the Mix task or creating new scripts that use Benchee directly:

```elixir
Benchee.run(%{
  "my_test" => fn -> ElxVast.validate(my_vast_xml) end
})
```

## Understanding Results

### Key Metrics

- **Iterations per second (ips)** - Higher is better
- **Average execution time** - Lower is better  
- **Memory usage** - Lower is better
- **Standard deviation** - Lower indicates more consistent performance

### Expected Performance

Typical performance on modern hardware:

- **Minimal documents**: >10,000 ips
- **Simple inline ads**: >1,000 ips
- **Complex documents**: >100 ips
- **Large documents (50+ ads)**: >10 ips

### Optimization Tips

1. **Batch validation** for multiple documents
2. **Cache parsed XML** if validating repeatedly
3. **Use file validation** for large documents already on disk
4. **Profile memory usage** for high-throughput scenarios

## Continuous Integration

Add benchmark validation to CI:

```bash
# Quick validation that benchmarks run without errors
mix benchmark --quick --validation-only
```

## Troubleshooting

### Common Issues

1. **Out of memory errors** with very large documents
   - Use `--quick` flag to reduce memory usage
   - Test with smaller document sizes

2. **Benchee not found**
   - Run `mix deps.get` to install dependencies
   - Ensure `benchee` is in your `mix.exs` dependencies

3. **Results directory errors**
   - Directory is created automatically
   - Ensure write permissions in project directory