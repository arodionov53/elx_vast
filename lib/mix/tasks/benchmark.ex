defmodule Mix.Tasks.Benchmark do
  @moduledoc """
  Run ElxVAST performance benchmarks.

  ## Usage

      mix benchmark                    # Run all benchmarks
      mix benchmark --validation-only  # Run only validation benchmarks
      mix benchmark --types-only      # Run only type validation benchmarks
      mix benchmark --quick          # Run quick benchmarks (shorter time)

  Results are saved to benchmark/results/ directory.
  """

  use Mix.Task
  @shortdoc "Run ElxVAST performance benchmarks"

  def run(args) do
    Mix.Task.run("compile")

    {opts, _} = OptionParser.parse!(args,
      switches: [validation_only: :boolean, types_only: :boolean, quick: :boolean],
      aliases: [v: :validation_only, t: :types_only, q: :quick]
    )

    # Ensure results directory exists
    File.mkdir_p!("benchmark/results")

    # Determine benchmark time based on quick flag
    {benchmark_time, memory_time} = if opts[:quick], do: {3, 1}, else: {10, 5}

    IO.puts("🚀 Starting ElxVAST Performance Benchmarks")
    IO.puts("=" |> String.duplicate(50))

    cond do
      opts[:validation_only] ->
        run_validation_benchmarks(benchmark_time, memory_time)

      opts[:types_only] ->
        run_type_benchmarks(benchmark_time, memory_time)

      true ->
        run_all_benchmarks(benchmark_time, memory_time)
    end

    IO.puts("\n✅ Benchmarks completed!")
    IO.puts("📈 Results saved to benchmark/results/")
  end

  defp run_all_benchmarks(benchmark_time, memory_time) do
    run_validation_benchmarks(benchmark_time, memory_time)
    run_type_benchmarks(benchmark_time, memory_time)
    run_size_analysis(benchmark_time, memory_time)
  end

  defp run_validation_benchmarks(benchmark_time, memory_time) do
    IO.puts("\n📊 Running validation benchmarks...")

    samples = create_samples()

    Benchee.run(
      samples,
      time: benchmark_time,
      memory_time: memory_time,
      formatters: [Benchee.Formatters.Console],
      print: [benchmarking: true, fast_warning: false]
    )
  end

  defp run_type_benchmarks(benchmark_time, memory_time) do
    IO.puts("\n🔍 Running type validation benchmarks...")

    alias ElxVast.Types

    Benchee.run(
      %{
        "time_valid_simple" => fn -> Types.valid_time?("00:30:00") end,
        "time_valid_millisecs" => fn -> Types.valid_time?("02:15:30.500") end,
        "time_invalid" => fn -> Types.valid_time?("25:70:90") end,
        "uri_valid_https" => fn -> Types.valid_uri?("https://example.com/path?query=value#anchor") end,
        "uri_valid_complex" => fn -> Types.valid_uri?("https://subdomain.example.org:8080/api/v1/data") end,
        "uri_invalid" => fn -> Types.valid_uri?("not-a-valid-uri-at-all") end,
        "offset_time" => fn -> Types.valid_offset?("00:00:15") end,
        "offset_percent" => fn -> Types.valid_offset?("75%") end,
        "offset_invalid" => fn -> Types.valid_offset?("150%") end,
        "mime_video" => fn -> Types.valid_mime_type?("video/mp4") end,
        "mime_invalid" => fn -> Types.valid_mime_type?("invalid/type") end,
      },
      time: benchmark_time,
      memory_time: memory_time,
      title: "Type Validation Performance",
      formatters: [Benchee.Formatters.Console]
    )
  end

  defp run_size_analysis(benchmark_time, memory_time) do
    IO.puts("\n📏 Running document size analysis...")

    small_doc = create_multi_ad_vast(1)
    medium_doc = create_multi_ad_vast(10)
    large_doc = create_multi_ad_vast(50)

    Benchee.run(
      %{
        "single_ad" => fn -> ElxVast.validate(small_doc) end,
        "10_ads" => fn -> ElxVast.validate(medium_doc) end,
        "50_ads" => fn -> ElxVast.validate(large_doc) end,
      },
      time: benchmark_time,
      memory_time: memory_time,
      title: "Document Size Analysis",
      formatters: [Benchee.Formatters.Console]
    )

    IO.puts("\n📐 Document sizes:")
    IO.puts("  Single ad: #{format_bytes(byte_size(small_doc))}")
    IO.puts("  10 ads:    #{format_bytes(byte_size(medium_doc))}")
    IO.puts("  50 ads:    #{format_bytes(byte_size(large_doc))}")
  end

  defp create_samples do
    %{
      # Valid documents
      "minimal_error_only" => fn -> ElxVast.validate(minimal_error_vast()) end,
      "simple_inline" => fn -> ElxVast.validate(simple_inline_vast()) end,
      "complex_inline" => fn -> ElxVast.validate(complex_inline_vast()) end,
      "wrapper_ad" => fn -> ElxVast.validate(wrapper_vast()) end,
      "multiple_ads" => fn -> ElxVast.validate(create_multi_ad_vast(3)) end,

      # Invalid documents (error paths)
      "invalid_no_version" => fn -> ElxVast.validate(invalid_no_version()) end,
      "invalid_empty" => fn -> ElxVast.validate(invalid_empty()) end,
      "invalid_malformed" => fn -> ElxVast.validate(malformed_xml()) end,
    }
  end

  # VAST document templates

  defp minimal_error_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Error><![CDATA[https://example.com/error?code=no_ads]]></Error>
    </VAST>
    """
  end

  defp simple_inline_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="simple-ad">
        <InLine>
          <AdSystem version="1.0">Benchmark Ad System</AdSystem>
          <AdServingId>benchmark-serving-id</AdServingId>
          <AdTitle>Simple Benchmark Ad</AdTitle>
          <Impression><![CDATA[https://example.com/impression/simple]]></Impression>
          <Creatives>
            <Creative>
              <UniversalAdId idRegistry="Ad-ID">simple-benchmark-id</UniversalAdId>
              <Linear>
                <Duration>00:00:30</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                    <![CDATA[https://example.com/video/simple.mp4]]>
                  </MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """
  end

  defp complex_inline_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="complex-benchmark-ad">
        <InLine>
          <AdSystem version="2.1">Complex Benchmark System</AdSystem>
          <AdServingId>complex-benchmark-id</AdServingId>
          <AdTitle><![CDATA[Complex Benchmark Advertisement]]></AdTitle>
          <Description><![CDATA[Comprehensive benchmark ad with multiple tracking events and creatives.]]></Description>
          <Impression><![CDATA[https://example.com/impression/complex]]></Impression>
          <Creatives>
            <Creative id="linear-creative">
              <UniversalAdId idRegistry="Ad-ID">complex-benchmark-universal</UniversalAdId>
              <Linear>
                <Duration>00:01:30</Duration>
                <TrackingEvents>
                  <Tracking event="start"><![CDATA[https://example.com/track/start]]></Tracking>
                  <Tracking event="firstQuartile"><![CDATA[https://example.com/track/first]]></Tracking>
                  <Tracking event="midpoint"><![CDATA[https://example.com/track/mid]]></Tracking>
                  <Tracking event="thirdQuartile"><![CDATA[https://example.com/track/third]]></Tracking>
                  <Tracking event="complete"><![CDATA[https://example.com/track/complete]]></Tracking>
                </TrackingEvents>
                <VideoClicks>
                  <ClickThrough><![CDATA[https://example.com/click-through]]></ClickThrough>
                  <ClickTracking><![CDATA[https://example.com/click-tracking]]></ClickTracking>
                </VideoClicks>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="1920" height="1080" bitrate="5000">
                    <![CDATA[https://example.com/video/complex-hd.mp4]]>
                  </MediaFile>
                  <MediaFile delivery="progressive" type="video/mp4" width="1280" height="720" bitrate="2500">
                    <![CDATA[https://example.com/video/complex-720p.mp4]]>
                  </MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
            <Creative id="companion-creative">
              <CompanionAds>
                <Companion width="300" height="250">
                  <StaticResource creativeType="image/jpeg">
                    <![CDATA[https://example.com/companion/banner.jpg]]>
                  </StaticResource>
                  <CompanionClickThrough><![CDATA[https://example.com/companion-click]]></CompanionClickThrough>
                </Companion>
              </CompanionAds>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """
  end

  defp wrapper_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="wrapper-benchmark-ad">
        <Wrapper followAdditionalWrappers="true">
          <AdSystem version="1.0">Wrapper Benchmark System</AdSystem>
          <VASTAdTagURI><![CDATA[https://adserver.example.com/vast/wrapped]]></VASTAdTagURI>
          <Impression><![CDATA[https://wrapper.example.com/impression]]></Impression>
          <Creatives>
            <Creative>
              <Linear>
                <TrackingEvents>
                  <Tracking event="start"><![CDATA[https://wrapper.example.com/track/start]]></Tracking>
                  <Tracking event="complete"><![CDATA[https://wrapper.example.com/track/complete]]></Tracking>
                </TrackingEvents>
              </Linear>
            </Creative>
          </Creatives>
        </Wrapper>
      </Ad>
    </VAST>
    """
  end

  defp create_multi_ad_vast(num_ads) do
    ads = Enum.map(1..num_ads, fn i ->
      """
        <Ad id="benchmark-ad-#{i}" sequence="#{i}">
          <InLine>
            <AdSystem version="1.0">Multi Ad Benchmark System</AdSystem>
            <AdServingId>benchmark-ad-#{i}-id</AdServingId>
            <AdTitle>Benchmark Ad #{i}</AdTitle>
            <Impression><![CDATA[https://example.com/impression/ad#{i}]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">benchmark-#{i}-universal</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4" width="1280" height="720">
                      <![CDATA[https://example.com/video/ad#{i}.mp4]]>
                    </MediaFile>
                  </MediaFiles>
                </Linear>
              </Creative>
            </Creatives>
          </InLine>
        </Ad>
      """
    end) |> Enum.join("\n")

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
    #{ads}
    </VAST>
    """
  end

  # Invalid documents for error path testing

  defp invalid_no_version do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST xmlns="http://www.iab.com/VAST">
      <Ad id="no-version">
        <InLine>
          <AdSystem>Test</AdSystem>
        </InLine>
      </Ad>
    </VAST>
    """
  end

  defp invalid_empty do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
    </VAST>
    """
  end

  defp malformed_xml do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="malformed"
    """
  end

  defp format_bytes(bytes) when bytes >= 1024 * 1024 do
    "#{Float.round(bytes / (1024 * 1024), 1)} MB"
  end

  defp format_bytes(bytes) when bytes >= 1024 do
    "#{Float.round(bytes / 1024, 1)} KB"
  end

  defp format_bytes(bytes) do
    "#{bytes} bytes"
  end
end