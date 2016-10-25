function mRespMat = generate_stimulus()

%%  %----------------------------------------------------------------------
    %                       Visual Setup
    %----------------------------------------------------------------------
    % Here we call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens');
    contrast = 1;

    % Get color codes for black white and gray
    % try different screen numbers if not working.
     screenNumber = max(screens);
    %screenNumber = 0;
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    gray=round((white+black)/2);
    if gray == white
        gray=white / 2;
    end
    inc=contrast*(white-gray);

%%  %----------------------------------------------------------------------
    %                       Window Setup
    %----------------------------------------------------------------------
    % Open an on screen window using PsychImaging
    %[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [],...
       [0 0 600 600]);
    [xCenter, yCenter] = RectCenter(windowRect);
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);

    % Measure the vertical refresh rate of the monitor
    ifi = Screen('GetFlipInterval', window);
    
    %numSecs = 0.2;
    waitframes = 1;
    Screen('Flip', window);  

    % Retreive the maximum priority number
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);



%%  %----------------------------------------------------------------------
    %                       Parameters and Data
    %----------------------------------------------------------------------
    nTrials = 100;
    nObjectsMoving = 600;
    nObjectsStill = 300;
    vVelocity = load('run_speed.csv');
    trialLength = 500;


    % Wait for user input to continue
    DrawFormattedText(window, 'Press Any Key to Begin','center','center', black );
    vbl = Screen('Flip', window);
    KbStrokeWait;

    Priority(topPriorityLevel)

%%  %----------------------------------------------------------------------
    %                       Run Trials
    %----------------------------------------------------------------------

    for trial = 1:nTrials
        
        globalInd = (1:trialLength)+floor(rand()*(length(vVelocity)-trialLength));
        globalSpeed = vVelocity(globalInd).*0.5;
        globalPos = cumsum(globalSpeed);
        vObjectSpeed = [10.*rand(1,nObjectsMoving) zeros(1,nObjectsStill)];
        vObjectSpeed = vObjectSpeed(randperm(length(vObjectSpeed)));
        vObjectStartx = 20.*screenXpixels.*rand(1,nObjectsMoving+nObjectsStill)-19*screenXpixels;
        vObjectStarty = screenYpixels.*rand(1,nObjectsMoving+nObjectsStill);
        vObjectSizex = rand(1,nObjectsMoving+nObjectsStill);
        vObjectSizey = rand(1,nObjectsMoving+nObjectsStill);
        vObjectColor = rand(1,nObjectsMoving+nObjectsStill);
        vObjectAngle = 2.*pi.*rand(1,nObjectsMoving+nObjectsStill);
        for j = 1:trialLength

        % initialization
            for k = 1:(nObjectsMoving+nObjectsStill);

                dumObj = CenterRectOnPointd([0 0 100*vObjectSizex(k) 100*vObjectSizey(k)],...
                    vObjectStartx(k)+vObjectSpeed(k)*cos(vObjectAngle(k))*j+globalPos(j),...
                    mod( vObjectStarty(k)+vObjectSpeed(k)*sin(vObjectAngle(k))*j,round(screenYpixels*1.5)));

                Screen('FillRect', window, [vObjectColor(k) vObjectColor(k) vObjectColor(k)], dumObj);
            end
        
            Screen('Flip',window);
            im = Screen('GetImage',window);
            if ~exist(['trial' int2str(trial)],'dir')
                mkdir(['trial' int2str(trial)])
            end
            imwrite(im,['./trial' int2str(trial) '/test' int2str(j),'.jpg']);
            WaitSecs(0.001);


        end % j
        fID = fopen(['trial' int2str(trial) '/globalSpeed.csv'],'w');
        fprintf(fID,'%f\t',globalSpeed);
        fclose(fID);
     end % trial

       



    sca;