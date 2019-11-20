import ./dcml/dcml
import strformat

var a = newDcml(5,2)

var Iint: int = 10
a.setDcml(Iint)
echo fmt"Iint {$a}"

var Iint8: int8 = 10
a.setDcml(Iint8)
echo fmt"Iint8 {$a}"

var Iint16: int16 = 10
a.setDcml(Iint16)
echo fmt"Iint16 {$a}"

var Iint32: int32 = 10
a.setDcml(Iint32)
echo fmt"Iint32 {$a}"

var Iint64: int64 = 10
a.setDcml(Iint64)
echo fmt"Iint64 {$a}"

var Uint: uint = 10
a.setDcml(Uint)
echo fmt"Uint {$a}"

var Uint8: uint8 = 10
a.setDcml(Uint8)
echo fmt"Uint8 {$a}"

var Uint16: uint16 = 10
a.setDcml(Uint16)
echo fmt"Uint16 {$a}"

var Uint32: uint32 = 10
a.setDcml(Uint32)
echo fmt"Uint32 {$a}"

var Uint64: uint64 = 10
a.setDcml(Uint64)
echo fmt"Uint64 {$a}"



var Fl : float = 10.1234


#pour test Rtrim   mettre setDcml(float) commentaire a.Rtrim
a.setDcml(Fl)
echo fmt"float = 10.1234  {$a}"
a.Rtrim
echo fmt"a.Rtrim {$a}"
Fl=10
a.setDcml(Fl)
echo fmt"float = 10  {$a}"
a.Rtrim
echo fmt"a.Rtrim {$a}"
Fl=10.10
a.setDcml(Fl)
echo fmt"float = 10.10  {$a}"
a.Rtrim
echo fmt"a.Rtrim {$a}"

a.setDcml("10")
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

#[var e = newDcml(15,2)
var i:int = 10
e.setDcml(i)
e^b
echo fmt"e^b {$e}"
]#

a.setDcml("10")

echo fmt" a==b  {a==b}"
echo fmt" a==10 {a==10}"
echo fmt" 10==a {10==a}"

echo fmt" a<b   {a<b}"
echo fmt" a<10  {a<10}"
echo fmt" a<b   {a<b}"

echo fmt" a<=b  {a<=b}"
echo fmt" 10<=a {10<=a}"
echo fmt" a<=10 {a<=10}"

echo fmt" a>b   {a>b}"
echo fmt" a>10  {a<10}"
echo fmt" a>b   {a>b}"

echo fmt" a>=b  {a>=b}"
echo fmt" 10>=a {10<=a}"
echo fmt" a>=10 {a<=10}"

a.setDcml("1")

echo fmt" a==b  {a==b}"
echo fmt" a==10 {a==10}"
echo fmt" 10==a {10==a}"

echo fmt" a<b   {a<b}"
echo fmt" a<10  {a<10}"
echo fmt" a<b   {a<b}"

echo fmt" a<=b  {a<=b}"
echo fmt" 10<=a {10<=a}"
echo fmt" a<=10 {a<=10}"

echo fmt" a>b   {a>b}"
echo fmt" a>10  {a<10}"
echo fmt" a>b   {a>b}"

echo fmt" a>=b  {a>=b}"
echo fmt" 10>=a {10<=a}"
echo fmt" a>=10 {a<=10}"





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
echo fmt" c.minus() {$c}"


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
d.setDcml(3.98)
d.truncate()
echo fmt" d.truncate() {$d}"


echo ""
d.setDcml("3.9800000")
echo fmt"c.setDcml('3.9800000') {$d}"
d.Rtrim()
echo fmt" d.Rtrim() {$d} \\n"


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
echo fmt" d.Round(3)  {$d}" 


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