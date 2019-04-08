/**
 * author: ぐにゃ (https://twitter.com/gnya_a)
 * date:   2019 04 08
 */

// stationery of equation
interface Equation {
  PVector f(float t, PVector u);
  
  String name();
  
  String description();
  
  float scale();
}

// Lorenz system
class Lorenz implements Equation {
  float p, r, b;
  
  Lorenz(float p, float r, float b) {
    this.p = p;
    this.r = r;
    this.b = b;
  }
  
  @Override
  PVector f(float t, PVector u) {
    PVector v = new PVector();
  
    // dx/dt = - p * x + p * y
    // dy/dt = - x * z + r * x - y
    // dz/dt =   z * y - b * z
    v.x = - p * u.x   + p * u.y;
    v.y = - u.x * u.z + r * u.x - u.y;
    v.z =   u.x * u.y - b * u.z;
  
    return v;
  }
  
  @Override
  String name() {
    return "Lorenz Attractor";
  }
  
  @Override
  String description() {
    return "p = " + p + ", r = " + r + ", b = " + b;
  }
  
  @Override
  float scale() {
    return 8;
  }
}

// NoseHoover system
class NoseHoover implements Equation {
  float a;
  
  NoseHoover(float a) {
    this.a = a;
  }
  
  @Override
  PVector f(float t, PVector u) {
    PVector v = new PVector();
  
    // dx/dt =   y
    // dy/dt = - x + y * z
    // dz/dt =   a - y~2
    v.x =   u.y;
    v.y = - u.x + u.y * u.z;
    v.z =   a - pow(u.y, 2);
  
    return v;
  }
  
  @Override
  String name() {
    return "Nosé-Hoover Attractor";
  }
  
  @Override
  String description() {
    return "a = " + a;
  }
  
  @Override
  float scale() {
    return 60;
  }
}

// Halvorsen system
class Halvorsen implements Equation {
  float a;
  
  Halvorsen(float a) {
    this.a = a;
  }
  
  @Override
  PVector f(float t, PVector u) {
    PVector v = new PVector();
  
    // dx/dt = -a * x - 4 * y - 4 * z - y^2
    // dy/dt = -a * y - 4 * z - 4 * x - z^2
    // dz/dt = -a * z - 4 * x - 4 * y - x^2
    v.x = -a * u.x - 4 * u.y - 4 * u.z - pow(u.y, 2);
    v.y = -a * u.y - 4 * u.z - 4 * u.x - pow(u.z, 2);
    v.z = -a * u.z - 4 * u.x - 4 * u.y - pow(u.x, 2);
  
    return v;
  }
  
  @Override
  String name() {
    return "Halvorsen Attractor";
  }
  
  @Override
  String description() {
    return "a = " + a;
  }
  
  @Override
  float scale() {
    return 22;
  }
}
