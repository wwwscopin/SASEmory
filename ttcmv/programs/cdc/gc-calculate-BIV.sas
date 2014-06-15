**** THIS SAS PROGRAM IS FOR THE CALCULATION OF
     PERCENTILES AND Z-SCORES BASED ON THE CDC
     GROWTH REFERENCE YEAR 2000 ****;
**** IT ALSO CALCULATE BIOLOGICAL IMPLAUSIBLE VALUES ****;

IF AGEMOS GE 0 AND AGEMOS LT 0.5 THEN _AGECAT=0;
  ELSE _AGECAT=INT(AGEMOS+0.5)-0.5;

IF RECUMBNT=1 THEN DO;
  LENGTH=HEIGHT;
  STATURE=.;
END;
 ELSE IF RECUMBNT=0 THEN DO;
  STATURE=HEIGHT;
  LENGTH=.;
 END;
 ELSE IF RECUMBNT=. THEN DO;
  IF AGEMOS NE . THEN DO;
   IF AGEMOS LT 24 THEN DO;
     LENGTH=HEIGHT;
     STATURE=.;
   END;
    ELSE IF AGEMOS GE 24 THEN DO;
     STATURE=HEIGHT;
     LENGTH=.;
    END;
  END;
  ELSE DO;
   IF HEIGHT LT 85 THEN DO;
     LENGTH=HEIGHT;
     STATURE=.;
   END;
    ELSE IF HEIGHT GE 85 THEN DO;
     STATURE=HEIGHT;
     LENGTH=.;
    END;
  END;
 END;

IF HEIGHT LT 20 OR HEIGHT GT 300 THEN HEIGHT=.;
IF WEIGHT LT 0.5 OR WEIGHT GT 300 THEN WEIGHT=.;
IF WEIGHT=. OR STATURE=. THEN BMI=.;
  ELSE BMI=WEIGHT/(STATURE/100)**2;
_ID=_N_;


DATA _INDATA1; SET _INDATA;
PROC SORT DATA=_INDATA1; BY SEX _AGECAT _ID;

DATA _INDATA2; SET _INDATA;
IF LENGTH=. THEN _HTCAT=.;
  ELSE IF LENGTH GE 45 AND LENGTH LT 45.5 THEN _HTCAT=45;
  ELSE _HTCAT=INT(LENGTH+0.5)-0.5;
PROC SORT DATA=_INDATA2; BY SEX _HTCAT _ID;

DATA _INDATA3; SET _INDATA;
IF STATURE=. THEN _HTCAT=.;
  ELSE IF STATURE GE 77 AND STATURE LT 77.5 THEN _HTCAT=77;
  ELSE _HTCAT=INT(STATURE+0.5)-0.5;
PROC SORT DATA=_INDATA3; BY SEX _HTCAT _ID;



DATA LGFAGE; SET cmv.LGFAGE;
 _AGECAT=_AGEMOS1;
 PROC SORT DATA=LGFAGE; BY SEX _AGECAT;

DATA HTFAGE; SET cmv.HTFAGE;
 _AGECAT=_AGEMOS1;
 PROC SORT DATA=HTFAGE; BY SEX _AGECAT;

DATA WTFAGE; SET cmv.WTFAGE;
 _AGECAT=_AGEMOS1;
 PROC SORT DATA=WTFAGE; BY SEX _AGECAT;

DATA BMIFAGE; SET cmv.BMIFAGE;
 _AGECAT=_AGEMOS1;
 PROC SORT DATA=BMIFAGE; BY SEX _AGECAT;

DATA HCFAGE; SET cmv.HCFAGE;
 _AGECAT=_AGEMOS1;
 PROC SORT DATA=HCFAGE; BY SEX _AGECAT;

DATA REFFAGE; MERGE LGFAGE HTFAGE WTFAGE BMIFAGE HCFAGE; BY SEX _AGECAT;

DATA REFFLG; SET cmv.WTFLG;
 _HTCAT=_LG1;
 PROC SORT DATA=REFFLG; BY SEX _HTCAT;

DATA REFFHT; SET cmv.WTFHT;
 _HTCAT=_HT1;
 PROC SORT DATA=REFFHT; BY SEX _HTCAT;


