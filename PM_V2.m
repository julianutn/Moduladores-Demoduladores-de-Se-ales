% Modulacion/Demodulacion PM.
% Alumno: Villalba Julian. ajulianvillalba@gmail.com 
% Profesor: Eneas N. Morel
clc; 
close all; 
clear all;

%Entradas
kp=input('Constante de desviacion de fase: ');
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

%Filtro de entrada........................................
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
%Filtro de entrada........................................


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



% Filtro modulada .......................................
Fpass = Fc + 7000;            % Passband Frequency
Fstop = Fc + 8000;            % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor


% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd2 = dfilt.dffir(b);
% Filtro modulada .......................................

%% Modulacion

pmmod = cos(2*Fc*pi*t' + kp.*senial);

pmmod = filter(Hd2, pmmod);

%% Demodulacion
% Para demodular aplico los conceptos de Modulacion de banda angosta. Por
% lo que el Kp debe ser lo suficientemente bajo para que el filtro del
% demodulador (Hd3) tome la señal casi en banda base. Tener en cuenta que
% si mi phi(t) tiende a 0, y, en ese caso, multriplicamos por un seno a la
% frecuencia de la Portadora (Fc), tendremos entonces, nuestro mensaje
% casi en banda base.

pmdemod=sin(2*pi*Fc*t').*pmmod ;
pmdemod=pmdemod.*40;

%derivada_pm = gradient(pm);
%yq = hilbert(mensaje).*exp(-1i*2*pi*fc*t);
%pmmod=gradient(pmmod);

%Filtro para demodulada...........................................
Fstop1 = 200;         % First Stopband Frequency
Fpass1 = 500;         % First Passband Frequency
Fpass2 = 6000;        % Second Passband Frequency
Fstop2 = 7000;        % Second Stopband Frequency
Astop1 = 60;          % First Stopband Attenuation (dB)
Apass  = 1;           % Passband Ripple (dB)
Astop2 = 80;          % Second Stopband Attenuation (dB)
match  = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
                      Astop2, Fs);
Hd3 = design(h, 'butter', 'MatchExactly', match);
%Filtro para demodulada...........................................

pmdemodFiltrada = filter(Hd3, pmdemod);



%% Transformadas de Fourier
fpmdemod = abs(fftshift(fft(pmdemodFiltrada)));
fportadora = abs(fftshift(fft(Portadora)));
fpmmod = abs(fftshift(fft(pmmod)));
fsenial = abs(fftshift(fft(senial)));
pmdemodFiltrada = resample(pmdemodFiltrada,1,20)*10;
Fs = Fs/20;


%% Mandale Play
sound(pmdemodFiltrada,Fs);


%% Graficos

figure(5)
subplot(311)
plot(SenialFiltrada);
title('Señal Filtraldra en T');
axis([0 length(pmdemodFiltrada) -0.1 0.1]);

subplot(312)
plot(t(1:8000),pmmod(1:8000),'m');
title('Señal Modulada en T');


subplot(313)
plot(pmdemodFiltrada);
title('Señal Demodulado en T');
axis([0 length(pmdemodFiltrada) -0.3 0.3]);

figure(3)
subplot(221)
plot(abs(fpmdemod)/N2); title('Demodulada en Frecuencia');  
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(222)
plot(abs(fportadora)/N2); title('Portadora en Frecuencia');  
xlabel('Frecuencia');
ylabel('Amplitud');

subplot(223)
plot(abs(fpmmod)/N2,'m'); title('Señal modulada en Frecuencia');  
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(224)
plot(abs(fsenial)/N2); title('Señial de entrada');  
xlabel('Frecuencia');
ylabel('Amplitud');


