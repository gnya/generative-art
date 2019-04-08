/**
 * author: ぐにゃ (https://twitter.com/gnya_a)
 * date:   2019 04 08
 */

import java.util.ArrayList;
import java.util.List;

// loop of Runge Kutta
static final int N = 50000;

// step-size of Runge Kutta
static final float H = 0.01;

static float window_scale = 1.0;
static PFont font = null;

// worker for calculate Runge Kutta
static RungeKuttaThread worker = null;

// attractor equation
static Equation equation = null;

// point of attractor
static List<PVector> attractor = null;
static List<PVector> dot_color = null;

// rotation matrix
static PMatrix3D matrix = null;

void setup() {
  // setup window
  size(800, 800, P3D);
  smooth();
  noFill();
  colorMode(HSB, 360, 256, 256);
  background(30, 10, 250);
  
  // font setting
  font = createFont("Open Sans Bold", 16);
  textFont(font);
  
  // setup attractor
  equation = new Lorenz(10, 28, 8. / 3.);
  //equation = new NoseHoover(1.5);
  //equation = new Halvorsen(1.4);
  
  // initial x
  PVector x = new PVector(0.1, 0, 0);
  
  // calculate attractor
  worker = new RungeKuttaThread(equation, H, N, x);
  new Thread(worker).start();
  
  // initialize rotation matrix
  matrix = new PMatrix3D();
}

void draw() {
  background(30, 10, 250);
  
  if (worker.is_running) {
    fill(80);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("wait...", width / 2, height / 2);
  } else {
    pushMatrix();
 
    translate(width / 2, height / 2);
    applyMatrix(matrix);
    scale(pow(1.08, window_scale));
  
    //draw attractor
    beginShape(LINE_STRIP);
    for (int i = 0; i < N + 1; i++) {
      PVector p = worker.pos.get(i);
      PVector c = worker.hsb.get(i);
      
      stroke(c.x, c.y, c.z);
      vertex(p.x, p.y, p.z);
    }
    endShape();
  
    popMatrix();
  
    fill(80);
    textSize(16);
    textAlign(CENTER, CENTER);
    text(equation.name(), width / 2, height * 0.85);
    textSize(12);
    text(equation.description(), width / 2, height * 0.85 + 20);
  }
}

// rotation matrix on mouse pressed
static PMatrix3D last_matrix = null;

// mouse pressed position
static float pressed_x;
static float pressed_y;

void mousePressed() {
  pressed_x = mouseX;
  pressed_y = mouseY;
  last_matrix = matrix;
}

void mouseDragged( ) {
  float x = mouseX - pressed_x;
  float y = mouseY - pressed_y;
  float theta = sqrt(x * x + y * y) * 0.005;
  PVector axis = new PVector(-y, x, 0);
  
  // update rotate matrix
  axis.normalize();
  matrix = getMatrix(axis, theta);
  matrix.apply(last_matrix);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  
  window_scale += e;
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

PMatrix3D getMatrix(PVector axis, float theta) {
  PMatrix3D ret = new PMatrix3D();
  float c = 1 - cos(theta);
  float s = 0 + sin(theta);
  float xx = axis.x * axis.x;
  float xy = axis.x * axis.y;
  float xz = axis.x * axis.z;
  float yy = axis.y * axis.y;
  float yz = axis.y * axis.z;
  float zz = axis.z * axis.z;
  
  ret.m00 = 1 + (xx - 1) * c;
  ret.m11 = 1 + (yy - 1) * c;
  ret.m22 = 1 + (zz - 1) * c;
  ret.m33 = 1;
  
  ret.m01 = xy * c - axis.z * s;
  ret.m10 = xy * c + axis.z * s;
  ret.m02 = xz * c + axis.y * s;
  ret.m20 = xz * c - axis.y * s;
  ret.m12 = yz * c - axis.x * s;
  ret.m21 = yz * c + axis.x * s;
  
  return ret;
}
