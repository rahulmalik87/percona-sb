cmake -GNinja -DCMAKE_INSTALL_PREFIX=$PWD/pjc -S . -B buil
cmake --build build --install target
