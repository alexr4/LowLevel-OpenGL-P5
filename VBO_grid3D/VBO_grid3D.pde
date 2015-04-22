/*Remember :
 The algorithm for compute the index of a pixel on a grid is : x + (y * gridWidth);
 */

import javax.media.opengl.GL2;
import java.nio.*;

//FinalPGraphics
PGraphics offscreen;

//VBO
int SIZEOF_INT = Integer.SIZE / 8;
int SIZEOF_FLOAT = Float.SIZE / 8;
PGL pgl;
IntBuffer vboName;
FloatBuffer vertData;

//Grid
float pointSize;
PVector anchorPoint;
ArrayList<PVector> gridList;
int offsetGrid;
int resGridWidth;
int resGridHeight;
int resGridDepth;
int gridWidth, gridHeight, gridDepth;

//debug
FPSTracking fpstracker;

//config
Boolean config;

void setup() {
  size(1280, 720, P3D);
  smooth();
  globalInit();
  config = true;
}

void draw() {
  if (config)
  {
    float dmf = dist(mouseX, mouseY, width/2, height/2);
    float hypotenuse = sqrt(width * width +height * height);
    float zDepth = map(dmf, 0, hypotenuse, anchorPoint.z, -anchorPoint.z); 

    fpstracker.run(frameRate);
    frame.setTitle("FPS : "+floor(frameRate)+" Nb particles : "+gridList.size()+" per cube");
    background(0);

    // updateGeometry(100);
    //  updateVBO();

    GL2 gl2 = ((PJOGL)pgl).gl.getGL2();

    offscreen.beginDraw();
    offscreen.background(0);
    offscreen.pushMatrix();
    offscreen.translate(anchorPoint.x, anchorPoint.y, zDepth);
    offscreen.rotateX(frameCount * 0.01);
    offscreen.rotateY(frameCount * 0.01);

    drawAxis(100, "RVB", offscreen);

    pgl = offscreen.beginPGL();

    pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
    gl2.glEnableClientState(GL2.GL_VERTEX_ARRAY);
    gl2.glEnableClientState(GL2.GL_COLOR_ARRAY);

    gl2.glVertexPointer(3, PGL.FLOAT, 7 * SIZEOF_FLOAT, 0);
    gl2.glColorPointer(4, PGL.FLOAT, 7 * SIZEOF_FLOAT, 3 * SIZEOF_FLOAT);

    gl2.glPointSize(pointSize);

    pgl.drawArrays(PGL.POINTS, 0, gridList.size());

    gl2.glDisableClientState(GL2.GL_VERTEX_ARRAY);
    gl2.glDisableClientState(GL2.GL_COLOR_ARRAY);
    pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

    offscreen.endPGL();
    offscreen.popMatrix();
    offscreen.endDraw();

    image(offscreen, 0, 0);

    //debug
    image(fpstracker.getImageTracker(), 10, height-10-fpstracker.getImageTracker().height);
    fill(0, 0, 255);
    text("FPS : "+floor(frameRate)+" Nb particles on grid : "+gridList.size(), 10, height-40-fpstracker.getImageTracker().height);
    text("Grid width : "+gridWidth+"px Grid height : "+gridHeight+"px", 10, height-20-fpstracker.getImageTracker().height);
  }
}


void globalInit()
{
  offscreen = createGraphics(width, height, P3D);
  offscreen.smooth();

  pointSize = 1;
  anchorPoint = new PVector(width/2, height/2, -height*2);
  initGrid(5, width, height, height);
  computeGridPosition();
  createGridGeometry();
  initVBO();

  int w = width/4;
  int h = 50;
  fpstracker = new FPSTracking(w, 60, w, h);
}

/*
void updateGeometry(float res)
 {
 float cubeSize = res;
 float[] temp = new float[nvert * 7];
 
 for (int n = 0; n < nvert; n++) {
 // position
 temp[n * 7 + 0] = random(-cubeSize, +cubeSize);
 temp[n * 7 + 1] = random(-cubeSize, +cubeSize); 
 temp[n * 7 + 2] = random(-cubeSize, +cubeSize);
 
 // color
 temp[n * 7 + 3] = 1;
 temp[n * 7 + 4] = 1;
 temp[n * 7 + 5] = 1;
 temp[n * 7 + 6] = 1;
 }
 
 //vertData = allocateDirectFloatBuffer(nvert * 7);
 vertData.rewind();
 vertData.put(temp);
 vertData.position(0);
 }
 
 void updateVBO() {
 // vboName = allocateDirectIntBuffer(1);
 pgl = beginPGL();
 // pgl.genBuffers(1, vboName);
 pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
 pgl.bufferData(PGL.ARRAY_BUFFER, nvert * 7 * SIZEOF_FLOAT, vertData, PGL.STATIC_DRAW);
 pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
 endPGL();
 }*/

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

