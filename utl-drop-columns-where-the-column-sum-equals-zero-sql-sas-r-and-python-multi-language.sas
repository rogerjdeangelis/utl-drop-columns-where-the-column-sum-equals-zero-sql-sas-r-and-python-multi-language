%let pgm=utl-drop-columns-where-the-column-sum-equals-zero-sql-sas-r-and-python-multi-language;

%stop_submission;

Drop columns where the column sum equals zero sql sas r and python multi-language

    SOLUTIONS

        1 sas sql
        2 r sql
          a. hardcoded
          b. dynamic (sql arrays  - handles all variables with prefix cx1_, no matter how many)
          c. generate code and insert in r script

          r should upgrade sqldf and add 'ALTER TABLE'
          (automatically generate code and insert in the R script)

        3 r tidyverse language
        4 python in memory sqllite3
          cludgy-had a hard time

github
https://tinyurl.com/ypn7hskf
https://github.com/rogerjdeangelis/utl-drop-columns-where-the-column-sum-equals-zero-sql-sas-r-and-python-multi-language

Although proceedural solutions are often simpler. My hope to provide solutions for skilled SQL programmers.
Leveraging your sql knowledge to R and Python.

SOAPBOX ON
R

It appears that RSQLLite has not been updated to support
  ALTER TABLE DROP COLUMN (see my workaround)

Pyhton does not support

 1 ALTER TABLE DROP COLUMN
 2 Data dictionaries (need to use the less convenient in memory sqllite database?)
 3 Math and Stat functions like standard deviation

SOAPBOX OFF

