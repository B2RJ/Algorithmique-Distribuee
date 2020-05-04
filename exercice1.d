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
    
    //writeln("Je suis le processus ", myId, " et j'ai pour voisin du haut ", upNeighbor.lid, ", pour voisin du bas ", downNeighbor.lid, " pour voisin de gauche ", leftNeighbor.lid, " et pour voisin de droite ", rightNeighbor.lid);

    // Creation des deux tableaux : Celui qui recence les noeuds et Celui qui recence leur voisin

    Noeud moi;
    moi.lid = myId;


    int[] nodes = [myId, upNeighbor.lid, downNeighbor.lid, leftNeighbor.lid, rightNeighbor.lid];

    // Tableau de destinataire
    Tid[4] neighbourRecipient = [upNeighbor.tid, downNeighbor.tid, leftNeighbor.tid, rightNeighbor.tid];

    //All is right, tout le monde écrit son tableau même 0
    //writeln(nodes);

    // if (myId == 9) {
    //     writeln(nodes); 
    // }

    //On peut pas creer un tableau avec des variables 
    //On peut pas donner une valeur dans une case précise à un tableau dynamique
    //Du coup, je dois définir moi même le tableau
    int[4][16] nodesNeighborhood = -2;
    for(int i = 0; i<4 ; i++)
    {
        nodesNeighborhood[myId][i] = nodes[i+1]; 
    }

    //Ok, tout le monde le fait même 0
    //writeln("Je suis ", myId, " et voilà mon tableau: " ,  "\x0a", nodesNeighborhood);
    // if (myId == 9) {
    //     writeln(nodesNeighborhood); 
    // }

    // Envoie de mes voisins à mes voisins
    for(int i = 0; i<4 ; i++)
    {   
        //writeln(myId);
        if(nodes[i+1] != -1)
        {
            send(neighbourRecipient[i], myId, cast(immutable)upNeighbor, cast(immutable)downNeighbor, cast(immutable)leftNeighbor, cast(immutable)rightNeighbor);
            //writeln("Je suis ", myId, " et j'ai envoyé à ", neighbourRecipient[i]);
        }
    }
    //writeln("Je suis ", myId, " et j'ai envoyé à mes voisin");

    while(nodes.length < 4)
    {
        receive
        (
            (int hisId, immutable(Noeud) uneighbor, immutable(Noeud) dneighbor, immutable(Noeud) lneighbor, immutable(Noeud) rneighbor)
            {
                //writeln("Je suis ", myId, " et j'ai bien reçu");
            }

        );
    }

    // while mon tablea 1 plus longue que mon nombre de ligne à -2
    // je reçoit les listes de mes potes


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
