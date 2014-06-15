/******************** Infection data ***************************/
proc sql;
create table infection as
select a.id,b.*
from cmv_id as a left join
cmv.infection_all as b
on a.id=b.id;
quit;


proc format;
value siteblood
1="Blood"
0="."
.=".";

value sitecns
1="CNS"
0="."
.=".";

value siteUT
1="UT"
0="."
.=".";

value siteCardio
1="Cardio"
0="."
.=".";

value siteResp
1="Lower Resp"
0="."
.=".";

value siteGI
1="GI"
0="."
.=".";

value siteSurgical
1="Surgical"
0="."
.=".";

value cultureSite
1="Blood"
2="Urine"
3="Wound"
4="Sputum/Trachael aspirate"
5="BAL"
6="CSF"
7="Stool"
8="Cathetar tip"
9="Other"
.=""
;

value cultureOrg
1="Stap epidermidis"
2="MSSA"
3="MRSA"
4="Vancomycin-susceptible Enterococcus faecalis"
5="Vancomycin-resistant Enterococcus faecalis"
6="Vancomycin-susceptible Enterococcus faecium"
7="Vancomycin-resistant Enterococcus faecium"
8="Kleb pneumoniae"
9="P aeruginosa"
10="Strep pneumoniae"
11="Strep viridans"
12="Strep agalactiae"
13="E coli"
14="Acinobacter baumannii"
15="Enterbacter cloace"
16="Enterbacter aerogenes"
17="Clostridium difficile"
18="Candida albicans"
19="Candida glabrata"
20="Candida tropicalis"
21="Influenza"
22="Henoch Schonlein purpura"
23="Respiratory Syntial virus"
24="Epstein Bar virus"
25="Enterovirus"
26="Adenovirus"
;

value yn
1="Yes"
0="No"
;


quit;
data infection; set infection;
length inf_site_stat $ 50;

length culture1_site_stat $ 50;
length culture2_site_stat $ 50;
length culture3_site_stat $ 50;
length culture4_site_stat $ 50;

length xray_conf $ 20;

if siteLowerResp = 1 and InfecConfirm = 1 then xray_conf="(Infiltrate confirmed)";
if siteLowerResp = 1 and InfecConfirm =0  then xray_conf="(Infiltrate NOT confirmed)";
if siteLowerResp = 1 and InfecConfirm not in (1,0)  then xray_conf="";
if siteLowerResp ~= 1   then xray_conf="";

inf_site_stat=put(siteblood,siteblood.) || "" || put(sitecns,sitecns.)
						|| "" || put(siteUT,siteUT.) || "" || put(sitecardio,sitecardio.)
						|| "" || put(siteLowerResp,siteResp.) || "" || xray_conf || put(siteGI,siteGI.)
						|| "" || put(siteSurgical,siteSurgical.);

if culture1Site ~= . then 
culture1_site_stat=put(culture1Site,cultureSite.) || "\n" || put(culture1org,cultureorg.);


if culture2Site ~= . then 
culture2_site_stat=put(culture2Site,cultureSite.) || "\n" || put(culture2org,cultureorg.);


if culture3Site ~= . then 
culture3_site_stat=put(culture3Site,cultureSite.) || "\n" || put(culture3org,cultureorg.);


if culture4Site ~= . then 
culture4_site_stat=put(culture4Site,cultureSite.) || "\n" || put(culture4org,cultureorg.);

run;


