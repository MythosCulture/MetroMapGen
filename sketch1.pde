import java.util.*;
import java.lang.Math;

Cell[] cells;
int rows, cols, points;
int[] rnd;
float cellSize;
color color1 = #BF573F;
color color2 = #c89fc1;

void setup() {
    size(700, 700);
    background(0, 50, 70); //change color
    
    cellSize = 10; //width and height of cell
    cols = int(width / cellSize + 1);
    rows = int(height / cellSize + 1);
    
    points = 10;
    
    CreateGrid();    

    int testLength = cols>rows?cols:rows;
    
    

    Cell randomCell1 = cells[(int)random(cells.length)];
    MetroLine testLine = new MetroLine(color1, testLength, randomCell1);
    testLine.generate();

    System.out.println("Starting Cell Index: " + randomCell1.gridIndex); //delete later
    System.out.println("Starting Cell X,Y: " + randomCell1.x +", " + randomCell1.y); //delete later

    Cell randomCell2 = cells[(int)random(cells.length)];
    MetroLine testLine2 = new MetroLine(color2, testLength, randomCell2);
    testLine2.generate();
    
    noLoop();
}

void CreateGrid() {
    cells = new Cell[rows * cols];
    
    int index = 0;
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            
            float centerX = c * cellSize;
            float centerY = r * cellSize;
            
            cells[index] = new Cell(centerX,centerY,index);
            
            index++;
        }
    }
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

    stroke(0, 0, 0);
    strokeWeight(1);
}

class Cell {
    //Add variables to cells as needed...
    int gridIndex;
    float x, y; //center of cell
    boolean isActive = false; //active = part of a line
    boolean isTopBorder, isBottomBorder, isLeftBorder, isRightBorder = false;
    
    Cell(float x, float y, int gridIndex) {
        this.x = x;
        this.y = y;
        this.gridIndex = gridIndex;

        if(gridIndex >= 0 && gridIndex <= cols - 1) this.isTopBorder = true;
        if(gridIndex <= cells.length - 1 && gridIndex >= cells.length - cols) this.isBottomBorder = true;

        if(gridIndex % cols == 0) this.isLeftBorder = true;
        if(gridIndex % cols == 1) this.isRightBorder = true;

    }
    
}

class MetroLine {
    color lineColor;
    int numOfStops, lineLength;
    Cell startCell;
    List<Cell> activeCells;

    MetroLine(color lineColor, int lineLength, Cell startCell) {
        this.lineColor = lineColor;
        this.lineLength = lineLength;
        this.startCell = startCell;

        activeCells = new ArrayList<Cell>();

        System.out.println("Metro Line created"); //delete later
        System.out.println("Color: " + this.lineColor + "; lineLength: " + this.lineLength + "; Cell starting index: " + this.startCell.gridIndex); //delete later
    }

    void generate() {

        int[] segmentLengths = new int[] {10, 5, 15, 5};
        Cell start = startCell;
        Cell end = startCell;
        Cell currentCell = startCell;
        String prevDirection = "none";

        System.out.println("Segment array " + Arrays.toString(segmentLengths) +"\n"); //delete later
        for(int i = 0; i < segmentLengths.length; i++) {
            System.out.println("\nMetro Line segment generation... iteration " + i); //delete later

            start = currentCell; //start of current metro line portion
            System.out.println("    start cell: " + start.gridIndex); //delete later
            System.out.println("    segmentLength: " + segmentLengths[i]); //delete later

            String direction = randomDirection(getDirections(currentCell, prevDirection));
            prevDirection = direction;
            System.out.println("        Starting direction: " + direction); //delete later

            //Somehow able to push out of bounds of the index...
            for(int j = 0; j < segmentLengths[i]; j++) {

                Cell adjacentCell = getAdjacentCell(currentCell, direction);
                

                if(currentCell == adjacentCell) {
                    //If it hits a border, change direction and continue
                    end = currentCell;
                    System.out.println("        hit border, end cell: " + end.gridIndex); //delete later
                    drawLine(start, end);
                    start = currentCell;

                    direction = randomDirection(getDirections(currentCell, prevDirection));
                    System.out.println("    Changing Direction to: " + direction); //delete later
                } else {
                    currentCell = adjacentCell;
                    end = currentCell;

                    currentCell.isActive = true;
                    activeCells.add(currentCell);
                }
            }
            System.out.println("    Start cell: " + start.gridIndex + " End cell: " + end.gridIndex); //delete later
            drawLine(start, end);
        }
    }

    private void drawLine(Cell start, Cell end) {
        stroke(lineColor);
        strokeWeight(cellSize * 1.5);
        line(start.x, start.y, end.x, end.y);
        noStroke();
    }

