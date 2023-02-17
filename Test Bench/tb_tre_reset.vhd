-- test : consecutive runs con reset sul primo 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD         : time := 100 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;

type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
                         
signal i : std_logic_vector(1 downto 0) := "00";

signal RAM: ram_type := (0 => std_logic_vector(to_unsigned(  3  , 8)), 
                         1 => std_logic_vector(to_unsigned(  248  , 8)), 
                         2 => std_logic_vector(to_unsigned(  112  , 8)),   
                         3 => std_logic_vector(to_unsigned(  39  , 8)),        
                         others => (others =>'0'));
                         
signal RAM1: ram_type := (0 => std_logic_vector(to_unsigned(  3  , 8)), 
                         1 => std_logic_vector(to_unsigned(  178  , 8)), 
                         2 => std_logic_vector(to_unsigned(  160  , 8)),   
                         3 => std_logic_vector(to_unsigned(  117  , 8)),
                         others => (others =>'0'));

signal RAM2: ram_type := (0 => std_logic_vector(to_unsigned(  3  , 8)), 
                         1 => std_logic_vector(to_unsigned(  183  , 8)), 
                         2 => std_logic_vector(to_unsigned(  229  , 8)),
                         3 => std_logic_vector(to_unsigned(  194  , 8)),                         
                         others => (others =>'0'));

signal RAM3: ram_type := (0 => std_logic_vector(to_unsigned(  3  , 8)), 
                         1 => std_logic_vector(to_unsigned(  96  , 8)), 
                         2 => std_logic_vector(to_unsigned(  172  , 8)),
                         3 => std_logic_vector(to_unsigned(  9  , 8)),                         
                         others => (others =>'0'));
                         
component project_reti_logiche is
port (
      i_clk         : in  std_logic;
      i_rst         : in  std_logic;
      i_start       : in  std_logic;
      i_data        : in  std_logic_vector(7 downto 0);
      o_address     : out std_logic_vector(15 downto 0);
      o_done        : out std_logic;
      o_en          : out std_logic;
      o_we          : out std_logic;
      o_data        : out std_logic_vector (7 downto 0)
      );
end component project_reti_logiche;

begin
UUT: project_reti_logiche
port map (
          i_clk      	=> tb_clk,
          i_rst      	=> tb_rst,
          i_start       => tb_start,
          i_data    	=> mem_o_data,
          o_address  	=> mem_address,
          o_done      	=> tb_done,
          o_en   	=> enable_wire,
          o_we 		=> mem_we,
          o_data    	=> mem_i_data
          );

p_CLK_GEN : process is
begin
    wait for c_CLOCK_PERIOD/2;
    tb_clk <= not tb_clk;
end process p_CLK_GEN;

