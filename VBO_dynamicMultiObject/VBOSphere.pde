class VBOSphere
{
  //variables
  //VBO
  IntBuffer vboName;
  FloatBuffer vertData;

  //3D Object Variables
  PVector location;
  float radiusX, radiusY, radiusZ;
  int maxVert; //CPU seems to have probleme with million elements
  int nvert;

  //dynamic data
  float nvertOff, nvertSpeed;

  //Constructeur
  VBOSphere(PVector loc_, float rad_)
  {
    location = loc_.get();
    radiusX = radiusY = radiusZ = rad_;
    //dynamic data 
    nvertSpeed = random(0.1);
    nvertOff = random(1); 
    maxVert = 100000; //CPU seems to have probleme with million elements
    nvert = maxVert;
    //nvert = floor(noise(nvertOff) * 1000); //WARNING nvert need to be a the max at first
    createGeometry(radiusX, radiusY, radiusZ);
    initVBO();
  }

  //Méthodes
  void run()
  {
    updateVerticesNumber();
    try {
      updateGeometry(radiusX, radiusY, radiusZ);
      updateVBO();
    }
    catch(Exception e)
    {
      println(e);
    }
  }

  //Behaviors
  void updateVerticesNumber()
  {
    nvert = floor(noise(nvertOff) * maxVert);
    nvertOff += nvertSpeed;
  }

  //Init
  void createGeometry(float rx, float ry, float rz)
  {
    float[] temp = new float[nvert * 7];

    for (int n = 0; n < nvert; n++) {

      float alpha = random(PI);
      float beta = random(TWO_PI);

      float radx = random(0, rx);
      float rady = radx;//random(0, ry);
      float radz = rady;//random(0, rz);

      // position
      temp[n * 7 + 0] = sin(alpha)*cos(beta)*radx;
      temp[n * 7 + 1] = sin(alpha)*sin(beta)*rady; 
      temp[n * 7 + 2] = cos(alpha)*radz;

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

  //Update
  void updateGeometry(float rx, float ry, float rz)
  {

    float[] temp = new float[nvert * 7];

    for (int n = 0; n < nvert; n++) {
      float alpha = random(PI);
      float beta = random(TWO_PI);

      float radx = random(0, rx);
      float rady = radx;//random(0, ry);
      float radz = radx;//random(0, rz);

      // position
      temp[n * 7 + 0] = sin(alpha)*cos(beta)*radx;
      temp[n * 7 + 1] = sin(alpha)*sin(beta)*rady; 
      temp[n * 7 + 2] = cos(alpha)*radz;

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
    pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
    pgl.bufferData(PGL.ARRAY_BUFFER, nvert * 7 * SIZEOF_FLOAT, vertData, PGL.DYNAMIC_DRAW);
    pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
    endPGL();
  }

  //Display()
  void display(PGraphics os_, PGL pgl_)
  {
    GL2 gl2 = ((PJOGL)pgl_).gl.getGL2();
    pgl_ = os_.beginPGL();

    pgl_.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
    gl2.glEnableClientState(GL2.GL_VERTEX_ARRAY);
    gl2.glEnableClientState(GL2.GL_COLOR_ARRAY);

    gl2.glVertexPointer(3, PGL.FLOAT, 7 * SIZEOF_FLOAT, 0);
    gl2.glColorPointer(4, PGL.FLOAT, 7 * SIZEOF_FLOAT, 3 * SIZEOF_FLOAT);

    //gl2.glPointSize(map(mouseX, 0, width, 1, 100));

    pgl_.drawArrays(PGL.POINTS, 0, nvert);

    gl2.glDisableClientState(GL2.GL_VERTEX_ARRAY);
    gl2.glDisableClientState(GL2.GL_COLOR_ARRAY);
    pgl_.bindBuffer(PGL.ARRAY_BUFFER, 0);

    os_.endPGL();
  }
}

