function [data_bc,blavg] = baseline_corr(data,baselinetw,times,blavg)
% Calculates baseline average and removes from rest of data.
%
% USAGE:
% function [data_bc] = baseline_corr(data,baselinetw,times)
%
% INPUTS:
% data          matrix, freq x time x chan x subj x condition
% baselinetw    baseline time window (in ms)
% times         specific time points used in data matrix (same size as 2nd
%               dimension of data)
% blavg         baseline average, if already computed, freq x chan x subj (optional)
%
% OUTPUTS:
% data_bc       baseline corrected data
% blavg         baseline average, freq x 1
%
% EXAMPLES:
%   [data_bn] = baseline_corr(powerdata,[0 300],EEG.times)
%
% Author: Max Bluestone, October 2017

%% Data matrix info

% Extract size of data matrix
datasize = size(data);

% Error out if size of times variable doesn't match time dimension of data
% matrix
if datasize(2) ~= length(times)
    error('Time points matrix does not match time dimension of data matrix')
end

% Convert to decibel
data_db = 10*log10(data);

%% Compute baseline average if not an input
if nargin<4

    % Pick out baseline window
    [~,minbound] = min(abs(min(baselinetw) - times)); % get closest value
    [~,maxbound] = min(abs(max(baselinetw) - times)); % get closest value

    % Make sure computed baseline window isn't too far off from requested
    % baseline window (<50ms difference)
    baselinewindow = times(maxbound) - times(minbound);

    if abs(baselinewindow - (max(baselinetw)-min(baselinetw))) > 50
        error('Computed baseline window is >50ms from what you want. Check results.ersptimes.')
    end
    
    fprintf('\nComputing baseline average from timepoints %i ms to %i ms.\n',times(minbound),times(maxbound));

    % Loop over other dimensions to compute baseline average
    for chan = 1:datasize(3)
        for subj = 1:datasize(4)

            % Extract baseline data (freq x time)
            if length(datasize)<5
                tmpdata(:,:) = squeeze(data_db(:,:,chan,subj));
                BL(:,:) = tmpdata(:,minbound:maxbound);
                
                blavg(:,chan,subj) = mean(BL,2);
            else
                for cond = 1:datasize(5)
                    tmpdata(cond,:,:) = squeeze(data_db(:,:,chan,subj,cond));
                    BL(cond,:,:) = tmpdata(cond,:,minbound:maxbound);
                end
                
                % Calculate mean power value over time for each freq in baseline period
                blavg(:,chan,subj) = mean(squeeze(mean(BL)),2);
            end
            
            
            
            clear tmpdata BL
        end
    end
end

%% Subtract baseline average from data

% Loop over other dimensions to subtract baseline average
for chan = 1:datasize(3)
    for subj = 1:datasize(4) 
        
        % Create matrix of baseline average the same size as freq x time
        % data matrix
        blmat = repmat(blavg(:,chan,subj),1,length(times));
        
        % Subtract baseline mean from rest of data
        if length(datasize)<5
            data_bc(:,:,chan,subj) = squeeze(data_db(:,:,chan,subj)) - blmat;
        else
            for cond2 = 1:datasize(5)
                data_bc(:,:,chan,subj,cond2) = squeeze(data_db(:,:,chan,subj,cond2)) - blmat;
            end
        end

    end
end

end
