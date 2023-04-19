function [rlut,aichange] = resistanceCalc2(sub,prescan,postscan,termlist,preairway,postairway,dose)

folder = ['./data/',sub,'_',prescan,'/'];
f = xml2struct([folder,'ZUNU_vida-xmlTree.xml']);
f = f.TreeFile.Links.Link;

folder2 = ['./data/',sub,'_',postscan,'/'];
f2 = xml2struct([folder2,'ZUNU_vida-xmlTree.xml']);
f2 = f2.TreeFile.Links.Link;

rTable = zeros(length(f),7);
rTable2 = zeros(length(f2),7);
rlut = zeros(length(termlist),4);

aichange = [];
%% First iterate through all segments in preRT airway tree %%
for link = length(f):-1:1
    
    ai = [];
    ao = [];
    atts = f{1,link}.Attributes;
    if isfield(f{1,link},'CP')
        cp = f{1,link}.CP;
        if length(cp) > 1
            for cidx = 1:length(cp)
                if isfield(cp{1,cidx}.Attributes,'outerCrossSecArea')
                    ao = [ao,str2double(cp{1,cidx}.Attributes.outerCrossSecArea)];
                end
                if isfield(cp{1,cidx}.Attributes,'innerCrossSecArea')
                    ai = [ai,str2double(cp{1,cidx}.Attributes.innerCrossSecArea)];
                end
            end
        else
            if isfield(cp.Attributes,'outerCrossSecArea')
                ao = [ao,str2double(cp.Attributes.outerCrossSecArea)];
            end
            if isfield(cp.Attributes,'innerCrossSecArea')
                ai = [ai,str2double(cp.Attributes.innerCrossSecArea)];
            end
        end
    end
    linkid = str2double(atts.id);
    
    rTable(link,1) = linkid;
    d = str2double(atts.meanLuminalDiameter);
    l = str2double(atts.cylinderLength);
    if ~isnan(d) && ~isnan(l)
        % Convert length and diameter to meters since constant used in
        % resistance calc uses meters (VIDA outputs metrics in mm)
        l = l/1000;
        d = d/1000;
        r = (8*1.7*(10^-5)*l)/(pi*(d/2)^4); % Resistance calc assuming Laminar flow
    else
        r = 0;
    end
    rTable(link,2) = r;
    rTable(link,3) = str2double(atts.bp2);
    mld = atts.meanLuminalDiameter;
    
    if strcmp(mld,'NA')
        rTable(link,4) = 0;
    else
        rTable(link,4) = str2double(mld);
    end
    
    wt = atts.meanWallThickness;
    if strcmp(wt,'NA')
        rTable(link,5) = 0;
    else
        rTable(link,5) = str2double(wt);
    end
    
    if isempty(ao)
        rTable(link,6) = 0;
    else
        rTable(link,6) = mean(ao);
    end
    if isempty(ai)
        rTable(link,7) = 0;
    else
        rTable(link,7) = mean(ai);
    end
    
end

%% Repeat iterations through postRT airway tree %%
for link = length(f2):-1:1
    
    ai = [];
    ao = [];
    atts = f2{1,link}.Attributes;
    if isfield(f2{1,link},'CP')
        cp = f2{1,link}.CP;
        if length(cp) > 1
            for cidx = 1:length(cp)
                if isfield(cp{1,cidx}.Attributes,'outerCrossSecArea')
                    ao = [ao,str2double(cp{1,cidx}.Attributes.outerCrossSecArea)];
                end
                if isfield(cp{1,cidx}.Attributes,'innerCrossSecArea')
                    ai = [ai,str2double(cp{1,cidx}.Attributes.innerCrossSecArea)];
                end
            end
        else
            if isfield(cp.Attributes,'outerCrossSecArea')
                ao = [ao,str2double(cp.Attributes.outerCrossSecArea)];
            end
            if isfield(cp.Attributes,'innerCrossSecArea')
                ai = [ai,str2double(cp.Attributes.innerCrossSecArea)];
            end
        end
    end
    linkid = str2double(atts.id);
    
    rTable2(link,1) = linkid;
    d = str2double(atts.meanLuminalDiameter);
    l = str2double(atts.cylinderLength);
    if ~isnan(d) && ~isnan(l)
        l = l/1000;
        d = d/1000;
        r = (8*1.7*(10^-5)*l)/(pi*(d/2)^4);
    else
        r = 0;
    end
    rTable2(link,2) = r;
    rTable2(link,3) = str2double(atts.bp2);
    mld = atts.meanLuminalDiameter;
    if strcmp(mld,'NA')
        rTable2(link,4) = 0;
    else
        rTable2(link,4) = str2double(mld);
    end
    
    wt = atts.meanWallThickness;
    if strcmp(wt,'NA')
        rTable2(link,5) = 0;
    else
        rTable2(link,5) = str2double(wt);
    end
    
    if isempty(ao)
        rTable2(link,6) = 0;
    else
        rTable2(link,6) = mean(ao);
    end
    if isempty(ai)
        rTable2(link,7) = 0;
    else
        rTable2(link,7) = mean(ai);
    end
    
end

%% Calc Ai changes %%
for term = 1:length(termlist)
    p1 = termlist(term,1);
    rlut(term,1) = p1;
    nbp2 = rTable(rTable(:,1)==p1,3);
    nextseg = findSeg(f,num2str(nbp2));
    
    while(~isempty(nextseg))
        segid = str2double(nextseg.id);
        rlut(term,2) = rlut(term,2) + rTable(rTable(:,1)==segid,2);
        airwaymask = preairway==segid;
        dilated = imdilate(airwaymask,ones(2,2,2));
        maskedPost = dilated.*postairway;
        [m,freq] = mode(nonzeros(maskedPost));
        if freq>0
            aichange = [aichange; segid,rTable(rTable(:,1)==segid,4),rTable(rTable(:,1)==segid,5),rTable(rTable(:,1)==segid,6),rTable(rTable(:,1)==segid,7),m,rTable2(rTable2(:,1)==m,4),rTable2(rTable2(:,1)==m,5),rTable2(rTable2(:,1)==m,6),rTable2(rTable2(:,1)==m,7),max(dose(airwaymask)),mean(dose(airwaymask)),sum(airwaymask(:))];
        end
        nextseg = findSeg(f,nextseg.bp1);
    end
end

%% Calc cumulative resistance %%
for term = 1:length(termlist)
    
    p1 = termlist(term,2);
    rlut(term,3) = p1;
    nbp2 = rTable2(rTable2(:,1)==p1,3);
    nextseg = findSeg(f2,num2str(nbp2));
    
    while(~isempty(nextseg))
        segid = str2double(nextseg.id);
        rlut(term,4) = rlut(term,4) + rTable2(rTable2(:,1)==segid,2);
        nextseg = findSeg(f2,nextseg.bp1);
    end
    
end