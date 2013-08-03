require 'pathname'
require_relative 'lib/db'
require_relative 'lib/model/cover'
require_relative 'lib/model/rank'

namespace :db do
  desc 'create database'
  task :create_database do
    conn = DB.connect_database
    unless conn.table_exists?(:ranks)
      conn.create_table :ranks do |t |
        t.column :number,      :integer, null: false
        t.column :update_date, :datetime, null: false
        t.timestamps
      end
      conn.add_index :ranks, :update_date
      conn.add_index :ranks, :number
      puts 'create ranks'
    end

    unless conn.table_exists?(:books)
      conn.create_table :books do |t |
        t.column :link,             :text, null: false
        t.column :author,           :string, null: false
        t.column :binding,          :string, null: false
        t.column :isbn,             :string, null: false
        t.column :amount,           :string, null: false
        t.column :page,             :string, null: false
        t.column :publication_date, :string, null: false
        t.column :publisher,        :string, null: false
        t.column :title,            :string, null: false
        t.timestamps
      end
      puts 'create books'
    end

    unless conn.table_exists?(:covers)
      conn.create_table :covers do |t |
        t.column :label,  :string, null: false
        t.column :url,    :text
        t.column :width,  :integer
        t.column :height, :integer
        t.column :image,  :binary
        t.timestamps
      end
      conn.add_index :covers, :label, unique: true
      puts 'create covers'
    end
  end

  desc 'create initial data'
  task :init do
    conn = DB.connect_database
    %w(large medium tiny thumbnail).each do |name|
      Cover.find_or_create_by!(label: name)
    end
  end
end
namespace :local do
  desc 'create local sample data'
  task 'seed' do
    DB.connect_database
    File.readlines(File.join(__dir__, 'db', 'local_seed.txt')).each do |line|
      data = line.split(',')
      Rank.create!(number: data[0], update_date: data[1])
    end
  end
end

