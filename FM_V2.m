    -% Modulacion/Demodulacion FM./+*
% Alumno: Villalba Julian. ajulianvillalba@gmail.com 
% Profesor: Eneas N. Morel
clc; 
close all; 
clear all;

%Entradas
kf=input('Constante de desviacion de frecuencia: ');
Fc=input('Frecuencia de la portadora (hertz): ');      % hertz 
Fs=input('Frecuencia de Sampleo (hertz): ');
x = input('Tiempo de Grabacion: ');  

%Defino mi vector Tiempo
                                 
tg = x;            % Segundos por muestra

%Objeto de Audio y Señal sin Filtrar
recObj = audiorecorder(Fs,8,1);         
disp('Grabando.')
recordblocking(recObj, x);
disp('Fin grabacion.');
SEntrada=(getaudiodata(recObj))';


%Defino Frecuencias de Corte para el filtro. (Tomo en cuenta las frecuancias que alcanza la voz)

% Filtro para la entrada de la señal....................................
Fpass = 6000;            % Passband Frequency
Fstop = 7000;            % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);
% Filtro para la entrada de la señal....................................



%Aplico el filtro a la señal de entrada
SenialFiltrada = filter(Hd, SEntrada);


%Sampleo la señal *20
senial=resample(SenialFiltrada,20,1);
xs=length(senial);
Fs=Fs*20;
ts = 1/(Fs);
t = (0:ts:tg-ts)'; 
N2=size(t,1);

Portadora=cos(2*Fc*pi*t)';


% Filtro despues de Modular............................................

Fstop1 = Fc-3500;            % First Stopband Frequency
Fpass1 = Fc-3000;            % First Passband Frequency
Fpass2 = Fc+3000;           % Second Passband Frequency
Fstop2 = Fc+3500;           % Second Stopband Frequency
Dstop1 = 0.001;           % First Stopband Attenuation
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.0001;          % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
                          0], [Dstop1 Dpass Dstop2]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd2 = dfilt.dffir(b);
% Filtro despues de Modular............................................


%% Modulacion

integral=cumsum(senial);   %Integro la señal

m_int = kf.*integral;      %Integral por Desviacion de frecuencia  

fmmod = cos(2*Fc*pi*t' + m_int)';
%fmmod=fmmod(senial,Fc,Fs,kf);
fmmod = filter(Hd2, fmmod);


%% Demodulacion
% Para demodular aplico los conceptos de Modulacion de banda angosta. Por
% lo que el Kf debe ser lo suficientemente bajo para que el filtro del
% demodulador (Hd3) tome la señal casi en banda base. Tener en cuenta que
% si mi phi(t) tiende a 0, y, en ese caso, multriplicamos por un seno a la
% frecuencia de la Portadora (Fc), tendremos entonces, nuestro mensaje
% casi en banda base.
%Ver pagina 510 a 513.


%demodulada=fmdemod(fmmod,Fc,Fs,kf);

demodulada=sin(2*pi*Fc*t).*fmmod ;
demodulada=gradient(demodulada);
demodulada=demodulada.*40;



%dem = diff(fmmod);                 
%demodulada = abs(dem);

%demodulada = hilbert(fmmod).*Portadora';
%demodulada=real(demodulada);

% Filtro Pasa Bajo despues de Demodular...................
Fpass = 6000;            % Passband Frequency
Fstop = 7000;            % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd3 = dfilt.dffir(b);
% Filtro Pasa Bajo despues de Demodular...................


% Aplico filtro a la Demodulada
fmdemodFiltrada = filter(Hd3, demodulada);


%% Transformadas de fourier
ffmdemodFiltrada = abs(fftshift(fft(fmdemodFiltrada)));
fportadora = abs(fftshift(fft(Portadora)));
fpmmod = abs(fftshift(fft(fmmod)));
fsenial = abs(fftshift(fft(senial)));

%Resampleo
fmdemodFiltrada = resample(fmdemodFiltrada,1,20);
Fs = Fs/20;


%% Mandale Play

sound(fmdemodFiltrada,Fs);


%% Graficos

figure(5)
subplot(411)
plot(SenialFiltrada);
title('Señal Filtraldra en T');


subplot(412)
plot(fmmod,'m');
title('Señal Modulada en T');
subplot(413)
plot(t(1:300),Portadora(1:300),'k.-');
title('Portadora en T')
subplot(414)
plot(fmdemodFiltrada);
title('Señal Demodulada en T')

figure(3)
subplot(221)
plot(abs(ffmdemodFiltrada)/N2); title('Demodulada en Frecuencia');  
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(222)
plot(abs(fportadora)/N2); title('Portadora en Frecuencia');  
xlabel('Frecuencia');
ylabel('Amplitud');

subplot(223)
plot(abs(fpmmod)/N2,'m'); 
title('Señal modulada en Frecuencia');  
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(224)
plot(abs(fsenial)/N2); title('Señial de entrada');  
xlabel('Frecuencia');
ylabel('Amplitud');
