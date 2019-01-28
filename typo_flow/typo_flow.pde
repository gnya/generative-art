/**
 * author: ぐにゃ (https://twitter.com/gnya_motion)
 * date:   2019 01 28
 */

import geomerative.*;

// window size
static final int WIDTH = 1000;
static final int HEIGHT = 1000;

// offset
static final int X_C = WIDTH / 2;
static final int Y_C = HEIGHT / 2;

// scaling
static final int SCALE = 5;

// number of loop
static final int N = 100000;

// font setting
static final String FONT_NAME = "FreeSansNoPunch.ttf";

// noise setting
static final int NOISE_SEED = 100;
static final float NOISE_STEP = 0.0018;

// Typo Flow setting
static final float COUNT_LIMIT = 3000;

void settings() {
  size(WIDTH, HEIGHT);
}

void setup() {
  smooth();
  noLoop();
  background(250, 245, 240);
  colorMode(HSB);
  noiseSeed(NOISE_SEED);
}

void draw() {
  // generate noise
  float[][][] v = new float[WIDTH][HEIGHT][2];
  float[][] start = {{-20.0, +20.0}, {0.0, 0.0}};
  fillArrayNoise(v, start);
  
  // calc Typo Flow
  float[][] count = new float[WIDTH][HEIGHT];
  float max1 = calcTypoFlow(count, v, "abc",  50, 0, -200);
  float max2 = calcTypoFlow(count, v, "ABC", 200, 0, +100);
  float max = max1 > max2 ? max1 : max2;
  
  loadPixels();
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      if (count[x][y] == 0) continue;
      int idx = y * WIDTH + x;
      float c = count[x][y] > max ? max : count[x][y];
      float p = sqrt(c / max);
      float h = hue(pixels[idx]) + 200 * sqrt(p);
      h = h % 256; // cliping
      float s = saturation(pixels[idx]) + 150 * p;
      if (s > 255) s = 255; // cliping
      float b = brightness(pixels[idx]) - 200 * p;
      if (b < 0) b = 0; // cliping
      pixels[idx] = color(h, s, b);
    }
  }
  
  updatePixels();
  
  println("できました！");
}

void keyPressed() {
  // save image on press 'S' key 
  if (key == 's' || key == 'S') {
    // generate path
    String path = "result/img" + System.currentTimeMillis() + ".png";
    
    // save
    save(path);
    println("保存しました！  " + path);
  }
}

float calcTypoFlow(float[][] count, float[][][] v, String text, 
                   int font_size, float x_c, float y_c) {
  // initialize the library
  RG.init(this);
  RFont font = new RFont(FONT_NAME, font_size, RFont.CENTER);
  
  // get the point on the curve's shape
  RCommand.setSegmentLength(1);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
  RGroup group = font.toGroup(text);
  RPoint[] points = group.getPoints();
  RPoint center = group.getCenter();
  
  float max = 0.0;
  
  // iteration
  for (RPoint p : points) {
    float x = p.x - center.x + X_C + x_c;
    float y = p.y - center.y + Y_C + y_c;
    float x_old, y_old;
    
    for (int i = 0; i < N; i++) {
      int x_img = (int) x;
      int y_img = (int) y;
      
      if (x_img < 0 || x_img >= WIDTH 
          || y_img < 0 || y_img >= HEIGHT) break;
      
      // counting
      count[x_img][y_img] += 1.0 - (float) i / N;
    
      // update max
      if (count[x_img][y_img]> max) {
        max = count[x_img][y_img];
      }
      
      // update x and y
      x_old = x; y_old = y;
      x = x_old + 0.1 * v[x_img][y_img][0];
      y = y_old + 0.1 * v[x_img][y_img][1];
    }
  }
  
  max = max > COUNT_LIMIT ? COUNT_LIMIT : max;
  
  return max;
}

void fillArrayNoise(float[][][] noises, float[][] start) {
  float[] offset_x = start[0].clone();
  
  for (int x = 0; x < WIDTH; x++) {
    float[] offset_y = start[1].clone();
    
    for (int y = 0; y < HEIGHT; y++) {
      for (int i = 0; i < start.length; i++) {
        noises[x][y][i] = 2 * (noise(offset_x[i], offset_y[i]) - 0.5);
        offset_y[i] += NOISE_STEP;
      }
    }
    
    for (int i = 0; i < start.length; i++) {
      offset_x[i] += NOISE_STEP;
    }
  }
}
