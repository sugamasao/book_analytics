require 'time'
require 'active_record'

class Rank < ActiveRecord::Base
  def self.already_create?(date)
    self.find_by(update_date: date_format(date))
  end

  def self.date_format(date)
    Time.parse(date.strftime('%Y-%m-%d %H:00:00'))
  end

  def local_update_date
    self.update_date.getlocal
  end
end

