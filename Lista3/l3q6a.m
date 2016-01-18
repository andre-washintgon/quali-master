% % LMS complexo
% e(k) = d(k) -w^H (k) x(k);
% w(k+1) = w(k) + mu_c * conjugated(e) * (k) * x(k)

% % NRMS
% % Inicializa
% x(0) = w(0) = [ 0 0 .. 0]^T
% mu_n no intervalo 0< mu_n <= 2
% gama  const. pequeno
% 
% % para k> 0:
% e(k) = d(k) - x^T (k) *w(k)
% w(k+1) = w(k) + mu_n/ (gama + x^T(k) * x(k) ) * e(k) * x(k)

clear all
clf (figure(1))
clf (figure(2))

rep = 500; % numero de repeti��es
SNR = 30;
% n_var_4qam = 10^-3;

mu_n = 0.1;
% gama = 10^-9; 
   
% sinal 4 qam
constelation = [1+1i,1-1i,-1+1i,-1-1i];
data  = ceil(4*rand(rep,1));
s = transpose(constelation(data));  % sinal de treinamento

% n = n_var_4qam*randn(1,rep); %ru�do


H_num = [0.5 1.2 1.5 -1];
H_den = 1;
sh = filter(H_num, H_den, s);
n_var_4qam = var(sh) * 10^(-SNR/10);
    
%ru�do deve ser complexo e a variancia divida para cada parte (real/imag)
n = sqrt(n_var_4qam/2)*(randn(1,rep)+1i*(randn(1, rep)));
% transposte deve ser usada no lugar do hermitiano
x=sh+transpose(n); % sinal desejado na entrada do equalizador + ruido

% part I: trainning.
w(1,1:4) = 0; 
% xw(1,4) = 0;
xr = zeros(1, 4);
passo = 0.19;
gama = 10^(-6);
for k=5:rep
   
    xr = [x(k) xr(1:4-1)]; % varre os elementos de x
    xw = xr*w';
    e=s(k-4) - xw; %xr * w';
    erro(k)=e;
    w = w + passo * xr * conj(e) / (xr * xr' + gama);
end


figure(1)
plot(1:500,real(erro.*erro));
xlabel('plot(e.*e)');

% part II: decision block included. 

rep = 5000;
% sinal 16 qam
constelation2 = [ 
1+1i,1-1i,-1+1i,-1-1i, 2+1i,2-1i,-2+1i,-2-1i, 1+2i,1-2i,-1+2i,-1-2i, 2+2i,2-2i,-2+2i,-2-2i ];
data  = ceil(16*rand(rep,1));
s2 = transpose(constelation2(data));  % sinal de entrada

sh2 = filter(H_num, H_den, s2);
n_var_4qam = var(sh2) * 10^(-SNR/10);
    
%ru�do deve ser complexo e a variancia divida para cada parte (real/imag)
n = sqrt(n_var_4qam/2)*(randn(1,rep)+1i*(randn(1, rep)));
% transposte deve ser usada no lugar do hermitiano
x2=sh2+transpose(n); % sinal desejado na entrada do equalizador + ruido
 xr = zeros(1, 4);
 xd =  zeros(1,4995);
 for k=5:rep
    xr = [x2(k) xr(1:4-1)]; % varre os elementos de x
    xw = xr*w';
    xd(k) = round(real(xw)) + round(imag(xw))*1i ;% decision  
    if(real(xd(k))>2)
        xd(k)=2+imag(xd(k))*1i;
    end
    if(real(xd(k))<-2)
        xd(k)= -2 + imag(xd(k))*1i;
    end
    if(imag(xd(k))>2)
        xd(k)= real(xd(k)) + 2i;
    end
    
    if(imag(xd(k))<-2)
        xd(k)= real(xd(k)) - 2i;
    end
    
    e= xd(k) - xw;
    erro(k)=e;
    w = w + passo * xr * conj(e) / (xr * xr' + gama);
    

 end
 
 figure(2)
plot(1:5000,real(erro.*erro),'red');
 axis([-1 600 -1 1]);
xlabel('plot(e.*e)');


[num, rate ]= biterr(abs(real(s2))',abs(real(xd)))
