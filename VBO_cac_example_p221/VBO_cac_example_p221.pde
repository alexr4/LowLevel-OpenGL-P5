import javax.media.opengl.GL2;
import java.nio.*;

//VBO
int nvert = 100000;
int SIZEOF_INT = Integer.SIZE / 8;
int SIZEOF_FLOAT = Float.SIZE / 8;
PGL pgl;
IntBuffer vboName;
FloatBuffer vertData;

//Obj
int nbObj;
float resX;
float resY;

void setup() {
  size(1280, 720, P3D);

  //obj
  nbObj = 2;
  resX = width/nbObj;
  resY = height/nbObj;

  createGeometry(resX/4);
  initVBO();
}

void draw() {
  frame.setTitle("FPS : "+floor(frameRate)+" Nb cube : "+(nbObj*nbObj)+" Nb particles : "+nvert+" per cube"+" Nb total of Particles : "+((nbObj*nbObj)*nvert));
  background(0);

  updateGeometry(resX/4);
  updateVBO();

  GL2 gl2 = ((PJOGL)pgl).gl.getGL2();

  //Clones-Object with 1VBO
  for (int i=0; i<nbObj; i++)
  {
    for (int j=0; j<nbObj; j++)
    {
      float x = i*resX+resX/2;
      float y = j*resY+resY/2;

      pushMatrix();
      translate(x, y);
      rotate(frameCount * 0.01, width, height, 0);

      pgl = beginPGL();

      pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
      gl2.glEnableClientState(GL2.GL_VERTEX_ARRAY);
      gl2.glEnableClientState(GL2.GL_COLOR_ARRAY);

      gl2.glVertexPointer(3, PGL.FLOAT, 7 * SIZEOF_FLOAT, 0);
      gl2.glColorPointer(4, PGL.FLOAT, 7 * SIZEOF_FLOAT, 3 * SIZEOF_FLOAT);

      pgl.drawArrays(PGL.POINTS, 0, nvert);

      gl2.glDisableClientState(GL2.GL_VERTEX_ARRAY);
      gl2.glDisableClientState(GL2.GL_COLOR_ARRAY);
      pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

      endPGL();
      popMatrix();
    }
  }
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
  // pgl.genBuffers(1, vboName);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
  pgl.bufferData(PGL.ARRAY_BUFFER, nvert * 7 * SIZEOF_FLOAT, vertData, PGL.STATIC_DRAW);
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
  pgl.bufferData(PGL.ARRAY_BUFFER, nvert * 7 * SIZEOF_FLOAT, vertData, PGL.STATIC_DRAW);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
  endPGL();
}

IntBuffer allocateDirectIntBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_INT).order(ByteOrder.nativeOrder()).asIntBuffer();
}

FloatBuffer allocateDirectFloatBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_FLOAT).order(ByteOrder.nativeOrder()).asFloatBuffer();
}

