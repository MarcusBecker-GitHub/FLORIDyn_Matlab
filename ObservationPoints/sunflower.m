function [y,z,area] = sunflower(n, alpha)   %  example: n=500, alpha=2
% SUNFLOWER distributes n points in a sunflower pattern 
%   Uses altered code from stack overflow:
% https://stackoverflow.com/questions/28567166/uniformly-distribute-x-points-inside-a-circle#28572551
%
% INPUT
% n     := Int, Number of points to be placed
% alpha := Int, weight of points on the rim (musn't be above sqrt(n)!)

if alpha>sqrt(n)
    error(['Sunflower: Rimpoints weight alpha is to large, must be' ... 
        ' smaller than sqrt(n), with n points.'])
end

b   = round(alpha*sqrt(n));      % number of boundary points
gr  = (sqrt(5)+1)/2;             % golden ratio
k   = 1:n;
r   = ones(1,n);

r(1:n-b) = sqrt(k(1:n-b)-1/2)/sqrt(n-(b+1)/2);
theta = 2*pi*k/gr^2;

y = (r.*cos(theta))';
z = (r.*sin(theta))';
%% Calculate the relative area represented by the observation point
% Draw a circle around the rotor points
phi = linspace(0,2*pi,100);
xc = 1.1*cos(phi');
yc = 1.1*sin(phi');
[v,c] = voronoin([y z;xc,yc]) ;

A = zeros(length(c),1) ;
for i = 1:length(c)
    v1 = v(c{i},1) ; 
    v2 = v(c{i},2) ;
    A(i) = polyarea(v1,v2) ;
end
area = A(1:n)./sum(A(1:n));
end

%% Get area of voronoi diagram
% https://www.mathworks.com/matlabcentral/answers/446168-how-can-i-get-the-area-of-each-polygon-of-a-voronoi-diagram
%
% Only issue are the outer points on the rim.