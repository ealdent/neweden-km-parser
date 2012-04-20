class KillmailParser
  REGEXP_PRIMITIVES = {
    :victim_name =>         "Victim: (.*)",
    :corp =>                "Corp: (.*)",
    :alliance =>            "Alliance: (.*)",
    :faction =>             "Faction: (.*)",
    :destroyed =>           "Destroyed: (.*)",
    :system =>              "System: (.*)",
    :security =>            "Security: (-?\\d{1,2}\\.\\d{1,2})",
    :damage_taken =>        "Damage Taken: (-?\\d+)",
    :name =>                "Name: (.*)",
    :ship =>                "Ship: (.*)",
    :weapon =>              "Weapon: (.*)",
    :damage_done =>         "Damage Done: (-?\\d+)",
    :involved_parties =>    "Involved parties:",
    :date =>                "\\d{4}\\.\\d{2}\\.\\d{2} \\d{2}:\\d{2}:\\d{2}"
  }

  attr_reader :killmail, :date, :victim, :attackers, :destroyed_items, :dropped_items

  def initialize(killmail)
    @valid = false
    @killmail = killmail.to_s.dup.freeze
    process
  end

  def parse_victim_and_date(pbody)
    raise "Could not parse victim and date" if pbody.nil? || pbody.empty?

    header, pbody = pbody.split("Involved parties:").map { |txt| txt.strip }
    date, victim = header.split("\n\n").map { |txt| txt.strip }
    [date, victim, pbody]
  end

  def parse_attackers(pbody)
    raise "Could not parse attackers" if pbody.nil? || pbody.empty?

    split_on = if pbody =~ /Destroyed items:/
      @has_destroyed = true
      'Destroyed items:'
    elsif pbody =~ /Dropped items:/
      @has_destroyed = false
      'Dropped items:'
    else
      @has_destroyed = false
      nil
    end

    attacker_txt, pbody = if split_on
      pbody.split(split_on).map { |txt| txt.strip }
    else
      [pbody.strip, nil]
    end

    attackers = attacker_txt.split("\n\n").map { |txt| txt.strip }
    [attackers, pbody]
  end

  def parse_destroyed_items(pbody)
    return [nil, nil] if pbody.nil? || pbody.empty?

    if pbody =~ /Dropped items:/
      pbody.split("Dropped items:").map { |txt| txt.strip }
    else
      [pbody.strip, nil]
    end
  end

  def process
    date, victim, pbody = parse_victim_and_date(@killmail)
    attackers, pbody = parse_attackers(pbody)
    destroyed, pbody = parse_destroyed_items(pbody) if pbody && @has_destroyed
    dropped = pbody.nil? ? nil : pbody.strip

    @date = DateTime.parse(date)

    victim_match = _victim.match(victim)
    @victim = {
      :name => victim_match[1],
      :corp => victim_match[2],
      :alliance => victim_match[3],
      :faction => victim_match[4],
      :ship => victim_match[5],
      :system => victim_match[6],
      :security => victim_match[7],
      :damage => victim_match[8]
    }

    @attackers = []
    attackers.each do |attacker|
      attacker_match = _attacker.match(attacker)
      @attackers << {
        :name =>        attacker_match[1],
        :security =>    attacker_match[2],
        :corp =>        attacker_match[3],
        :alliance =>    attacker_match[4],
        :faction =>     attacker_match[5],
        :ship =>        attacker_match[6],
        :weapon =>      attacker_match[7],
        :damage =>      attacker_match[8]
      }
    end

    @destroyed_items = []
    @dropped_items = []
    [[destroyed, @destroyed_items], [dropped, @dropped_items]].each do |body, items|
      body.to_s.split(/[\n\r]+/).each do |item|
        item_match = _item.match(item.strip)
        qty, loc = if item_match[3] && item_match[3] =~ /^\d+/
          [item_match[3], item_match[5]]
        elsif item_match[3]
          [1, item_match[3]]
        else
          [1, nil]
        end

        items << {
          :name => item_match[1],
          :quantity => qty.to_i,
          :location => loc
        }
      end
    end

    @hash = {
      :victim => @victim,
      :attackers => @attackers,
      :destroyed_items => @destroyed_items,
      :dropped_items => @dropped_items,
      :date => @date
    }

    @valid = true
  end

  def valid?
    @valid
  end

  def to_hash
    @hash
  end

  def to_json
    @hash.to_json
  end

  def _item
    /^([^,]*)(, Qty: (\d+))?( \((.*)\))?$/
  end

  def _victim
    Regexp.new(%{#{_victim_name}\n#{_corp}\n#{_alliance}\n#{_faction}\n#{_destroyed}\n#{_system}\n#{_security}\n#{_damage_taken}})
  end

  def _attacker
    Regexp.new(%{#{_name}\n#{_security}\n#{_corp}\n#{_alliance}\n#{_faction}\n#{_ship}\n#{_weapon}\n#{_damage_done}})
  end

  REGEXP_PRIMITIVES.each_pair do |name, regexp|
    class_eval <<-RUBY
      def _#{name}
        #{regexp.inspect}
      end
    RUBY
  end
end