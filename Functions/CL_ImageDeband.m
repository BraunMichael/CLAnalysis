function [filtered_Image, mask, FFT_Image] = CL_ImageDeband(Image,Show_Filtering)
%% CL Image deband
%Michael Braun

%% Calculate and show fft for filtering
imFft = fftshift(fft2(double(Image))); % move zero frequency to center of spectrum
FFTfilterfigure=figure;
%Save FFT image
FFT_Image=log(1+abs(imFft));
imagesc(FFT_Image);
pbaspect([1 1 1])
colormap jet

%Maximize figure for better viewing
pause(0.01);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

%Have user select banding peak in FFT
ellipseHandle=imellipse(gca, [ length(Image)/2 length(Image)/2 length(Image)/20 length(Image)/20 ] );
ellipseHandle.setFixedAspectRatioMode( '1' )
questdlg({'Drag the circle to move over banding spots and to resize' 'When finished, double click on the circle to generate a mask from the area within'},'Masking Instructions','OK','Cancel','OK');

wait(ellipseHandle);
mask_single=createMask(ellipseHandle);

%Select multiple points, using s as break point
s=0;
while s==0
    button=questdlg('Do you want to mask more ares (not mirror of point just selected)?','Continue selecting?','yes','no','yes');
    switch button
        case 'yes'
            %Have user select banding peak in FFT
            ellipseHandle=imellipse(gca, [ length(Image)/2 length(Image)/2 length(Image)/20 length(Image)/20 ] );
            ellipseHandle.setFixedAspectRatioMode( '1' )
            wait(ellipseHandle);
            mask_single=mask_single+createMask(ellipseHandle);
            s=0;
        case 'no'
            s=1;
    end
end

%Create the mirrored mask
mask=imcomplement(mask_single+rot90(mask_single,2));
close(FFTfilterfigure)

%Calculate the final filtered image
filtered_Image=real(ifft2(ifftshift(imFft .* (mask))));

if Show_Filtering==1
%% Show 4 pane figure with initial, FFT, filter, and final image
figure;
%Maximize figure for better viewing
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

ax1=subplot(2,2,1);
colormap(ax1,jet)
imagesc(Image)
title('IR Image','Interpreter','latex')
axis off
pbaspect([1 1 1])
set(ax1,'Visible','off')

ax2=subplot(2,2,2);
colormap(ax2,jet)
imagesc(log(1+abs(imFft)))
title('FFT of IR Image','Interpreter','latex')
axis off
pbaspect([1 1 1])
set(ax2,'Visible','off')

ax3=subplot(2,2,3);
colormap(ax3,gray)
imagesc(mask)
title('FFT Mask','Interpreter','latex')
axis off
pbaspect([1 1 1])
set(ax3,'Visible','off')

ax4=subplot(2,2,4);
colormap(ax4,jet)
imagesc(filtered_Image)
title('Filtered IR Image','Interpreter','latex')
axis off
pbaspect([1 1 1])
set(ax4,'Visible','off')

%% Show the final figure large
figure
colormap jet
imagesc(filtered_Image)
title('Filtered IR Image','Interpreter','latex')
axis off
pbaspect([1 1 1])
else
end