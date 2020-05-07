// import std.c.time;
import std.stdio;
import std.concurrency;
import core.time;
import std.algorithm;
import std.math;

import std.container : DList;
import std.range : popFrontN, popBackN, walkLength;


struct CancelMessage{}

struct Noeud
{
    Tid tid; //thread_ID
    int lid; //logical_ID
}

void receiveAllFinalization(Noeud [][] childTid, int row, int col)
{
    for(int i=0 ; i<row ; ++i) {
        for(int j=0 ; j<col ; ++j) {
            receiveOnly!CancelMessage();
        }
    }
}


bool nodesNeighborhoodComplete(int[4][16]* nodesNeighborhood, int myId){
    if (myId == 2) {
                 //writeln("Debut");
    }    
    for (int i = 1 ; i<4 ; i++){
        for (int j = 1 ; j <16 ; j++) {
            if (myId == 2) {
                //writeln("==>", nodesNeighborhood[i][j]);
            }    
            if(nodesNeighborhood[i][j] == [-2, -2, -2, -2]){
                if (myId == 2) {
                 //writeln("Fin");
                } 
                return true;
            }
        }
    }
    if (myId == 2) {
        //writeln("Fin");
    } 
    return false;
}

/*
    Bon, ce coup ci c'est la classe "Arrays" qui est pas finie. 
    Pour une raison sans doute très pertinentes, il y a aucun moyen de savoir si elle contient une valeur
    avec les fonctions membres. Ou alors, j'ai pas trouvé et les gens sur les forums non plus. 
    Bref, j'ai donc conçu cette fonction pas piquée des hannetons afin de rechercher si dans mon tableau
    j'avais une ligne comme celle-ci [-2,-2,-2,-2].
    J'ai comparé avec la ligne [-18,-18,-18,-18] qui N'est PAS présente dans mon tableau. 
    Cette fonction me permet de savoir si j'ai toutes les informations de la grille.
*/

bool myCanFind(int[4][16] nodesNeighborhood) {
    if (nodesNeighborhood[][].find([-2,-2,-2,-2]) != nodesNeighborhood[][].find([-18,-18,-18,-18])) {
        return true;
    }  
    return false;   
}

