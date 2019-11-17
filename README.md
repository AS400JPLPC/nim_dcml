# nim_dcml

- démarage projet 2019/11/05
# en test 

- date de mise a jour 2019/11/17 


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

 clone(a) 10

 b+22.96 32.96

 c.ceil(b) 33

 c.floor(b) 32

 c.plus() +32

 c.plus() -32

 d.fma( a, b, c) 203

 d.rem(a, b) 1

 d.divint(a,c) 3

 d.truncate() 3

c.setDcml('3.9800000') 3.9800000
 d.reduce() 3.98 \\n

 d.Rjust() 10.10

 d.Valide() 10.00

 d.Round(3) 10.123

d.setDcml('10.12345') 10.12345
var d invalide format 

d.setDcml('123456.12345') 123456.12345
dcml.nim(694)            Valide
Error: unhandled exception: Overlay Digit Valide() value:123456.12345  [DecimalError]```
  
  
  
