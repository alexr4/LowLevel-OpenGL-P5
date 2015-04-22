void initGrid(int res, int wgrid, int hgrid, int dgrid)
{
  offsetGrid = res;
  gridWidth = wgrid;
  gridHeight = hgrid;
  gridDepth = dgrid;
  resGridWidth = wgrid / offsetGrid;
  resGridHeight = hgrid / offsetGrid;
  resGridDepth = hgrid / offsetGrid;
  gridList = new ArrayList<PVector>();
}

void computeGridPosition()
{
  for (int j = 0; j < resGridHeight; j++)
  {
    for (int i = 0; i < resGridWidth; i++)
    {
      for (int h = 0; h < resGridDepth; h++)
      {
        float x = i * offsetGrid + (gridWidth/2 * -1);
        float y = j * offsetGrid + (gridHeight/2 * -1);
        float z = h * offsetGrid +  (gridDepth/2 * -1);

        gridList.add(new PVector(x, y, z));
      }
    }
  }

  println(gridList.size(), resGridHeight, resGridWidth, (resGridHeight * resGridWidth));
}

void createGridGeometry()
{
  int lengthVA = (resGridHeight * resGridWidth * resGridDepth) * 7;
  float[] temp = new float[lengthVA];

  for (int n = 0; n < gridList.size (); n++) {
    // position
    temp[n * 7 + 0] = gridList.get(n).x;
    temp[n * 7 + 1] = gridList.get(n).y; 
    temp[n * 7 + 2] = gridList.get(n).z;

    // color
    temp[n * 7 + 3] = 1;
    temp[n * 7 + 4] = 1;
    temp[n * 7 + 5] = 1;
    temp[n * 7 + 6] = 1;
  }
  vertData = allocateDirectFloatBuffer(lengthVA);
  vertData.rewind();
  vertData.put(temp);
  vertData.position(0);
}


void initVBO() {
  vboName = allocateDirectIntBuffer(1);
  pgl = beginPGL();
  pgl.genBuffers(1, vboName);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, vboName.get(0));
  pgl.bufferData(PGL.ARRAY_BUFFER, gridList.size () * 7 * SIZEOF_FLOAT, vertData, PGL.STATIC_DRAW);
  pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);
  endPGL();
}


IntBuffer allocateDirectIntBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_INT).order(ByteOrder.nativeOrder()).asIntBuffer();
}

FloatBuffer allocateDirectFloatBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_FLOAT).order(ByteOrder.nativeOrder()).asFloatBuffer();
}

