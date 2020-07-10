/* Copyright © 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0 */

cas mysess;
caslib _all_ assign;

/* Sample parameters  */
%let p_loan = 500000;
%let p_mortdue = 195;
%let p_value = 163;
%let p_yoj = 10;
%let p_reason = HomeImp;
%let p_job = Office;

/* Create dataset with the input parameters */

proc sql;
   create table inserted_data
       (LOAN num, 
		MORTDUE num,
		VALUE num,
		YOJ num,
		REASON char(10),
		JOB char(10));

insert into inserted_data
    values(&p_loan, &p_mortdue, &p_value, &p_yoj, "&p_reason", "&p_job");
run;

/* Copy data to a CASLIB */
data casuser.to_score;
	set work.inserted_data;
run;

/*  Let's score the dataset with the previously created ASTORE
	p.s.: excluding the ODS output as it is not relevant for this analysis
 */
ods exclude all;
proc astore;
/* 	describe rstore=public.forest_astore; */
 	score data=casuser.to_score out=public.scoreout1 rstore=public.forest_astore copyvars=(_ALL_) ;
quit;
run;
ods exclude none;

/*  Making the probability outcome become a text so it is easier for the 
	analyst to interpret it.
*/

data public.outcome;
	length outcome $ 30;
	set public.scoreout1;
	if I_BAD = 1 then
		do;
			outcome = 'Your request was approved';
		end;
	else
	   do;
			outcome = 'Your request was NOT approved';
	   end;
run;

/* Printing the outcome */
proc print data=public.outcome noobs;
	title "Here is the result from your request: ";
	var outcome;
run;


/* The plots below helps the analyst to understand how the 
	scored inputs compare to the historical data.
*/

proc sgplot data=public.hmeq; 
	title "You requested $ &p_loan - here is how it compares to historical data:";
 	histogram LOAN / nbins = 100;
	REFLINE &p_loan / axis=X lineattrs=(thickness=2 color=darkred pattern=dash); 
run;

proc sgplot data=public.hmeq; 
	title "You filled $ &p_mortdue for MORTDUE - here is how it compares to historical data:";
 	histogram MORTDUE / nbins = 100;
	REFLINE &p_mortdue / axis=X lineattrs=(thickness=2 color = darkred pattern = dash); 
run;

proc sgplot data=public.hmeq; 
	title "You filled $ &p_value for Value of current property - here is how it compares to historical data:";
 	histogram VALUE / nbins = 100;
	REFLINE &p_value / axis=X lineattrs=(thickness=2 color=darkred pattern=dash); 
run;

proc sgplot data=public.hmeq; 
	title "You filled &p_yoj for years on the job - here is how it compares to historical data:";
 	histogram YOJ / nbins=100;
	REFLINE &p_yoj / axis=X lineattrs=(thickness=2 color=darkred pattern=dash); 
run;

proc sgplot data=public.hmeq;
	title "You filled &p_reason for reason - here is how it compares to historical data:";
	vbar REASON;
    refline "&p_reason" / axis=x 
          lineattrs=(thickness=2 color=darkred pattern=dash);
run;

proc sgplot data=public.hmeq;
	title "You filled &p_job for reason - here is how it compares to historical data:";
	vbar JOB;
    refline "&p_job" / axis=x 
          lineattrs=(thickness=2 color=darkred pattern=dash);
run;