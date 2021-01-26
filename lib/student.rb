require_relative "../config/environment.rb"
require 'pry'
class Student
    attr_accessor :name, :grade
    attr_reader :id
    

    def initialize(id = nil, name, grade)
      @id = id
      @name = name
      @grade = grade
    end

    def self.create_table
      query =<<-TAB
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT, 
        grade TEXT
      );
      TAB
      DB[:conn].execute(query)
    end

    def self.drop_table
      query =<<-TAB
      DROP TABLE IF EXISTS students
      TAB
      DB[:conn].execute(query)
    end

    def save
      if self.id
        self.update
      else
        query =<<-SQL
          INSERT INTO students(name, grade)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(query, self.name, self.grade)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def update
      query = "UPDATE students 
      SET name = ?, grade = ?
      WHERE id = ?"
      DB[:conn].execute(query, self.name, self.grade, self.id)
    end

    def self.create(name, grade)
      student = Student.new(name, grade)
      student.save
      student
    end

    def self.new_from_db(row)
      # new_student = self.new WHY_NOT_THIS?
      # new_student.id = row[0]
      # new_student.name = row[1]
      # new_student.grade = row[2]
      # new_student
      # Mass Assignment
      # row = [1,"pat", 12]
      id, name, grade = row
      # id = row[0]
      # name = row[1]
      # grade = row[2]
      self.new(id, name, grade)
    end

    def self.find_by_name(name)
      query = <<-TAB
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
      TAB
      DB[:conn].execute(query, name).map do |row|
        self.new_from_db(row)
      end.first
    end


  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]


end
