require 'time'
require 'active_record'

class Rank < ActiveRecord::Base

  def self.already_create?(date)
    self.find_by(update_date: date_format(date))
  end

  def self.date_format(date)
    str = date.strftime('%Y-%m-%d %H:')
    min = date.min / 20 * 20
    # 2013-10-11 12:34:55 => 2013-10-11 12:20:00
    Time.parse("#{str}#{min}:00")
  end

  def local_update_date
    self.update_date.getlocal
  end
end

