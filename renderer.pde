import java.util.HashSet;
import java.util.Set;

import java.awt.event.KeyEvent;
import java.awt.AWTException;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.Robot;

final private boolean DEBUG_MODE = false;
final private int     DEBUG_PLAYER_COLOR_R = 255;
final private int     DEBUG_PLAYER_COLOR_G = 0;
final private int     DEBUG_PLAYER_COLOR_B = 0;

float scene_delta_time = 0;
float scene_fps = 0;

/*
* dn: to whomever is reading this, you'll see _IMMU or _IMMU_C associated with finals in this project.
*     IMMU is shorthand for immutable, which means unchanging (if you aren't mr. pope reading this)
*     C    is shorthand for const, or constant. I'm indicating the value is constant, even though i'm already saying its immutable.
*/
// -- 1280 x 720 (720p res) 
final private int _IMMU_C_WINDOW_H = 720;
final private int _IMMU_C_WINDOW_W = 1280;

final private float _IMMU_PLAYER_RENDER_DISTANCE_NEAREST = 0.01;
final private float _IMMU_PLAYER_RENDER_DISTANCE_FARTHEST = 1500;

/*
*  dn - player config
*/

int __PLAYER_SCORE = 0;

float __player_loc_x;
float __player_loc_y;
float __player_loc_z;

int __player_coordinates_x = -500;
int __player_coordinates_y = 1;
int __player_coordinates_z = 0;

final private float _IMMU_PLAYER_SPEED = 0.7;
final private float _IMMU_PLAYER_SPRINT_SPEED = 2;
  
float __player_velocity_y = 0;
float __player_speed = 0.7;
float __player_sprint_speed = 7;

float __player_size_h = 50;

boolean __player_on_ground = false;

final private float _IMMU_PLAYER_FOV = 1.5;
final private float _IMMU_PLAYER_SPRINT_FOV = 2;

PVector __player_camera_position;
PVector __player_camera_looking_at;
float   __player_camera_fov = 1;
float   __player_camera_fov_while_sprinting = 1.5;
float   __player_camera_sensitivity = 0.1;

/*
*  dn - config
*/

final private char _IMMU_C_KEY_FORWARDS = 'w';
final private char _IMMU_C_KEY_BACKWARDS = 's';
final private char _IMMU_C_KEY_LEFT = 'a';
final private char _IMMU_C_KEY_RIGHT = 'd';

final private char _IMMU_C_KEY_JUMP = ' ';
final private char _IMMU_C_KEY_SPRINT = 'r'; // -- TODO: replace with shift

final int __scene_background_r = 135;
final int __scene_background_g = 206;
final int __scene_background_b = 235;

final int __scene_floor_r = 28;
final int __scene_floor_g = 28;
final int __scene_floor_b = 28;

final int __scene_wall_height = 5000;
final int __scene_wall_size = 100;

float __scene_gravity = 0.06;
ArrayList<Platform> __scene_platforms;
ArrayList<Wall> __scene_walls;

Robot __IMMU_C_WINDOW_MANAGER;
Set<Character> __KEY_BUFFER = new HashSet<Character>();

