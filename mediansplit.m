%% Median Split
% Function for splitting data structure by median of column of data 
% points and outputting split
%
% USAGE:
% function [table,top,bottom] = mediansplit(data,colname,includemedian)
%
% INPUTS:
% INdata          structure or table of data to be split on the median
% colname         name of the column or field in the data structure where the median will be taken (as string)
% includemedian   boolean to include values that equal the median in the 'top' and 'bottom' outputs (true/false)
%                     - when mutliple values equal the median, randomly places 
%                       values back and forth between 'top' and 'bottom'
%
% OUTPUTS:
% OUTdata         table with the original column data and another column w/ median split indication
% top             column vector containing the values greater than the median split (top 50%)
% bottom          column vector containing the values less than the median split (bottom 50%)
%
% EXAMPLES:
%   [table,top,bottom] = mediansplit(data,'ResponseTime',true);
%
% Author: Max Bluestone, June 2017

function [OUTdata,top,bottom] = mediansplit(INdata,colname,includemedian)

coldata = INdata.(colname);
OUTdata = INdata;
OUTdata.MedianSplit = repmat({''}, size(OUTdata,1), 1);

median = quantile(coldata,0.5);

% Initialize count variables for loop
randcount = randi(2,1);
topcount = 1;
bottomcount = 1;

for i = 1:length(coldata)

    if coldata(i) > median
        
        OUTdata.MedianSplit(i) = {'top'};
                
        if exist('top','var')
            top(topcount,:) = INdata(i,:);
        end
        
        if ~exist('top','var')
            top = INdata(i,:);
        end
        
        topcount = topcount + 1;
        
    elseif coldata(i) < median
        
        OUTdata.MedianSplit(i) = {'bottom'};
        
        if exist('bottom','var')
            bottom(bottomcount,:) = INdata(i,:);
        end
        
        if ~exist('bottom','var')
            bottom = INdata(i,:);
        end
        
        bottomcount = bottomcount + 1;
        
    elseif coldata(i) == median
        
        OUTdata.MedianSplit(i) = {'Median'};
        
        if includemedian
            
            if mod(randcount,2)
                
                if ~exist('top','var')
                    top = INdata(i,:);
                end
        
                top(topcount,:) = INdata(i,:);
                
                topcount = topcount + 1;
                
            elseif mod(randcount,1)
                
                if ~exist('top','var')
                    bottom = INdata(i,:);
                end
        
                bottom(bottomcount,:) = coldata(i,:);
                
                bottomcount = bottomcount + 1;
                
            end
            
            randcount = randcount + 1;
            
        end
        
    end
    
end

end