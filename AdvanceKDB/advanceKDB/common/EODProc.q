

path.home:"/" sv -2_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn];
path.HDB:path.home,"/HDB";

input.log:`$.z.x 0;

system "l ",path.home,"/SRC/TP/q/sym.q";

comp:()!()
comp[`maxPrice]:(17;2;9)
comp[`minPrice]:(17;2;9)
comp[`bidAskSpread]:(17;2;9)
comp[`price]:(17;2;9)
comp[`size]:(17;2;9)
comp[`bid]:(17;2;9)
comp[`ask]:(17;2;9)
comp[`bsize]:(17;2;9)
comp[`asize]:(17;2;9)

upd:{[TABLE;DATA] TABLE insert DATA}

WD:{[TABLE]
 	(hsym `$sv["/";(path.HDB;(-10#string[input.log]);string[TABLE];"")];comp) set .Q.en[hsym `$path.HDB;value TABLE];
	};

main:{[]
    -11!input.log;
    {WD[x]} each tables[];
    };

main[];
exit 0;
