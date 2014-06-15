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
  value F0001v   0 = "Unchecked"
                 1 = "Checked" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_082.d01';
data cmv.infection_p1(label="Infection Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat InfectionSiteOther $CHAR50. ;
  informat XrayDate MMDDYY8. ;  format XrayDate  MMDDYY8. ;
  informat Culture1Date MMDDYY8. ;  format Culture1Date  MMDDYY8. ;
  informat Culture1SiteOther $CHAR50. ;
  informat Culture1OrgOther $CHAR150. ;
  informat Culture2Date MMDDYY8. ;  format Culture2Date  MMDDYY8. ;
  informat Culture2SiteOther $CHAR50. ;
  informat Culture2OrgOther $CHAR150. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormCompl  SiteBlood  SiteCNS  SiteUT  SiteCardio
        SiteLowerResp  SiteOther  InfectionSiteOther $  SiteGI
        SiteSurgical  InfecConfirm  XrayDate  CultureYes
        CulturePositive  Culture1Date  Culture1Site  Culture1SiteOther $
        Culture1Org  Culture1OrgOther $  Culture2Date  Culture2Site
        Culture2SiteOther $  Culture2Org  Culture2OrgOther $ ;
  /*format DFSTATUS DFSTATv. ;
  format SiteBlood F0001v.  ;
  format SiteCNS  F0001v.  ;
  format SiteUT   F0001v.  ;
  format SiteCardio F0001v.  ;
  format SiteLowerResp F0001v.  ;
  format SiteOther F0001v.  ;
  format SiteGI   F0001v.  ;
  format SiteSurgical F0001v.  ;
  format InfecConfirm F0002v.  ;
  format CultureYes F0002v.  ;
  format CulturePositive F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        SiteBlood="SiteBlood"
        SiteCNS="SiteCNS"
        SiteUT="SiteUT"
        SiteCardio="SiteCardio"
        SiteLowerResp="SiteLowerResp"
        SiteOther="SiteOther"
        InfectionSiteOther="Infection Site Other"
        SiteGI="SiteGI"
        SiteSurgical="SiteSurgical"
        InfecConfirm="InfecConfirm"
        XrayDate="XrayDate"
        CultureYes="CultureYes"
        CulturePositive="CulturePositive"
        Culture1Date="Positive culture 1 : Culture date"
        Culture1Site="Positive culture 1 : Culture Site"
        Culture1SiteOther="Positive culture 1 : Culture Site Other"
        Culture1Org="Positive culture 1 : Culture Oragnism"
        Culture1OrgOther="Positive culture 1 : Culture Org Other"
        Culture2Date="Positive culture 2 : Culture date"
        Culture2Site="Positive culture 2 : Culture Site"
        Culture2SiteOther="Positive culture 2: Culture Site Other"
        Culture2Org="Positive culture 2 : Culture Oragnism"
        Culture2OrgOther="Positive culture 2 : Culture Org Other";
run;
