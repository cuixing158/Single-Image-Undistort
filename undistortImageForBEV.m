function [J,mapX,mapY] = undistortImageForBEV(I,lambda,x_center,y_center,distortionR)
% Brief: 使用除法模型distortion division model已知的三个参数(lambda,x_center,y_center)针对2D俯视拼接畸变图像I进行去畸变。
% Details:
%    给一个预定义畸变边界半径distortionR，在此半径内无任何畸变，大于此半径之外按照除法畸变模型进行逼近去畸变。
% 
% Syntax:  
%     [J,mapX,mapY] = undistortImageForBEV(I,lambda,x_center,y_center,distortionR)
% 
% Inputs:
%    I - [m,n] size,any image type,畸变图像
%    lambda - [1,1] size,[double] type,畸变系数
%    x_center - [1,1] size,[double] type,畸变中心横坐标
%    y_center - [1,1] size,[double] type,畸变中心纵坐标
%    distortionR - [1,1] size,[double] type,临界畸变半径
% 
% Outputs:
%    J - [M,N] size,any image type,无畸变图像
%    mapX - [M,N] size,[double] type,映射X坐标
%    mapY - [M,N] size,[double] type,映射Y坐标
% 
% Example: 
%    None
% 
% See also: None

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         14-Jun-2023 07:05:20
% Version history revision notes:
%                                  None
% Implementation In Matlab R2023a
% Copyright © 2023 TheMatrix.All Rights Reserved.
%

expandR = calDistRadius(distortionR,lambda);
scale = distortionR/expandR;
[~,~,mapX,mapY] = undistortImageForDivisionModel(I,lambda,x_center,y_center,OutputView="valid");
% figure(Name="undistort Image,division model");imshow(undistortImg)
% undistortImg = imresize(undistortImg,scale);
mapX = imresize(mapX,scale);
mapY = imresize(mapY,scale);

blender = vision.AlphaBlender('Operation','Binary Mask',...
    'MaskSource','Input port','LocationSource','Input port');
[H,W,~] = size(I);
[X,Y] = meshgrid(1:W,1:H);
maskInd = sqrt((X(:)-W/2).^2+(Y(:)-H/2).^2)<distortionR;
maskImg = reshape(maskInd,H,W);
[H1,W1,~] = size(mapX);
mapX = blender(mapX,X,maskImg ,[W1/2-W/2,H1/2-H/2]);
mapY = blender(mapY,Y,maskImg ,[W1/2-W/2,H1/2-H/2]);
% J = blender(undistortImg,oriImg,maskImg,int32([W1/2-W/2,H1/2-H/2]));
J = images.internal.interp2d(I,mapX,mapY,...
    "linear",0, false);
release(blender);
end

function R = calDistRadius(r,lambda)
% distortion division model, https://www.wikiwand.com/en/Distortion_(optics)
pt = [r,0];
x_u = pt(1)./(1+lambda*r.^2);
y_u = pt(2)./(1+lambda*r.^2);
R = sqrt(x_u^2+y_u^2);
end