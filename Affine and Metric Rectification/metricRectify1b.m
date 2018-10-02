%% Metric Rectification Method Ib: We will use a conic here for the constraints instead of the orthogonal lines
I = imread('test_images/Crop_circles_affineRectified.png');
imshow(I);
hold on
% Here we will select the points on the conic.
xy = ginput2(5);
% Get points from the circle.
p_1 = [xy(1,1) xy(1,2) 1]; p_2 = [xy(2,1) xy(2,2) 1]; p_3 = [xy(3,1) xy(3,2) 1]; p_4 = [xy(4,1) xy(4,2) 1];
p_5 = [xy(5,1) xy(5,2) 1];
plot(p_1(1),p_1(2),'*');plot(p_2(1),p_2(2),'*');plot(p_3(1),p_3(2),'*');plot(p_4(1),p_4(2),'*'); plot(p_5(1),p_5(2),'*');

%% Fit the conic equation with the selected points
C = conicfit([p_1' p_2' p_3' p_4' p_5']);
% Now we find the line_infinity for this image.
xy = ginput2(4);
p_1 = [xy(1,1) xy(1,2) 1]; p_2 = [xy(2,1) xy(2,2) 1]; p_3 = [xy(3,1) xy(3,2) 1]; p_4 = [xy(4,1) xy(4,2) 1];
plot(p_1(1),p_1(2),'+'); plot(p_2(1),p_2(2),'+'); plot(p_3(1),p_3(2),'+'); plot(p_4(1),p_4(2),'+');

% Using the cross product, find the equation of the line for 4 seemingly parallel lines L_1 through L_4
L_1 = cross(p_1, p_2); L_2 = cross(p_4, p_3); L_3 = cross(p_1, p_4); L_4 = cross(p_2, p_3);
L_1 = L_1./L_1(3);L_2 = L_2./L_2(3);L_3 = L_3./L_3(3);L_4 = L_4./L_4(3);

% Plot the parallel lines on the image
x_0 = 100; x_1 = 5000;
plot([x_0 x_1],[(-L_1(1)*(x_0)-L_1(3))/L_1(2) (-L_1(1)*(x_1)-L_1(3))/L_1(2) ],'r'); 
plot([x_0 x_1],[(-L_2(1)*(x_0)-L_2(3))/L_2(2) (-L_2(1)*(x_1)-L_2(3))/L_2(2) ],'b'); 
plot([x_0 x_1],[(-L_3(1)*(x_0)-L_3(3))/L_3(2) (-L_3(1)*(x_1)-L_3(3))/L_3(2) ],'g'); 
plot([x_0 x_1],[(-L_4(1)*(x_0)-L_4(3))/L_4(2) (-L_4(1)*(x_1)-L_4(3))/L_4(2) ],'y'); 

%%
% Find the intersections of these lines to determine the points at infinity
m_1 = cross(L_1/norm(L_1(3)), L_2/norm(L_2(3))); m_2 = cross(L_3/norm(L_3(3)), L_4/norm(L_4(3)));

% Now find the intersection between the line at infinity and the conic.
[one, two] = intersect(C, m_1', m_2');
C_infinity = one*two' + two*one';
% Since we now have all the information about the conic at infinity we can
% use SVD to decompose the matrix into USU' to obtain the rectifying
% transformation. 
[U, S, U_t] = svd(C_infinity);
% Since the diagonal values may not be one we can do an arithmetic trick to
% enforce the identity matrix.
U_left = ((U')*sqrt(S));
U_left = (U_left*U_t)
U_left = U_left/U_left(3,3)
%%
hold off
U_format = [U_left(1,1:2) 0;U_left(2,1:2) 0;0 0 1];
T = maketform('affine', U_format');
alpha = imtransform(I, T);
imshow(alpha);
% imwrite(alpha,'output_1b.png')