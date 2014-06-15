/* CREATED BY: nshenvi Feb 16,2010 14:41PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_007.d01';
data cmv.plate_007(label="MOC Demographic P 1 / 2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat MOC_DOB  MMDDYY10. ;  format MOC_DOB  MMDDYY10. ;
  informat RaceOther $CHAR20. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormCompl  MOC_DOB  zipcode  IsHispanic  MOC_race
        RaceOther $  MaritalStatus  Education  Insurance  UseCigarettes
        UseAlcohol  UseDrugs  DiaperCare ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        MOC_DOB="MOC Date of Birth"
        zipcode="zipcode"
        IsHispanic="Is MOC Hispanic"
        MOC_race="MOC race"
        RaceOther="Race Other"
        MaritalStatus="Marital Status"
        Education="Education"
        Insurance="Medical Insurance"
        UseCigarettes="Did MOC use cigarettes"
        UseAlcohol="Did MOC use alcohol"
        UseDrugs="Did MOC use drugs"
        DiaperCare="Did mother care Diaper";

if MOC_race = 99 then MOC_race=.;
if MaritalStatus = 99 then MaritalStatus=.;
if Education = 99 then Education=.;
if Insurance = 99 then Insurance=.;
if UseCigarettes = 99 then UseCigarettes=.;
if UseAlcohol = 99 then UseAlcohol= 99;
if UseDrugs = 99 then UseDrugs = .;
if DiaperCare  = 99 then DiaperCare =.;


