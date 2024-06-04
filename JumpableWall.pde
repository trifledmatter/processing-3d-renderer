class JumpableWall extends Wall {
  boolean playerGrounded = false;
  float groundedTime = 0;
  boolean jumpAvailable = false;
  
  JumpableWall(float x, float y, float z, float w, float h, float d, int c) {
    super(x, y, z, w, h, d, c);
  }

  @Override
  void display() {
    super.display();
  }
  
  void update_grounding(float playerX, float playerY, float playerZ, float playerSizeH) {
    // -- the detection range was inside of the rectangle, so i have an offset here to extend it out of the rectangle
    float detectionOffset = 20;

    if (playerX > x - w / 2 - detectionOffset && playerX < x + w / 2 + detectionOffset &&
        playerZ > z - d / 2 - detectionOffset && playerZ < z + d / 2 + detectionOffset &&
        playerY + playerSizeH / 2 > y - h / 2 && playerY - playerSizeH / 2 < y + h / 2) {
          
      if (!playerGrounded) { // if player isn't already grounded or on ground, permit them a double jump.
        playerGrounded = true;
        groundedTime = millis();
        jumpAvailable = true;
      }
      
    } else { // else deny them the double jump
      playerGrounded = false;
      jumpAvailable = false;
    }
}

  
  boolean is_jump_available() {
    if (playerGrounded && millis() - groundedTime < 1000) {
      return true;
    }
    return false;
  }
}
