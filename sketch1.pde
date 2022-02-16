import java.util.*;
import java.lang.Math;

Cell[] cells;
int rows, cols, points;
int[] rnd;
float cellSize;
color color1 = #BF573F;


void setup() {
    size(700, 700);
    background(0, 50, 70); //change color
    
    cellSize = 10; //width and height of cell
    cols = int(width / cellSize + 1);
    rows = int(height / cellSize + 1);
    
    points = 10;
    
    CreateGrid();
    CreateRandomPoints();
    
    noLoop();
}

void CreateGrid() {
    cells = new Cell[rows * cols];
    
    int index = 0;
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            
            float centerX = c * cellSize;
            float centerY = r * cellSize;
            
            cells[index] = new Cell(centerX,centerY);
            
            index++;
        }
    }
}

//make array to store "active" cells. Have function that selects from that array and uses it to connect the random points from int[] rnd w/ the find path function
void CreateRandomPoints() {
    rnd = new int[points];
    
    for (int i = 0; i < points; i++) {
        rnd[i] = (int)random(cells.length);
    }
    
    Arrays.sort(rnd);
    
    int rndFirst = rnd[0];
    int rndLast = rnd[rnd.length - 1];
    
    noStroke();
    fill(color1);

    FindPath(rndFirst, rndLast);
    
}

