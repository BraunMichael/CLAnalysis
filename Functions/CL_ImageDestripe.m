function [Image_destriped] = CL_ImageDestripe(Image)
%% CL Image destripe testing
%Michael Braun

Image_destriped=zeros(size(Image));
Image_median=median(Image(:));
for ii=1:length(Image)
Image_destriped(ii,:)=Image(ii,:)-(median(Image(ii,:))-Image_median);
end

%Alternate method from Gwyddion
%Median difference shifts the lines so that the median of differences (between vertical neighbour pixels) becomes zero,
%instead of the difference of medians. Therefore it better preserves large features while it is more sensitive to completely bogus lines.


% figure;
% %Maximize figure for better viewing
% pause(0.00001);
% frame_h = get(handle(gcf),'JavaFrame');
% set(frame_h,'Maximized',1);
% 
% ax1=subplot(1,2,1);
% colormap(ax1,jet(256))
% imagesc(Image)
% title('IR Image','Interpreter','latex')
% axis off
% pbaspect([1 1 1])
% set(ax1,'Visible','off')
% 
% ax2=subplot(1,2,2);
% colormap(ax2,jet(256))
% imagesc(Image_destriped)
% title('Destriped IR Image','Interpreter','latex')
% axis off
% pbaspect([1 1 1])
% set(ax2,'Visible','off')