function CL_specdraw(~,spec_data_corr,CLspec_plot)

global CLspectra_permuted ellipseHandle mask_single

mask_single=createMask(ellipseHandle);
% NumberSpectraPoints=nnz(mask_single);
% fprintf('%g averaged points in the spectrum\n',NumberSpectraPoints)
spec_selected=zeros(size(spec_data_corr));
% kk=1;
for ii=1:size(mask_single,1)
    for jj=1:size(mask_single,2)
        %         if mask_single(ii,jj)==0
        spec_selected(ii,jj,:)=spec_data_corr(ii,jj,:).*(mask_single(ii,jj));
    end
end
CLspectra=mean(mean(spec_selected,1),2);
CLspectra_permuted=(permute(CLspectra,[3 2 1]));
set(CLspec_plot, 'YData', CLspectra_permuted);
end