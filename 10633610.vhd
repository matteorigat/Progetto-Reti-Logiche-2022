library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_reti_logiche is
     Port( 
            i_clk     : in  std_logic; 					-- Segnale di CLOCK in ingresso dal TestBench
            i_start   : in  std_logic;					-- Segnale di START generato dal TestBench
            i_rst     : in  std_logic;				     -- Segnale di RESET che inizializza la macchina pronta per ricevere il primo segnale di START
            i_data    : in  std_logic_vector(7 downto 0);	-- Segnale che arriva dalla memoria in seguito ad una richiesta di lettura
            o_address : out std_logic_vector(15 downto 0);	-- Segnale di uscita che manda l'indirizzo alla memoria
            o_done    : out std_logic;					-- Segnale di uscita che comunica la fine dell'elaborazione e il dato di uscita scritto in memoria
            o_en      : out std_logic;					-- Segnale di ENABLE da dover mandare alla memoria per poter comunicare(sia in lettura che scrittura)
            o_we      : out std_logic;					-- Segnale WRITE ENABLE da dover mandare alla memoria per poter scriverci.
            o_data    : out std_logic_vector (7 downto 0) 	-- Segnale di uscita dal componente verso la memoria 
        );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

type state_type is (rst, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, final);
signal state, pre_state: state_type;  -- State è lo stato corrente, pre_state tiene traccia dell'ultimo stato del convolutore visitato

signal i : integer range -1 to 7;     -- Conta gli 8 bit della parola in ingresso per poi finire la codifica se i=-1
signal j : integer range 0 to 15;     -- Conta i 16 bit dello stream di uscita salvato in risultato
signal val : integer range 0 to 255;  -- Lunghezza sequenza di ingresso

signal parola : std_logic_vector(7 downto 0) := (others => '0');        -- Salva la parola in ingresso
signal risultato : std_logic_vector(15 downto 0) := (others => '0');    -- Salva le due parole di uscita
signal in_address : std_logic_vector(15 downto 0) := (others => '0');   -- Tiene traccia dell'ultimo indirizzo di lettura
signal out_address : std_logic_vector(15 downto 0) := (others => '0');  -- Tiene traccia dell'ultimo indirizzo di scrittura

begin

process(i_clk, i_rst)

begin

if i_rst = '1' then -- segnale RESET --> inizializza

    o_en <= '0';
    o_we <= '0';
    o_done <= '0';
    
    out_address <= "0000001111101000"; -- 1000
    in_address <= "0000000000000001";

    state <= rst;

elsif i_clk'event and i_clk = '1' then

    if state = rst then  -- Segnale START --> salto incondizionato e richiesta indirizzo memoria 0
        
        if i_start = '1' then

            o_en <= '1';
            o_address <= "0000000000000000";
            o_we <= '0';
            o_done <= '0';
            pre_state <= s3;
            state <= s0;
        else 
            state <= rst;
        end if;

    elsif state = s0 then  -- Attendo RAM e richiesta indirizzo memoria 1
        
        o_en <= '1';
        o_address <= "0000000000000001";
        o_we <= '0';
        o_done <= '0';
        state <= s1;

    elsif state = s1 then  -- Leggo valore iniziale all'indirizzo 0
        
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';

        val <= to_integer(unsigned(i_data));
        
        if i_data = "00000000" then -- Nessuna parola da leggere vado in stato finale
            state <= final;
        else 
            state <= s2; 
        end if;         

    elsif state = s2 then   -- Lettura parola

        o_en <= '0';
        o_we <= '0'; 
        o_done <= '0';

        parola <= i_data;
        val <= val - 1;

        i <= 7;   -- inizializzo indici per il ciclo di convoluzione
        j <= 15;

        state <= pre_state;

    elsif state = s3 then   -- Stato 0 convolutore (s3 s4 s5 s6)
        
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';

        if i = -1 then     -- Ho codificato 8 bit della parola, vado a stampare
             state <= s7;
             pre_state <= s3;  -- Tengo memoria dell'ultimo stato

        elsif parola(i) = '0' then
              risultato(j) <= '0';
              risultato(j-1) <= '0';
              state <= s3;
        else
              risultato(j) <= '1';
              risultato(j-1) <= '1';
              state <= s5;
        end if;

        i <= i - 1;
        j <= j - 2;
          
    elsif state = s4 then    -- Stato 1 convolutore
         
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
         
        if i = -1 then 
             state <= s7;
             pre_state <= s4;
      
        elsif parola(i) = '0' then
              risultato(j) <= '1';
              risultato(j-1) <= '1';
              state <= s3;
        else
              risultato(j) <= '0';
              risultato(j-1) <= '0';
              state <= s5;
        end if;

        i <= i - 1;
        j <= j - 2;

    elsif state = s5 then    -- Stato 2 convolutore
        
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';

        if i = -1 then 
             state <= s7;
             pre_state <= s5;
      
        elsif parola(i) = '0' then
              risultato(j) <= '0';
              risultato(j-1) <= '1';
              state <= s4;
        else
              risultato(j) <= '1';
              risultato(j-1) <= '0';
              state <= s6;
        end if;

        i <= i - 1;
        j <= j - 2;

    elsif state = s6 then    -- Stato 3 convolutore
       
       o_en <= '0';
       o_we <= '0';
       o_done <= '0';

        if i = -1 then 
             state <= s7;
             pre_state <= s6; 
      
        elsif parola(i) = '0' then
             risultato(j) <= '1';
             risultato(j-1) <= '0';
             state <= s4;
        else
             risultato(j) <= '0';
             risultato(j-1) <= '1';
             state <= s6;
        end if;

        i <= i - 1;
        j <= j - 2;

    elsif state = s7 then    -- Stampo il primo output, 8 bit
       
        o_en <= '1';
        o_we <= '1';
        o_done <= '0'; 

        o_data <=  risultato(15 downto 8);
        o_address <= out_address;

        in_address <= in_address + "0000000000000001";

        state <= s8;

    elsif state = s8 then  -- Stampo il secondo output, altri 8 bit
        
        o_en <= '1';
        o_we <= '1';
        o_done <= '0';

        o_data <=  risultato(7 downto 0);
        o_address <= out_address + "0000000000000001";

        if val = 0 then
            state <= final;  -- Non ho altre parole, vado in stato finale
        else
            state <= s9;  -- Vado a leggere la prossima parola
        end if;
    
    elsif state = s9 then  -- Richiesta indirizzo memoria prossima parola
        
        o_en <= '1';
        o_address <= in_address;
        o_we <= '0';
        o_done <= '0';

        out_address <= out_address + "0000000000000010";

        state <= s10;

    elsif state = s10 then  -- Attendo RAM per leggere la prossima parola
        
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        state <= s2;

    elsif state = final then  -- Stato finale, porto DONE alto e attendo che i_start vada a 0

       if i_start = '0' then
            o_en <= '0';
            o_we <= '0';
            o_done <= '0';

            out_address <= "0000001111101000"; -- 1000
            in_address <= "0000000000000001";

            state <= rst;
        else
            o_en <= '0';
            o_we <= '0';
            o_done <= '1';

            state <= final;
        end if;
    
    end if;

end if; -- rising clock       

end process;

end Behavioral;
