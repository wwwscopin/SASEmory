options nodate pageno=1 linesize=80 pagesize=60; 
  data cake;
   input Name $ 1-10 Present 12-13 Taste 15-16;
   datalines;
Davis      77 84
Orlando    93 80
Ramey      68 72
Roe        68 75
Sanders    56 79
Simms      68 77
Strickland 82 79
; 
  proc rank data=cake out=order descending ties=mean; 
     var present taste;
   ranks PresentRank TasteRank;
run; 
  proc print data=order;
   title "Rankings of Participants' Scores";
run; 
