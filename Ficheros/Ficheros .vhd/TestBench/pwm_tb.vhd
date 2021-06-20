----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 27.11.2020 12:52:31
-- Module Name: Interfaz de la salida de audio
-- Design Name: Generacion de la señal PWM 
-- File Name: pwm.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Comprobacion que el contador cuente cada dos ciclos, que la cuenta se 
--              reinicia al llegar a 299 y que el valor de las señales pwm_pulse y de 
--              sample_request es el esperado
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: Para comprobar el correcto funcionamiento, se han introducido 
--                      en sample_in los valores extremos ("00000000" y "11111111") y 
--                      del valor aleatorio intermedio ("11001101")
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity pwm_tb is
end pwm_tb;

architecture Behavioral of pwm_tb is

--components declarations
component pwm 
    Port ( 
           clk_12megas : in STD_LOGIC;
           reset : in STD_LOGIC;
           en_2_cycles : in STD_LOGIC;
           sample_in : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_request : out STD_LOGIC;
           pwm_pulse : out STD_LOGIC);
end component;

component en_4_cycles
    Port ( 
            clk_12megas : in STD_LOGIC;
            reset : in STD_LOGIC;
            clk_3megas : out STD_LOGIC;
            en_2_ciclos : out STD_LOGIC;
            en_4_ciclos : out STD_LOGIC);
end component;

--input signal declaration
signal reset, clk_12megas: STD_LOGIC := '0';
signal sample_in: STD_LOGIC_VECTOR (sample_size - 1 downto 0) := (others => '0');

--output signals declaration
signal sample_request, clk_3megas, en_2_cycles, pwm_pulse, en_4_ciclos : STD_LOGIC := '0';

-- Clock period definitions
constant clk_period : time := 83.33 ns; -- Periodo de 12 MHz

begin

uut_enable: en_4_cycles
    PORT MAP (
        reset=>reset,
        clk_12megas=>clk_12megas,
        clk_3megas=>clk_3megas,
        en_2_ciclos=>en_2_cycles,
        en_4_ciclos=>en_4_ciclos);

uut_pwm : pwm
    PORT MAP (
        reset=>reset,
        clk_12megas=>clk_12megas,
        en_2_cycles=>en_2_cycles,
        sample_in=>sample_in,
        sample_request=>sample_request,
        pwm_pulse=>pwm_pulse);
    
-- Clock process definitions( clock with 50% duty cycle)
clk_process :process
begin
    clk_12megas <= '0';
    wait for clk_period/2;
    clk_12megas <= '1';
    wait for clk_period/2;
end process;

-- Stimulus process
stim_proc: process
begin
    reset<='1';
    wait for 5 us;
    reset<='0';
    sample_in <= "00000000"; -- Valor extremo
    wait for 30 us;      
    sample_in <= "11111111"; -- Valor extremo
    wait for 30 us;  
    sample_in <= "11001101"; -- Valor aleatorio intermedio   
    wait for 500 us;      
end process;

end Behavioral;
