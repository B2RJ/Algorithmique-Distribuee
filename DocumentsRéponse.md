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

Un noeud sait qu'il a terminé quand la taille de sa liste de noeud est égale au nombre de liste qu'il a pas noeud. 

Question 3: 

Je vais utiliser une liste pour le nombre de noeud et une une liste de listes pour accéder aux listes de voisins. 

Question 4 : 

Sur une moyenne de ... executions : </br>
Pour une grille de 4 x 4 il y a X messages échangés. </br>
Pour une grille de 10 x 10 il y a X messages échangés. </br>
Pour une grille de 50 x 50 il y a X messages échangés.

