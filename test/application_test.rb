ENV["RACK_ENV"] = "test"

require "fileutils"
require "tmpdir"
require "minitest/autorun"
require "net/http"
require "socket"

# Never open the checked-in dictionary or a developer's database in tests.
source = File.expand_path("..", __dir__)
directory = Dir.mktmpdir("2sek-test-")
%w[application.rb config.ru config lib views public].each do |path|
  FileUtils.cp_r(File.join(source, path), directory)
end
FileUtils.mkdir_p(File.join(directory, "db"))
Dir.chdir(directory) { require File.join(directory, "application") }
Ordbook.set :root, directory
Minitest.after_run do
  Database.disconnect
  FileUtils.remove_entry(directory)
end

class ApplicationTest < Minitest::Test
  def setup
    Word.dataset.delete
    Word.create(word: "apple", definition: "æble", lang: "en")
    Word.create(word: "æble", definition: "apple", lang: "da")
    @request = Rack::MockRequest.new(Ordbook.new)
  end

  def test_home_page
    response = @request.get("/")
    assert_equal 200, response.status
    assert_includes response.body, "word_search_form"
    assert_includes response["cache-control"], "public"
  end

  def test_case_insensitive_prefix_lookup
    response = @request.get("/lookup.json?q=APP")
    assert_equal 200, response.status
    assert_includes response["content-type"], "application/json"
    words = JSON.parse(response.body).fetch("words")
    assert_equal ["apple"], words.map { |word| word.fetch("word") }
    assert_equal "æble", words.first.fetch("definition")
  end

  def test_danish_lookup
    response = @request.get("/lookup.json?q=%C3%A6")
    assert_equal ["æble"], JSON.parse(response.body).fetch("words").map { |word| word.fetch("word") }
  end

  def test_no_matches
    response = @request.get("/lookup.json?q=unmatched")
    assert_equal 200, response.status
    assert_empty JSON.parse(response.body).fetch("words")
  end

  def test_lookup_is_sorted_and_limited
    25.times { |index| Word.create(word: "test%02d" % index, definition: "fixture", lang: "en") }
    response = @request.get("/lookup.json?q=test")
    words = JSON.parse(response.body).fetch("words").map { |word| word.fetch("word") }
    assert_equal 20, words.size
    assert_equal (0...20).map { |index| "test%02d" % index }, words
  end

  def test_static_asset_and_missing_route
    assert_equal 200, @request.get("/application.css").status
    assert_equal 404, @request.get("/missing").status
  end

  def test_production_puma_boot_and_http_request
    listener = TCPServer.new("127.0.0.1", 0)
    port = listener.addr[1]
    listener.close
    pid = Process.spawn(
      { "RACK_ENV" => "production", "PORT" => port.to_s },
      RbConfig.ruby, "-S", "puma", "-C", "config/puma.rb",
      chdir: Ordbook.root, out: File::NULL, err: File::NULL
    )
    response = nil
    100.times do
      begin
        response = Net::HTTP.start("127.0.0.1", port, nil, open_timeout: 1, read_timeout: 1) { |http| http.get("/") }
        break
      rescue Errno::ECONNREFUSED
        sleep 0.1
      end
    end
    refute_nil response, "Puma must become ready within ten seconds"
    assert_equal "200", response.code
    assert_includes response.body, "word_search_form"
  ensure
    if pid
      Process.kill("TERM", pid) rescue Errno::ESRCH
      Process.wait(pid)
    end
  end
end
