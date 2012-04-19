require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'neweden-km-parser'

EXAMPLE_KILLMAILS = {}
Dir.glob(File.join(File.dirname(__FILE__), '*.txt')).map do |f|
  EXAMPLE_KILLMAILS[f.split('/').last] = File.read(f)
end

class Test::Unit::TestCase
end
