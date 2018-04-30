% REMOVE_FIELDS is a wrap-up to check if the fields within a vector are
% part of the structure feeded to the function to remove them.

function [strctr] = removeFields(strctr, fields_to_remove)

strctr = rmfield(strctr, fields_to_remove(isfield(strctr, fields_to_remove)));

end