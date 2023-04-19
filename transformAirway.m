clear
addpath('/PowerVault/src/MATLAB/nifti');
folder = '/PowerVault/Airways/data/';
d = dir(folder);
for idx = 3:length(d)
    if d(idx).isdir
        subject = d(idx).name(1:6)
        scan = d(idx).name(8:12)
        folderBase = ['/PowerVault/IPF_Study/data/',subject,'/NIFTI/',scan,'/B50f_600um/'];
        tform = affine3d([0 1 0 0; 1 0 0 0; 0 0 -1 0; 1 1 1 1]);
        refscanfile = [folderBase,subject,'_',scan,'_100IN.nii.gz'];
        refscan = load_untouch_nii(refscanfile);
        offset_x = refscan.hdr.hist.qoffset_x;
        offset_y = refscan.hdr.hist.qoffset_y;
        offset_z = refscan.hdr.hist.qoffset_z;
        tform.T(4,:) = tform.T(4,:).*[offset_x,offset_y,offset_z,1];
        img = analyze75read([folder,d(idx).name,'/ZUNU_vida-aircolor']);
        img2 = imwarp(img,tform);
        %refscan.Datatype=class(img);
        refscan.img = img2;
        save_untouch_nii(refscan,[folder,subject,'_',scan,'/aircolor.nii']);
        gzip([folder,subject,'_',scan,'/aircolor.nii']);
        delete([folder,subject,'_',scan,'/aircolor.nii']);
   end
end