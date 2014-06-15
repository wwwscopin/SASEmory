/* CREATED BY: nshenvi May 25,2010 08:48AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;/*
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_083.d01';
data cmv.infection_p2(label="Infection pg 2/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat Culture3Date MMDDYY8. ;  format Culture3Date  MMDDYY8. ;
  informat Culture3SiteOther $CHAR50. ;
  informat Culture3OrgOther $CHAR150. ;
  informat Culture4Date MMDDYY8. ;  format Culture4Date  MMDDYY8. ;
  informat Culture4SiteOther $CHAR50. ;
  informat Culture4OrgOther $CHAR150. ;
  informat Culture5Date MMDDYY8. ;  format Culture5Date  MMDDYY8. ;
  informat Culture5SiteOther $CHAR50. ;
  informat Culture5OrgOther $CHAR150. ;
  informat Culture6Date MMDDYY8. ;  format Culture6Date  MMDDYY8. ;
  informat Culture6SiteOther $CHAR50. ;
  informat Culture6OrgOther $CHAR150. ;
  informat Comments $CHAR1000. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  Culture3Date
        Culture3Site  Culture3SiteOther $  Culture3Org
        Culture3OrgOther $  Culture4Date  Culture4Site
        Culture4SiteOther $  Culture4Org  Culture4OrgOther $
        Culture5Date  Culture5Site  Culture5SiteOther $  Culture5Org
        Culture5OrgOther $  Culture6Date  Culture6Site
        Culture6SiteOther $  Culture6Org  Culture6OrgOther $  Comments $
        IsNarrative ;
  *format DFSTATUS DFSTATv. ;
  *format IsNarrative F0002v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        Culture3Date="Positive culture 3 : Culture date"
        Culture3Site="Positive culture 3 : Culture Site"
        Culture3SiteOther="Positive culture 3: Culture Site Other"
        Culture3Org="Positive culture 3 : Culture Oragnism"
        Culture3OrgOther="Positive culture 3 : Culture Org Other"
        Culture4Date="Positive culture 4 : Culture date"
        Culture4Site="Positive culture 4 : Culture Site"
        Culture4SiteOther="Positive culture 4 : Culture Site Other"
        Culture4Org="Positive culture 4: Culture Oragnism"
        Culture4OrgOther="Positive culture 4 : Culture Org Other"
        Culture5Date="Positive culture 5 : Culture date"
        Culture5Site="Positive culture 5 : Culture Site"
        Culture5SiteOther="Positive culture 5: Culture Site Other"
        Culture5Org="Positive culture 5 : Culture Oragnism"
        Culture5OrgOther="Positive culture 5 : Culture Org Other"
        Culture6Date="Positive culture 6 : Culture date"
        Culture6Site="Positive culture 6 : Culture Site"
        Culture6SiteOther="Positive culture 6: Culture Site Other"
        Culture6Org="Positive culture 6 : Culture Oragnism"
        Culture6OrgOther="Positive culture 6 : Culture Org Other"
        Comments="Comments"
        IsNarrative="IsNarrative";
run;
