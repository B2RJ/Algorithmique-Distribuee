BRUNEAU Richard p1402059

Sujet F

Exercice 1:

Question 1:
    Ma grille est la suivante : 

    0 -- 1 -- 2 -- 3
    |    |    |    |
    4 -- 5 -- 6 -- 7
    |    |    |    |
    8 -- 9 -- 10 - 11 
    |    |    |    |
    12 - 13 - 14 - 15

Etape 1 : Chaque noeud envoie son id et l'id de ses voisins

id envoie à voisin : (id, [voisin du haut, voisin du bas, voisin gauche, voisin droit])

0 envoie à 4 : (0,[-1, 4, -1, 1]) //-1 signifie qu'il n'y pas de voisin </br> 
0 envoie à 1 : (0,[-1, 4, -1, 1]) </br> 
1 envoie à 5 : (1,[-1, 5, 0, 2]) </br> 
1 envoie à 0 : (1,[-1, 5, 0, 2]) </br> 
1 envoie à 2 : (1,[-1, 5, 0, 2]) </br> 
et ainsi de suite, au milieu de la grille on aura </br> 
5 envoie à 1 : (5,[1, 9, 4, 6]) </br> 
5 envoie à 9 : (5,[1, 9, 4, 6]) </br> 
5 envoie à 4 : (5,[1, 9, 4, 6]) </br> 
5 envoie à 6 : (5,[1, 9, 4, 6]) </br> 
toujours la même logique </br> 

Etape 2 : Chaque noeud reçoit pour la première fois une pair (id, liste de voisin ) </br> 

Le noeud qui reçoit met à jour sa représentation du graphe.  
    <ul>
        <li>En mettant à jour sa liste de noeud 
        <li>En mettant à jour la liste de lien du noeud reçu.
    </ul>
Puis retransmet à chacun de ses voisins l'information (sauf à celui qui vient de lui envoyer) </br> 

Dans notre cas, ça donnerait la situation suivante pour le noeud 0. 
</br> 
0 envoie à 1 et à 4 sa paire (id + liste de voisin). </br> 
1 envoie la paire de 0 à 2 et 5. </br> 
4 envoie la paire de 0 à 5 et 8 </br> 
2 envoie la paire de 0 à 3 et 6 </br> 
5 envoie la paire de 0 à 4 8 </br> 
8 envoie la paire de 0 à 5 et 8 </br> 

![arbre]

[arbre]: ./images/Ex1Q1.png "arbre"


Nous pouvons tracer le même genre d'arbre pour chacun des noeuds du graphe.


Question 2: 

D'après l'algorithme : Un noeud sait qu'il a terminé quand la taille de sa liste de noeud est égale au nombre de listes dans sans liste qui recence les paires "ID(k), ID-voisins(k)". 

C'est également ce que j'aurais implémenté si la classe liste fournissait un moyen de récupérer sa taille. 

Dans mon code, j'ai utilisé un tableau pour stocké la grille que j'ai initialisé en mettant toutes les valeurs à -2. Je continue d'iterer tant que j'ai des valeurs à -2 dans mon tableau. 


Question 3: 

Si nous avions utilisé un langage avec des structures de données complètes, c'est à dire des listes qui donne la taille de la liste quand on le demande, j'aurais utilisé des listes. Or, ici, que ce soit les DList ou les SList, ce n'est pas le cas. 

J'ai donc utilisé un tableau pour stocker tout les noeuds découverts par le noeud qui remplit le tableau et un autre tableau 2D celui-ci pour connaitre les voisins de chaque noeud. 

Question 4 : 

Sur une moyenne de 1000 executions : </br>
Pour une grille de 4 x 4 il y a 2 005 messages échangés. Le minimum est de 1 026 messages alors que le maximum est de 7 235 messages.</br>


La consigne demandait de réaliser cette moyenne sur des grilles 10x10 et 50x50, malheureusement, mon PC ne peut pas réalisé ces tentatives. Au maximum, j'ai pu faire sur une grille 7 x 7. Voici les résultats. </br>

Pour une grille de 7 x 7 il y a 280 102 messages échangés. Le minimum est de 132 036 messages alors que le maximum est de 1 308 530 messages. </br>

Cette limite matériel repose sur le processeur, le nombre de coeur dont il est équipé ainsi que les processus déjà en cours. 



Exercice 1:

Question 1:

<a href="./exercice2.d">(voir code, fichier exercice2.d)</a>

Question 2:

ur une moyenne de 1000 executions : </br>
Pour une grille de 4 x 4 il y a 49 messages échangés. Le minimum est de 49 messages alors que le maximum est de 49 messages.</br>

Pour une grille de 7 x 7 il y a 169 messages échangés. Le minimum est de 169 messages alors que le maximum est de 169 messages. </br>

Pour une grille de 10 x 10 il y a 361 messages échangés. Le minimum est de 361 messages alors que le maximum est de 361 messages. </br>

Pour une grille de 45 x 45 il y a 7921 messages échangés. Le minimum est de 7921 messages alors que le maximum est de 7921 messages. </br>

Je me suis arrêté à 45, car j'ai une erreur à la création de thread au-delà.


Question 3: 

En rajoutant un aléatoire d'environs ~50 millisecondes sur certains noeuds, de temps en temps il n'y a pas  de changement. En effet, le noeud recevra le message, attendra et le transmettra à ces voisins, ne changeant absolument rien au déroulé du programme. 

Sur une moyenne de 1000 executions : </br>
Pour une grille de 4 x 4 il y a 49 messages échangés. Le minimum est de 49 messages alors que le maximum est de 49 messages.</br>

Pour une grille de 10 x 10 il y a 361 messages échangés. Le minimum est de messages 361 alors que le maximum est de 361 messages. </br>

Pour une grille de 45 x 45 il y a 7921 messages échangés. Le minimum est de messages 7921 alors que le maximum est de 7921 messages.

Question 4 : 

Pas concerné. 


Exercice 3

Question 1 : 

Dans un premier temps, on reprend l'algorithme de l'exercice précédant en innondant le réseau. Ce qui sera envoyé sera de la forme : 
(message, IdDeLaSource)

Une fois qu'un noeud à reçu le message, il envoie un acquittement au noeud qui lui envoyé (tout en le propageant, comme avant).
ACK de la forme : (ACK, destinataire, IdACK)
ACK = "message de l'ACK
destinataire = IdDeLaSources
IdACK = l'ID du créateur de l'ACK pour que le premier emeteur sache de qui acquitte. 

Ce qui donne:

<ul>
        <li>Un noeud innonde le réseau
        <li>Les noeuds qui recoivent le message de base le transmette à tout leurs autres voisins
        <li>Quand je reçoit un acquitement, je le renvoie à tout mes voisins sauf l'expediteur.
        <li>Le noeud qui a innondé le réseau connai
    </ul>
