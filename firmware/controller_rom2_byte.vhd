
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"7c",x"40",x"40",x"7c"),
     1 => (x"1c",x"00",x"00",x"7c"),
     2 => (x"3c",x"60",x"60",x"3c"),
     3 => (x"7c",x"3c",x"00",x"1c"),
     4 => (x"7c",x"60",x"30",x"60"),
     5 => (x"6c",x"44",x"00",x"3c"),
     6 => (x"6c",x"38",x"10",x"38"),
     7 => (x"1c",x"00",x"00",x"44"),
     8 => (x"3c",x"60",x"e0",x"bc"),
     9 => (x"44",x"00",x"00",x"1c"),
    10 => (x"4c",x"5c",x"74",x"64"),
    11 => (x"08",x"00",x"00",x"44"),
    12 => (x"41",x"77",x"3e",x"08"),
    13 => (x"00",x"00",x"00",x"41"),
    14 => (x"00",x"7f",x"7f",x"00"),
    15 => (x"41",x"00",x"00",x"00"),
    16 => (x"08",x"3e",x"77",x"41"),
    17 => (x"01",x"02",x"00",x"08"),
    18 => (x"02",x"02",x"03",x"01"),
    19 => (x"7f",x"7f",x"00",x"01"),
    20 => (x"7f",x"7f",x"7f",x"7f"),
    21 => (x"08",x"08",x"00",x"7f"),
    22 => (x"3e",x"3e",x"1c",x"1c"),
    23 => (x"7f",x"7f",x"7f",x"7f"),
    24 => (x"1c",x"1c",x"3e",x"3e"),
    25 => (x"10",x"00",x"08",x"08"),
    26 => (x"18",x"7c",x"7c",x"18"),
    27 => (x"10",x"00",x"00",x"10"),
    28 => (x"30",x"7c",x"7c",x"30"),
    29 => (x"30",x"10",x"00",x"10"),
    30 => (x"1e",x"78",x"60",x"60"),
    31 => (x"66",x"42",x"00",x"06"),
    32 => (x"66",x"3c",x"18",x"3c"),
    33 => (x"38",x"78",x"00",x"42"),
    34 => (x"6c",x"c6",x"c2",x"6a"),
    35 => (x"00",x"60",x"00",x"38"),
    36 => (x"00",x"00",x"60",x"00"),
    37 => (x"5e",x"0e",x"00",x"60"),
    38 => (x"0e",x"5d",x"5c",x"5b"),
    39 => (x"c2",x"4c",x"71",x"1e"),
    40 => (x"4d",x"bf",x"c5",x"ee"),
    41 => (x"1e",x"c0",x"4b",x"c0"),
    42 => (x"c7",x"02",x"ab",x"74"),
    43 => (x"48",x"a6",x"c4",x"87"),
    44 => (x"87",x"c5",x"78",x"c0"),
    45 => (x"c1",x"48",x"a6",x"c4"),
    46 => (x"1e",x"66",x"c4",x"78"),
    47 => (x"df",x"ee",x"49",x"73"),
    48 => (x"c0",x"86",x"c8",x"87"),
    49 => (x"ef",x"ef",x"49",x"e0"),
    50 => (x"4a",x"a5",x"c4",x"87"),
    51 => (x"f0",x"f0",x"49",x"6a"),
    52 => (x"87",x"c6",x"f1",x"87"),
    53 => (x"83",x"c1",x"85",x"cb"),
    54 => (x"04",x"ab",x"b7",x"c8"),
    55 => (x"26",x"87",x"c7",x"ff"),
    56 => (x"4c",x"26",x"4d",x"26"),
    57 => (x"4f",x"26",x"4b",x"26"),
    58 => (x"c2",x"4a",x"71",x"1e"),
    59 => (x"c2",x"5a",x"c9",x"ee"),
    60 => (x"c7",x"48",x"c9",x"ee"),
    61 => (x"dd",x"fe",x"49",x"78"),
    62 => (x"1e",x"4f",x"26",x"87"),
    63 => (x"4a",x"71",x"1e",x"73"),
    64 => (x"03",x"aa",x"b7",x"c0"),
    65 => (x"d2",x"c2",x"87",x"d3"),
    66 => (x"c4",x"05",x"bf",x"ee"),
    67 => (x"c2",x"4b",x"c1",x"87"),
    68 => (x"c2",x"4b",x"c0",x"87"),
    69 => (x"c4",x"5b",x"f2",x"d2"),
    70 => (x"f2",x"d2",x"c2",x"87"),
    71 => (x"ee",x"d2",x"c2",x"5a"),
    72 => (x"9a",x"c1",x"4a",x"bf"),
    73 => (x"49",x"a2",x"c0",x"c1"),
    74 => (x"fc",x"87",x"e8",x"ec"),
    75 => (x"ee",x"d2",x"c2",x"48"),
    76 => (x"ef",x"fe",x"78",x"bf"),
    77 => (x"4a",x"71",x"1e",x"87"),
    78 => (x"72",x"1e",x"66",x"c4"),
    79 => (x"87",x"f9",x"ea",x"49"),
    80 => (x"1e",x"4f",x"26",x"26"),
    81 => (x"d4",x"ff",x"4a",x"71"),
    82 => (x"78",x"ff",x"c3",x"48"),
    83 => (x"c0",x"48",x"d0",x"ff"),
    84 => (x"d4",x"ff",x"78",x"e1"),
    85 => (x"72",x"78",x"c1",x"48"),
    86 => (x"71",x"31",x"c4",x"49"),
    87 => (x"48",x"d0",x"ff",x"78"),
    88 => (x"26",x"78",x"e0",x"c0"),
    89 => (x"d2",x"c2",x"1e",x"4f"),
    90 => (x"e6",x"49",x"bf",x"ee"),
    91 => (x"ed",x"c2",x"87",x"f9"),
    92 => (x"bf",x"e8",x"48",x"fd"),
    93 => (x"f9",x"ed",x"c2",x"78"),
    94 => (x"78",x"bf",x"ec",x"48"),
    95 => (x"bf",x"fd",x"ed",x"c2"),
    96 => (x"ff",x"c3",x"49",x"4a"),
    97 => (x"2a",x"b7",x"c8",x"99"),
    98 => (x"b0",x"71",x"48",x"72"),
    99 => (x"58",x"c5",x"ee",x"c2"),
   100 => (x"5e",x"0e",x"4f",x"26"),
   101 => (x"0e",x"5d",x"5c",x"5b"),
   102 => (x"c8",x"ff",x"4b",x"71"),
   103 => (x"f8",x"ed",x"c2",x"87"),
   104 => (x"73",x"50",x"c0",x"48"),
   105 => (x"87",x"df",x"e6",x"49"),
   106 => (x"c2",x"4c",x"49",x"70"),
   107 => (x"49",x"ee",x"cb",x"9c"),
   108 => (x"70",x"87",x"c3",x"cc"),
   109 => (x"ed",x"c2",x"4d",x"49"),
   110 => (x"05",x"bf",x"97",x"f8"),
   111 => (x"d0",x"87",x"e2",x"c1"),
   112 => (x"ee",x"c2",x"49",x"66"),
   113 => (x"05",x"99",x"bf",x"c1"),
   114 => (x"66",x"d4",x"87",x"d6"),
   115 => (x"f9",x"ed",x"c2",x"49"),
   116 => (x"cb",x"05",x"99",x"bf"),
   117 => (x"e5",x"49",x"73",x"87"),
   118 => (x"98",x"70",x"87",x"ed"),
   119 => (x"87",x"c1",x"c1",x"02"),
   120 => (x"c0",x"fe",x"4c",x"c1"),
   121 => (x"cb",x"49",x"75",x"87"),
   122 => (x"98",x"70",x"87",x"d8"),
   123 => (x"c2",x"87",x"c6",x"02"),
   124 => (x"c1",x"48",x"f8",x"ed"),
   125 => (x"f8",x"ed",x"c2",x"50"),
   126 => (x"c0",x"05",x"bf",x"97"),
   127 => (x"ee",x"c2",x"87",x"e3"),
   128 => (x"d0",x"49",x"bf",x"c1"),
   129 => (x"ff",x"05",x"99",x"66"),
   130 => (x"ed",x"c2",x"87",x"d6"),
   131 => (x"d4",x"49",x"bf",x"f9"),
   132 => (x"ff",x"05",x"99",x"66"),
   133 => (x"49",x"73",x"87",x"ca"),
   134 => (x"70",x"87",x"ec",x"e4"),
   135 => (x"ff",x"fe",x"05",x"98"),
   136 => (x"fa",x"48",x"74",x"87"),
   137 => (x"5e",x"0e",x"87",x"fa"),
   138 => (x"0e",x"5d",x"5c",x"5b"),
   139 => (x"4d",x"c0",x"86",x"f8"),
   140 => (x"7e",x"bf",x"ec",x"4c"),
   141 => (x"c2",x"48",x"a6",x"c4"),
   142 => (x"78",x"bf",x"c5",x"ee"),
   143 => (x"1e",x"c0",x"1e",x"c1"),
   144 => (x"cd",x"fd",x"49",x"c7"),
   145 => (x"70",x"86",x"c8",x"87"),
   146 => (x"87",x"cd",x"02",x"98"),
   147 => (x"ea",x"fa",x"49",x"ff"),
   148 => (x"49",x"da",x"c1",x"87"),
   149 => (x"c1",x"87",x"f0",x"e3"),
   150 => (x"f8",x"ed",x"c2",x"4d"),
   151 => (x"cf",x"02",x"bf",x"97"),
   152 => (x"e6",x"d2",x"c2",x"87"),
   153 => (x"b9",x"c1",x"49",x"bf"),
   154 => (x"59",x"ea",x"d2",x"c2"),
   155 => (x"87",x"d3",x"fb",x"71"),
   156 => (x"bf",x"fd",x"ed",x"c2"),
   157 => (x"ee",x"d2",x"c2",x"4b"),
   158 => (x"d9",x"c1",x"05",x"bf"),
   159 => (x"48",x"a6",x"c4",x"87"),
   160 => (x"78",x"c0",x"c0",x"c8"),
   161 => (x"7e",x"e1",x"db",x"c2"),
   162 => (x"49",x"bf",x"97",x"6e"),
   163 => (x"80",x"c1",x"48",x"6e"),
   164 => (x"e2",x"71",x"7e",x"70"),
   165 => (x"98",x"70",x"87",x"f1"),
   166 => (x"c4",x"87",x"c3",x"02"),
   167 => (x"66",x"c4",x"b3",x"66"),
   168 => (x"28",x"b7",x"c1",x"48"),
   169 => (x"70",x"58",x"a6",x"c8"),
   170 => (x"db",x"ff",x"05",x"98"),
   171 => (x"49",x"fd",x"c3",x"87"),
   172 => (x"c3",x"87",x"d4",x"e2"),
   173 => (x"ce",x"e2",x"49",x"fa"),
   174 => (x"c3",x"49",x"73",x"87"),
   175 => (x"1e",x"71",x"99",x"ff"),
   176 => (x"f0",x"f9",x"49",x"c0"),
   177 => (x"c8",x"49",x"73",x"87"),
   178 => (x"1e",x"71",x"29",x"b7"),
   179 => (x"e4",x"f9",x"49",x"c1"),
   180 => (x"c5",x"86",x"c8",x"87"),
   181 => (x"ee",x"c2",x"87",x"fa"),
   182 => (x"9b",x"4b",x"bf",x"c1"),
   183 => (x"c2",x"87",x"dd",x"02"),
   184 => (x"49",x"bf",x"ea",x"d2"),
   185 => (x"70",x"87",x"db",x"c7"),
   186 => (x"87",x"c4",x"05",x"98"),
   187 => (x"87",x"d2",x"4b",x"c0"),
   188 => (x"c7",x"49",x"e0",x"c2"),
   189 => (x"d2",x"c2",x"87",x"c0"),
   190 => (x"87",x"c6",x"58",x"ee"),
   191 => (x"48",x"ea",x"d2",x"c2"),
   192 => (x"49",x"73",x"78",x"c0"),
   193 => (x"ce",x"05",x"99",x"c2"),
   194 => (x"49",x"eb",x"c3",x"87"),
   195 => (x"70",x"87",x"f8",x"e0"),
   196 => (x"02",x"99",x"c2",x"49"),
   197 => (x"fb",x"87",x"c2",x"c0"),
   198 => (x"c1",x"49",x"73",x"4c"),
   199 => (x"87",x"ce",x"05",x"99"),
   200 => (x"e0",x"49",x"f4",x"c3"),
   201 => (x"49",x"70",x"87",x"e1"),
   202 => (x"c0",x"02",x"99",x"c2"),
   203 => (x"4c",x"fa",x"87",x"c2"),
   204 => (x"99",x"c8",x"49",x"73"),
   205 => (x"c3",x"87",x"cd",x"05"),
   206 => (x"ca",x"e0",x"49",x"f5"),
   207 => (x"c2",x"49",x"70",x"87"),
   208 => (x"87",x"d6",x"02",x"99"),
   209 => (x"bf",x"c9",x"ee",x"c2"),
   210 => (x"87",x"ca",x"c0",x"02"),
   211 => (x"c2",x"88",x"c1",x"48"),
   212 => (x"c0",x"58",x"cd",x"ee"),
   213 => (x"4c",x"ff",x"87",x"c2"),
   214 => (x"49",x"73",x"4d",x"c1"),
   215 => (x"c0",x"05",x"99",x"c4"),
   216 => (x"f2",x"c3",x"87",x"ce"),
   217 => (x"de",x"df",x"ff",x"49"),
   218 => (x"c2",x"49",x"70",x"87"),
   219 => (x"87",x"dc",x"02",x"99"),
   220 => (x"bf",x"c9",x"ee",x"c2"),
   221 => (x"b7",x"c7",x"48",x"7e"),
   222 => (x"cb",x"c0",x"03",x"a8"),
   223 => (x"c1",x"48",x"6e",x"87"),
   224 => (x"cd",x"ee",x"c2",x"80"),
   225 => (x"87",x"c2",x"c0",x"58"),
   226 => (x"4d",x"c1",x"4c",x"fe"),
   227 => (x"ff",x"49",x"fd",x"c3"),
   228 => (x"70",x"87",x"f4",x"de"),
   229 => (x"02",x"99",x"c2",x"49"),
   230 => (x"c2",x"87",x"d5",x"c0"),
   231 => (x"02",x"bf",x"c9",x"ee"),
   232 => (x"c2",x"87",x"c9",x"c0"),
   233 => (x"c0",x"48",x"c9",x"ee"),
   234 => (x"87",x"c2",x"c0",x"78"),
   235 => (x"4d",x"c1",x"4c",x"fd"),
   236 => (x"ff",x"49",x"fa",x"c3"),
   237 => (x"70",x"87",x"d0",x"de"),
   238 => (x"02",x"99",x"c2",x"49"),
   239 => (x"c2",x"87",x"d9",x"c0"),
   240 => (x"48",x"bf",x"c9",x"ee"),
   241 => (x"03",x"a8",x"b7",x"c7"),
   242 => (x"c2",x"87",x"c9",x"c0"),
   243 => (x"c7",x"48",x"c9",x"ee"),
   244 => (x"87",x"c2",x"c0",x"78"),
   245 => (x"4d",x"c1",x"4c",x"fc"),
   246 => (x"03",x"ac",x"b7",x"c0"),
   247 => (x"c4",x"87",x"d3",x"c0"),
   248 => (x"d8",x"c1",x"48",x"66"),
   249 => (x"6e",x"7e",x"70",x"80"),
   250 => (x"c5",x"c0",x"02",x"bf"),
   251 => (x"49",x"74",x"4b",x"87"),
   252 => (x"1e",x"c0",x"0f",x"73"),
   253 => (x"c1",x"1e",x"f0",x"c3"),
   254 => (x"d5",x"f6",x"49",x"da"),
   255 => (x"70",x"86",x"c8",x"87"),
   256 => (x"d8",x"c0",x"02",x"98"),
   257 => (x"c9",x"ee",x"c2",x"87"),
   258 => (x"49",x"6e",x"7e",x"bf"),
   259 => (x"66",x"c4",x"91",x"cb"),
   260 => (x"6a",x"82",x"71",x"4a"),
   261 => (x"87",x"c5",x"c0",x"02"),
   262 => (x"73",x"49",x"6e",x"4b"),
   263 => (x"02",x"9d",x"75",x"0f"),
   264 => (x"c2",x"87",x"c8",x"c0"),
   265 => (x"49",x"bf",x"c9",x"ee"),
   266 => (x"c2",x"87",x"eb",x"f1"),
   267 => (x"02",x"bf",x"f2",x"d2"),
   268 => (x"49",x"87",x"dd",x"c0"),
   269 => (x"70",x"87",x"cb",x"c2"),
   270 => (x"d3",x"c0",x"02",x"98"),
   271 => (x"c9",x"ee",x"c2",x"87"),
   272 => (x"d1",x"f1",x"49",x"bf"),
   273 => (x"f2",x"49",x"c0",x"87"),
   274 => (x"d2",x"c2",x"87",x"f1"),
   275 => (x"78",x"c0",x"48",x"f2"),
   276 => (x"cb",x"f2",x"8e",x"f8"),
   277 => (x"5b",x"5e",x"0e",x"87"),
   278 => (x"1e",x"0e",x"5d",x"5c"),
   279 => (x"ee",x"c2",x"4c",x"71"),
   280 => (x"c1",x"49",x"bf",x"c5"),
   281 => (x"c1",x"4d",x"a1",x"cd"),
   282 => (x"7e",x"69",x"81",x"d1"),
   283 => (x"cf",x"02",x"9c",x"74"),
   284 => (x"4b",x"a5",x"c4",x"87"),
   285 => (x"ee",x"c2",x"7b",x"74"),
   286 => (x"f1",x"49",x"bf",x"c5"),
   287 => (x"7b",x"6e",x"87",x"ea"),
   288 => (x"c4",x"05",x"9c",x"74"),
   289 => (x"c2",x"4b",x"c0",x"87"),
   290 => (x"73",x"4b",x"c1",x"87"),
   291 => (x"87",x"eb",x"f1",x"49"),
   292 => (x"c7",x"02",x"66",x"d4"),
   293 => (x"87",x"de",x"49",x"87"),
   294 => (x"87",x"c2",x"4a",x"70"),
   295 => (x"d2",x"c2",x"4a",x"c0"),
   296 => (x"f0",x"26",x"5a",x"f6"),
   297 => (x"00",x"00",x"87",x"fa"),
   298 => (x"00",x"00",x"00",x"00"),
   299 => (x"00",x"00",x"00",x"00"),
   300 => (x"00",x"00",x"00",x"00"),
   301 => (x"71",x"1e",x"00",x"00"),
   302 => (x"bf",x"c8",x"ff",x"4a"),
   303 => (x"48",x"a1",x"72",x"49"),
   304 => (x"ff",x"1e",x"4f",x"26"),
   305 => (x"fe",x"89",x"bf",x"c8"),
   306 => (x"c0",x"c0",x"c0",x"c0"),
   307 => (x"c4",x"01",x"a9",x"c0"),
   308 => (x"c2",x"4a",x"c0",x"87"),
   309 => (x"72",x"4a",x"c1",x"87"),
   310 => (x"0e",x"4f",x"26",x"48"),
   311 => (x"5d",x"5c",x"5b",x"5e"),
   312 => (x"ff",x"4b",x"71",x"0e"),
   313 => (x"66",x"d0",x"4c",x"d4"),
   314 => (x"d6",x"78",x"c0",x"48"),
   315 => (x"ce",x"db",x"ff",x"49"),
   316 => (x"7c",x"ff",x"c3",x"87"),
   317 => (x"ff",x"c3",x"49",x"6c"),
   318 => (x"49",x"4d",x"71",x"99"),
   319 => (x"c1",x"99",x"f0",x"c3"),
   320 => (x"cb",x"05",x"a9",x"e0"),
   321 => (x"7c",x"ff",x"c3",x"87"),
   322 => (x"98",x"c3",x"48",x"6c"),
   323 => (x"78",x"08",x"66",x"d0"),
   324 => (x"6c",x"7c",x"ff",x"c3"),
   325 => (x"31",x"c8",x"49",x"4a"),
   326 => (x"6c",x"7c",x"ff",x"c3"),
   327 => (x"72",x"b2",x"71",x"4a"),
   328 => (x"c3",x"31",x"c8",x"49"),
   329 => (x"4a",x"6c",x"7c",x"ff"),
   330 => (x"49",x"72",x"b2",x"71"),
   331 => (x"ff",x"c3",x"31",x"c8"),
   332 => (x"71",x"4a",x"6c",x"7c"),
   333 => (x"48",x"d0",x"ff",x"b2"),
   334 => (x"73",x"78",x"e0",x"c0"),
   335 => (x"87",x"c2",x"02",x"9b"),
   336 => (x"48",x"75",x"7b",x"72"),
   337 => (x"4c",x"26",x"4d",x"26"),
   338 => (x"4f",x"26",x"4b",x"26"),
   339 => (x"0e",x"4f",x"26",x"1e"),
   340 => (x"0e",x"5c",x"5b",x"5e"),
   341 => (x"1e",x"76",x"86",x"f8"),
   342 => (x"fd",x"49",x"a6",x"c8"),
   343 => (x"86",x"c4",x"87",x"fd"),
   344 => (x"48",x"6e",x"4b",x"70"),
   345 => (x"c2",x"03",x"a8",x"c2"),
   346 => (x"4a",x"73",x"87",x"f0"),
   347 => (x"c1",x"9a",x"f0",x"c3"),
   348 => (x"c7",x"02",x"aa",x"d0"),
   349 => (x"aa",x"e0",x"c1",x"87"),
   350 => (x"87",x"de",x"c2",x"05"),
   351 => (x"99",x"c8",x"49",x"73"),
   352 => (x"ff",x"87",x"c3",x"02"),
   353 => (x"4c",x"73",x"87",x"c6"),
   354 => (x"ac",x"c2",x"9c",x"c3"),
   355 => (x"87",x"c2",x"c1",x"05"),
   356 => (x"c9",x"49",x"66",x"c4"),
   357 => (x"c4",x"1e",x"71",x"31"),
   358 => (x"92",x"d4",x"4a",x"66"),
   359 => (x"49",x"cd",x"ee",x"c2"),
   360 => (x"d0",x"fe",x"81",x"72"),
   361 => (x"49",x"d8",x"87",x"eb"),
   362 => (x"87",x"d3",x"d8",x"ff"),
   363 => (x"c2",x"1e",x"c0",x"c8"),
   364 => (x"fd",x"49",x"ea",x"dc"),
   365 => (x"ff",x"87",x"e7",x"ec"),
   366 => (x"e0",x"c0",x"48",x"d0"),
   367 => (x"ea",x"dc",x"c2",x"78"),
   368 => (x"4a",x"66",x"cc",x"1e"),
   369 => (x"ee",x"c2",x"92",x"d4"),
   370 => (x"81",x"72",x"49",x"cd"),
   371 => (x"87",x"f2",x"ce",x"fe"),
   372 => (x"ac",x"c1",x"86",x"cc"),
   373 => (x"87",x"c2",x"c1",x"05"),
   374 => (x"c9",x"49",x"66",x"c4"),
   375 => (x"c4",x"1e",x"71",x"31"),
   376 => (x"92",x"d4",x"4a",x"66"),
   377 => (x"49",x"cd",x"ee",x"c2"),
   378 => (x"cf",x"fe",x"81",x"72"),
   379 => (x"dc",x"c2",x"87",x"e3"),
   380 => (x"66",x"c8",x"1e",x"ea"),
   381 => (x"c2",x"92",x"d4",x"4a"),
   382 => (x"72",x"49",x"cd",x"ee"),
   383 => (x"f2",x"cc",x"fe",x"81"),
   384 => (x"ff",x"49",x"d7",x"87"),
   385 => (x"c8",x"87",x"f8",x"d6"),
   386 => (x"dc",x"c2",x"1e",x"c0"),
   387 => (x"ea",x"fd",x"49",x"ea"),
   388 => (x"86",x"cc",x"87",x"e5"),
   389 => (x"c0",x"48",x"d0",x"ff"),
   390 => (x"8e",x"f8",x"78",x"e0"),
   391 => (x"0e",x"87",x"e7",x"fc"),
   392 => (x"5d",x"5c",x"5b",x"5e"),
   393 => (x"4d",x"71",x"1e",x"0e"),
   394 => (x"d4",x"4c",x"d4",x"ff"),
   395 => (x"c3",x"48",x"7e",x"66"),
   396 => (x"c5",x"06",x"a8",x"b7"),
   397 => (x"c1",x"48",x"c0",x"87"),
   398 => (x"49",x"75",x"87",x"e2"),
   399 => (x"87",x"de",x"dd",x"fe"),
   400 => (x"66",x"c4",x"1e",x"75"),
   401 => (x"c2",x"93",x"d4",x"4b"),
   402 => (x"73",x"83",x"cd",x"ee"),
   403 => (x"ef",x"c6",x"fe",x"49"),
   404 => (x"6b",x"83",x"c8",x"87"),
   405 => (x"48",x"d0",x"ff",x"4b"),
   406 => (x"dd",x"78",x"e1",x"c8"),
   407 => (x"c3",x"49",x"73",x"7c"),
   408 => (x"7c",x"71",x"99",x"ff"),
   409 => (x"b7",x"c8",x"49",x"73"),
   410 => (x"99",x"ff",x"c3",x"29"),
   411 => (x"49",x"73",x"7c",x"71"),
   412 => (x"c3",x"29",x"b7",x"d0"),
   413 => (x"7c",x"71",x"99",x"ff"),
   414 => (x"b7",x"d8",x"49",x"73"),
   415 => (x"c0",x"7c",x"71",x"29"),
   416 => (x"7c",x"7c",x"7c",x"7c"),
   417 => (x"7c",x"7c",x"7c",x"7c"),
   418 => (x"7c",x"7c",x"7c",x"7c"),
   419 => (x"c4",x"78",x"e0",x"c0"),
   420 => (x"49",x"dc",x"1e",x"66"),
   421 => (x"87",x"cc",x"d5",x"ff"),
   422 => (x"48",x"73",x"86",x"c8"),
   423 => (x"87",x"e4",x"fa",x"26"),
   424 => (x"c0",x"1e",x"73",x"1e"),
   425 => (x"f5",x"db",x"c2",x"4b"),
   426 => (x"c2",x"50",x"c0",x"48"),
   427 => (x"49",x"bf",x"f1",x"db"),
   428 => (x"87",x"ce",x"df",x"fe"),
   429 => (x"c4",x"05",x"98",x"70"),
   430 => (x"c9",x"db",x"c2",x"87"),
   431 => (x"c4",x"48",x"73",x"4b"),
   432 => (x"26",x"4d",x"26",x"87"),
   433 => (x"26",x"4b",x"26",x"4c"),
   434 => (x"6f",x"68",x"53",x"4f"),
   435 => (x"69",x"68",x"2f",x"77"),
   436 => (x"4f",x"20",x"65",x"64"),
   437 => (x"3d",x"20",x"44",x"53"),
   438 => (x"79",x"65",x"6b",x"20"),
   439 => (x"32",x"31",x"46",x"20"),
   440 => (x"14",x"12",x"58",x"00"),
   441 => (x"1c",x"1b",x"1d",x"11"),
   442 => (x"94",x"59",x"5a",x"23"),
   443 => (x"eb",x"f2",x"f5",x"91"),
   444 => (x"00",x"26",x"f6",x"f4"),
   445 => (x"55",x"41",x"00",x"00"),
   446 => (x"4f",x"42",x"4f",x"54"),
   447 => (x"45",x"4e",x"54",x"4f"),
   448 => (x"45",x"4e",x"00",x"53"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

