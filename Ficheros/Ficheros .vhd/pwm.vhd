----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 26.11.2020 18:48:57
-- Module Name: Interfaz de la salida de audio
-- Design Name: Generacion de la señal PWM 
-- File Name: pwm.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Generacion de una señal PWM, dependiendo del valor de entrada, y el valor 
--              de la cuenta, se activaran la salidas correspondientes para producir una 
--              modulacion por ancho de pulsos.
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: La salida, pwm_pulse, siempre que la cuenta sea menor que la señal
--                      de entrada, sample_in. Por otra parte, Cada vez que el modulo llegue 
--                      al final de la cuenta (299) y se reinicie, proporciona un  pulso 
--                      activo en sample_request de un periodo de reloj, para solicitar una
--                      nueva muestra a la entrada.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity pwm is
    Port ( clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_2_cycles : in STD_LOGIC;
           sample_in : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_request : out STD_LOGIC;
           pwm_pulse : out STD_LOGIC);
end pwm;

architecture Behavioral of pwm is

signal r_reg, r_next : UNSIGNED (sample_size downto 0);
signal buf_reg, buf_next : STD_LOGIC := '0';

begin

-- register & output buffer
process (clk_12megas, reset)
begin
if reset='1' then
    r_reg <= (others => '0');
    buf_reg <= '0';
elsif (rising_edge(clk_12megas)) then
    if (en_2_cycles = '1') then
        r_reg <= r_next;
        buf_reg <= buf_next;
    end if;
end if;

end process;

-- next state logic
process(r_reg, en_2_cycles)
begin
    -- Contador de 0 a 299 ( 50 us )
    if (r_reg = 299) then
        r_next <= (others => '0');
        if (en_2_cycles = '1') then
            sample_request <= '1'; -- pulso en sample request para solicitar una nueva muestra en la entrada
        else 
            sample_request <= '0';
        end if;              
    else
        r_next <= r_reg + 1; -- Se incrementa el contador
        sample_request <= '0';
    end if;
end process;

-- output logic
buf_next <= 
    --La salida del contador se compara con la palabra digital que se quiere convertir
    '1' when (r_reg < unsigned(sample_in)) else -- Si es mas pequeño, se pone la salida PWM a 0
    '0'; -- Si es mas grande, se pone la salida PWM a 1

pwm_pulse <= buf_reg;

end Behavioral;
