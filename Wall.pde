class Wall {
  float x, y, z;
  float w, h, d;
  int c;
  
  Wall(float x, float y, float z, float w, float h, float d, int c) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;
    this.h = h;
    this.d = d;
    this.c = c;
  }
  
  void display() {
    pushMatrix();
    translate(x, y, z);
    fill(c);
    box(w, h, d);
    popMatrix();
  }
}
