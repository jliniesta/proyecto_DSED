----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 30.12.2020 23:25:08
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Controlador para la implementacion fisica y test en placa
-- File Name: dsed_audio.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description: Archivo final que se implementa en la placa con todos los 
--              componentes anteriores.
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity dsed_audio is
    Port ( clk_100Mhz : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           -- Control ports
           BTNL : in STD_LOGIC;
           BTNC : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           SW0 : in STD_LOGIC;
           SW1 : in STD_LOGIC;
           
           -- Display
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);

          --To/From the microphone
           micro_clk : out STD_LOGIC;
           micro_data : in STD_LOGIC;
           micro_LR : out STD_LOGIC;
           
          --To/From the mini-jack
           jack_sd : out STD_LOGIC;
           jack_pwm : out STD_LOGIC);
end dsed_audio;

architecture Behavioral of dsed_audio is

component clk_wiz_12Mhz is 
    Port (reset : in STD_LOGIC;
          clk_in1 : in STD_LOGIC;
          clk_out1 : out STD_LOGIC);
end component;

component audio_interface is
    Port (clk_12megas : in STD_LOGIC;
          reset : in STD_LOGIC;
           
          --Recording ports
          --To/From the controller
          record_enable : in STD_LOGIC;
          sample_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0);
          sample_out_ready : out STD_LOGIC;
           
          --To/From the microphone
          micro_clk : out STD_LOGIC;
          micro_data : in STD_LOGIC;
          micro_LR : out STD_LOGIC;

          --Playing ports
          --To/From the controller
          play_enable : in STD_LOGIC;
          sample_in : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
          sample_request : out STD_LOGIC;
           
          --To/From the mini-jack
          jack_sd : out STD_LOGIC;
          jack_pwm : out STD_LOGIC);
end component;

component fir_filter is
    Port (clk : in STD_LOGIC;
          Reset : in STD_LOGIC;
          Sample_In : in signed (sample_size - 1 downto 0);
          Sample_In_enable : in STD_LOGIC;
          filter_select : in STD_LOGIC;
          Sample_Out : out signed (sample_size - 1 downto 0);
          Sample_Out_ready : out STD_LOGIC);
end component;

component ram_mem_project is
     PORT (clka : IN STD_LOGIC;
           ena : IN STD_LOGIC;
           wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
           addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
           dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
           douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
end component;

component controlador_audio is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           
           -- Control ports
           BTNL : in STD_LOGIC;
           BTNC : in STD_LOGIC;
           BTNR : in STD_LOGIC;
           SW0 : in STD_LOGIC;
           SW1 : in STD_LOGIC;
           
           -- Display
           decenas_disp : out STD_LOGIC_VECTOR (6 downto 0);
           unidades_disp : out STD_LOGIC_VECTOR (6 downto 0);
                      
           -- AUDIO INTERFACE
           record_enable : out STD_LOGIC;
           sample_out_AUDIO_INTERFACE : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_out_ready_AUDIO_INTERFACE : in STD_LOGIC;
           play_enable : out STD_LOGIC;
           sample_in_AUDIO_INTERFACE : out STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_request_AUDIO_INTERFACE : in STD_LOGIC;
           
           -- FILTER
           Sample_In_FILTER : out signed (sample_size - 1 downto 0);
           Sample_In_enable_FILTER : out STD_LOGIC;
           filter_select : out STD_LOGIC;
           Sample_Out_FILTER : in signed (sample_size - 1 downto 0);
           Sample_Out_ready_FILTER : in STD_LOGIC;
           
           -- RAM
           ena : out STD_LOGIC;
           wea : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
           addra : out STD_LOGIC_VECTOR(18 DOWNTO 0);
           dina : out STD_LOGIC_VECTOR(sample_size - 1 DOWNTO 0);
           douta : in STD_LOGIC_VECTOR(sample_size - 1 DOWNTO 0));
end component;

component cont_disp is
     PORT (clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           unidades_disp : in STD_LOGIC_VECTOR (6 downto 0);
           decenas_disp : in STD_LOGIC_VECTOR (6 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0));
