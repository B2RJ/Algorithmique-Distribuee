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
    I had to create this function to find a specific ligne. 
    (Here, -2, -2, -2, -2). 
    To do that, I compare with the line -18, -18, -18, -18 who didn't exist inside my array. 
    This function allows me to know if I have all the information inside my array
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

    // I create the counter
    // I begin to one because we have the father's message yet
    int monCptMessage = 1;
    
    // I create two arrays. One for the nodes and one for the neighbor
    Noeud moi;
    moi.lid = myId;

    //Array with the Id
    int[] nodesBasic = [myId, upNeighbor.lid, downNeighbor.lid, leftNeighbor.lid, rightNeighbor.lid];
   
    //Index to know how many message we have
    bool[4] msgReceived = [false, false, false, false];
    //If I didn't have neigbor I pass the index to true
    for (int i = 1 ; i < 5 ; i++) {
        if (nodesBasic[i] == -1) {
            msgReceived[i-1] = true;
        }
    }
    // Index of the father
    int father = -1;

    // A boolean to know if have received the message before
    bool receivedBefore = false;

    // Array of my recipient
    Tid[4] neighbourRecipient = [upNeighbor.tid, downNeighbor.tid, leftNeighbor.tid, rightNeighbor.tid];

    // I send the first message to my neighbor
    if (myId == 5) {
        father = myId;
        for(int i = 0; i<4 ; i++)
        {   
            if(nodesBasic[i+1] != -1)
            {
                monCptMessage = monCptMessage + 1;
                send(neighbourRecipient[i], "Hello", myId);
            }
        }
    }
    // While we have a neighbord to false we receive
    while(end(msgReceived)){
        receive
        (
            (string message, int IdSources)
            {
                if(message == "Hello") {
                    if(!receivedBefore) {
                        //We change the boolean
                        receivedBefore = true;
                        // We write who is my father
                        father = IdSources;
                        // I send the message to my neighbor except the sender 
                        for(int i = 0; i<4 ; i++)
                        {   
                            if(nodesBasic[i+1] != -1 && IdSources != nodesBasic[i+1])
                            {
                                monCptMessage = monCptMessage + 1;  
                                send(neighbourRecipient[i], message, myId);
                            }
                            if(nodesBasic[i+1] == IdSources) {
                                // The sender become true
                                if(msgReceived[i]== false) {
                                    msgReceived[i] = true;
                                }
                            }
                        }
                    }
                    else {
                        for(int i = 0 ; i<4 ; i++) {
                            if(IdSources == nodesBasic[i+1]) {
                                // The sender become true
                                if(msgReceived[i]== false) {
                                    msgReceived[i] = true;
                                }
                                monCptMessage = monCptMessage + 1;
                                send(neighbourRecipient[i], "already received", myId);
                            }
                        }
                    }    
                }
                else {
                    // If, it isn't "Hello", it is "already receive" or an "ACK" and we do the same things
                    for(int i = 0 ; i<4 ; i++) {
                            if(IdSources == nodesBasic[i+1]) {
                            // The sender become true
                                msgReceived[i] = true;
                            }
                        }
                }
            }
        );
    }  

    //I have the ACK from all my neighbor so, I can send mine to my father
    for(int i = 0 ; i<4 ; i++) {
        if(father == nodesBasic[i+1]) {
            monCptMessage = monCptMessage + 1;
            send(neighbourRecipient[i], "ACK", myId);
        }
    }    
    //I send the number of message
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
            // We give up, down, left and right. If the neighbor didn't exist, we give "nul" (-1)
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
