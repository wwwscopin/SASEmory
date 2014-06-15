/* CREATED BY: aknezev Dec 10,2010 17:28PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_066.d01';
data cmv.plate_066(label="NEC PN Log P2/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat StartDate8 MMDDYY8. ;  format StartDate8  MMDDYY8. ;
  informat EndDate8 MMDDYY8. ;  format EndDate8  MMDDYY8. ;
  informat StartDate9 MMDDYY8. ;  format StartDate9  MMDDYY8. ;
  informat EndDate9 MMDDYY8. ;  format EndDate9  MMDDYY8. ;
  informat StartDate10 MMDDYY8. ;  format StartDate10  MMDDYY8. ;
  informat EndDate10 MMDDYY8. ;  format EndDate10  MMDDYY8. ;
  informat StartDate11 MMDDYY8. ;  format StartDate11  MMDDYY8. ;
  informat EndDate11 MMDDYY8. ;  format EndDate11  MMDDYY8. ;
  informat StartDate12 MMDDYY8. ;  format StartDate12  MMDDYY8. ;
  informat EndDate12 MMDDYY8. ;  format EndDate12  MMDDYY8. ;
  informat StartDate13 MMDDYY8. ;  format StartDate13  MMDDYY8. ;
  informat EndDate13 MMDDYY8. ;  format EndDate13  MMDDYY8. ;
  informat StartDate14 MMDDYY8. ;  format StartDate14  MMDDYY8. ;
  informat EndDate14 MMDDYY8. ;  format EndDate14  MMDDYY8. ;
  informat StartDate15 MMDDYY8. ;  format StartDate15  MMDDYY8. ;
  informat EndDate15 MMDDYY8. ;  format EndDate15  MMDDYY8. ;
  informat StartDate16 MMDDYY8. ;  format StartDate16  MMDDYY8. ;
  informat EndDate16 MMDDYY8. ;  format EndDate16  MMDDYY8. ;
  informat StartDate17 MMDDYY8. ;  format StartDate17  MMDDYY8. ;
  informat EndDate17 MMDDYY8. ;  format EndDate17  MMDDYY8. ;
  informat StartDate18 MMDDYY8. ;  format StartDate18  MMDDYY8. ;
  informat EndDate18 MMDDYY8. ;  format EndDate18  MMDDYY8. ;
  informat StartDate19 MMDDYY8. ;  format StartDate19  MMDDYY8. ;
  informat EndDate19 MMDDYY8. ;  format EndDate19  MMDDYY8. ;
  informat StartDate20 MMDDYY8. ;  format StartDate20  MMDDYY8. ;
  informat EndDate20 MMDDYY8. ;  format EndDate20  MMDDYY8. ;
  informat StartDate21 MMDDYY8. ;  format StartDate21  MMDDYY8. ;
  informat EndDate21 MMDDYY8. ;  format EndDate21  MMDDYY8. ;
  informat StartDate22 MMDDYY8. ;  format StartDate22  MMDDYY8. ;
  informat EndDate22 MMDDYY8. ;  format EndDate22  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  StartDate8  EndDate8  EntrealPct8  StartDate9
        EndDate9  EntrealPct9  StartDate10  EndDate10  EntrealPct10
        StartDate11  EndDate11  EntrealPct11  StartDate12  EndDate12
        EntrealPct12  StartDate13  EndDate13  EntrealPct13  StartDate14
        EndDate14  EntrealPct14  StartDate15  EndDate15  EntrealPct15
        StartDate16  EndDate16  EntrealPct16  StartDate17  EndDate17
        EntrealPct17  StartDate18  EndDate18  EntrealPct18  StartDate19
        EndDate19  EntrealPct19  StartDate20  EndDate20  EntrealPct20
        StartDate21  EndDate21  EntrealPct21  StartDate22  EndDate22
        EntrealPct22  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        StartDate8="Start Date 8"
        EndDate8="9. End Date"
        EntrealPct8="Row 8.Percent Entreal 8"
        StartDate9="Start Date 9"
        EndDate9="9. End Date"
        EntrealPct9="Percent Entreal 9"
        StartDate10="Start Date10"
        EndDate10="10. End Date"
        EntrealPct10="Percent Entreal 10"
        StartDate11="Start Date 11"
        EndDate11="11. End Date"
        EntrealPct11="Percent Entreal 11"
        StartDate12="Start Date 12"
        EndDate12="12. End Date"
        EntrealPct12="Percent Entreal 12"
        StartDate13="Start Date 13"
        EndDate13="13. End Date"
        EntrealPct13="Percent Entreal 13"
        StartDate14="Start Date 14"
        EndDate14="14. End Date"
        EntrealPct14="Percent Entreal 14"
        StartDate15="Start Date 15"
        EndDate15="15. End Date"
        EntrealPct15="Percent Entreal 15"
        StartDate16="Start Date 16"
        EndDate16="16. End Date"
        EntrealPct16="Percent Entreal 16"
        StartDate17="Start Date17"
        EndDate17="17. End Date"
        EntrealPct17="Percent Entreal 17"
        StartDate18="Start Date18"
        EndDate18="18. End Date"
        EntrealPct18="Percent Entreal 18"
        StartDate19="Start Date19"
        EndDate19="19. End Date"
        EntrealPct19="Percent Entreal 19"
        StartDate20="Start Date20"
        EndDate20="20. End Date"
        EntrealPct20="Percent Entreal 20"
        StartDate21="Start Date21"
        EndDate21="21. End Date"
        EntrealPct21="Percent Entreal 21"
        StartDate22="Start Date22"
        EndDate22="22. End Date"
        EntrealPct22="Percent Entreal 22"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