end component;

--signal declaration
signal clk_12megas: STD_LOGIC;
signal play_enable_aux: STD_LOGIC;
signal record_enable_aux: STD_LOGIC;
signal sample_in_audio_interface: STD_LOGIC_VECTOR (sample_size - 1 downto 0);
signal sample_in_filter: signed (sample_size - 1 downto 0);
signal sample_in_enable_filter: STD_LOGIC;
signal filter_select: STD_LOGIC;
signal ena: STD_LOGIC;
signal wea: STD_LOGIC_VECTOR(0 DOWNTO 0);
signal addra: STD_LOGIC_VECTOR(18 DOWNTO 0);
signal dina: STD_LOGIC_VECTOR(sample_size - 1 downto 0);
signal sample_request_audio_interface: STD_LOGIC;
signal sample_out_audio_interface: STD_LOGIC_VECTOR (sample_size - 1 downto 0);
signal sample_out_ready_audio_interface: STD_LOGIC;
signal sample_out_filter: signed (sample_size - 1 downto 0);
signal sample_out_ready_filter: STD_LOGIC;
signal douta: STD_LOGIC_VECTOR(sample_size - 1 downto 0);
signal unidades_disp: STD_LOGIC_VECTOR(6 DOWNTO 0);
signal decenas_disp: STD_LOGIC_VECTOR(6 DOWNTO 0);


begin

uut_clk_wiz: clk_wiz_12Mhz PORT MAP(
        reset => reset,
        clk_in1 => clk_100Mhz,
        clk_out1 => clk_12megas);
    
uut_audio_interface : audio_interface PORT MAP(
        clk_12megas => clk_12megas,
        reset => reset,
        record_enable => record_enable_aux,
        sample_out => sample_out_audio_interface,
        sample_out_ready => sample_out_ready_audio_interface,
        micro_clk => micro_clk,
        micro_data => micro_data,
        micro_LR => micro_LR,
        play_enable => play_enable_aux,
        sample_in => sample_in_audio_interface,
        sample_request => sample_request_audio_interface,
        jack_sd => jack_sd,
        jack_pwm => jack_pwm);
        
uut_fir_filter: fir_filter PORT MAP(
        clk=>clk_12megas,
        Reset=> reset,
        Sample_In=> sample_in_filter,
        Sample_In_enable=> sample_in_enable_filter,
        filter_select=> filter_select,
        Sample_Out=> sample_out_filter,
        Sample_Out_ready=> sample_out_ready_filter);
        
uut_ram: ram_mem_project PORT MAP(
        clka => clk_12megas,
        ena => ena,
        wea => wea, 
        addra => addra,
        dina => dina,
        douta => douta);
        
uut_controlador_audio : controlador_audio PORT MAP(
        clk => clk_12megas,
        reset => reset,
        BTNL => BTNL,
        BTNC => BTNC,
        BTNR => BTNR,
        SW0 => SW0,
        SW1 => SW1,
        decenas_disp => decenas_disp,
        unidades_disp => unidades_disp,
        record_enable => record_enable_aux,
        play_enable => play_enable_aux,
        sample_out_AUDIO_INTERFACE => sample_out_audio_interface,
        sample_out_ready_AUDIO_INTERFACE => sample_out_ready_audio_interface,
        sample_in_AUDIO_INTERFACE => sample_in_audio_interface,
        sample_request_AUDIO_INTERFACE => sample_request_audio_interface,
        Sample_In_FILTER => sample_in_filter,
        Sample_In_enable_FILTER => sample_in_enable_filter,                
        filter_select => filter_select,
        Sample_Out_FILTER => sample_out_filter,
        Sample_Out_ready_FILTER => sample_out_ready_filter,
        ena => ena,
        wea => wea,
        addra => addra,
        dina => dina,
        douta => douta);

uut_controlador_disp: cont_disp PORT MAP(
        clk=>clk_12megas,
        reset=>reset,
        unidades_disp=> unidades_disp,
        decenas_disp=> decenas_disp,
        seg=> seg,
        an=> an);

end Behavioral;
