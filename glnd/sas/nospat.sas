data id;
 infile 'sitevisit.dat';
 input id;

data nos;
    set glnd.plate101;
	
         keep id t dfseq dt_infect infect_number;
         data x;
          merge id(in=a) nos;
           by id;
           if a;
           
          data nos2;
           array dtnos(10) ;
           array seqnos(10);
           array nosnum(10);
           do i=1 to 10;
           nnos=i;
                set x;
                 by id;
                 dtnos(i)=dt_infect;
                 seqnos(i)=dfseq;
                 nosnum(i)=infect_number;
                 if last.id then return;
            end;
           keep id dtnos1-dtnos10 seqnos1-seqnos10 nosnum1-nosnum10 nnos;
           format dtnos1-dtnos10 mmddyy8. nosnum1-nosnum10 ;
          data nos1;
 set nos2;
       if seqnos1=. then nnos=0; 
           proc print;
           
run;
*/;
