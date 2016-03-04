function writeCorres(data, str, idx)
  dlmwrite(['7_result/ASIFT/' str '_' int2str(idx) '.txt'], data, 'delimiter', ' ', 'precision', '%f');
end