DATA FINFAGE; MERGE _INDATA1 (IN=A) REFFAGE (IN=B); BY SEX _AGECAT;
 IF A;

IF (LENGTH LT 20 OR LENGTH GT 300) THEN DO;
  _LLG=.; _MLG=.; _SLG=.;
  LGZ=.; LGPCT=.;
  _SDLGZLO=.; _SDLGZHI=.;    *FOR MISSING VALUES;
END;
ELSE DO;
_LLG = ((AGEMOS-_AGEMOS1)*(_LLG2-_LLG1)/(_AGEMOS2-_AGEMOS1)+_LLG1);
_MLG = ((AGEMOS-_AGEMOS1)*(_MLG2-_MLG1)/(_AGEMOS2-_AGEMOS1)+_MLG1);
_SLG = ((AGEMOS-_AGEMOS1)*(_SLG2-_SLG1)/(_AGEMOS2-_AGEMOS1)+_SLG1);
  IF (_LLG GT -0.01 AND _LLG LT 0.01) THEN LGZ=LOG(LENGTH/_MLG)/_SLG;
    ELSE LGZ=((LENGTH/_MLG)**_LLG-1)/(_LLG*_SLG);
  LGPCT=PROBNORM(LGZ)*100;
_SDLGZLO=((_MLG-_MLG*(1-2*_LLG*_SLG)**(1/_LLG))/2);
_SDLGZHI=((_MLG*(1+2*_LLG*_SLG)**(1/_LLG)-_MLG)/2);
END;
IF LENGTH LT _MLG THEN _FLAGLG=(LENGTH-_MLG)/_SDLGZLO;
  ELSE _FLAGLG=(LENGTH-_MLG)/_SDLGZHI;
IF _FLAGLG=. THEN _BIVLG=.;
 ELSE IF _FLAGLG LT -5 THEN _BIVLG=1;
 ELSE IF _FLAGLG GT 3 THEN _BIVLG=2;
 ELSE _BIVLG=0;

IF (STATURE LT 45 OR STATURE GT 300) THEN DO;
  _LHT=.; _MHT=.; _SHT=.;
  STZ=.; STPCT=.;
  _SDSTZLO=.; _SDSTZHI=.;    *FOR MISSING VALUES;
END;
ELSE DO;
_LHT = ((AGEMOS-_AGEMOS1)*(_LHT2-_LHT1)/(_AGEMOS2-_AGEMOS1)+_LHT1);
_MHT = ((AGEMOS-_AGEMOS1)*(_MHT2-_MHT1)/(_AGEMOS2-_AGEMOS1)+_MHT1);
_SHT = ((AGEMOS-_AGEMOS1)*(_SHT2-_SHT1)/(_AGEMOS2-_AGEMOS1)+_SHT1);
  IF (_LHT GT -0.01 AND _LHT LT 0.01) THEN STZ=LOG(STATURE/_MHT)/_SHT;
    ELSE STZ=((STATURE/_MHT)**_LHT-1)/(_LHT*_SHT);
  STPCT=PROBNORM(STZ)*100;
_SDSTZLO=((_MHT-_MHT*(1-2*_LHT*_SHT)**(1/_LHT))/2);
_SDSTZHI=((_MHT*(1+2*_LHT*_SHT)**(1/_LHT)-_MHT)/2);
END;
IF STATURE LT _MHT THEN _FLAGST=(STATURE-_MHT)/_SDSTZLO;
  ELSE _FLAGST=(STATURE-_MHT)/_SDSTZHI;
IF _FLAGST=. THEN _BIVST=.;
 ELSE IF _FLAGST LT -5 THEN _BIVST=1;
 ELSE IF _FLAGST GT 3 THEN _BIVST=2;
 ELSE _BIVST=0;

IF (AGEMOS LT 0 OR AGEMOS GT 240) OR
   (WEIGHT LT 0.5 OR WEIGHT GT 400) THEN DO;
  _LWT=.; _MWT=.; _SWT=.;
  WAZ=.; WTPCT=.;
  _SDWAZLO=.; _SDWAZHI=.;    *FOR MISSING VALUES;
