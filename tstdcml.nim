import ./dcml/dcml
import strformat

var a = newDcml(5,2)

a.setDcml("10")

echo $a


a+10
echo fmt"a+10 {$a}"
a-10
echo fmt"a-10 {$a}"
a*10
echo fmt"a*10 {$a}"
a/10
echo fmt"a/10 {$a}"
a//10
echo fmt"a//10 {$a}"
a.setDcml("10")
a^10
echo fmt"a^10 {$a}"

a.setDcml("10")
var b = clone(a)
a.setDcml("10")
a+b
echo fmt"a+b {$a}"
a-b
echo fmt"a-b {$a}"
a*b
echo fmt"a*b {$a}"
a/b
echo fmt"a/b {$a}"
a//b
echo fmt"a//b {$a}"
a.setDcml("10")
a^b
echo fmt"a^b {$a}"




delDcml(a)


echo ""
echo fmt" clone(a) {$b}"


echo ""
b+22.96
echo fmt" b+22.96 {$b}"


echo ""
var c = newDcml(5,2)
c.ceil(b)
echo fmt" c.ceil(b) {$c}"


echo ""
c.floor(b)
echo fmt" c.floor(b) {$c}"



echo ""
c.plus()
echo fmt" c.plus() {c.signed()}"


echo ""
c.minus()
echo fmt" c.plus() {$c}"


echo ""
a.setDcml("10")
b.setDcml("20")
c.setDcml("3")
var d = newDcml(15,2)
d.fma( a, b, c)
echo fmt" d.fma( a, b, c) {$d}"


echo ""
d.rem(a, c)
echo fmt" d.rem(a, b) {$d}"


echo ""
d.divint(a,c)
echo fmt" d.divint(a,c) {$d}"


echo ""
c.setDcml("3.98")
d.truncate()
echo fmt" d.truncate() {$d}"


echo ""
d.setDcml("3.9800000")
echo fmt"c.setDcml('3.9800000') {$d}"
d.reduce()
echo fmt" d.reduce() {$d} \\n"


echo ""
d.setDcml("10.1")
d.Rjust()
echo fmt" d.Rjust() {$d}"


echo ""
d.setDcml("10")
d.Valide()
echo fmt" d.Valide() {$d}"

echo ""
d.setDcml("10.123456789")
d.Round(3)
echo fmt" d.Round(3) {$d}"


echo ""
d.setDcml("10.12345")
echo fmt"d.setDcml('10.12345') {$d}"
if d.isErr() : echo $d
else : echo "var d invalide format "

echo ""
a.setDcml("123456.12345")
echo fmt"d.setDcml('123456.12345') {$a}"
a.Valide()
echo fmt" d.Valide() {$a}"