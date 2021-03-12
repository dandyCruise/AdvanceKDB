\p 5001


sym:`ibm`bac`usb
price:121.3 5.76 8.19
amount:1000 500 800
time:09:03:06.000 09:03:23.000 09:04:01.000
trade:([]sym;price;amt:amount;time)

.z.ws:{[x] res:`$x;
    $[res in trade[`sym];
      neg[.z.w] .Q.s select from trade where sym=res;
      neg[.z.w] "No results, avaliable syms: ",(raze {" ",x}each distinct string[trade[`sym]])];
	};

