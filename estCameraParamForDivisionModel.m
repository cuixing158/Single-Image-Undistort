function [xCenter,yCenter,lambda] = estCameraParamForDivisionModel(arcsTable)
% Brief: 从包含"圆弧曲线"参数表格arcsTable中估计除法模型畸变中心和畸变系数
% Details:
%    从来自于自研开发的交互式APP中自动计算"圆弧曲线"参数表格arcsTable，然后根
% 据本函数进一步求解除法模型的畸变中心(xCenter,yCenter)和畸变系数lambda
% 
% Syntax:  
%     [xCenter,yCenter,lambda] = estCameraParamForDivisionModel(arcsTable)
% 
% Inputs:
%    arcsTable - [m,n] size,[table] type,VariableNames有["arcs","points",
%               "resnorm"]等，前2个变量必须有，其中arcs存储圆弧系数[A,B,C],points
%               存储拟合该圆弧的点集坐标，resnorm可选参数，存储残差平方和
% 
% Outputs:
%    xCenter - [1,1] size,[double] type,畸变中心横坐标
%    yCenter - [1,1] size,[double] type,畸变中心纵坐标
%    lambda - [1,1] size,[double] type,畸变系数
% 
% Example: 
%    load ../data/preSavedData/data_caoji_ok1.mat % come from undistortFisheyeFromSingleView/getArcs.mlapp
%    arcsTable = M;
%    [xCenter,yCenter,lambda] = estCameraParamForDivisionModel(arcsTable)
% 
% See also: None

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         01-Dec-2023 15:14:08
% Version history revision notes:
%                                  None
% Implementation In Matlab R2023b
% Copyright © 2023 TheMatrix.All Rights Reserved.
%
arguments
    arcsTable  table 
end
numArcs = size(arcsTable,1);
assert(numArcs>=3,"you must find at least 3 strght line arcs in image");

arcs = vertcat(arcsTable.arcs);
points = arcsTable.points;

fitFcn = @(arcs)robustArc(arcs);% test_leastSquareFitCircle.m
distFcn = @(model,arcs)evaluateStraight(model,arcs,points);
sampleSize = 3;
maxDistance = 50;%0.12*10^(-20);% in square pixels
data = arcs;
[~,inlierIdx] = ransac(data,fitFcn,distFcn,sampleSize,maxDistance);
inlierData = arcs(inlierIdx,:);
model = fitFcn(inlierData);
xCenter = model(1);
yCenter = model(2);
lambda = model(3);
end

function  model = robustArc(arcs)
% M = vertcat(M.arcs);
numArcs = size(arcs,1);
indexCombine = nchoosek(1:numArcs,2);
numCombines = size(indexCombine,1);
AA = zeros(numCombines,2);
bb = zeros(numCombines,1);
for idx = 1:numCombines
    idx1 = indexCombine(idx,1);
    idx2 = indexCombine(idx,2);
    AA(idx,:) = [arcs(idx1,1)-arcs(idx2,1),arcs(idx1,2)-arcs(idx2,2)];% [A_i-A_j,B_i-B_j],来源论文中公式12
    bb(idx) = arcs(idx2,3)-arcs(idx1,3);% C_j-C_i,来源论文中公式12
end
x_center = lsqminnorm(AA,bb);% x_center = AA\bb;
lambda = 1./(x_center(1).^2+x_center(2).^2+arcs(1,1)*x_center(1)+arcs(1,2)*x_center(2)+arcs(1,3));% 来源论文公式13
model = [x_center(1),x_center(2),lambda];
% disp(model);
% disp(model(3))
end

function dist = evaluateStraight(model,M,points)
% M = [A,B,C], x^2+y^2+A*x+B*y+C==0
% points, n*1 cell, each cell is m*2 double
x_center = model(1);
y_center = model(2);
lambda = model(3);

numArcs = size(M,1);
dist = zeros(numArcs,1);
for i = 1:numArcs
    currArcPoints = points{i};% distortion arc points,[x,y]
    r_2 = sum((currArcPoints-[x_center,y_center]).^2,2);
    undistortPts = [x_center,y_center]+(currArcPoints-[x_center,y_center])./(1+lambda*r_2);

    % dist(i) = straightNess(undistortPts);% 算法使用此函数较耗时，待调查原因
    % https://ww2.mathworks.cn/matlabcentral/answers/66555-using-svd-to-solve-systems-of-linear-equation-have-to-implement-direct-parameter-calibration-method
    A = [undistortPts(:,1),ones(size(undistortPts,1),1);]; % y = k*x+b
    b = undistortPts(:,2);
    [U,S,V] = svd(A);
    coff = (V*pinv(S)*U')*b; % or use coff = A\b; formular: y = coff(1)*x+coff(2)
    dist(i) = max(abs(coff(1)*undistortPts(:,1)-undistortPts(:,2)+coff(2))./sqrt(coff(1).^2+1));% appromate straightness
    
end
% disp("distance:");
% disp(dist);
end