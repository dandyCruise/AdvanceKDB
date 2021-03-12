
if[not system"p";system"p ",getenv`PORT_CEP];

TPPORT:hopen`$"::",getenv`PORT_TP;

path.CEP:"/" sv -2_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn]
path.home:"/" sv -4_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn];
path.common:path.home,"/common"

system"l ",path.common,"/log4q.q"
system"l ",path.common,"/log.q"

\t 1000

upd:insert;

.z.ts:{
	`agg upsert (select bidAskSpread: max bid - min ask by sym from quote) lj (select maxPrice:max price, minPrice:min price by sym from trade);
	TPPORT(".u.upd";`agg;(value flip 0!agg))
	};


/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{[x]
	(.[;();:;].)each x;
	};

.u.rep (hopen `$"::",getenv`PORT_TP)"(.u.sub[`trade;`];.u.sub[`quote;`])";
