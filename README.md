# nim_dcml

- démarage projet 2019/11/05
# en test 

- date de mise a jour 2019/11/17 

- début test avec  treeview.nim   encours   style feuille de calcul projet NIM_etudes



decimal avec bornage pour conformiter avec SQL field definition

C’est un projet qui s’appui sur Nim-decimal
je remercie l’équipe du très gros travail pour adapter qui est fait en c/c++ pour Nim-lang

https://github.com/status-im/nim-decimal

et du soutient que j’ai eu dans le forum Nim.

- Mon intervention consiste 

1. Définir la décimal newDcml( iEntier ; iScale) pour borner et ainsi respecter la définition des zones dcml(x,y) dans SQL 

2. j’ai été obligé de changer par rapport au projet initial les retours de valeurs et non pas le retour d’une nouvelle variable

3. la partie disons normale qui sert en gestion sera conforme , la partie mathématique est réduite au minimum

4. Formatage avec justification last zero

5. Contrôle des entrées String

6. Prise en compte de Float

7. fonction
  add  sub  mult  div  divInterger  power
8. autre fonction

  comparaion < > >= <= ==

  floor ceil  
  
  (signed) plus minus
  
  divint (Integer division)
  
  fma ( a mult b  add c )
  
  rem (remainder)
  
  truncate
  
  reduce  (trim zero rigth)

  Rjust  (alligne zeros right (format scale ))
  
  Valide (format for type SQL DCML)
  
  Round
  
  isErr



- reslutats tstdcml.nim

 ```..TEST.. 
 
10
a+10 20
a-10 10
a*10 100
a/10 10
a//10 1
a^10 10000000000
a+b 20
a-b 10
a*b 100
a/b 10
a//b 1
a^b 10000000000

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


 clone(a) 10

 b+22.96 32.96

 c.ceil(b) 33

 c.floor(b) 32

 c.plus() +32 (signed)

 c.minus() -32


 a.setDcml("10")
 b.setDcml("20")
 c.setDcml("3")
 
 
 d.fma( a, b, c) 203

 d.rem(a, c) 1

 d.divint(a,c) 3

 d.setDcml("3.98")
 d.truncate() 3

 c.setDcml('3.9800000') 3.9800000
 d.reduce() 3.98 \\n

 d.setDcml('10.1') 10.1
 d.Rjust() 10.10

d.setDcml('10') 10
d.Valide() 10.00

 d.setDcml('10.123456') 10.123456
 d.Round(3) 10.123

d.setDcml('10.12345') 10.12345
if d.isErr()==true:   message "var d'invalide format" 

d.setDcml('123456.12345') 123456.12345
dcml.nim(694)            Valide
Error: unhandled exception: Overlay Digit Valide() value:123456.12345  [DecimalError]

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
