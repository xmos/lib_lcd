{signal: [
  {name: 'PIXEL_CLK',  wave: '10101|01010101|01010|101', node: '.A.B...D..........C....E'},
  {name: 'DE',         wave: '0....|.1......|...0.|...'},
  {name: 'H_SYNC',     wave: '10.1.|........|.....|..0'},
  {name: 'RGB',        wave: 'x....|.2.2.2.2|.2.x.|x..', node:'', data: ['DQ[0]','DQ[1]','DQ[2]',,'DQ[w-1]' ]},
   {              node: '.M.H...I..........K....J'},
   {              node: '.O.....................P'}],
  edge: ['M-A ', 'B-H', 'C-K' , 'D-I', 'E-J', 'M<->H Thpw', 'H<->I Thbp', 'I<->K Thd', 'K<->J Thfp', 'O<->P Th']
}
