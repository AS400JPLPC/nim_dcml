# nim_dcml

- démarage projet 2019/11/05
# en test non stable

- date de mise à jour 2019/11/25
- fin des tests de contrôle de cohérence/validité dcml 2019/11/20
- simplification le 2019/11/23
  - harmonistaion en fonction de nim-decimal
  - `:=` remplace setDcml
  - supression toStr 
  - ajout debug sortie libre sans contrôle
  - modification sortie $ avec contrôle
  - suppression proc delDcml inutil veuillez utiliser nil
  - encours de test structure Reccord Enrg... 
- test réel valeur et ajout fonction dans eval  le 2019/11/25
  
- reste à faire

  1 . manque format-edition à faire    Decimal.EditCode(fr/us):string  ex 1 234.25 or 1.234,25 

  2 . à tester en situation interactive voir treeview.nim

  3 . à tester en mode SQL direct

- début test avec 2019/11/21 treeview.nim   encours  avec pratique Dcml (voir projet NIM_etudes)



decimal avec bornage pour conformiter avec SQL field definition

C’est un projet qui s’appui sur Nim-decimal
je remercie l’équipe du très gros travail pour adapter qui est fait en c/c++ pour Nim-lang

https://github.com/status-im/nim-decimal

et du soutient que j’ai eu dans le forum Nim.

tous les calculs ce font en valeur étendue seul la fonction Valide formaté

- Mon intervention consiste 

1. Définir la décimal newDcml( iEntier ; iScale) pour borner et ainsi respecter la définition des zones dcml(x,y) dans SQL 

2. j’ai été obligé de changer par rapport au projet initial les retours de valeurs et non pas le retour d’une nouvelle variable

3. la partie disons normale qui sert en gestion sera conforme , la partie mathématique est réduite au minimum

4. Formatage avec justification last zero

5. affectation de valeur (set dcml)  :=  int/int8/int16/int32/int64 uint/uint8/uint16/uint32/uint64/float/string  ex: a:=10

6. a.eval("+", $a, "/" , 100 , "*" , 4 ) etc... 

7. debug(a):string  acces sans contrôle

8. fonction
  +=  -=  *= /= //=  ^= 
9. autre fonction

  comparaion < > >= <= ==

  floor 
  
  ceil  
  
  (signed) plus minus
  
  divint (Integer division)
  
  fma ( a mult b  add c )
  
  rem (remainder)
  
  truncate
  
  Rtrim  (trim zero rigth (format scale ))

  Rjust  (add zeros right (format scale ))
  
  Valide (format for type SQL DCML   sans arrondi)
  
  Round ( arrondi)
  
  isErr



- reslutats tstdcml.nim

 ```..TEST.. 
 
a:=aa 10.00
a:=aa 10
Iint 10.00
Iint8 10.00
Iint16 10.00
Iint32 10.00
Iint64 10.00
Uint 10.00
Uint8 10.00
Uint16 10.00
Uint32 10.00
Uint64 10.00
float = 10.1234  10.12
a.Rtrim 10.12
float = 10  10.00
a.Rtrim 10.00
float = 10.10  10.10
a.Rtrim 10.10
a+=10 20.00
a-=10 10.00
a*=10 100.00
a/=10 10.00
a//=10 1.00
a^=10 10000000000
a+=b 20.00
a-=b 10.00
a*=b 100.00
a/=b 10.00
a//=b 1.00
e:= 10.00
e^=b 10000000000.00
e^=b 10000000000.00
 a==b  true
 a==10 true
 10==a true
 a<b   false
 a<10  false
 a<b   false
 a<=b  true
 10<=a true
 a<=10 true
 a>b   false
 a>10  false
 a>b   false
 a>=b  true
 10>=a true
 a>=10 true
 a==b  false
 a==10 false
 10==a false
 a<b   true
 a<10  true
 a<b   true
 a<=b  true
 10<=a false
 a<=10 true
 a>b   false
 a>10  true
 a>b   false
 a>=b  false
 10>=a false
 a>=10 true

 clone(a) 10.00

 b+22.96 32.96

 c.ceil(b) 33.00

 c.floor(b) 32.00

 c.plus() +32.00

 c.minus() 32.00

 test delete (a)

 redefinition var (a)  mauvais coding  only test 
 d.fma( a, b, c) 203.00

 d.rem(a, b) 1.00

 d.divint(a,c) 3.00

 d.truncate() 3.00

c:=3.9800000 3.98
 d.Rtrim() 3.98 \\n

 d.Rjust() 10.10

 d.Valide() 10.00

 d.Round(3)  10.12

d:=10.12345 10.12
var d invalide format 

d:=123456789012.12345 
 a.isErr() 123456789012.12345
30.00 + 20.00 + 3.00
53.00
100.00 / 100 * 4 + 100.00
104.00
100.00 % 4 +$a
104.00
100.00 +% 4
104.00
100.00 -% 4
96.00
```
  


# test hypotetique de prix revients vente etc.... 


```
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

==============================================================================================================================
resultat

 Poids :  5.0 tonnes   PrixBase : 450.00 remise : 1.50  prixAchat = 2283.75 
 
 poidsUnite : 1.2 grm +  gache : 0.005%   * prixGramme : 0.0004500000 + 40% (frais gestion Entreprise)  Prix de fabrication = 0.00075603780000000000
 poids: 5.0 * 1000000 (poids en gramme)  / poidFab : 1.20 grm  - 0.001% de perte manutention   Nombre article = 4166625
gainUnite sur un article 0.09924396220000000000
benefice effet de masse  gainUnite: 0.09924396220000000000   * nbrArticle: 4166625  - prixAchat: 2283.75 benefice= 411228.62
```
 ________________________________________________________________________________________________________________________
 
 
 
# Dependency license

This library depends on and redistribute mpdecimal. mpdecimal is available at http://www.bytereef.org/mpdecimal/index.html

Mpdecimal is licensed under the following Simplified BSD terms (BSD 2-clause).

```Copyright (c) 2008-2016 Stefan Krah. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.```
