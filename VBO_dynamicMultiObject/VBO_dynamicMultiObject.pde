import javax.media.opengl.GL2;
import java.nio.*;

//FinalPGraphics
PGraphics offscreen;

//Object01
VBOCube cube;
VBOSphere sphere;


//debug
FPSTracking fpstracker;

void setup() {
  size(1280, 720, P3D);

  //offscreen
  offscreen = createGraphics(width, height, P3D);
  offscreen.smooth();

  float resCube = 100;
  cube = new VBOCube(new PVector(width/2 - resCube*3, height/2), resCube);
  
  sphere = new VBOSphere(new PVector(width/2 + resCube*3, height/2), resCube);

  int w = width/4;
  int h = 50;
  fpstracker = new FPSTracking(w, 60, w, h);
}

void draw() {
  background(0); 

  //update
  fpstracker.run(frameRate);
  cube.run();
  sphere.run();

  offscreen.beginDraw();
  offscreen.background(0);

  offscreen.pushMatrix();
  offscreen.translate(width/2, height/2, cube.location.z);
  offscreen.rotate(frameCount * 0.01, width, height, 0);
  drawAxis(100, "RVB", offscreen);
  offscreen.popMatrix();

  offscreen.pushMatrix();
  offscreen.translate(cube.location.x, cube.location.y, cube.location.z);
  offscreen.rotate(frameCount * 0.01, width, height, 0);
  cube.display(offscreen, pgl);
  offscreen.popMatrix(); 

  offscreen.pushMatrix();
  offscreen.translate(sphere.location.x, sphere.location.y, sphere.location.z);
  offscreen.rotate(frameCount * 0.01, width, height, 0);
  sphere.display(offscreen, pgl);
  offscreen.popMatrix();



  offscreen.endDraw();

  image(offscreen, 0, 0);

  //debug
  showDebug();
}

void showDebug()
{
  noStroke();
  fill(10);
  rect(10, height-90-fpstracker.getImageTracker().height, fpstracker.getImageTracker().width+20, fpstracker.getImageTracker().height*2+30);
  image(fpstracker.getImageTracker(), 20, height-20-fpstracker.getImageTracker().height);
  fill(255, 220, 0);
  text("FPS : "+floor(frameRate)+"\nNb Particles inside Cube : "+cube.nvert+"\nNb Particles inside Sphere : "+sphere.nvert, 20, height-80-fpstracker.getImageTracker().height, fpstracker.getImageTracker().width, fpstracker.getImageTracker().height);
}

void drawAxis(float l, String colorMode, PGraphics off_)
{
  color xAxis = color(255, 0, 0);
  color yAxis = color(0, 255, 0);
  color zAxis = color(0, 0, 255);

  if (colorMode == "rvb" || colorMode == "RVB")
  {
    xAxis = color(255, 0, 0);
    yAxis = color(0, 255, 0);
    zAxis = color(0, 0, 255);
  } else if (colorMode == "hsb" || colorMode == "HSB")
  {
    xAxis = color(0, 100, 100);
    yAxis = color(115, 100, 100);
    zAxis = color(215, 100, 100);
  }

  off_.pushStyle();
  off_.strokeWeight(1);
  //x-axis
  off_.stroke(xAxis); 
  off_.line(0, 0, 0, l, 0, 0);
  //y-axis
  off_.stroke(yAxis); 
  off_.line(0, 0, 0, 0, l, 0);
  //z-axis
  off_.stroke(zAxis); 
  off_.line(0, 0, 0, 0, 0, l);
  off_.popStyle();
}

