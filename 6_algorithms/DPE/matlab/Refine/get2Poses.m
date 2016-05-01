function poses = get2Poses(in_mat, ex_mat, minDim, method); %'OPnP'
  
  poses = [];
  tgt = [-minDim,minDim,minDim,-minDim;-minDim,-minDim,minDim,minDim;0,0,0,0;1,1,1,1];
  src = ex_mat*tgt;
  src(1,:) = src(1,:)./src(3,:);
  src(2,:) = src(2,:)./src(3,:);
  if (method == 'OPnP')
    [RR, tt, error, flag] = OPnP(tgt(1:3,:), src(1:2,:));
    numPoses = min(size(RR, 3), 2);
    poses = zeros(numPoses, 6);
    for i = 1:numPoses
      poses(i, :) = exMat2Rz0RxRz1(RR(:, :, i), tt(:, i));
    end
  else
    [R1, R2, t1, t2, reprojErr1, reprojErr2] = planePose_IPPE_P(eye(3), tgt(1:3, :), src(1:2,:), 'Harker', true);
    poses = zeros(2, 6);
    poses(1, :) = exMat2Rz0RxRz1(R1, t1);
    poses(2, :) = exMat2Rz0RxRz1(R2, t2);
  end
end

function pose = exMat2Rz0RxRz1(R, t)
	rx = pi - acos(R(3,3));
	if (rx == 0)
		rz0 = 0;
		rz1 = atan2(-R(1,2), R(1,1));
	else
		rz0 = atan2(R(1,3), -R(2,3));
		rz1 = atan2(R(3,1), R(3,2));
	end
	pose = [t(1) t(2) t(3) rx rz0 rz1];
end