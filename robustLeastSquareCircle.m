function [model,resnorm] = robustLeastSquareCircle(points)
% least square fit circle
% author: cuixingxing
% email: cuixingxing150@gmail.com
xdata = points(:,1);
ydata = points(:,2);
fun = @(x)(xdata-x(1)).^2+(ydata-x(2)).^2-x(3).^2;
[minv,maxv] = bounds(points);
options = optimoptions(@lsqnonlin,Algorithm="Levenberg-Marquardt");
[model,resnorm] = lsqnonlin(fun,[mean(points),mean(maxv-minv)],[],[],options);
resnorm = resnorm/size(xdata,1);
% resnorm
% [model,fval] = fminsearch(@(x)objectfun(x,xdata,ydata),[mean(points),mean(maxv-minv)]);
% options = optimoptions('particleswarm','SwarmSize',300,'MaxStallIterations',100,...
%     'HybridFcn',@fmincon,'MaxIterations',3*300);
% [model,fval] = particleswarm(@(x)objectfun(x,xdata,ydata),3,[-inf,-inf,0],[inf,inf,inf],options);
% fval
end

function errs = objectfun(x,xdata,ydata)
errs = 0;
for i = 1:numel(xdata)
    xi = xdata(i);
    yi = ydata(i);
    % err1 = (sqrt((xi-x(1)).^2+(yi-x(2)).^2)-x(3)).^2;% points to cicle edge dist
    errs = errs+((xi-x(1)).^2+(yi-x(2)).^2-x(3).^2).^2;
end
end