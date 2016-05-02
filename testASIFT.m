clear all; close all; clc;
addpath('function');
addpath(genpath('6_algorithms'));

% compile
compile = 0;

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

% nm_mat
Tw = 400;
Th = 400;
nm_mat = eye(3);
nm_mat(1:2, :) = 0.5 * (3300/12350) * [1/Tw, 0, -1/(2*Tw) - 0.5; 0, -1/Th, 1/(2*Th) + 0.5];

if compile
  compile_matcher;
end

for ci = 7
  if ci < 5
    si = 1:5;
  else
    si = 1;
  end
  for sii = si
    for mi = 1:6
      str = [];
      if ci < 5
        str = [m(mi, :) '_' c(ci, :) '_' int2str(s(sii))];
      else
        str = [m(mi, :) '_' c(ci, :)];
      end
      %markerkeyFileName = ['5_markers/' m(mi, :) '.key'];
      marker = rgb2gray(im2double(imread(['5_markers/' m(mi, :) '.png'])));
      video_obj = VideoReader(['1_videos/' str '.mp4']);
      idx = importdata(['3_index/' str '.txt']);
      for i = 1:780%idx
        fprintf([str '  %d frame\n'], i);
        %imwrite(rgb2gray(im2double(read(video_obj, i))), '6_algorithms/ASIFT_RANSAC/tmp.png');
        img = rgb2gray(im2double(read(video_obj, i)));
        warning('off', 'all');
        cd '6_algorithms/ASIFT_RANSAC';
        [P, Q, fail] = ASIFT_RANSAC(marker, img, in_mat, nm_mat);
        %[P, Q, fail] = ASIFT_RANSAC(markerkeyFileName, 'tmp.png', in_mat, nm_mat);
        cd '../..';
        writeCorres([P; Q], str, i);
      end
    end
  end
end