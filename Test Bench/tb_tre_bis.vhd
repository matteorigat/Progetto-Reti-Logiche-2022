library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_tb is
end project_tb;

architecture projecttb of project_tb is
constant c_CLOCK_PERIOD         : time := 15 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;


type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

signal   i                      : integer := 0;

signal RAM0: ram_type := (0 => std_logic_vector(to_unsigned(  2  , 8)), 
                         1 => std_logic_vector(to_unsigned(  162  , 8)), 
                         2 => std_logic_vector(to_unsigned(  75  , 8)),
                         others => (others =>'0'));
			 -- Expected Output  1000 -> 209                         
			 -- Expected Output  1001  -> 205                         
			 -- Expected Output  1002  -> 247                         
			 -- Expected Output  1003  -> 210                         

signal RAM1: ram_type := (0 => std_logic_vector(to_unsigned(  6  , 8)), 
                         1 => std_logic_vector(to_unsigned(  163  , 8)), 
                         2 => std_logic_vector(to_unsigned(  47  , 8)),
                         3 => std_logic_vector(to_unsigned(  4  , 8)),
                         4 => std_logic_vector(to_unsigned(  64  , 8)),
                         5 => std_logic_vector(to_unsigned(  67  , 8)),
                         6 => std_logic_vector(to_unsigned(  13  , 8)),
                         others => (others =>'0'));
			 -- Expected Output  1000 -> 209                         
			 -- Expected Output  1001  -> 206                         
			 -- Expected Output  1002  -> 189                         
			 -- Expected Output  1003  -> 37
			 -- Expected Output  1004  -> 176 
			 -- Expected Output  1005  -> 55 
			 -- Expected Output  1006  -> 55 
			 -- Expected Output  1007  -> 0 
			 -- Expected Output  1008  -> 55 
			 -- Expected Output  1009  -> 14 
			 -- Expected Output  1010  -> 176 
			 -- Expected Output  1011  -> 232        
			 
