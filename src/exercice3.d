// import std.c.time;
import std.stdio;
import std.concurrency;
import core.time;
import std.algorithm;
import std.math;

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
bool myCanFind(int[4][2025] nodesNeighborhood) {
    if (nodesNeighborhood[][].find([-2,-2,-2,-2]) != nodesNeighborhood[][].find([-18,-18,-18,-18])) {
        return true;
    }  
    return false;   
}

bool end(bool[4] msgReceived) {
    for(int i = 0 ; i < 4 ; i++) {
        if(msgReceived[i] == false){
            return true;
        }
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
    
    // Creation des deux tableaux : Celui qui recence les noeuds et Celui qui recence leur voisin
    Noeud moi;
    moi.lid = myId;

    //Tableau d'id de base
    int[] nodesBasic = [myId, upNeighbor.lid, downNeighbor.lid, leftNeighbor.lid, rightNeighbor.lid];
   
    //Indice pour savoir combien de message on a reçu
    bool[4] msgReceived = [false, false, false, false];
    //Si je n'ai pas de voisin, je passe l'indice correspondant à true.
    for (int i = 1 ; i < 5 ; i++) {
        if (nodesBasic[i] == -1) {
            msgReceived[i-1] = true;
        }
    }
    // Indice du voisin "père"
    int father = -1;

    //Un booleen pour savoir si on a dé&jà reçu le message
    bool receivedBefore = false;

    // Tableau de destinataires
    Tid[4] neighbourRecipient = [upNeighbor.tid, downNeighbor.tid, leftNeighbor.tid, rightNeighbor.tid];

    // Envoie du message à mes voisins
    if (myId == 5) {
        father = myId;
        for(int i = 0; i<4 ; i++)
        {   
            if(nodesBasic[i+1] != -1)
            {
                monCptMessage = monCptMessage + 1;
                send(neighbourRecipient[i], "Coucou", myId);
            }
        }
    }
    // Tant qu'il y a encore un voisin à False, on continue de recevoir
    while(end(msgReceived)){
        receive
        (
            (string message, int IdSources)
            {
                if(message == "Coucou") {
                    if(!receivedBefore) {
                        //On passe le booleen à true
                        receivedBefore = true;
                        // On enregistre qui est son "père"
                        father = IdSources;
                        // Envoie du message à mes voisins, sauf celui qui me l'a envoyé
                        for(int i = 0; i<4 ; i++)
                        {   
                            if(nodesBasic[i+1] != -1 && IdSources != nodesBasic[i+1])
                            {
                                monCptMessage = monCptMessage + 1;  
                                send(neighbourRecipient[i], message, myId);
                            }
                            if(nodesBasic[i+1] == IdSources) {
                                // On passe à true le noeud qui nous a transmis le message
                                if(msgReceived[i]== false) {
                                    msgReceived[i] = true;
                                }
                            }
                        }
                    }
                    else {
                        for(int i = 0 ; i<4 ; i++) {
                            if(IdSources == nodesBasic[i+1]) {
                                // On passe le booleen de l'expéditeur à true.
                                if(msgReceived[i]== false) {
                                    msgReceived[i] = true;
                                }
                                monCptMessage = monCptMessage + 1;
                                send(neighbourRecipient[i], "Deja reçu", myId);
                            }
                        }
                    }    
                }
                else {
                    //Si c'est pas "Coucou", ça ne peut être que "Deja reçu" ou un "ACK" et le résultat est le meme
                    for(int i = 0 ; i<4 ; i++) {
                            if(IdSources == nodesBasic[i+1]) {
                                // On passe le booleen de l'expéditeur à true.
                                msgReceived[i] = true;
                            }
                        }
                }
            }
        );
    }  

    //J'ai donc reçu les acquitements de tout mes voisins, je peux envoyer à mon père l'ack.
    // J'envoie "myId" uniquement pour pas avoir à recoder un autre type de message
    for(int i = 0 ; i<4 ; i++) {
        if(father == nodesBasic[i+1]) {
            monCptMessage = monCptMessage + 1;
            send(neighbourRecipient[i], "ACK", myId);
        }
    }    
    //On envoie le nombre de message échangés
    send(ownerTid, monCptMessage);

    // end of your code
    send(ownerTid, CancelMessage());
}


void main()
{
    // number of child processes (must be a number that can be sqrt)
    int row = 45;
    int col = 45;
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
    while (i<2025) {
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