void FindPath(int start, int end) {
    int startIndex = start;
    int endIndex = end;
    int startEndDelta = end - start; //tracks # of indexes between start and end
    int drawReturn;

    List<String> list = new ArrayList<String>();

    //Up, down, down/left, down/right, up/left, up/right, left, right
    // up = x <= -cols
    // down = x >= cols
    // down/left = x >= cols-1
    // down/right = x >= cols+1
    // up/left = x <= -cols+1
    // up/right = x <= -cols-1
    // left = no restrictions except when single digits: if x > -cols && x < 0 //not quite right

    do{
        int rndMove = (int)random(8);
        int sideStepsToEdge = startIndex % cols; // 0 through cols-1

        switch(rndMove){
            default:
            case 0: //Up
                if (startEndDelta <= cols*-1){
                    list.add("Up");
                    startIndex -= cols;
                    startEndDelta += cols;
                }
                break;
            case 1: //Down
                if (startEndDelta >= cols){
                    list.add("Down");
                    startIndex += cols;
                    startEndDelta -= cols;
                }
                break;
            case 2: //Down/left
                if (startEndDelta >= cols-1){
                    list.add("Down/left");
                    startIndex += cols-1;
                    startEndDelta -= cols-1;                    
                }
                break;
            case 3: //Down/right
                if (startEndDelta >= cols+1){
                    list.add("Down/right");
                    startIndex += cols+1;
                    startEndDelta -= cols+1;                        
                }
                break;
            case 4: //Up/left
                if (startEndDelta <= (cols*-1)+1){
                    list.add("Up/left");
                    startIndex -= cols-1;
                    startEndDelta += cols-1;
                }
                break;
            case 5: //Up/right
                if (startEndDelta <= (cols*-1)-1){
                    list.add("Up/right");
                    startIndex -= cols+1;
                    startEndDelta += cols+1;
                }
                break;
            case 6: //Left
                if (startEndDelta > cols*-1 && startEndDelta < 0){}
                if (startEndDelta > cols){/* Greater than columns, allow movement within edge*/
                    //use sideStepsToEdge
                }
                break;
            case 6: //Right
                if (startEndDelta < cols && startEndDelta > 0){}
                if (startEndDelta > cols){/* Greater than columns, allow movement within edge*/
                    //use sideStepsToEdge
                }
                break;
        }

    }while(startEndDelta != 0)


    String lastAction = "none"; //prevents repeating steps

    String msg ="";
    
    do{
        //Calculating rows ("steps") allowed to travel for given cycle
        double calculateSteps = (double)(startEndDelta) / cols;
        //double calculateSteps = ((double)(startEndDelta) / cols > rows/2) ? ((double)(startEndDelta) / cols)/2 : (double)(startEndDelta) / cols;
        int steps = (int)random((int)calculateSteps + 1);
        boolean endIsLeft = (startIndex % cols > endIndex % cols) ? true : false;
        int rndMove = (int)random(3);
        
        //Notes//
        System.out.println("-----START OF TURN-----");
        System.out.println("endIsLeft:\t\t" + endIsLeft);
        System.out.println("calculateSteps:\t\t" + calculateSteps);
        System.out.println("steps:\t\t\t" + steps);
        System.out.println("startEndDelta:\t\t" + startEndDelta);
        System.out.println("startIndex:\t\t"+ startIndex);
        //end of notes//

        //TODO: Find way to prevent steps from picking consistently high/low numbers
        //and if the number of total steps allowed is low, force it to use all of them
        //this needs to scale, since the grid can technically be any size. Hard coding a "5" won't work for example
        //Potential solution: Make inital calculatedSteps a variable then use that to create percentages to guide selection of steps

        if (startEndDelta >= cols && steps != 0) {
            switch(rndMove) {
                default:
                case 0 : //move down from start
                    if (lastAction == "down") {
                        break;
                    }
                    msg = "    SWITCH A: 0, moved " + steps + " rows DOWN from START.";
                    drawReturn = drawPath(startIndex, steps, cols, endIsLeft, msg);

                    startIndex += drawReturn;
                    startEndDelta -= drawReturn;
                    lastAction = "down";
                    break;
                case 1 : //move left and right
                    if (lastAction == "side") {
                        break;
                    }
                    int sideStepDelta = startEndDelta % cols; //total steps allowed to move left or right
                    int sideStepsToEdge = startIndex % cols;
                    int sideSteps;
                    if (endIsLeft) {
                        sideSteps = (sideStepsToEdge < sideStepDelta) ? (int)random(sideStepsToEdge) : (int)random(sideStepDelta);
                        msg = "    SWITCH A: 1, moved " + sideSteps + " cells LEFT from START.";
                        drawReturn = drawPath(startIndex, sideSteps, -1, endIsLeft, msg);
                        System.out.println("        CALC:"+ startIndex % cols);
                        System.out.println("        sideSteps:"+ sideSteps);

                        startIndex -= drawReturn; //neg bc moving left
                        startEndDelta += drawReturn;
                    }
                    else if (!endIsLeft) {
                        sideSteps = (cols-sideStepsToEdge < sideStepDelta) ? (int)random(cols-sideStepsToEdge) : (int)random(sideStepDelta);
                        msg = "    SWITCH A: 1, moved " + sideSteps + " cells RIGHT from START.";
                        drawReturn = drawPath(startIndex, sideSteps, 1, endIsLeft, msg);
                        System.out.println("        CALC:"+ (cols-(startIndex % cols)));
                        System.out.println("        sideSteps:"+ sideSteps);

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                    lastAction = "side";
                    break;
                case 2 : //move diagonally or side to side
                    if(lastAction == "diagonal") {
                        break;
                    }
                    if (endIsLeft) {
                        msg = "    SWITCH A: 2a, moved " + steps + " rows DOWN/LEFT from START.";
                        //     //Don't go past the end point & don't move past the borders of the grid
                        //     if (startIndex + (cols-1) >= endIndex || startIndex % cols == 0) {
                        drawReturn = drawPath(startIndex, steps, cols-1, endIsLeft, msg);

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                    else if (!endIsLeft) {
                        msg = "    SWITCH A: 2b, moved " + steps + " rows DOWN/RIGHT from START.";
                        //     //Don't go past the end point & don't move past the borders of the grid
                        //     if (startIndex + (cols+1) >= endIndex || startIndex % cols == cols-1){
                        drawReturn = drawPath(startIndex, steps, cols+1, endIsLeft, msg);

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                else {
                    System.out.println("    SWITCH A: 2c, met condition OTHER");
                    System.out.println(startEndDelta);
                    startEndDelta = 0;
                }
                lastAction = "diagonal";
                break;
            }
        }
        else if (startEndDelta < cols) {
            //if (startEndDelta == cols-1) { //Hasn't triggered yet
            //    System.out.println("    !!(LEGAL)" + startEndDelta + " DELTA REMAINING. SETTING TO 0.");
            //    startEndDelta = 0;
            //}

            if (endIsLeft) {
                //"cols-startEndDelta" bc otherwise it wants to go left all the way to the next line up
                //start index is one line too far up from end index
                msg = "    SWITCH B: True, moved " +  (cols-startEndDelta) + " rows LEFT from START.";
                drawReturn = drawPath(startIndex,  cols-startEndDelta, -1, endIsLeft, msg);

                startIndex -= drawReturn; //neg bc moving left
                startEndDelta += drawReturn;
            }
            else if (!endIsLeft) {
                msg = "    SWITCH B: False, moved " + startEndDelta + " rows RIGHT from START.";
                drawReturn = drawPath(startIndex, startEndDelta, 1, endIsLeft, msg);

                startIndex += drawReturn;
                startEndDelta -= drawReturn;
            }

            //if(startEndDelta > 0) { //Has been triggered when startEndDelta is negative before
                // check whats up if this starts getting triggered
                //System.out.println(startEndDelta + " DELTA REMAINING. SETTING TO 0.");
                //startEndDelta = 0;
            //}
        }
        System.out.println("end startEndDelta:\t" + startEndDelta);
        System.out.println("----END OF TURN-----");
    } while(startEndDelta != 0);
    
}

int drawPath( int index, int loopCounter, int incrNum, boolean endIsLeft ,String message) {
    int indexStart = index;
    int indexEnd;

    System.out.println(message); //for debugging

    for(int i = loopCounter; i > 0; i--) {
        index += incrNum;
        cells[index].isActive = true;

        //only works for increments of 1
        if (endIsLeft && index % cols == 0) { //Don't move off grid left
            System.out.println("\t\t!!Tried to move off grid LEFT!!");
            break;
        }
        else if (!endIsLeft && index % cols == cols-1) { //Don't move off grid right
            System.out.println("\t\t!!Tried to move off grid RIGHT!!");
            break;
        }
    }

    indexEnd = index;

    stroke(color1);
    strokeWeight(cellSize*1.5);
    line(cells[indexStart].x, cells[indexStart].y, cells[indexEnd].x, cells[indexEnd].y);
    noStroke();

    int returnIndex = Math.abs(indexStart - indexEnd);
    return returnIndex;
}

//Log passes of each metro line based on some variable (randomly gen int to decide how many lines)
//Each pass generates points on a grid. 
//-Each point will connect to another point to form part of the line
//-Points can also connect to more than one point to represent branches in the line
//-Point (and maybe line data) will be loaded into cell class for reference when generating new metro lines to prevent them from generating ontop of eachother.
//-Might use cells prevent points from generating on certain spots (land and water?)

//Make random point generation generate more points more uniformly (i.e. with matching x or y coordinates)

void draw() {
    //noStroke();
    //fill(color1);
    //circle(centerX, centerY, cellSize);
    
    //Test for filling grid w/ circles//
    //for (Cell item : cells) {
    //circle(item.x, item.y, cellSize);
    //}
    System.out.println("ROWS: " + rows + "; COLUMNS: " + cols);
    System.out.println(Arrays.toString(rnd));
    System.out.println(cells[rnd[0]].x + " " + cells[rnd[0]].y + "; INDEX: " + rnd[0]);
    System.out.println(cells[rnd[rnd.length - 1]].x + " " + cells[rnd[rnd.length - 1]].y + "; INDEX: " + rnd[rnd.length - 1]);
    
    //connect two last rnd points
    stroke(0, 0, 0);
    strokeWeight(1);
    line(cells[rnd[0]].x, cells[rnd[0]].y, cells[rnd[rnd.length - 1]].x, cells[rnd[rnd.length - 1]].y);
    
    //draw rnd points
    noStroke();
    fill(color1);
    for (int item : rnd) {
        circle(cells[item].x, cells[item].y, cellSize);
    }
    
}

class Cell {
    //Add variables to cells as needed...
    float x, y; //center of cell
    boolean isActive = false; //active = part of a line
    
    Cell(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
}