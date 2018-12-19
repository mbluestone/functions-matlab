function OutArray = RandomizeRows(InArray)
% RandomizeRows     Randomizes the row of a cell array or table
%
%   OutArray = RanomizeRows(InArray)
%
%   InArray  = m x n cell array or table
%
%   OutArray = an m x n cell array or table, with the rows randomized

% Detect whether input array is a cell array or table; initalize the
% appropriate OutArray
if istable(InArray)
    OutArray = table();
elseif iscell(InArray)
    OutArray = cell(size(InArray));
end

[NumOfRows,~] = size(InArray);
count = 0;

for RandRow = randperm(NumOfRows)
   count = count + 1;
   OutArray(count,:) = InArray(RandRow,:);
end

end