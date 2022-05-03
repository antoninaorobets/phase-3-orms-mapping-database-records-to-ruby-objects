class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(raw)
    self.new(id: raw[0], name: raw[1], album: raw[2])
  end

  def self.all
    all_songs = []
    sql =  "SELECT * FROM songs"
    DB[:conn].execute(sql).map do |row|
      all_songs << self.new_from_db(row)
    end
    all_songs
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM songs WHERE name = ?"
      self.new_from_db( DB[:conn].execute(sql, name)[0])
    
  end
end
