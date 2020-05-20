// import std.c.time;
import std.stdio;
import std.concurrency;
import core.time;
import std.algorithm;
import std.math;

import std.algorithm.comparison : among, equal;
import std.range : iota;

import std.Random;

import core.thread;

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

/*
    J'ai conçu cette fonction pas piquée des hannetons afin de rechercher si dans mon tableau
    j'avais une ligne comme celle-ci [-2,-2,-2,-2].
    J'ai comparé avec la ligne [-18,-18,-18,-18] qui N'est PAS présente dans mon tableau. 
    Cette fonction me permet de savoir si j'ai toutes les informations de la grille.
*/
bool myCanFind(int[4][400] nodesNeighborhood) {
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

    // Création du compteur de message
    // Il est à 1 car il y a le message du père
    int monCptMessage = 1;
    
    // Creation des deux tableaux : Celui qui recence les noeuds et celui qui recence leur voisin
    Noeud moi;
    moi.lid = myId;

    int[] nodesBasic = [myId, upNeighbor.lid, downNeighbor.lid, leftNeighbor.lid, rightNeighbor.lid];
    
    // Tableau de destinataire
    Tid[4] neighbourRecipient = [upNeighbor.tid, downNeighbor.tid, leftNeighbor.tid, rightNeighbor.tid];

    // Tableau de reception 
    bool[] receptionMessages = [false, false, false, false];

    // Envoie du message à mes voisins
    if (myId == 5) {
        for(int i = 0; i<4 ; i++)
        {   
            if(nodesBasic[i+1] != -1)
            {
                monCptMessage = monCptMessage + 1;
                send(neighbourRecipient[i], "Coucou", myId);
            }
            
        }
        send(ownerTid, monCptMessage);
        send(ownerTid, CancelMessage());
    } else {
        receive
        (
            (string message, int IdSources)
            {
                // Envoie du message à mes voisins, sauf celui qui me l'a envoyé
                for(int i = 0; i<4 ; i++)
                {   
                    if(nodesBasic[i+1] != -1 && IdSources != nodesBasic[i+1])
                    {
                        //Random pour savoir si on fait une pause entre chaque envoie
                        auto rnd = Random(42);
                        auto myRnd = uniform(0, 16, rnd);
                        if (myRnd%2 == 0) {
                            bool changement = receiveTimeout(dur!("msecs")(50), (string message, int IdSources2)
                                {
                                    for(int i=1 ; i<5 ; i++) {
                                        if (IdSources2 == nodesBasic[i]) {
                                            receptionMessages[i-1] = true;
                                        }
                                    }
                                }
                            );
                        }
                        if (receptionMessages[i] == false) {
                            monCptMessage = monCptMessage + 1;
                            send(neighbourRecipient[i], message, myId);
                        }    
                    }
                }
                send(ownerTid, monCptMessage);
                send(ownerTid, CancelMessage());
                return 0;
            }
        );
    }  
    // end of your code
}


void main()
{
    // number of child processes (must be a number that can be sqrt)
    int row = 20;
    int col = 20;
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

    int nbMessageTotal = 0;
    int i = 0;
    while (i<400) {
        receive(
            (int nbMessage)
            {
                nbMessageTotal = nbMessageTotal + nbMessage;
                i = i + 1;
            }
        );   
    }
    writeln(nbMessageTotal);

    // wait for all completions
    receiveAllFinalization(childTid, row, col);
}