r stackoverflow
https://stackoverflow.com/questions/79086427/subset-columns-based-on-condition-on-a-subset-of-columns-dplyr

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/**************************************************************************************************************************/
/*                                  |                                               |                                     */
/*               INPUT              |                   PROCESS                     |            OUTPUT                   */
/*                                  |                                               |                                     */
/*                                  |           DROP CX1_A BECAUSE IT SUMS TO ZERO  |                                     */
/*                                  |                                               |                                     */
/* SD1.HAVE total obs=5             |     IF THE CX1* COL SUMS TO 0 DROP THE COLUMN |                                     */
/*                                  |                                               |                                     */
/*                                  |     NO CHANGE     DROP CX1_A     NO CHANGE    |      CX1_A HAS BEEN DROPPED         */
/*                 CX1 CX1 CX2 CX2  |     =========     ===========   ===========   |                                     */
/* NAME1 NAME2 ID3  _A  _B _A  _B   | NAME1 NAME2 ID3   CX1_A CX1_B   CX2_A CX2_B   |  NAME1 NAME2 ID3 CX1_B CX2_A CX2_B  */
/*                                  |                                               |                                     */
/*  a       6   0   0   1   0   4   |  a     6     0       0     1     0     4      |    a     6   0     1     0     4    */
/*  b       7   0   0   2   0   5   |  b     7     0       0     2     0     5      |    b     7   0     2     0     5    */
/*  c       4   0   0   0   1   0   |  c     4     0       0     0     1     0      |    c     4   0     0     1     0    */
/*  d       5   0   0   0   1   0   |  d     5     0       0     0     1     0      |    d     5   0     0     1     0    */
/*  e       5   0   0   0   0   0   |  e     5     0       0     0     0     0      |    e     5   0     0     0     0    */
/*                                  |                     ==                        |                                     */
/*                                  |                      0                        |                                     */
/*                                  |-----------------------------------------------|                                     */
/*                                  |                                               |                                     */
/*                                  | SAS SQL                                       |                                     */
/*                                  | =======                                       |                                     */
/*                                  |    %array(_vrs,values=                        |                                     */
/*                                  |      %utl_varlist(sd1.have,keep=cx1_:));      |                                     */
/*                                  |                                               |                                     */
/*                                  |    %put &_vrs1;  _VARS1=CX1_A                 |                                     */
/*                                  |    %put &_vrs2;  _VARS2=CX1_B                 |                                     */
/*                                  |    %put &_vrsn;  _VARSN=2                     |                                     */
/*                                  |                                               |                                     */
/*                                  |     Runs the code twice with CX1_A then CX1_B |                                     */
/*                                  |     %do_over(_vrs,phrase=%nrstr(              |                                     */
/*                                  |      SELECT CASE                              |                                     */
/*                                  |        WHEN sum(?) = 0 THEN 1                 |                                     */
/*                                  |        ELSE 0                                 |                                     */
/*                                  |      END INTO :drop_column                    |                                     */
/*                                  |      FROM sd1.have                            |                                     */
/*                                  |      ;                                        |                                     */
/*                                  |      %IF &drop_column = 1 %THEN %DO;          |                                     */
/*                                  |        ALTER TABLE sd1.have                   |                                     */
/*                                  |        DROP ?;                                |                                     */
/*                                  |      %END;                                    |                                     */
/*                                  |      ));                                      |                                     */
/*                                  |    QUIT;                                      |                                     */
/*                                  |                                               |                                     */
/*                                  |-----------------------------------------------|                                     */
/*                                  |                                               |                                     */
/*                                  |    R TIDYVERSE LANGUAGE  (looks like PERL)    |                                     */
/*                                  |    ====================                       |                                     */
/*                                  |                                               |                                     */
/*                                  |    want<-have %>%                             |                                     */
/*                                  |      select(                                  |                                     */
/*                                  |        .,                                     |                                     */
/*                                  |        - any_of(                              |                                     */
/*                                  |          select(., matches('^CX[12]'))        |                                     */
/*                                  |          %>% keep(~ sum(.x) == 0) %>% names() |                                     */
/*                                  |        )                                      |                                     */
/*                                  |      )                                        |                                     */
/*                                  |                                               |                                     */
/*                                  |-----------------------------------------------|                                     */
/*                                  |                                               |                                     */
/*                                  | PYTHON AND R SQL HARDCODE (DYNAMIC is BELOW   |                                     */
/*                                  | ===========================================   |                                     */
/*                                  |                                               |                                     */
/*                                  | keeps <- sqldf("                              |                                     */
/*                                  |  with drops as (                              |                                     */
/*                                  |   select                                      |                                     */
/*                                  |      case                                     |                                     */
/*                                  |        when sum(cx1_a) = 0 then 'CX1_A'       |                                     */
/*                                  |        else 'x'                               |                                     */
/*                                  |      end as cx                                |                                     */
/*                                  |      from have                                |                                     */
/*                                  |   union                                       |                                     */
/*                                  |     all                                       |                                     */
/*                                  |   select                                      |                                     */
/*                                  |      case                                     |                                     */
/*                                  |        when sum(cx1_b) = 0 then 'CX1_B'       |                                     */
/*                                  |        else 'x'                               |                                     */
/*                                  |      end as cx                                |                                     */
/*                                  |      from have )                              |                                     */
/*                                  |   select                                      |                                     */
/*                                  |     group_concat(name, ',') as names          |                                     */
/*                                  |   from                                        |                                     */
/*                                  |     pragma_table_info('have')                 |                                     */
/*                                  |   where                                       |                                     */
/*                                  |     name not in (                             |                                     */
/*                                  |       select * from drops where cx <> 'x')    |                                     */
/*                                  |   ")                                          |                                     */
/*                                  |  want <- sqldf(paste('select '                |                                     */
/*                                  |           ,keeps$names                        |                                     */
/*                                  |           ,' from have'))                     |                                     */
/*                                  |                                               |                                     */
/*                                  |  WHAT IS GOING ON ABOVE                       |                                     */
/*                                  |  ======================                       |                                     */
/*                                  |                                               |                                     */
/*                                  |  1. creates just one variable, cx,            |                                     */
/*                                  |     containing  'CX1_A' when                  |                                     */
/*                                  |     the sum(CX1_A)=0 otherwise                |                                     */
/*                                  |     cx = 'x'                                  |                                     */
/*                                  |  2  stacks the cx above with second value     |                                     */
/*                                  |     containing  'CX1_B' when                  |                                     */
/*                                  |     the sum(CX1_B)=0 otherwise                |                                     */
/*                                  |     cx = 'x'                                  |                                     */
/*                                  |  3  The result is                             |                                     */
/*                                  |       cx                                      |                                     */
/*                                  |       ==                                      |                                     */
/*                                  |       'CX1_A'  because sum(CX1_A)  =0         |                                     */
/*                                  |       'X'      because sum(CX1_B) != 0        |                                     */
/*                                  |  4  Get the variable list in original         |                                     */
/*                                  |     have table and remove CX1_B               |                                     */
/*                                  |     remove CX1_A using                        |                                     */
/*                                  |     where cx <> 'x'                           |                                     */
/*                                  |     create varible names with the             |                                     */
/*                                  |     variable list minus CX1_A                 |                                     */
/*                                  |     NAME1,NAME2,ID3,CX1_B,CX2_A,CX2_B         |                                     */
/*                                  |                                               |                                     */
/*                                  |  5  Unfortunately sqld does not support       |                                     */
/*                                  |     ALTER TABLE DROP COLUMN so we             |                                     */
/*                                  |     need to constuct the query using          |                                     */
/*                                  |     the names above                           |                                     */
/*                                  |     and send the query to sqllite             |                                     */
/*                                  |                                               |                                     */
/*                                  |     sqldf(paste('select ',keeps$names         |                                     */
/*                                  |      ,' from have'))                          |                                     */
/*                                  |                                               |                                     */
/*                                  |                                               |                                     */
/*                                  |     select                                    |                                     */
/*                                  |      NAME1,NAME2,ID3,CX1_B,CX2_A,CX2_B        |                                     */
/*                                  |     from have                                 |                                     */
/*                                  |                                               |                                     */
/**************************************************************************************************************************/


