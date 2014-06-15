/* CREATED BY: aknezev Dec 13,2010 12:15PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_093.d01';
data cmv.breastfeedlog(label="Breast Feed Log");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat StartDate1 MMDDYY8. ;  format StartDate1  MMDDYY8. ;
  informat EndDate1 MMDDYY8. ;  format EndDate1  MMDDYY8. ;
  informat comments1 $CHAR26. ;
  informat StartDate2 MMDDYY8. ;  format StartDate2  MMDDYY8. ;
  informat EndDate2 MMDDYY8. ;  format EndDate2  MMDDYY8. ;
  informat comments2 $CHAR26. ;
  informat StartDate3 MMDDYY8. ;  format StartDate3  MMDDYY8. ;
  informat EndDate3 MMDDYY8. ;  format EndDate3  MMDDYY8. ;
  informat comments3 $CHAR26. ;
  informat StartDate4 MMDDYY8. ;  format StartDate4  MMDDYY8. ;
  informat EndDate4 MMDDYY8. ;  format EndDate4  MMDDYY8. ;
  informat comments4 $CHAR26. ;
  informat StartDate5 MMDDYY8. ;  format StartDate5  MMDDYY8. ;
  informat EndDate5 MMDDYY8. ;  format EndDate5  MMDDYY8. ;
  informat comments5 $CHAR26. ;
  informat StartDate6 MMDDYY8. ;  format StartDate6  MMDDYY8. ;
  informat EndDate6 MMDDYY8. ;  format EndDate6  MMDDYY8. ;
  informat comments6 $CHAR26. ;
  informat StartDate7 MMDDYY8. ;  format StartDate7  MMDDYY8. ;
  informat EndDate7 MMDDYY8. ;  format EndDate7  MMDDYY8. ;
  informat comments7 $CHAR26. ;
  informat StartDate8 MMDDYY8. ;  format StartDate8  MMDDYY8. ;
  informat EndDate8 MMDDYY8. ;  format EndDate8  MMDDYY8. ;
  informat comments8 $CHAR26. ;
  informat StartDate9 MMDDYY8. ;  format StartDate9  MMDDYY8. ;
  informat EndDate9 MMDDYY8. ;  format EndDate9  MMDDYY8. ;
  informat comments9 $CHAR26. ;
  informat StartDate10 MMDDYY8. ;  format StartDate10  MMDDYY8. ;
  informat EndDate10 MMDDYY8. ;  format EndDate10  MMDDYY8. ;
  informat comments10 $CHAR26. ;
  informat StartDate11 MMDDYY8. ;  format StartDate11  MMDDYY8. ;
  informat EndDate11 MMDDYY8. ;  format EndDate11  MMDDYY8. ;
  informat comments11 $CHAR26. ;
  informat StartDate12 MMDDYY8. ;  format StartDate12  MMDDYY8. ;
  informat EndDate12 MMDDYY8. ;  format EndDate12  MMDDYY8. ;
  informat comments12 $CHAR26. ;
  informat StartDate13 MMDDYY8. ;  format StartDate13  MMDDYY8. ;
  informat EndDate13 MMDDYY8. ;  format EndDate13  MMDDYY8. ;
  informat comments13 $CHAR26. ;
  informat StartDate14 MMDDYY8. ;  format StartDate14  MMDDYY8. ;
  informat EndDate14 MMDDYY8. ;  format EndDate14  MMDDYY8. ;
  informat comments14 $CHAR26. ;
  informat StartDate15 MMDDYY8. ;  format StartDate15  MMDDYY8. ;
  informat EndDate15 MMDDYY8. ;  format EndDate15  MMDDYY8. ;
  informat comments15 $CHAR26. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  StartDate1  EndDate1  fresh_milk1  frozen_milk1
        moc_milk1  donor_milk1  comments1 $  StartDate2  EndDate2
        fresh_milk2  frozen_milk2  moc_milk2  donor_milk2  comments2 $
        StartDate3  EndDate3  fresh_milk3  frozen_milk3  moc_milk3
        donor_milk3  comments3 $  StartDate4  EndDate4  fresh_milk4
        frozen_milk4  moc_milk4  donor_milk4  comments4 $  StartDate5
        EndDate5  fresh_milk5  frozen_milk5  moc_milk5  donor_milk5
        comments5 $  StartDate6  EndDate6  fresh_milk6  frozen_milk6
        moc_milk6  donor_milk6  comments6 $  StartDate7  EndDate7
        fresh_milk7  frozen_milk7  moc_milk7  donor_milk7  comments7 $
        StartDate8  EndDate8  fresh_milk8  frozen_milk8  moc_milk8
        donor_milk8  comments8 $  StartDate9  EndDate9  fresh_milk9
        frozen_milk9  moc_milk9  donor_milk9  comments9 $  StartDate10
        EndDate10  fresh_milk10  frozen_milk10  moc_milk10
        donor_milk10  comments10 $  StartDate11  EndDate11
        fresh_milk11  frozen_milk11  moc_milk11  donor_milk11
        comments11 $  StartDate12  EndDate12  fresh_milk12
        frozen_milk12  moc_milk12  donor_milk12  comments12 $
        StartDate13  EndDate13  fresh_milk13  frozen_milk13  moc_milk13
        donor_milk13  comments13 $  StartDate14  EndDate14
        fresh_milk14  frozen_milk14  moc_milk14  donor_milk14
        comments14 $  StartDate15  EndDate15  fresh_milk15
        frozen_milk15  moc_milk15  donor_milk15  comments15 $  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        StartDate1="StartDate1"
        EndDate1="1. End Date"
        fresh_milk1="Row1 fresh_milk"
        frozen_milk1="Row1 frozen_milk"
        moc_milk1="Row 1 moc_milk"
        donor_milk1="Row 1 donor_milk"
        comments1="comments1"
        StartDate2="StartDate2"
        EndDate2="1. End Date"
        fresh_milk2="Row2 fresh_milk"
        frozen_milk2="Row2 frozen_milk"
        moc_milk2="Row 2 moc_milk"
        donor_milk2="Row 2 donor_milk"
        comments2="comments2"
        StartDate3="StartDate3"
        EndDate3="3. End Date"
        fresh_milk3="Row3 fresh_milk"
        frozen_milk3="Row3 frozen_milk"
        moc_milk3="Row 3 moc_milk"
        donor_milk3="Row 3 donor_milk"
        comments3="comments3"
        StartDate4="StartDate4"
        EndDate4="4. End Date"
        fresh_milk4="Row4 fresh_milk"
        frozen_milk4="Row4 frozen_milk"
        moc_milk4="Row 4 moc_milk"
        donor_milk4="Row 4 donor_milk"
        comments4="comments4"
        StartDate5="Row 5. Start Date"
        EndDate5="5. End Date"
        fresh_milk5="Row5 fresh_milk"
        frozen_milk5="Row 5 frozen_milk"
        moc_milk5="Row 5 moc_milk"
        donor_milk5="Row5 donor_milk"
        comments5="comments5"
        StartDate6="Row 6. Start Date"
        EndDate6="6. End Date"
        fresh_milk6="Row6 fresh_milk"
        frozen_milk6="Row 6 frozen_milk"
        moc_milk6="Row 6 moc_milk"
        donor_milk6="Row 6 donor_milk"
        comments6="comments6"
        StartDate7="Row 7. Start Date"
        EndDate7="7. End Date"
        fresh_milk7="Row7 fresh_milk"
        frozen_milk7="Row 7 frozen_milk"
        moc_milk7="Row 7 moc_milk"
        donor_milk7="Row 7 donor_milk"
        comments7="comments7"
        StartDate8="Row 8. Start Date"
        EndDate8="8. End Date"
        fresh_milk8="Row8 fresh_milk"
        frozen_milk8="Row 8 frozen_milk"
        moc_milk8="Row 8 moc_milk"
        donor_milk8="Row 8 donor_milk"
        comments8="comments8"
        StartDate9="Row 9. Start Date"
        EndDate9="9. End Date"
        fresh_milk9="Row 9 fresh_milk"
        frozen_milk9="Row 9 frozen_milk"
        moc_milk9="Row 9 moc_milk"
        donor_milk9="Row 9 donor_milk"
        comments9="comments9"
        StartDate10="Row 10. Start Date"
        EndDate10="10. End Date"
        fresh_milk10="Row 10 fresh_milk"
        frozen_milk10="Row 10 frozen_milk"
        moc_milk10="Row 10 moc_milk"
        donor_milk10="Row10 donor_milk"
        comments10="comments10"
        StartDate11="Row 11. Start Date"
        EndDate11="11. End Date"
        fresh_milk11="Row 11 fresh_milk"
        frozen_milk11="Row 11 frozen_milk"
        moc_milk11="Row 11 moc_milk"
        donor_milk11="Row11 donor_milk"
        comments11="comments11"
        StartDate12="Row 12. Start Date"
        EndDate12="12. End Date"
        fresh_milk12="Row 12 fresh_milk"
        frozen_milk12="Row 12 frozen_milk"
        moc_milk12="Row 12 moc_milk"
        donor_milk12="Row12 donor_milk"
        comments12="comments12"
        StartDate13="Row 13. Start Date"
        EndDate13="13. End Date"
        fresh_milk13="Row 13 fresh_milk"
        frozen_milk13="Row 13 frozen_milk"
        moc_milk13="Row 13 moc_milk"
        donor_milk13="Row13 donor_milk"
        comments13="comments13"
        StartDate14="Row 14. Start Date"
        EndDate14="14. End Date"
        fresh_milk14="Row 14 fresh_milk"
        frozen_milk14="Row 14 frozen_milk"
        moc_milk14="Row 14 moc_milk"
        donor_milk14="Row14 donor_milk"
        comments14="comments14"
        StartDate15="Row 15. Start Date"
        EndDate15="15. End Date"
        fresh_milk15="Row 15 fresh_milk"
        frozen_milk15="Row 15 frozen_milk"
        moc_milk15="Row 15 moc_milk"
        donor_milk15="Row15 donor_milk"
        comments15="comments15"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
