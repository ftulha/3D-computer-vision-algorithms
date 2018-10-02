%% Metric Rectification Method Ia
I = imread('test_images\UCF SU.jpg');

imshow(I);
hold on
% Here will will select 3 points to form the first orthogonal line and the
% subsequent 3 to form the second. 
xy = ginput2(6);
% Reformat the coordinates.
p_1 = [xy(1,1) xy(1,2) 1]; p_2 = [xy(2,1) xy(2,2) 1]; p_3 = [xy(3,1) xy(3,2) 1]; p_4 = [xy(4,1) xy(4,2) 1];
p_5 = [xy(5,1) xy(5,2) 1]; p_6 = [xy(6,1) xy(6,2) 1]; 

plot(p_1(1),p_1(2),'*');plot(p_2(1),p_2(2),'*');plot(p_3(1),p_3(2),'*');plot(p_4(1),p_4(2),'*');
% saveas(gcf,'res_1.png')

%% % Using the cross product, find the equation of the line for 4 seemingly
plot(p_5(1),p_5(2),'*'); plot(p_6(1),p_6(2),'*');
% orthogonal lines L_1 through L_4
L_1 = cross(p_1, p_2); L_2 = cross(p_2, p_3); L_3 = cross(p_4, p_5); L_4 = cross(p_5, p_6);
L_1 = L_1./L_1(3); L_2 = L_2./L_2(3); L_3 = L_3./L_3(3); L_4 = L_4./L_4(3); 

x_0 = 100; x_1 = 5000;
plot([x_0 x_1],[(-L_1(1)*(x_0)-L_1(3))/L_1(2) (-L_1(1)*(x_1)-L_1(3))/L_1(2) ],'r'); 
plot([x_0 x_1],[(-L_2(1)*(x_0)-L_2(3))/L_2(2) (-L_2(1)*(x_1)-L_2(3))/L_2(2) ],'b'); 
plot([x_0 x_1],[(-L_3(1)*(x_0)-L_3(3))/L_3(2) (-L_3(1)*(x_1)-L_3(3))/L_3(2) ],'g'); 
plot([x_0 x_1],[(-L_4(1)*(x_0)-L_4(3))/L_4(2) (-L_4(1)*(x_1)-L_4(3))/L_4(2) ],'y'); 
% saveas(gcf,'res_2.png')

%% We will set up the matrix L.S = 0 and find the null vector of S.
L = [L_1(1)*L_2(1) L_1(1)*L_2(2)+L_1(2)*L_2(1) L_1(2)*L_2(2);
     L_3(1)*L_4(1) L_3(1)*L_4(2)+L_3(2)*L_4(1) L_3(2)*L_4(2)]
S = null(L);
set = [S(1)/S(3) S(2)/S(3); S(2)/S(3) 1];
a = chol(set*set');
H_metric = [a(1,:) 0;a(2,:) 0;0 0 1];
hold off

T = maketform('affine', H_metric');
alpha = imtransform(I,T);
imshow(alpha);
imwrite(alpha,'output_1a.png')