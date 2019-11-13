import ./dcml/dcml
import strformat


var a = newDcml(20,2)

a.fromString("12345678901234567890.1234")
echo $a ,"---", $a
try:
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
b.fromString("123.4")
try:
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
b.fromString("-1234567890123456789012345678901234.1234")
try:
  echo  "--- Valide(34,4)  max 38"
  b.Valide()
  echo  fmt"{$b}  Entier  {b.entier} Scale {b.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg 
  echo " valeur conservé : ",$b 


var c = newDcml(15,1)
c.fromString("123456789012345.1234")
try:
  echo  "--- newDcml(15,1)"
  c.Valide()
  echo  fmt"{$c}  Entier  {c.entier} Scale {c.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg



a.fromString("123")
try:
  echo  " 123 --- newDcml(20,2)"
  a.Valide
  echo  $a
  a.aRound(0) 
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg




a.fromString("321.0")
try:
  echo  "321.0--- newDcml(20,2)"
  a.Valide()
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let 
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg



a.fromString("0.12")
try:
  echo  "0.12--- newDcml(20,2)"
  a.Valide()
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg


a.fromString("0.123456")
try:
  echo  "0.123456---a.aRound(3)"
  a.aRound(3)
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg


a.fromString("-321")
try:
  echo  "-321---- newDcml(20,2)"
  a.Valide()
  echo  fmt"{$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg
  

a.fromString("5000.69874")
try:
  echo  "---  5000.69874  a.aRound(0) newDcml(20,2)"
  a.aRound(0)
  echo  fmt"a.aRound(0) {$a}  Entier  {a.entier} Scale {a.scale}"
except:
  let
    msg = getCurrentExceptionMsg()
  echo "Got exception ", msg


echo "----------"
echo  "---a = newDcml(4,0)"
a = newDcml(4,0)
a.fromString("5000.68494")
echo $a
a.aRound(3)
echo  fmt"a.aRound(3) {$a}  Entier  {a.entier} Scale {a.scale}"
a.Valide()
echo  fmt"a.Valide() {$a}  Entier  {a.entier} Scale {a.scale} "
echo "----------"


a.fromString("5000.68654")
echo "---$$$$$$---"
a.Valide()

echo  fmt"{$a}   isErr  {a.isErr()}    entier  {a.entier} scale {a.scale}"
echo "---$$$$$$---"