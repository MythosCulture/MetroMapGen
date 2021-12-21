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

void CreateGrid()
{
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

void CreateRandomPoints()
{
    rnd = new int[points];
    
    for (int i = 0; i < points; i++) {
        rnd[i] = (int)random(cells.length);
}
    
    Arrays.sort(rnd);
    
    int rndFirst = rnd[0];
    int rndLast = rnd[rnd.length - 1];
    
    //int temp = (int)(rndLast/cols)-(rndFirst/cols);
    //int temp2 = ((temp*cols)-(rndFirst/cols))-rndLast;
    
    noStroke();
    fill(color1);
    //for( int i = temp; i > 0; i --)
    //{
    //circle(cells[rndFirst + (cols * i)].x, cells[rndFirst + (cols * i)].y, cellSize);
//}
    FindPath(rndFirst, rndLast);
    
}

void FindPath(int start, int end)
{
    int startIndex = start;
    int endIndex = end;
    int startEndDelta = end - start; //tracks # of indexes between start and end
    
    do{
        //Calculating rows ("steps") allowed to travel for given cycle
        double calculateSteps = (double)(startEndDelta) / cols;
        int steps = (int)random((int)calculateSteps + 1);
        boolean endIsLeft = (startIndex % cols > endIndex % cols) ? true : false;
        
        System.out.println("endIsLeft: " + endIsLeft);
        System.out.println("calculateSteps: " + calculateSteps);
        System.out.println("steps: " + steps);
        System.out.println("startEndDelta: " + startEndDelta);
        
        if (startEndDelta > cols) {
            switch((int)random(3)) {
                default:
                case 0 : //move down from start
                    System.out.println("    SWITCH A: 0, moved " + steps + " rows DOWN from START.");
                    for (int i = steps; i > 0; i--) {
                        startEndDelta -= cols;
                        startIndex += cols;
                        circle(cells[startIndex].x, cells[startIndex].y, cellSize);
                    }
                    break;
                case 1 : //move up from end
                    System.out.println("    SWITCH A: 1, moved " + steps + " rows UP from END.");
                    for (int i = steps; i > 0; i--) {
                        startEndDelta -= cols;
                        endIndex-= cols;
                        circle(cells[endIndex].x, cells[endIndex].y, cellSize);
                    }
                    break;
                case 2 : //move diagonally or side to side
                    if (endIsLeft) {
                        System.out.println("    SWITCH A: 2a, moved " + steps + " rows DOWN/LEFT from START.");
                        for (int i = steps; i > 0; i--) {
                            //Don't go past the end point & don't move past the borders of the grid
                            if (startIndex + (cols-1) >= endIndex || startIndex % cols == 0) {
                            break;
                            } 
                        else {
                                startEndDelta -=cols - 1;
                                startIndex += cols - 1;
                                circle(cells[startIndex].x, cells[startIndex].y, cellSize);
                            }
                        }
                    }
                    else if (!endIsLeft) {
                        System.out.println("    SWITCH A: 2b, moved " + steps + " rows DOWN/RIGHT from START.");
                        for (int i = steps; i > 0; i--) {
                            //Don't go past the end point & don't move past the borders of the grid
                            if (startIndex + (cols+1) >= endIndex || startIndex % cols == cols-1){
                                break;
                            }
                            else {
                                startEndDelta -=cols + 1;
                                startIndex += cols + 1;
                                circle(cells[startIndex].x, cells[startIndex].y, cellSize);
                            }
                        }
                    }
                else {
                    System.out.println("    SWITCH A: 2c, met condition OTHER");
                    System.out.println(startEndDelta);
                    startEndDelta = 0;
                }
                break;
            }
        }
        else if (startEndDelta < cols) {
            if (startEndDelta == cols-1) { ///ADD TO IF STATEMENT!!!!!!!!!!!
                System.out.println("    !!(LEGAL)" + startEndDelta + " DELTA REMAINING. SETTING TO 0.");
                startEndDelta = 0;
            }
            if (endIsLeft) {
                System.out.println("    SWITCH B: True, moved " + (cols-startEndDelta) + " rows LEFT from START.");
                for (int i =  cols-startEndDelta; i > 0; i--) { 
                    //"cols-startEndDelta" bc otherwise it wants to go left all the way to the next line
                    //Don't move past the borders of the grid
                    if (i % cols == 0) {
                        break;
                    } 
                    else {
                        startEndDelta--;
                        startIndex--;
                        circle(cells[startIndex].x, cells[startIndex].y, cellSize);
                    }
                }
                if(startEndDelta > 0) {
                    System.out.println(startEndDelta + " DELTA REMAINING. SETTING TO 0.");
                    startEndDelta = 0;
                }
            }
            else if (!endIsLeft) {
                System.out.println("    SWITCH B: False, moved " + startEndDelta + " rows RIGHT from START.");
                for (int i = startEndDelta; i > 0; i--) { 
                    //Don't move past the borders of the grid
                    if (i % cols == cols - 1) {
                        break;
                    }
                    else {
                        startEndDelta--;
                        startIndex++;
                        circle(cells[startIndex].x, cells[startIndex].y, cellSize);
                    }
                }
                if(startEndDelta > 0) {
                    System.out.println(startEndDelta + " DELTA REMAINING. SETTING TO 0.");
                    startEndDelta = 0;
                }
            }
        }
        
    } while(startEndDelta > 0);
    
    
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
    
    stroke(0, 0, 0);
    line(cells[rnd[0]].x, cells[rnd[0]].y, cells[rnd[rnd.length - 1]].x, cells[rnd[rnd.length - 1]].y);
    
    noStroke();
    fill(color1);
    
    for (int item : rnd) {
        circle(cells[item].x, cells[item].y, cellSize);
    }
    
}

class Cell {
    //Add variables to cells as needed...
    float x, y; //center of cell
    
    Cell(float x, float y) {
        this.x = x;
        this.y = y;
    }
    
}
