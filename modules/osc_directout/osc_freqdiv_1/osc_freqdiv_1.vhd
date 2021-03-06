----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:28:22 11/11/2011 
-- Design Name: 
-- Module Name:    frequency_divider_2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity osc_freqdiv_1 is
    Port ( clk : in  STD_LOGIC;         -- clock
           i_en : in  STD_LOGIC;        -- enable
           o_osz : out  STD_LOGIC;      -- oscillator output back to logic
           o_osz_drct : out STD_LOGIC;  -- oscillator output to output pin
           o_trig_rcnf : out STD_LOGIC  -- trigger output to output pin after reconfiguration
         );
end osc_freqdiv_1;

architecture Behavioral of osc_freqdiv_1 is

  -- a = 100000000
  -- b =  50000000
  
  --signal d, dInc, dN : std_logic_vector(7 downto 0);
  signal d, dInc, dN : signed(27 downto 0)  := "0000000000000000000000000000";
  signal osc_ff : std_logic := '0';
  signal triggered : std_logic := '0';  -- triggered?
  --signal d, dInc, dN : signed(26 downto 0)  := signed(0);

  
  
begin

  process (d)
  begin
    if (d(27) = '1') then
      --dInc <= "0010111110101111000010000000";  -- 50000000
      --dInc <= "0001011111010111100001000000";  -- 25000000
      --dInc <= "0000101111101011110000100000";  -- 12500000
      dInc <= "0000010111110101111000010000";  --  6250000
      --o_osz <= '0';
    else
      --dInc <= "1101000001010000111110000000";  -- 50000000 - 100000000
      --dInc <= "1011100001111001011101000000";  -- 25000000 - 100000000
      --dInc <= "1111010000010100001111100000";  -- 12500000 - 100000000
      dInc <= "1010011010010111110100010000";  --  6250000 - 100000000
      -- this gives only single pulse on event
      --o_osz <= '1' and i_en;
      -- toggle oscillator signal, resulting in half the period
      osc_ff <= not(osc_ff) and i_en;
    end if;
  end process;

  dN <= d + dInc;
  o_osz <= osc_ff;
  --o_osz_drct <= osc_ff;
  
  process (clk)
  begin
    --wait until clk'event and clk = '1';
    if clk'event and clk = '1' then
      d <= dN;
      -- trigger after reconfiguration
      if triggered = '0' then
        o_trig_rcnf <= '1';
        triggered <= '1';               -- disable retrigger forever
      else
        o_trig_rcnf <= '0';
      end if;
    end if;
    -- clock B tick whenever d(24) is zero
  end process;

  OBUF_inst1 : OBUF
    generic map (
      DRIVE => 12,
      IOSTANDARD => "DEFAULT",
      SLEW => "SLOW")
    port map (
      O => o_osz_drct,     -- Buffer output (connect directly to top-level port)
      I => osc_ff      -- Buffer input 
      );
  
end Behavioral;