signal RAM2: ram_type := (0 => std_logic_vector(to_unsigned(  3  , 8)), 
                         1 => std_logic_vector(to_unsigned(  112  , 8)), 
                         2 => std_logic_vector(to_unsigned(  164  , 8)),
                         3 => std_logic_vector(to_unsigned(  45  , 8)),
                         others => (others =>'0'));
			 -- Expected Output  1000 -> 57                         
			 -- Expected Output  1001  -> 176                         
			 -- Expected Output  1002  -> 209                         
			 -- Expected Output  1003  -> 247
			 -- Expected Output  1004  -> 13
			 -- Expected Output  1005  -> 40    
			 
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
          o_en   	    => enable_wire,
          o_we 		    => mem_we,
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
            if i=0 then
                if mem_we = '1' then
                    RAM0(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM0(conv_integer(mem_address)) after 2 ns;
                end if;
            elsif i=1 then
                if mem_we = '1' then
                    RAM1(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM1(conv_integer(mem_address)) after 2 ns;
                end if;
            elsif i=2 then
                if mem_we = '1' then
                    RAM2(conv_integer(mem_address))  <= mem_i_data;
                    mem_o_data                      <= mem_i_data after 2 ns;
                else
                    mem_o_data <= RAM2(conv_integer(mem_address)) after 2 ns;
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
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= i + 1;

    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;
    i <= i + 1;
    
    wait for 100 ns;
    tb_start <= '1';
    wait for c_CLOCK_PERIOD;
    wait until tb_done = '1';
    wait for c_CLOCK_PERIOD;
    tb_start <= '0';
    wait until tb_done = '0';
    wait for 100 ns;

    -- Input=  [162, 75]  
    -- Output =  [209, 205, 247, 210]  
    
    assert RAM0(1000) = std_logic_vector(to_unsigned( 209 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  209  found " & integer'image(to_integer(unsigned(RAM0(1000))))  severity failure;
    assert RAM0(1001) = std_logic_vector(to_unsigned( 205 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  205  found " & integer'image(to_integer(unsigned(RAM0(1001))))  severity failure;
    assert RAM0(1002) = std_logic_vector(to_unsigned( 247 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  247  found " & integer'image(to_integer(unsigned(RAM0(1002))))  severity failure;
    assert RAM0(1003) = std_logic_vector(to_unsigned( 210 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  210  found " & integer'image(to_integer(unsigned(RAM0(1003))))  severity failure;
    
    assert RAM1(1000) = std_logic_vector(to_unsigned( 209 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  209  found " & integer'image(to_integer(unsigned(RAM1(1000))))  severity failure;
    assert RAM1(1001) = std_logic_vector(to_unsigned( 206 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  206  found " & integer'image(to_integer(unsigned(RAM1(1001))))  severity failure;
    assert RAM1(1002) = std_logic_vector(to_unsigned( 189 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  189  found " & integer'image(to_integer(unsigned(RAM1(1002))))  severity failure;
    assert RAM1(1003) = std_logic_vector(to_unsigned( 37 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  37   found " & integer'image(to_integer(unsigned(RAM1(1003))))  severity failure;
    assert RAM1(1004) = std_logic_vector(to_unsigned( 176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  176  found " & integer'image(to_integer(unsigned(RAM1(1004))))  severity failure;
    assert RAM1(1005) = std_logic_vector(to_unsigned( 55 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  55   found " & integer'image(to_integer(unsigned(RAM1(1005))))  severity failure;
    assert RAM1(1006) = std_logic_vector(to_unsigned( 55 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  55   found " & integer'image(to_integer(unsigned(RAM1(1006))))  severity failure;
    assert RAM1(1007) = std_logic_vector(to_unsigned( 0 , 8))   report "TEST FALLITO (WORKING ZONE). Expected  0    found " & integer'image(to_integer(unsigned(RAM1(1007))))  severity failure;
    assert RAM1(1008) = std_logic_vector(to_unsigned( 55 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  55   found " & integer'image(to_integer(unsigned(RAM1(1008))))  severity failure;
    assert RAM1(1009) = std_logic_vector(to_unsigned( 14 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  14   found " & integer'image(to_integer(unsigned(RAM1(1009))))  severity failure;
    assert RAM1(1010) = std_logic_vector(to_unsigned( 176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  176  found " & integer'image(to_integer(unsigned(RAM1(1010))))  severity failure;
    assert RAM1(1011) = std_logic_vector(to_unsigned( 232 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  232  found " & integer'image(to_integer(unsigned(RAM1(1011))))  severity failure;
    
    assert RAM2(1000) = std_logic_vector(to_unsigned( 57 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  57   found " & integer'image(to_integer(unsigned(RAM2(1000))))  severity failure;
    assert RAM2(1001) = std_logic_vector(to_unsigned( 176 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  176  found " & integer'image(to_integer(unsigned(RAM2(1001))))  severity failure;
    assert RAM2(1002) = std_logic_vector(to_unsigned( 209 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  209  found " & integer'image(to_integer(unsigned(RAM2(1002))))  severity failure;
    assert RAM2(1003) = std_logic_vector(to_unsigned( 247 , 8)) report "TEST FALLITO (WORKING ZONE). Expected  247  found " & integer'image(to_integer(unsigned(RAM2(1003))))  severity failure;
    assert RAM2(1004) = std_logic_vector(to_unsigned( 13 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  13   found " & integer'image(to_integer(unsigned(RAM2(1004))))  severity failure;
    assert RAM2(1005) = std_logic_vector(to_unsigned( 40 , 8))  report "TEST FALLITO (WORKING ZONE). Expected  40   found " & integer'image(to_integer(unsigned(RAM2(1005))))  severity failure;
    

    assert false report "Simulation Ended! TEST PASSATO" severity failure;
end process test;

end projecttb; 