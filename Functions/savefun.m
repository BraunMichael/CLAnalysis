function savefun(~,~)

global cirpos circcolors colorindex CLspectra_permuted ellipseHandle wavelength h5filename_only mask_single
cirpos=ellipseHandle.getPosition;
rectangle('Position',cirpos,'Curvature',[1 1],'EdgeColor',char(circcolors(colorindex)),'LineWidth',3);
NumberSpectraPoints=nnz(mask_single);
fprintf('The number of spectra points averaged is %g\n',NumberSpectraPoints)
pngfilename_only_circ=strcat(h5filename_only,'_colorcircles','.png');
pngfilename_circ=strcat(pngfilename_only_circ,'.png');
delete(pngfilename_circ)
print(pngfilename_only_circ,'-dpng','-r100')
Intensity=CLspectra_permuted;
Wavelength=wavelength';
NumberSpectraAveraged=ones(size(Wavelength)).*NumberSpectraPoints;
dataout=table(Wavelength,Intensity,NumberSpectraAveraged);
datafilename=strcat(h5filename_only,'_',char(circcolors(colorindex)),'.txt');
writetable(dataout,datafilename)
colorindex=colorindex+1;
if colorindex==9
    disp('You have reached the maximum number of circles you can draw on one plot, please start a new plot')
    disp('Circle color is now starting over')
    colorindex=1;
    return
end
drawnow;

end