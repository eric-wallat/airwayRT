clear
lidx = 1;
d = dir('./data/');
for idx = 3:2:length(d)
    if d(idx).isdir
        %% Read in input data %%
        subject = d(idx).name(1:6)
        prescan = d(idx).name(8:12);
        postscan = d(idx+1).name(8:12);
        prefolder = ['./data/',subject,'_',prescan,'/'];
        postfolder = ['./data/',subject,'_',postscan,'/'];
        dose = niftiread(['/PowerVault/IPF_Study/data/',subject,'/NIFTI/RT/B50f_600um/Dose.nii.gz']);
        jacratio = niftiread(['/PowerVault/IPF_Study/working/',subject,'/LER4D/',prescan,'/B50f_600um/',...
            subject,'_',postscan,'_',prescan,'_Ratio.nii.gz']);
        jacratio = double(jacratio);
        preairway = niftiread([prefolder,'aircolor.nii.gz']);
        postairway = niftiread([postfolder,'aircolor_warped.nii.gz']);
        
        %% Create list matching pre/post airway pairs %%
        pretermlist = findTerminalAirways(prefolder,preairway,postairway);
        pretermlist(any(isnan(pretermlist),2),:) = [];
        
        %% Calculate segment resistances and luminal area changes %%
        [rlut,aichange] = resistanceCalc2(subject,prescan,postscan,pretermlist,preairway,postairway,dose);
        
        %% Perform nearest neighbor search to calc JacRatio for each terminal airway %%
        terminalJRmask = nnJacRatio(preairway,jacratio,rlut);
        
        % Specify region of low dose to investigate. I used regions <5Gy %
        lowdose = dose;
        lowdose(dose<=5) = 1;
        lowdose(dose>5) = 0;
        for tidx = 1:length(rlut)
            
            ratiomask = terminalJRmask;
            ratiomask(terminalJRmask==rlut(tidx,1)) = 1;
            ratiomask(terminalJRmask~=rlut(tidx,1)) = 0;
            tempJR = jacratio.*ratiomask.*lowdose;
            rlut(tidx,5) = mean(nonzeros(tempJR));

        end
        rluts{lidx} = rlut;
        aichanges{lidx} = aichange;
        lidx = lidx + 1;
    end
end

tidx = 1;
for idx = 3:2:length(d)
    if d(idx).isdir
        subject = d(idx).name(1:6)
            writetable(array2table(rluts{tidx}),'resistances.xlsx','Sheet',subject);
            writetable(array2table(aichanges{tidx}),'dichanges_vols.xlsx','Sheet',subject);
            tidx = tidx + 1;
    end
end