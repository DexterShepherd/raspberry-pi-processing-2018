int numCols, numRows, numCells;
float initializationThreshhold, xScale, yScale;
Cell[][] cells;
Walker[] walkers;

void setup() {
  size(760, 640);
  numCols = numRows = 100;
  initializationThreshhold = 0.5;

  xScale = width / numCols;
  yScale = height / numRows;
  cells = new Cell[numRows][numCols];
  walkers = new Walker[100];

  for( int i = 0; i < numCols; i += 1 ) {
    for ( int j = 0; j < numRows; j += 1 ) {
      cells[i][j] = new Cell(i, j, 0);
    }
  }

  for( int i = 0; i < 100; i += 1 ) {
    walkers[i] = new Walker(new PVector(random(width * 0.5), random(height)));
  }

  /* colorMode(HSB, 360, 100, 100); */
  /* noStroke(); */
  stroke(0, 20);
  background(255);
}

void draw() {
  initCircle(frameCount, 100);
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

  for(int i = 0; i < walkers.length; i += 1) {
    walkers[i].update();
  }


  for(int i = 0; i < walkers.length; i += 1) {
    walkers[i].display();
  }
}

void initCircle(float r, int detail) {
  for(int i = 0; i < detail; i += 1) {
    float angle = map(i, 0, detail, 0, TWO_PI);
    int row = floor(sin(angle) * r + ( numRows / 2 ));
    int col = floor(cos(angle) * r + ( numCols / 2 ));
    cells[wrapCol(col)][wrapRow(row)].state = 1;
  }
}

class Walker {
  PVector loc;

  Walker(PVector _loc) {
    loc = _loc.copy();
  }

  void update() {
    int x = floor(map(loc.x, 0, width, 0, numCols));
    int y = floor(map(loc.y, 0, height, 0, numRows));

    float angle = map(cells[wrapCol(x)][wrapRow(y)].activationCount % 100, 0, 100, 0, 1) * TWO_PI;

    if ( angle != 0 ) {
      loc.x += sin(angle);
      loc.y += cos(angle);
    }

    if ( loc.x < 0  || loc.x > width * 0.5 || loc.y < 0 || loc.y > height ) {
      loc = new PVector(random(width * 0.5), random(height));
    }
  }

  void display() {
    if( loc.x <  width * 0.5 ) {
      point(loc.x, loc.y);
      point(map(loc.x, 0, width, width, 0), loc.y);
    }
  }
}

class Cell {
  PVector loc;
  int x, y, state, next, activationCount;
  int[][] n;

  Cell(int _x, int _y, int _s) {
    x = _x;
    y = _y;
    loc = new PVector(x * xScale, y * yScale);
    state = _s;
    next = _s;
    activationCount = 0;

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
    fill((activationCount * 0.5 % 100) + 200, 100, 100);
    if ( state == 1 ) {
      activationCount += 1;
      /* rect(loc.x, loc.y, 1, 1); */
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
