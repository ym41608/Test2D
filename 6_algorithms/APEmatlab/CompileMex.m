disp('COMPILING MEX FILES...')

cd mex

disp('==> compiling ''Poses2Trans_mex.cpp'' (1 out of 4)');
mex COMPFLAGS="/openmp" OPTIMFLAGS="/O2" Poses2Trans_mex.cpp

disp('==> compiling ''CreateSet_mex.cpp'' (2 out of 4)');
mex OPTIMFLAGS="/O2" CreateSet_mex.cpp

disp('==> compiling ''EvaluateEa_color_mex.cpp'' (3 out of 4)');
mex COMPFLAGS="/openmp" OPTIMFLAGS="/O2" EvaluateEa_color_mex.cpp

disp('==> compiling ''EvaluateEa_photo_mex.cpp'' (4 out of 4)');
mex COMPFLAGS="/openmp" OPTIMFLAGS="/O2" EvaluateEa_photo_mex.cpp

disp('==> DONE!');
fprintf('\n');
cd ..

%disp('COMPILING MEX FILES...')
%
%cd mex
%
%disp('==> compiling ''Poses2Trans_mex.cpp'' (1 out of 4)');
%mex OPTIMFLAGS="/O2" Poses2Trans_mex.cpp
%
%disp('==> compiling ''CreateSet_mex.cpp'' (2 out of 4)');
%mex OPTIMFLAGS="/O2" CreateSet_mex.cpp
%
%disp('==> compiling ''EvaluateEa_color_mex.cpp'' (3 out of 4)');
%mex OPTIMFLAGS="/O2" EvaluateEa_color_mex.cpp
%
%disp('==> compiling ''EvaluateEa_photo_mex.cpp'' (4 out of 4)');
%mex OPTIMFLAGS="/O2" EvaluateEa_photo_mex.cpp
%
%disp('==> DONE!');
%fprintf('\n');
%cd ..