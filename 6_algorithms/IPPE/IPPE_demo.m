function IPPE_demo()
%IPPE_demo: An example of using IPPE to solve a plane's pose. If all runs
%correctly, the first solution should give zero reprojection error (up to
%machine precision)
%
% This file is part of the IPPE package for fast plane-based pose
% estimation from the paper "Infinitesimal Plane-based Pose Estimation" by Toby Collins and Adrien Bartoli, 
% published in the International Journal of Computer Vision, September
% 2014. A copy of the author's pre-print version can be found here:
%
% http://isit.u-clermont1.fr/~ab/Publications/Collins_Bartoli_IJCV14.pdf
%
% We hope you find this code useful and please cite our paper in your work:
%
%
%@article{
%year={2014},
%issn={0920-5691},
%journal={International Journal of Computer Vision},
%volume={109},
%number={3},
%doi={10.1007/s11263-014-0725-5},
%title={Infinitesimal Plane-Based Pose Estimation},
%url={http://dx.doi.org/10.1007/s11263-014-0725-5},
%publisher={Springer US},
%keywords={Plane; Pose; SfM; PnP; Homography},
%author={Collins, Toby and Bartoli, Adrien},
%pages={252-286},
%language={English}
%}
%
%
% This is free software covered by the FreeBSD License (see IPPE_license.txt) with Copyright (c) 2014 Toby Collins


addpath('./homogEstimationMethods/harker/');
addpath('./homogEstimationMethods/DLT/');

%%generate a camera intrinsic matrix:
K = eye(3);
K(1:2,end) = [640;480];
K(1,1) = 640;
K(2,2) = 640;

%%generate some model points in world coordinates on the plane z=0:
n = 10;
P = rand(2,n);
P(3,:) = 0;

%%generate a rigid transform (R,t) from world coordinates to camera
%%coordinates, and transform model points to camera coordinates:
[R,S,V] = svd(rand(3,3));
PCam = R*P;
c = mean(PCam,2);
t = [0.1;-0.1;2.5]-c;

PCam(1,:) = PCam(1,:) + t(1);
PCam(2,:) = PCam(2,:) + t(2);
PCam(3,:) = PCam(3,:) + t(3);

%%generate correspondences by projecting the points onto the image
Q = K*PCam;
Q(1,:) = Q(1,:)./Q(3,:);
Q(2,:) = Q(2,:)./Q(3,:);
Q = Q(1:2,:);

%perform IPPE:
homogMethod = 'Harker';  %Harker DLT 
[R1,R2,t1,t2,reprojErr1,reprojErr2] = planePose_IPPE_P(K,P,Q,homogMethod,true);

disp('Simple IPPE demo.');

disp('True pose:');
R,t

disp('Recovered first pose (with lowest reprojection error):')
R1,t1

disp('Recovered second pose (with highest reprojection error):')
R2,t2

disp('Reprojection errors:')
reprojErr1,reprojErr2







