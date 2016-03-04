close all; clear all; clc;

% conditions
c = ['tr'; 'zo'; 'or'; 'ir'; 'fl'; 'ml'; 'fm'];

% speed
s = 1:5;

% marker
m = ['wi'; 'du'; 'ci'; 'be'; 'fi'; 'ma'];

%
nPerf = 23;

% cut
for ci = 1:7
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
      fprintf([str '\n']);
      nf = importdata(['2_nframes/' str '.txt']);
      ps = 5; pe = nf - 5;
      interval = (pe - ps + 1) / nPerf;
      idx = floor(ps:interval:pe);
      if (idx(1) < ps || idx(end) > pe)
        error();
      end
      dlmwrite(['3_index/' str '.txt'], idx, 'delimiter', ' ', 'precision', '%d');
    end
  end
end