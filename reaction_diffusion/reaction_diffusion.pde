float[][] aLevel;
float[][] bLevel;

float[][] lastALevel;
float[][] lastBLevel;

float[] kernal = {
  0.05,  0.2, 0.05,
  0.2,  -1.0, 0.2,
  0.05,  0.2, 0.05
}; int[] n = { -1, -1,  -1, 0,  -1, 1,
   0, -1,   0, 0,   0, 1,
   1, -1,   1, 0,   1, 1
};

int xSize, ySize;
float cellWidth, cellHeight;

float dA, dB, feed, k;

void setup() {
  size(640, 640);
  xSize = ySize = 64;

  cellWidth = width / xSize;
  cellHeight = height / ySize;

  aLevel = new float[xSize][ySize];
  bLevel = new float[xSize][ySize];

  lastALevel = new float[xSize][ySize];
  lastBLevel = new float[xSize][ySize];

  for( int i = 0; i < xSize; i += 1 ) {
    for( int j = 0; j < ySize; j += 1 ) {
      aLevel[i][j] = 1;
      bLevel[i][j] = 0;
      lastALevel[i][j] = 1;
      lastBLevel[i][j] = 0;
    }
  }

  setDefault();
  kernal = defaultKernal();
  walkKernal(3);
  initBlobs(4);

  noStroke();
}

void randomNeightborhood(int range) {
  for(int i = 0; i < 18; i += 1) {
    n[i] = floor(random(-range, range));
  }
}

void initBlobs(int numBlobs) {
  for( int k = 0; k < numBlobs; k += 1 ) {
    int startx = int(random(20, xSize-20));
    int starty = int(random(20, ySize-20));

    for (int i = startx; i < startx+10; i++) {
      for (int j = starty; j < starty+10; j ++) {
        float a = 1;
        float b = 1;
        aLevel[i][j] = 1;
        bLevel[i][j] = 1;
        lastALevel[i][j] = 1;
        lastBLevel[i][j] = 1;
      }
    }
  }
}

void update() {
  for( int i = 0; i < xSize; i += 1 ) {
    for( int j = 0; j < ySize; j += 1 ) {
      float a = lastALevel[i][j];
      float b = lastBLevel[i][j];

      float lapA = 0; 
      float lapB = 0; 

      float tempDA = dB * -a;
      float tempDB = dA + dB * b;

      for( int k = 0; k < 9; k += 1 ) {
        lapA += lastALevel[wrapX(i + n[k * 2])][wrapY(j + n[(k * 2) + 1])] * kernal[k];
        lapB += lastBLevel[wrapX(i + n[k * 2])][wrapY(j + n[(k * 2) + 1])] * kernal[k];
      }

      float newA = a + ( tempDA * lapA - a * b * b + feed * ( 1 - a ) ) * 0.4;
      float newB = b + ( tempDB * lapB + a * b * b - ( k + feed ) * b ) * 0.4;

      aLevel[i][j] = constrain(newA, 0, 1);
      bLevel[i][j] = constrain(newB, 0, 1);
    }
  }
}

void draw() {
  update();
  swap();

  for( int i = 0; i < xSize; i += 1 ) {
    for( int j = 0; j < ySize; j += 1 ) {
      
      float val = bLevel[i][j] - aLevel[i][j];
      fill(( val * val * val ) * 255);
      rect(i * cellWidth, j * cellHeight, cellWidth + 1, cellHeight + 1);
    }
  }
}

void swap() {
  float[][] tempA = lastALevel;
  float[][] tempB = lastBLevel;
  lastALevel = aLevel;
  lastBLevel = bLevel;
  aLevel = tempA;
  bLevel = tempB;
}

void setDefault() {
  dA = 0.8;
  dB = 0.5;
  feed = 0.055;
  k = 0.062;
}

/* void setDefault() { */
/*   dA = 1.0; */
/*   dB = 0.5; */
/*   feed = 0.055; */
/*   k = 0.062; */
/* } */

void setRandom() {
  dA = random(1.0, 1.5);
  dB = random(1.5, 2.0);
  feed = random(0.1);
  k = random(0.1);
}

int wrapX(int i) {
  return ( xSize + ( i % xSize )) % xSize;
}

int wrapY(int i) {
  return ( ySize + ( i % ySize )) % ySize;
}

void mouseClicked() {
  setup();
}

void randomKernal() {
  float total = 0;
  for(int i = 0; i < 8; i += 1) {
    float val;
    if ( total != 0 ) {
      /* println("!!"); */
      val = random(0, total) * -1.1;
    }
    else {
      println("!");
      val = random(-1, 1);
    }
    kernal[i] = val;
    total += val;
  }
  kernal[8] = -total;
  kernal = shuffle(kernal);
}

void walkKernal(int iterations) {
  for(int i = 0; i < iterations; i += 1) {
    int r1 = floor(random(0, 9));
    int r2 = r1;
    while(r1 == r2) {
      r2 = floor(random(0, 9));
    }
    float val = random(0.000, 0.100);
    kernal[r1] += val;
    kernal[r2] -= val;
  }

  /* kernal = shuffle(kernal); */
}

float[] defaultKernal() {
  float[] k = {
    0.05,  0.2, 0.05,
    0.2,  -1.0, 0.2,
    0.05,  0.2, 0.05
  };
  return k;
}

float[] shuffle(float[] input) {
  for(int i = 0; i < input.length; i += 1) {
    int pos = floor(random(input.length));
    float temp = input[i];
    input[i] = input[pos];
    input[pos] = temp;
  }

  return input;
}
