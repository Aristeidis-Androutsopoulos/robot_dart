set -e

CLEAN=0

CLEAN=${1:-$CLEAN}

brew install binutils pybind11
python -m pip install --upgrade pip
pip3 install numpy

brew install dartsim --only-dependencies
pip3 install dartpy

brew install sdl2 glfw eigen glm bullet assimp devil faad2 freetype glslang harfbuzz libpng libspng jpeg openexr spirv-tools zstd webp

if [ $CLEAN -ne 0 ]; then
    echo "-- Cleaning.."
    # Remove previous attempts
    sudo rm -rf /opt/magnum
    # rm -rf /opt/dart
    sudo rm -rf /opt/robot_dart
fi

# Make temp folder
mkdir -p temp_robot_dart
cd temp_robot_dart

if [ $CLEAN -ne 0 ]; then
    rm -rf corrade
    rm -rf magnum
    rm -rf magnum-plugins
    rm -rf magnum-integration
fi

# Magnum related
if [ ! -d "corrade" ]
then
git clone https://github.com/mosra/corrade.git
fi
cd corrade
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/magnum ..
make -j8
sudo make install

cd ../..
if [ ! -d "magnum" ]
then
git clone https://github.com/mosra/magnum.git
fi
cd magnum
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/magnum -DMAGNUM_WITH_AUDIO=ON -DMAGNUM_WITH_DEBUGTOOLS=ON -DMAGNUM_WITH_GL=ON -DMAGNUM_WITH_MESHTOOLS=ON -DMAGNUM_WITH_PRIMITIVES=ON -DMAGNUM_WITH_SCENEGRAPH=ON -DMAGNUM_WITH_SHADERS=ON -DMAGNUM_WITH_TEXT=ON -DMAGNUM_WITH_TEXTURETOOLS=ON -DMAGNUM_WITH_TRADE=ON -DMAGNUM_WITH_GLFWAPPLICATION=ON -DMAGNUM_WITH_WINDOWLESSGLXAPPLICATION=ON  -DMAGNUM_WITH_WINDOWLESSCGLAPPLICATION=ON -DMAGNUM_WITH_OPENGLTESTER=ON -DMAGNUM_WITH_ANYAUDIOIMPORTER=ON -DMAGNUM_WITH_ANYIMAGECONVERTER=ON -DMAGNUM_WITH_ANYIMAGEIMPORTER=ON -DMAGNUM_WITH_ANYSCENEIMPORTER=ON -DMAGNUM_WITH_MAGNUMFONT=ON -DMAGNUM_WITH_OBJIMPORTER=ON -DMAGNUM_WITH_TGAIMPORTER=ON -DMAGNUM_WITH_WAVAUDIOIMPORTER=ON -DMAGNUM_WITH_GL_INFO=ON -DMAGNUM_WITH_AL_INFO=ON -DMAGNUM_TARGET_EGL=OFF ..
make -j8
sudo make install

cd ../..
if [ ! -d "magnum-plugins" ]
then
git clone https://github.com/mosra/magnum-plugins.git
fi
cd magnum-plugins
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/magnum -DMAGNUM_WITH_ASSIMPIMPORTER=ON -DMAGNUM_WITH_DDSIMPORTER=ON -DMAGNUM_WITH_JPEGIMPORTER=ON -DMAGNUM_WITH_OPENGEXIMPORTER=ON -DMAGNUM_WITH_PNGIMPORTER=ON -DMAGNUM_WITH_TINYGLTFIMPORTER=ON -DMAGNUM_WITH_STBTRUETYPEFONT=ON ..
make -j
sudo make install

cd ../..
if [ ! -d "magnum-integration" ]
then
git clone https://github.com/mosra/magnum-integration.git
fi
cd magnum-integration
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/magnum -DMAGNUM_WITH_DART=ON -DMAGNUM_WITH_EIGEN=ON -DMAGNUM_WITH_BULLET=ON -DMAGNUM_WITH_GLM=ON ..
make -j
sudo make install

cd ../..
if [ ! -d "magnum-bindings" ]
then
git clone https://github.com/mosra/magnum-bindings.git
fi
cd magnum-bindings
mkdir build && cd build
cmake .. -DMAGNUM_WITH_PYTHON=ON
make -j
cd src/python
sudo python3 setup.py install

export PATH=/opt/magnum/bin:$PATH
export LD_LIBRARY_PATH=/opt/magnum/lib:$LD_LIBRARY_PATH

cd ../../..
if [ $CLEAN -ne 0 ]; then
    rm -rf temp_robot_dart
fi

# RobotDART
./waf configure --prefix /opt/robot_dart --python
./waf -j8
./waf examples -j8
sudo ./waf install
