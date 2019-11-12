# nim_dcml
decimal avec bornage pour conformiter avec SQL field definition

C’est un projet qui s’appui sur Nim-decimal
je remercie l’équipe du très gros travail pour adapter ce qui ce fait en c/c++ en Nim

https://github.com/status-im/nim-decimal

ainsi que  pour le soutient que j’ai eu dans le forum Nim.

# Mon intervention consiste 

1. Définir la décimal newDcml( iEntier ; iScale) pour la bornée et ainsi respecter la définition des zones dcml(x,y) dans SQL 

2.  j’ai été obligé de changer par rapport au projet initial les retours de valeurs et non pas le retour d’une nouvelle variable

3. la partie disons normale qui sert en gestion sera conforme , reste la partie mathématique pour le moment je ne compte pas l’enlever … je vais voir à l’usure 