/*                   _
(_)_ __  _ __      _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/


options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input  name1$ name2 id3 cx1_a cx1_b cx2_a cx2_b;
cards4;
a     6   0     0     1     0     4
b     7   0     0     2     0     5
c     4   0     0     0     1     0
d     5   0     0     0     1     0
e     5   0     0     0     0     0
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.HAVE total obs=5                                                                                                   */
/*                                                                                                                        */
/* Obs    NAME1    NAME2    ID3    CX1_A    CX1_B    CX2_A    CX2_B                                                       */
/*                                                                                                                        */
/*  1       a        6       0       0        1        0        4                                                         */
/*  2       b        7       0       0        2        0        5                                                         */
/*  3       c        4       0       0        0        1        0                                                         */
/*  4       d        5       0       0        0        1        0                                                         */
/*  5       e        5       0       0        0        0        0                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                             _
/ |  ___  __ _ ___   ___  __ _| |
| | / __|/ _` / __| / __|/ _` | |
| | \__ \ (_| \__ \ \__ \ (_| | |
|_| |___/\__,_|___/ |___/\__, |_|
                            |_|
*/

* create macro array for use with SQL;

%array(_vrs,values=
  %utl_varlist(sd1.have,keep=cx1_:));

%put &_vrs1; /* _VARS1=CX1_A  */
%put &_vrs2; /* _VARS2=CX1_B  */
%put &_vrsn; /* _VARSN=2      */


/* Runs the code twice with CX1_A then CX1_B */
PROC SQL;
 %do_over(_vrs,phrase=%nrstr(
  SELECT CASE
    WHEN sum(?) = 0 THEN 1
    ELSE 0
  END INTO :drop_column
  FROM sd1.have
  ;
  %IF &drop_column = 1 %THEN %DO;
    ALTER TABLE sd1.have
    DROP ?;
  %END;
  ));
