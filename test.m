clear;
close all;

step=0.1;

t = (-20:step:20)';

x = sin(t);

y = 10 * cos(t);

z = cos(t);

samplescount = 20;

[p,q] = rat(samplescount/ numel(t));
rs = resample(z,p,q);

trs = (t(1):(step*(q/p)):t(end))';

figure, plot(t,z,'-',trs,rs,'o');
figure, plot(trs, rs,'o');
%{
P1(:, 1) = t';

P1(:, 2) = sin(t);

P2(:, 1) = t';

P2(:, 2) = 10 * cos(t);

P3(:, 1) = t';

P3(:, 2) = cos(t);

[k1,~] = convhull(P1);
[k2,~] = convhull(P2);
[k3,~] = convhull(P3);


plot3(P1(:,2),P2(:,2),P3(:, 2),'*')
hold on
plot3(P1(k1,2),P2(k2,2),P3(k3,2))

a_f = sym('a_f');
b_f = sym('b_f');
c_f = sym('c_f');
d_f = sym('d_f');

syms f(t)

f(t) = a_f * (t^3) + b_f * (t^2) + c_f * (t) + d_f;

a_g = sym('a_g');
b_g = sym('b_g');
c_g = sym('c_g');
d_g = sym('d_g');

syms g(t)

g(t) = a_g * (t^3) + b_g * (t^2) + c_g * (t) + d_g;

a_h = sym('a_h');
b_h = sym('b_h');
c_h = sym('c_h');
d_h = sym('d_h');

syms h(t)

h(t) = a_h * (t^3) + b_h * (t^2) + c_h * (t) + d_h;

syms F(x, y)

F(x, y) = (((f(x) - f(y))^2) + ((g(x) - g(y))^2) + ((h(x) - h(y))^2))^(1/2);

F_x = diff(F, x);

F_y = diff(F, y);

S_x = solve(F_x == 0,'ReturnConditions',true);

S_y = solve(F_y == 0,'ReturnConditions',true);
%}