END;
ELSE DO;
_LWT = ((AGEMOS-_AGEMOS1)*(_LWT2-_LWT1)/(_AGEMOS2-_AGEMOS1)+_LWT1);
_MWT = ((AGEMOS-_AGEMOS1)*(_MWT2-_MWT1)/(_AGEMOS2-_AGEMOS1)+_MWT1);
_SWT = ((AGEMOS-_AGEMOS1)*(_SWT2-_SWT1)/(_AGEMOS2-_AGEMOS1)+_SWT1);
  IF (_LWT GT -0.01 AND _LWT LT 0.01) THEN WAZ=LOG(WEIGHT/_MWT)/_SWT;
    ELSE WAZ=((WEIGHT/_MWT)**_LWT-1)/(_LWT*_SWT);
  WTPCT=PROBNORM(WAZ)*100;
_SDWAZLO=((_MWT-_MWT*(1-2*_LWT*_SWT)**(1/_LWT))/2);
_SDWAZHI=((_MWT*(1+2*_LWT*_SWT)**(1/_LWT)-_MWT)/2);
END;
IF WEIGHT LT _MWT THEN _FLAGWT=(WEIGHT-_MWT)/_SDWAZLO;
  ELSE _FLAGWT=(WEIGHT-_MWT)/_SDWAZHI;
IF _FLAGWT=. THEN _BIVWT=.;
 ELSE IF _FLAGWT LT -5 THEN _BIVWT=1;
 ELSE IF _FLAGWT GT 5 THEN _BIVWT=2;
 ELSE _BIVWT=0;

IF (AGEMOS LT 24 OR AGEMOS GT 240) OR
   (BMI LT 2 OR BMI GT 80) THEN DO;
  _LBMI=.; _MBMI=.; _SBMI=.;
  BMIZ=.; BMIPCT=.;
  _SDBMILO=.; _SDBMIHI=.;    *FOR MISSING VALUES;
END;
ELSE DO;
_LBMI = ((AGEMOS-_AGEMOS1)*(_LBMI2-_LBMI1)/(_AGEMOS2-_AGEMOS1)+_LBMI1);
_MBMI = ((AGEMOS-_AGEMOS1)*(_MBMI2-_MBMI1)/(_AGEMOS2-_AGEMOS1)+_MBMI1);
_SBMI = ((AGEMOS-_AGEMOS1)*(_SBMI2-_SBMI1)/(_AGEMOS2-_AGEMOS1)+_SBMI1);
  IF (_LBMI GT -0.01 AND _LBMI LT 0.01) THEN BMIZ=LOG(BMI/_MBMI)/_SBMI;
    ELSE BMIZ=((BMI/_MBMI)**_LBMI-1)/(_LBMI*_SBMI);
  BMIPCT=PROBNORM(BMIZ)*100;
_SDBMILO=((_MBMI-_MBMI*(1-2*_LBMI*_SBMI)**(1/_LBMI))/2);
_SDBMIHI=((_MBMI*(1+2*_LBMI*_SBMI)**(1/_LBMI)-_MBMI)/2);
END;
IF BMI LT _MBMI THEN _FLAGBMI=(BMI-_MBMI)/_SDBMILO;
  ELSE _FLAGBMI=(BMI-_MBMI)/_SDBMIHI;
IF _FLAGBMI=. THEN _BIVBMI=.;
 ELSE IF _FLAGBMI LT -4 THEN _BIVBMI=1;
 ELSE IF _FLAGBMI GT 5 THEN _BIVBMI=2;
 ELSE _BIVBMI=0;

IF (AGEMOS LT 0 OR AGEMOS GT 36) OR
   (HEADCIR LT 0.5 OR HEADCIR GT 100) THEN DO;
  _LHC=.; _MHC=.; _SHC=.;
  HCZ=.; HCPCT=.;
  _SDHCZLO=.; _SDHCZHI=.;    *FOR MISSING VALUES;
