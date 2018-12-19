%% PsychToolbox Stuff
AssertOpenGL;   % check for Opengl compatibility, abort otherwise
rand('state',sum(100*clock));   % Reseed the random-number generator for each expt
Screen('Preference', 'SkipSyncTests', 0); % PILOTING ONLY

% Dummy calls to prevent delays
KbCheck;
WaitSecs(0.1);
GetSecs;

KbName('UnifyKeyNames');    % Make sure keyboard mapping is the same on all supported operating systems
enter = KbName('return');
escapeKey = KbName('ESCAPE');
trigger = KbName('5%');
enablekeys = KbName(respkeys);

InitializePsychSound(1);

% added for KbQueue
keylist=zeros(1,256);%%create a list of 256 zeros
keylist([enablekeys enter escapeKey])=1;%%set keys you interested in to 1

% % added for KbQueue
% % If Current Designs Keyboard is detected, make it the response device.
% % Otherwise, send an error.
% deviceString='Keyboard';%% name of the scanner trigger box
% [id,name] = GetKeyboardIndices;% get a list of all devices connected
% resp_device=0;
% 
% for i=1:length(name)%for each possible device
%     if strcmp(name{i},deviceString)%compare the name to the name you want
%         resp_device=id(i);%grab the correct id, and exit loop
%         break;
%     end
% end

% Initialize PsychHID and get list of devices
clear PsychHID;
% LoadPsychHID;
devices = PsychHID('devices');

% If Current Designs Keyboard is detected, make it the response device. Otherwise, use any keyboard.
if ~isempty(find(strcmp({devices.manufacturer}, 'Current Designs, Inc.') & strcmp({devices.usageName}, 'Keyboard'),1));
    resp_device = find(strcmp({devices.manufacturer}, 'Current Designs, Inc.') & strcmp({devices.usageName}, 'Keyboard'));
else
    resp_device = find(strcmp({devices.usageName}, 'Keyboard'));
end

if resp_device==0%%error checking
 error('No device by that name was detected');
end

%%% for EEG port codes
if strcmp(eegMode,'y')
    s = daq.createSession('ni'); % setup the session
    ch = addDigitalChannel(s,'Dev1', 'Port2/Line0:7', 'OutputOnly');
    outputSingleScan(s, [0 0 0 0 0 0 0 0])
end

%% Initialize Experiment %%

% Get screenNumber of stimulation display, and choose the maximum index, which is usually the right one.
screens=Screen('Screens');
screenNumber=max(screens);
HideCursor;

% Open a double buffered fullscreen window on the stimulation screen
% 'screenNumber' and use background color specified in settings
% 'w' is the handle used to direct all drawing commands to that window
% 'wRect' is a rectangle defining the size of the window. See "help PsychRects" for help on such rectangles
%     [w, wRect]=Screen('OpenWindow',screenNumber, backgroundColor);

% if using debugging node, opens the screen in a small window so that the 
% command window is still visible - if not debugging, opens regular sized screen
if dbgn == 1
    [S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow',...          
        S.screenColor, [0 0 1024 768], 32);
else
    [S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow',...         
        S.screenColor, [], 32);
end

W=S.myRect(RectRight); % screen width
H=S.myRect(RectBottom); % screen height
slack = Screen('GetFlipInterval', S.Window)/2;

% Set text size
Screen('TextSize', S.Window, 30);

Priority(MaxPriority(S.Window));   % Set priority for script execution to realtime priority

if strcmp(computer,'PCWIN') == 1
    ShowHideWinTaskbarMex(0);
end

% Initialize KbCheck and return to zero in case a button is pressed
[KeyIsDown, endrt, KeyCode]=KbCheck;
% ESC key quits the experiment
if KeyCode(KbName('ESCAPE')) == 1
    clear all
    close all
    sca
    return;
end
KeyIsDown = zeros(size(KeyIsDown));
endrt = zeros(size(endrt));
KeyCode = zeros(size(KeyCode));
