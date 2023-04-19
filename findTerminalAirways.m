function postairwayvals = findTerminalAirways(folder,preairway,postairway)
f = xml2struct([folder,'ZUNU_vida-xmlTree.xml']);
f = f.TreeFile.Links.Link;
termlist = {};
idx = 1;
postairwayvals = [];
for link = length(f):-1:1
    term = 1;
    atts = f{1,link}.Attributes;
    b2 = atts.bp2;
    for link2 = length(f):-1:1
        atts2 = f{1,link2}.Attributes;
        b1 = atts2.bp1;
        if strcmp(b1,b2)
            term = 0;
            break
        end
    end
    if term
        
        termlist{idx,1} = str2double(b2);
        binaryImage = preairway == termlist{idx,1};
        maskedPost = postairway.*binaryImage;
        [m,freq] = mode(nonzeros(maskedPost)); % Finds the postRT airway that overlaps most with the preRT airway label
        if ~isempty(postairwayvals)
            match = find(postairwayvals(:,2)==m);
            if ~isempty(match)
                if freq>postairwayvals(match,3)
                    postairwayvals(match,1) = termlist{idx,1};
                    postairwayvals(match,3) = freq;
                end
            else
                postairwayvals = [postairwayvals; termlist{idx,1}, m, freq];
            end
        else
            postairwayvals = [termlist{idx,1}, m, freq];
        end
        idx = idx + 1;
    end
end
