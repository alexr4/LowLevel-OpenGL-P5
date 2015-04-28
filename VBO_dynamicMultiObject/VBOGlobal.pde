PGL pgl;
int SIZEOF_INT = Integer.SIZE / 8;
int SIZEOF_FLOAT = Float.SIZE / 8;

IntBuffer allocateDirectIntBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_INT).order(ByteOrder.nativeOrder()).asIntBuffer();
}

FloatBuffer allocateDirectFloatBuffer(int n) {
  return ByteBuffer.allocateDirect(n * SIZEOF_FLOAT).order(ByteOrder.nativeOrder()).asFloatBuffer();
}

