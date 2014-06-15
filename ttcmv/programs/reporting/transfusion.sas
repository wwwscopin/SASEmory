data trans_rbc;
	set cmv.plate_031;
	rbc_txt0=HMS(scan(rbc_TxStartTime,1,":"), scan(rbc_TxStartTime,2,":"), 0 ); 
	rbc_txt1=HMS(scan(rbc_TxEndTime,1,":"), scan(rbc_TxEndTime,2,":"), 0 ); 
	rbc_txt=rbc_txt1-rbc_txt0; if rbc_txt<0 then rbc_txt=rbc_txt+24*3600;
	keep id BodyWeight DateHbHct DateTransfusion Hb HbHctTest Hct TimeHbHct rbcVolumeTransfused rbc_TxEndTime rbc_TxStartTime rbc_txt;
run;

proc print data=trans_rbc;run;

data trans_plt;
	set cmv.plate_033;
	plt_txt0=HMS(scan(plt_TxStartTime,1,":"), scan(plt_TxStartTime,2,":"), 0 ); 
	plt_txt1=HMS(scan(plt_TxEndTime,1,":"), scan(plt_TxEndTime,2,":"), 0 ); 
	plt_txt=plt_txt1-plt_txt0; if plt_txt<0 then plt_txt=plt_txt+24*3600;
	keep id plt_TxStartTime plt_TxEndTime plt_txt plt_VolumeTransfused DatePlateletCount DateTransfusion PlateletCount PlateletNum TimePlateletCount;
run;

data trans_ffp;
	set cmv.plate_035;
	ffp_txt0=HMS(scan(ffp_TxStartTime,1,":"), scan(ffp_TxStartTime,2,":"), 0 ); 
	ffp_txt1=HMS(scan(ffp_TxEndTime,1,":"), scan(ffp_TxEndTime,2,":"), 0 ); 
	ffp_txt=ffp_txt1-ffp_txt0; if ffp_txt<0 then ffp_txt=ffp_txt+24*3600;
	keep id ffp_TxStartTime ffp_TxEndTime ffp_txt ffp_VolumeTransfused DatePtPTTTest PT PTT fibrinogen inr PTPTTest TimePtPTTTest DateTransfusion;
run;

data trans_cryo;
	set cmv.plate_037;
	cryo_txt0=HMS(scan(cryo_TxStartTime,1,":"), scan(cryo_TxStartTime,2,":"), 0 ); 
	cryo_txt1=HMS(scan(cryo_TxEndTime,1,":"), scan(cryo_TxEndTime,2,":"), 0 ); 
	cryo_txt=cryo_txt1-cryo_txt0; if cryo_txt<0 then cryo_txt=cryo_txt+24*3600;
	keep id cryo_TxStartTime cryo_TxEndTime cryo_txt cryo_VolumeTransfused DateFibrinogen Fibrinogen FibrinogenLevel TimeFibrinogen  		  DateTransfusion;
run;

