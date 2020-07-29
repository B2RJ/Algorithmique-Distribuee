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



/*
    I had to create this function to find a specific ligne. 
    (Here, -2, -2, -2, -2). 
    To do that, I compare with the line -18, -18, -18, -18 who didn't exist inside my array. 
    This function allows me to know if I have all the information inside my array
*/
bool myCanFind(int[4][49] nodesNeighborhood) {
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

    // I create the counter
    // I begin to one because we have the father's message yet
    int monCptMessage = 1;
    
    // I create two arrays. One for the nodes and one for the neighbor
    Noeud moi;
    moi.lid = myId;

    int[] nodesBasic = [myId, upNeighbor.lid, downNeighbor.lid, leftNeighbor.lid, rightNeighbor.lid];
    
    // Array of my recipient
    Tid[4] neighbourRecipient = [upNeighbor.tid, downNeighbor.tid, leftNeighbor.tid, rightNeighbor.tid];

    // I didn't find how to create an array with variable in DLang, so my code isn't very optimize
    int[4][49] nodesNeighborhood = -2;
    for(int i = 0; i<4 ; i++)
    {
        nodesNeighborhood[myId][i] = nodesBasic[i+1]; 
    }

    // I send my neighbors to my neighbors
    for(int i = 0; i<4 ; i++)
    {   
        if(nodesBasic[i+1] != -1)
        {
            monCptMessage = monCptMessage + 1;
            send(neighbourRecipient[i], myId, cast(immutable)upNeighbor, cast(immutable)downNeighbor, cast(immutable)leftNeighbor, cast(immutable)rightNeighbor, myId);
        }
    }

    int[] nodes;
    for (int i = 0 ; i<5 ; i++) {
        if(nodesBasic[i] == -1)
        {
            
        }
        else {
            //This is a concatenation
            nodes = nodes ~ [nodesBasic[i]];
        }
    }

    while(myCanFind(nodesNeighborhood))
    {
        receive
        (
            (int hisId, immutable(Noeud) uneighbor, immutable(Noeud) dneighbor, immutable(Noeud) lneighbor, immutable(Noeud) rneighbor, int IdSources)
            {
                if(nodes.canFind(hisId) || hisId == -1 ){
                    //We do nothing but I didn't find how to make a not
                } else {
                    nodes = nodes ~ [hisId];
                }
                if(nodes.canFind(uneighbor.lid) || uneighbor.lid == -1 ) {
                    //We do nothing but I didn't find how to make a not
                }
                else {
                    nodes = nodes ~ [uneighbor.lid];
                }
                if(nodes.canFind(dneighbor.lid) || dneighbor.lid == -1 ) {
                    //We do nothing but I didn't find how to make a not
                }
                else {
                    nodes = nodes ~ [dneighbor.lid];
                }
                if(nodes.canFind(lneighbor.lid) ||lneighbor.lid == -1 ) {
                    //We do nothing but I didn't find how to make a not
                }
                else {
                    nodes = nodes ~ [lneighbor.lid];
                }
                if(nodes.canFind(rneighbor.lid) ||rneighbor.lid == -1 ) {
                    //We do nothing but I didn't find how to make a not
                }
                else {
                    nodes = nodes ~ [rneighbor.lid];
                }

                nodesNeighborhood[hisId][0] = uneighbor.lid;
                nodesNeighborhood[hisId][1] = dneighbor.lid;
                nodesNeighborhood[hisId][2] = lneighbor.lid;
                nodesNeighborhood[hisId][3] = rneighbor.lid;
                
                // I send the message to my neighbor except the sender
                for(int i = 0; i<4 ; i++)
                {   
                    if(nodesBasic[i+1] != -1 && IdSources != nodesBasic[i+1])
                    {
                        monCptMessage = monCptMessage + 1;
                        send(neighbourRecipient[i], hisId, uneighbor, dneighbor, lneighbor, rneighbor, myId);
                    }
                }
            }
        );
    }

    send(ownerTid, monCptMessage);
    // end of your code

    send(ownerTid, CancelMessage());
    
}


void main()
{
    // number of child processes (must be a number that can be sqrt)
    int row = 7;
    int col = 7;
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
    while (i<49) {
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