END;
ELSE DO;
_LHC = ((AGEMOS-_AGEMOS1)*(_LHC2-_LHC1)/(_AGEMOS2-_AGEMOS1)+_LHC1);
_MHC = ((AGEMOS-_AGEMOS1)*(_MHC2-_MHC1)/(_AGEMOS2-_AGEMOS1)+_MHC1);
_SHC = ((AGEMOS-_AGEMOS1)*(_SHC2-_SHC1)/(_AGEMOS2-_AGEMOS1)+_SHC1);
  IF (_LHC GT -0.01 AND _LHC LT 0.01) THEN HCZ=LOG(HEADCIR/_MHC)/_SHC;
    ELSE HCZ=((HEADCIR/_MHC)**_LHC-1)/(_LHC*_SHC);
  HCPCT=PROBNORM(HCZ)*100;
_SDHCZLO=((_MHC-_MHC*(1-2*_LHC*_SHC)**(1/_LHC))/2);
_SDHCZHI=((_MHC*(1+2*_LHC*_SHC)**(1/_LHC)-_MHC)/2);
END;
IF HEADCIR LT _MHC THEN _FLAGHC=(HEADCIR-_MHC)/_SDHCZLO;
  ELSE _FLAGHC=(HEADCIR-_MHC)/_SDHCZHI;
IF _FLAGHC=. THEN _BIVHC=.;
 ELSE IF _FLAGHC LT -5 THEN _BIVHC=1;
 ELSE IF _FLAGHC GT 5 THEN _BIVHC=2;
 ELSE _BIVHC=0;

DROP _LLG _MLG _SLG _LLG1 _LLG2 _MLG1 _MLG2 _SLG1 _SLG2
     _LHT _MHT _SHT _LWT _MWT _SWT _LBMI _MBMI _SBMI _LHC _MHC _SHC
     _LHT1 _LHT2 _MHT1 _MHT2 _SHT1 _SHT2
     _LWT1 _LWT2 _MWT1 _MWT2 _SWT1 _SWT2
     _LBMI1 _LBMI2 _MBMI1 _MBMI2 _SBMI1 _SBMI2
     _LHC1 _LHC2 _MHC1 _MHC2 _SHC1 _SHC2 _AGEMOS1 _AGEMOS2;
    * _SDLGZLO _SDLGZHI _FLAGLG _SDSTZLO _SDSTZHI _FLAGST
     _SDWAZLO _SDWAZHI _FLAGWT _SDBMILO _SDBMIHI _FLAGBMI
     _SDHCZLO _SDHCZHI _FLAGHC;
PROC SORT DATA=FINFAGE; BY SEX _AGECAT _ID;


DATA FINFLG; MERGE _INDATA2 (IN=A) REFFLG (IN=B); BY SEX _HTCAT;
 IF A;
IF (LENGTH LT 45 OR LENGTH GT 103.5) OR
   (WEIGHT LT 0.5 OR WEIGHT GT 400) THEN DO;
 _LWLT=.; _MWLT=.; _SWLT=.;
 WLZ=.; WLPCT=.;
 _SDWLZLO=.; _SDWLZHI=.;    *FOR MISSING VALUES;
END;
ELSE DO;
_LWLT = ((LENGTH-_LG1)*(_LWLG2-_LWLG1)/(_LG2-_LG1)+_LWLG1);
_MWLT = ((LENGTH-_LG1)*(_MWLG2-_MWLG1)/(_LG2-_LG1)+_MWLG1);
_SWLT = ((LENGTH-_LG1)*(_SWLG2-_SWLG1)/(_LG2-_LG1)+_SWLG1);
  IF (_LWLT GT -0.01 AND _LWLT LT 0.01) THEN WLZ=LOG(WEIGHT/_MWLT)/_SWLT;
    ELSE WLZ=((WEIGHT/_MWLT)**_LWLT-1)/(_LWLT*_SWLT);
  WLPCT=PROBNORM(WLZ)*100;
_SDWLZLO=((_MWLT-_MWLT*(1-2*_LWLT*_SWLT)**(1/_LWLT))/2);
_SDWLZHI=((_MWLT*(1+2*_LWLT*_SWLT)**(1/_LWLT)-_MWLT)/2);
END;
IF WEIGHT LT _MWLT THEN _FLAGWLG=(WEIGHT-_MWLT)/_SDWLZLO;
  ELSE _FLAGWLG=(WEIGHT-_MWLT)/_SDWLZHI;