void spawnedFunc(int myId, int n)
{
  
    Noeud upNeighbor, downNeighbor, leftNeighbor, rightNeighbor;

    // waiting for the reception of information sent by the father
    receive
    (
     (immutable(Noeud) uneighbor, immutable(Noeud) dneighbor, immutable(Noeud) lneighbor, immutable(Noeud) rneighbor)
        {
            upNeighbor = cast(Noeud)uneighbor;
            downNeighbor = cast(Noeud)dneighbor;
            leftNeighbor = cast(Noeud)lneighbor;
            rightNeighbor = cast(Noeud)rneighbor;
        }
    );
    
    // Creation des deux tableaux : Celui qui recence les noeuds et Celui qui recence leur voisin
    Noeud moi;
    moi.lid = myId;

    int[] nodesBasic = [myId, upNeighbor.lid, downNeighbor.lid, leftNeighbor.lid, rightNeighbor.lid];
    
    // Tableau de destinataire
    Tid[4] neighbourRecipient = [upNeighbor.tid, downNeighbor.tid, leftNeighbor.tid, rightNeighbor.tid];

    //On peut pas creer un tableau avec des variables 
    //On peut pas donner une valeur dans une case précise à un tableau dynamique
    //Du coup, je dois définir moi même le tableau. 
    // Avec un langage différent, j'aurais utilisé une variable au lieu du "16", 
    //ça m'aurait eviter de devoir le changer à chaque changement de taille
    int[4][16] nodesNeighborhood = -2;
    for(int i = 0; i<4 ; i++)
    {
        nodesNeighborhood[myId][i] = nodesBasic[i+1]; 
    }

    // Envoie de mes voisins à mes voisins
    for(int i = 0; i<4 ; i++)
    {   
        //writeln(myId);
        if(nodesBasic[i+1] != -1)
        {
            send(neighbourRecipient[i], myId, cast(immutable)upNeighbor, cast(immutable)downNeighbor, cast(immutable)leftNeighbor, cast(immutable)rightNeighbor);
        }
    }
    

    int[] nodes;
    for (int i = 0 ; i<5 ; i++) {
        if(nodesBasic[i] == -1)
        {
            
        }
        else {
            nodes = nodes ~ [nodesBasic[i]];
        }
    }

    //Il n'y a pas contains() ou canFind() sur un tableau 2D, 
    //on va donc rendre le code encore moins lisible
    int[4][16] * p;
    p = &nodesNeighborhood;
    bool a = nodesNeighborhoodComplete(p, myId);
    if(myId == 2) {
        //writeln("Je suis: ", myId, " et le booleen est a: ", a, " voici mon tableau", nodesNeighborhood);
    }
    bool b = myCanFind(nodesNeighborhood);
    //bool a = nodesNeighborhoodComplete(p);
    while(myCanFind(nodesNeighborhood))
    {
        receive
        (
            (int hisId, immutable(Noeud) uneighbor, immutable(Noeud) dneighbor, immutable(Noeud) lneighbor, immutable(Noeud) rneighbor)
            {
                if(nodes.canFind(hisId) || hisId == -1 ){
                    //On ne fait rien, mais "!" c'est pas not dans ce langage
                } else {
                    nodes = nodes ~ [hisId];
                    
                }
                if(nodes.canFind(uneighbor.lid) || uneighbor.lid == -1 ) {
                    //Même chose. L'impression de coder comme en L1
                }
                else {
                    nodes = nodes ~ [uneighbor.lid];
                    
                }
                if(nodes.canFind(dneighbor.lid) || dneighbor.lid == -1 ) {
                    //Toujours pareil, pas de length ou de size sur les listes, je trouve pas le not
                }
                else {
                    nodes = nodes ~ [dneighbor.lid];
                    
                }
                if(nodes.canFind(lneighbor.lid) ||lneighbor.lid == -1 ) {
                    //Toujours pareil
                }
                else {
                    nodes = nodes ~ [lneighbor.lid];
                    
                }
                if(nodes.canFind(rneighbor.lid) ||rneighbor.lid == -1 ) {
                    //Désolé pour la longueur du code
                }
                else {
                    nodes = nodes ~ [rneighbor.lid];
                    
                }

                //writeln(hisId);
                nodesNeighborhood[hisId][0] = uneighbor.lid;
                nodesNeighborhood[hisId][1] = dneighbor.lid;
                nodesNeighborhood[hisId][2] = lneighbor.lid;
                nodesNeighborhood[hisId][3] = rneighbor.lid;
                
                // Envoie de ceci à mes voisins, sauf celui qui me l'a envoyé
                for(int i = 0; i<4 ; i++)
                {   
                    if(nodesBasic[i+1] != -1)
                    {
                        send(neighbourRecipient[i], hisId, uneighbor, dneighbor, lneighbor, rneighbor);
                    }
                }
            }
        );
    }
    //writeln("Je suis: ", myId, " et voici mon tableau: ", nodes);
    if(true) {
        writeln("Je suis: ", myId, " et voici mon tableau: ", nodes);
        writeln("Je suis: ", myId, " et voici mon tableau: ", nodesNeighborhood);
        }
    

    // end of your code

    send(ownerTid, CancelMessage());
    
}


void main()
{
    // number of child processes (must be a number that can be sqrt)
    int row = 4;
    int col = 4;
    int n = row * col;

    // spawn threads (child processes)
    Noeud [][] childTid = new Noeud[][](row, col);
    for(int i = 0; i < row; ++i) {
        for(int j = 0; j < col; ++j) {
            childTid[i][j].tid = spawn(&spawnedFunc, i*row + j, n);
            childTid[i][j].lid = i*row + j;
        }
    }

    for(int i=0 ; i<row ; ++i) {
        for(int j=0 ; j<col ; ++j) {

            Noeud nul;
            nul.tid = Tid();
            nul.lid = -1;

            Noeud up, down, left, right;
            // On attribut à up, down, left, right, le bon voisin. Si le voisin n'existe pas, on donne le noeud 'nul' qui vaut -1
            up = i > 0 ? childTid[i-1][j] : nul;
            down = i < row-1 ? childTid[i+1][j] : nul;
            left = j > 0 ? childTid[i][j-1] : nul;
            right = j < col-1 ? childTid[i][j+1] : nul;

            send(childTid[i][j].tid, cast(immutable)up, cast(immutable)down, cast(immutable)left, cast(immutable)right);
        }
    }

    // wait for all completions
    receiveAllFinalization(childTid, row, col);
}
