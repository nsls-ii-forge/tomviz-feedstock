
#!/bin/sh

# Copied from conda-forge ParaView feedstock
if test `uname` = "Linux"
then
  # No rule to make target `.../_build_env/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/librt.so'
  mkdir -p $BUILD_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/
  for sn in rt pthread dl m; do
    cp -v $BUILD_PREFIX/x86_64-conda-linux-gnu/sysroot/usr/lib/lib${sn}.so $BUILD_PREFIX/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib/
  done
fi

# First build ParaView
mkdir -p paraview-build && cd paraview-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DBUILD_TESTING:BOOL=OFF \
  -DPython3_FIND_STRATEGY=LOCATION \
  -DPython3_ROOT_DIR=${PREFIX} \
  -DPARAVIEW_ENABLE_CATALYST:BOOL=OFF \
  -DPARAVIEW_ENABLE_PYTHON:BOOL=ON \
  -DPARAVIEW_ENABLE_WEB:BOOL=OFF \
  -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF\
  -DPARAVIEW_USE_QTHELP:BOOL=OFF \
  -DPARAVIEW_PLUGINS_DEFAULT:BOOL=OFF \
  -DPARAVIEW_USE_VTKM:BOOL=OFF \
  -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB \
  -DVTK_PYTHON_VERSION:STRING=3 \
  -DVTK_PYTHON_FULL_THREADSAFE:BOOL=ON \
  -DVTK_NO_PYTHON_THREADS:BOOL=OFF \
  ../paraview
ninja install -j${CPU_COUNT}

# Now build Tomviz
cd .. && mkdir -p tomviz-build && cd tomviz-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DParaView_DIR:PATH=${SRC_DIR}/paraview-build \
  -DBUILD_TESTING:BOOL=OFF \
  -DPython3_FIND_STRATEGY=LOCATION \
  -DPython3_ROOT_DIR=${PREFIX} \
  ../tomviz
ninja install -j${CPU_COUNT}