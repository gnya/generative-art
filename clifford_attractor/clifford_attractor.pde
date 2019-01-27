/**
 * author: ぐにゃ (https://twitter.com/gnya_motion)
 * date:   2019 01 27
 */

// window size
static final int WIDTH = 1000;
static final int HEIGHT = 1000;

// offset
static final int X_C = WIDTH / 2;
static final int Y_C = HEIGHT / 2;

// scaling
static final int SCALE = 120;

// number of loop
static final int N = 5000000;

// parameter of Clifford Attractor
static final float A = -2.0;
static final float B = -1.5;
static final float C = -2.0;
static final float D = -1.8;

void settings() {
  size(WIDTH, HEIGHT);
}

void setup() {
  smooth();
  noLoop();
  background(250, 245, 240);
  colorMode(HSB);
}

void draw() {
  int[][] count = new int[WIDTH][HEIGHT];
  int max = calcCliffordAttractor(count, A, B, C, D);
  
  loadPixels();
  
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      if (count[x][y] == 0) continue;
      int idx = y * WIDTH + x;
      float p = sqrt((float) count[x][y] / max);
      float h = hue(pixels[idx]) + 200 * sqrt(p);
      h = h % 256; // cliping
      float s = saturation(pixels[idx]) + 400 * p;
      if (s > 255) s = 255; // cliping
      float b = brightness(pixels[idx]) - 300 * p;
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

int calcCliffordAttractor(int[][] count, float a, float b, float c, float d) {
  // initialization of valiables
  float x_next, x = 0.0;
  float y_next, y = 0.0;
  
  int max = 0;
  
  // iteration
  for (int i = 0; i < N; i++) {
    // counting
    int x_img = (int) (x * SCALE + X_C);
    int y_img = (int) (y * SCALE + Y_C);
    count[x_img][y_img]++;
    
    // update max
    if (count[x_img][y_img] > max) {
      max = count[x_img][y_img];
    }
    
    // update x and y
    x_next = sin(a * y) + c * cos(x);
    y_next = sin(b * x) + d * cos(y);
    x = x_next; y = y_next;
  }
  
  return max;
}
