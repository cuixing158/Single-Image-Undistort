function H = projtform2dFromDecompose(intrinsicK,relR,relT,normN,d)
% Brief: 从分解的单应(透视变换)矩阵的角度直接构建单应(透视变换)矩阵
% Details:
%    参考：1. https://blog.csdn.net/rs_lys/article/details/105427224
%    2.本实现遵循premultiply convention，即常用习惯方式https://ww2.mathworks.cn/help/images/migrate-geometric-transformations-to-premultiply-convention.html
% 
% Syntax:  
%     H = projtform2dFromDecompose(intrinsicK,relR,relT,normN,d)
% 
% Inputs:
%    intrinsicK - [1,1] size,[cameraIntrinsics] type,设计为build-in类型，代表相机内参
%    relR - [3,3] size,[double] type,第二幅视图相对第一副视图的旋转矩阵
%    relT - [3,1] size,[double] type,第二幅视图相对第一副视图的平移向量
%    normN - [3,1] size,[double] type,单位法矢量
%    d - [1,1] size,[double] type,第一幅视图相机光心原点到成像图像平面的距离(即焦距？)
% 
% Outputs:
%    H - [3,3] size,[double] type,单应(透视变换)矩阵，满足x2 =
%    H*x1,其中x1,x2分别为视图1,2图像上的点
% 
% Example: 
%    None
% 
% See also: None

% Author:                          cuixingxing
% Email:                           cuixingxing150@gmail.com
% Created:                         22-May-2023 02:44:21
% Version history revision notes:
%                                  None
% Implementation In Matlab R2023a
% Copyright © 2023 TheMatrix.All Rights Reserved.
%
arguments 
    intrinsicK (1,1) cameraIntrinsics
    relR (3,3) {mustBeNumeric}
    relT (3,1) {mustBeNumeric}
    normN (3,1) {mustBeNumeric}
    d (1,1) {mustBeNumeric}
end
K = intrinsicK.K;
H = K*(relR-relT*normN'/d)/K;
end