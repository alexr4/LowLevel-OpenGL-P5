import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture cam;


PImage src, dst;
OpenCV opencv;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;
ArrayList<PVector> gridList;
PShape grid;
float offset;
float resX;
float resY;
float incZ;
color ref;

void setup() {
  size(640*2, 480*2, P3D);

  String[] cameras = Capture.list();
  String fpsString00 = "=30";
  String fpsString01 = "=60";

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      if (cameras[i].indexOf(fpsString01) != -1)// || cameras[i].indexOf(fpsString00) != -1)
      {
        println(i+" : "+cameras[i]);
      }
    }

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[1]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }

  //grid
  gridList = new ArrayList<PVector>();
  offset = 3;
  resX = 640/offset;
  resY = 480/offset;
  incZ = 0.15;
  ref = color(255);

  for (int i=0; i<resX; i++)
  {
    for (int j=0; j<resY; j++)
    {
      float x = i*offset;
      float y = j*offset;
      gridList.add(new PVector(x, y));
    }
  }

  grid = createShape();
  grid.beginShape(POINTS);
  grid.stroke(255);
  for (PVector v : gridList)
  {
    grid.vertex(v.x, v.y);
  }
  grid.endShape();


  //opencv = new OpenCV(this, src);
  opencv = new OpenCV(this, 640, 480);

  opencv.gray();
  opencv.threshold(70);
  dst = opencv.getOutput();

  contours = opencv.findContours();

  println("found " + contours.size() + " contours");
}

void draw() {
  background(40);
  //test
  image(cam, 0, 0);
  image(dst, 0, 480);

  pushMatrix();
  translate(640, 0);
  noFill();  
  for (Contour contour : contours) {


    stroke(255, 0, 0);
    beginShape();
    for (PVector point : contour.getPolygonApproximation ().getPoints()) {
      vertex(point.x, point.y);
    }
    endShape();

    stroke(0, 255, 0);
    contour.draw();
  }
  popMatrix();

  pushMatrix();
  translate(640, 480);
  stroke(255);
  shape(grid);
  popMatrix();


  frame.setTitle("fps : "+floor(frameRate));
}

void captureEvent(Capture c) {
  c.read();
  opencv.loadImage(cam);
  opencv.gray();
  opencv.threshold(floor(map(mouseX, 0, width, 1, 100)));
  dst = opencv.getOutput();
  contours = opencv.findContours();
  try {
    gridList.clear();
    for (int i=0; i<resX; i++)
    {
      for (int j=0; j<resY; j++)
      {
        float x = i*offset;
        float y = j*offset;
        int index = floor(x + (y*dst.width));
        if (dst.pixels[index] != ref)
        {
          float z = brightness(cam.pixels[index])*incZ;
          gridList.add(new PVector(x, y, z));
        }
      }
    }

    grid = createShape();
    grid.beginShape(POINTS);
    grid.stroke(255);
    for (PVector v : gridList)
    {
      grid.vertex(v.x, v.y, v.z);
    }
    grid.endShape();
  }
  catch(Exception e)
  {
    println(e);
  }
}

