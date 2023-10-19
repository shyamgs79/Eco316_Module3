clc
clear all
%Creating a SF network using preferential attachment

tic
%number of agents
n=500;
totalpossconnections=(n*(n-1))/2;

%number of connections desired is c(note n << c << totalpossconnections)
c=1000;

%strength of preference (typically, p >= 1)
p=2;

SF=zeros(n);
%SF=sparse(zeros(n));
%SF=false(n);
%SF=sparse(false(n));


for i=1:n
    
    diffn=0;
    while diffn==0
        x=randi(n);
        if x~=i
            SF(i,x)=1;
            SF(x,i)=1;
            diffn=1;
        end
    end
    
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
    
    if SF(nodechosen,x)==0 && nodechosen~=x
        SF(nodechosen,x)=1;
        SF(x,nodechosen)=1;
        connectionsmade=connectionsmade+1;
    end
end

degrees=sum(SF,2);
figure(1)
plot(degrees);
figure(2)
histogram(degrees);
toc

[gclustering] = findclusteringcoeff(SF);
B=findshortestpaths(SF);

G=graph(SF);
figure(3)
plot(G);
figure(4)
spy(SF);
