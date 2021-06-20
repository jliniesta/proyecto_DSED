----------------------------------------------------------------------------------
-- Company: Universidad Politectica de Madrid
-- Subject: DSED (Disenos de Sistemas Electronicos Digitales)
-- Engineer: Javier Lopez Iniesta Diaz del Campo and Fernando Garcia Gutierrez
--
-- Create Date: 04.01.2021 16:12:35
-- Module Name: Implementacion fisica y test en placa
-- Design Name: Controlador para la implementacion fisica y test en placa
-- File Name: controlador.vhd
-- Project Name: Sistema de grabación, tratamiento y reproducción de video
-- Target Devices: NEXYS 4 DDR
-- Tool Versions: -
-- Description:  Controlador que modifica el funcionamiento del proyecto
--               en función de los cambios externos.
-- Dependencies: 
-- Revision: v1.0
-- Additional Comments: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.package_dsed.all;

entity controlador_audio is
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
           play_enable : out STD_LOGIC;
           sample_out_AUDIO_INTERFACE : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
           sample_out_ready_AUDIO_INTERFACE : in STD_LOGIC;
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
end controlador_audio;

architecture Behavioral of controlador_audio is

type state_type is (idle, borrar, grabar, memoria_llena, funciones, play_normal, play_alreves, play_LP, play_HP, espera_LP, espera_HP);

signal state, next_state : state_type;
signal filter_select_aux : STD_LOGIC := '0';
signal WP_REG, WP_NEXT : UNSIGNED(18 DOWNTO 0) := (others => '0');
signal RP_REG, RP_NEXT : UNSIGNED(18 DOWNTO 0) := (others => '0');
signal AUX_P_REG, AUX_P_NEXT : UNSIGNED(18 DOWNTO 0) := (others => '0');
signal CONT_REG, CONT_NEXT : UNSIGNED(14 DOWNTO 0) := (others => '0');
signal TIME_RECORDED_REG, TIME_RECORDED_NEXT : UNSIGNED(4 DOWNTO 0) := (others => '0');
signal time_recorded : UNSIGNED(4 DOWNTO 0) := (others => '0');

--converter_bin_ca2
signal bin_in : STD_LOGIC_VECTOR (sample_size - 1 downto 0);
signal ca2_out : SIGNED (sample_size - 1 downto 0);

component converter_bin_ca2
     Port ( bin_in : in STD_LOGIC_VECTOR (sample_size - 1 downto 0);
            ca2_out : out SIGNED (sample_size - 1 downto 0));
end component;


--converter_bin_ca2
signal ca2_in : SIGNED (sample_size - 1 downto 0);
signal bin_out : STD_LOGIC_VECTOR (sample_size - 1 downto 0);

component converter_ca2_bin
     Port ( ca2_in : in SIGNED (sample_size - 1 downto 0);
            bin_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0));
end component;

component rom_display is
    Port (time_recorded : in UNSIGNED(4 DOWNTO 0);
          decenas_disp : out STD_LOGIC_VECTOR (6 downto 0);
          unidades_disp : out STD_LOGIC_VECTOR (6 downto 0));
end component;

signal pitido_out : STD_LOGIC_VECTOR (sample_size - 1 downto 0);

component signal_pitido is
    Port (reset : in STD_LOGIC;
          clk : in STD_LOGIC;
          pitido_out : out STD_LOGIC_VECTOR (sample_size - 1 downto 0));
end component;

begin

uut_converter_bin_ca2: converter_bin_ca2
    PORT MAP (bin_in=>bin_in,
              ca2_out=>ca2_out);

uut_converter_ca2_bin: converter_ca2_bin
    PORT MAP (ca2_in=>ca2_in,
              bin_out=>bin_out);
              
uut_rom_display: rom_display PORT MAP(
              time_recorded => time_recorded,
              decenas_disp => decenas_disp,
              unidades_disp => unidades_disp);
              
uut_signal_pitido: signal_pitido PORT MAP(
                reset => reset,
                clk => clk,
                pitido_out => pitido_out);            
                            
