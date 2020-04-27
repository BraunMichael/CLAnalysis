function CL_specdraw(~,spec_data_corr,CLspec_plot)

global CLspectra_permuted ellipseHandle mask_single

mask_single=createMask(ellipseHandle);
spec_selected=zeros(nnz(mask_single),size(spec_data_corr,3));
kk=1;
for ii=1:size(mask_single,1)
    for jj=1:size(mask_single,2)
        if mask_single(ii,jj)==0
        else spec_selected(kk,:)=spec_data_corr(ii,jj,:).*(mask_single(ii,jj));
            kk=kk+1;
        end
    end
end
CLspectra=mean(spec_selected,1);
CLspectra_permuted=(permute(CLspectra,[2 1]));
set(CLspec_plot, 'YData', CLspectra_permuted);
end