import frames.timing.*;
import frames.primitives.*;
import frames.processing.*;

// 1. Frames' objects
Scene scene;
Frame frame;
Vector v1, v2, v3;
// timing
TimingTask spinningTask;
boolean yDirection;
// scaling is a power of 2
int n = 4;

// 2. Hints
boolean triangleHint = true;
boolean gridHint = true;
boolean debug = true;

// 3. Use FX2D, JAVA2D, P2D or P3D
String renderer = P3D;


float vX1;
float vX2;
float vX3;

float vY1;
float vY2;
float vY3;

float minX;
float maxX;
float minY;
float maxY;


void setup() {
  //use 2^n to change the dimensions
  size(1024, 1024, renderer);
  scene = new Scene(this);
  if (scene.is3D())
    scene.setType(Scene.Type.ORTHOGRAPHIC);
  scene.setRadius(width/2);
  scene.fitBallInterpolation();

  // not really needed here but create a spinning task
  // just to illustrate some frames.timing features. For
  // example, to see how 3D spinning from the horizon
  // (no bias from above nor from below) induces movement
  // on the frame instance (the one used to represent
  // onscreen pixels): upwards or backwards (or to the left
  // vs to the right)?
  // Press ' ' to play it :)
  // Press 'y' to change the spinning axes defined in the
  // world system.
  spinningTask = new TimingTask() {
    public void execute() {
      spin();
    }
  };
  scene.registerTask(spinningTask);

  frame = new Frame();
  frame.setScaling(width/pow(2, n));

  // init the triangle that's gonna be rasterized
  randomizeTriangle();
}

void draw() {
  background(0);
  stroke(0, 255, 0);
  if (gridHint)
    scene.drawGrid(scene.radius(), (int)pow( 2, n));
  if (triangleHint)
    drawTriangleHint();
  pushMatrix();
  pushStyle();
  scene.applyTransformation(frame);
  triangleRaster();
  popStyle();
  popMatrix();
}

// Implement this function to rasterize the triangle.
// Coordinates are given in the frame system which has a dimension of 2^n
void triangleRaster() {
  // frame.coordinatesOf converts from world to frame
  // here we convert v1 to illustrate the idea
  pushStyle();
  stroke(0, 255, 255, 125);
  
  minX = min(frame.coordinatesOf(v1).x(), frame.coordinatesOf(v2).x(), frame.coordinatesOf(v3).x());
  maxX = max(frame.coordinatesOf(v1).x(), frame.coordinatesOf(v2).x(), frame.coordinatesOf(v3).x());
  minY = min(frame.coordinatesOf(v1).y(), frame.coordinatesOf(v2).y(), frame.coordinatesOf(v3).y());
  maxY = max(frame.coordinatesOf(v1).y(), frame.coordinatesOf(v2).y(), frame.coordinatesOf(v3).y());
  
  pushStyle();
  noFill();
  strokeWeight(5);
  stroke(0, 255, 255); 
  
  for(float x = minX; x<= maxX; ++x){
    for(float y = minY; y<= maxY; ++y){
       if(insideOutside(v1,v3,new Vector(x,y))&&insideOutside(v1,v2,new Vector(x,y))&&insideOutside(v3,v2,new Vector(x,y)))
         point(x,y);
    }  
  }
  popStyle();

  popStyle();
   
  if (debug) {
    pushStyle();
    stroke(255, 255, 0, 125);
    point((frame.coordinatesOf(v1).x()),(frame.coordinatesOf(v1).y()));
    point((frame.coordinatesOf(v2).x()),(frame.coordinatesOf(v2).y()));
    point((frame.coordinatesOf(v3).x()),(frame.coordinatesOf(v3).y()));
    popStyle();
  }

}

boolean insideOutside(Vector v1, Vector v3, Vector x){
  
  boolean xfound = false;
  boolean yfound = false;
  
  for( float a = 0; a<= 1; a+=0.1){
    for(float b = 0; b<= 1; b+= 0.1){
      if (frame.coordinatesOf(v1).x()*a + frame.coordinatesOf(v3).x()*b == frame.coordinatesOf(x).x())
          xfound = true;
      if (frame.coordinatesOf(v1).y()*a + frame.coordinatesOf(v3).y()*b == frame.coordinatesOf(x).y())
          //yfound = true;
      if(xfound == yfound == true)
        return true;
    }
  }
  return false;
}


void randomizeTriangle() {
  int low = -width/2;
  int high = width/2;
  v1 = new Vector(random(low, high), random(low, high));
  v2 = new Vector(random(low, high), random(low, high));
  v3 = new Vector(random(low, high), random(low, high));
}

void drawTriangleHint() {
  pushStyle();
  noFill();
  strokeWeight(2);
  stroke(255, 0, 0);
  triangle(v1.x(), v1.y(), v2.x(), v2.y(), v3.x(), v3.y());
  strokeWeight(5);
  stroke(0, 255, 255);
  point(v1.x(), v1.y());
  point(v2.x(), v2.y());
  point(v3.x(), v3.y());
  popStyle();
}

void spin() {
  if (scene.is2D())
    scene.eye().rotate(new Quaternion(new Vector(0, 0, 1), PI / 100), scene.anchor());
  else
    scene.eye().rotate(new Quaternion(yDirection ? new Vector(0, 1, 0) : new Vector(1, 0, 0), PI / 100), scene.anchor());
}

void keyPressed() {
  if (key == 'g')
    gridHint = !gridHint;
  if (key == 't')
    triangleHint = !triangleHint;
  if (key == 'd')
    debug = !debug;
  if (key == '+') {
    n = n < 7 ? n+1 : 2;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == '-') {
    n = n >2 ? n-1 : 7;
    frame.setScaling(width/pow( 2, n));
  }
  if (key == 'r')
    randomizeTriangle();
  if (key == ' ')
    if (spinningTask.isActive())
      spinningTask.stop();
    else
      spinningTask.run(20);
  if (key == 'y')
    yDirection = !yDirection;
}
