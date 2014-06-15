************************************************************************;
* Simple example document, jpp 10.8.2008 ;
************************************************************************;
***Set environment******************************************************;
%LET basepath=C:\sas2latex\simple;
%LET filepath=&basepath\SAS;
%LET outpath=Latex;
%LET acrorpath=C:\Program Files\Adobe\Reader 9.0\Reader;

%INCLUDE "&filepath\include\t.sas";
%LET texfile=Simple Example Document;
%LET quoterep='¢';
%LET SC=SYSTASK COMMAND;
***LaTeX code***********************************************************;
%t('\documentclass{article}',n);
%t('\title{&texfile}');
%t('\author{jpp}');
%t('\begin{document}');
%t('\maketitle');
%t('\tableofcontents');
%t('\section{First Section}');
%t('Some text here.');
%t('\end{document}');
***Compile**************************************************************;
&SC "latex ""&texfile..tex""" SHELL WAIT;
&SC "latex ""&texfile..tex""" SHELL WAIT;
&SC "dvips ""&texfile..dvi""" SHELL WAIT;
&SC "ps2pdf14 ""&texfile..ps"" ""&basepath\&texfile..pdf""" SHELL WAIT;
***End******************************************************************;
