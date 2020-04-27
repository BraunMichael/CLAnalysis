function CL_specdraw(src,spec_data_corr,CLspec_plot,ellipseHandle)
% hObject    handle to end_segmenting_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mask_single=createMask(ellipseHandle);
% NumberSpectraPoints=nnz(mask_single);
% fprintf('%g averaged points in the spectrum\n',NumberSpectraPoints)
spec_selected=zeros(size(spec_data_corr));
for ii=1:size(mask_single,1)
    for jj=1:size(mask_single,2)
        spec_selected(ii,jj,:)=spec_data_corr(ii,jj,:).*(mask_single(ii,jj));
    end
end
CLspectra=mean(mean(spec_selected,1),2);
CLspectra_permuted=(permute(CLspectra,[3 2 1]));
set(CLspec_plot, 'YData', CLspectra_permuted);
%     drawnow;  %# Give the button callback a chance to interrupt the opening function
% guidata(hObject, handles);
end