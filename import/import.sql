Spool D:\Buisness_Solution\import\preperation_output.txt
/
--------connecting sys-------------
conn system/psl@dbpsl
/
-------------drop user----------
drop user psl cascade
/
-------creating user----------------
create user psl identified by psl
default tablespace psl_ts
quota unlimited on psl_ts
/
--------grant user------------------
grant DBA to psl
/
spool off
/