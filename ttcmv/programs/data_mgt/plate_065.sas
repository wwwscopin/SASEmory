/* CREATED BY: aknezev Dec 10,2010 17:26PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_065.d01';
data cmv.plate_065(label="NEC PN Log P1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat nec_date MMDDYY8. ;  format nec_date  MMDDYY8. ;
  informat StartDate1 MMDDYY8. ;  format StartDate1  MMDDYY8. ;
  informat EndDate1 MMDDYY8. ;  format EndDate1  MMDDYY8. ;
  informat StartDate2 MMDDYY8. ;  format StartDate2  MMDDYY8. ;
  informat EndDate2 MMDDYY8. ;  format EndDate2  MMDDYY8. ;
  informat StartDate3 MMDDYY8. ;  format StartDate3  MMDDYY8. ;
  informat EndDate3 MMDDYY8. ;  format EndDate3  MMDDYY8. ;
  informat StartDate4 MMDDYY8. ;  format StartDate4  MMDDYY8. ;
  informat EndDate4 MMDDYY8. ;  format EndDate4  MMDDYY8. ;
  informat StartDate5 MMDDYY8. ;  format StartDate5  MMDDYY8. ;
  informat EndDate5 MMDDYY8. ;  format EndDate5  MMDDYY8. ;
  informat StartDate6 MMDDYY8. ;  format StartDate6  MMDDYY8. ;
  informat EndDate6 MMDDYY8. ;  format EndDate6  MMDDYY8. ;
  informat StartDate7 MMDDYY8. ;  format StartDate7  MMDDYY8. ;
  informat EndDate7 MMDDYY8. ;  format EndDate7  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  EntrealPct_dp7  EntrealPct_dp6  EntrealPct_dp5
        EntrealPct_dp4  EntrealPct_dp3  EntrealPct_dp2  EntrealPct_dp1
        nec_date  EntrealPct_d0  StartDate1  EndDate1  EntrealPct1
        StartDate2  EndDate2  EntrealPct2  StartDate3  EndDate3
        EntrealPct3  StartDate4  EndDate4  EntrealPct4  StartDate5
        EndDate5  EntrealPct5  StartDate6  EndDate6  EntrealPct6
        StartDate7  EndDate7  EntrealPct7  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        EntrealPct_dp7="Percent Entreal 7 days prior to NEC"
        EntrealPct_dp6="Percent Entreal 6 days prior to NEC"
        EntrealPct_dp5="Percent Entreal 5 days prior to NEC"
        EntrealPct_dp4="Percent Entreal 4 days prior to NEC"
        EntrealPct_dp3="Percent Entreal 3 days prior to NEC"
        EntrealPct_dp2="Percent Entreal 2 days prior NEC"
        EntrealPct_dp1="Percent Entreal 1 day prior to NEC"
        nec_date="nec date"
        EntrealPct_d0="Percent Entreal Day of NEC"
        StartDate1="Start Date 1"
        EndDate1="1. End Date"
        EntrealPct1="Percent Entreal 1"
        StartDate2="Start Date 2"
        EndDate2="2. End Date"
        EntrealPct2="Percent Entreal 2"
        StartDate3="Start Date 3"
        EndDate3="3. End Date"
        EntrealPct3="Percent Entreal 3"
        StartDate4="Start Date 4"
        EndDate4="4. End Date"
        EntrealPct4="Percent Entreal 4"
        StartDate5="Start Date 5"
        EndDate5="5. End Date"
        EntrealPct5="Percent Entreal 5"
        StartDate6="Start Date 6"
        EndDate6="6. End Date"
        EntrealPct6="Percent Entreal 6"
        StartDate7="Start Date 7"
        EndDate7="7. End Date"
        EntrealPct7="Percent Entreal 7"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
