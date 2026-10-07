defmodule ElxVastTest do
  use ExUnit.Case
  doctest ElxVast

  describe "validate/1" do
    test "validates a minimal valid VAST 4.1 document" do
      valid_vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.1" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test Ad System</AdSystem>
            <AdServingId>test-serving-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
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

      assert {:ok, result} = ElxVast.validate(valid_vast)
      assert result.version == "4.1"
      assert result.valid == true
    end

    test "validates VAST with Error element" do
      error_vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.1" xmlns="http://www.iab.com/VAST">
        <Error><![CDATA[https://example.com/error?code=no_ads]]></Error>
      </VAST>
      """

      assert {:ok, result} = ElxVast.validate(error_vast)
      assert result.version == "4.1"
      assert result.valid == true
    end

    test "rejects VAST without version" do
      invalid_vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem>Test</AdSystem>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(invalid_vast)
      assert reason =~ "Missing required version attribute"
    end

    test "rejects VAST with invalid version" do
      invalid_vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="3.0" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem>Test</AdSystem>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(invalid_vast)
      assert reason =~ "Invalid version"
    end

    test "rejects empty VAST document" do
      invalid_vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.1" xmlns="http://www.iab.com/VAST">
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(invalid_vast)
      assert reason =~ "must contain either Ad elements or Error elements"
    end

    test "rejects malformed XML" do
      invalid_xml = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.1" xmlns="http://www.iab.com/VAST">
        <Ad id="12345"
      """

      assert {:error, reason} = ElxVast.validate(invalid_xml)
      assert reason =~ "XML processing failed"
    end

    test "rejects non-string input" do
      assert {:error, "Input must be a binary string"} = ElxVast.validate(nil)
      assert {:error, "Input must be a binary string"} = ElxVast.validate(123)
    end

    test "validates a minimal valid VAST 4.3 document" do
      valid_vast = VastValidatorTestHelper.valid_minimal_inline_vast_43()
      assert {:ok, result} = ElxVast.validate(valid_vast)
      assert result.version == "4.3"
      assert result.valid == true
    end

    test "validates a minimal valid VAST 4.2 document" do
      valid_vast = VastValidatorTestHelper.valid_minimal_inline_vast_42()
      assert {:ok, result} = ElxVast.validate(valid_vast)
      assert result.version == "4.2"
      assert result.valid == true
    end

    test "VAST 4.1 still accepted after widening version support" do
      valid_vast = VastValidatorTestHelper.valid_minimal_inline_vast()
      assert {:ok, result} = ElxVast.validate(valid_vast)
      assert result.version == "4.1"
      assert result.valid == true
    end

    test "accepts VAST 4.3 patch version" do
      vast_43_patch = String.replace(
        VastValidatorTestHelper.valid_minimal_inline_vast_43(),
        ~s(version="4.3"),
        ~s(version="4.3.1")
      )
      assert {:ok, result} = ElxVast.validate(vast_43_patch)
      assert result.version == "4.3.1"
      assert result.valid == true
    end

    test "rejects VAST version 5.0 with updated message" do
      invalid_vast = String.replace(
        VastValidatorTestHelper.valid_minimal_inline_vast_43(),
        ~s(version="4.3"),
        ~s(version="5.0")
      )
      assert {:error, reason} = ElxVast.validate(invalid_vast)
      assert reason =~ "Invalid version"
      assert reason =~ "4.1"
      assert reason =~ "4.2"
      assert reason =~ "4.3"
    end

    test "result shape identical across VAST versions" do
      {:ok, result_41} = ElxVast.validate(VastValidatorTestHelper.valid_minimal_inline_vast())
      {:ok, result_43} = ElxVast.validate(VastValidatorTestHelper.valid_minimal_inline_vast_43())

      assert Map.keys(result_41) |> Enum.sort() == Map.keys(result_43) |> Enum.sort()
      assert Map.keys(result_41) |> Enum.sort() == [:ads, :errors, :valid, :version]
    end
  end

  describe "ClosedCaptionFiles validation" do
    test "validates Linear with valid ClosedCaptionFiles" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                      <![CDATA[https://example.com/video.mp4]]>
                    </MediaFile>
                  </MediaFiles>
                  <ClosedCaptionFiles>
                    <ClosedCaptionFile language="en" type="text/vtt">
                      <![CDATA[https://example.com/captions_en.vtt]]>
                    </ClosedCaptionFile>
                  </ClosedCaptionFiles>
                </Linear>
              </Creative>
            </Creatives>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:ok, result} = ElxVast.validate(vast)
      assert result.valid == true
    end

    test "rejects ClosedCaptionFile missing language attribute" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                      <![CDATA[https://example.com/video.mp4]]>
                    </MediaFile>
                  </MediaFiles>
                  <ClosedCaptionFiles>
                    <ClosedCaptionFile type="text/vtt">
                      <![CDATA[https://example.com/captions.vtt]]>
                    </ClosedCaptionFile>
                  </ClosedCaptionFiles>
                </Linear>
              </Creative>
            </Creatives>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(vast)
      assert reason =~ "language"
    end

    test "rejects empty ClosedCaptionFiles container" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                      <![CDATA[https://example.com/video.mp4]]>
                    </MediaFile>
                  </MediaFiles>
                  <ClosedCaptionFiles>
                  </ClosedCaptionFiles>
                </Linear>
              </Creative>
            </Creatives>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(vast)
      assert reason =~ "ClosedCaptionFiles must contain at least one"
    end
  end

  describe "InteractiveCreativeFile validation" do
    test "validates Linear with valid InteractiveCreativeFile" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                      <![CDATA[https://example.com/video.mp4]]>
                    </MediaFile>
                  </MediaFiles>
                  <InteractiveCreativeFile type="text/html" apiFramework="SIMID">
                    <![CDATA[https://example.com/interactive.html]]>
                  </InteractiveCreativeFile>
                </Linear>
              </Creative>
            </Creatives>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:ok, result} = ElxVast.validate(vast)
      assert result.valid == true
    end

    test "rejects InteractiveCreativeFile missing type attribute" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4" width="640" height="480">
                      <![CDATA[https://example.com/video.mp4]]>
                    </MediaFile>
                  </MediaFiles>
                  <InteractiveCreativeFile>
                    <![CDATA[https://example.com/interactive.html]]>
                  </InteractiveCreativeFile>
                </Linear>
              </Creative>
            </Creatives>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(vast)
      assert reason =~ "type"
    end
  end

  describe "MediaFile mediaType attribute" do
    test "accepts MediaFile with mediaType attribute" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
                <Linear>
                  <Duration>00:00:30</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4" width="640" height="480" mediaType="2D">
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

      assert {:ok, result} = ElxVast.validate(vast)
      assert result.valid == true
    end

    test "accepts MediaFile without mediaType attribute" do
      vast = VastValidatorTestHelper.valid_minimal_inline_vast_43()
      assert {:ok, result} = ElxVast.validate(vast)
      assert result.valid == true
    end
  end

  describe "JavaScriptResource attribute validation" do
    test "validates JavaScriptResource with valid attributes" do
      vast = VastValidatorTestHelper.complex_valid_vast()
      assert {:ok, result} = ElxVast.validate(vast)
      assert result.valid == true
    end

    test "rejects JavaScriptResource missing apiFramework" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
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
            <AdVerifications>
              <Verification vendor="example.com">
                <JavaScriptResource>
                  <![CDATA[https://verification.com/omid.js]]>
                </JavaScriptResource>
              </Verification>
            </AdVerifications>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(vast)
      assert reason =~ "apiFramework"
    end
  end

  describe "ExecutableResource attribute validation" do
    test "validates ExecutableResource with valid attributes" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
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
            <AdVerifications>
              <Verification vendor="example.com">
                <ExecutableResource apiFramework="omid" type="application/octet-stream">
                  <![CDATA[https://verification.com/omid.bin]]>
                </ExecutableResource>
              </Verification>
            </AdVerifications>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:ok, result} = ElxVast.validate(vast)
      assert result.valid == true
    end

    test "rejects ExecutableResource missing apiFramework" do
      vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.3" xmlns="http://www.iab.com/VAST">
        <Ad id="12345">
          <InLine>
            <AdSystem version="1.0">Test</AdSystem>
            <AdServingId>test-id</AdServingId>
            <AdTitle>Test Ad</AdTitle>
            <Impression><![CDATA[https://example.com/impression]]></Impression>
            <Creatives>
              <Creative>
                <UniversalAdId idRegistry="Ad-ID">12345</UniversalAdId>
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
            <AdVerifications>
              <Verification vendor="example.com">
                <ExecutableResource>
                  <![CDATA[https://verification.com/omid.bin]]>
                </ExecutableResource>
              </Verification>
            </AdVerifications>
          </InLine>
        </Ad>
      </VAST>
      """

      assert {:error, reason} = ElxVast.validate(vast)
      assert reason =~ "apiFramework"
    end
  end

  describe "validate_file/1" do
    setup do
      # Create a temporary valid VAST file for testing
      valid_vast = """
      <?xml version="1.0" encoding="UTF-8"?>
      <VAST version="4.1" xmlns="http://www.iab.com/VAST">
        <Error><![CDATA[https://example.com/error]]></Error>
      </VAST>
      """

      temp_file = Path.join(System.tmp_dir(), "test_vast.xml")
      File.write!(temp_file, valid_vast)

      on_exit(fn -> File.rm(temp_file) end)

      {:ok, temp_file: temp_file}
    end

    test "validates file successfully", %{temp_file: temp_file} do
      assert {:ok, result} = ElxVast.validate_file(temp_file)
      assert result.version == "4.1"
      assert result.valid == true
    end

    test "handles non-existent file" do
      assert {:error, reason} = ElxVast.validate_file("non_existent_file.xml")
      assert reason =~ "File read error"
    end
  end
end
