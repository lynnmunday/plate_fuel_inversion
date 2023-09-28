./isopod -i param_mesh.i
rm *0000*
./isopod -i synthetic.i
rm *0000*
rm mesh*source*
./isopod -i main.i
rm *0000*
