% Modulacion/Demodulacion AM Portadora. 
% Alumno: Villalba Julian. ajulianvillalba@gmail.com 
% Profesor: Eneas N. Morel

clc; 
close all; 
clear all;

%Entradas
im=input('Indice de Modulacion: ');
Fc=input('Frecuencia de la portadora: ');      % hertz 
Fs=input('Frecuencia de Sampleo: ');
x = input('Tiempo de Grabacion: ');  

%Defino mi vector Tiempo
                                 
tg = x;             % Segundos por muestra


%Objeto de Audio y Se�al sin Filtrar
recObj = audiorecorder(Fs,8,1);         
disp('Grabando.')
recordblocking(recObj, x);
disp('Fin grabacion.');
SEntrada=(getaudiodata(recObj))';


%Defino Frecuencias de Corte para el filtro. (Tomo en cuenta las frecuancias que alcanza la voz)
FreqArranque = 1000 / (Fs/2);
FreqCorte = 4000 / (Fs/2);

[num1,dem1] = butter(6, [FreqArranque, FreqCorte], 'bandpass');    %Creo un filtro pasabanda de orden 6 con las frecuncias mencioandas
[num2,dem2]=freqz(num1,dem1);                                      %Respuesta en frecuancia del filtro (lo uso para graficar)


%Aplico el filtro a la se�al de entrada
SenialFiltrada = filter(num1, dem1, SEntrada);

%Resampleo la Se�al Filtrada, Redefino mi Fs y armo mi verctor t
senial=resample(SenialFiltrada,20,1);
xs=length(senial);
Fs=Fs*20;
ts = 1/(Fs);
t = (0:ts:tg-ts)'; 
N2=size(t,1);   

Portadora=0.1*cos(2*Fc*pi*t)';

%% Modulacion
% Modulo se�al Filtrada con Gran Portadora xam = [Ac+|min.m'normalizado'(t)|*m(t)]*cos(wct)
%Brice�o Pag. 470. Donde |min.m'normalizado'(t)| = 1 , entonces: Ac=1/(ind. de modulacion)  
%Sino im=(Vmax - Vmin)/(Vmax + Vmin)  o im=Em/Ec
plot(t(1:300),Portadora(1:300),'k.-');

senialn=(senial + (abs(min(senial)))-1);

A = 1/im;
Modulada = (A+senialn).*Portadora;

%Filtro la se�al Modulada
FreqArranque = (Fc-4000) / (Fs/2);
FreqCorte = (Fc+4000) / (Fs/2);

[numM,demM] = butter(6, [FreqArranque, FreqCorte], 'bandpass');      %Creo un filtro pasabanda de orden 6 con las frecuncias mencioandas
                                 
Modulada = filter(numM,demM, Modulada);

%% Demodulacion
Demodulada = Modulada.*Portadora;
% Filtro la se�al Demodulada
N     = 12;    % Order
Fpass = 4000;  % Passband Frequency
Fstop = 4200;  % Stopband Frequency
Wpass = 1;     % Passband Weight
Wstop = 1;     % Stopband Weight
dens  = 20;    % Density Factor

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, [0 Fpass Fstop Fs/2]/(Fs/2), [1 1 0 0], [Wpass Wstop], ...
           {dens});
Hd = dfilt.dffir(b);

DemoFiltrada = filter(Hd,Demodulada);

%Transformadas de Fourier
fPortadora = (fftshift(fft(Portadora)));
fSenialFil = (fftshift(fft(Modulada)));
fSenial = (fftshift(fft(senial)));
fDemod = (fftshift(fft(DemoFiltrada)));
freq = -Fs/2:(Fs/N2):(Fs/2)-(Fs/N2);


%Resampleo de Demodulacion, Redefino mi Fs 
dem=resample(DemoFiltrada,1,20);
Fs=Fs/20;

%% Audio
sound(dem*20,Fs,8);


%% Graficos 
figure(3)
subplot(221)
plot(freq,abs(fDemod)/N2); title('Demodulada en Frecuencia');  
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(222)
plot(freq,abs(fPortadora)/N2); title('Portadora en Frecuencia');  
xlabel('Frecuencia');
ylabel('Amplitud');

subplot(223)
plot(freq,abs(fSenialFil)/N2); title('Se�al Modulada en Frecuencia');  
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(224)
plot(freq,abs(fSenial)/N2); title('Se�ial de entrada');  
xlabel('Frecuencia');
ylabel('Amplitud');

figure(4)
subplot(312)
plot(Modulada);
title('Modulada')
subplot(311)
plot(SenialFiltrada)
title('Se�al de entrada')
subplot(313)
plot(DemoFiltrada)
title('Demodulada')



