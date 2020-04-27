%% CL Analysis
%Michael Braun

clear; close all; clc; format shortG; warning('off','all')
set(0,'defaultaxesfontname','arial')
set(0,'DefaultAxesFontSize',24)

global h5filename_only

%Set the width of the scale bar as fraction of image width
scalebarwidth=0.2;
%Set the horizontal end location of the scale bar as a fraction of image width
scalebarlocation_horiz=0.1;
%Set the vertical location of the scale bar as a fraction of image width
scalebarlocation_vert=0.05;
%Enable (1) or disable (0) colormap editor window popping up upon running
%code
colormap_enabled=0;
%Show raw IR image?
Show_raw=0;
%Show the intermediate filtering step (1) or not (0)
Show_Filtering=0;
%Save file?
Save_file=1;
%Delay between frames of video from multiframe file (s)
%Only while viewing in MATLAB!
pauseduration=0;
%Number of times to repeat video if multiframe
Video_Repeats=1;
%Save Movie?
Movie_Save=1;
%Movie Framerate
Movie_framerate=5;

%% Retrieve the h5 data set
%double is used to ensure data type compatibility
[h5filename, folderpath] = uigetfile('*.h5');
cd(folderpath)
[~, h5filename_only, ~]=fileparts(h5filename);

% Show the full metadata tree
%h5disp(h5filename);

%Get all the info from the h5 file and calculate the scale
[adc_data, ctr_data, spec_data, adc_rate, adc_oversample, pixeltime, frametime, workingdistance, voltage, aperture_size, mag, resolution, p1, p2, scaletext, spec_center,measurement_string, n_frames] = CL_InfoMag(h5filename, scalebarwidth, scalebarlocation_horiz, scalebarlocation_vert);
spec_data_corr=double(permute(flip(spec_data,3),[3 2 1]));
%% Deal with multiple frame data sets


%Multi frame case
if n_frames>1
    CL_multiframe(adc_data,frametime,p1,p2,scaletext,Video_Repeats,pauseduration,Show_Filtering,Movie_Save,h5filename_only,Movie_framerate,aperture_size,voltage,pixeltime,adc_rate,adc_oversample)
    
    %Single frame case
