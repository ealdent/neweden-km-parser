require 'helper'

class TestNewedenKmParser < Test::Unit::TestCase
  context "a generic killmail" do
    should "parse without error" do
      kmp = KillmailParser.new(EXAMPLE_KILLMAILS['km_generic.txt'])

    end
  end

  context "a degenerate killmail with no dropped items" do
    should "parse without error"
  end

  context "a degenerate killmail with no destroyed items" do
    should "parse without error"
  end
end
