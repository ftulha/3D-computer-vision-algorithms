%% Metric Rectification Method 2. We will not use the affinely rectified but the original perspective image in this case.
I = imread('building.jpg');
imshow(I);
[x,y] = getpts;
P = [x y ones(1,15)']; %Please use three points to form an intersection of orthogonal lines
% saveas(gcf,'z 1.png')
%%
hold on
% Use the 5 pairs of orthogonal lines to build up the equation of
L_1 = cross(P(1,:),P(2,:));
M_1 = cross(P(2,:),P(3,:));
L_2 = cross(P(4,:),P(5,:));
M_2 = cross(P(5,:),P(6,:));
L_3 = cross(P(7,:),P(8,:));
M_3 = cross(P(8,:),P(9,:));
L_4 = cross(P(10,:),P(11,:));
M_4 = cross(P(11,:),P(12,:));
L_5 = cross(P(13,:),P(14,:));
M_5 = cross(P(14,:),P(15,:));

% Set up M.c = 0
M = [L_1(1)*M_1(1) (L_1(1)*M_1(2)+L_1(2)*M_1(1))/2 L_1(2)*M_1(2) (L_1(1)*M_1(3)+L_1(3)*M_1(1))/2 (L_1(2)*M_1(3)+L_1(3)*M_1(2))/2 L_1(3)*M_1(3)
    L_2(1)*M_2(1) (L_2(1)*M_2(2)+L_2(2)*M_2(1))/2 L_2(2)*M_2(2) (L_2(1)*M_2(3)+L_2(3)*M_2(1))/2 (L_2(2)*M_2(3)+L_2(3)*M_2(2))/2 L_2(3)*M_2(3)
    L_3(1)*M_3(1) (L_3(1)*M_3(2)+L_3(2)*M_3(1))/2 L_3(2)*M_3(2) (L_3(1)*M_3(3)+L_3(3)*M_3(1))/2 (L_3(2)*M_3(3)+L_3(3)*M_3(2))/2 L_3(3)*M_3(3)
    L_4(1)*M_4(1) (L_4(1)*M_4(2)+L_4(2)*M_4(1))/2 L_4(2)*M_4(2) (L_4(1)*M_4(3)+L_4(3)*M_4(1))/2 (L_4(2)*M_4(3)+L_4(3)*M_4(2))/2 L_4(3)*M_4(3)
    L_5(1)*M_5(1) (L_5(1)*M_5(2)+L_5(2)*M_5(1))/2 L_5(2)*M_5(2) (L_5(1)*M_5(3)+L_5(3)*M_5(1))/2 (L_5(2)*M_5(3)+L_5(3)*M_5(2))/2 L_5(3)*M_5(3)];

%% Find the null vector which will give us the conic
c = null(M);
C_inf = [c(1) c(2)/2 c(4)/2;c(2)/2 c(3) c(5)/2;c(4)/2 c(5)/2 1]; %1 since f is for scale
[U,S,U_t] = svd(C_inf);
U_left = ((U')*sqrt(S));
U_left = (U_left*U_t)
U_left = U_left/U_left(3,3)
%% 
H_metric = [abs(U_left(1,1)) U_left(1,2) 0;abs(U_left(2,1)) U_left(2,2) 0;0 0 1];
hold off
T = maketform('affine', H_metric');
alpha = imtransform(I,T);
imshow(alpha);
imwrite(alpha,'output_2.png')