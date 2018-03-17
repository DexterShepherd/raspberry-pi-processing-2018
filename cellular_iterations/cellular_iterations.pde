int numCols, numRows, numCells;
float initializationThreshhold;
Cell[][] cells;

void setup() {
  size(500, 500);
  numCols = numRows = 100;
  initializationThreshhold = 0.5;
  cells = new Cell[numRows][numCols];
  for( int i = 0; i < numCols; i += 1 ) {
    for ( int j = 0; j < numRows; j += 1 ) {
      cells[i][j] = new Cell(
        i, j, random(1) > initializationThreshhold ? 1 : 0
      );
    }
  }
  fill(255);
  noStroke();
}

void draw() {
  background(0);
  for(int i = 0; i < numCols; i += 1) {
    for(int j = 0; j < numRows; j += 1) {
      cells[i][j].update();
    }
  }

  for(int i = 0; i < numCols; i += 1) {
    for(int j = 0; j < numRows; j += 1) {
      cells[i][j].display();
    }
  }
}

class Cell {
  int x, y, state, next;
  int[][] n;

  Cell(int _x, int _y, int _s) {
    x = _x;
    y = _y;
    state = _s;
    next = _s;

    n = new int[9][2];

    n[0][0] = -1; n[0][1] = -1;
    n[1][0] = -1; n[1][1] = 0;
    n[2][0] = -1; n[2][1] = 1;
    n[3][0] =  0; n[3][1] = -1;
    n[4][0] =  0; n[4][1] = 0;
    n[5][0] =  0; n[5][1] = 1;
    n[6][0] =  1; n[6][1] = -1;
    n[7][0] =  1; n[7][1] = 0;
    n[8][0] =  1; n[8][1] = 1;

  }

  void update() {
    int neighborhood = 0;       

    for( int i = 0; i < 9; i +=1 ) {
      int xIndex = wrapCol(x + n[i][0]);
      int yIndex = wrapRow(y + n[i][1]);
      neighborhood += cells[xIndex][yIndex].state;
    }

    neighborhood -= state;

    if ( state == 1 && neighborhood < 2) {
      next = 0;
    } else if ( state == 1 && neighborhood > 3 ) {
      next = 0;
    } else if ( state == 0 && neighborhood == 3 ) {
      next = 1;
    } else {
      next = state;
    }
  }

  void display() {
    if ( state == 1 ) {
      rect(x * 4, y * 4, 4, 4);
    }

    int temp = state;
    state = next;
    next = temp;
  }
}

int wrapRow(int i) {
  return ( numRows + ( i % numRows )) % numRows;
}

int wrapCol(int i) {
  return ( numCols + ( i % numCols )) % numCols;
}

void keyPressed() {
  if ( keyCode == BACKSPACE ) {
    exit();
  }
}
