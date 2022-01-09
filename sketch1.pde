import java.util.Arrays;
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

    String msg ="";
    
    do{
        //Calculating rows ("steps") allowed to travel for given cycle
        double calculateSteps = (double)(startEndDelta) / cols;
        int steps = (int)random((int)calculateSteps + 1);
        boolean endIsLeft = (startIndex % cols > endIndex % cols) ? true : false;
        
        //Notes//
        System.out.println("endIsLeft: " + endIsLeft);
        System.out.println("calculateSteps: " + calculateSteps);
        System.out.println("steps: " + steps);
        System.out.println("startEndDelta: " + startEndDelta);
        //end of notes//

        //TODO:

        if (startEndDelta >= cols) {
            switch((int)random(3)) {
                default:
                case 0 : //move down from start
                    if(steps != 0) {
                        msg = "    SWITCH A: 0, moved " + steps + " rows DOWN from START.";
                        drawReturn = drawPath(startIndex, steps, cols, msg);

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                    break;
                case 1 : //move left and right //This is broken!!!
                    int sideSteps;
                    if (endIsLeft) {
                        sideSteps = (int)random(startIndex % cols);
                        msg = "    SWITCH A: 1, moved " + sideSteps + " cells LEFT from START.";
                        drawReturn = drawPath(startIndex, sideSteps, -1, msg);
                        System.out.println("        sideSteps:"+startIndex % cols);

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                    else if (!endIsLeft) {
                        sideSteps = (int)random(cols-(startIndex % cols));
                        msg = "    SWITCH A: 1, moved " + sideSteps + " cells RIGHT from START.";
                        drawReturn = drawPath(startIndex, sideSteps, 1, msg);
                        System.out.println("        sideSteps:"+(cols-(startIndex % cols)));

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                    break;
                case 2 : //move diagonally or side to side
                if(steps != 0) {
                    if (endIsLeft) {
                        msg = "    SWITCH A: 2a, moved " + steps + " rows DOWN/LEFT from START.";
                        // for (int i = steps; i > 0; i--) {
                        //     //Don't go past the end point & don't move past the borders of the grid
                        //     if (startIndex + (cols-1) >= endIndex || startIndex % cols == 0) {
                        //     break;
                        //     } 
                        // else {
                        //         startEndDelta -=cols - 1;
                        //         startIndex += cols - 1;
                        //     }
                        // }
                        drawReturn = drawPath(startIndex, steps, cols-1, msg);

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                    else if (!endIsLeft) {
                        msg = "    SWITCH A: 2b, moved " + steps + " rows DOWN/RIGHT from START.";
                        // for (int i = steps; i > 0; i--) {
                        //     //Don't go past the end point & don't move past the borders of the grid
                        //     if (startIndex + (cols+1) >= endIndex || startIndex % cols == cols-1){
                        //         break;
                        //     }
                        //     else {
                        //         startEndDelta -=cols + 1;
                        //         startIndex += cols + 1;
                        //     }
                        // }
                        drawReturn = drawPath(startIndex, steps, cols+1, msg);

                        startIndex += drawReturn;
                        startEndDelta -= drawReturn;
                    }
                else {
                    System.out.println("    SWITCH A: 2c, met condition OTHER");
                    System.out.println(startEndDelta);
                    startEndDelta = 0;
                }
                }
                break;
            }
        }
        else if (startEndDelta < cols) {
            if (startEndDelta == cols-1) { //Hasn't triggered yet
                System.out.println("    !!(LEGAL)" + startEndDelta + " DELTA REMAINING. SETTING TO 0.");
                startEndDelta = 0;
            }

            if (endIsLeft) {
                msg = "    SWITCH B: True, moved " + (cols-startEndDelta) + " rows LEFT from START.";
                //"cols-startEndDelta" bc otherwise it wants to go left all the way to the next line
                drawReturn = drawPath(startIndex, cols-startEndDelta, -1, msg);

                startIndex += drawReturn;
                startEndDelta -= drawReturn;
            }
            else if (!endIsLeft) {
                msg = "    SWITCH B: False, moved " + startEndDelta + " rows RIGHT from START.";
                drawReturn = drawPath(startIndex, startEndDelta, 1, msg);

                startIndex += drawReturn;
                startEndDelta -= drawReturn;
            }

            if(startEndDelta > 0) { 
                // !!use to be nested in endIsLeft and !endIsLeft & never got triggered
                // check whats up if this starts getting triggered
                System.out.println(startEndDelta + " DELTA REMAINING. SETTING TO 0.");
                startEndDelta = 0;
            }
        }
        
    } while(startEndDelta > 0);
    
}

int drawPath( int index, int loopCounter, int incrNum, String message) {
    int indexStart = index;
    int indexEnd;

    System.out.println(message); //for debugging

    for(int i = loopCounter; i > 0; i--) {
        if (i % cols == 0 || i % cols == cols-1) //Don't move off grid left || Don't move off grid right
        {
            break;
        }
        index += incrNum;
        cells[index].isActive = true;
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