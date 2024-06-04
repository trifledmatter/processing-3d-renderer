/*
* Ethan Pelletier
* Processing Assignemnt - Computer Science 120
* Mr. Pope
* May 27th, 2024
*/

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

// dn: set the player's render distance to save frames
final private float _IMMU_PLAYER_RENDER_DISTANCE_NEAREST = 0.01;
final private float _IMMU_PLAYER_RENDER_DISTANCE_FARTHEST = 1500;

/*
*  dn - player config
*/

int __player_score = 0; // keep track of how many platforms the player achieved

// -- player's location in the world
float __player_loc_x;
float __player_loc_y;
float __player_loc_z;

// -- saving player's spawn coordinates
int __player_coordinates_x = -500;
int __player_coordinates_y = 1;
int __player_coordinates_z = 0;

// -- constants for speed and movement
private float _IMMU_PLAYER_SPEED = 3.50;
private float _IMMU_PLAYER_SPRINT_SPEED = 5;
  
float __player_velocity_y = 0;
float __player_speed = 3.50;
float __player_sprint_speed = 5;

float __player_size_h = 50;

// dn: floor collision detection
boolean __player_on_ground = false;

// dn: fov wizardry
final private float _IMMU_PLAYER_FOV = 1.5;
final private float _IMMU_PLAYER_SPRINT_FOV = 2.50;
final private float _IMMU_PLAYER_WALK_FOV = 1.75;

final private float _IMMU_FOV_TRANSITION_SPEED = 0.08;

/*
* I say "player_camera" here, but both words refer to the same thing, in case that causes confusion.
* there is no player entity / model, you're just navigating a camera with physics.
*/
PVector __player_camera_position;
PVector __player_camera_looking_at;
float   __player_camera_fov = 1;
float   __player_camera_fov_while_sprinting = _IMMU_PLAYER_SPRINT_FOV;
float   __player_camera_sensitivity = 0.2;

float   __player_target_fov = _IMMU_PLAYER_FOV;
float   __player_current_fov = _IMMU_PLAYER_FOV;


boolean __player_finished = false; // keep track if they finished the map or not

/*
*  dn - config
*  the objective here is to have an easy place to keep all movement & scene configurations
*/

final private char _IMMU_C_KEY_FORWARDS = 'w';
final private char _IMMU_C_KEY_BACKWARDS = 's';
final private char _IMMU_C_KEY_LEFT = 'a';
final private char _IMMU_C_KEY_RIGHT = 'd';

final private char _IMMU_C_KEY_JUMP = ' ';
final private char _IMMU_C_KEY_SPRINT = 'r'; // -- TODO: replace with shift

final private char _IMMU_C_KEY_INC_PLAYER_SPEED = 'j'; // increase player speed key
final private char _IMMU_C_KEY_DEC_PLAYER_SPEED = 'k'; // decrease player speed key

final private char _IMMU_C_KEY_PLAYER_SNEAK = 'c'; // shifting

boolean __has_popup = false; // keep track of whether or now we're showing a popup
final private char _IMMU_C_KEY_ACKNOWLEDGE_DONE = '.';

final int __scene_background_r = 135; // sky blue
final int __scene_background_g = 206; // sky blue
final int __scene_background_b = 235; // sky blue

int __scene_floor_r = 28; // charcoal
int __scene_floor_g = 28; // charcoal
int __scene_floor_b = 28; // charcoal

// -- so that the player doesn't escape the map
final int __scene_wall_height = 5000;
final int __scene_wall_size = 100;

float __scene_gravity = (9.6 / 60) / 2.90; // gravity applied to player at deltatime / scene draw

// -- store platforms in memory, and keep track of platforms the player interacted with 
ArrayList<Platform> __scene_platforms;
Set<Platform> __intersected_scene_platforms = new HashSet<>();


// -- store walls in memory too
ArrayList<Wall> __scene_walls;
ArrayList<JumpableWall> __scene_jumpable_walls;

// -- the Robot here is supposed to keep the cursor centered in the middle of the screen
Robot __IMMU_C_WINDOW_MANAGER;
Set<Character> __KEY_BUFFER = new HashSet<Character>();

// -- in case of player falling to ground, reset score.
boolean __floors_cause_death = false;

// -- for smooth transitioning of fov, use this to transition the values
float fov_lerp(float start, float stop, float amt) {
  return start + amt * (stop - start);
}

