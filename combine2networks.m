function [C] = combine2networks(A,B)
n=size(A,1);
m=size(B,1);
C=zeros(n+m);
%C=false(n+m);
%C=sparse(zeros(n+m));
%C=sparse(false(n+m));
C(1:n,1:n)=A;
C(n+1:n+m, n+1:n+m)=B;

end

