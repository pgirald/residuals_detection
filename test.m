clear;
close all;

step=0.1;

t = (-20:step:20)';

x = 5*sin(t);

y = 5*cos(t);

z = 5*cos(t);

samplescount = 20;

[p,q] = rat(samplescount/ numel(t));
rs = resample(z,p,q);

trs = (t(1):(step*(q/p)):t(end))';

figure, plot(t,z,'-',trs,rs,'o');
figure, plot(trs, rs,'o');

%{
dR = [gradient(x(:)),gradient(y(:)),gradient(z(:))];
dt = gradient(t);
dRdt = dR./dt;
T = dRdt./sqrt(sum(dRdt.^2,2));%Vector tangente unitario

dT = [gradient(T(:,1)),gradient(T(:,2)),gradient(T(:,3))];
dTdt = dT./dt;

N = dTdt./sqrt(sum(dTdt.^2,2)); %Vector normal unitario

B = cross(T,N); %Vector binormal unitario
%}
dR = [x(2:end)-x(1:end-1),y(2:end)-y(1:end-1),z(2:end)-z(1:end-1)];
ds = sqrt(sum(dR.^2,2));
s = [0;cumsum(ds)];

dRds = [gradient(x,s),gradient(y,s),gradient(z,s)];

T = dRds./sqrt(sum(dRds.^2,2)); % Unit tangent vector.

dTds = [gradient(T(:,1),s),gradient(T(:,2),s),gradient(T(:,3),s)];

N = dTds ./ sqrt(sum((dTds).^2,2)); % Unit normal vector.

B = cross(T,N); % Unit bi-normal vector.

points = 1:80:401;

figure, plot3(x,y,z,'DisplayName',"Trayectoria de píxel");
hold on;
quiver3(x(points),y(points),z(points),...
    T(points,1),T(points,2),T(points,3),...
    'LineWidth',1,'Color','r','AutoScale','off','DisplayName',"Tangente unitario");
quiver3(x(points),y(points),z(points),...
    N(points,1),N(points,2),N(points,3),...
    'LineWidth',1,'Color','g','AutoScale','off','DisplayName',"Normal unitario");
quiver3(x(points),y(points),z(points),...
    B(points,1),B(points,2),B(points,3),...
    'LineWidth',1,'Color','b','AutoScale','off','DisplayName',"Binormal unitario");

legend
axis equal;
hold off;
%{
plot(t,x);
dx = gradient(x);
dt = gradient(t);
dx = dx./sqrt((dx.^2)+(dt.^2));
dt = dt./sqrt((dx.^2)+(dt.^2));
points = 1:20:400;
hold on;
quiver(t(points),x(points),dt(points),dx(points),'g','AutoScale','off');
axis equal
%}
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