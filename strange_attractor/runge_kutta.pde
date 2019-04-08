/**
 * author: ぐにゃ (https://twitter.com/gnya_a)
 * date:   2019 04 08
 */
 
class RungeKuttaThread implements Runnable {
  Equation e;
  float h;
  int n;
  List<PVector> pos;
  List<PVector> hsb;
  boolean is_running;
  
  RungeKuttaThread(Equation e, float h, int n, PVector x) {
    this.e = e;
    this.h = h;
    this.n = n;
    pos = new ArrayList<PVector>(n + 1);
    hsb = new ArrayList<PVector>(n + 1);
    pos.add(x);
    is_running =false;
  }
  
  @Override
  synchronized void run() {
    is_running = true;
    
    // RungeKutta iteration
    PVector x = pos.get(0).copy();
    PVector k_a, k_b, k_c, k_d;
    PVector x_a, x_b, x_c, x_d;
    float t = 0.0;
  
    for (int i = 0; i < n; i++) {
      x_a = x;
      k_a = e.f(t        , x_a).mult(h);
      x_b = PVector.div(k_a, 2).add(x);
      k_b = e.f(t + h / 2, x_b).mult(h);
      x_c = PVector.div(k_b, 2).add(x);
      k_c = e.f(t + h / 2, x_c).mult(h);
      x_d = PVector.add(x, k_c);
      k_d = e.f(t + h    , x_d).mult(h);
  
      x.add(k_a.add(k_b.add(k_c).mult(2)).add(k_d).div(6));
      t += h;
      pos.add(x.copy());
    }
    
    // centering
    PVector center = new PVector();
  
    for (PVector v : pos) center.add(v);
  
    center.div(n + 1);
  
    for (int i = 0; i < n + 1; i++) {
      pos.get(i).sub(center).mult(e.scale());
    }
    
    // color
    for (int i = 0; i < n + 1; i++) {
      float l = sqrt(i / float(n));
      PVector c = new PVector();
      
      c.x = 30  + 150 * sqrt(l);
      c.y = 10  + 150 * l;
      c.z = 250 - 75  * l;
      
      // cliping
      c.x %= 360;
      if (c.x < 0  ) c.x = (360 + c.x) % 360;
      if (c.y > 255) c.y = 255;
      if (c.z < 0  ) c.z = 0;
      
      hsb.add(c);
    }
    
    is_running = false;
  }
}
