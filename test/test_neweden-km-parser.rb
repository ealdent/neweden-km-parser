require 'helper'

class TestNewedenKmParser < Test::Unit::TestCase
  context "a generic killmail" do
    should "parse without error" do
      kmp = KillmailParser.new(EXAMPLE_KILLMAILS['km_generic.txt'])
    end

    context "after parsing" do
      setup do
        @kmp = KillmailParser.new(EXAMPLE_KILLMAILS['km_generic.txt'])
      end

      should "have the correct date" do
        assert_equal @kmp.date, DateTime.parse("2012-02-26 03:42:00")
      end

      should "have the correct victim" do
        assert_equal @kmp.victim[:name], 'Roboticus420'
        assert_equal @kmp.victim[:corp], 'Ever Flow'
        assert_equal @kmp.victim[:alliance], 'Northern Coalition.'
        assert_equal @kmp.victim[:faction], 'Unknown'
        assert_equal @kmp.victim[:ship], 'Basilisk'
        assert_equal @kmp.victim[:system], 'O1-FTD'
        assert_equal @kmp.victim[:security], '-0.4'
        assert_equal @kmp.victim[:damage], '20738'
      end

      should "have the correct number of attackers" do
        assert_equal @kmp.attackers.count, 2
      end

      should "have the correct attackers" do
        assert_equal @kmp.attackers[0][:name], 'Angel Drade'
        assert_equal @kmp.attackers[0][:security], '-3.70'
        assert_equal @kmp.attackers[0][:corp], 'SQUINGEL'
        assert_equal @kmp.attackers[0][:alliance], 'Nulli Tertius'
        assert_equal @kmp.attackers[0][:faction], 'None'
        assert_equal @kmp.attackers[0][:ship], 'Hurricane'
        assert_equal @kmp.attackers[0][:weapon], 'Hurricane'
        assert_equal @kmp.attackers[0][:damage], '19235'

        assert_equal @kmp.attackers[1][:name], 'SkippyTheWonderTard'
        assert_equal @kmp.attackers[1][:security], '3.10'
        assert_equal @kmp.attackers[1][:corp], 'Kickass inc'
        assert_equal @kmp.attackers[1][:alliance], 'Nulli Tertius'
        assert_equal @kmp.attackers[1][:faction], 'None'
        assert_equal @kmp.attackers[1][:ship], 'Hurricane'
        assert_equal @kmp.attackers[1][:weapon], 'Hurricane'
        assert_equal @kmp.attackers[1][:damage], '1503'
      end

      should "have the correct number of destroyed items" do
        assert_equal @kmp.destroyed_items.count, 3
      end

      should "have the correct destroyed items" do
        assert_equal @kmp.destroyed_items[0][:name], 'Photon Scattering Field II'
        assert_equal @kmp.destroyed_items[0][:quantity], 1
        assert_equal @kmp.destroyed_items[0][:location], nil

        assert_equal @kmp.destroyed_items[1][:name], 'Reactor Control Unit II'
        assert_equal @kmp.destroyed_items[1][:quantity], 2
        assert_equal @kmp.destroyed_items[1][:location], nil

        assert_equal @kmp.destroyed_items[2][:name], 'Warrior II'
        assert_equal @kmp.destroyed_items[2][:quantity], 3
        assert_equal @kmp.destroyed_items[2][:location], 'Drone Bay'
      end

      should "have the correct number of dropped items" do
        assert_equal @kmp.dropped_items.count, 3
      end

      should "have the correct dropped items" do
        assert_equal @kmp.dropped_items[0][:name], 'Large S95a Partial Shield Transporter'
        assert_equal @kmp.dropped_items[0][:quantity], 3
        assert_equal @kmp.dropped_items[0][:location], nil

        assert_equal @kmp.dropped_items[1][:name], 'Warrior II'
        assert_equal @kmp.dropped_items[1][:quantity], 2
        assert_equal @kmp.dropped_items[1][:location], 'Drone Bay'

        assert_equal @kmp.dropped_items[2][:name], 'Damage Control II'
        assert_equal @kmp.dropped_items[2][:quantity], 1
        assert_equal @kmp.dropped_items[2][:location], nil
      end
    end
  end

  context "a pod mail with implants" do
    should "parse without error" do
      kmp = KillmailParser.new(EXAMPLE_KILLMAILS['km_podmail_w_implants.txt'])
    end
  end

  context "a pod mail with no implants" do
    should "parse without error" do
      kmp = KillmailParser.new(EXAMPLE_KILLMAILS['km_podmail_wo_implants.txt'])
    end
  end

  context "a degenerate killmail with no dropped items" do
    should "parse without error" # do
    #   kmp = KillmailParser.new(EXAMPLE_KILLMAILS['km_degenerate_dropped.txt'])
    # end
  end

  context "a degenerate killmail with no destroyed items" do
    should "parse without error"
  end
end
