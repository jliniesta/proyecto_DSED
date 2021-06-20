% PROYECTO FPGA DSED

% JAVIER LOPEZ INIESTA DIAZ DEL CAMPO
% FERNANDO GARCIA GUTIERREZ

%% ENTRADA DEL AUDIO

[data, fs] = audioread('haha.wav'); % Carga de un fichero .wav en Matlab
file = fopen('sample_in.dat','w'); % Creaccion de otro fichero con el formato que emplea el testbench
fprintf(file, '%d\n', round(data.*127));

%% AUDIO FILTRADO A TRAVÉS DE MATLAB

% Utilizacion de la funcion filter de Matlab para obtener la respuesta de un filtro FIR con precision real
test = filter([0.039, 0.2422, 0.4453, 0.2422, 0.039],[1, 0, 0, 0, 0], data); %Paso Bajo
% test = filter([-0.0078, -0.2031, 0.6015, -0.2031, -0.0078],[1, 0, 0, 0, 0], data); %Paso Alto
sound(test);

file1 = fopen('sample_out_matlab.dat','w'); % Creaccion de otro fichero con el formato que emplea el testbench
fprintf(file1, '%d\n', round(test.*127));

%% AUDIO FILTRADO A TRAVÉS DE VIVADO

% Carga y escucha de un fichero con el formato de salida del testbench en vivado
vhdlout=load('sample_out_vivado.dat')/127;
sound(vhdlout);

%% COMPARACION DE AMBOS AUDIOS FILTRADOS

error = vhdlout(2:end) - test(1:end-1);
hold on
title('Comparacion resultados del testbench con los valores con precision real');
xlabel('Numero de muestras')
plot(test, 'k')
plot(vhdlout, 'b')
plot (error, 'r')
legend('Audio filtrado por Matlab', 'Audio filtrado por vivado', 'Diferencia', 'Location', 'southeast') 
hold off