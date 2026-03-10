%% SYNCHRONIZED VIDEO + AUDIO WAVEFORM DISPLAY WITH DELAY - MULTI-TRIAL
% Shows multiple trials with video, audio playback, and real-time waveform
% Includes adjustable audio delay to account for processing/reaction time

clear; clc; close all;
cd('E:\Dropbox\LeuchterGrandjean_lc_sg\ToolboxDemo_ARF2026\vids')

%% === CONFIGURATION ===
fprintf('=== SYNCHRONIZED VIDEO + AUDIO DISPLAY - MULTI-TRIAL ===\n');

% Audio delay parameter (in milliseconds)
audioDelayMs = 250;  % ADJUST THIS VALUE (200-300ms typical for auditory-motor response)

fprintf('Audio delay set to: %d ms\n', audioDelayMs);

%% === SELECT MULTIPLE VIDEOS ===
[videoFiles, videoPath] = uigetfile('*.mp4', 'Select trial videos to display', ...
                                    'MultiSelect', 'on');
if isequal(videoFiles, 0)
    error('No videos selected. Demo cancelled.');
end

% Ensure videoFiles is a cell array even if only one file selected
if ~iscell(videoFiles)
    videoFiles = {videoFiles};
end

numTrials = length(videoFiles);
fprintf('✓ Selected %d video(s)\n', numTrials);

%% === SELECT CORRESPONDING AUDIO FILES ===
audioFiles = cell(numTrials, 1);
audioPath = '';

for i = 1:numTrials
    fprintf('\n--- Video %d/%d: %s ---\n', i, numTrials, videoFiles{i});
    
    [audioFile, audioPathTemp] = uigetfile({'*.wav;*.mp3;*.m4a', 'Audio Files (*.wav, *.mp3, *.m4a)'}, ...
                                           sprintf('Select audio for video %d/%d: %s', i, numTrials, videoFiles{i}));
    if audioFile == 0
        error('Audio file selection cancelled. Cannot proceed.');
    end
    
    audioFiles{i} = audioFile;
    if i == 1
        audioPath = audioPathTemp;  % Store path from first selection
    end
    
    fprintf('✓ Matched: %s <-> %s\n', videoFiles{i}, audioFile);
end

fprintf('\n=== ALL %d VIDEO-AUDIO PAIRS MATCHED ===\n', numTrials);

%% === SETUP VISUALIZATION - FULLSCREEN ===
hFig = figure('Name', 'Vocal Tract Mimicry Display - Multi-Trial', ...
              'WindowState', 'maximized');

