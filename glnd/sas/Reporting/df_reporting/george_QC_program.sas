* Read QC Note extracted file;

data qcs;
  infile '/wasid/WASID/rollover/qcnotes.dat' dlm='|' dsd lrecl=2000 missover;
  length f3 $ 12;
  length f13 $ 150;
  length f14 $ 150;
  length f17 $ 500 f18 $ 500 f19 $ 50 f20 $ 50 f21 $ 50;
  input
    f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
    f13 f14 f15 f16 f17 f18 f19 f20 f21 f22;

* f1 = status
* f5 = plate #
* f6 = reader code + 4000
* f7 = id
* f8 = field #+3
* f13 = field name
* f15 = problem code
;
  status = f1;
  plate = f5;
  reader = f6;
  id = f7;
  field = f8+3;

  name = f13;
  pcode = f15;
  
  if plate = 404 and reader = 4004 and 
     (9 <= field <= 16 or field in (18, 20, 22, 24, 26)) and
     pcode = 1;

proc sort;
  by id field;
  
proc print;
  var id plate reader status field f8 name pcode;


data delqcs;
  set qcs;

  file '/wasid/WASID/rollover/del_qcs.dat' lrecl=2000;

  f1=7;
       put f1 +(-1) '|' f2 +(-1) '|' f3 +(-1) '|' f4 +(-1) '|' f5 +(-1) '|'
           f6 +(-1) '|' f7 +(-1) '|' f8 +(-1) '|' f9 +(-1) '|' f10 +(-1) '|'
           f11 +(-1) '|' f12 +(-1) '|' f13 +(-1) '|' f14 +(-1) '|' f15 +(-1)
           '|' f16 +(-1) '|' f17 +(-1) '|' f18 +(-1) '|' f19 +(-1) '|' f20 +(-1)
            '|' f21 +(-1) '|' f22;
 
run;
  