--state and data registers
SYNC_PROC: process (clk, reset)
begin

    if (reset = '1') then -- Si hay un reset se ponen a 0 los registros
        state <= idle;
        RP_REG <= (others => '0');
        WP_REG <= (others => '0');
        AUX_P_REG <= (others => '0');
        TIME_RECORDED_REG <= (others => '0');
        CONT_REG <= (others => '0');
        
    elsif (rising_edge(clk)) then
        state <= next_state;
        RP_REG <= RP_NEXT;
        WP_REG <= WP_NEXT;
        AUX_P_REG <= AUX_P_NEXT;
        CONT_REG <= CONT_NEXT;
        TIME_RECORDED_REG <= TIME_RECORDED_NEXT;
    end if;
    
end process;

--next state logic
OUTPUT_DECODE: process (state, RP_REG, WP_REG, AUX_P_REG, CONT_REG, TIME_RECORDED_REG, sample_out_ready_AUDIO_INTERFACE, sample_out_AUDIO_INTERFACE, sample_request_AUDIO_INTERFACE, Sample_Out_ready_FILTER, Sample_Out_FILTER, ca2_out, bin_out, douta, pitido_out)
begin

   RP_NEXT <= RP_REG;
   WP_NEXT <= WP_REG;
   AUX_P_NEXT <= AUX_P_REG;
   TIME_RECORDED_NEXT <= TIME_RECORDED_REG;
   CONT_NEXT <= CONT_REG;

   -- Se ponen a 0 todas las salidas para evitar latches en el sistema
   record_enable<='0';
   play_enable<='0';
   wea <= "0";
   dina <= (others => '0');
   ena <= '0';
   addra <= (others => '0');
   sample_in_AUDIO_INTERFACE<= (others => '0');
   filter_select <= '0';
   Sample_In_FILTER <= (others => '0');
   Sample_In_enable_FILTER <= '0';
   bin_in <= (others => '0');
   ca2_in <= (others => '0');

    case state is 
        when idle =>
                       
        -- Borrar
        when borrar =>
            -- Se resetean los punteros, poniendolos a 0
            RP_NEXT <= (others => '0'); 
            WP_NEXT <= (others => '0');
            AUX_P_NEXT <= (others => '0');
            TIME_RECORDED_NEXT <= (others => '0');
            CONT_NEXT <= (others => '0');
            
        -- Grabación     
        when grabar =>
            record_enable<='1'; -- Se habilita el record de la interfaz de audio
            wea <= "1";
            -- Se guarda en la RAM cada muestra
            dina <= sample_out_AUDIO_INTERFACE; 
            ena <= sample_out_ready_AUDIO_INTERFACE;
            
            if (sample_out_ready_AUDIO_INTERFACE = '1') then
                WP_NEXT <= WP_REG + 1; --Se incrementa el puntero de escritura cuando se muestrea un dato
                addra <= std_logic_vector(WP_REG + 1); -- Se incrementa la dirección de la RAM
                
                -- MEJORA ADICCIONAL
                if (CONT_REG = 20000) then -- Cada 20000 ciclos (50 us * 20000 = 1s)
                    TIME_RECORDED_NEXT<= TIME_RECORDED_REG +1; -- Se incrementa el tiempo grabado en en 1 (1 segundo)
                    CONT_NEXT <= (others => '0'); -- Se reinicia el contador
                else 
                    CONT_NEXT <= CONT_REG +1; -- Se incrementa el contador 
                end if;
                
            else 
                addra <= std_logic_vector(WP_REG);
            end if;
            
            -- MEJORA ADICCIONAL
            if (TIME_RECORDED_REG = 23) then -- Cuando quedan 3 segundos de
                 play_enable<='1'; -- Se habilita el play de la interfaz de audio
                 sample_in_AUDIO_INTERFACE<= pitido_out; -- Se reproduce un pitido
            end if;
        
        -- Memoria llena (MEJORA ADICCIONAL)     
        when memoria_llena =>
             play_enable<='1'; -- Se habilita el play de la interfaz de audio
             sample_in_AUDIO_INTERFACE<= pitido_out; -- Se reproduce un pitido
             
        when funciones =>
            RP_NEXT <= (others => '0'); --Para empezar a leer (ReadPointer) desde el inicio de la memoria RAM
            AUX_P_NEXT <= WP_REG; -- Se guarda en el registro auxiliar, el valor del registro de escritura
        
        -- Reproducción normal    
        when play_normal => 
            play_enable<='1'; -- Se habilita el play de la interfaz de audio
            -- Se leen las muestras almacenadas en la RAM
            wea <= "0";
            ena <= sample_request_AUDIO_INTERFACE;
            sample_in_AUDIO_INTERFACE<= douta;
            
            if (sample_request_AUDIO_INTERFACE = '1') then
                RP_NEXT <= RP_REG + 1; --Se incrementa el puntero de lectura cuando se ha terminado de reproducir un dato
                addra <= std_logic_vector(RP_REG + 1); -- Se incrementa la dirección de la RAM
            else 
                addra <= std_logic_vector(RP_REG);
            end if;     
              
        -- Reproducción al reves
        when play_alreves => 
            play_enable<='1';  -- Se habilita el play de la interfaz de audio
            -- Se leen las muestras almacenadas en la RAM
            sample_in_AUDIO_INTERFACE<= douta;
            wea <= "0"; -- Lectura
            ena <= sample_request_AUDIO_INTERFACE; 
            
            if (sample_request_AUDIO_INTERFACE = '1') then
                AUX_P_NEXT <= AUX_P_REG - 1; --Se decrementa el puntero auxiliar
                addra <= std_logic_vector(AUX_P_REG - 1); -- Se decrementa la dirección de la RAM
            else 
                addra <= std_logic_vector(AUX_P_REG);
            end if;                 

        -- Reproducción con un filtro paso bajo  
        when play_LP => 
            play_enable<='1';     
            filter_select <= '0';
            -- Se leen las muestras almacenadas en la RAM
            wea <= "0";
            ena <= sample_request_AUDIO_INTERFACE;  
            -- Se convierte el dato en binario (RAM) a complemento a 2 (entrada filtro)
            bin_in <= douta; 
            Sample_In_FILTER <= ca2_out;
            Sample_In_enable_FILTER <= sample_request_AUDIO_INTERFACE;
            -- Se convierte el dato en complementa a 2 (salida filtro) a binario (interfaz de audio)
            ca2_in <= Sample_Out_FILTER; 
            sample_in_AUDIO_INTERFACE <= bin_out;
            addra <= std_logic_vector(RP_REG);
            
        -- Estado de espera del filtro paso bajo  
        when espera_LP =>
            play_enable<='1';     
            filter_select <= '0';
            -- Se leen las muestras almacenadas en la RAM
            wea <= "0";
            ena <= sample_request_AUDIO_INTERFACE;  
            -- Se convierte el dato en binario (RAM) a complemento a 2 (entrada filtro)
            bin_in <= douta; 
            Sample_In_FILTER <= ca2_out;
            Sample_In_enable_FILTER <= sample_request_AUDIO_INTERFACE;
            -- Se convierte el dato en complementa a 2 (salida filtro) a binario (interfaz de audio)
            ca2_in <= Sample_Out_FILTER; 
            sample_in_AUDIO_INTERFACE <= bin_out;
            
            --Se espera 7 ciclos hasta que se termina de filtrar una muestra
            if (Sample_Out_ready_FILTER = '1') then
                RP_NEXT <= RP_REG + 1; --Se incrementa el puntero de lectura
                addra <= std_logic_vector(RP_REG + 1);    
            else 
                addra <= std_logic_vector(RP_REG); -- Se incrementa la dirección de la RAM
            end if; 
            
        -- Reproducción con un filtro paso alto  
       when play_HP =>
            play_enable<='1';     
            filter_select <= '1';
            -- Se leen las muestras almacenadas en la RAM
            wea <= "0";
            ena <= sample_request_AUDIO_INTERFACE;  
            -- Se convierte el dato en binario (RAM) a complemento a 2 (entrada filtro)
            bin_in <= douta; 
            Sample_In_FILTER <= ca2_out;
            Sample_In_enable_FILTER <= sample_request_AUDIO_INTERFACE;
            -- Se convierte el dato en complementa a 2 (salida filtro) a binario (interfaz de audio)
            ca2_in <= Sample_Out_FILTER; 
            sample_in_AUDIO_INTERFACE <= bin_out;
            addra <= std_logic_vector(RP_REG);
            
        when espera_HP =>
            play_enable<='1';     
            filter_select <= '1';
            -- Se leen las muestras almacenadas en la RAM
            wea <= "0";
            ena <= sample_request_AUDIO_INTERFACE;  
            -- Se convierte el dato en binario (RAM) a complemento a 2 (entrada filtro)
            bin_in <= douta; 
            Sample_In_FILTER <= ca2_out;
            Sample_In_enable_FILTER <= sample_request_AUDIO_INTERFACE;
            -- Se convierte el dato en complementa a 2 (salida filtro) a binario (interfaz de audio)
            ca2_in <= Sample_Out_FILTER; 
            sample_in_AUDIO_INTERFACE <= bin_out;
            
            --Se espera 7 ciclos hasta que se termina de filtrar una muestra
            if (Sample_Out_ready_FILTER = '1') then
                RP_NEXT <= RP_REG + 1; --Se incrementa el puntero de lectura cuando se ha terminado de filtrar un dato
                addra <= std_logic_vector(RP_REG + 1); -- Se incrementa la dirección de la RAM
            else 
                addra <= std_logic_vector(RP_REG);
            end if;   
                                   
    end case;
        
