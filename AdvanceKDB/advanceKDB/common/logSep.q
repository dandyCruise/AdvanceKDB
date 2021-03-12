/

	File: Log Seperator
	Description: Reads in a TP log and creates a new TP log with just trade and quotes with ibm.n

\

input.log: .z.x[0]

old:hsym `$input.log ;
new:hsym `$ ("/" sv -1_f),"/IBM",3_last f:("/" vs input.log) ;
new set ();
LH:hopen new ;

upd:{[t;x] 
    if[t=`trade;
    data:flip f where {`IBM.N = x[1]} each (f:flip x);
    if[count data; LH enlist (`upd;`trade;data)]]
    };

main:{[]
	-11!old;
	};

main[]

0N!"New Log ", string new;

exit 0; 
