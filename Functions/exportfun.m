function exportfun(~,~)
%can maybe use cirpos(colorindex) in savefun to create matrix of positions,
%then replot the image (without the buttons) and draw the circles with no
%ellipse, save it, and delete it
global h5filename_only dataout
% cirpos=ellipseHandle.getPosition;
% rectangle('Position',cirpos,'Curvature',[1 1],'EdgeColor',char(circcolors(colorindex)),'LineWidth',3);
% NumberSpectraPoints=nnz(mask_single);
% fprintf('The number of spectra points averaged is %g\n',NumberSpectraPoints)
pngfilename_only_circ=strcat(h5filename_only,'_colorcircles','.png');
pngfilename_circ=strcat(pngfilename_only_circ,'.png');
delete(pngfilename_circ)
print(pngfilename_only_circ,'-dpng','-r100')
datafilename=strcat(h5filename_only,'_colorcircles','.txt');
writetable(dataout,datafilename)
drawnow;
end