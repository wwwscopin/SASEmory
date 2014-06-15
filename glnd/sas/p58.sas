/* CREATED BY: bwu2 Apr 18,2011 14:42PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */

proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value DFSCRNv  0 = "blank"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error" ;

filename data1 '/dfax/glnd/sas/plate58.d01';
data glnd.plate58(label="Glutamine Results, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat not_obtained_base $CHAR100. ;
  informat not_obtained_day3 $CHAR100. ;
  informat not_obtained_day7 $CHAR100. ;
  informat not_obtained_day14 $CHAR100. ;
  informat not_obtained_day21 $CHAR100. ;
  informat not_obtained_day28 $CHAR100. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        glutamine_base  glutamic_acid_base  not_obtained_base $
        glutamine_day3  glutamic_acid_day3  not_obtained_day3 $
        glutamine_day7  glutamic_acid_day7  not_obtained_day7 $
        glutamine_day14  glutamic_acid_day14  not_obtained_day14 $
        glutamine_day21  glutamic_acid_day21  not_obtained_day21 $
        glutamine_day28  glutamic_acid_day28  not_obtained_day28 $
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
/*
  format DFSTATUS DFSTATv. ;
  format DFSCREEN DFSCRNv. ;
*/
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        glutamine_base="Glutamine: Baseline"
        glutamic_acid_base="Glutamic Acid: Baseline"
        not_obtained_base="Not obtained: Baseline"
        glutamine_day3="Glutamine: Day 3"
        glutamic_acid_day3="Glutamic Acid: Day 3"
        not_obtained_day3="Not obtained: Day 3"
        glutamine_day7="Glutamine: Day 7"
        glutamic_acid_day7="Glutamic Acid: Day 7"
        not_obtained_day7="Not obtained: Day 7"
        glutamine_day14="Glutamine: Day 14"
        glutamic_acid_day14="Glutamic Acid: Day 14"
        not_obtained_day14="Not obtained: Day 14"
        glutamine_day21="Glutamine: Day 21"
        glutamic_acid_day21="Glutamic Acid: Day 21"
        not_obtained_day21="Not obtained: Day 21"
        glutamine_day28="Glutamine: Day 28"
        glutamic_acid_day28="Glutamic Acid: Day 28"
        not_obtained_day28="Not obtained: Day 28"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
