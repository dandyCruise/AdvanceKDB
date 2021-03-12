system"p ",getenv`PORT_RDB2

path.RDB2:"/" sv -2_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn];
path.home:"/" sv -4_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn];
path.common:path.home,"/common"

system"l ",path.common,"/log4q.q"
system"l ",path.common,"/log.q"


upd:upsert;

/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5011";":5012");

/ end of day: save, clear, hdb reload
.u.end:{
	t:tables`.;
	t@:where `g=attr each t@\:`sym;
	.Q.hdpf[`$":",.u.x 1;`:.;x;`sym];
	@[;`sym;`g#] each t;
	};

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{[x]
    (.[;();:;].)each x;
    };

.u.rep enlist(hopen `$"::",getenv`PORT_TP)"(.u.sub[`agg;`])"
`sym xkey `agg;