void setup () {
  size(_IMMU_C_WINDOW_W, _IMMU_C_WINDOW_H, P3D); // -- p3d is required for a 3d context, even though i'm doing most of the heavy lifting in the code
  
  // -- initialize the scene with player / camera in proper location
  __player_loc_x = width / 2 + __player_coordinates_x;
  __player_loc_y = height / 2 + __player_coordinates_y;
  __player_loc_z = 0 + __player_coordinates_z;
  
  
  // -- need this here to keep track of looking direction so that I can render all objects into view
  __player_camera_position = new PVector(__player_loc_x, __player_loc_y, __player_loc_z);
  __player_camera_looking_at = new PVector(0, 0, 0);
  
  // -- fov wizardry
  __player_current_fov = _IMMU_PLAYER_FOV;
  __player_target_fov = _IMMU_PLAYER_FOV;
  
  // -- this is where I set up all of the platforms in the scene
  __scene_platforms = new ArrayList<Platform>();
  __scene_platforms.add( new Platform(-100, 300, height / 2 + 50, __scene_wall_size, 20, __scene_wall_size) ); // dn: (1) [x, y, z] :: coordinates -> (2) [w, h, d] :: dimensions
  __scene_platforms.add( new Platform(-400, 200, height / 2 + -150, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(-200, 50, height / 2 + -300, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(-200, 0, height / 2 + -725, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(0, -100, height / 2 + -750, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(200, -300, height / 2 + -500, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(400, -500, height / 2 + -500, __scene_wall_size, 20, __scene_wall_size) );
  __scene_platforms.add( new Platform(400, -600, height / 2 + -600, __scene_wall_size, 20, __scene_wall_size) );
    
  __scene_platforms.add( new Platform(0, -1200, height / 2 + -600, __scene_wall_size, 20, __scene_wall_size) );
    
    
  // -- and the walls, too.
  __scene_walls = new ArrayList<Wall>();
  __scene_walls.add( new Wall(0, height / 2 - 100, 500, 1000, __scene_wall_height, 20, 150)  ); // x y z w h d
  __scene_walls.add( new Wall(0, height / 2 - 100, -500, 1000, __scene_wall_height, 20, 150)  ); // x y z w h d'
  
  __scene_walls.add( new Wall(500, height / 2 - 100, 0, 20, __scene_wall_height, 1000, 80)  ); // x y z w h d
  __scene_walls.add( new Wall(-500, height / 2 - 100, 0, 20, __scene_wall_height, 1000, 80)  ); // x y z w h d
  
  
  // -- jumpable walls
  __scene_jumpable_walls = new ArrayList<JumpableWall>();
  __scene_jumpable_walls.add(new JumpableWall(500, -1000, height / 2 + -850, __scene_wall_size, 20 + 1000, __scene_wall_size, color(random(255), random(255), random(255))));

  // -- if the "robot" fails, that's fine, the mouse just won't get centered, I'm catching this error in case it doesn't work on MacOS.
  try { __IMMU_C_WINDOW_MANAGER = new Robot(); } catch (AWTException e) { e.printStackTrace(); }
  
  noCursor(); // hide the cursor
  perspective(__player_camera_fov, float(width) / float(height), _IMMU_PLAYER_RENDER_DISTANCE_NEAREST, _IMMU_PLAYER_RENDER_DISTANCE_FARTHEST); // foreshortening applications to make distant objects appear smaller and give the illusion of 3d.
}

void reapply_perspective () { perspective(__player_current_fov, float(width) / float(height), _IMMU_PLAYER_RENDER_DISTANCE_NEAREST, _IMMU_PLAYER_RENDER_DISTANCE_FARTHEST); } // -- utility to adjust the "fov" or perspective of the player


/*
* dn: this looks redundant but is important, instead of directly changing fov instantly, this will be used to smoothly transition the fov into it's new state
*/
void updateFOV() {
  __player_current_fov = fov_lerp(__player_current_fov, __player_target_fov, _IMMU_FOV_TRANSITION_SPEED);
  reapply_perspective();
}


/*
* dn: the draw function here serves as a guide-method of the scene's delta time,
*     in this environment, draw primarily controls player movement & the camera position, but of course renders the scene again.
*/
void draw () {
  background(__scene_background_r, __scene_background_g, __scene_background_b); // skybox
  lights();
  
  handlePlayerMovement(); // -- adjust coordinates based on input
  
  applyGravity(); // -- constantly apply gravity to the player if they aren't grounded (grounded checks are in the gravity function)
  
  movePlayer(); // -- adjust the player position based on updated coordinates
  
  updateCamera(); // -- make the camera follow the player, also accounts for camera movement
  
  updateFOV(); // -- ensure to update the fov in case of change
  
  renderScene(); // -- render all objects to scene
  
  if (DEBUG_MODE) {
    renderPlayerWithScene();
  }
}


// -- when the mouse moves, keep track of its positioning, adjust camera values against the sensitivity modifier, and center the cursor in the middle of the window again
void mouseMoved(MouseEvent e) {
  Point __mouse_location = MouseInfo.getPointerInfo().getLocation();
  
  int mouseX = __mouse_location.x - (displayWidth - width) / 2;
  int mouseY = __mouse_location.y - (displayHeight - height) / 2;

  __player_camera_looking_at.y += (mouseX - width / 2) * __player_camera_sensitivity;
  __player_camera_looking_at.x += (mouseY - height / 2) * __player_camera_sensitivity;
  __player_camera_looking_at.x = constrain(__player_camera_looking_at.x, -75, 75); // -- dn: was 90 deg but reduced to fix issue with camera clipping through scene objects

  __IMMU_C_WINDOW_MANAGER.mouseMove((displayWidth - width) / 2 + width / 2, (displayHeight - height) / 2 + height / 2); // dn: ensuring the mouse is always in the middle of the screen
}

// -- removal of buffer creates "blocking" movements, which means
//    without the buffer, you could not jump and move forward for example
//    basically this is a very minimal implementation of asynchronous input handling

void keyPressed() { __KEY_BUFFER.add(key); }
void keyReleased() { __KEY_BUFFER.remove(key); }

// -- DEBUG ONLY, renders what the player might look like in the scene
void renderPlayerWithScene () {
  pushMatrix();
  translate(__player_loc_x, __player_loc_y, __player_loc_z);
  fill(DEBUG_PLAYER_COLOR_R, DEBUG_PLAYER_COLOR_G, DEBUG_PLAYER_COLOR_B);
  box(20, __player_size_h, 20);
  popMatrix();
}

// if the player isn't on ground, apply gravity to it.
void applyGravity() {
  if (!__player_on_ground) {
    __player_velocity_y += __scene_gravity;
  }
}

// for each platform and wall in the scene, render it.
void renderScene () {
   // -- floor
     
   pushMatrix();
   translate(0, height / 2 + 100, 0);
   fill(__scene_floor_r, __scene_floor_g, __scene_floor_b);
   box(1000, 20, 1000); // create a 1000 x 1000 floor to stand on
   popMatrix();
   
   
   
  
   // -- walls
   for (Wall w : __scene_walls) { // for each wall in the __scene_wall array
     w.display();
   }
   
   // -- jumpable walls
   for (JumpableWall jw : __scene_jumpable_walls) {
    jw.display();
    jw.update_grounding(__player_loc_x, __player_loc_y, __player_loc_z, __player_size_h);
    if (jw.is_jump_available()) {
      __player_on_ground = true;
    }
  }
  
    

   // BUG: text is visible through walls because it is rendered on top of it; the player shouldn't notice though
   hint(DISABLE_DEPTH_TEST);
   
   fill(255); // Set text color to white
   textAlign(TOP, LEFT); // Set text alignment to center
   textSize(16);
   rotate(0); 
   
   fill(255, 0, 0);
   text("HOW TO PLAY:", 0, __player_loc_y - 135, -100);
   
   fill(255);
   text("Jump on all the platforms!", 0, __player_loc_y - 100, -100);
   text("Turn all platforms green to win!", 0, __player_loc_y - 75, -100);
   
   fill(0, 255, 0);

   text("Your current score: " + __player_score, 0, __player_loc_y - 50, -100);
   
   fill(255, 0, 0);
   
   // -- control hints
   text("CONTROLS: ", 0, 425, -100);
   
   fill(255);
   text("[w] = forward, [s] = backward, [a] = left, [d] = right", 0, 450, -100);
   text("[space] = jump, [r] = run, [j] = increase player speed, [k] = decrease player speed", 0, 475, -100);
   text("[.] = reset your score", 0, 500, -100);
   
   fill(255, 0, 0);
   text("[ ! JUMPING UNDER PLATFORMS WILL LAUNCH YOU ! ]", 0, 525, -100);
   
   // -- by this time __player_finished is true
   if (__intersected_scene_platforms.size() >= 1 && !__player_finished) {
     __floors_cause_death = true;
     __scene_floor_r = 255;
     __scene_floor_g = 0;
     __scene_floor_b = 0;
   } else {
     __floors_cause_death = false;
     __scene_floor_r = 28;
     __scene_floor_g = 28;
     __scene_floor_b = 28;
   }
   
   
   
   //if (__intersected_scene_platforms.size() >= 1) {
   //    __has_popup = true;
   //}
   
   
   if (__intersected_scene_platforms.size() == __scene_platforms.size()) {
     // -- player completed all platforms, they are safe
      //__has_popup = true;

     __floors_cause_death = false;
     __player_finished = true;
     
     __scene_floor_r = 28;
     __scene_floor_g = 28;
     __scene_floor_b = 28;
     __intersected_scene_platforms.clear();
   }
   
   //if (__has_popup) {
   //  fill(255, 0, 0);
   //  text("Press [" + _IMMU_C_KEY_ACKNOWLEDGE_POPUP + "] to restart!", 0, 500, -100);
   //}
   
   hint(ENABLE_DEPTH_TEST);
   
   // -- platforms
   // for each (iterable) in (array or stream)
   for (Platform p : __scene_platforms) { // for each platform in the __scene_platforms array
     p.display();
   }
}

void handlePlayerMovement () {
  
  // -- acknowledge any pop ups
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_ACKNOWLEDGE_DONE)) {
      __player_finished = true;
      __player_score = 0;
      __intersected_scene_platforms.clear();
  }

  // -- decrease player speed and height
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_PLAYER_SNEAK)) {
    __player_speed -= 0.5;
    __player_target_fov = _IMMU_PLAYER_FOV - 0.6;
    updateFOV();
  }
  
  // -- increase player speed
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_INC_PLAYER_SPEED)) {
    if ((_IMMU_PLAYER_SPEED <= 10) && 
        (__player_speed <= 10)) {
          
      // global
      _IMMU_PLAYER_SPEED += 1;
      _IMMU_PLAYER_SPRINT_SPEED += 1;
      
      // local
      __player_speed += 1;
      __player_sprint_speed += 3;
      
      System.out.println("[!] Increased player speed! -> " + _IMMU_PLAYER_SPEED);
    }
  }
  
  // -- decrease player speed
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_DEC_PLAYER_SPEED)) {
    if ((_IMMU_PLAYER_SPEED < 12 && _IMMU_PLAYER_SPEED >= 1) && 
        (__player_speed < 12 && __player_speed >= 1)) {
          
      // global
      _IMMU_PLAYER_SPEED -= 1;
      _IMMU_PLAYER_SPRINT_SPEED -= 1;
      
      // local
      __player_speed -= 1;
      __player_sprint_speed -= 3;
      
      System.out.println("[!] Decreased player speed! -> " + _IMMU_PLAYER_SPEED);
    }
  }
  
  // -- moving forward increases the value of the player's x coordinate and decreases the z coordinate.
  //    which moves the player towards the camera's looking direction.
  //    use of sin because it represents the y component of the camera facing direction vector rotated by the camera's pitch angle
  //    btw the rotation will account for the player's orientation relative to the world's x, y, and z axes.
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_FORWARDS)) {
    __player_loc_x += sin(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z -= cos(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  
  // -- inverse logic for backwards. decreases x value and increases z value.
  //    moves the player away from the camera's looking direction
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_BACKWARDS)) {
    __player_loc_x -= sin(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z += cos(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  
  // -- moving right should increase both x and z coordinates which causes the camera and by extension the player to move parallel to the ground plane relative to the camera's looking direction
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_RIGHT)) {
    __player_loc_x += cos(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z += sin(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  
  // -- inverse logic for left movement
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_LEFT)) {
    __player_loc_x -= cos(radians(__player_camera_looking_at.y)) * __player_speed;
    __player_loc_z -= sin(radians(__player_camera_looking_at.y)) * __player_speed;
  }
  
  // -- adjust the player's speed and field of view based on sprinting or regulat movement
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_SPRINT)) {
    __player_speed = _IMMU_PLAYER_SPRINT_SPEED;
    __player_target_fov = _IMMU_PLAYER_SPRINT_FOV; // because the player is sprinting, the fov's value should be adjusted for a more narrow perspective against normal walking fov.
  } 
  else if (__KEY_BUFFER.contains(_IMMU_C_KEY_FORWARDS) || 
             __KEY_BUFFER.contains(_IMMU_C_KEY_BACKWARDS) ||
             __KEY_BUFFER.contains(_IMMU_C_KEY_LEFT) || 
             __KEY_BUFFER.contains(_IMMU_C_KEY_RIGHT)) {
    __player_speed = _IMMU_PLAYER_SPEED;
    __player_target_fov = _IMMU_PLAYER_WALK_FOV; // fov value isn't increased as much but will give the illusion of movement, also, it's pretty satisfying to see fov change based on movement
  } 
  else {
    // dn: no movement so let's reset the player fov back to normal
    __player_speed = _IMMU_PLAYER_SPEED;
    __player_target_fov = _IMMU_PLAYER_FOV;
  }
  
  // -- hacky but effective jumping logic, where the y is offset by -5 when jumping.
  if (__KEY_BUFFER.contains(_IMMU_C_KEY_JUMP)) {
    for (JumpableWall jw : __scene_jumpable_walls) {
      if (jw.is_jump_available()) {
        __player_velocity_y = -8;
        __player_on_ground = false;
        jw.jumpAvailable = false;
      }
    }
    if (__player_on_ground) {
      __player_velocity_y = -5;
      __player_on_ground = false; // reapply physics as the player isn't touching anything
    }
  }
  
  __player_speed = _IMMU_PLAYER_SPEED;
}


