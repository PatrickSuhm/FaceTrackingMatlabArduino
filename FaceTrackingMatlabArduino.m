%---------------------------------------------------------%
% This Matlab script should get you started with face	  %
% tracking. To use it, you need an Arduino and a webcam,  %
% that is mounted on a pan/tilt platform. The two servos  %
% of the pan/tilt platform have to be connected to two    %
% digital pins of the Arduino. To keep things simple, the %
% "Matlab Support Package for Arduino" is used, so there  %
% is no need to program the Arduino, just install the     %
% support package in Matlab and connect the Arduino to    % 
% you computer via USB.                                   %
% This Youtube tutorial shows the results:                %                 
% https://www.youtube.com/watch?v=X1eb78jfWw4             %
% Author: Patrick Suhm                                    %
%---------------------------------------------------------%

clear all 
close all
clc

if ~exist('a')
% instantiate arduino object
a = arduino('COM5','Uno')
% attach servos for tilt and rotation at your prefered pins
spin=servo(a, 3);       
tilt=servo(a, 5);
end

% set the servos to middle position at startup (depends on you hardware)
ti_mid=0.3;
sp_mid=0.5;
writePosition(tilt,ti_mid);
writePosition(spin,sp_mid);  

% initial servo positions
sp_val=0.5;     
ti_val=0.5;
% set target point to the middle of the image (depends on the image size)    
x_mid=80;
y_mid=60;

% PI controller variables
integ=[0;0];
% PI constants for spin
kps=0.005; 
kis=0.005;
% PI constants for tilt
kpt=0.005; 
kit=0.005;

% use this to find out about your camera --> info.DeviceInfo.SupportedFormats
info = imaqhwinfo('winvideo'); 

% capture the video frames using the videoinput function
% you have to replace the resolution & your installed adapter name.
% specify your resolution here, second arg is internal cam (2) or usb cam (1)
obj = imaq.VideoDevice('winvideo',1,'MJPG_160x120');    

% counter value
idx=0;      

% start the videoplayer
videoplayer = vision.VideoPlayer; 

% start the timer
tic;

% run for 100 loops
while(idx < 100)
    idx=idx+1;
    % grab an image for processing
    frame = step(obj);        
    
    % detect the face with Viola-Jones algorithm
    detection = vision.CascadeObjectDetector();
    
    % find bounding boxes
    bboxes = step(detection, frame);
    
    if ~isempty(bboxes)
        % draw bounding boxes
        frame = insertObjectAnnotation(frame, 'rectangle', bboxes, 'Person','TextBoxOpacity', 0.4, 'FontSize', 10);
    end
    
    % show the image
    step(videoplayer, frame);               
    
    % PI servo control
    if exist('bboxes')
        if ~isempty(bboxes)
          
            % error vector
            e=[ x_mid-(bboxes(1)+bboxes(3)/2);...
                y_mid-(bboxes(2)+bboxes(4)/2)];
            % scaling
            e=e/10;  
            
            % control the spin servo
            % integral part and anti wind up for the spin servo
            if( sp_val>0.1 && sp_val<0.9 )          
                integ(1)=integ(1)+e(1);
            end
            % PI controller for the spin servo    
            sp_val=sp_mid+kps*e(1)+kis*integ(1);
            % write the new servo position for the spin servo
            if ( sp_val>0.1 && sp_val<0.9 )
                writePosition(spin,sp_val); 
            end
            
            % control the tilt servo
            % integral part and anti wind up for the tilt servo
            if( ti_val>0.1 && ti_val<0.9 )          
                integ(2)=integ(2)+e(2);
            end
            % PI controller for the tilt servo 
            ti_val=ti_mid-kpt*e(2)-kit*integ(2);
            % write the new servo position for the tilt servo
            if ( ti_val>0.1 && ti_val<0.9 )
                writePosition(tilt,ti_val);
            end          
        end
    end 
 
    looptime(idx)=toc; 
 
    % use a loop time that is bounded from below (improves PI controller)
    % if your computer is faster, you can go below 150ms
    while(looptime(idx)<0.15) 
        looptime(idx)=toc;
    end
    % start timer   
    tic;
end
 
% set the servos to middle position at the end
writePosition(spin,sp_mid);  
writePosition(tilt,ti_mid);

% clean up
clear obj;
release(videoplayer);
disp('done')

