options nocenter;
libname shapes 'p:\bio113\hw';
data shapes.shapes;
infile 'g:\shared\bio113\hw1_3.dat';
informat shape $9.;
input shape @;
if shape='oval' then input radius;
else if shape='rectangle' then input length width;
else  delete;
run;
proc print;
run;