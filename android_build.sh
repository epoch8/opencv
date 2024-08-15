#!/bin/bash

# Set variables
OPENCV_DIR="$(pwd)"  # Set this to the root directory of your OpenCV source
BUILD_DIR="$(pwd)/opencv-release"

# Parse named arguments
for arg in "$@"; do
  case $arg in
    CMAKE_TOOLCHAIN_FILE=*)
      CMAKE_TOOLCHAIN_FILE="${arg#*=}"
      ;;
  esac
done

# Check for required arguments
if [ -z "$CMAKE_TOOLCHAIN_FILE" ]; then
  echo "CMAKE_TOOLCHAIN_FILE is required."
  exit 1
fi

# Clean up any previous builds
sudo rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create directories for each ABI
# sudo rm -r v8/ v7/ x86/ x86_64/ || true
# mkdir -p v8/ v7/ x86/ x86_64/

# Function to build OpenCV for a specific ABI
build_opencv() {
  ABI=$1
  OUTPUT_DIR=$2

  # Create build directory for the ABI
  mkdir -p "$BUILD_DIR/$ABI"
  cd "$BUILD_DIR/$ABI"

  # Configure the build
cmake "$OPENCV_DIR" \
  -DCMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" \
  -DANDROID_ABI="$ABI" \
  -DANDROID_NATIVE_API_LEVEL=21 \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_SHARED_LINKER_FLAGS="-llog" \
  -DANDROID_STL=c++_shared \
  -DBUILD_JAVA=ON  \
  -DBUILD_opencv_java=ON \
  -DBUILD_opencv_calib3d=ON \
  -DBUILD_opencv_core=ON \
  -DBUILD_opencv_dnn=ON \
  -DBUILD_opencv_features2d=ON \
  -DBUILD_opencv_flann=ON \
  -DBUILD_opencv_highgui=ON \
  -DBUILD_opencv_imgcodecs=ON \
  -DBUILD_opencv_imgproc=ON \
  -DBUILD_opencv_ml=ON \
  -DBUILD_opencv_objdetect=ON \
  -DBUILD_opencv_photo=ON \
  -DBUILD_opencv_shape=ON \
  -DBUILD_opencv_stitching=ON \
  -DBUILD_opencv_superres=ON \
  -DBUILD_opencv_video=ON \
  -DBUILD_opencv_videoio=ON \
  -DBUILD_opencv_videostab=ON


  # Build and install
  make -j 16
  sudo make install

  # Copy the output library to the appropriate directory
#   if [ -f "lib/arm64-v8a/libopencv_java3.so" ]; then
#     sudo cp "lib/arm64-v8a/libopencv_java3.so" "../../$OUTPUT_DIR/"
#     file "../../$OUTPUT_DIR/libopencv_java3.so"
#   else
#     echo "libopencv_java3.so not found for $ABI"
#   fi

#   sudo rm -rf *
#   cd ../..
}

# # Build for arm64-v8a
build_opencv "arm64-v8a" "v8"

# Build for armeabi-v7a
# build_opencv "armeabi-v7a" "v7"


# # Build for x86_64
#build_opencv "x86_64" "x86_64"

# # Build for x86  - не собирает пока почему то
#build_opencv "x86" "x86"


echo "Build completed successfully."


#run as 