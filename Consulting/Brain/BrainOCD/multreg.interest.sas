/* --------------------------------------------------------------------
	FILE: multreg.interest.sas

	DATA: Interest data

	PURPOSE: Performing a path analysis using PROC REG. Note that this
		was used as an example in the handout "Path Aanalysis and
		Regression." See also the output from the file
		sem.interest.sas
   -------------------------------------------------------------------- */

* - NOTE: Set LIBNAME p7291 to the directory/folder containing the
	interest data set;
*LIBNAME p7291 '';


/* To perform a path analysis, make certain to use the
   CORR option on the PROC REG statement to print out
   the correlation matrix for the variables. Also make
   certain to use the STB option on the MODEL statement
   to get standardized beta coefficients */

TITLE 'Path Analysis and Multivariate Multiple Regression';
PROC REG DATA=carey.interest CORR;
  MODEL lawyer archtct = educ vocab geometry   / STB;
  MTEST / PRINT;
run;
