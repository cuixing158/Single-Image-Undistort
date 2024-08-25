function [val,x,exitflag] = straightNess(points)
% Brief: evaluate line strainghtness form 2-dim points
% Details:
%    minimal-zone method, 对于平面上的二维点集(xi,yi),最小区域法确定两条包络线使得两条平行线l1,l2使得其距离最小，此距离即为直线度，设l1: a*x+b*y+c==0, l2: a*x+b*y+d==0,则两条直接的距离为：D = abs(c-d)/sqrt(a^2+b^2),
% 直线度val即为D取最小值，待优化求解的变量为a,b,c,d，在以下程序中分别对应x(1),x(2),x(3),x(4)
% 
% Syntax:  
%     val = straightNess(points)
% 
% Inputs:
%    points - [m,2] size,[double] type,Description
% 
% Outputs:
%    val - [1,1] size,[double] type,直线度，此值越小代表“直线”越直
% 
% Example: 
%   numPts = 300;
%   maxNumX = 100;
%   x = randi(maxNumX,numPts,1);
%   y = -x+50*rand(numPts,1);
%   [val,coeff,exitflag] = straightNess([x,y]);
%   figure;scatter(x,y,20,"blue","filled");hold on;
%   x_ = 1:maxNumX;
%   y1 = (-coeff(3)-coeff(1).*x_)./coeff(2);
%   y2 = (-coeff(4)-coeff(1).*x_)./coeff(2);
%   grid on;plot(x_,y1,x_,y2,LineWidth=2)
%   legend(["samples","bounds1","bounds2"])
%   title("straightness:"+string(val))
% 
% See also: None

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         11-May-2023 10:26:16
% Version history revision notes:
%                                  None
% Implementation In Matlab R2023a
% Copyright © 2023 TheMatrix.All Rights Reserved.
%
arguments
    points (:,2) {mustBeNumeric}
end

x0 = [1,2,3,100];
nonlcon = @(x)edgeCon(x,points);
A = [];
b = [];
Aeq = [];
beq = [];
lb = [];
ub = [];
options = optimoptions('fmincon','SpecifyObjectiveGradient',true);
[x,D_2,exitflag] = fmincon(@objFun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
val = sqrt(D_2);
end

function [D_2,grad] = objFun(x)
D_2 = (x(3)-x(4)).^2./(x(1).^2+x(2).^2); 
grad = [-2*x(1).*(x(3)-x(4)).^2./(x(1).^2+x(2).^2).^2,...
    -2*x(2).*(x(3)-x(4)).^2./(x(1).^2+x(2).^2).^2,...
    2*(x(3)-x(4))./(x(1).^2+x(2).^2),...
    -2*(x(3)-x(4))./(x(1).^2+x(2).^2)];
end
function [c,ceq] = edgeCon(x,points)
c = (x(1).*points(:,1)+x(2).*points(:,2)+x(3)).*(x(1).*points(:,1)+x(2).*points(:,2)+x(4));
ceq = x(1).^2+x(2).^2+x(3).^2-1;
end