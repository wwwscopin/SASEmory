
data cmv.kramer;
input gender ga n third fifth tenth fiftieth ninetieth nintyfifth ninetyseventh mean sd;
datalines;
1	22	82	338	368	401	490	587	627	659	501	111
1	23	114	406	434	475	589	714	762	797	598	114
1	24	156	468	498	547	690	844	902	940	697	125
1	25	202	521	557	617	795	981	1048	1092	800	147
1	26	234	571	614	686	908	1125	1200	1251	909	178
1	27	254	627	677	763	1033	1278	1358	1416	1026	209
1	28	330	694	752	853	1173	1445	1532	1598	1159	241
1	29	392	780	845	964	1332	1629	1729	1809	1312	273
1	30	467	885	959	1099	1507	1837	1955	2053	1487	306
1	31	584	1012	1098	1259	1698	2069	2209	2327	1682	339
1	32	997	1164	1266	1444	1906	2319	2478	2614	1896	369
1	33	1368	1344	1460	1648	2127	2580	2750	2897	2123	391
1	34	2553	1552	1677	1866	2360	2851	3029	3184	2361	410
1	35	4314	1783	1907	2091	2600	3132	3318	3475	2607	428
1	36	9648	2024	2144	2321	2845	3411	3604	3759	2855	443
1	37	19965	2270	2384	2552	3080	3665	3857	4003	3091	449
1	38	51947	2498	2605	2766	3290	3877	4065	4202	3306	448
1	39	77623	2684	2786	2942	3465	4049	4232	4361	3489	445
1	40	112737	2829	2927	3079	3613	4200	4382	4501	3638	447
1	41	54139	2926	3025	3179	3733	4328	4512	4631	3745	459
1	42	8791	2960	3070	3233	3815	4433	4631	4773	3800	485
1	43	276	2954	3081	3249	3864	4528	4747	4941	3793	527
2	22	80	332	347	385	466	552	576	576	472	72
2	23	106	379	403	450	557	669	706	726	564	95
2	24	148	424	456	513	651	790	839	887	656	121
2	25	184	469	508	578	751	918	982	1060	754	152
2	26	191	516	562	645	858	1060	1139	1247	860	186
2	27	188	569	624	717	976	1218	1313	1446	976	222
2	28	287	634	697	802	1109	1390	1499	1657	1107	254
2	29	299	716	787	903	1259	1578	1701	1885	1256	286
2	30	390	814	894	1022	1427	1783	1918	2121	1422	319
2	31	461	938	1026	1168	1613	2004	2150	2347	1604	345
2	32	795	1089	1184	1346	1817	2242	2399	2578	1808	368
2	33	1055	1264	1369	1548	2035	2494	2664	2825	2029	389
2	34	2018	1467	1581	1768	2266	2761	2948	3097	2266	409
2	35	3391	1695	1813	1998	2506	3037	3242	3384	2512	426
2	36	8203	1935	2052	2227	2744	3307	3523	3660	2754	439
2	37	17308	2177	2286	2452	2968	3543	3752	3886	2981	443
2	38	47516	2406	2502	2658	3169	3738	3931	4061	3181	439
2	39	7568	2589	2680	2825	3334	3895	4076	4202	3350	434
2	40	110738	2722	2814	2955	3470	4034	4212	4331	3486	434
2	41	52063	2809	2906	3051	3576	4154	4330	4444	3588	439
2	42	7970	2849	2954	3114	3655	4251	4423	4554	3656	448
2	43	277	2862	2975	3159	3717	4333	4495	4685	3693	459
;
run;