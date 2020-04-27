function [filtered_Image_stack] = CL_DebandMaskApply(Image_stack,mask)
%% CL Deband Mask Apply
%Michael Braun

%Preallocate array
filtered_Image_stack=zeros(size(Image_stack));
for ii=1:size(Image_stack,3)
%% Calculate fft for filtering
imFft = fftshift(fft2(double(Image_stack(:,:,ii)))); % move zero frequency to center of spectrum

%Calculate the filtered image
filtered_Image_stack(:,:,ii)=real(ifft2(ifftshift(imFft .* (mask))));
end