QUIT;

proc print data=sd1.have;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*             CX1_A HAS BEEN DROPPED                                                                                     */
/*                                                                                                                        */
/*  NAME1    NAME2    ID3      CX1_B    CX2_A    CX2_B                                                                    */
/*                                                                                                                        */
/*    a        6       0         1        0        4                                                                      */
/*    b        7       0         2        0        5                                                                      */
/*    c        4       0         0        1        0                                                                      */
/*    d        5       0         0        1        0                                                                      */
/*    e        5       0         0        0        0                                                                      */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                     _
|___ \   _ __   ___  __ _| |
  __) | | `__| / __|/ _` | |
 / __/  | |    \__ \ (_| | |
|_____| |_|    |___/\__, |_|
 _                   _ |_|
| |__   __ _ _ __ __| | ___ ___   __| | ___  __| |
| `_ \ / _` | `__/ _` |/ __/ _ \ / _` |/ _ \/ _` |
| | | | (_| | | | (_| | (_| (_) | (_| |  __/ (_| |
|_| |_|\__,_|_|  \__,_|\___\___/ \__,_|\___|\__,_|

*/

* YOU NEED TO RECREATE SD1.HAVE BECAUSE CX1_A HAS BEEN DROPED FROM SD1.HAVE;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input  name1$ name2 id3 cx1_a cx1_b cx2_a cx2_b;
cards4;
a     6   0     0     1     0     4
b     7   0     0     2     0     5
c     4   0     0     0     1     0
d     5   0     0     0     1     0
e     5   0     0     0     0     0
;;;;
run;quit;

%utl_rbeginx;
parmcards4;
library(sqldf)
library(haven)
source("c:/oto/fn_tosas9x.r")
have<-read_sas("d:/sd1/have.sas7bdat")
have
keeps <- sqldf("
 with drops as (
  select
     case
       when sum(cx1_a) = 0 then 'CX1_A'
       else 'x'
     end as cx
     from have
  union
    all
  select
     case
       when sum(cx1_b) = 0 then 'CX1_B'
       else 'x'
     end as cx
     from have )
  select
    group_concat(name, ',') as names
  from
    pragma_table_info('have')
  where
    name not in (
      select * from drops where cx <> 'x')
  ")
 want <- sqldf(paste('select '
          ,keeps$names
          ,' from have'))
 want
 fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rwant;
run;quit;

/*   _                             _
  __| |_   _ _ __   __ _ _ __ ___ (_) ___
 / _` | | | | `_ \ / _` | `_ ` _ \| |/ __|
| (_| | |_| | | | | (_| | | | | | | | (__
 \__,_|\__, |_| |_|\__,_|_| |_| |_|_|\___|
       |___/
*/

* handles many variables

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input  name1$ name2 id3 cx1_a cx1_b cx2_a cx2_b;
cards4;
a     6   0     0     1     0     4
b     7   0     0     2     0     5
c     4   0     0     0     1     0
d     5   0     0     0     1     0
e     5   0     0     0     0     0
;;;;
run;quit;

%array(_vars,values=%utl_varlist(sd1.have,keep=CX1_:));

%put &=_vars1;  /* _VARS1=CX1_A  */
%put &=_vars2;  /* _VARS2=CX1_B  */
%put &=_varsn;  /* _VARSN=2      */

%utl_submit_r64x('
 library(sqldf);
 library(haven);
 source("c:/oto/fn_tosas9x.r");
 have<-read_sas("d:/sd1/have.sas7bdat");
 keeps <- sqldf("with drops as (
   %do_over(_vars,phrase=%str(
      select
          case
            when sum(?)=0 then `?`
            else `x`
          end as cx
      from have),between=union all)
   )
   select
      group_concat(name, `,`) as names
   from
      pragma_table_info(`have`)
   where
      name not in (
          select
            *
          from
            drops
          where
            cx <> `x`)
  ");
 want <- sqldf(paste("select ",keeps$names," from have"));
 want;
 fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rdwant"
     );
',resolve=Y);


proc print data=sd1.rdwant;
run;quit;

/*                                _                   _                    _
  __ _  ___ _ __     ___ ___   __| | ___    ___ _   _| |_  _ __   __ _ ___| |_ ___
 / _` |/ _ \ `_ \   / __/ _ \ / _` |/ _ \  / __| | | | __|| `_ \ / _` / __| __/ _ \
| (_| |  __/ | | | | (_| (_) | (_| |  __/ | (__| |_| | |_ | |_) | (_| \__ \ ||  __/
 \__, |\___|_| |_|  \___\___/ \__,_|\___|  \___|\__,_|\__|| .__/ \__,_|___/\__\___|
 |___/                                                    |_|

*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input  name1$ name2 id3 cx1_a cx1_b cx2_a cx2_b;
cards4;
a     6   0     0     1     0     4
b     7   0     0     2     0     5
c     4   0     0     0     1     0
d     5   0     0     0     1     0
e     5   0     0     0     0     0
;;;;
run;quit;

* This does require a little cut and paste from the sas log;
* First we generate the code to place in the R script;
* This will work for many variables, not just two as in this example;
* Remove the last 'union all';

%array(_vars,values=%utl_varlist(sd1.have,keep=CX1_:));

%put &=_vars1;  /* _VARS1=CX1_A  */
%put &=_vars2;  /* _VARS2=CX1_B  */
%put &=_varsn;  /* _VARSN=2      */

data _null_;
 %do_over(_vars,phrase=
  %str(put "select case when sum(?)=0 then '?' else 'x' end as cx from have union all";)
 );
run;quit;

%utl_rbeginx;
parmcards4;
library(sqldf)
library(haven)
source("c:/oto/fn_tosas9x.r")
have<-read_sas("d:/sd1/have.sas7bdat")
keeps <- sqldf("
  with drops as (
   select case when sum(CX1_A)=0 then 'CX1_A' else 'x' end as cx from have union all
   select case when sum(CX1_B)=0 then 'CX1_B' else 'x' end as cx from have
  )
  select
    group_concat(name, ',') as names
  from
    pragma_table_info('have')
  where
    name not in (
      select * from drops where cx <> 'x')
  ")
 want <- sqldf(paste('select ',keeps$names,' from have'))
 want
 fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rrwant"
     )
;;;;
%utl_rendx;

proc print data=sd1.rrwant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* R                                         SAS                                                                          */
/*                                                                                                                        */
/*  > want                                                                                                                */
/*                                                                                                    */                  */
/*    NAME1 NAME2 ID3 CX1_B CX2_A CX2_B     ROWNAMES    NAME1    NAME2    ID3    CX1_B    CX2_A    CX2_B                  */
/*                                                                                                                        */
/*  1     a     6   0     1     0     4         1         a        6       0       1        0        4                    */
/*  2     b     7   0     2     0     5         2         b        7       0       2        0        5                    */
/*  3     c     4   0     0     1     0         3         c        4       0       0        1        0                    */
/*  4     d     5   0     0     1     0         4         d        5       0       0        1        0                    */
/*  5     e     5   0     0     0     0         5         e        5       0       0        0        0                    */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____          _   _     _                                _
|___ /   _ __  | |_(_) __| |_   ___   _____ _ __ ___  ___ | | __ _ _ __   __ _ _   _  __ _  __ _  ___
  |_ \  | `__| | __| |/ _` | | | \ \ / / _ \ `__/ __|/ _ \| |/ _` | `_ \ / _` | | | |/ _` |/ _` |/ _ \
 ___) | | |    | |_| | (_| | |_| |\ V /  __/ |  \__ \  __/| | (_| | | | | (_| | |_| | (_| | (_| |  __/
|____/  |_|     \__|_|\__,_|\__, | \_/ \___|_|  |___/\___||_|\__,_|_| |_|\__, |\__,_|\__,_|\__, |\___|
                            |___/                                        |___/             |___/
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input  name1$ name2 id3 cx1_a cx1_b cx2_a cx2_b;
cards4;
a     6   0     0     1     0     4
b     7   0     0     2     0     5
c     4   0     0     0     1     0
d     5   0     0     0     1     0
e     5   0     0     0     0     0
;;;;
run;quit;

%utl_rbeginx;
parmcards4;
library(tidyverse)
library(haven)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
want<-have %>%
  select(
    .,
    - any_of(
      select(., matches('^CX[12]'))
      %>% keep(~ sum(.x) == 0) %>% names()
    )
  )
 want
 fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="twant"
     )
;;;;
%utl_rendx;

proc print data=sd1.twant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* R                                         SAS                                                                          */
/*                                                                                                                        */
/*  > want                                                                                                                */
/*                                                                                                    */                  */
/*    NAME1 NAME2 ID3 CX1_B CX2_A CX2_B     ROWNAMES    NAME1    NAME2    ID3    CX1_B    CX2_A    CX2_B                  */
/*                                                                                                                        */
/*  1     a     6   0     1     0     4         1         a        6       0       1        0        4                    */
/*  2     b     7   0     2     0     5         2         b        7       0       2        0        5                    */
/*  3     c     4   0     0     1     0         3         c        4       0       0        1        0                    */
/*  4     d     5   0     0     1     0         4         d        5       0       0        1        0                    */
/*  5     e     5   0     0     0     0         5         e        5       0       0        0        0                    */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*  _                 _   _                             _
| || |    _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
| || |_  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
|__   _| | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
   |_|   | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
         |_|    |___/                                |_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input  name1$ name2 id3 cx1_a cx1_b cx2_a cx2_b;
cards4;
a     6   0     0     1     0     4
b     7   0     0     2     0     5
c     4   0     0     0     1     0
d     5   0     0     0     1     0
e     5   0     0     0     0     0
;;;;
run;quit;

%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read());
import sqlite3
have,meta = ps.read_sas7bdat('d:/sd1/have.sas7bdat');
drops=pdsql('''
   select * from
     (select case when sum(CX1_A)=0 then 'CX1_A' else 'x' end as cx from have union all
      select case when sum(CX1_B)=0 then 'CX1_B' else 'x' end as cx from have)
   where
      cx <> "x"
   ''');
print(drops)
conn = sqlite3.connect(':memory:')
have.to_sql('my_table',conn,index=False)
keeps=pdsql('''
  select
    group_concat(name, ",") as names
  from
    pragma_table_info("have")
  where
    name not in (
      select * from drops)
  ''')
print(keeps)
query = "SELECT " + keeps.iloc[0,0] + " FROM my_table"
want  = pd.read_sql_query(query, conn)
print(want)
conn.close()
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3);
;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

;;;;
%utl_pyendx;

proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*   PYTHON                                          SAS                                                                  */
/*                                                                                                                        */
/*     NAME1  NAME2  ID3  CX1_B  CX2_A  CX2_B        NAME1    NAME2    ID3    CX1_B    CX2_A    CX2_B                     */
/*                                                                                                                        */
/*   0     a    6.0  0.0    1.0    0.0    4.0          a        6       0       1        0        4                       */
/*   1     b    7.0  0.0    2.0    0.0    5.0          b        7       0       2        0        5                       */
/*   2     c    4.0  0.0    0.0    1.0    0.0          c        4       0       0        1        0                       */
/*   3     d    5.0  0.0    0.0    1.0    0.0          d        5       0       0        1        0                       */
/*   4     e    5.0  0.0    0.0    0.0    0.0          e        5       0       0        0        0                       */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
