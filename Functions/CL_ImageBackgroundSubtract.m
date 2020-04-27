function [Background_subtracted_image, background_mask] = CL_ImageBackgroundSubtract(Image)
%% CL Image Background Subtraction
%Michael Braun

BackgroundSubtractfigure=figure;
colormap jet(256)
image(Image,'CDataMapping','scaled')
title('Background Subtraction','Interpreter','latex')
axis off
pbaspect([1 1 1])

%Shift background intensity to 0 by selecting background areas
%Maximize figure for better viewing
pause(0.01);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

%Have user select background regions of image
Background_handle=imellipse(gca, [ length(Image)/2 length(Image)/2 length(Image)/8 length(Image)/8 ] );
Background_handle.setFixedAspectRatioMode( '1' )
questdlg({'Drag the circle to select a background area, and to resize.' 'When finished, double click on the circle to generate a mask from the area within.'},'Masking Instructions','OK','Cancel','OK');
wait(Background_handle);
background_mask=createMask(Background_handle);

%Select multiple points, using s as break point
s=0;
while s==0
    button=questdlg('Do you want to select more areas as the background?','Continue selecting?','yes','no','yes');
    switch button
        case 'yes'
            %Have user select banding peak in FFT
            Background_handle=imellipse(gca, [ length(Image)/2 length(Image)/2 length(Image)/8 length(Image)/8 ] );
            Background_handle.setFixedAspectRatioMode( '1' )
            wait(Background_handle);
            background_mask=background_mask+createMask(Background_handle);
            s=0;
        case 'no'
            s=1;
    end
end

%Close the figure used for subtracting
close(BackgroundSubtractfigure)
%Calculate the background
det_background=mean2(nonzeros(Image.*background_mask));
%Subtract the background
Background_subtracted_image=Image-det_background;
