require 'time'
require 'active_record'

class Rank < ActiveRecord::Base

  def self.already_create?(date)
    self.find_by(update_date: date_format(date))
  end

  def self.date_format(date)
    # 2013-10-11 12:34:55 => 2013-10-11 12:00:00
    str = date.strftime('%Y-%m-%d %H:00:00')
    Time.parse(str)
  end

  def local_update_date
    self.update_date.getlocal
  end

  def self.permalink(date)
    query = {start_date: Time.parse("#{date.to_s} 00:00:00"), end_date: Time.parse("#{date.to_s} 23:59:59")}
    self.order('update_date DESC').where('update_date >= :start_date AND update_date <= :end_date', query)
  end

  def self.max_rank
    self.order('update_date DESC').find_by(number: self.minimum(:number))
  end
end

