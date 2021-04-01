y0 = [1,0,0]';
guess = y0;

max_iter = 100;
tol = 1e-6;

t_s = 0;
t_e = 10*60; %	#10 minutes 
dt = 1;
n = floor(t_e/dt);
t_steps = linspace(t_s,t_e,n+1);

% for storing values
yt = zeros(3,n+1);
yt(:,1) = y0;
% Differential equations
F = @(Y) [
    -0.04*Y(1)+10000*Y(2)*Y(3)
    0.04*Y(1)-10000*Y(2)*Y(3)-3e07*Y(2)^2
    3e07*Y(2)^2
];

relaxationFactor = 1;

% Residual equations for Newton Raphson method
R = @(Y,Ynext) Ynext - Y - dt*(F(Ynext));

for i = 2:n+1
    err = 1;
    old = guess;
    iter = 0;
    while err > tol && iter < max_iter 
        J = fdjac(R, old,guess);
        new = guess - relaxationFactor * (J\R(old,guess));
        err = max(abs(new-guess));
        guess = new;
        iter = iter+1;
    end
    yt(:,i) = new;
end
close all
b = [4.060695630083880e-02     1.968523606662947e-02     1.225548903924852e-03 -8.588160826206462e-07     4.390359279281821e-10 0 1];
model = @(B,x) B(7) - B(1).*sqrt(x) - B(2).*log(B(6)+x) + B(3)*x + B(4)*x.^2 +B(5)*x.^3;

% semilogy(t_steps,yt(1,:))
plot(t_steps,yt(1,:))
hold on
plot(t_steps,yt(2,:))
% semilogy(t_steps,yt(2,:))
hold on
plot(t_steps,yt(3,:))
plot(t_steps, model(b,t_steps))
% semilogy(t_steps,yt(3,:))
legend("y_1","y_2","y_3","model1")


bopt = nlinfit(t_steps(2:end),yt(1,2:end),model,b)

max(abs(model(bopt,t_steps(2:end)) - yt(1,2:end)))
% Numerical Jacobian implementation from https://www.mathworks.com/matlabcentral/answers/407316-how-can-i-take-the-jacobian-of-a-function
function df=njac(f,x,xnext) 
    n=length(x); 
    E=speye(n); 
    e=eps^(1/3); 
    for i=1:n 
        df(:,i)=(f(x,xnext+e*E(:,i))-f(x,xnext-e*E(:,i)))/(2*e); % zentraler Differenzenquotient 
    end 
end

% Forward differences jacobian
function df=fdjac(f,now,next)
    e = 1e-6;
    heye = e*speye(length(next));
    for i = 1:length(next)
        df(:,i) =  (f(now,next+heye(:,i))-f(now,next))/e;
    end
end