%% === PROCESS EACH TRIAL SEQUENTIALLY ===
for trialIdx = 1:numTrials
    
    %% === RESET FIGURE FOR NEW TRIAL ===
    clf(hFig);
    set(hFig, 'Color', 'white');
    
    %% === TRIAL INITIALIZATION ===
    fullVideoPath = fullfile(videoPath, videoFiles{trialIdx});
    fullAudioPath = fullfile(audioPath, audioFiles{trialIdx});
    
    fprintf('\n========================================\n');
    fprintf('TRIAL %d/%d\n', trialIdx, numTrials);
    fprintf('Video: %s\n', videoFiles{trialIdx});
    fprintf('Audio: %s\n', audioFiles{trialIdx});
    fprintf('========================================\n');
    
    %% === LOAD VIDEO ===
    videoReader = VideoReader(fullVideoPath);
    frameRate = videoReader.FrameRate;
    totalFrames = videoReader.NumFrames;
    videoDuration = videoReader.Duration;
    
    fprintf('✓ Video loaded: %d frames at %.1f fps (%.2f seconds)\n', ...
            totalFrames, frameRate, videoDuration);
    
    %% === LOAD AUDIO ===
    [audioData, audioSampleRate] = audioread(fullAudioPath);
    
    fprintf('✓ Audio loaded: %d samples at %d Hz\n', ...
            length(audioData), audioSampleRate);
    
    % If stereo, convert to mono
    if size(audioData, 2) > 1
        audioData = mean(audioData, 2);
        fprintf('  Converted stereo to mono\n');
    end
    
    %% === PREPARE AUDIO DELAY ===
    audioDelaySec = audioDelayMs / 1000;  % Convert to seconds
    
    fprintf('✓ Audio will be delayed by %.0f ms\n', audioDelayMs);
    
    %% === PREPARE TIME VECTORS ===
    % Video time vector
    videoTimeVector = (0:(totalFrames-1)) / frameRate;
    
    % Audio time vector (original, no padding yet)
    audioTimeVector = (0:(length(audioData)-1)) / audioSampleRate;
    audioDuration = length(audioData) / audioSampleRate;
    
    % For visualization, we'll pad/trim to match video duration
    if audioDuration > videoDuration
        samplesToKeep = round(videoDuration * audioSampleRate);
        audioDataDisplay = audioData(1:samplesToKeep);
        fprintf('⚠ Audio trimmed to match video duration\n');
    elseif audioDuration < videoDuration
        samplesToAdd = round((videoDuration - audioDuration) * audioSampleRate);
        audioDataDisplay = [audioData; zeros(samplesToAdd, 1)];
        fprintf('⚠ Audio padded with silence to match video duration\n');
    else
        audioDataDisplay = audioData;
    end
    
    % Audio time vector for display
    audioTimeVectorDisplay = (0:(length(audioDataDisplay)-1)) / audioSampleRate;
    
    fprintf('Synchronization: Video=%.3fs, Audio=%.3fs, Delay=%.3fs\n', ...
            videoDuration, length(audioDataDisplay)/audioSampleRate, audioDelaySec);
    
    %% === CREATE AUDIO PLAYER FOR REAL-TIME PLAYBACK ===
    audioPlayer = audioplayer(audioData, audioSampleRate);
    
    fprintf('🔊 Audio player ready for playback\n');
    
    % Add main figure title
    sgtitle('Vocal tract mimicry upon listening to voice emotions through headphones', ...
            'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);
    
    % Reset video to start
    videoReader.CurrentTime = 0;
    
    %% === START PLAYBACK ===
    fprintf('🎬 Starting synchronized playback for trial %d/%d...\n', trialIdx, numTrials);
    fprintf('   Audio will start after %.0f ms delay...\n', audioDelayMs);
    
    % Record start time
    startTime = tic;
    
    % Start video playback immediately
    frameCount = 0;
    audioStarted = false;
    
    while hasFrame(videoReader)
        frameCount = frameCount + 1;
        
        % Read video frame
        videoFrame = readFrame(videoReader);
        
        % Calculate current time
        currentTime = (frameCount - 1) / frameRate;
        elapsedTime = toc(startTime);
        
        % Start audio after delay
        if ~audioStarted && elapsedTime >= audioDelaySec
            play(audioPlayer);
            audioStarted = true;
            fprintf('🔊 Audio playback started at %.3f seconds\n', elapsedTime);
        end
        
        % Calculate waveform progression (only after delay has passed)
        if currentTime >= audioDelaySec
            % We're past the delay - show audio progression from beginning
            audioTime = currentTime - audioDelaySec;
            audioIndexEnd = find(audioTimeVectorDisplay <= audioTime, 1, 'last');
            if isempty(audioIndexEnd)
                audioIndexEnd = 1;
            end
        else
            % Still in delay period - no progression yet
            audioIndexEnd = 0;
            audioTime = 0;
        end
        
        % === TOP PANEL: VIDEO ===
        subplot(2, 1, 1);
        imshow(videoFrame);
        
        % Get trial name for display
        [~, videoName, ~] = fileparts(videoFiles{trialIdx});
        [~, audioName, ~] = fileparts(audioFiles{trialIdx});
        
        % Add trial counter in top-left
        text(50, 50, sprintf('TRIAL %d/%d', trialIdx, numTrials), ...
             'Color', 'cyan', 'FontSize', 16, 'FontWeight', 'bold', ...
             'BackgroundColor', 'black', 'HorizontalAlignment', 'left');
        
        
        title(sprintf('Video: %s | Audio: %s (delayed %dms) | Time: %.2f / %.2f sec', ...
              videoName, audioName, audioDelayMs, currentTime, videoDuration), ...
              'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');
        
        % === BOTTOM PANEL: PROGRESSIVE AUDIO WAVEFORM ===
        subplot(2, 1, 2);
        hold off;
        
        % Plot full waveform in light gray (showing what's coming)
        plot(audioTimeVectorDisplay, audioDataDisplay, 'Color', [0.85 0.85 0.85], 'LineWidth', 1);
        hold on;
        
        % Get y-limits
        yLimits = [min(audioDataDisplay)*1.1, max(audioDataDisplay)*1.1];
        
        % Add shaded region showing the delay period (always visible)
        fill([0, audioDelaySec, audioDelaySec, 0], ...
             [yLimits(1), yLimits(1), yLimits(2), yLimits(2)], ...
             [1, 1, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        
        % Plot revealed portion in blue ONLY if we're past the delay
        if audioIndexEnd > 0
            plot(audioTimeVectorDisplay(1:audioIndexEnd), audioDataDisplay(1:audioIndexEnd), ...
                 'b-', 'LineWidth', 2);
            
            % Add vertical line at current audio time
            plot([audioTime audioTime], yLimits, 'r-', 'LineWidth', 2);
            
            % Add current time marker
            plot(audioTime, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        else
            % Still in delay period - show marker at 0
            plot(0, 0, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        end
        
        xlabel('Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Amplitude', 'FontSize', 12, 'FontWeight', 'bold');
        title(sprintf('Audio Stimulus Waveform (Progressive Display, %dms delay)', audioDelayMs), ...
              'FontSize', 13, 'FontWeight', 'bold');
        
        xlim([0, videoDuration]);
        ylim(yLimits);
        grid on;
        
        % Add legend
        if frameCount == 1
            legend({'Full stimulus (preview)', 'Delay period', 'Revealed (heard)', 'Current audio time'}, ...
                   'Location', 'northeast', 'FontSize', 10);
        end
        
        hold off;
        
        drawnow;
        
        % Progress indicator
        if mod(frameCount, 50) == 0
            fprintf('  Trial %d/%d: Processed %.1f%%\n', ...
                    trialIdx, numTrials, (frameCount/totalFrames)*100);
        end
    end
    
    %% === ENSURE AUDIO COMPLETES ===
    if isplaying(audioPlayer)
        fprintf('⏳ Waiting for audio to complete...\n');
        while isplaying(audioPlayer)
            pause(0.1);
        end
    end
    
    % Stop audio player
    stop(audioPlayer);
    delete(audioPlayer);
    
    %% === TRIAL COMPLETE ===
    fprintf('✅ Trial %d/%d complete! (%d frames, %.2fs)\n', ...
            trialIdx, numTrials, frameCount, videoDuration);
    
    % Hold final frame
    fprintf('📺 Showing final frame for 2 seconds...\n');
    pause(2);
    
    %% === TRANSITION TO NEXT TRIAL ===
    if trialIdx < numTrials
        fprintf('⏭️  Moving to next trial in 2 seconds...\n');
        
        % Transition parameters
        transitionDuration = 2.0;
        dotInterval = 0.5;
        numDots = floor(transitionDuration / dotInterval);
        
        % Clear and prepare for transition screen
        clf(hFig);
        set(hFig, 'Color', 'black');
        ax = axes('Parent', hFig, 'Position', [0 0 1 1]);
        axis(ax, 'off');
        set(ax, 'Color', 'black');
        
        % Create text handles
        text(0.5, 0.6, sprintf('TRIAL %d COMPLETE', trialIdx), ...
            'Units', 'normalized', 'HorizontalAlignment', 'center', ...
            'FontSize', 28, 'FontWeight', 'bold', 'Color', 'white', ...
            'Parent', ax);
        
        text(0.5, 0.5, sprintf('Moving to Trial %d/%d', trialIdx+1, numTrials), ...
            'Units', 'normalized', 'HorizontalAlignment', 'center', ...
            'FontSize', 20, 'FontWeight', 'bold', 'Color', [0.7 0.7 0.7], ...
            'Parent', ax);
        
        % Progress dots
        dotsTextHandle = text(0.5, 0.35, '', ...
            'Units', 'normalized', 'HorizontalAlignment', 'center', ...
            'FontSize', 36, 'FontWeight', 'bold', 'Color', 'cyan', ...
            'Parent', ax);
        
        % Animate dots
        for dotIdx = 1:numDots
            dotString = repmat('● ', 1, dotIdx);
            set(dotsTextHandle, 'String', dotString);
            drawnow;
            pause(dotInterval);
        end
        
        pause(0.1);
    end
    
end % End trial loop

%% === FINAL SUMMARY ===
fprintf('\n========================================\n');
fprintf('🎉 ALL %d TRIALS COMPLETE!\n', numTrials);
fprintf('========================================\n');
fprintf('Ready for presentation! 🎬\n');