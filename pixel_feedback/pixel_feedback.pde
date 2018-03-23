float[] reactionKernal = {
  0.05,  0.2, 0.05,
  0.2,  -1.0, 0.2,
  0.05,  0.2, 0.05
}; 

float[] blurKernal = {
  0.0625, 0.1250, 0.0625,
  0.1250, 0.2500, 0.1250,
  0.0625, 0.1250, 0.0625
};


float[] sharpKernal = {
   0.0, -0.5,  0.0,
  -0.5,  3.0, -0.5,
   0.0, -0.5,  0.0
};

int[] n = {
  -1, -1,  -1, 0,  -1, 1,
   0, -1,   0, 0,   0, 1,
   1, -1,   1, 0,   1, 1
};

int xSize, ySize;
int viewerWidth, viewerHeight;
float cellWidth, cellHeight;

float[][] bufferA;
float[][] bufferB;
PVector[][] bufferC;

PGraphics graphics;

float zoomSpeed;
float rotationAngle;

float vA, vB, vC, vD, vE, vF, vG;
float xA, xB, xC, xD, xE;
float yA, yB, yC, yD, yE, yF, yG;

void preset() {
  rotationAngle = random(-0.001, 0.001);
  zoomSpeed = random(0.98, 1.02);
}

void setup() {
  size(640, 640);
  // fullScreen();
  noCursor();
  preset();
  xSize = ySize = 64;

  viewerWidth = xSize * 4;
  viewerHeight = ySize * 8;

  cellWidth = viewerWidth / xSize;
  cellHeight = viewerHeight / ySize;

  bufferA = new float[xSize][ySize];
  bufferB = new float[xSize][ySize];
  bufferC = new PVector[xSize][ySize];

  graphics = createGraphics(xSize, ySize);


  for(int i = 0; i < xSize; i += 1) {
    for( int j = 0; j < ySize; j += 1 ) {
      bufferA[i][j] = noise(i * 0.1, j * 0.1);
      bufferB[i][j] = bufferA[i][j];
      bufferC[i][j] = new PVector(
        /* i * cellWidth - viewerWidth * 0.5, */
        i * cellWidth,
        j * cellHeight - viewerHeight * 0.5,
        j * cellHeight - viewerHeight * 0.5
      );
    }
  }

  noStroke();
  colorMode(RGB);
  background(250, 250, 255);
}

void draw() {
  translate(width * 0.5, height * 0.5);
  sharpen();
  blur();
  blur();
  colorMode(HSB, 360, 100, 100);
  for(int i = 0; i < xSize; i += 1) {
    for(int j = 0; j < ySize; j += 1) {
      fill(
        bufferB[i][j] * 200 + 160,
        bufferB[i][j] * 30,
        100 - bufferB[i][j] * 100
      );

      rect(bufferC[i][j].x, bufferC[i][j].y, cellWidth * 2, cellHeight * 2);
      rect(-bufferC[i][j].x, bufferC[i][j].y, cellWidth * 2, cellHeight * 2);
    }
  }

  if ( frameCount % 10 == 0 ) {
    walkKernal(sharpKernal, 1, 0.1);
    walkKernal(blurKernal, 1, 0.01);
  }
  if (frameCount % 300 == 0) {
    preset();
    resetKernals();
  }
  // saveFrame(frameCount + ".gif");
}


void sharpen() {
  for( int i = 0; i < xSize; i += 1 ) {
    for( int j = 0; j < ySize; j += 1 ) {
      float sum = 0;
      for( int k = 0; k < 9; k += 1 ) {

        int x = wrapX(i + (bufferA[i][j] * 2) - 1 + n[k * 2]);
        int y = wrapY(j + (bufferB[i][j] * 2) - 1 + n[(k * 2) + 1]);

        sum += bufferA[x][y] * sharpKernal[k];
      }

      float v = sin(i * 0.01 + cos(i * 0.1) + frameCount * 0.0001) * cos(i * 0.001 + frameCount * 0.002) * 0.03;
      sum = constrain(sum+ v, 0.0, 1.0);

      
      float xOffset = sin(frameCount * 0.02+ i * 0.01) * 0.5 * (noise(i * 0.001, j * 0.01, frameCount / 5 * 0.001) * 2) - 1;
      float yOffset = cos(frameCount * 0.01 + j * 0.1 * 0.5 * sin(i * 0.2 + frameCount * 0.005)) * (noise(i * 0.005, j * 0.02, frameCount / 5 * 0.001) * 2) - 1;

      bufferB[
        wrapX(i + xOffset)
      ][
        wrapY(j + yOffset)
      ] = sum;
    }
  }
}

