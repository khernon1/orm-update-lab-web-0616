require 'pry'
require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id
  #attr_reader :id


  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      grade INTEGER)
      SQL
      
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students 
    SQL
    
    DB[:conn].execute(sql)
  end

  def save
    if persisted?
      update
    else
      insert
    end
  end

  def update
    #UPDATE [table name] SET [column name] = [new value] WHERE [column name] = [value];
    sql = <<-SQL
      UPDATE students SET name = ? WHERE id = ?
      SQL

       DB[:conn].execute(sql, self.name, self.id)
  end

  def insert
    sql = <<-SQL
    INSERT INTO students (name, grade) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("select id from students").flatten.last
    #binding.pry
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row = {})
    #row = [nil, nil, nil]
    new_student = self.new(name, name)
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
      SQL

      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
  end

  def persisted?
    !!self.id
  end


end
