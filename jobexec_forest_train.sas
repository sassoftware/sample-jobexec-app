/* Copyright © 2020, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0 */

cas mysess;
caslib _all_ assign;

* Macro Variables for input, output data and files;
  %let dm_data_caslib = public;
  %let dm_datalib = public;
  %let dm_lib     = WORK;
  %let dm_folder  = %sysfunc(pathname(work));

%macro dm_unary_input;
%mend dm_unary_input;
%global dm_num_unary_input;
%let dm_num_unary_input = 0;
%macro dm_interval_input;
   'LOAN'n 'MORTDUE'n 'VALUE'n 'YOJ'n
%mend dm_interval_input;
%global dm_num_interval_input;
%let dm_num_interval_input = 7 ;
%macro dm_binary_input;
   'REASON'n
%mend dm_binary_input;
%global dm_num_binary_input;
%let dm_num_binary_input = 1 ;
%macro dm_nominal_input;
	'JOB'n
%mend dm_nominal_input;
%global dm_num_nominal_input;
%let dm_num_nominal_input = 4 ;
%macro dm_ordinal_input;
%mend dm_ordinal_input;
%global dm_num_ordinal_input;
%let dm_num_ordinal_input = 0;
%macro dm_class_input;
	'REASON'n
%mend dm_class_input;
%global dm_num_class_input;
%let dm_num_class_input = 5 ;
%macro dm_segment;
%mend dm_segment;
%global dm_num_segment;
%let dm_num_segment = 0;
%macro dm_id;
%mend dm_id;
%global dm_num_id;
%let dm_num_id = 0;
%macro dm_text;
%mend dm_text;
%global dm_num_text;
%let dm_num_text = 0;
%macro dm_strat_vars;
   'BAD'n
%mend dm_strat_vars;
%global dm_num_strat_vars;
%let dm_num_strat_vars = 1 ;

proc forest data=public.hmeq
     seed=12345 loh=0 binmethod=QUANTILE maxbranch=2 
     assignmissing=USEINSEARCH minuseinsearch=1
     ntrees=100
     maxdepth=20
     inbagfraction=0.6
     minleafsize=5
     numbin=50
     vote=PROBABILITY printtarget
  ;
  target 'BAD'n / level=nominal;
  input %dm_interval_input / level=interval;
  input %dm_binary_input %dm_nominal_input %dm_ordinal_input %dm_unary_input / level=nominal;
  grow IGR;
  savestate rstore=casuser.forest_astore;
run;

proc casutil;
	droptable incaslib=public casdata="forest_astore" quiet;
	promote incaslib=casuser casdata="forest_astore" outcaslib=public;
quit;