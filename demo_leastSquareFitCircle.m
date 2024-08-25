%% robust least squre fit circle,just run this demo

%% Create randome points along a circle
r = 1;
numPts = 100;
theta = linspace(0,2*pi,numPts);
xdata = r*cos(theta)+0.1*randn(1,numPts);
ydata = r*sin(theta)+0.1*randn(1,numPts);

% add noise
xdata(1) = 5;xdata(2) = 4;xdata(3) = 5;
ydata(1) = 4;ydata(2) = 5;ydata(3) = 5;
h1 = scatter(xdata,ydata); % sample data

% noise least square fit circle
fun = @(x)(xdata-x(1)).^2+(ydata-x(2)).^2-x(3).^2;
x = lsqnonlin(fun,[0,0,1]);

h2 = viscircles(x(1:2),x(3),color="red");hold on; % noise least square fit
h3 = viscircles([0,0],1,color="blue");% ground truth


%% robust fit
fitFcn = @(points)robustLeastSquareCircle(points);
distFcn = @(model, points)((points(:,1)-model(1)).^2+(points(:,2)-model(2)).^2-model(3).^2).^2;
sampleSize = 3;
maxDistance = 0.5;
data = [xdata(:),ydata(:)];

[modelRansac,inlierIdx] = ransac(data,fitFcn,distFcn,sampleSize,maxDistance);
h4 = viscircles(modelRansac(1:2),modelRansac(3),color="black");

modelRobust = fitFcn(data(inlierIdx,:));
h5 = viscircles(modelRobust(1:2),modelRobust(3),color="green");% robust fit'

legend([h1,h2,h3,h4,h5],{'point samples','least square fit','ground truth','Ransac samples fit','robust fit'},Location="northwest")
grid on;axis equal


