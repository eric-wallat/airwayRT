function vecmap = nnJacRatio(airway,jacratio,termlist)

mask = jacratio;
mask(mask<0.01) = 0;
mask(mask>=0.01) = 1;
[xsize, ysize, zsize] = size(mask);
airway(airway<0) = 0;
endpoints = {};
for lidx = 1 : length(termlist)
    
    [r,c,v] = ind2sub(size(airway),find(airway==termlist(lidx,1)));
    vec = [r,c,v];
    vec = sortrows(vec,3);
    [l, ~] = size(vec);
    idx = ceil(l/2);
    p = vec(idx,:,:);
    endpoints{lidx} = p;
end

vecmap = zeros(xsize,ysize,zsize);
for x = 1 : xsize
    for y = 1 : ysize
        for z = 1 : zsize
            if mask(x,y,z) == 1
                d=1000000;
                for lidx = 1: length(termlist)
                    temp = sqrt((x-endpoints{lidx}(1))^2+(y-endpoints{lidx}(2))^2+(z-endpoints{lidx}(3))^2);
                    if temp < d
                        d = temp;
                        vecmap(x,y,z) = termlist(lidx,1);
                    end
                end
            end
        end
    end
end