void blur() {
  zoom(zoomSpeed, rotationAngle);
  for( int i = 0; i < xSize; i += 1 ) {
    for( int j = 0; j < ySize; j += 1 ) {
      float sum = 0;
      for( int k = 0; k < 9; k += 1 ) {
        sum += bufferB[wrapX(i + n[k * 2])][wrapY(j + n[(k * 2) + 1])] * blurKernal[k];
      }

      float v = sin(i * 0.01 + sin(j * 0.1) + frameCount * 0.001) * cos(j * 0.001 + frameCount * 0.002) * 0.01;
      sum = constrain(sum + v, 0.0, 1.0);

      bufferA[i][j] = sum;
    }
  }
}

void zoom(float z, float r) {
  graphics.beginDraw();

  graphics.loadPixels(); 

  colorMode(RGB);
  for(int i = 0; i < xSize; i += 1) {
    for( int j = 0; j < ySize; j += 1 ) {
      int index = i + j*xSize;

      graphics.pixels[index] = color(
        bufferB[i][j] * 255, 
        bufferB[i][j] * 255, 
        bufferB[i][j] * 255
      );
    }
  }

  graphics.updatePixels();

  graphics.translate(xSize * 0.5, ySize * 0.5);
  graphics.rotate(r);
  graphics.scale(z);
  graphics.image(graphics, -xSize * 0.5, -ySize * 0.5, xSize, ySize);

  graphics.endDraw();

  graphics.loadPixels();

  for(int i = 0; i < xSize; i += 1) {
    for( int j = 0; j < ySize; j += 1 ) {
      int index = i + j*xSize;
      float p = red(graphics.pixels[index]) / 255;
      bufferB[i][j] = p;
    }
  }
}


float[] walkKernal(float[] kernal, int iterations, float m) {
  for(int i = 0; i < iterations; i += 1) {
    int r1 = floor(random(0, 9));
    int r2 = r1;
    while(r1 == r2) {
      r2 = floor(random(0, 9));
    }
    float val = random(0.000, m);
    kernal[r1] += val;
    kernal[r2] -= val;
  }

  return kernal;

  /* kernal = shuffle(kernal); */
}

int wrapX(int i) {
  return ( xSize + ( i % xSize )) % xSize;
}

int wrapY(int i) {
  return ( ySize + ( i % ySize )) % ySize;
}

int wrapX(float f) {
  int i = floor(f);
  return ( xSize + ( i % xSize )) % xSize;
}

int wrapY(float f) {
  int i = floor(f);
  return ( ySize + ( i % ySize )) % ySize;
}

void mouseClicked() {
  float noiseScale = random(0.01, 0.3);
  resetKernals();
  for(int i = 0; i < xSize; i += 1) {
    for( int j = 0; j < ySize; j += 1 ) {
      bufferA[i][j] = noise(i * noiseScale, j * noiseScale);
      bufferB[i][j] = bufferB[i][j];
      bufferC[i][j] = new PVector(
        /* i * cellWidth - viewerWidth * 0.5, */
        i * cellWidth,
        j * cellHeight - viewerHeight * 0.5,
        j * cellHeight - viewerHeight * 0.5
      );
    }
  }
}

void resetKernals() {
  float[] b = {
    0.0625, 0.1250, 0.0625,
    0.1250, 0.2500, 0.1250,
    0.0625, 0.1250, 0.0625
  };


  float[] s = {
     0.0, -0.5,  0.0,
    -0.5,  3.0, -0.5,
     0.0, -0.5,  0.0
  };

  blurKernal = b;
  sharpKernal = s;
}
