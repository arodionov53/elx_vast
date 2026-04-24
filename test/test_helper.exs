ExUnit.start()

defmodule VastValidatorTestHelper do
  @moduledoc """
  Helper functions and fixtures for VAST validator tests.
  """

  def valid_minimal_inline_vast() do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="12345">
        <InLine>
          <AdSystem version="1.0">Test Ad System</AdSystem>
          <AdServingId>test-serving-id-123</AdServingId>
          <AdTitle>Test Video Ad</AdTitle>
          <Impression><![CDATA[https://example.com/impression?id=123]]></Impression>
          <Creatives>
            <Creative>
              <UniversalAdId idRegistry="Ad-ID">test-universal-id</UniversalAdId>
              <Linear>
                <Duration>00:00:30</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                    <![CDATA[https://example.com/media/video.mp4]]>
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

  def valid_wrapper_vast() do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="wrapper-123">
        <Wrapper>
          <AdSystem version="2.0">Wrapper System</AdSystem>
          <Impression><![CDATA[https://wrapper.com/impression]]></Impression>
          <VASTAdTagURI><![CDATA[https://adserver.com/vast?id=456]]></VASTAdTagURI>
          <Creatives>
            <Creative>
              <Linear>
                <TrackingEvents>
                  <Tracking event="start"><![CDATA[https://wrapper.com/track/start]]></Tracking>
                  <Tracking event="complete"><![CDATA[https://wrapper.com/track/complete]]></Tracking>
                </TrackingEvents>
              </Linear>
            </Creative>
          </Creatives>
        </Wrapper>
      </Ad>
    </VAST>
    """
  end

  def valid_error_vast() do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Error><![CDATA[https://example.com/error?reason=no_ads_available]]></Error>
    </VAST>
    """
  end

  def complex_valid_vast() do
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      <Ad id="complex-ad-123" sequence="1" adType="video">
        <InLine>
          <AdSystem version="3.0">Complex Ad System</AdSystem>
          <AdServingId>complex-serving-id-789</AdServingId>
          <AdTitle>Complex Test Video Ad</AdTitle>
          <Impression id="impression-1"><![CDATA[https://example.com/impression1]]></Impression>
          <Impression id="impression-2"><![CDATA[https://example.com/impression2]]></Impression>
          <Advertiser>Test Advertiser Inc.</Advertiser>
          <Description>A complex test ad with multiple features</Description>
          <Pricing model="CPM" currency="USD">5.50</Pricing>
          <Category authority="https://example.com/categories">Automotive</Category>
          <Survey type="text/javascript"><![CDATA[https://example.com/survey]]></Survey>
          <Expires>3600</Expires>
          <Creatives>
            <Creative id="creative-1">
              <UniversalAdId idRegistry="Ad-ID">complex-universal-id-123</UniversalAdId>
              <Linear skipoffset="00:00:05">
                <Duration>00:00:30</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4" width="1920" height="1080" bitrate="2000" codec="avc1.42E01E">
                    <![CDATA[https://example.com/media/hd-video.mp4]]>
                  </MediaFile>
                  <MediaFile delivery="progressive" type="video/mp4" width="1280" height="720" bitrate="1200" codec="avc1.42E01E">
                    <![CDATA[https://example.com/media/720p-video.mp4]]>
                  </MediaFile>
                </MediaFiles>
                <TrackingEvents>
                  <Tracking event="start"><![CDATA[https://example.com/track/start]]></Tracking>
                  <Tracking event="firstQuartile"><![CDATA[https://example.com/track/q1]]></Tracking>
                  <Tracking event="midpoint"><![CDATA[https://example.com/track/midpoint]]></Tracking>
                  <Tracking event="thirdQuartile"><![CDATA[https://example.com/track/q3]]></Tracking>
                  <Tracking event="complete"><![CDATA[https://example.com/track/complete]]></Tracking>
                  <Tracking event="progress" offset="00:00:10"><![CDATA[https://example.com/track/progress10]]></Tracking>
                  <Tracking event="mute"><![CDATA[https://example.com/track/mute]]></Tracking>
                  <Tracking event="unmute"><![CDATA[https://example.com/track/unmute]]></Tracking>
                </TrackingEvents>
                <VideoClicks>
                  <ClickThrough id="click-through-1"><![CDATA[https://advertiser.com/landing]]></ClickThrough>
                  <ClickTracking id="click-track-1"><![CDATA[https://example.com/click-track]]></ClickTracking>
                  <CustomClick id="custom-1"><![CDATA[https://example.com/custom-click]]></CustomClick>
                </VideoClicks>
              </Linear>
            </Creative>
          </Creatives>
          <AdVerifications>
            <Verification vendor="example.com-omid">
              <JavaScriptResource apiFramework="omid" browserOptional="false">
                <![CDATA[https://verification.com/omid.js]]>
              </JavaScriptResource>
              <TrackingEvents>
                <Tracking event="verificationNotExecuted"><![CDATA[https://verification.com/not-executed]]></Tracking>
              </TrackingEvents>
              <VerificationParameters><![CDATA[{"key": "value"}]]></VerificationParameters>
            </Verification>
          </AdVerifications>
        </InLine>
      </Ad>
    </VAST>
    """
  end
end