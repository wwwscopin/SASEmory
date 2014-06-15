/* CREATED BY: nshenvi Apr 09,2010 08:19AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_078.d01';
data cmv.rop(label="ROP");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormComplete  LeftRetinopathy  RightRetinopathy
        LeftRetinopathyStage  RightRetinopathyStage  LeftPlus
        RightPlus  LeftLaser  RightLaser  LeftCryotherapy
        RightCryotherapy  LeftScleBuckle  RightScleBuckle
        LeftVitrectomy  RightVitrectomy ;
 /* format DFSTATUS DFSTATv. ;
  format LeftRetinopathy F0002v.  ;
  format RightRetinopathy F0002v.  ;
  format LeftPlus F0002v.  ;
  format RightPlus F0002v.  ;
  format LeftLaser F0002v.  ;
  format RightLaser F0002v.  ;
  format LeftCryotherapy F0002v.  ;
  format RightCryotherapy F0002v.  ;
  format LeftScleBuckle F0002v.  ;
  format RightScleBuckle F0002v.  ;
  format LeftVitrectomy F0002v.  ;
  format RightVitrectomy F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        LeftRetinopathy="1.1 Left ROP developed?"
        RightRetinopathy="1.1 Right ROP developed?"
        LeftRetinopathyStage="1.1 Left ROP Stage"
        RightRetinopathyStage="RightRetinopathyStage"
        LeftPlus="LeftPlus"
        RightPlus="1.1 Right ROP Stage"
        LeftLaser="2.1 Left Laser"
        RightLaser="2.1 Right Laser"
        LeftCryotherapy="2.2 Left retinal ablation?"
        RightCryotherapy="2.2 Right retinal ablation?"
        LeftScleBuckle="2.3 Left Scleral Buckle"
        RightScleBuckle="2.3 Right Scleral Buckle"
        LeftVitrectomy="2.4 Left vitrectomy performed?"
        RightVitrectomy="2.4 Right vitrectomy performed?";
