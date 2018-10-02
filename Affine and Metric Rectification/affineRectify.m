%% Affine Rectification
% We shall take two lines that are parallel in the 3d space in the image and will select points such that we have
% two lines. 
% I = imread('test_images/building2.jpg');
% I = imread('test_images/Crop_circles.jpg');
% I = imread('test_images/UCF SU.jpg');
% I = imread('test_images/home.jpg');
I = imread('test_images/chessboard.jpg');

imshow(I);
hold on
xy = ginput2(4);

% Reformat the coordinates 
p_1 = [xy(1,1) xy(1,2) 1]; p_2 = [xy(2,1) xy(2,2) 1]; p_3 = [xy(3,1) xy(3,2) 1]; p_4 = [xy(4,1) xy(4,2) 1];
plot(p_1(1),p_1(2),'*');plot(p_2(1),p_2(2),'*');plot(p_3(1),p_3(2),'*');plot(p_4(1),p_4(2),'*');
hold on
saveas(gcf,'res_1.png')

%%
% Using the cross product, find the equation of the line for 4 seemingly
% parallel lines L_1 through L_4
L_1 = cross(p_1, p_2); L_2 = cross(p_4, p_3); L_3 = cross(p_1, p_4); L_4 = cross(p_2, p_3);
L_1 = L_1./L_1(3);L_2 = L_2./L_2(3);L_3 = L_3./L_3(3);L_4 = L_4./L_4(3);

x_0 = 100; x_1 = 5000;
plot([x_0 x_1],[(-L_1(1)*(x_0)-L_1(3))/L_1(2) (-L_1(1)*(x_1)-L_1(3))/L_1(2) ],'r'); 
plot([x_0 x_1],[(-L_2(1)*(x_0)-L_2(3))/L_2(2) (-L_2(1)*(x_1)-L_2(3))/L_2(2) ],'b'); 
plot([x_0 x_1],[(-L_3(1)*(x_0)-L_3(3))/L_3(2) (-L_3(1)*(x_1)-L_3(3))/L_3(2) ],'g'); 
plot([x_0 x_1],[(-L_4(1)*(x_0)-L_4(3))/L_4(2) (-L_4(1)*(x_1)-L_4(3))/L_4(2) ],'y'); 
saveas(gcf,'res_2.png')

%%
% Find the intersections of these lines to determine the points at infinity
m_1 = cross(L_1/norm(L_1(3)), L_2/norm(L_2(3))); m_2 = cross(L_3/norm(L_3(3)), L_4/norm(L_4(3)));
m_1 = vpa(m_1)./vpa(m_1(3)); m_2 = vpa(m_2)./vpa(m_2(3))
plot(m_1(1)/m_1(3), m_1(2)/m_1(3), '+'); plot(m_2(1)/m_2(3), m_2(2)/m_2(3), '+');
% Find the equation of the line at infinity
L_inf = cross(m_1, m_2);
L_inf = double(L_inf/norm(L_inf));

%%
H_affine = ([1 0 0; 0 1 0; L_inf(1)/L_inf(3) L_inf(2)/L_inf(3) 1]);
% T = projective2d(double(H_affine));
% tformfwd([10 20],T)
T = maketform('projective', H_affine');
alpha = imtransform(I,T);
hold off
imshow(alpha);
imwrite(alpha,'1.png')
saveas(gcf,'output_aR.png')