else
    %The first dataset from adc_map is traditionally the image from
    %the secondary electron detector, SEM_SEdet
    SEM_SEdet=permute(flip(adc_data(1,:,:),3),[3 2 1]);
    %The 2nd dataset from adc_map is traditionally an analog detector,
    %typically the IR detector, and is the assumption here
    IR_det=permute(flip(adc_data(2,:,:),3),[3 2 1]);
    
    if Show_raw==0
    else
    %Show the Original IR image
    figure;
    colormap jet(256)
    image(IR_det,'CDataMapping','scaled')
    title('Raw IR Image','Interpreter','latex')
    axis off
    pbaspect([1 1 1])
    end
    
    %filter any banding from the IR image
    [IR_det_filtered, mask, FFT_Image]=CL_ImageDeband(IR_det,Show_Filtering);
    
    %Remove striping
    [IR_det_filtered_destripe] = CL_ImageDestripe(IR_det_filtered);
    
    %Subtract off the background
    [IR_det_filtered_destripe_subtracted, ~] = CL_ImageBackgroundSubtract(IR_det_filtered_destripe);
    
    %% Generate the images
    
    %Check if there is counter data
    if max(ctr_data(:))==min(ctr_data(:))
    else
        ctr_0_data=permute(flip(ctr_data(1,:,:),3),[3 2 1]);
        ctr_1_data=permute(flip(ctr_data(2,:,:),3),[3 2 1]);
        
        figure()
        %Maximize figure for better viewing
        pause(0.00001);
        frame_h = get(handle(gcf),'JavaFrame');
        set(frame_h,'Maximized',1);
        
        ax1=subplot(1,2,1);
        colormap(ax1,gray(256))
        image(ctr_0_data,'CDataMapping','scaled')
        title(sprintf('Photon Counter 1 - Scale = %s',scaletext),'Interpreter','latex')
        axis off
        pbaspect([1 1 1])
        set(ax1,'Visible','off')
        if colormap_enabled==1
            colormapeditor
        else
        end
        hold on
        %plot the scalebar
        plot([p1(2),p2(2)],[p1(1),p2(1)],'Color',[0.999999 0.999999 0.999999],'LineWidth',15);
        hold off
        
        ax2=subplot(1,2,2);
        colormap(ax2,gray(256))
        image(ctr_1_data,'CDataMapping','scaled')
        title(sprintf('Photon Counter 2 - Scale = %s',scaletext),'Interpreter','latex')
        axis off
        pbaspect([1 1 1])
        hold on
        %plot the scalebar
        plot([p1(2),p2(2)],[p1(1),p2(1)],'Color',[0.999999 0.999999 0.999999],'LineWidth',15);
        hold off
        
        %Put some scan parameters in the middle of figures
        MyBox = uicontrol('style','text');
        set(MyBox,'String', ...
            sprintf('Aperture =\n%g um\n\nVoltage =\n%g kV\n\nWD =\n%g mm\n\nFrame time =\n%.3g s\n\nPixel time =\n%g ms\n\nResolution =\n%gx%g\n\nadc rate =\n%g kHz\n\nadc\nover sample =\n%gx', ...
            aperture_size,voltage,workingdistance,frametime,pixeltime,resolution,resolution,adc_rate,adc_oversample),...
            'FontSize',18,'Units','normalized','Position',[0.481, 0.05, 0.085, 0.8],...
            'HorizontalAlignment','left','BackgroundColor',[1 1 1])
        
        
    end
    
    
    
    figure()
    %Maximize figure for better viewing
    pause(0.00001);
    frame_h = get(handle(gcf),'JavaFrame');
    set(frame_h,'Maximized',1);
    
    ax1=subplot(1,2,1);
    colormap(ax1,gray(256))
    image(SEM_SEdet,'CDataMapping','scaled')
    title(sprintf('SEM Secondary Electron Image - Scale = %s',scaletext),'Interpreter','latex')
    axis off
    pbaspect([1 1 1])
    set(ax1,'Visible','off')
    if colormap_enabled==1
        colormapeditor
    else
    end
    hold on
    %plot the scalebar
    plot([p1(2),p2(2)],[p1(1),p2(1)],'Color',[0.999999 0.999999 0.999999],'LineWidth',15);
    hold off
    
    ax2=subplot(1,2,2);
    colormap(ax2,jet(256))
    image(IR_det_filtered_destripe_subtracted,'CDataMapping','scaled')
    title(sprintf('IR Detector - Scale = %s',scaletext),'Interpreter','latex')
    axis off
    pbaspect([1 1 1])
    caxis([0 max(IR_det_filtered_destripe_subtracted(:))])
    IR_colorbar=colorbar('peer',ax2);
    IR_colorbar.Label.String = 'Detector signal above average background';
    hold on
    %plot the scalebar
    plot([p1(2),p2(2)],[p1(1),p2(1)],'Color',[0.999999 0.999999 0.999999],'LineWidth',15);
    hold off
    
    %Put some scan parameters in the middle of figures
    MyBox = uicontrol('style','text');
    set(MyBox,'String', ...
        sprintf('Aperture =\n%g um\n\nVoltage =\n%g kV\n\nWD =\n%g mm\n\nFrame time =\n%.3g s\n\nPixel time =\n%g ms\n\nResolution =\n%gx%g\n\nadc rate =\n%g kHz\n\nadc\nover sample =\n%gx', ...
        aperture_size,voltage,workingdistance,frametime,pixeltime,resolution,resolution,adc_rate,adc_oversample),...
        'FontSize',18,'Units','normalized','Position',[0.481, 0.05, 0.085, 0.8],...
        'HorizontalAlignment','left','BackgroundColor',[1 1 1])
    %Save file
    if Save_file==0
    else
    pngfilename=strcat(h5filename_only,'.png');
    delete(pngfilename)
    print(pngfilename,'-dpng','-r100')
    end
    
    %Check if there is spectrum data
    if spec_data==0
    else
        CLspectra=mean(mean(spec_data,3),2);
        %Converted to wavelength from pixel value, specific for 800 nm
        %center wavelength, slightly different at other center wavelengths,
        %take an identical spectrum in spectrometer software to compare!
        wavelength=linspace(spec_center-277.03638,spec_center+279.2435,length(CLspectra));
        figure();
        plot(wavelength,CLspectra','k')
        title('Frame Averaged Spectrum','Interpreter','latex')
        xlabel('Wavelength (nm)','Interpreter','latex')
        ylabel('Intensity','Interpreter','latex')
        axis([min(wavelength) max(wavelength) -inf inf])
        
        
    end
end
fprintf('%s\n',h5filename)

