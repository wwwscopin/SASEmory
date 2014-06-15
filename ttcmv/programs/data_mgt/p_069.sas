/* CREATED BY: nshenvi Feb 25,2010 12:37PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
 /* value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0088v   99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "Not Done (Image N/A)" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
*/
run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_069.d01';
data cmv.plate_069 (label="IVH Pg 2/ 2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat USoundDate MMDDYY8. ;  format USoundDate  MMDDYY8. ;
  informat Comments $CHAR1000. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  InUteroFindings
        USoundDate  GerminalMatrix  LeftVentricle  RightVentricle
        LeftParenchyma  RightParenchyma  LeftVentWithBlood
        RightVenWithBlood  LeftVentWoutBlood  RightVentWoutBlood
        Comments $  IsNarrative ;
  /*format DFSTATUS DFSTATv. ;
  format InUteroFindings F0088v.  ;
  format GerminalMatrix F0002v.  ;
  format LeftVentricle F0002v.  ;
  format RightVentricle F0002v.  ;
  format LeftParenchyma F0002v.  ;
  format RightParenchyma F0002v.  ;
  format LeftVentWithBlood F0002v.  ;
  format RightVenWithBlood F0002v.  ;
  format LeftVentWoutBlood F0002v.  ;
  format RightVentWoutBlood F0002v.  ;
  format IsNarrative F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        InUteroFindings="4.1 In Utero Findings"
        USoundDate="4.1a Date of Ultra Sound"
        GerminalMatrix="4.1b. Blood/echo density Germinal Matrix"
        LeftVentricle="4.1c. Blood/echo density Left Ventricle"
        RightVentricle="4.1c. Blood/echo density Right Ventricle"
        LeftParenchyma="4.1d. Blood/echo density Left Parenchyma"
        RightParenchyma="4.1d. Blood/echo density RightParenchyma"
        LeftVentWithBlood="4.1e. Left Vent With Blood"
        RightVenWithBlood="41.1e Right Ven With Blood"
        LeftVentWoutBlood="4.1f. Left Vent With out Blood"
        RightVentWoutBlood="4.1f. Right Vent With out Blood"
        Comments="Comments"
        IsNarrative="IsNarrative";