    private String randomDirection (List<String> directions) {
        if(directions.size() == 0) { //temporary
            directions.add("up");
            directions.add("down");
            directions.add("left");
            directions.add("right");
            directions.add("upleft");
            directions.add("upright");
            directions.add("downleft");
            directions.add("downright");
            System.out.println("Directions list empty, refilled contents.");
        }

        String message = "  DIRECTIONS LIST: "; //delete later
        for(String item: directions){ //delete later
            message += item + " ";
        }
        System.out.println(message); //delete later

        return directions.get((int)random(directions.size()));
    }

    private List<String> getDirections(Cell cell, String prevDirection) {
        //If it hits an corner from a diagonal direction, it'll have no options...
        List<String> directions = new ArrayList<>();
        directions.add("up");
        directions.add("down");
        directions.add("left");
        directions.add("right");
        directions.add("upleft");
        directions.add("upright");
        directions.add("downleft");
        directions.add("downright");


        if(cell.isLeftBorder){
            directions.remove("left");
            directions.remove("upleft");
            directions.remove("downleft");
        }
        if(cell.isRightBorder){
            directions.remove("right");
            directions.remove("upright");
            directions.remove("downright");
        }
        if(cell.isBottomBorder) {
            directions.remove("down");
            directions.remove("downleft");
            directions.remove("downright");
        }
        if(cell.isTopBorder) {
            directions.remove("up");
            directions.remove("upleft");
            directions.remove("upright");
        }

        //Don't pick previous direction & don't pick the direction it came from (so it doesn't cross over itself)
        if(prevDirection == "left" || prevDirection == "right") {
            directions.remove("left");
            directions.remove("right");

            if(prevDirection == "left") {
                directions.remove("upright");
                directions.remove("downright");
            }
            if(prevDirection == "right") {
                directions.remove("upleft");
                directions.remove("downleft");
            }
        }
        if(prevDirection == "up" || prevDirection == "down") {
            directions.remove("up");
            directions.remove("down");

            if(prevDirection == "up") {
                directions.remove("downleft");
                directions.remove("downright");
            }
            if(prevDirection == "down") {
                directions.remove("upleft");
                directions.remove("upright");
            }
        }
        if(prevDirection == "upright" || prevDirection == "downleft") {
            directions.remove("upright");
            directions.remove("downleft");

            if(prevDirection == "upright") {
                directions.remove("down");
                directions.remove("left");
            }
            if(prevDirection == "downleft") {
                directions.remove("up");
                directions.remove("right");
            }
        }
        if(prevDirection == "upleft" || prevDirection == "downright") {
            directions.remove("upleft");
            directions.remove("downright");

            if(prevDirection == "upleft") {
                directions.remove("down");
                directions.remove("right");
            }
            if(prevDirection == "downright") {
                directions.remove("up");
                directions.remove("left");
            }
        }

        return directions;
    }

    private Cell getAdjacentCell(Cell cell, String dir) {
        String errorMsg = "...Can't get adjecent cell: ";
        Cell result = cell;

        if(dir == "up") {
            errorMsg += "up of " + cell.gridIndex;
            if(!cell.isTopBorder) {
                return cells[cell.gridIndex - cols];
            } else{
                System.out.println(errorMsg);
            }
        }
        if(dir == "down") {
            errorMsg += "down of " + cell.gridIndex;
            if(!cell.isBottomBorder) {
                return cells[cell.gridIndex + cols];
            } else{
                System.out.println(errorMsg);
            }
        }
        if(dir == "left") {
            errorMsg += "left of " + cell.gridIndex;
            if(!cell.isLeftBorder) {
                return cells[cell.gridIndex - 1];
            } else{
                System.out.println(errorMsg);
            }
        }
        if(dir == "right") {
            errorMsg += "right of " + cell.gridIndex;
            if(!cell.isRightBorder) {
                return cells[cell.gridIndex + 1];
            } else{
                System.out.println(errorMsg);
            }
        }

        //Diagonals
        if(dir == "upleft") {
            errorMsg += "upleft of " + cell.gridIndex;
            if(!cell.isTopBorder && !cell.isLeftBorder) {
                return cells[cell.gridIndex - cols - 1];
            } else{
                System.out.println(errorMsg);
            }
        }
        if(dir == "upright") {
            errorMsg += "upright of " + cell.gridIndex;
            if(!cell.isTopBorder && !cell.isRightBorder) {
                return cells[cell.gridIndex - cols + 1];
            } else{
                System.out.println(errorMsg);
            }
        }
        if(dir == "downleft") {
            errorMsg += "downleft of " + cell.gridIndex;
            if(!cell.isBottomBorder && !cell.isLeftBorder) {
                return cells[cell.gridIndex + cols - 1];
            } else{
                System.out.println(errorMsg);
            }
        }
        if(dir == "downright") {
            errorMsg += "downright of " + cell.gridIndex;
            if(!cell.isBottomBorder && !cell.isRightBorder) {
                return cells[cell.gridIndex + cols + 1];
            } else{
                System.out.println(errorMsg);
            }
        }

        //System.out.println("Error in getAdjacentCell, returned original cell");
        return cell;

    }
}