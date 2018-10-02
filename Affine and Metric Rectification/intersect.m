function [ p1,p2] = intersect(C, m1, m2)

% Setting up the terms of the quadratic equation,
% A*lambda^2 + B*lambda + C = 0
A = m2'*C*m2; B = 2*m2'*C*m1; C = m1'*C*m1;

% Now we can find lambda_1 and lambda_2 using the quadratic formula
lambda_1 = (-B + sqrt(B^2 - 4*A*C))/(2*A);
lambda_2 = (-B - sqrt(B^2 - 4*A*C))/(2*A);

% We can finally determine the intersection points, in_1 and in_2
p1 = m1 + lambda_1*m2;
p2 = m1 + lambda_2*m2;

disp('The two intersection points are: ')
disp(num2str(p1));
disp('and');
disp(num2str(p2));

end