MEM : process(tb_clk)
begin
    if tb_clk'event and tb_clk = '1' then
        if enable_wire = '1' then
            if i = "00" then
                if mem_we = '1' then
                    RAM(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM(conv_integer(mem_address)) after 2 ns;
                end if;
            elsif i = "01" then
                if mem_we = '1' then
                    RAM1(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM1(conv_integer(mem_address)) after 2 ns;
                end if;
            elsif i = "10" then
                if mem_we = '1' then
                    RAM2(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM2(conv_integer(mem_address)) after 2 ns;
                end if;
            elsif i = "11" then
                if mem_we = '1' then
                    RAM3(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM3(conv_integer(mem_address)) after 2 ns;
                end if;
            end if;  
        end if;
    end if;
end process;

test : process is
begin 
    wait for 100 ns;
    wait for c_CLOCK_PERIOD;
    tb_rst <= '1';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_rst <= '0';
    wait for c_CLOCK_PERIOD;
    wait for 100 ns;
    tb_start <= '1';
    
    wait for c_CLOCK_PERIOD;
    wait for 50 ns;
	   tb_start <= '0';
	   tb_rst <= '1';
	   wait for c_CLOCK_PERIOD;
	   tb_rst <= '0';
	   tb_start <= '1';
	wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "01";
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "10"; 
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= "11";
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    
    assert RAM(1000) = STD_LOGIC_VECTOR(TO_UNSIGNED(229, 8)) report "TEST FALLITO" severity failure;
    assert RAM(1001) = STD_LOGIC_VECTOR(TO_UNSIGNED(108, 8)) report "TEST FALLITO" severity failure;
    assert RAM(1002) = STD_LOGIC_VECTOR(TO_UNSIGNED(57, 8)) report "TEST FALLITO" severity failure;
    assert RAM(1003) = STD_LOGIC_VECTOR(TO_UNSIGNED(176, 8)) report "TEST FALLITO" severity failure;
    assert RAM(1004) = STD_LOGIC_VECTOR(TO_UNSIGNED(13, 8)) report "TEST FALLITO" severity failure;
    assert RAM(1005) = STD_LOGIC_VECTOR(TO_UNSIGNED(249, 8)) report "TEST FALLITO" severity failure;
    
    assert RAM1(1000) = STD_LOGIC_VECTOR(TO_UNSIGNED(210, 8)) report "TEST FALLITO" severity failure;
    assert RAM1(1001) = STD_LOGIC_VECTOR(TO_UNSIGNED(189, 8)) report "TEST FALLITO" severity failure;
    assert RAM1(1002) = STD_LOGIC_VECTOR(TO_UNSIGNED(17, 8)) report "TEST FALLITO" severity failure;
    assert RAM1(1003) = STD_LOGIC_VECTOR(TO_UNSIGNED(192, 8)) report "TEST FALLITO" severity failure;
    assert RAM1(1004) = STD_LOGIC_VECTOR(TO_UNSIGNED(57, 8)) report "TEST FALLITO" severity failure;
    assert RAM1(1005) = STD_LOGIC_VECTOR(TO_UNSIGNED(132, 8)) report "TEST FALLITO" severity failure;

    assert RAM2(1000) = STD_LOGIC_VECTOR(TO_UNSIGNED(210, 8)) report "TEST FALLITO" severity failure;
    assert RAM2(1001) = STD_LOGIC_VECTOR(TO_UNSIGNED(137, 8)) report "TEST FALLITO" severity failure;
    assert RAM2(1002) = STD_LOGIC_VECTOR(TO_UNSIGNED(86, 8)) report "TEST FALLITO" severity failure;
    assert RAM2(1003) = STD_LOGIC_VECTOR(TO_UNSIGNED(244, 8)) report "TEST FALLITO" severity failure;
    assert RAM2(1004) = STD_LOGIC_VECTOR(TO_UNSIGNED(155, 8)) report "TEST FALLITO" severity failure;
    assert RAM2(1005) = STD_LOGIC_VECTOR(TO_UNSIGNED(13, 8)) report "TEST FALLITO" severity failure;
    
    assert RAM3(1000) = STD_LOGIC_VECTOR(TO_UNSIGNED(58, 8)) report "TEST FALLITO" severity failure;
    assert RAM3(1001) = STD_LOGIC_VECTOR(TO_UNSIGNED(192, 8)) report "TEST FALLITO" severity failure;
    assert RAM3(1002) = STD_LOGIC_VECTOR(TO_UNSIGNED(209, 8)) report "TEST FALLITO" severity failure;
    assert RAM3(1003) = STD_LOGIC_VECTOR(TO_UNSIGNED(43, 8)) report "TEST FALLITO" severity failure;
    assert RAM3(1004) = STD_LOGIC_VECTOR(TO_UNSIGNED(0, 8)) report "TEST FALLITO" severity failure;
    assert RAM3(1005) = STD_LOGIC_VECTOR(TO_UNSIGNED(223, 8)) report "TEST FALLITO" severity failure;    
    
    assert false report "Simulation Ended! TEST PASSATO" severity failure;

end process test;

end projecttb; 