void movePlayer() {
  __player_loc_y += __player_velocity_y;

  /*
  * dn: floor collision detection (hacky, doesn't let player clip past y = 0)
  *
  * check if the bottom half of the player is above floor level (with 100 being an offset added to the floor level so the player doesn't clip through it)
  * if player position is seen to be colliding with the floor, their y location is adjusted so the player is "aligned" with the floor level
  * then set their velocity to 0 to indicate that the player stopped moving vertically
  */
  if (__player_loc_y + __player_size_h / 2 > height / 2 + 100) {
    __player_loc_y = height / 2 + 100 - __player_size_h / 2;
    __player_on_ground = true;
    __player_velocity_y = 0;
    __has_popup = true;
    
    if (__floors_cause_death) {
      // reset score
      __floors_cause_death = false;
      __has_popup = false;
      __intersected_scene_platforms.clear();
      __player_score = 0;
    }
  } else {
    __player_on_ground = false;
  }

  /*
  * dn: platform collision detection
  */
  for (Platform p : __scene_platforms) {
    if (__player_loc_x > p.x - p.w / 2 && __player_loc_x < p.x + p.w / 2 && // -- player's x coordinate falls within platform width bounds
        __player_loc_z > p.z - p.d / 2 && __player_loc_z < p.z + p.d / 2 && // -- player z coordinate falls within platform depth bounds
        __player_loc_y + __player_size_h / 2 > p.y - p.h / 2 && // -- player y coordinate (+ player height / 2 ) is above platform height
        __player_loc_y - __player_size_h / 2 < p.y + p.h / 2) { // -- player y coordinate (- player height / 2 ) is below platform height
      
      __player_loc_y = p.y - p.h / 2 - __player_size_h / 2;
      __player_on_ground = true; // player collided with platform and mark the player as grounded
      __player_velocity_y = 0; // reset player y velocity
      
      
      // dn: just in case the player couldn't claim a point from the platform, increment the player's points
      if (!__intersected_scene_platforms.contains(p)) {
        __player_score++;
        __intersected_scene_platforms.add(p);
      }
      
      // -- update platform color to show that it was touched
      if (!__player_finished) {
        p.r = 0;
        p.g = 255;
        p.b = 0;
      }
    }
   
  }
  
  /*
  * dn: wall collision
  */
  for (Wall w : __scene_walls) {
    // -- collision calculations
    if (__player_loc_x + 10 > w.x - w.w / 2 && __player_loc_x - 10 < w.x + w.w / 2 && // x coordinates (extended by 10px on either side) overlap with wall width bounds
        __player_loc_y + __player_size_h / 2 > w.y - w.h / 2 && __player_loc_y - __player_size_h / 2 < w.y + w.h / 2 && // y coordinates (considering player height) overlaps with wall height bounds 
        __player_loc_z + 10 > w.z - w.d / 2 && __player_loc_z - 10 < w.z + w.d / 2) { // z coordinate overlaps with wall depth bounds

      // -- calculating minimum distances from the player to the wall along each of the wall's sides (axises)
      float dx = min(abs(__player_loc_x + 10 - (w.x - w.w / 2)), abs(__player_loc_x - 10 - (w.x + w.w / 2)));
      float dy = min(abs(__player_loc_y + __player_size_h / 2 - (w.y - w.h / 2)), abs(__player_loc_y - __player_size_h / 2 - (w.y + w.h / 2)));
      float dz = min(abs(__player_loc_z + 10 - (w.z - w.d / 2)), abs(__player_loc_z - 10 - (w.z + w.d / 2)));

      // determining closes axis to the player and move the player accordingly
      if (dx < dy && dx < dz) {
        if (__player_loc_x < w.x) {
          __player_loc_x = w.x - w.w / 2 - 10; // closest to the wall along the x axis
        } else {
          __player_loc_x = w.x + w.w / 2 + 10; 
        }
      } else if (dy < dx && dy < dz) {
        if (__player_loc_y < w.y) {
          __player_loc_y = w.y - w.h / 2 - __player_size_h / 2; // closes to the wall along the y axis
        } else {
          __player_loc_y = w.y + w.h / 2 + __player_size_h / 2;
        }
      } else {
        if (__player_loc_z < w.z) {
          __player_loc_z = w.z - w.d / 2 - 10; // closes to the wall along the z axis
        } else {
          __player_loc_z = w.z + w.d / 2 + 10;
        }
      }
    }
  }
  
  
  /*
  * dn: jumpable wall logic
  */
  for (JumpableWall w : __scene_jumpable_walls) {
    
    // -- collision calculations
    if (__player_loc_x + 5 > w.x - w.w / 2 && __player_loc_x - 5 < w.x + w.w / 2 && // x coordinates (extended by 10px on either side) overlap with wall width bounds
        __player_loc_y + __player_size_h / 2 > w.y - w.h / 2 && __player_loc_y - __player_size_h / 2 < w.y + w.h / 2 && // y coordinates (considering player height) overlaps with wall height bounds 
        __player_loc_z + 5 > w.z - w.d / 2 && __player_loc_z - 5 < w.z + w.d / 2) { // z coordinate overlaps with wall depth bounds

      // -- calculating minimum distances from the player to the wall along each of the wall's sides (axises)
      float dx = min(abs(__player_loc_x + 5 - (w.x - w.w / 2)), abs(__player_loc_x - 5 - (w.x + w.w / 2)));
      float dy = min(abs(__player_loc_y + __player_size_h / 2 - (w.y - w.h / 2)), abs(__player_loc_y - __player_size_h / 2 - (w.y + w.h / 2)));
      float dz = min(abs(__player_loc_z + 5 - (w.z - w.d / 2)), abs(__player_loc_z - 5 - (w.z + w.d / 2)));

      // determining closes axis to the player and move the player accordingly
      if (dx < dy && dx < dz) {
        if (__player_loc_x < w.x) {
          __player_loc_x = w.x - w.w / 2 - 5; // closest to the wall along the x axis
        } else {
          __player_loc_x = w.x + w.w / 2 + 5; 
        }
      } else if (dy < dx && dy < dz) {
        if (__player_loc_y < w.y) {
          __player_loc_y = w.y - w.h / 2 - __player_size_h / 2; // closes to the wall along the y axis
        } else {
          __player_loc_y = w.y + w.h / 2 + __player_size_h / 2;
        }
      } else {
        if (__player_loc_z < w.z) {
          __player_loc_z = w.z - w.d / 2 - 5; // closes to the wall along the z axis
        } else {
          __player_loc_z = w.z + w.d / 2 + 5;
        }
      }
    }
      
    w.update_grounding(__player_loc_x, __player_loc_y, __player_loc_z, __player_size_h);
    if (w.is_jump_available()) {
      __player_on_ground = true;
    }
  }
}

void updateCamera() {
  // -- update camera position to match the player location
  //    (it centers the camera onto the player so that we can see from the player's perspective)
  __player_camera_position.x = __player_loc_x;
  __player_camera_position.y = __player_loc_y - __player_size_h / 2;
  __player_camera_position.z = __player_loc_z;


  // -- adjust camera orientation based on player looking direction, and the target position of the camera is calculated by rotating a vector pointing straight ahead from the camera's position
  //    so that according the player's looking direction, it creates the effect of the camera following the player's "gaze" (or just mouse movement)
  camera(__player_camera_position.x, __player_camera_position.y, __player_camera_position.z, 
         __player_camera_position.x + cos(radians(__player_camera_looking_at.x)) * sin(radians(__player_camera_looking_at.y)), 
         __player_camera_position.y + sin(radians(__player_camera_looking_at.x)), 
         __player_camera_position.z - cos(radians(__player_camera_looking_at.x)) * cos(radians(__player_camera_looking_at.y)), 
         0, 1, 0);
}
