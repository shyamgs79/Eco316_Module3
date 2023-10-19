clc
clear all
%Creating a SF network using preferential attachment

tic
%number of agents
n=500;
totalpossconnections=n*(n-1);

%number of connections desired is c(note n << c << totalpossconnections)
c=1500;

%strength of preference (typically, p >= 1)
p=1;

%SF=zeros(n);
%SF=sparse(zeros(n));
%SF=false(n);
SF=sparse(false(n));


for i=1:n
    x=randi(n);
    SF(i,x)=1;
end


connectionsmade=n;
while connectionsmade<c
    
    degrees=sum(SF,2);
    degreesp=degrees.^p;
    
    probs=cumsum(degreesp)./sum(degreesp);
    
    nodechosen=1;
    xn=rand;
    for i=2:n
        if xn>probs(i-1) && xn<=probs(i)
            nodechosen=i;
            break
        end
    end
    
    x=randi(n);
    
    if SF(nodechosen,x)==0
        SF(nodechosen,x)=1;
        connectionsmade=connectionsmade+1;
    end
end

degrees=sum(SF,2);

plot(degrees);
histogram(degrees);
toc

[gclustering] = findclusteringcoeff(SF);
B=findshortestpaths(SF);
