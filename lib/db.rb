require 'fileutils'
require 'active_record'

module DB

  # @param [path] Pathname sqlite3 database path
  # @return [ActiveRecord::ConnectionAdapters::SQLite3Adapter] connection object
  def self.connect_database(path = nil)
    spec = if ENV['DATABASE_URL']
      ENV['DATABASE_URL'] + '?pool=15'
    else
      FileUtils.mkdir_p(path.dirname)
      {adapter: 'sqlite3', database: path.to_s}
    end

    ActiveRecord::Base.establish_connection(spec)
    ActiveRecord::Base.connection
  end
end

