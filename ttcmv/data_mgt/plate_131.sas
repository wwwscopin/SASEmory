/* CREATED BY: nshenvi May 24,2010 13:54PM using DFsas */
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
  value F0137v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0138v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0139v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0140v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0141v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0142v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0143v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0144v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0145v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0146v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0147v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0148v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0149v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0150v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0151v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0152v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0153v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0154v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0155v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;
  value F0156v   1 = "Dopamine"
                 2 = "Dobutamine"
                 3 = "Epinephrine"
                 4 = "Norepinephrine"
                 5 = "Milinone"
                 6 = "Isoprotenol"
                 7 = "Prostaglandin"
                 8 = "Hydrocortisone"
                 9 = "Other" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_131.d01';
data cmv.vasopressor(label="Vasopressor Log");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat TreatmentDate1 MMDDYY8. ;  format TreatmentDate1  MMDDYY8. ;
  informat TreatmentDate2 MMDDYY8. ;  format TreatmentDate2  MMDDYY8. ;
  informat TreatmentDate3 MMDDYY8. ;  format TreatmentDate3  MMDDYY8. ;
  informat TreatmentDate4 MMDDYY8. ;  format TreatmentDate4  MMDDYY8. ;
  informat TreatmentDate5 MMDDYY8. ;  format TreatmentDate5  MMDDYY8. ;
  informat TreatmentDate6 MMDDYY8. ;  format TreatmentDate6  MMDDYY8. ;
  informat TreatmentDate7 MMDDYY8. ;  format TreatmentDate7  MMDDYY8. ;
  informat TreatmentDate8 MMDDYY8. ;  format TreatmentDate8  MMDDYY8. ;
  informat TreatmentDate9 MMDDYY8. ;  format TreatmentDate9  MMDDYY8. ;
  informat TreatmentDate10 MMDDYY8. ;  format TreatmentDate10  MMDDYY8. ;
  informat TreatmentDate11 MMDDYY8. ;  format TreatmentDate11  MMDDYY8. ;
  informat TreatmentDate12 MMDDYY8. ;  format TreatmentDate12  MMDDYY8. ;
  informat TreatmentDate13 MMDDYY8. ;  format TreatmentDate13  MMDDYY8. ;
  informat TreatmentDate14 MMDDYY8. ;  format TreatmentDate14  MMDDYY8. ;
  informat TreatmentDate15 MMDDYY8. ;  format TreatmentDate15  MMDDYY8. ;
  informat TreatmentDate16 MMDDYY8. ;  format TreatmentDate16  MMDDYY8. ;
  informat TreatmentDate17 MMDDYY8. ;  format TreatmentDate17  MMDDYY8. ;
  informat TreatmentDate18 MMDDYY8. ;  format TreatmentDate18  MMDDYY8. ;
  informat TreatmentDate19 MMDDYY8. ;  format TreatmentDate19  MMDDYY8. ;
  informat TreatmentDate20 MMDDYY8. ;  format TreatmentDate20  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  TreatmentDate1
        DrugCode1  dose1  concentration1  volume1  lbwi_weight1
        time_hr1  time_min1  TreatmentDate2  DrugCode2  dose2
        concentration2  volume2  lbwi_weight2  time_hr2  time_min2
        TreatmentDate3  DrugCode3  dose3  concentration3  volume3
        lbwi_weight3  time_hr3  time_min3  TreatmentDate4  DrugCode4
        dose4  concentration4  volume4  lbwi_weight4  time_hr4
        time_min4  TreatmentDate5  DrugCode5  dose5  concentration5
        volume5  lbwi_weight5  time_hr5  time_min5  TreatmentDate6
        DrugCode6  dose6  concentration6  volume6  lbwi_weight6
        time_hr6  time_min6  TreatmentDate7  DrugCode7  dose7
        concentration7  volume7  lbwi_weight7  time_hr7  time_min7
        TreatmentDate8  DrugCode8  dose8  concentration8  volume8
        lbwi_weight8  time_hr8  time_min8  TreatmentDate9  DrugCode9
        dose9  concentration9  volume9  lbwi_weight9  time_hr9
        time_min9  TreatmentDate10  DrugCode10  dose10  concentration10
        volume10  lbwi_weight10  time_hr10  time_min10  TreatmentDate11
        DrugCode11  dose11  concentration11  volume11  lbwi_weight11
        time_hr11  time_min11  TreatmentDate12  DrugCode12  dose12
        concentration12  volume12  lbwi_weight12  time_hr12  time_min12
        TreatmentDate13  DrugCode13  dose13  concentration13  volume13
        lbwi_weight13  time_hr13  time_min13  TreatmentDate14
        DrugCode14  dose14  concentration14  volume14  lbwi_weight14
        time_hr14  time_min14  TreatmentDate15  DrugCode15  dose15
        concentration15  volume15  lbwi_weight15  time_hr15  time_min15
        TreatmentDate16  DrugCode16  dose16  concentration16  volume16
        lbwi_weight16  time_hr16  time_min16  TreatmentDate17
        DrugCode17  dose17  concentration17  volume17  lbwi_weight17
        time_hr17  time_min17  TreatmentDate18  DrugCode18  dose18
        concentration18  volume18  lbwi_weight18  time_hr18  time_min18
        TreatmentDate19  DrugCode19  dose19  concentration19  volume19
        lbwi_weight19  time_hr19  time_min19  TreatmentDate20
        DrugCode20  dose20  concentration20  volume20  lbwi_weight20
        time_hr20  time_min20 ;
  /*format DFSTATUS DFSTATv. ;
  format DrugCode1 F0137v.  ;
  format DrugCode2 F0138v.  ;
  format DrugCode3 F0139v.  ;
  format DrugCode4 F0140v.  ;
  format DrugCode5 F0141v.  ;
  format DrugCode6 F0142v.  ;
  format DrugCode7 F0143v.  ;
  format DrugCode8 F0144v.  ;
  format DrugCode9 F0145v.  ;
  format DrugCode10 F0146v.  ;
  format DrugCode11 F0147v.  ;
  format DrugCode12 F0148v.  ;
  format DrugCode13 F0149v.  ;
  format DrugCode14 F0150v.  ;
  format DrugCode15 F0151v.  ;
  format DrugCode16 F0152v.  ;
  format DrugCode17 F0153v.  ;
  format DrugCode18 F0154v.  ;
  format DrugCode19 F0155v.  ;
  format DrugCode20 F0156v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        TreatmentDate1="1. Treatment Date"
        DrugCode1="1. Drug code"
        dose1="1. Avg daily dose"
        concentration1="1. Concentration"
        volume1="1.Volume"
        lbwi_weight1="1.lbwi_weight"
        time_hr1="1. Time hours"
        time_min1="1. Time mins"
        TreatmentDate2="2. Treatment Date"
        DrugCode2="2. Drug code"
        dose2="2. Avg daily dose"
        concentration2="2. Concentration"
        volume2="2.Volume"
        lbwi_weight2="2.lbwi_weight"
        time_hr2="2. Time hours"
        time_min2="2. Time mins"
        TreatmentDate3="3. Treatment Date"
        DrugCode3="3. Drug code"
        dose3="3. Avg daily dose"
        concentration3="3. Concentration"
        volume3="3.Volume"
        lbwi_weight3="3.lbwi_weight"
        time_hr3="3. Time hours"
        time_min3="3. Time mins"
        TreatmentDate4="4. Treatment Date"
        DrugCode4="4. Drug code"
        dose4="4. Avg daily dose"
        concentration4="43. Concentration"
        volume4="4.Volume"
        lbwi_weight4="4.lbwi_weight"
        time_hr4="4. Time hours"
        time_min4="4. Time mins"
        TreatmentDate5="5. Treatment Date"
        DrugCode5="5. Drug code"
        dose5="5. Avg daily dose"
        concentration5="5. Concentration"
        volume5="5.Volume"
        lbwi_weight5="5.lbwi_weight"
        time_hr5="5. Time hours"
        time_min5="5. Time mins"
        TreatmentDate6="6. Treatment Date"
        DrugCode6="6. Drug code"
        dose6="6. Avg daily dose"
        concentration6="6. Concentration"
        volume6="6.Volume"
        lbwi_weight6="6.lbwi_weight"
        time_hr6="6. Time hours"
        time_min6="6. Time mins"
        TreatmentDate7="7. Treatment Date"
        DrugCode7="7. Drug code"
        dose7="7. Avg daily dose"
        concentration7="7. Concentration"
        volume7="7.Volume"
        lbwi_weight7="7.lbwi_weight"
        time_hr7="7. Time hours"
        time_min7="7. Time mins"
        TreatmentDate8="8. Treatment Date"
        DrugCode8="8. Drug code"
        dose8="8. Avg daily dose"
        concentration8="8. Concentration"
        volume8="8.Volume"
        lbwi_weight8="8.lbwi_weight"
        time_hr8="8. Time hours"
        time_min8="8. Time mins"
        TreatmentDate9="9. Treatment Date"
        DrugCode9="9. Drug code"
        dose9="9. Avg daily dose"
        concentration9="9. Concentration"
        volume9="9.Volume"
        lbwi_weight9="9.lbwi_weight"
        time_hr9="9. Time hours"
        time_min9="9. Time mins"
        TreatmentDate10="10. Treatment Date"
        DrugCode10="10. Drug code"
        dose10="10. Avg daily dose"
        concentration10="10. Concentration"
        volume10="10.Volume"
        lbwi_weight10="10.lbwi_weight"
        time_hr10="10. Time hours"
        time_min10="10. Time mins"
        TreatmentDate11="11. Treatment Date"
        DrugCode11="11. Drug code"
        dose11="11. Avg daily dose"
        concentration11="11. Concentration"
        volume11="11.Volume"
        lbwi_weight11="11.lbwi_weight"
        time_hr11="11. Time hours"
        time_min11="11. Time mins"
        TreatmentDate12="12. Treatment Date"
        DrugCode12="12. Drug code"
        dose12="12. Avg daily dose"
        concentration12="12. Concentration"
        volume12="12.Volume"
        lbwi_weight12="12.lbwi_weight"
        time_hr12="12. Time hours"
        time_min12="12. Time mins"
        TreatmentDate13="13. Treatment Date"
        DrugCode13="13. Drug code"
        dose13="13. Avg daily dose"
        concentration13="13. Concentration"
        volume13="13.Volume"
        lbwi_weight13="13.lbwi_weight"
        time_hr13="13. Time hours"
        time_min13="13. Time mins"
        TreatmentDate14="14. Treatment Date"
        DrugCode14="14. Drug code"
        dose14="14. Avg daily dose"
        concentration14="14. Concentration"
        volume14="14.Volume"
        lbwi_weight14="14.lbwi_weight"
        time_hr14="14. Time hours"
        time_min14="14. Time mins"
        TreatmentDate15="15. Treatment Date"
        DrugCode15="15. Drug code"
        dose15="15. Avg daily dose"
        concentration15="15. Concentration"
        volume15="15.Volume"
        lbwi_weight15="15.lbwi_weight"
        time_hr15="15. Time hours"
        time_min15="15. Time mins"
        TreatmentDate16="16. Treatment Date"
        DrugCode16="16. Drug code"
        dose16="16. Avg daily dose"
        concentration16="16. Concentration"
        volume16="16.Volume"
        lbwi_weight16="16.lbwi_weight"
        time_hr16="16. Time hours"
        time_min16="16. Time mins"
        TreatmentDate17="17. Treatment Date"
        DrugCode17="17. Drug code"
        dose17="17. Avg daily dose"
        concentration17="17. Concentration"
        volume17="17.Volume"
        lbwi_weight17="17.lbwi_weight"
        time_hr17="17. Time hours"
        time_min17="17. Time mins"
        TreatmentDate18="18. Treatment Date"
        DrugCode18="18. Drug code"
        dose18="18. Avg daily dose"
        concentration18="18. Concentration"
        volume18="18.Volume"
        lbwi_weight18="18.lbwi_weight"
        time_hr18="18. Time hours"
        time_min18="18. Time mins"
        TreatmentDate19="19. Treatment Date"
        DrugCode19="19. Drug code"
        dose19="19. Avg daily dose"
        concentration19="19. Concentration"
        volume19="19.Volume"
        lbwi_weight19="19.lbwi_weight"
        time_hr19="19. Time hours"
        time_min19="19. Time mins"
        TreatmentDate20="20. Treatment Date"
        DrugCode20="20. Drug code"
        dose20="20. Avg daily dose"
        concentration20="20. Concentration"
        volume20="20.Volume"
        lbwi_weight20="20.lbwi_weight"
        time_hr20="20. Time hours"
        time_min20="20. Time mins"; run;
