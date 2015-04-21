import java.nio.*;
 
int nvert = 1000000;
int SIZEOF_INT = Integer.SIZE / 8;
int SIZEOF_FLOAT = Float.SIZE / 8;
 
PGL pgl;
PShader sh;
 
int vertLoc;
int colorLoc;
 
IntBuffer vboName;
FloatBuffer vertData;
 
void setup() {
  size(640, 480, P3D);
 
  sh = loadShader("frag.glsl", "vert.glsl");
 
  createGeometry();
  initVBO();
}
 
void draw() {
  frame.setTitle("fps : "+floor(frameRate));
  background(0);
 
  rotate(frameCount * 0.01, width, height, 0);
  pgl = beginPGL();
  sh.bind();
 
  vertLoc = pgl.getAttribLocation(sh.glProgram, "vertex");
  colorLoc = pgl.getAttribLocation(sh.glProgram, "color");
 
  pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
  pgl.enableVertexAttribArray(vertLoc);
  pgl.enableVertexAttribArray(colorLoc);
 
  pgl.vertexAttribPointer(vertLoc, 3, PGL.FLOAT, false, 7 * SIZEOF_FLOAT, 0);
  pgl.vertexAttribPointer(colorLoc, 4, PGL.FLOAT, false, 7 * SIZEOF_FLOAT, 3 * SIZEOF_FLOAT);
 
  pgl.drawArrays(PGL.POINTS, 0, nvert);
 
  pgl.disableVertexAttribArray(vertLoc);
  pgl.disableVertexAttribArray(colorLoc);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
 
  sh.unbind();  
  endPGL();
 
  if (frameCount % 60 == 0) println("fps: " + frameRate);
}
 
void createGeometry() {
  float[] temp = new float[nvert * 7];
 
  for (int n = 0; n < nvert; n++) {
    // position
    temp[n * 7 + 0] = random(-1500, +1500);
    temp[n * 7 + 1] = random(-1500, +1500); 
    temp[n * 7 + 2] = random(-1500, +1500);
 
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
