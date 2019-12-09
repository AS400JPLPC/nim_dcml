import db_sqlite, math
import strformat
import Zoned
import dcml/dcml
let db = open("mytest.db", "", "", "")

db.exec(sql"DROP TABLE IF EXISTS my_table")
db.exec(sql"""CREATE TABLE my_table (
                 id    INTEGER PRIMARY KEY,
                 name  VARCHAR(50) NOT NULL,
                 i     INT(11),
                 f     DECIMAL(18, 10)
              )""")
var f = newDcml(18,10)

db.exec(sql"BEGIN")
for i in 1..1000:
  f.eval("=",i , "+" ,1 , "/" ,7.2)
  db.exec(sql"INSERT INTO my_table (name, i, f) VALUES (?, ?, ?)",
          "Item#" & $i, i, $f)
db.exec(sql"COMMIT")

for x in db.fastRows(sql"SELECT * FROM my_table"):
  echo x

f.eval("=",1001 , "+" ,1 , "/" ,7.2)
let id = db.tryInsertId(sql"""INSERT INTO my_table (name, i, f)
                              VALUES (?, ?, ?)""",
                        "Item#1000000001", 1000000001, $f)
echo "Inserted item: ", db.getValue(sql"SELECT name FROM my_table WHERE id=?", id,)


for row in db.fastRows(sql"SELECT  f, name , id , i FROM my_table"):
  f:= row[0]
  echo  row[1] , "  ",  row[2] ," ",row[3] , "   ", $f
db.close()