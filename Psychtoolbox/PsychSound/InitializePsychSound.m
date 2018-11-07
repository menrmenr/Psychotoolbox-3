function InitializePsychSound(reallyneedlowlatency)
% InitializePsychSound([reallyneedlowlatency=0])
%
% This routine loads the PsychPortAudio sound driver for high-precision,
% low-latency, multi-channel sound playback and recording.
%
% Call it at the beginning of your experiment script, optionally providing
% the 'reallyneedlowlatency' flag set to one to push really hard for low
% latency.
%
% On MacOS/X and GNU/Linux, the PsychPortAudio driver will just work with
% the lowest possible latency and highest timing precision after this
% initialization.
%
% On Microsoft Windows you won't get any low-latency or high timing precision
% sound with any Psychtoolbox version before version 3.0.15, so upgrading to
% version 3.0.15 is required if you care about precision.
%
% PsychPortAudio on Windows supports two different Windows sound systems,
% MME and DirectSound. The Windows MME (MultiMediaExtensions) sound system has
% typical latencies and inaccuracies in excess of 500 msecs. DirectSound also
% typically has latencies in the > 40 msecs range and inaccurate timing.

% History:
% 6/6/2007    Written (MK).

if nargin < 1
    reallyneedlowlatency = [];
end

if isempty(reallyneedlowlatency)
    reallyneedlowlatency = 0; %#ok<NASGU> % Default: Don't push too hard for low latency.
end

% The usual tricks for MS-Windows:
if IsWin
    % Override driver installed?
    if exist([PsychtoolboxRoot 'portaudio_x86.dll'], 'file') || exist([PsychtoolboxRoot 'portaudio_x64.dll'], 'file')
        % Yes! Use override driver:
        fprintf('Detected optional PortAudio override driver plugin in Psychtoolbox root folder. Will use that.\n');
        driverloadpath = PsychtoolboxRoot;
    else
        % No - We use our standard driver:
        driverloadpath = [PsychtoolboxRoot 'PsychSound'];
    end

    % Standard path trick: Change working directory to driver load path,
    % preinit PsychPortAudio so it gets linked against the proper DLL, change
    % path back to old current directory:
    try
        olddir = pwd;
        cd(driverloadpath);
        % We force loading+linking+init of the driver:
        d = PsychPortAudio('GetDevices');
        cd(olddir);
    catch %#ok<*CTCH>
        cd(olddir);
        error('Failed to load PsychPortAudio driver for unknown reason! Dependency problem?!?');
    end
end

% Maybe some tricks (in the future) for OS/X? None yet.
if IsOSX
    try
        % We force loading+linking+init of the driver here, so in case
        % something goes wrong we can catch this and output useful
        % troubleshooting tips to the user:
        d = PsychPortAudio('GetDevices'); %#ok<NASGU>
        fprintf('PsychPortAudio initialized. Will use CoreAudio for audio.\n');
    catch
        fprintf('Failed to load PsychPortAudio driver!\n\n');
        fprintf('The most likely cause is that the helper library libportaudio.0.0.19.dylib is not\n');
        fprintf('stored in one of the library directories. This is the case at first use of the new\n');
        fprintf('sound driver.\n\n');
        fprintf('A copy of this file can be found in %s \n', [PsychtoolboxRoot 'PsychSound/libportaudio.0.0.19.dylib']);
        fprintf('You need to copy that file into one of the following directories, then retry:\n');
        fprintf('If you have administrator permissions, copy it to (at your option): /usr/local/lib\n');
        fprintf('or /usr/lib  -- you may need to create that directories first.\n\n');
        fprintf('If you are a normal user, you can also create a subdirectory lib/ in your home folder\n');
        fprintf('then copy the file there. E.g., your user name is lisa, then copy the file into\n');
        fprintf('/Users/lisa/lib/ \n\n');
        fprintf('Please try this steps, then restart your script.\n\n');
        em = psychlasterror;
        fprintf('The exact error message of the linker was: %s\n', em.message);
        fprintf('\n\n');
        error('Failed to load PsychPortAudio driver.');
    end
end

return;
