function [ShortestPaths] = findshortestpaths(A)

n=size(A,1);
ShortestPaths=inf*ones(n,n);
tA=eye(n,n);
ctr=0;
maxpathlengthtoconsider=10;

for i=1:maxpathlengthtoconsider
    
    tA=tA*A;
    
    for row=1:n
        for col=1:n
            
            if row==col
                ShortestPaths(row,col)=1; %This is true only if shortest path to oneself is ASSUMED to be 1 (technically, not true unless Network included self-loops)
            end
            
            if ShortestPaths(row,col)==inf && tA(row,col)~=0
                ShortestPaths(row,col)=i;
                ctr=ctr+1;
                if ctr==n*n
                    return
                end
            end
        end
    end
end
end

