
%% CL Batch Convert Single SEM only
%Michael Braun

clear; close all; clc; format shortG; warning('off','all')
set(0,'defaultaxesfontname','arial')
set(0,'DefaultAxesFontSize',24)

%Set the width of the scale bar as fraction of image width
scalebarwidth=0.2;
%Set the horizontal end location of the scale bar as a fraction of image width
scalebarlocation_horiz=0.1;
%Set the vertical location of the scale bar as a fraction of image width
scalebarlocation_vert=0.05;
%Enable (1) or disable (0) colormap editor window popping up upon running
%code
colormap_enabled=0;
%Show the intermediate filtering step (1) or not (0)
Show_Filtering=1;
%Delay between frames of video from multiframe file (s)
pauseduration=0.3;
%Number of times to repeat video if multiframe
Video_Repeats=1;

%% Retrieve the h5 data set
%double is used to ensure data type compatibility

%Select folder containing all the files
folderpath=uigetdir();
%Set this folder as current directory
cd(folderpath);

% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(folderpath)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', folderpath);
    uiwait(warndlg(errorMessage));
    return;
end

% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(folderpath, '*.h5');
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    h5filename = fullfile(folderpath, baseFileName);
    [~, h5filename_only, ~]=fileparts(h5filename);
    
    %Get all the info from the h5 file and calculate the scale
    [adc_data, adc_rate, adc_oversample, pixeltime, frametime, workingdistance, voltage, aperture_size, mag, resolution, p1, p2, scaletext] = CL_InfoMag(h5filename, scalebarwidth, scalebarlocation_horiz, scalebarlocation_vert);
    
    %% Deal with multiple frame data sets
    
    %Check if single frame or many frames
    n_frames=double(h5readatt(h5filename,'/measurement/sync_raster_scan/settings','n_frames'));
    
    %Multi frame case
    if n_frames>1
        fprintf('%s contains multiple frames, moving to subfolder multiple\n',h5filename_only)
        movefile(h5filename,multiframe_path)
        
        %Single frame case
    else
        %The first dataset from adc_map is traditionally the image from
        %the secondary electron detector, SEM_SEdet
        SEM_SEdet=permute(flip(adc_data(1,:,:),3),[3 2 1]);
        
        %% Generate the image
        figure()
        %Maximize figure for better viewing
        pause(0.00001);
        frame_h = get(handle(gcf),'JavaFrame');
        set(frame_h,'Maximized',1);
        colormap gray(256)
        image(SEM_SEdet,'CDataMapping','scaled')
        title(sprintf('SEM - Mag = %g',mag),'Interpreter','latex')
        axis off
        pbaspect([1 1 1])
        print(sprintf('SEM - Mag = %g',round(mag)),'-dpng','-r100')
        fprintf('%s\n',h5filename_only);
        
    end
end


