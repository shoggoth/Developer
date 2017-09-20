require 'sqlite3'

db = SQLite3::Database.new("test.db")
rows = db.execute("select * from users")
p rows[0]
