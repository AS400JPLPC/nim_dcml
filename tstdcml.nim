import dcml/dcml
import strformat


var a = newDcml(10,2)

var aa = newDcml(8,2)

aa:=10
a:=aa
echo fmt"a:=aa {$a}"
echo fmt"a:=aa {a.entier}"

var Iint: int = 10
a:=Iint
echo fmt"Iint {$a}"

var Iint8: int8 = 10
a:=Iint8
echo fmt"Iint8 {$a}"

var Iint16: int16 = 10
a:=Iint16
echo fmt"Iint16 {$a}"

var Iint32: int32 = 10
a:=Iint32
echo fmt"Iint32 {$a}"

var Iint64: int64 = 10
a:=Iint64
echo fmt"Iint64 {$a}"

var Uint: uint = 10
a:=Uint
echo fmt"Uint {$a}"

var Uint8: uint8 = 10
a:=Uint8
echo fmt"Uint8 {$a}"

var Uint16: uint16 = 10
a:=Uint16
echo fmt"Uint16 {$a}"

var Uint32: uint32 = 10
a:=Uint32
echo fmt"Uint32 {$a}"

var Uint64: uint64 = 10
a:=Uint64
echo fmt"Uint64 {$a}"



var Fl : float = 10.1234


#pour test Rtrim   mettre setDcml(float) commentaire a.Rtrim
a:=Fl
echo fmt"float = 10.1234  {$a}"
a.Rtrim
echo fmt"a.Rtrim {$a}"
Fl=10
a:=Fl
echo fmt"float = 10  {$a}"
a.Rtrim
echo fmt"a.Rtrim {$a}"
Fl=10.10
a:=Fl
echo fmt"float = 10.10  {$a}"
a.Rtrim
echo fmt"a.Rtrim {$a}"

a:="10"
a+=10
echo fmt"a+=10 {$a}"
a-=10
echo fmt"a-=10 {$a}"
a*=10
echo fmt"a*=10 {$a}"
a/=10
echo fmt"a/=10 {$a}"
a//=10
echo fmt"a//=10 {$a}"
a:="10"
a^=10
echo fmt"a^=10 {a.debug}"

a:=10

var b = clone(a)

a:=10
a+=b
echo fmt"a+=b {$a}"
a-=b
echo fmt"a-=b {$a}"
a*=b
echo fmt"a*=b {$a}"
a/=b
echo fmt"a/=b {$a}"
a//=b
echo fmt"a//=b {$a}"


var e = newDcml(20,2)
var i:int = 10
e:=i
echo fmt"e {$e}"
e^=b
echo fmt"e^=b {e.debug()}"
e.Rtrim()
echo fmt"e.Rtrim() {$e}"

a:=10


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

a:=1

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





echo ""
echo fmt" clone(a) {$b}"


echo ""
b+=22.96
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
echo fmt" test delete (a)  a =nil "
a =nil
echo ""
echo fmt" redefinition var (a)  mauvais coding  only test  a = newDcml(10,2)"
a = newDcml(10,2)
a:=10


b:=20
c:=3
var d = newDcml(15,2)




echo ""
d.rem(a, c)
echo fmt" d.rem(a, b) {$d}"


echo ""
d.divint(a,c)
echo fmt" d.divint(a,c) {$d}"


echo ""
d:=3.98
d.truncate()
echo fmt" d.truncate() {$d}"


echo ""
d:=3.9800000
echo fmt"c:=3.9800000 {$d}"
d.Rtrim()
echo fmt" d.Rtrim() {$d} \\n"


echo ""
d:=10.1
d.Rjust()
echo fmt" d.Rjust() {$d}"


echo ""
d:=10
d.Valide()
echo fmt" d.Valide() {$d}"

echo ""
d:=10.123456789
d.Round(3)
echo fmt" d.Round(3)  {$d}" 


echo ""
d:=10.12345
echo fmt"d:=10.12345 {$d}"
if d.isErr() : echo $d
else : echo "var d invalide format "


# erreur
echo ""
a:="123456789012.12345"
echo fmt"d:=123456789012.12345 "
if a.isErr():
  echo fmt" a.isErr() {a.debug()}"

a:=30



echo fmt"{$a} + {$b} + {$c}"
a.eval( "+",$b,"+",$c)

echo $a

a:=100

echo fmt"{$a} / 100 * 4 + {$a}"
a.eval( "/",100,"*",4, "+" ,$a)

echo $a

a:=100
echo fmt"{$a} % 4 +$a"
a.eval("%", 4 , "+" ,$a)

echo $a


a:=100
echo fmt"{$a} +% 4"
a.eval( "+%",4)

echo $a

a:=100
echo fmt"{$a} -% 4"
a.eval("-%" , 4)

echo $a

#[
echo "erreur"
a.eval("-%","aaa")

echo $a
]#



var article    :string  =""
var poids      = newDcml(3,1)  # tonnes ex 1.5 tonnes
var prixBase   = newDcml(8,2)  # montant achat de la tonne
var prixGramme = newDcml(3,15) # montant achat du gramme
var refund     = newDcml(2,2)  # % refund
var prixAchat  = newDcml(8,2)  # montant achat
var poidsUnite = newDcml(5,1)  # poids en grammes de l'article
var prixBrut   = newDcml(4,15) # prix brut de l'article
var increase   = newDcml(2,3)  # % increase usinage spécifique 
var prixFab    = newDcml(4,15) # prix fabrication brut + 40% gestion salaire investissement ....
var poidsFab   = newDcml(5,2)  # poids d'un article à la fabrication gramme
var nbrArticle = newDcml(15,0) # nombre d'artcile fab maxi.
var prixVente  = newDcml(4,2)  # prix de vente unitaire de base
var gainUnite  = newDcml(4,15) # profit sur un article

var benefice   = newDcml(18,2) # benefice par tonne


article = "vis Acier"
# 2 tonnes
poids := 5

# 450€ tonne
prixBase := 450

# 0.000450€ gr
prixGramme.eval("=",$prixBase,"/" ,1000000)


# remise
refund := 1.5
prixAchat.eval("=", $poids , "*", $prixBase, "+%",$refund)


# poids 1 vis
poidsUnite := 1.2
# gache
increase := 0.005

# poids fabrication
poidsFab.eval("=" ,$poidsUnite, "+%", $increase)



# calcul du prix de fabrication
prixFab.eval("=", $poidsUnite, "+%",$increase,"*" ,$prixGramme,"+%",40)

# calcul du nombre article  
nbrArticle.eval("=",$poids, "*",1000000, "/", $poidsFab , "-%", 0.001)


echo fmt" Poids :  {$poids} tonnes   PrixBase : {$prixbase} remise : {$refund}  prixAchat = {$prixAchat} "
echo " "
echo fmt" poidsUnite : {$poidsUnite} grm +  gache : {$increase}%   * prixGramme : {$prixgramme} + 40% (frais gestion Entreprise)  Prix de fabrication = {$prixFab}"

echo fmt" poids: {$poids} * 1000000 (poids en gramme)  / poidFab : {$poidsFab} grm  - 0.001% de perte manutention   Nombre article = {$nbrArticle}"

prixVente := 0.10 #cts soit 1€ les dix

gainUnite.eval( "=" , $prixVente , "-" , $prixFab )

echo fmt"gainUnite sur un article {gainUnite}"

benefice.eval("=" , $gainUnite ,  "*" ,$nbrArticle , "-", $prixAchat )


echo fmt"benefice effet de masse  gainUnite: {$gainUnite}   * nbrArticle: {$nbrArticle }  - prixAchat: {$prixAchat} benefice= {$benefice}"

echo "fin"