end process;


NEXT_STATE_DECODE: process (state, BTNC, BTNL, BTNR, SW0, SW1, RP_REG, WP_REG, AUX_P_REG, sample_request_AUDIO_INTERFACE, Sample_Out_ready_FILTER)
begin

    next_state <= idle;

    case (state) is
        when idle => 
             if (BTNC = '1') then
                 next_state <= borrar;
             elsif (BTNL = '1') then
                if (WP_REG = 524287) then  -- Si esta la memoria llena  
                     next_state <= memoria_llena;
                else 
                     next_state <= grabar;  
                end if; 
             elsif (BTNR = '1') then
                 next_state <= funciones;
             else 
                 next_state <= idle;
             end if;
             
        when borrar =>
             if (BTNC = '1') then
                 next_state <= borrar;     
             else   
                next_state <= idle;
             end if;
             
        when grabar =>
            if (BTNL = '1') then
                if (WP_REG = 524287) then   -- Si se llena la memoria mientras se esta grabando   
                    next_state <= memoria_llena;
                else 
                    next_state <= grabar;  
                end if;
            else    
                next_state <= idle;
            end if;
            
        when memoria_llena =>
            if (BTNL = '1') then
                next_state <= memoria_llena;
            else    
                next_state <= idle;
            end if;
            
        when funciones =>
            if ((SW0 = '0') and (SW1 = '0')) then
                next_state <= play_normal;
            elsif ((SW0 = '1') and (SW1 = '0')) then
                next_state <= play_alreves;
            elsif ((SW0 = '0') and (SW1 = '1')) then
                next_state <= play_LP;
            else 
                next_state <= play_HP;
            end if;

        when play_normal =>
            if ( RP_REG = WP_REG ) then
                next_state <= idle;
            else 
                next_state <=  play_normal;
            end if;
            
        when play_alreves =>
            if ( RP_REG = AUX_P_REG ) then
                next_state <= idle;
            else 
                next_state <=  play_alreves;
            end if;
            
        when play_LP =>
            if (sample_request_AUDIO_INTERFACE = '1') then
                next_state <=  espera_LP;
            else
                next_state <=  play_LP;
            end if;
        
        when espera_LP =>
            if ( Sample_Out_ready_FILTER = '1') then
                if ( RP_REG = WP_REG ) then
                    next_state <= idle;
                else 
                    next_state <=  play_LP;
                end if;
            else 
                next_state <= espera_LP;
            end if;
              
        when play_HP =>
            if (sample_request_AUDIO_INTERFACE = '1') then
                next_state <=  espera_HP;
            else
                next_state <=  play_HP;
            end if;
            
        when espera_HP =>
            if ( Sample_Out_ready_FILTER = '1') then
                if ( RP_REG = WP_REG ) then
                    next_state <= idle;
                else 
                    next_state <=  play_HP;
                end if;
            else 
                next_state <= espera_HP;
            end if;
            
    end case;
end process;

time_recorded <= TIME_RECORDED_REG; 

end Behavioral;
