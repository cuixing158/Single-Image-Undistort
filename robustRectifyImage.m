function [undistortImage,mapX,mapY] = robustRectifyImage(distortionImage,M,options)
% Brief: robust rectify distortion from single image
% Details:
%  reproduce+ improve，reference paper:2009_(经典_重点_大连理工)A Simple 
% Method of Radial Distortion Correction with Centre of Distortion Estimation
%
% Syntax:
% [undistortImage,mapX,mapY] = robustRectifyImage(distortionImage,M)
%
% Inputs:
% distortionImage - 任意畸变图像，不限大小和类型
% M - [m,n] size,[table] type,VariableNames有["arcs","points","resnorm"]等，
%       前2个变量必须有，其中arcs存储圆弧系数[A,B,C],points存储拟合该圆弧的点
%       集坐标，resnorm可选参数，存储残差平方和.
% options，可选name-value参数，OutputView可以指定["same","full","valid"]
%       的一种。类似MATLAB内建函数undistortImage的OutputView选项
%
% Outputs:
%    undistortImage - 无畸变图像，类型同输入图像
%    mapX - [M,N] size,[double] type,x的映射坐标
%    mapY - [M,N] size,[double] type,y的映射坐标
%
% Example:
%    demo_undistortImage_synthetic.mlx
%
% Notes:
%    使用此函数需要事先确定好输入参数M，可以通过本项目中的getArcs.mlapp交互方式获得。
%
% See also: None

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         08-May-2023 11:20:03
% Version history revision notes:
%                                  2023.6.14
%                                  独立重构undistortImageForDivisionModel函数
% Implementation In Matlab R2023a
% Copyright © 2023 TheMatrix.All Rights Reserved.
%
arguments
    distortionImage
    M  table 
    options.OutputView (1,:) {mustBeMember(options.OutputView,["same","full","valid"])}="same"
end

% estimate camera parameters for division model
[xCenter,yCenter,lambda] = estCameraParamForDivisionModel(M);

% undistort image
[undistortImage,~,mapX,mapY] = undistortImageForDivisionModel(distortionImage,...
    lambda,xCenter,yCenter,OutputView=options.OutputView);
end




