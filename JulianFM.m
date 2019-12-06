% Alumno: Villalba Julian. ajulianvillalba@gmail.com 
% Profesor: Eneas N. Morel
% UTN Frd

clear all;
close all;
clc;


fs = 44100; %Fq de sampleo para audioread 
fd = 500;   %desviacion de fq
A =1;       %Amplitud
fc =300000; %Frecuencia Portadora
fm=9600;    %Ancho de b. señal.


if fc<50000
    fc=50000;
end

audio=audioread('C:\Users\Julian\Desktop\Fm Comunicaciones\audioDos.wav');
aud=audio(fs*1:fs*4);
[data, fcar] = audioread('C:\Users\Julian\Desktop\Fm Comunicaciones\audioDos.wav');
%sound(data,44100)
data2 = data(:,1);



%Resampleo la señal
data2=resample(data2,20,1);

%Variables
fs=fcar*20;
x = 5*[data2]' ; 
carson=2*(fd+fm);



%Filtro Pasabajo a la entrada (Antes de modular)**********
Fpass = fm;        % Passband Frequency
Fstop = fm+1400;       % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 80;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, fs);
Hd = design(h, 'butter', 'MatchExactly', match);
%******************************************************

%Filtro la señal
x = filter(Hd, x);

%sound(x, fcar);

%Defino el vector Tiempo
t= linspace(0, (length(x)-1)/fs, length(x));



%% Modulacion

%Intedro la señal
s_int = cumsum(x) / fs;


mod = A*cos(2*pi*fc*t + 2*pi*fd*s_int);


%Filtro pasa banda (Despues de Modular)****************************
Fstop1 = (fc-carson/2)-500;        % First Stopband Frequency
Fpass1 = fc-(carson/2);        % First Passband Frequency
Fpass2 = fc+(carson/2);       % Second Passband Frequency
Fstop2 = 500+(fc+carson/2);       % Second Stopband Frequency
Astop1 = 60;          % First Stopband Attenuation (dB)
Apass  = 1;           % Passband Ripple (dB)
Astop2 = 80;          % Second Stopband Attenuation (dB)
match  = 'passband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
                      Astop2, fs);
Hd2 = design(h, 'butter', 'MatchExactly', match);
%*******************************************************************


%Aplico el Filtro despues de Modular
mod = filter(Hd2, mod);
   


%% Demodulacion

%Derivo la señal modulada
derivada = diff(mod);
derivada = [derivada 0];
derivada = abs(derivada); 



%Filtro Pasabajo**************************************
Fpass = 5000;        % Passband Frequency
Fstop = 5500;       % Stopband Frequency
Apass = 1;           % Passband Ripple (dB)
Astop = 80;          % Stopband Attenuation (dB)
match = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, fs);
Hd3 = design(h, 'butter', 'MatchExactly', match);
%****************************************************

demodulada = filter(Hd, derivada);


% centro la señal
s_rmvmn = (demodulada - mean(demodulada));
s_demod = s_rmvmn / max(abs(s_rmvmn));

%% TFF

fmod = abs(fftshift(fft(mod)));       %Modulada
fdemod = abs(fftshift(fft(s_demod))); %Demodulada
fsenial = abs(fftshift(fft(x)));      %Señal de Entrada
%% Transformadas de Fourier y plots

%En Frecuancia 

figure(2)
subplot(3,1,1)
plot(fsenial)
title('Señal de entrada Filtrada')
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(3,1,2)
plot(fmod, 'r')
title('Señal Modulada')
xlabel('Frecuancia');
ylabel('Amplitud');

subplot(3,1,3)
plot(fdemod, 'k')
title('Señal Demodulada')
xlabel('Frecuancia');
ylabel('Amplitud');

%En Tiempo

figure(1)
subplot(3,1,1)
plot(x)
title('Señal de entrada')
xlabel('Tiempo');
ylabel('Amplitud');

subplot(3,1,2)
plot(mod, 'r')
title('Señal Modulada')
xlabel('Tiempo');
ylabel('Amplitud');

subplot(3,1,3)
plot(s_demod, 'k')
axis([0 5e5 -0.05 0.05]);
title('Señal Demodulada')
xlabel('Tiempo');
ylabel('Amplitud');

%% Audio Demodulado
%Resampleo la señal
s_demod=resample(s_demod,1,20);
fs=fs/20;
sound(s_demod*60, fs);