IF _FLAGWLG=. THEN _BIVWLG=.;
 ELSE IF _FLAGWLG LT -4 THEN _BIVWLG=1;
 ELSE IF _FLAGWLG GT 5 THEN _BIVWLG=2;
 ELSE _BIVWLG=0;

DROP _LG1 _LG2 _HTCAT _LWLT _MWLT _SWLT _LWLG1 _LWLG2 _MWLG1 _MWLG2 _SWLG1
 _SWLG2 _SDWLZLO _SDWLZHI;* _FLAGWLG;
PROC SORT DATA=FINFLG; BY SEX _AGECAT _ID;


DATA FINFHT; MERGE _INDATA3 (IN=A) REFFHT (IN=B); BY SEX _HTCAT;
 IF A;
IF (STATURE LT 77 OR STATURE GT 121.5) OR
   (WEIGHT LT 0.5 OR WEIGHT GT 400) THEN DO;
 _LWHT=.; _MWHT=.; _SWHT=.;
 WSZ=.; WSPCT=.;
 _SDWSZLO=.; _SDWSZHI=.;    *FOR MISSING VALUES;
END;
ELSE DO;
_LWHT = ((STATURE-_HT1)*(_LWHT2-_LWHT1)/(_HT2-_HT1)+_LWHT1);
_MWHT = ((STATURE-_HT1)*(_MWHT2-_MWHT1)/(_HT2-_HT1)+_MWHT1);
_SWHT = ((STATURE-_HT1)*(_SWHT2-_SWHT1)/(_HT2-_HT1)+_SWHT1);
  IF (_LWHT GT -0.01 AND _LWHT LT 0.01) THEN WSZ=LOG(WEIGHT/_MWHT)/_SWHT;
    ELSE WSZ=((WEIGHT/_MWHT)**_LWHT-1)/(_LWHT*_SWHT);
  WSPCT=PROBNORM(WSZ)*100;
_SDWSZLO=((_MWHT-_MWHT*(1-2*_LWHT*_SWHT)**(1/_LWHT))/2);
_SDWSZHI=((_MWHT*(1+2*_LWHT*_SWHT)**(1/_LWHT)-_MWHT)/2);
END;
IF WEIGHT LT _MWHT THEN _FLAGWST=(WEIGHT-_MWHT)/_SDWSZLO;
  ELSE _FLAGWST=(WEIGHT-_MWHT)/_SDWSZHI;
IF _FLAGWST=. THEN _BIVWST=.;
 ELSE IF _FLAGWST LT -4 THEN _BIVWST=1;
 ELSE IF _FLAGWST GT 5 THEN _BIVWST=2;
 ELSE _BIVWST=0;

DROP _HT1 _HT2 _HTCAT _LWHT _MWHT _SWHT _LWHT1 _LWHT2 _MWHT1 _MWHT2 _SWHT1
 _SWHT2 _SDWSZLO _SDWSZHI; * _FLAGWST;
PROC SORT DATA=FINFHT; BY SEX _AGECAT _ID;

DATA _INDATA; MERGE FINFAGE FINFLG FINFHT; BY SEX _AGECAT _ID;
 IF RECUMBNT=1 THEN DO;
   HAZ=LGZ; HTPCT=LGPCT; _BIVHT=_BIVLG;
   WHZ=WLZ; WHPCT=WLPCT; _BIVWHT=_BIVWLG;
 END;
 ELSE IF RECUMBNT=0 THEN DO;
   HAZ=STZ; HTPCT=STPCT; _BIVHT=_BIVST;
   WHZ=WSZ; WHPCT=WSPCT; _BIVWHT=_BIVWST;
 END;
 ELSE DO;
  HAZ=.; HTPCT=.; _BIVHT=.;
  WHZ=.; WHPCT=.; _BIVWHT=.;
 END;

DROP _AGECAT _ID LGZ LGPCT STZ STPCT WLZ WLPCT WSZ WSPCT LENGTH STATURE
     _BIVLG _BIVST _BIVWLG _BIVWST;


run;