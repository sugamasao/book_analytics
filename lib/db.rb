require 'pathname'
require 'active_record'

module DB

  # @return [ActiveRecord::ConnectionAdapters::SQLite3Adapter] connection object
  def self.connect_database
    spec = if ENV['DATABASE_URL']
      ENV['DATABASE_URL'] + '?pool=15'
    else
      {adapter: 'sqlite3', database: self.local_database_path}
    end

    ActiveRecord::Base.establish_connection(spec)
    ActiveRecord::Base.connection
  end

  def self.local_database_path
    path = Pathname.new(__dir__).parent.join('db', 'database.sqlite3')
    path.parent.mkpath
    path.to_s
  end

end

