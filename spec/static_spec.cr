require "./spec_helper"

PUBLIC_PATH      = "spec/public"
TEST_PUBLIC_PATH = "spec/public"

describe "Grip::Handlers::Static" do
  it "renders html" do
    request = HTTP::Request.new("GET", "/index.html")
    static = Grip::Handlers::Static.new PUBLIC_PATH

    response = create_request_and_return_io(static, request)

    response.body.should eq "<head></head><body>Hello World!</body>\n"
  end

  it "returns Not Found when file doesn't exist" do
    request = HTTP::Request.new("GET", "/not_found.html")
    static = Grip::Handlers::Static.new PUBLIC_PATH

    response = create_request_and_return_io(static, request)

    response.body.should eq "404 Not Found\n"
  end

  it "delivers index.html if path ends with /" do
    request = HTTP::Request.new("GET", "/index.html")
    static = Grip::Handlers::Static.new PUBLIC_PATH

    response = create_request_and_return_io(static, request)

    response.body.should eq "<head></head><body>Hello World!</body>\n"
  end

  it "serves the correct content type for serve file" do
    %w(png svg css js).each do |ext|
      file = File.expand_path(TEST_PUBLIC_PATH) + "/fake.#{ext}"
      File.write(file, "")
      request = HTTP::Request.new("GET", "/fake.#{ext}")
      static = Grip::Handlers::Static.new PUBLIC_PATH
      response = create_request_and_return_io(static, request)
      response.headers["content-type"].should eq(Grip::Support::MimeTypes.mime_type(ext))
      File.delete(file)
    end
  end

  it "returns Not Found when directory_listing is disabled" do
    request = HTTP::Request.new("GET", "/dist")
    static_true = Grip::Handlers::Static.new PUBLIC_PATH, directory_listing: true
    static_false = Grip::Handlers::Static.new PUBLIC_PATH # Listing is off by default in Grip

    response_true = create_request_and_return_io(static_true, request)
    response_false = create_request_and_return_io(static_false, request)

    response_true.body.should match(/index/)
    response_false.status_code.should eq 404
  end

  it "sets default response headers" do
    request = HTTP::Request.new("GET", "/index.html")
    static = Grip::Handlers::Static.new PUBLIC_PATH

    response = create_request_and_return_io(static, request)

    response.headers["Accept-Ranges"].should eq "bytes"
    response.headers["X-Content-Type-Options"].should eq "nosniff"
    response.headers["Cache-Control"].should eq "private, max-age=3600"
  end
end
