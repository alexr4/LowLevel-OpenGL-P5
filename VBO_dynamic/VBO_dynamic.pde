import javax.media.opengl.GL2;
import java.nio.*;

//FinalPGraphics
PGraphics offscreen;

//VBO
int maxVert = 500000;
int nvert = maxVert;
int SIZEOF_INT = Integer.SIZE / 8;
int SIZEOF_FLOAT = Float.SIZE / 8;
PGL pgl;
IntBuffer vboName;
FloatBuffer vertData;

//dynamic data
float nvertOff, nvertSpeed;

//Obj
int nbObj;
float resX;
float resY;

//debug
FPSTracking fpstracker;

void setup() {
  size(1280, 720, P3D);

  //offscreen
  offscreen = createGraphics(width, height, P3D);
  offscreen.smooth();

  //obj
  nbObj = 6;
  resX = width/nbObj;
  resY = height/nbObj;

  //dynamic data 
  nvertSpeed = random(0.01);
  nvertOff = random(1);
  //nvert = floor(noise(nvertOff) * 1000); //WARNING nvert need to be a the max at first
  createGeometry(resX/4);
  initVBO();


  int w = width/4;
  int h = 50;
  fpstracker = new FPSTracking(w, 60, w, h);
}

void draw() {
  fpstracker.run(frameRate);

  //frame.setTitle("FPS : "+floor(frameRate)+" Nb cube : "+(nbObj*nbObj)+" Nb particles : "+nvert+" per cube"+" Nb total of Particles : "+((nbObj*nbObj)*nvert));
  background(0);

  nvert = floor(noise(nvertOff) * maxVert);

  try {
    updateGeometry(resX/4);
    updateVBO();
  }
  catch(Exception e)
  {
    println(e);
  }

  GL2 gl2 = ((PJOGL)pgl).gl.getGL2();

  offscreen.beginDraw();
  offscreen.background(0);

  offscreen.pushMatrix();
  offscreen.translate(width/2, height/2, -resX/4);
  offscreen.rotate(frameCount * 0.01, width, height, 0);
  drawAxis(100, "RVB", offscreen);
  offscreen.popMatrix();
  
  
  //Clones-Object with 1VBO
  for (int i=0; i<nbObj; i++)
  {
    for (int j=0; j<nbObj; j++)
    {
      float x = i*resX+resX/2;
      float y = j*resY+resY/2;

      offscreen.pushMatrix();
      offscreen.translate(x, y);
      offscreen.rotate(frameCount * 0.01, width, height, 0);

      pgl = offscreen.beginPGL();

      pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
      gl2.glEnableClientState(GL2.GL_VERTEX_ARRAY);
      gl2.glEnableClientState(GL2.GL_COLOR_ARRAY);

      gl2.glVertexPointer(3, PGL.FLOAT, 7 * SIZEOF_FLOAT, 0);
      gl2.glColorPointer(4, PGL.FLOAT, 7 * SIZEOF_FLOAT, 3 * SIZEOF_FLOAT);

      pgl.drawArrays(PGL.POINTS, 0, nvert);

      gl2.glDisableClientState(GL2.GL_VERTEX_ARRAY);
      gl2.glDisableClientState(GL2.GL_COLOR_ARRAY);
      pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

      offscreen.endPGL();
      offscreen.popMatrix();
    }
  }
  offscreen.endDraw();

  image(offscreen, 0, 0);
  nvertOff += nvertSpeed;

  //debug
  showDebug();
}

void showDebug()
{
  noStroke();
  fill(10);
  rect(10, height-60-fpstracker.getImageTracker().height, fpstracker.getImageTracker().width+20, fpstracker.getImageTracker().height*2);
  image(fpstracker.getImageTracker(), 20, height-20-fpstracker.getImageTracker().height);
  fill(255, 220, 0);
  text("FPS : "+floor(frameRate)+" Nb cube : "+round(nbObj*nbObj)+" Nb particles : "+nvert+" per cube"+" Nb total of Particles : "+round((nbObj*nbObj)*nvert), 20, height-55-fpstracker.getImageTracker().height, fpstracker.getImageTracker().width, fpstracker.getImageTracker().height);
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
  //pgl.genBuffers(1, vboName);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
  pgl.bufferData(PGL.ARRAY_BUFFER, nvert * 7 * SIZEOF_FLOAT, vertData, PGL.DYNAMIC_DRAW);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
  endPGL();
}

void createGeometry(float res)
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
  vertData = allocateDirectFloatBuffer(nvert * 7);
  vertData.rewind();
  vertData.put(temp);
  vertData.position(0);
}

void initVBO() {
  vboName = allocateDirectIntBuffer(1);
  pgl = beginPGL();
  pgl.genBuffers(1, vboName);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
  pgl.bufferData(PGL.ARRAY_BUFFER, nvert * 7 * SIZEOF_FLOAT, vertData, PGL.DYNAMIC_DRAW);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
  endPGL();
}

IntBuffer allocateDirectIntBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_INT).order(ByteOrder.nativeOrder()).asIntBuffer();
}

FloatBuffer allocateDirectFloatBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_FLOAT).order(ByteOrder.nativeOrder()).asFloatBuffer();
}

