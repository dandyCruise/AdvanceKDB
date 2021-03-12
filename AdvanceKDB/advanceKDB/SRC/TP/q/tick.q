
if[not system"p";system"p ",getenv`PORT_TP];

path.TP:"/" sv -2_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn];
path.home:"/" sv -4_ "/" vs $["/"=first fn:string .z.f;fn;raze (system "pwd"),"/", fn];

path.common:path.home,"/common";

system"l ",path.TP,"/q/sym.q";
system"l ",path.TP,"/q/u.q";
system"l ",path.common,"/log4q.q";
system"l ",path.common,"/log.q";

.count.agg:0;
.count.trade:0;
.count.quote:0;



\d .u
ld:{
	if[not type key L::`$(-10_string L),string x;
		.[L;();:;()]];
		i::j::-11!(-2;L);
		if[0<=type i;
			-2 (string L)," is a corrupt log. Truncate to length ",(string last i)," and restart"
			;exit 1];
		hopen L};

tick:{
	init[];
	if[not min(`time`sym~2#key flip value@)each t;
		'`timesym];@[;`sym;`g#]each t;d::.z.D;
		if[l::count y;
			L::`$":",y,"/",x,10#".";l::ld d
		]};

endofday:{
	end d;
	d+:1;
	if[l;hclose l;l::0(`.u.ld;d)
	]};

ts:{
	if[d<x;if[d<x-1;system"t 0";'"more than one day?"]
	;endofday[]
	]};

batch:{pub'[t;value each t];
	@[`.;t;@[;`sym;`g#]0#];
	i::j;
	ts .z.D};

upd:{[t;x]
	if[not -16=type first first x;
		if[d<"d"$a:.z.P;.z.ts[]];
		a:"n"$a;x:$[0>type first x;a,x;(enlist(count first x)#a),x]
	];
	t insert x;
	.count[t]+:(count first x);
	if[l;l enlist (`upd;t;x);j+:1];};


\d .
.u.tick["TP";path.home,"/log"];


////////////////////CRON AREA

system"l ",path.common,"/cron.q";

logger:{.log4q.INFO("Summary
             agg   | count:",raze string .count.agg," | sub: ", (raze raze  ";" sv string .u.w[`agg][;0]),"
             trade | count:",raze string .count.trade," | sub: ", (raze raze ";" sv string .u.w[`trade][;0]),"
             quote | count:",raze string .count.quote," | sub: ", (raze raze ";" sv string .u.w[`quote][;0]));}

.cron.add["logger[]";0;`repeat;60];
.cron.add[".u.batch[]";0;`repeat;1];


/////////////////////////////////


\
 globals used
 .u.w - dictionary of tables->(handle;syms)
 .u.i - msg count in log file
 .u.j - total msg count (log file plus those held in buffer)
 .u.t - table names
 .u.L - tp log filename, e.g. `:./sym2008.09.11
 .u.l - handle to tp log file
 .u.d - date
/test
>q tick.q
>q tick/ssl.q
/run
>q tick.q sym  .  -p 5010	/tick
>q tick/r.q :5010 -p 5011	/rdb
>q sym            -p 5012	/hdb
>q tick/ssl.q sym :5010		/feed

