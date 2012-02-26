class KillmailParser
  FIELD_MAP = {
    'Weapon' =>       :weapon,
    'Victim' =>       :name,
    'Name' =>         :name,
    'Corp' =>         :corp,
    'Alliance' =>     :alliance,
    'Faction' =>      :faction,
    'Destroyed' =>    :ship,
    'Security' =>     :security,
    'System' =>       :system,
    'Damage Taken' => :damage,
    'Ship' =>         :ship,
    'Damage Done' =>  :damage
  }

  def initialize(killmail)
    @killmail = killmail
    process_killmail
  end

  # private

  def process_killmail
    raise "Killmail missing" if @killmail.nil? || @killmail.empty?

    lines = @killmail.split(/[\n\r]+/)
    @timestamp = DateTime.parse(lines[0]).to_time

    @victim = Victim.new(lines[1, 8])
    @involved_parties = []

    cursor = 10
    while lines[cursor] != 'Destroyed items:'
      @involved_parties << InvolvedParty.new(lines[cursor, 8])
      cursor += 8
    end

  end

  def parse_item(line_item)
    item, post = line_item.to_s.strip.split(', ')
    if post
      post_post = post.split('Qty: ')
      qty, location = post_post.split
      new_item(item, qty, location)
    else
      new_item(item)
    end
  end

  def new_item(name, quantity = nil, location = nil)
    {
      :name => name,
      :quantity => quantity || 1,
      :location => location
    }
  end
end