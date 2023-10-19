function [gclustering] = findclusteringcoeff(A)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

A=double(A);
n=size(A,1);

for i=1:n
    A(i,i)=0;
end


A2=A*A;
A3=A2*A;

nr=trace(A3);
dr=0;

for i=1:n
    for j=1:n
        if i==j
            continue
        else
            dr=dr+A2(i,j);
        end
    end
end

gclustering=nr/dr;




end

