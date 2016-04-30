clear all; close all; clc;
addpath('function');
addpath(genpath('6_algorithms'));

% conditions
c = ['tr'; 'zo'; 'or'; 'ir'; 'fl'; 'ml'; 'fm'];

% speed
s = 1:5;

% marker
m = ['wi'; 'du'; 'ci'; 'be'; 'fi'; 'ma'];

% in_mat
Ih = 540;
Iw = 960;
focal_length = 3067.45 / 4;
in_mat = [focal_length,0,Iw/2+0.5,0;0,focal_length,Ih/2+0.5,0;0,0,1,0;0,0,0,1];

for ci = 7%1:7
  if ci < 5
    si = 1:5;
  else
    si = 1;
  end
  for sii = si
    for mi = 2:6
      str = [];
      if ci < 5
        str = [m(mi, :) '_' c(ci, :) '_' int2str(s(sii))];
      else
        str = [m(mi, :) '_' c(ci, :)];
      end
      fprintf([str '\n']);
      idx = importdata(['3_index/' str '.txt']);
      txt = fopen(['7_result/IPPE/' str '.txt'], 'w');
      for i = idx
        corres = importdata(['7_result/ASIFT/' str '_' int2str(i) '.txt']);
        P = corres(1:3, :);
        Q = corres(4:5, :);
        n = size(P, 2);
        if (n < 4)
          ex_mat = zeros(3, 4);
        else
          Q = in_mat(1:3, 1:3)*[Q; ones(1, n)];
          Q = Q(1:2, :);
          homogMethod = 'Harker';  %Harker DLT 
          [R1,R2,t1,t2,reprojErr1,reprojErr2] = planePose_IPPE_P(in_mat(1:3, 1:3), P, Q, homogMethod, true);
          ex_mat = [R1, t1];
        end
        fprintf(txt,'%f %f %f %f %f %f %f %f %f %f %f %f\n', ex_mat(:).');
      end
      fclose(txt);
    end
  end
end