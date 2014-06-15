%let tmp="wbh";
%let tmp1=%sysfunc(dequote(&tmp));
%put &tmp1;

ods rtf file="test.rtf" style=journal toc_data startpage =no bodytitle ;
ods escapechar='^';
proc report nowd headskip missing split = "*" style(header) = {just=center}; run;
ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt}
* &tmp";
ods rtf close;
