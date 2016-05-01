function [R1,R2,t1,t2,reprojErr1,reprojErr2] = planePose_IPPE_P(K,P,Q,hEstMethod,sortSolutions)
%planePose_IPPE_P: The solution to Perspective IPPE with point correspondences computed
%between points in world coordinates on the plane z=0, and points in the
%camera's image.
%
%Inputs
%K: The 3x3 camera intrinsic matrix
%
%P: 2xn or 3xn matrix holding the model points in world coordinates. Points are
%defined on the plane z=0. If P is 3xn then the third row must be
%all-zeros. The model points do not need to be zero-centered.
%
%Q 2xn matrix holding the points in the camera image. These are defined in
%pixels (so are not normalised). If you want to use normalised points, just
%set K to I3 and use normalised points in Q.
%
%hEstMethod: the homography estimation method, either 'Harker' (default) or 'DLT'. If
%'Harker' then the method of Harker and O'Leary is used, from the paper
%"Computation of Homographies" in the 2005 British Computer Vision
%Conference. Otherwise the Direct Linear Transform is used, from Peter Kovesi's implementation at http://www.csse.uwa.edu.au/~pk.
%If hEstMethod=[] then the default is used.
%
%sortSolutions: boolean specifying whether to sort the solutions based on
%their reprojection error (with lowest first). If sortSolutions=[] then the
%solutions are not sorted.
%
%Outputs:
%
%(R1,t1,reprojErr1): The first solution to the plane's rigid pose with
%corresponding reprojection error.
%
%(R2,t2,reprojErr2): The second solution to the plane's rigid pose with
%corresponding reprojection error.
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


%set defaults for hEstMethod and sortSolutions:
if isempty(hEstMethod)
    hEstMethod = 'Harker';
end
if isempty(sortSolutions)
    sortSolutions = false;
end

%argument sanity check:
assert(size(P,1)==2|size(P,1)==3);
if size(P,1)==3
    assert(norm(P(3,:))<=eps);
end
assert(size(P,2)==size(Q,2));
assert(size(Q,1) == 2);

%n is the number of points:
n = size(P,2);

%zero-center model points:
Pbar = mean(P,2);
U(1,:) = P(1,:)-Pbar(1);
U(2,:) = P(2,:)-Pbar(2);

Kinv = inv(K);

%transform correspondences to normalised pixel coordinates:
Q_n = Kinv(1:2,:)*[Q;ones(1,n)];

%compute the model-to-image homography:
switch hEstMethod
    case 'DLT'
        H = homography2d([U;ones(1,n)],[Q_n;ones(1,n)]);
    case 'Harker'
        H = homographyHarker([U;ones(1,n)],[Q_n;ones(1,n)]);
end

%Compute the Jacobian J of the homography at (0,0):
H = H./H(3,3);
J(1,1) = H(1,1)-H(3,1)*H(1,3);
J(1,2) = H(1,2)-H(3,2)*H(1,3);
J(2,1) = H(2,1)-H(3,1)*H(2,3);
J(2,2) = H(2,2)-H(3,2)*H(2,3);

%Compute the two rotation solutions:
v = [H(1,3);H(2,3)];
[R1,R2] = IPPE_dec(v,J);

%Compute the two translation solutions:
t1_ = estT(R1,U,Q_n);
t2_ = estT(R2,U,Q_n);
t1 = [R1,t1_]*[-Pbar;1];
t2 = [R2,t2_]*[-Pbar;1];

%computes the reprojection errors (if needed)
if nargout>4||sortSolutions
    [reprojErr1,reprojErr2] = computeReprojErrs(R1,R2,t1,t2,K,P,Q);
    
    %Sort the solutions (if needed):
    if sortSolutions
        [reprojErr1,reprojErr2] = computeReprojErrs(R1,R2,t1,t2,K,P,Q);
        if reprojErr2<reprojErr1
            [R1,R2,t1,t2,reprojErr1,reprojErr2] = swapSolutions(R1,R2,t1,t2,reprojErr1,reprojErr2);
        end
    end
end

function [reprojErr1,reprojErr2] = computeReprojErrs(R1,R2,t1,t2,K,P,Q)
%computeReprojErrs: Computes the reprojection errors for the two solutions
%generated by IPPE.

%transform model points to camera coordinates and project them onto the
%image:
PCam1 = R1(:,1:2)*P(1:2,:);
PCam1(1,:) = PCam1(1,:) + t1(1);
PCam1(2,:) = PCam1(2,:) + t1(2);
PCam1(3,:) = PCam1(3,:) + t1(3);

PCam2 = R2(:,1:2)*P(1:2,:);
PCam2(1,:) = PCam2(1,:) + t2(1);
PCam2(2,:) = PCam2(2,:) + t2(2);
PCam2(3,:) = PCam2(3,:) + t2(3);

Qest_1 = K*PCam1;
Qest_1 = Qest_1./[Qest_1(3,:);Qest_1(3,:);Qest_1(3,:)];

Qest_2 = K*PCam2;
Qest_2 = Qest_2./[Qest_2(3,:);Qest_2(3,:);Qest_2(3,:)];

%compute reprojection errors:
reprojErr1 = norm(Qest_1(1:2,:)-Q);
reprojErr2 = norm(Qest_2(1:2,:)-Q);


function t = estT(R,psPlane,qq)
%Computes the least squares estimate of translation given the rotation solution.
if size(psPlane,1)==2
    psPlane(3,:) =0;
end
%qq = homoMult(Kinv,pp')';
Ps = R*psPlane;

numPts = size(psPlane,2);
Ax = zeros(numPts,3);
bx = zeros(numPts,1);

Ay = zeros(numPts,3);
by = zeros(numPts,1);



Ax(:,1) = 1;
Ax(:,3) = -qq(1,:);
bx(:) = qq(1,:).*Ps(3,:) -  Ps(1,:);

Ay(:,2) = 1;
Ay(:,3) = -qq(2,:);
by(:) = qq(2,:).*Ps(3,:) -  Ps(2,:);

A = [Ax;Ay];
b = [bx;by];

AtA = A'*A;
Atb = A'*b;

Ainv = IPPE_inv33(AtA);
t = Ainv*Atb;

function [R1,R2,t1,t2,reprojErr1,reprojErr2] = swapSolutions(R1_,R2_,t1_,t2_,reprojErr1_,reprojErr2_)
%swaps the solutions:
R1 = R2_;
t1 = t2_;
reprojErr1 = reprojErr2_;

R2 = R1_;
t2 = t1_;
reprojErr2 = reprojErr1_;
