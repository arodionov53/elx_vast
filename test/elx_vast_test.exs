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
