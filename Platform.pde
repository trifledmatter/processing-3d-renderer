class Platform {
  float x, y, z; // -- coords
  float w, h, d; // -- dimensions (width, height, depth)
  
  int r, g, b; // -- colors
  
  boolean interacted_with_platform = false;
  
  Platform (
  
    float x,
    float y,
    float z,
    
    float w,
    float h,
    float d,
    
    int r, // <-- opt
    int g, // <-- opt
    int b // <-- opt

  ) {
  
    this.x = x;
    this.y = y;
    this.z = z;
    
    this.w = w;
    this.h = h;
    this.d = d;
    
    this.r = r;
    this.g = g;
    this.b = b;
  
  }
  
  /*
  * dn: in the event where we don't have an rgb value to provide, default to fill(100)
  */
  Platform (
  
    float x,
    float y,
    float z,
    
    float w,
    float h,
    float d
    
  ) {
  
    this.x = x;
    this.y = y;
    this.z = z;
    
    this.w = w;
    this.h = h;
    this.d = d;
    
    this.r = (int) Math.floor(random(255));
    this.g = (int) Math.floor(random(255));
    this.b = (int) Math.floor(random(255));
  
  }
  
  void display () {
    pushMatrix();
    translate(x, y, z);
    fill(r, g, b);
    box(w, h, d);
    popMatrix();
  }
}
