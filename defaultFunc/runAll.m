function [] = runAll(path)

folder  = path;
list    = dir(fullfile(folder, '*.m'));
nFile   = length(list);
success = false(1, nFile);
for k = 1:nFile
  file = list(k).name;
  try
    run(fullfile(folder, file));
    success(k) = true;
  catch
    fprintf('failed: %s\n', file);
  end
end

end