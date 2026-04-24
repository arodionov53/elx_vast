#!/usr/bin/env elixir

# ElxVAST Performance Benchmark
# Run with: elixir benchmark/vast_benchmark.exs

Mix.install([
  {:benchee, "~> 1.3"},
  {:sweet_xml, "~> 0.7.4"}
])

# Load the validator modules
Code.require_file("lib/elx_vast.ex")
Code.require_file("lib/elx_vast/types.ex")
Code.require_file("lib/elx_vast/validators.ex")
Code.require_file("lib/elx_vast/elements.ex")

defmodule VastBenchmark do
  @moduledoc """
  Comprehensive performance benchmarks for ElxVAST library.
  Tests various VAST document types, sizes, and validation scenarios.
  """

  # VAST document samples for benchmarking

  def minimal_valid_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Error><![CDATA[https://example.com/error?code=no_ads]]></Error>
    </VAST>
    """
  end

  def simple_inline_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="12345">
        <InLine>
          <AdSystem version="1.0">Test Ad System</AdSystem>
          <AdServingId>test-serving-id</AdServingId>
          <AdTitle>Simple Test Ad</AdTitle>
          <Impression><![CDATA[https://example.com/impression]]></Impression>
          <Creatives>
            <Creative>
              <UniversalAdId idRegistry="Ad-ID">simple-ad-id</UniversalAdId>
              <Linear>
                <Duration>00:00:30</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                    <![CDATA[https://example.com/video.mp4]]>
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

  def complex_inline_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="complex-ad-12345" sequence="1" conditionalAd="false">
        <InLine>
          <AdSystem version="2.1"><![CDATA[Complex Ad Server]]></AdSystem>
          <AdServingId>complex-serving-id-abc-123</AdServingId>
          <AdTitle><![CDATA[Complex Video Advertisement with Multiple Creatives]]></AdTitle>
          <Description><![CDATA[This is a comprehensive test ad with multiple tracking events, creatives, and companion ads.]]></Description>
          <Advertiser id="advertiser-123"><![CDATA[Example Advertiser Inc.]]></Advertiser>
          <Pricing model="cpm" currency="USD"><![CDATA[2.50]]></Pricing>
          <Survey type="generic"><![CDATA[https://example.com/survey?id=123]]></Survey>
          <Impression id="impression-1"><![CDATA[https://example.com/impression?campaign=123&creative=456]]></Impression>
          <Impression id="impression-2"><![CDATA[https://backup.example.com/impression?campaign=123]]></Impression>
          <ViewableImpression id="viewable-1">
            <Viewable><![CDATA[https://example.com/viewable?id=123]]></Viewable>
            <NotViewable><![CDATA[https://example.com/not-viewable?id=123]]></NotViewable>
            <ViewUndetermined><![CDATA[https://example.com/view-undetermined?id=123]]></ViewUndetermined>
          </ViewableImpression>
          <Category authority="IAB"><![CDATA[IAB2-1]]></Category>
          <Category authority="IAB"><![CDATA[IAB2-3]]></Category>
          <Creatives>
            <Creative id="creative-linear-1" sequence="1" adId="ad-123">
              <UniversalAdId idRegistry="Ad-ID" idValue="complex-universal-ad-id">complex-ad-id-12345</UniversalAdId>
              <Linear>
                <Duration>00:01:30</Duration>
                <TrackingEvents>
                  <Tracking event="start"><![CDATA[https://example.com/track/start?id=123]]></Tracking>
                  <Tracking event="firstQuartile"><![CDATA[https://example.com/track/first-quartile?id=123]]></Tracking>
                  <Tracking event="midpoint"><![CDATA[https://example.com/track/midpoint?id=123]]></Tracking>
                  <Tracking event="thirdQuartile"><![CDATA[https://example.com/track/third-quartile?id=123]]></Tracking>
                  <Tracking event="complete"><![CDATA[https://example.com/track/complete?id=123]]></Tracking>
                  <Tracking event="progress" offset="00:00:15"><![CDATA[https://example.com/track/progress-15s?id=123]]></Tracking>
                  <Tracking event="progress" offset="50%"><![CDATA[https://example.com/track/progress-50p?id=123]]></Tracking>
                  <Tracking event="mute"><![CDATA[https://example.com/track/mute?id=123]]></Tracking>
                  <Tracking event="unmute"><![CDATA[https://example.com/track/unmute?id=123]]></Tracking>
                  <Tracking event="pause"><![CDATA[https://example.com/track/pause?id=123]]></Tracking>
                  <Tracking event="resume"><![CDATA[https://example.com/track/resume?id=123]]></Tracking>
                  <Tracking event="fullscreen"><![CDATA[https://example.com/track/fullscreen?id=123]]></Tracking>
                  <Tracking event="exitFullscreen"><![CDATA[https://example.com/track/exit-fullscreen?id=123]]></Tracking>
                </TrackingEvents>
                <AdParameters xmlEncoded="false"><![CDATA[campaign_id=123&placement_id=456&custom_param=value]]></AdParameters>
                <VideoClicks>
                  <ClickThrough id="clickthrough-1"><![CDATA[https://example.com/click-through?campaign=123]]></ClickThrough>
                  <ClickTracking id="click-track-1"><![CDATA[https://example.com/click-track?id=123]]></ClickTracking>
                  <ClickTracking id="click-track-2"><![CDATA[https://backup.example.com/click-track?id=123]]></ClickTracking>
                  <CustomClick id="custom-1" label="Share"><![CDATA[https://example.com/custom/share?id=123]]></CustomClick>
                  <CustomClick id="custom-2" label="Info"><![CDATA[https://example.com/custom/info?id=123]]></CustomClick>
                </VideoClicks>
                <MediaFiles>
                  <MediaFile id="media-1" delivery="progressive" type="video/mp4" width="1920" height="1080" codec="H.264" bitrate="5000" minBitrate="2000" maxBitrate="8000" scalable="true" maintainAspectRatio="true" apiFramework="VPAID">
                    <![CDATA[https://example.com/media/video-1080p.mp4]]>
                  </MediaFile>
                  <MediaFile id="media-2" delivery="progressive" type="video/mp4" width="1280" height="720" codec="H.264" bitrate="2500" maintainAspectRatio="true">
                    <![CDATA[https://example.com/media/video-720p.mp4]]>
                  </MediaFile>
                  <MediaFile id="media-3" delivery="progressive" type="video/mp4" width="640" height="480" codec="H.264" bitrate="1000" maintainAspectRatio="true">
                    <![CDATA[https://example.com/media/video-480p.mp4]]>
                  </MediaFile>
                  <MediaFile id="media-webm" delivery="progressive" type="video/webm" width="1280" height="720" codec="VP8" bitrate="2000">
                    <![CDATA[https://example.com/media/video-720p.webm]]>
                  </MediaFile>
                </MediaFiles>
                <Icons>
                  <Icon program="AdChoices" width="20" height="20" xPosition="right" yPosition="top" duration="00:01:30" offset="00:00:00" apiFramework="static">
                    <StaticResource creativeType="image/png">
                      <![CDATA[https://example.com/icons/adchoices.png]]>
                    </StaticResource>
                    <IconClicks>
                      <IconClickThrough><![CDATA[https://example.com/adchoices]]></IconClickThrough>
                      <IconClickTracking><![CDATA[https://example.com/track/icon-click]]></IconClickTracking>
                    </IconClicks>
                  </Icon>
                </Icons>
              </Linear>
            </Creative>
            <Creative id="creative-companion-1" sequence="2">
              <CompanionAds>
                <Companion id="companion-1" width="300" height="250" assetWidth="300" assetHeight="250" expandedWidth="600" expandedHeight="500" apiFramework="static" adSlotID="companion-slot-1">
                  <StaticResource creativeType="image/jpeg">
                    <![CDATA[https://example.com/companions/banner-300x250.jpg]]>
                  </StaticResource>
                  <TrackingEvents>
                    <Tracking event="creativeView"><![CDATA[https://example.com/track/companion-view?id=1]]></Tracking>
                  </TrackingEvents>
                  <CompanionClickThrough><![CDATA[https://example.com/companion-click?id=1]]></CompanionClickThrough>
                  <CompanionClickTracking><![CDATA[https://example.com/track/companion-click?id=1]]></CompanionClickTracking>
                </Companion>
                <Companion id="companion-2" width="728" height="90" assetWidth="728" assetHeight="90">
                  <StaticResource creativeType="image/jpeg">
                    <![CDATA[https://example.com/companions/banner-728x90.jpg]]>
                  </StaticResource>
                  <CompanionClickThrough><![CDATA[https://example.com/companion-click?id=2]]></CompanionClickThrough>
                </Companion>
              </CompanionAds>
            </Creative>
          </Creatives>
          <AdVerifications>
            <Verification vendor="IAS">
              <JavaScriptResource apiFramework="omid" browserOptional="true">
                <![CDATA[https://example.com/verification/ias-script.js]]>
              </JavaScriptResource>
              <TrackingEvents>
                <Tracking event="verificationNotExecuted"><![CDATA[https://example.com/verification/not-executed]]></Tracking>
              </TrackingEvents>
              <VerificationParameters><![CDATA[verification_id=123&campaign_id=456]]></VerificationParameters>
            </Verification>
          </AdVerifications>
          <Extensions>
            <Extension type="Count">
              <total_available>10</total_available>
            </Extension>
            <Extension type="CustomTracking">
              <CustomEvent event="userEngagement"><![CDATA[https://example.com/custom/engagement]]></CustomEvent>
            </Extension>
          </Extensions>
        </InLine>
      </Ad>
    </VAST>
    """
  end

  def wrapper_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="wrapper-ad-12345" sequence="1">
        <Wrapper followAdditionalWrappers="true" allowMultipleAds="false" fallbackOnNoAd="true">
          <AdSystem version="3.0"><![CDATA[Wrapper Ad System]]></AdSystem>
          <VASTAdTagURI><![CDATA[https://adserver.example.com/vast?campaign=123&wrapper=true]]></VASTAdTagURI>
          <Impression><![CDATA[https://wrapper.example.com/impression?wrapper=true]]></Impression>
          <Creatives>
            <Creative>
              <Linear>
                <TrackingEvents>
                  <Tracking event="start"><![CDATA[https://wrapper.example.com/track/start]]></Tracking>
                  <Tracking event="firstQuartile"><![CDATA[https://wrapper.example.com/track/first-quartile]]></Tracking>
                  <Tracking event="midpoint"><![CDATA[https://wrapper.example.com/track/midpoint]]></Tracking>
                  <Tracking event="thirdQuartile"><![CDATA[https://wrapper.example.com/track/third-quartile]]></Tracking>
                  <Tracking event="complete"><![CDATA[https://wrapper.example.com/track/complete]]></Tracking>
                </TrackingEvents>
                <VideoClicks>
                  <ClickTracking><![CDATA[https://wrapper.example.com/click-track]]></ClickTracking>
                </VideoClicks>
              </Linear>
            </Creative>
          </Creatives>
        </Wrapper>
      </Ad>
    </VAST>
    """
  end

  def multiple_ads_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="ad-1" sequence="1">
        <InLine>
          <AdSystem version="1.0">Multi Ad System</AdSystem>
          <AdServingId>ad-1-serving-id</AdServingId>
          <AdTitle>First Advertisement</AdTitle>
          <Impression><![CDATA[https://example.com/impression/ad1]]></Impression>
          <Creatives>
            <Creative>
              <UniversalAdId idRegistry="Ad-ID">ad-1-universal-id</UniversalAdId>
              <Linear>
                <Duration>00:00:15</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                    <![CDATA[https://example.com/video/ad1.mp4]]>
                  </MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
      <Ad id="ad-2" sequence="2">
        <InLine>
          <AdSystem version="1.0">Multi Ad System</AdSystem>
          <AdServingId>ad-2-serving-id</AdServingId>
          <AdTitle>Second Advertisement</AdTitle>
          <Impression><![CDATA[https://example.com/impression/ad2]]></Impression>
          <Creatives>
            <Creative>
              <UniversalAdId idRegistry="Ad-ID">ad-2-universal-id</UniversalAdId>
              <Linear>
                <Duration>00:00:20</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="1280" height="720">
                    <![CDATA[https://example.com/video/ad2.mp4]]>
                  </MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
      <Ad id="ad-3" sequence="3">
        <InLine>
          <AdSystem version="1.0">Multi Ad System</AdSystem>
          <AdServingId>ad-3-serving-id</AdServingId>
          <AdTitle>Third Advertisement</AdTitle>
          <Impression><![CDATA[https://example.com/impression/ad3]]></Impression>
          <Creatives>
            <Creative>
              <UniversalAdId idRegistry="Ad-ID">ad-3-universal-id</UniversalAdId>
              <Linear>
                <Duration>00:00:30</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="1920" height="1080">
                    <![CDATA[https://example.com/video/ad3.mp4]]>
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

  # Invalid VAST documents for error path testing

  def invalid_no_version do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST xmlns="http://www.iab.com/VAST">
      <Ad id="12345">
        <InLine>
          <AdSystem>Test</AdSystem>
        </InLine>
      </Ad>
    </VAST>
    """
  end

  def invalid_wrong_version do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="3.0" xmlns="http://www.iab.com/VAST">
      <Ad id="12345">
        <InLine>
          <AdSystem>Test</AdSystem>
        </InLine>
      </Ad>
    </VAST>
    """
  end

  def invalid_empty_vast do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
    </VAST>
    """
  end

  def malformed_xml do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="12345"
    """
  end

  # Generate large document with repeated elements
  def large_vast_document(num_ads \\ 50) do
    ads = Enum.map(1..num_ads, fn i ->
      """
        <Ad id="ad-#{i}" sequence="#{i}">
          <InLine>
            <AdSystem version="1.0">Large Scale Ad System</AdSystem>
            <AdServingId>ad-#{i}-serving-id</AdServingId>
            <AdTitle>Advertisement Number #{i}</AdTitle>
            <Impression><![CDATA[https://example.com/impression/ad#{i}]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">ad-#{i}-universal-id</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <TrackingEvents>
                    <Tracking event="start"><![CDATA[https://example.com/track/start/ad#{i}]]></Tracking>
                    <Tracking event="complete"><![CDATA[https://example.com/track/complete/ad#{i}]]></Tracking>
                  </TrackingEvents>
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

  def run_benchmarks do
    IO.puts("🚀 Starting ElxVAST Performance Benchmarks")
    IO.puts("=" |> String.duplicate(50))

    # Prepare test data
    samples = %{
      "minimal_valid" => minimal_valid_vast(),
      "simple_inline" => simple_inline_vast(),
      "complex_inline" => complex_inline_vast(),
      "wrapper" => wrapper_vast(),
      "multiple_ads" => multiple_ads_vast(),
      "large_document" => large_vast_document(20),
      "xlarge_document" => large_vast_document(100)
    }

    invalid_samples = %{
      "invalid_no_version" => invalid_no_version(),
      "invalid_wrong_version" => invalid_wrong_version(),
      "invalid_empty" => invalid_empty_vast(),
      "malformed_xml" => malformed_xml()
    }

    # Create temporary files for file validation benchmarks
    temp_files = create_temp_files(samples)

    try do
      # Main validation benchmarks
      IO.puts("\n📊 Running validation benchmarks...")

      valid_jobs = Map.new(samples, fn {key, xml} ->
        {key, fn -> ElxVast.validate(xml) end}
      end)

      invalid_jobs = Map.new(invalid_samples, fn {key, xml} ->
        {"invalid_#{key}", fn -> ElxVast.validate(xml) end}
      end)

      all_jobs = Map.merge(valid_jobs, invalid_jobs)

      Benchee.run(
        all_jobs,
        time: 10,
        memory_time: 5,
        formatters: [Benchee.Formatters.Console],
        print: [
          benchmarking: true,
          fast_warning: false
        ]
      )

      # File validation benchmarks
      IO.puts("\n📁 Running file validation benchmarks...")

      file_jobs = Map.new(temp_files, fn {key, path} ->
        {key, fn -> ElxVast.validate_file(path) end}
      end)

      Benchee.run(
        file_jobs,
        time: 5,
        memory_time: 2,
        title: "File Validation Performance",
        formatters: [
          Benchee.Formatters.Console,
          {Benchee.Formatters.HTML, file: "benchmark/results/file_validation_benchmark.html"}
        ]
      )

      # Type validation benchmarks
      IO.puts("\n🔍 Running type validation benchmarks...")
      run_type_validation_benchmarks()

      # Document size analysis
      IO.puts("\n📏 Running document size analysis...")
      run_size_analysis_benchmarks()

      IO.puts("\n✅ Benchmarks completed!")
      IO.puts("📈 Results saved to benchmark/results/")
      IO.puts("🌐 Open benchmark/results/validation_benchmark.html to view detailed results")

    after
      cleanup_temp_files(temp_files)
    end
  end

  defp create_temp_files(samples) do
    File.mkdir_p!("benchmark/temp")

    Map.new(samples, fn {key, xml} ->
      path = "benchmark/temp/#{key}.xml"
      File.write!(path, xml)
      {key, path}
    end)
  end

  defp cleanup_temp_files(temp_files) do
    Enum.each(temp_files, fn {_key, path} ->
      File.rm(path)
    end)
    File.rmdir("benchmark/temp")
  end

  defp run_type_validation_benchmarks do
    alias ElxVast.Types

    Benchee.run(
      %{
        "valid_time_simple" => fn -> Types.valid_time?("00:30:00") end,
        "valid_time_complex" => fn -> Types.valid_time?("02:15:30.500") end,
        "invalid_time" => fn -> Types.valid_time?("25:70:90") end,
        "valid_uri_https" => fn -> Types.valid_uri?("https://example.com/path?query=value") end,
        "valid_uri_http" => fn -> Types.valid_uri?("http://subdomain.example.org:8080/api") end,
        "invalid_uri" => fn -> Types.valid_uri?("not-a-valid-uri") end,
        "valid_offset_time" => fn -> Types.valid_offset?("00:00:15") end,
        "valid_offset_percent" => fn -> Types.valid_offset?("50%") end,
        "invalid_offset" => fn -> Types.valid_offset?("150%") end,
        "valid_mime_video" => fn -> Types.valid_mime_type?("video/mp4") end,
        "valid_mime_image" => fn -> Types.valid_mime_type?("image/jpeg") end,
        "invalid_mime" => fn -> Types.valid_mime_type?("invalid/type") end,
      },
      time: 3,
      memory_time: 1,
      title: "Type Validation Performance",
      formatters: [
        Benchee.Formatters.Console,
        {Benchee.Formatters.HTML, file: "benchmark/results/type_validation_benchmark.html"}
      ]
    )
  end

  defp run_size_analysis_benchmarks do
    # Test different document sizes
    small_doc = large_vast_document(1)
    medium_doc = large_vast_document(10)
    large_doc = large_vast_document(50)
    xlarge_doc = large_vast_document(200)

    Benchee.run(
      %{
        "1_ad" => fn -> ElxVast.validate(small_doc) end,
        "10_ads" => fn -> ElxVast.validate(medium_doc) end,
        "50_ads" => fn -> ElxVast.validate(large_doc) end,
        "200_ads" => fn -> ElxVast.validate(xlarge_doc) end,
      },
      time: 5,
      memory_time: 3,
      title: "Document Size Performance Analysis",
      formatters: [
        Benchee.Formatters.Console,
        {Benchee.Formatters.HTML, file: "benchmark/results/size_analysis_benchmark.html"}
      ]
    )

    # Report document sizes
    IO.puts("\n📐 Document Size Analysis:")
    IO.puts("  1 ad:   #{byte_size(small_doc)} bytes")
    IO.puts("  10 ads: #{byte_size(medium_doc)} bytes")
    IO.puts("  50 ads: #{byte_size(large_doc)} bytes")
    IO.puts("  200 ads: #{byte_size(xlarge_doc)} bytes")
  end
end

# Create results directory
File.mkdir_p!("benchmark/results")

# Run the benchmarks
VastBenchmark.run_benchmarks()