defmodule ElxVast.TypesTest do
  use ExUnit.Case
  alias ElxVast.Types

  describe "valid_time?/1" do
    test "accepts valid time formats" do
      assert Types.valid_time?("00:00:30")
      assert Types.valid_time?("01:23:45")
      assert Types.valid_time?("23:59:59")
      assert Types.valid_time?("00:00:30.123")
      assert Types.valid_time?("01:23:45.999")
    end

    test "rejects invalid time formats" do
      refute Types.valid_time?("25:00:00")
      refute Types.valid_time?("00:60:00")
      refute Types.valid_time?("00:00:60")
      refute Types.valid_time?("1:23:45")
      refute Types.valid_time?("01:2:45")
      refute Types.valid_time?("01:23:4")
      refute Types.valid_time?("invalid")
      refute Types.valid_time?(nil)
      refute Types.valid_time?(123)
    end
  end

  describe "valid_offset?/1" do
    test "accepts valid time offsets" do
      assert Types.valid_offset?("00:00:15")
      assert Types.valid_offset?("00:00:15.000")
      assert Types.valid_offset?("01:30:45.123")
    end

    test "accepts valid percentage offsets" do
      assert Types.valid_offset?("0%")
      assert Types.valid_offset?("25%")
      assert Types.valid_offset?("50%")
      assert Types.valid_offset?("75%")
      assert Types.valid_offset?("100%")
      assert Types.valid_offset?("12.5%")
    end

    test "rejects invalid offset formats" do
      refute Types.valid_offset?("101%")
      refute Types.valid_offset?("-5%")
      refute Types.valid_offset?("25:00:00")
      refute Types.valid_offset?("invalid")
      refute Types.valid_offset?(nil)
    end
  end

  describe "valid_uri?/1" do
    test "accepts valid URIs" do
      assert Types.valid_uri?("https://example.com")
      assert Types.valid_uri?("http://example.com/path")
      assert Types.valid_uri?("//example.com")
      assert Types.valid_uri?("/relative/path")
      assert Types.valid_uri?("about:blank")
      assert Types.valid_uri?("ftp://example.com")
    end

    test "rejects invalid URIs" do
      refute Types.valid_uri?("")
      refute Types.valid_uri?("not a uri")
      refute Types.valid_uri?(nil)
      refute Types.valid_uri?(123)
    end
  end

  describe "valid_integer?/1" do
    test "accepts valid integers" do
      assert Types.valid_integer?("123")
      assert Types.valid_integer?("0")
      assert Types.valid_integer?("-42")
      assert Types.valid_integer?(456)
      assert Types.valid_integer?(0)
      assert Types.valid_integer?(-10)
    end

    test "rejects invalid integers" do
      refute Types.valid_integer?("12.34")
      refute Types.valid_integer?("abc")
      refute Types.valid_integer?("")
      refute Types.valid_integer?(nil)
      refute Types.valid_integer?(12.34)
    end
  end

  describe "valid_positive_integer?/1" do
    test "accepts valid positive integers" do
      assert Types.valid_positive_integer?("123")
      assert Types.valid_positive_integer?("1")
      assert Types.valid_positive_integer?(456)
      assert Types.valid_positive_integer?(1)
    end

    test "rejects zero and negative integers" do
      refute Types.valid_positive_integer?("0")
      refute Types.valid_positive_integer?("-42")
      refute Types.valid_positive_integer?(0)
      refute Types.valid_positive_integer?(-10)
      refute Types.valid_positive_integer?("abc")
      refute Types.valid_positive_integer?(nil)
    end
  end

  describe "valid_boolean?/1" do
    test "accepts valid boolean values" do
      assert Types.valid_boolean?("true")
      assert Types.valid_boolean?("false")
      assert Types.valid_boolean?("1")
      assert Types.valid_boolean?("0")
      assert Types.valid_boolean?(true)
      assert Types.valid_boolean?(false)
    end

    test "rejects invalid boolean values" do
      refute Types.valid_boolean?("yes")
      refute Types.valid_boolean?("no")
      refute Types.valid_boolean?("2")
      refute Types.valid_boolean?("")
      refute Types.valid_boolean?(nil)
      refute Types.valid_boolean?(123)
    end
  end

  describe "valid_mime_type?/1" do
    test "accepts valid MIME types" do
      assert Types.valid_mime_type?("video/mp4")
      assert Types.valid_mime_type?("application/javascript")
      assert Types.valid_mime_type?("image/png")
      assert Types.valid_mime_type?("text/html")
    end

    test "rejects invalid MIME types" do
      refute Types.valid_mime_type?("video")
      refute Types.valid_mime_type?("/mp4")
      refute Types.valid_mime_type?("video/")
      refute Types.valid_mime_type?("")
      refute Types.valid_mime_type?(nil)
    end
  end

  describe "valid_currency?/1" do
    test "accepts valid currency codes" do
      assert Types.valid_currency?("USD")
      assert Types.valid_currency?("EUR")
      assert Types.valid_currency?("GBP")
      assert Types.valid_currency?("JPY")
    end

    test "rejects invalid currency codes" do
      refute Types.valid_currency?("US")
      refute Types.valid_currency?("USDX")
      refute Types.valid_currency?("123")
      refute Types.valid_currency?("")
      refute Types.valid_currency?(nil)
    end
  end

  describe "position validation" do
    test "valid_x_position?/1" do
      assert Types.valid_x_position?("left")
      assert Types.valid_x_position?("right")
      assert Types.valid_x_position?("100")
      assert Types.valid_x_position?("0")

      refute Types.valid_x_position?("top")
      refute Types.valid_x_position?("center")
      refute Types.valid_x_position?("-10")
      refute Types.valid_x_position?(nil)
    end

    test "valid_y_position?/1" do
      assert Types.valid_y_position?("top")
      assert Types.valid_y_position?("bottom")
      assert Types.valid_y_position?("100")
      assert Types.valid_y_position?("0")

      refute Types.valid_y_position?("left")
      refute Types.valid_y_position?("center")
      refute Types.valid_y_position?("-10")
      refute Types.valid_y_position?(nil)
    end
  end

  describe "enumerated type validation" do
    test "valid_ad_type?/1" do
      assert Types.valid_ad_type?("video")
      assert Types.valid_ad_type?("audio")
      assert Types.valid_ad_type?("hybrid")

      refute Types.valid_ad_type?("image")
      refute Types.valid_ad_type?("")
      refute Types.valid_ad_type?(nil)
    end

    test "valid_delivery_method?/1" do
      assert Types.valid_delivery_method?("streaming")
      assert Types.valid_delivery_method?("progressive")

      refute Types.valid_delivery_method?("download")
      refute Types.valid_delivery_method?("")
      refute Types.valid_delivery_method?(nil)
    end

    test "valid_pricing_model?/1" do
      assert Types.valid_pricing_model?("CPC")
      assert Types.valid_pricing_model?("CPM")
      assert Types.valid_pricing_model?("CPE")
      assert Types.valid_pricing_model?("CPV")
      assert Types.valid_pricing_model?("cpc")
      assert Types.valid_pricing_model?("cpm")

      refute Types.valid_pricing_model?("CPA")
      refute Types.valid_pricing_model?("")
      refute Types.valid_pricing_model?(nil)
    end
  end

  describe "tracking event validation" do
    test "valid_tracking_event?/1" do
      assert Types.valid_tracking_event?("start")
      assert Types.valid_tracking_event?("firstQuartile")
      assert Types.valid_tracking_event?("midpoint")
      assert Types.valid_tracking_event?("thirdQuartile")
      assert Types.valid_tracking_event?("complete")
      assert Types.valid_tracking_event?("mute")
      assert Types.valid_tracking_event?("unmute")
      assert Types.valid_tracking_event?("pause")
      assert Types.valid_tracking_event?("resume")
      assert Types.valid_tracking_event?("skip")
      assert Types.valid_tracking_event?("creativeView")

      refute Types.valid_tracking_event?("invalid_event")
      refute Types.valid_tracking_event?("")
      refute Types.valid_tracking_event?(nil)
    end

    test "valid_verification_event?/1" do
      assert Types.valid_verification_event?("verificationNotExecuted")

      refute Types.valid_verification_event?("start")
      refute Types.valid_verification_event?("")
      refute Types.valid_verification_event?(nil)
    end
  end
end