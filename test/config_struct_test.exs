defmodule MaruSwagger.ConfigStructTest do
  use ExSpec, async: true
  doctest MaruSwagger.ConfigStruct
  alias MaruSwagger.ConfigStruct

  describe "MaruSwagger - Plug: init options" do
    defmodule BasicTest.Api do
      use Maru.Router
    end

    def init(opts) do
      [{:module, nil} | opts] |> ConfigStruct.from_opts
    end

    def api_module do
      MaruSwagger.ConfigStructTest.BasicTest.Api
    end

    it "requires :at for mounting point" do
      assert %MaruSwagger.ConfigStruct{
        path: ["swagger", "v1"],
        pretty: false,
        swagger_inject: []
      } == init(
        at: "swagger/v1",
      )
    end

    it "raises without :at" do
      assert_raise KeyError, "key :at not found in: [module: nil, for: MaruSwagger.ConfigStructTest.BasicTest.Api]", fn ->
        init(for: BasicTest.Api)
      end
    end

    it "accepts :pretty for JSON output" do
      assert %MaruSwagger.ConfigStruct{
        path: ["swagger", "v1"],
        pretty: true,
        swagger_inject: []
      } == init(
        at: "swagger/v1",
        pretty: true,
      )
    end

    it "accepts :prefix to prepend to URLs" do
      assert %MaruSwagger.ConfigStruct{
        path: ["swagger", "v1"],
        pretty: true,
        swagger_inject: []
      } == init(
        at: "swagger/v1",
        pretty: true,
      )
    end

    describe "swagger_inject" do
      @only_valid_fields  [
        host: "myapi.com",
        schemes: ["http"],
        consumes: ["application/json"],
        produces: ["application/json", "application/vnd.api+json"]
      ]

      @some_invalid_fields [
        host: "myapi.com",
        invalidbasePath: "/",
        schemes: ["http"],
        consumes: ["application/json"],
        produces: ["application/json", "application/vnd.api+json"]
      ]
      it "only allowes pre-defined fields" do
        res = init(
          at: "swagger/v1",
          swagger_inject: @only_valid_fields
        )
        assert res.swagger_inject == @only_valid_fields
      end

      it "filters non-predefined fields" do
        res = init(
          at: "swagger/v1",
          swagger_inject: @some_invalid_fields
        )
        refute res.swagger_inject == @some_invalid_fields
        assert res.swagger_inject == [
          host: "myapi.com",
          schemes: ["http"],
          consumes: ["application/json"],
          produces: ["application/json", "application/vnd.api+json"]
        ]
      end
    end
  end
end
