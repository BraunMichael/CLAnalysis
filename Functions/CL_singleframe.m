function [SEM_SEdet, IR_det] = CL_singleframe(adc_data,p1,p2,scaletext,colormap_editor_enabled)
%% CL single frame analysis
%Michael Braun

%% Generate the images

%The first dataset from adc_map is traditionally the image from
%the secondary electron detector, SEM_SEdet
SEM_SEdet=permute(flip(adc_data(1,:,:),3),[3 2 1]);
%The 2nd dataset from adc_map is traditionally an analog detector,
%typically the IR detector, and is the assumption here
IR_det=permute(flip(adc_data(2,:,:),3),[3 2 1]);

figure()
%Maximize figure for better viewing
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

ax1=subplot(1,2,1);
colormap(ax1,gray)
image(SEM_SEdet,'CDataMapping','scaled')
title(sprintf('SEM Secondary Electron Image - Scale = %s',scaletext),'Interpreter','latex')
axis off
pbaspect([1 1 1])
set(ax1,'Visible','off')
if colormap_editor_enabled==1
    colormapeditor
else
end
hold on
%plot the scalebar
plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',15);
hold off

ax2=subplot(1,2,2);
colormap(ax2,jet)
image(IR_det,'CDataMapping','scaled')
title(sprintf('IR Detector - Scale = %s',scaletext),'Interpreter','latex')
axis off
pbaspect([1 1 1])
hold on
%plot the scalebar
plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',15);
hold off




