import ./dcml/dcml
import strformat


var a = newDcml(20,2)


try:
  a.fromString("12345678901234567890.1234")
  echo $a ,"---", $a
  echo  "--- newDcml(20,2)"
  a.Valide()
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg

if  a.isErr() :
  echo "probleme non conforme"

a+10
echo  fmt"a+10   {$a}  Entier  {a.entier} Scale {a.scale}"
a+=10
echo  fmt"a+=10  {$a}  Entier  {a.entier} Scale {a.scale}"
a-10
echo  fmt"a-10   {$a}  Entier  {a.entier} Scale {a.scale}"
a-=10


echo  fmt"a-=10  {$a}  Entier  {a.entier} Scale {a.scale}"
a*10
echo  fmt"a*10   {$a}  Entier  {a.entier} Scale {a.scale}"

a*=10
echo  fmt"a*=10  {$a}  Entier  {a.entier} Scale {a.scale}"

a/10
echo  fmt"a/10   {$a}  Entier  {a.entier} Scale {a.scale}"
a/=10
echo  fmt"a/=10  {$a}  Entier  {a.entier} Scale {a.scale}"



var b = newDcml(3,1)
try:
  b.fromString("123.4")
  echo  "--- Valide(3,1)  max 38"
  b.Valide()
  echo  fmt"{$b}  Entier  {b.entier} Scale {b.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg 
  echo " valeur conservé : ",$b 

a.fromString("123.4")

echo fmt" a == b { a == b }"
echo fmt" a >= b { a >= b }"
echo fmt" a > b { a > b }"
echo fmt" a <= b { a <= b }"
echo fmt" a < b { a < b }"

echo fmt" a == b { a == 10 }"
echo fmt" a >= b { a >= 10 }"
echo fmt" a > b { a > 10 }"
echo fmt" a <= b { a <= 10 }"
echo fmt" a < b { a < 10 }"


a.fromString("123.4")
b.fromString("3")
var x = newdecimal()
x.copyData(a)
x.rem(b)
echo  fmt"rem {$x}  Entier  {x.entier} Scale {x.scale}"

var y = newdecimal()
x.copyData(a)
y.copyData(a)
echo  fmt"{$a} * {$b} + {$x} = {$y}  "
y.fma(b,x)
echo  fmt"a.fma(b,x)  {$a} * {$b} + {$x} = {$y}  "
y.fromString("31")
x.fromString("3")
echo  fmt"{$y} / {$x}  "
y.divint(x)
echo  fmt" y.divint(x)  31 / 3 = {$y}  resultats int "
b.fromString("31")
b//(x)
echo  fmt" b//(x)  31 // {$x} = {$b}  resultats int "
b.fromString("31")
x.fromString("3")
b^(x)
echo  fmt" b^(x)  31 ^ {$x} = {$b}  "


b = newDcml(34,4)
try:
  b.fromString("-1234567890123456789012345678901234.1234")
  echo  "--- Valide(34,4)  max 38"
  b.Valide()
  echo  fmt"{$b}  Entier  {b.entier} Scale {b.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg 
  echo " valeur conservé : ",$b 


var c = newDcml(15,1)
try:
  c.fromString("123456789012345.1234")
  echo  "--- newDcml(15,1)"
  c.Valide()
  echo  fmt"{$c}  Entier  {c.entier} Scale {c.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg

try:
  a.fromString("123")
  echo  " 123 --- newDcml(20,2)"
  a.Valide
  echo  $a
  a.aRound(0) 
  echo  fmt"  a.aRound(0)  {$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg




try:
  a.fromString("321.0")
  echo  "321.0--- newDcml(20,2)"
  a.Valide()
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let 
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg




try:
  a.fromString("0.12")
  echo  "0.12--- newDcml(20,2)"
  a.Valide()
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg


try:
  a.fromString("0.123456")
  echo  "0.123456---a.aRound(3)"
  a.aRound(3)
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg




try:
  a.fromString("-321")
  echo fmt" ----------------------a {$a}"
  echo  "-321---- newDcml(20,2)"
  a.Valide()
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg
  


try:
  a.fromString("5000.69874")
  echo  "---  5000.69874  a.aRound(0) newDcml(20,2)"
  a.aRound(0)
  echo  fmt"a.aRound(0) {$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg


echo "----------"
echo  "---a = newDcml(4,0)   199"
a = newDcml(4,0)
a.fromString("5000.68494")
echo "202"
a.aRound(3)
echo  fmt"a.aRound(3) {$a}  Entier  {a.entier} Scale {a.scale}"
echo "204"

a.Valide()
echo  fmt"a.Valide() {$a}  Entier  {a.entier} Scale {a.scale} "
echo "----------"


try:
  var d = newDcml(3,0)
  d.fromString("333.0")
  echo  "333--- newDcml(3,0)"
  echo  fmt"{$d}   isErr  {d.isErr()}    entier  {d.entier} scale {d.scale}"
  if d.isErr() :
    d.Valide()
  echo  fmt"{$d}   isErr  {d.isErr()}    entier  {d.entier} scale {d.scale}"
except:
  let 
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg


try:
  var e = newDcml(0,2)
  e.fromString(".1")
  e.ajustRzeros()
  echo $e
  echo  "0--- newDcml(0,2)"
  echo  fmt"{$e}   isErr  {e.isErr()}    entier  {e.entier} scale {e.scale}"

  e.Valide()
  echo  fmt"{$e}   isErr  {e.isErr()}    entier  {e.entier} scale {e.scale}"
except:
  let 
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg

a.fromString("5000.68654")
echo "---$$$$$$  a.fromString(\"5000.68654\")  ---"
echo $a
echo  fmt"{$a}   isErr  {a.isErr()}    entier  {a.entier} scale {a.scale}"
a.Valide()

echo  fmt"{$a}   isErr  {a.isErr()}    entier  {a.entier} scale {a.scale}"
echo "---$$$$$$---"

echo "----------"
echo  "---nx = newDcml(4,0)"
var nx = newDcml(4,0)
nx.fromString("5000.68494")
echo $nx
nx.aRound(3)
echo  fmt"nx.aRound(3) {$nx}  Entier  {nx.entier} Scale {nx.scale}"
nx.Valide()
echo  fmt"nx.Valide() {$nx}  Entier  {nx.entier} Scale {nx.scale} "





type Person = object
  nom: string
  salair: DecimalType 



var prs : Person
prs.salair=newDcml(20,2)





prs.salair.fromString("19000")
prs.nom = "JP"

echo fmt"{$prs.salair}"

prs.salair+=float(1000000.95)
echo fmt"{$prs.salair} {prs.salair.entier} {prs.salair.scale}  "

prs.salair.Valide()

echo fmt"{$prs.salair} {prs.salair.entier} {prs.salair.scale}  "




try:
  var  f: DecimalType = newDecimal("aa")
  echo " OK   f"
except:
  let msg = getCurrentExceptionMsg()
  echo "Got exception ", msg