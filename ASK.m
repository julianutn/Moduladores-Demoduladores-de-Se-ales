% Modulacion/Demodulacion ASK. 
% Alumno: Villalba Julian. ajulianvillalba@gmail.com 
% Profesor: Eneas N. Morel
clc;
clear all;
close all;
vec=[1 0 1 0 1 0 1 1 0 1 1 1 0];                                   
A=5;
x = length(vec);
Fs=10000;
fc = 30;

t = 0:1/Fs:x/10 - 1/Fs;
portadora = cos(2*pi*fc*t);
plot(portadora)
bits=[];
for n=1:1:length(vec)
    if vec(n)==1
       bit=ones(1,1000);
       bit=bit*A;
    else vec(n)==0
        bit=zeros(1,1000);
        
    end
    
     bits=[bits bit];
end

modulada= bits.*portadora;
plot(modulada)

demo= modulada.*portadora;

%Filtro ...................................

N     = 100;   % Order
Fpass = 30;    % Passband Frequency
Fstop = 31;  % Stopband Frequency
Wpass = 1;    % Passband Weight
Wstop = 1;    % Stopband Weight
dens  = 20;   % Density Factor

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, [0 Fpass Fstop Fs/2]/(Fs/2), [1 1 0 0], [Wpass Wstop], ...
           {dens});
Hd = dfilt.dffir(b);

%........................................
demofilter=filter(Hd,demo);
j = length(demofilter);

contador = 0;
acumulador = 0;
demod = [];

for n=1:j+1
    if (contador == 100)
        contador = 0;
        acumulador = acumulador/100;
        if acumulador > 0.5
            bitdemod = ones(1,100);
            demod = [demod bitdemod];
        else 
            bitdemod = zeros(1,100);
            demod = [demod bitdemod];
            
        end
        acumulador = 0;
    end
    if n<=j
        contador = contador + 1;
        acumulador = acumulador + demofilter(n);
    end
end


%% Graficos
figure(2)
subplot(311)
plot(demo)
title('Demodulada')
subplot(312)
plot(demofilter*A)
title('Demodulada Filtrada')
subplot(3,1,3)
plot(demod*A,'LineWidth',1.5);grid on;
title('Demodulada Reconstruida')

figure(1)
subplot(3,1,1);
axis([0 100*length(vec) -(A+2) A+2]);
plot(bits,'lineWidth',1.5);grid on;
ylabel('Amplitud');
xlabel('Tiempo');
title('Señal');
subplot(3,1,2)
plot(modulada)
title('Modulada')
subplot(3,1,3)
plot(portadora)
title('Portadora')

