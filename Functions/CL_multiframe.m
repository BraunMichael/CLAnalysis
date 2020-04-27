function [] = CL_multiframe(adc_data,frametime,p1,p2,scaletext,Video_Repeats,pauseduration,Show_Filtering,Movie_Save,h5filename_only,Movie_framerate,aperture_size,voltage,pixeltime,adc_rate,adc_oversample)
%% CL Multiframe Analysis
%Michael Braun


%Create datacubes
SEM_SEdet=permute(flip(adc_data(1,:,:,1,:),3),[3 2 5 4 1]);
IR_det=permute(flip(adc_data(2,:,:,1,:),3),[3 2 5 4 1]);

%Eliminate empty frames at the end by checking trace of each frame,
%impossible to be real data with all 0's on diagonal
%Set check number for when end of data is found
k=0;
endindex=1;
for ii=2:size(adc_data,5)
    if k==0
        if trace(SEM_SEdet(:,:,ii))==0
            k=1;
            endindex=ii;
        elseif ii==size(adc_data,5)
            endindex=ii;
        end
    end
end
SEM_SEdet=SEM_SEdet(:,:,1:endindex-1);
IR_det=IR_det(:,:,1:endindex-1);

%% IR Debanding
%Run the 2nd frame (in case 1st is messed up, and we know there are at
%least 2 since this is multiframe) through debanding file
[~, mask]=CL_ImageDeband(IR_det(:,:,2),Show_Filtering);
%Apply debanding to the whole IR stack
IR_det_filtered = CL_DebandMaskApply(IR_det,mask);

%Find the 10th smallest value of IR detector to scale without outliers
IR_det_uni=unique(IR_det_filtered);
IR_det_min=IR_det_uni(round(0.1*length(IR_det_uni)));

multiframemoviefig=figure();
%Maximize figure for better viewing
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

%% Generate the 1st SEM image

%The first dataset from adc_map is traditionally the image from
%the secondary electron detector, SEM_SEdet
ax1=subplot(1,2,1);
colormap(ax1,gray(256))
SEMimage=imagesc(SEM_SEdet(:,:,1));
title(sprintf('SEM Secondary Electron Image - Scale = %s',scaletext),'Interpreter','latex')
axis off
pbaspect([1 1 1])
set(ax1,'Visible','off')
hold on
%plot the scalebar
plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',15);
hold off


%% Generate the 1st IR detector Image

%This is generally plugged into the 2nd analog channel, and is the
%assumption here

ax2=subplot(1,2,2);
colormap(ax2,jet(256))
IRimage=imagesc(IR_det_filtered(:,:,1));
title(sprintf('IR Detector - Scale = %s',scaletext),'Interpreter','latex')
axis off
pbaspect([1 1 1])
caxis([IR_det_min (max(IR_det(:))-0.5*(max(IR_det(:)-IR_det_min)))])
IR_colorbar=colorbar('peer',ax2);
IR_colorbar.Label.String = 'Detector signal';
hold on

%plot the scalebar
plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',15);
hold off
MyBox = uicontrol('style','text');
set(MyBox,'String', ...
    sprintf('Time Elapsed\n%g s\n\nFrame\n%g/%g\n\nAperture =\n%g um\n\nVoltage =\n%g kV\n\nFrame time =\n%.3g s\n\nPixel time =\n%g ms\n\nadc rate =\n%g kHz\n\nadc\nover sample =\n%gx', ...
    frametime*ii,ii,size(SEM_SEdet,3),aperture_size,voltage,frametime,pixeltime,adc_rate,adc_oversample),...
    'FontSize',18,'Units','normalized','Position',[0.481, 0.05, 0.085, 0.8],...
    'HorizontalAlignment','left','BackgroundColor',[1 1 1])
drawnow
if Movie_Save==1
    movieframe=struct('cdata', cell(1,size(SEM_SEdet,3)), 'colormap', cell(1,size(SEM_SEdet,3)));
    movieframe(1)=getframe(multiframemoviefig);
end

%Pause to slow down the movie while viewing in Matlab
pause(pauseduration)

%% Plot the rest of the frames
for kk=1:Video_Repeats
    for ii=2:size(SEM_SEdet,3)
        % Redraw the SEM and IR images
        set(SEMimage, 'CData', SEM_SEdet(:,:,ii));
        set(IRimage, 'CData', IR_det(:,:,ii));
        
        MyBox = uicontrol('style','text');
        set(MyBox,'String', ...
            sprintf('Time Elapsed\n%g s\n\nFrame\n%g/%g\n\nAperture =\n%g um\n\nVoltage =\n%g kV\n\nFrame time =\n%.3g s\n\nPixel time =\n%g ms\n\nadc rate =\n%g kHz\n\nadc\nover sample =\n%gx', ...
            frametime*ii,ii,size(SEM_SEdet,3),aperture_size,voltage,frametime,pixeltime,adc_rate,adc_oversample),...
            'FontSize',18,'Units','normalized','Position',[0.481, 0.05, 0.085, 0.8],...
            'HorizontalAlignment','left','BackgroundColor',[1 1 1])
        drawnow
        if Movie_Save==1
            if kk==1
                movieframe(ii)=getframe(multiframemoviefig);
            end
        end
        %Pause to slow down the movie
        pause(pauseduration)
    end
end

if Movie_Save==1
    avifilename=strcat(h5filename_only,'.avi');
    delete(avifilename)
    moviefile=VideoWriter(avifilename);
    moviefile.FrameRate = Movie_framerate;
    open(moviefile)
    writeVideo(moviefile,movieframe);
    close(moviefile);
end