/
	Load in CSV .......
	Description: Takes in CSV FP, table name and Header(Y/N)
\

path.home:"/" sv -2_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn];

system"l ",path.home,"/SRC/TP/q/sym.q";

input.CSV:`$.z.x 0;
input.table:`$.z.x 1;
input.header:"b"$.z.x 2;

loadCSV:{[]
    $[all input.header;
    input.table set ((value meta input.table)[`t];enlist ",") 0:hsym input.CSV;
    input.table insert ((value meta input.table)[`t];",") 0:hsym input.CSV
    ];
    };

sendTP:{[]
    p:getenv`PORT_TP;
    h:hopen`$"::",p;
    h(".u.upd";input.table;(value flip get input.table));
    hclose h;
    }

main:{[]
	loadCSV[];
	sendTP[];
    };

main[];
exit 0; 