void setup () {
  size(_IMMU_C_WINDOW_W, _IMMU_C_WINDOW_H, P3D); // -- p3d is required for a 3d context, even though i'm doing most of the heavy lifting in the code
  
  __player_loc_x = width / 2 + __player_coordinates_x;
  __player_loc_y = height / 2 + __player_coordinates_y;
  __player_loc_z = 0 + __player_coordinates_z;
  
  __player_camera_position = new PVector(__player_loc_x, __player_loc_y, __player_loc_z);
  __player_camera_looking_at = new PVector(0, 0, 0);
  
  __scene_platforms = new ArrayList<Platform>();
  __scene_platforms.add( new Platform(-100, 300, height / 2 + 50, __scene_wall_size, 20, __scene_wall_size) ); // dn: (1) [x, y, z] :: coordinates -> (2) [w, h, d] :: dimensions
  __scene_platforms.add( new Platform(-400, 200, height / 2 + -150, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(-200, 50, height / 2 + -300, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(-200, 0, height / 2 + -725, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(0, -100, height / 2 + -750, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(200, -300, height / 2 + -500, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(400, -500, height / 2 + -500, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(400, -600, height / 2 + -600, __scene_wall_size, 20, __scene_wall_size) );

  __scene_walls = new ArrayList<Wall>();
  __scene_walls.add( new Wall(0, height / 2 - 100, 500, 1000, __scene_wall_height, 20, 150)  ); // x y z w h d
  __scene_walls.add( new Wall(0, height / 2 - 100, -500, 1000, __scene_wall_height, 20, 100)  ); // x y z w h d'
  
  __scene_walls.add( new Wall(500, height / 2 - 100, 0, 20, __scene_wall_height, 1000, 200)  ); // x y z w h d
  __scene_walls.add( new Wall(-500, height / 2 - 100, 0, 20, __scene_wall_height, 1000, 255)  ); // x y z w h d

  try { __IMMU_C_WINDOW_MANAGER = new Robot(); } catch (AWTException e) { e.printStackTrace(); }
  
  noCursor();
  perspective(__player_camera_fov, float(width) / float(height), _IMMU_PLAYER_RENDER_DISTANCE_NEAREST, _IMMU_PLAYER_RENDER_DISTANCE_FARTHEST);
}

void reapply_perspective () { perspective(__player_camera_fov, float(width) / float(height), _IMMU_PLAYER_RENDER_DISTANCE_NEAREST, _IMMU_PLAYER_RENDER_DISTANCE_FARTHEST); }

void draw () {
  background(__scene_background_r, __scene_background_g, __scene_background_b);
  
  // TODO: player stuff here
  handlePlayerMovement();
  applyGravity();
  movePlayer();
  updateCamera();
  
  lights();
  renderScene();
  
  // scores
  System.out.println(__PLAYER_SCORE);
  
  if (DEBUG_MODE) {
    renderPlayerWithScene();
  }
}

void mouseMoved() {
  Point __mouse_location = MouseInfo.getPointerInfo().getLocation();
  
  int mouseX = __mouse_location.x - (displayWidth - width) / 2;
  int mouseY = __mouse_location.y - (displayHeight - height) / 2;

  __player_camera_looking_at.y += (mouseX - width / 2) * __player_camera_sensitivity;
  __player_camera_looking_at.x += (mouseY - height / 2) * __player_camera_sensitivity;
  __player_camera_looking_at.x = constrain(__player_camera_looking_at.x, -75, 75); // -- dn: was 90 deg but reduced to fix issue with camera clipping through scene objects

  __IMMU_C_WINDOW_MANAGER.mouseMove((displayWidth - width) / 2 + width / 2, (displayHeight - height) / 2 + height / 2); // dn: ensuring the mouse is always in the middle of the screen
}

void keyPressed() { __KEY_BUFFER.add(key); }
void keyReleased() { __KEY_BUFFER.remove(key); }

void renderPlayerWithScene () {
  pushMatrix();
  translate(__player_loc_x, __player_loc_y, __player_loc_z);
  fill(DEBUG_PLAYER_COLOR_R, DEBUG_PLAYER_COLOR_G, DEBUG_PLAYER_COLOR_B);
  box(20, __player_size_h, 20);
  popMatrix();
}

void applyGravity() {
  if (!__player_on_ground) {
    __player_velocity_y += __scene_gravity;
  }
}

void renderScene () {
   // -- floor
     
   pushMatrix();
   translate(0, height / 2 + 100, 0);
   fill(__scene_floor_r, __scene_floor_g, __scene_floor_b);
   box(1000, 20, 1000);
   popMatrix();
   
   // -- platforms
   for (Platform p : __scene_platforms) {
    p.display();
  }
  
  // -- walls
  for (Wall w : __scene_walls) {
    w.display();
  }
}

void handlePlayerMovement () {
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_FORWARDS)) {
    __player_loc_x += sin(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z -= cos(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_BACKWARDS)) {
    __player_loc_x -= sin(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z += cos(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_RIGHT)) {
    __player_loc_x += cos(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z += sin(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_LEFT)) {
    __player_loc_x -= cos(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z -= sin(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_SPRINT)) {
    //key == _IMMU_C_KEY_SPRINT
    __player_speed = _IMMU_PLAYER_SPRINT_SPEED;
    __player_camera_fov = _IMMU_PLAYER_SPRINT_FOV;
    reapply_perspective();
    
  } else {
    __player_speed = _IMMU_PLAYER_SPEED;
    __player_camera_fov = _IMMU_PLAYER_FOV;
    reapply_perspective();
  }
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_JUMP)) {
    if (__player_on_ground) {
      __player_velocity_y = -5;
      __player_on_ground = false;
    }
  }
}

void movePlayer() {
  __player_loc_y += __player_velocity_y;

  /*
  * dn: floor collision detection (hacky, doesn't let player clip past y = 0)
  */
  if (__player_loc_y + __player_size_h / 2 > height / 2 + 100) {
    __player_loc_y = height / 2 + 100 - __player_size_h / 2;
    __player_on_ground = true;
    __player_velocity_y = 0;
  } else {
    __player_on_ground = false;
  }

  /*
  * dn: platform collision detection
  */
  for (Platform p : __scene_platforms) {
    boolean __already_updated_score = false;
    
    if (__player_loc_x > p.x - p.w / 2 && __player_loc_x < p.x + p.w / 2 &&
        __player_loc_z > p.z - p.d / 2 && __player_loc_z < p.z + p.d / 2 &&
        __player_loc_y + __player_size_h / 2 > p.y - p.h / 2 &&
        __player_loc_y - __player_size_h / 2 < p.y + p.h / 2) {
      
      __player_loc_y = p.y - p.h / 2 - __player_size_h / 2;
      __player_on_ground = true;
      __player_velocity_y = 0;
      
      p.interacted_with_platform = true;
      
      // -- update platform color
      p.r = 0;
      p.g = 255;
      p.b = 0;
    }
    
    // -- score updating

    if (p.interacted_with_platform) {
        if (!__already_updated_score) {
          __PLAYER_SCORE += 1;
        }
        p.interacted_with_platform = false;
        __already_updated_score = true;

      }
  }
  
  /*
  * dn: wall collision
  */
  for (Wall w : __scene_walls) {
    if (__player_loc_x + 10 > w.x - w.w / 2 && __player_loc_x - 10 < w.x + w.w / 2 &&
        __player_loc_y + __player_size_h / 2 > w.y - w.h / 2 && __player_loc_y - __player_size_h / 2 < w.y + w.h / 2 &&
        __player_loc_z + 10 > w.z - w.d / 2 && __player_loc_z - 10 < w.z + w.d / 2) {

      float dx = min(abs(__player_loc_x + 10 - (w.x - w.w / 2)), abs(__player_loc_x - 10 - (w.x + w.w / 2)));
      float dy = min(abs(__player_loc_y + __player_size_h / 2 - (w.y - w.h / 2)), abs(__player_loc_y - __player_size_h / 2 - (w.y + w.h / 2)));
      float dz = min(abs(__player_loc_z + 10 - (w.z - w.d / 2)), abs(__player_loc_z - 10 - (w.z + w.d / 2)));

      if (dx < dy && dx < dz) {
        if (__player_loc_x < w.x) {
          __player_loc_x = w.x - w.w / 2 - 10;
        } else {
          __player_loc_x = w.x + w.w / 2 + 10;
        }
      } else if (dy < dx && dy < dz) {
        if (__player_loc_y < w.y) {
          __player_loc_y = w.y - w.h / 2 - __player_size_h / 2;
        } else {
          __player_loc_y = w.y + w.h / 2 + __player_size_h / 2;
        }
      } else {
        if (__player_loc_z < w.z) {
          __player_loc_z = w.z - w.d / 2 - 10;
        } else {
          __player_loc_z = w.z + w.d / 2 + 10;
        }
      }
    }
  }
}

void updateCamera() {
  __player_camera_position.x = __player_loc_x;
  __player_camera_position.y = __player_loc_y - __player_size_h / 2;
  __player_camera_position.z = __player_loc_z;

  camera(__player_camera_position.x, __player_camera_position.y, __player_camera_position.z, 
         __player_camera_position.x + cos(radians(__player_camera_looking_at.x)) * sin(radians(__player_camera_looking_at.y)), 
         __player_camera_position.y + sin(radians(__player_camera_looking_at.x)), 
         __player_camera_position.z - cos(radians(__player_camera_looking_at.x)) * cos(radians(__player_camera_looking_at.y)), 
         0, 1, 0);
}
