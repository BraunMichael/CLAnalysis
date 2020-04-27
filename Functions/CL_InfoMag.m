function [adc_data, ctr_data, spec_data, adc_rate, adc_oversample, pixeltime, frametime, workingdistance, voltage, aperture_size, mag, resolution, p1, p2, scaletext,spec_center,measurement_string,n_frames] = CL_InfoMag(h5filename, scalebarwidth, scalebarlocation_horiz, scalebarlocation_vert)
%% CL Info extraction and magnification calculation
%Michael Braun

% Show the full metadata tree
%h5disp(h5filename);
ctr_data=0;
spec_data=0;

try
    h5info(h5filename,'/measurement/sync_raster_scan');
    measurement_string='sync_raster_scan';
catch
    h5info(h5filename,'/measurement/hyperspec_cl');
    measurement_string='hyperspec_cl';
end
%adc is analog to digital converter, which can read SEM and photodiode
%inputs
adc_data=h5read(h5filename,strcat('/measurement/',measurement_string,'/adc_map'));
%ctr is the photon counter inputs
try ctr_data=h5read(h5filename,strcat('/measurement/',measurement_string,'/ctr_map'));
catch
end
%spec is the spectrometer spectrum output for all pixels
try spec_data=h5read(h5filename,strcat('/measurement/',measurement_string,'/spec_map'));
catch
end


%Get the adc rate (in kHz, analog to digital conversion)
adc_rate=double(h5readatt(h5filename,'/hardware/sync_raster_daq/settings','adc_rate'))/1000;
%Get the dac rate (in Hz, digital to analog conversion)
% dac_rate=double(h5readatt(h5filename,'/hardware/sync_raster_daq/settings','dac_rate'));
%Get the adc oversampling (number of times reading averaged per pixel)
%The multiplcation of adc rate and oversampling gives pixel rate (and 1
%divided by that gives the pixel time
adc_oversample=double(h5readatt(h5filename,'/hardware/sync_raster_daq/settings','adc_oversample'));
%Get the pixel time (in milliseconds)
pixeltime=double(h5readatt(h5filename,strcat('/measurement/',measurement_string,'/settings'),'pixel_time')*1000);
%Get the frame time (in seconds)
frametime=double(h5readatt(h5filename,strcat('/measurement/',measurement_string,'/settings'),'frame_time'));
%Get the spectrometer center wavelength (0 if not connected) (nm)
spec_center=double(h5readatt(h5filename,'/hardware/acton_spectrometer/settings','center_wl'));
%Get the working distance (in mm)
workingdistance=double(h5readatt(h5filename,'/hardware/sem_remcon/settings','WD'));
%Get the voltage (in kV)
voltage=round(double(h5readatt(h5filename,'/hardware/sem_remcon/settings','kV')));
%Get the aperture (in number) and convert to size (in um)
switch (double(h5readatt(h5filename,'/hardware/sem_remcon/settings','select_aperture')));
    case 1
        aperture_size=30;
    case 2
        aperture_size=10;
    case 3
        aperture_size=20;
    case 4
        aperture_size=60;
    case 5
        %Roughly 5 nA
        aperture_size=120;
    case 6
        %Roughly 22 nA
        aperture_size=300;
end

%Check if single frame or many frames
n_frames=double(h5readatt(h5filename,strcat('/measurement/',measurement_string,'/settings'),'n_frames'));

%% Calculate scale

%Get the magnification of the images
mag=double(h5readatt(h5filename,'/hardware/sem_remcon/settings','magnification'));
%Get the number of pixels of the images (assumes square images)
resolution=double(h5readatt(h5filename,strcat('/measurement/',measurement_string,'/settings'),'Nh'));
%Calculate the horizontal field width
%From 3 exponential fitting, referenced with 110 um metal gate at low mag
%and assuming 200 nm diameter Ge/GeSn core/shell NW's at high mag

y0=0.69683;
x0=8.96066;
A1=98.25925;
t1=5501.32045;
A2=811.03158;
t2=256.6487;
A3=15.40327;
t3=42171.19345;
HFW = A1*exp(-(mag-x0)/t1) + A2*exp(-(mag-x0)/t2) + A3*exp(-(mag-x0)/t3) + y0;
%Determine the width per pixel (um/pixel)
pixel_width=HFW/resolution;
%From desired scale bar width, find closest width (in um) for scalebar
scale=round(scalebarwidth*HFW,1,'significant');
%Calculate the width of scalebar in pixels
scale_pix=scale/pixel_width;
%Calculate horizontal start position of scalebar
scale_horiz_start=resolution-scalebarlocation_horiz*resolution-scale_pix;
%Calculate vertical start position of scalebar
scale_vert=resolution-resolution*scalebarlocation_vert;
%Store points for scalebar
p1 = [scale_vert,scale_horiz_start];
p2 = [scale_vert,scale_horiz_start+scale_pix];

%% Determine scale bar text
if scale<1
    scaletext=strcat(num2str(scale*1000),' nm');
else scaletext=strcat(num2str(scale),' $$\mu$$m');
end