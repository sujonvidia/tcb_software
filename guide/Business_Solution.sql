Spool D:\Buisness_Solution\guide\output.txt
/
--------connecting sys-------------
conn sys/psl@dbpsl as sysdba
/
--------create tablespace-----------
create tablespace psl_ts
datafile 'D:\oracle\psl_datafile\psl_data.dbf'
size 20M autoextend on
/
-------creating user----------------
create user psl identified by psl
default tablespace psl_ts
quota unlimited on psl_ts
/
--------grant user------------------
grant DBA to psl
/
--------conecting psl user------------
conn psl/psl@dbpsl
/
--------creating table---------------------
-----------------NEW-----------------
--No.1
create table log_book (
       row_no         number(12),
       username       varchar2(20)    not null,  
       usr_id         number(4)       not null,
       log_in         varchar2(50),
       log_out        varchar2(50),
       ---------
       constraint     logbook_rowno_pk primary key(row_no))
/
--no.2
create table company (  
       comp_code        varchar2(3),     
       comp_name        varchar2(50)    not null,
       org_type         varchar2(40),
       address1         varchar2(100),
       address2         varchar2(100),
       phone            varchar2(25),       
       email            varchar2(25),       
       yr_st_dt         Date            not null,
       yr_en_dt         Date,
       acc_opening      Char(1),
       closed           Char(1),
       cl_fis_yr        varchar2(10),     
       invt_opening     char(1),
      -----------------
       SYSDT            DATE              DEFAULT SYSDATE CONSTRAINT NN_company_SYSDT NOT NULL,
       constraint       comppany_code_pk  primary key(comp_code))
      
/
--No.3
create table level_inf(
       userlevel          number(2)    not null,
       level_desc         varchar2(30) not null,
       ---------
       SYSDT            DATE              DEFAULT SYSDATE CONSTRAINT NN_users_SYSDT NOT NULL)
/
---------------------- Trigger for Level_inf-----------------------------
--=======================================================================
CREATE OR REPLACE TRIGGER level_inf_add_upd_del
          before insert on level_inf
          for each row
 begin        
 select  nvl(max(userlevel),-1)+1
     into    :new.userlevel
     from    level_inf;
  end;
--=========================End Trigger====================================
/
--No.4
create table users(
       username           varchar2(20)     not null,
       userpass           varchar2(10)     not null, 
       userlevel          number(2)        not null,
       user_id            number(4)        not null,
       ---------
       SYSDT            DATE              DEFAULT SYSDATE CONSTRAINT NN_levelinf_SYSDT NOT NULL)
/
--no.5
create table fiscal (
         f_year            varchar2(9)     not null,  
         fp_no             number(2,0)     not null,          
         mnth_name         varchar2(9)     not null,
         st_date           date            not null,
         en_date           date            not null
)
/
--no.16
create table Ttitle(
       row_no       number(12)             not null,
       tf_code      varchar2(20)           not null,
       tt_code      varchar2(20)           not null,
       t_name       varchar2(50)           not null,
      ---------
       SYSDT        DATE   DEFAULT SYSDATE CONSTRAINT NN_title_SYSDT NOT NULL)
/
--no.5   
create table sub_ldgr (
       ROW_NO     NUMBER(8)                          NOT NULL,
       LDGR_CODE  NUMBER(6),
       AC_NO_S    VARCHAR2(9 BYTE),
       AC_NAME    VARCHAR2(60 BYTE)                  NOT NULL,
       AC_NO_E    VARCHAR2(9 BYTE),
       USER_ID    NUMBER(4),
     ------------
       SYSDT        DATE   DEFAULT SYSDATE CONSTRAINT NN_subldger_SYSDT NOT NULL,
       constraint   subledger_ldgrcode_pk  primary key(ldgr_code))
/
--no.14
CREATE TABLE TDISTRICT
(  
  ROW_NO     NUMBER(12)         not null,
  DIST_CODE  NUMBER(3)          not null,
  DIST_NAME  VARCHAR2(50)       not null,
  SYSDT      DATE                               DEFAULT SYSDATE CONSTRAINT NN_TDIST_SYSDT NOT NULL,
  CONSTRAINT TDISTRICT_PK                       PRIMARY KEY (DIST_CODE))
/
-------------------------------------------------------------------
--------------------------------------------------------------------
CREATE OR REPLACE TRIGGER tdistrict_add_upd_del
          before insert or update on tdistrict
          for each row
begin
  if inserting then                                                  ---when value inserting
  --------------------------------------------
      --for leger code of Tdistrict
       select nvl(max(row_no),0)+1 into :new.row_no from tdistrict;

        
   --------------------endig insertion---------
 
   elsif updating  then                                      ----when value updating
   ------------------------------------------
      null;
   ---------------ending updating--------------
  end if;

end;
/
---------------------------------------------------------------------
--no.16
create table party_list(
       ROW_NO     NUMBER(12),
       LOC_CODE   VARCHAR2(3 BYTE),
       PRTY_CODE  VARCHAR2(8 BYTE),
       PRTY_NAME  VARCHAR2(60 BYTE),
       PRTY_TYPE  VARCHAR2(12 BYTE),
       ADDRESS1   VARCHAR2(100 BYTE),
       ADDRESS2   VARCHAR2(80 BYTE),
       CONT_PERS  VARCHAR2(50 BYTE),
       PHONE      VARCHAR2(25 BYTE),
       EMAIL      VARCHAR2(40 BYTE),
       WEB        VARCHAR2(40 BYTE),
       DIST_NM    VARCHAR2(50 BYTE),
       CR_LIMT    NUMBER(12,2),
       SM_CODE    VARCHAR2(6 BYTE),
       USER_ID    NUMBER(4),
      ---------
       SYSDT        DATE           DEFAULT      SYSDATE CONSTRAINT NN_partylist_SYSDT NOT NULL,
       constraint   partycode_unk  unique(prty_code)
)
/
CREATE OR REPLACE TRIGGER "PSL".partylist_add_upd_del
          before insert or update on party_list
          for each row
begin
 if inserting then   ---when value inserting
  --------------------------------------------
  
   --row number generating
   select  nvl(max(row_no),0)+1
   into    :new.row_no
   from    party_list;     
   
       if :new.prty_type='Dealer' then
    select nvl(max(prty_code),20000)+1
    into :new.prty_code
    from party_list WHERE prty_type='Dealer';
       
   elsif
    :new.prty_type='Supplier' then
    select nvl(max(prty_code),30000)+1
    into :new.prty_code
    from party_list WHERE prty_type='Supplier';
   
   elsif
    :new.prty_type='Stuff' then
    select nvl(max(prty_code),15000)+1
    into :new.prty_code
    from party_list WHERE prty_type='Stuff';
    
   elsif
   :new.prty_type='Other' then
    select nvl(max(prty_code),40000)+1
    into :new.prty_code
    from party_list WHERE prty_type='Other';
   end if;
   end if;
   end;
/
/
--no.6
create table Acc (
       row_no                number(8)       not null,
       ldgr_code             number(6),
       ac_no                 varchar2(9)     not null,       
       ac_name               varchar2(100)    not null,    
       init_dr               number(15,2)    DEFAULT 0,
       init_cr               number(15,2)    DEFAULT 0,
       start_dr              number(15,2)    DEFAULT 0,
       start_cr              number(15,2)    DEFAULT 0,         
       estm_bgdt             number(15,2)    DEFAULT 0,
       revis_bgdt            number(15,2)    DEFAULT 0,
       aprov_bgdt            number(15,2)    DEFAULT 0,
       actual_bdgt           number(15,2)    DEFAULT 0,
       f6mnt_bdgt            number(15,2)    DEFAULT 0,
       ac_status             varchar2(10)    DEFAULT 'Active',
       user_id               number(4),
     ------------------
       constraint           chk_acSTATUS               CHECK (AC_sTATUS in('Active','Close')),
       SYSDT                DATE                       DEFAULT SYSDATE CONSTRAINT NN_acc_SYSDT NOT NULL,
       constraint           acc_acno_unk               UNIQUE(ac_no),
       constraint           acc_ldgrcode_fk            foreign key(ldgr_code) references sub_ldgr(ldgr_code))
/
create index acc_ndx
on acc(ldgr_code,ac_no)
/
---------------trigger for ACC------------------------
create or replace trigger acc_add_upd_del
          before insert or update on ACC
          for each row
declare
  prty_chk    number(10);
begin
  if inserting then   ---when value inserting
  --------------------------------------------
     
     --for row no of Acc      
      select nvl(max(row_no),0)+1 into  :new.row_no
      from   acc ;
             
    --------------------endig insertion---------
 
   elsif updating  then  ----when value updating
   
         select count(prty_code) 
         into   prty_chk
         from   party_list
         where  prty_code=:old.ac_no;
         
         --------
         if prty_chk>0 then
            update party_list
            set    prty_name=:new.ac_name
            where  prty_code=:old.ac_no;
         end if;
      
 ---------------ending updating--------------
  end if;

end;
----------------------------------------------------
/
CREATE OR REPLACE VIEW BUDGET_VU
(AC_NAME,AC_NO,ESTM_BGDT, REVIS_BGDT,APROV_BGDT, ACTUAL_BDGT,F6MNT_BDGT)
AS 
select AC_NAME,
       AC_NO,        
       ESTM_BGDT, 
       REVIS_BGDT, 
       APROV_BGDT, 
       ACTUAL_BDGT, 
       F6MNT_BDGT 
FROM ACC
/
--no.3
create table project(
             row_no            number(8),
	     project_code      varchar2(8),
             project_name      varchar2(50)      not null,
             location1         varchar2(100),
             location2         varchar2(50),
            ------------------------------------------
SYSDT          DATE             DEFAULT SYSDATE CONSTRAINT NN_project_SYSDT NOT NULL,
constraint     project_code_pk  primary key(project_code))
/
create or replace view open_vu
          as select ac_name,ac_no,init_dr,init_cr from acc
/
/* Formatted on 2011/07/14 17:33 (Formatter Plus v4.8.8) */
CREATE TABLE budget(
       row_no                 NUMBER(8),
       ac_no                  VARCHAR2(9),
       ac_name                VARCHAR2(100)     NOT NULL,
       estm_bgdt              NUMBER(15,2)     DEFAULT 0,
       revis_bgdt             NUMBER(15,2)     DEFAULT 0,
       aprov_bgdt             NUMBER(15,2)     DEFAULT 0,
       actual_bdgt            NUMBER(15,2)     DEFAULT 0,
       f6mnt_bdgt             NUMBER(15,2)    DEFAULT 0,
       pestm_bgdt             NUMBER(15,2)    DEFAULT 0,
       previs_bgdt            NUMBER(15,2)    DEFAULT 0,
       paprov_bgdt            NUMBER(15,2)    DEFAULT 0,
       pactual_bdgt           NUMBER(15,2)    DEFAULT 0,
       pf6mnt_bdgt            NUMBER(15,2)    DEFAULT 0,
       f_year                 VARCHAR2(9),
       ac_status              VARCHAR2(10)    DEFAULT 'Active',
       user_id                NUMBER(4),
------------------
CONSTRAINT                  chk_bacstatus               CHECK (ac_status IN('Active','Close')),
       sysdt                DATE                       DEFAULT SYSDATE CONSTRAINT nn_budget_sysdt NOT NULL,
       CONSTRAINT           budget_acno_unk            UNIQUE(ac_no)
      )
/
CREATE INDEX budget_ndx
ON budget(ac_name,ac_no)
/
---------------trigger for ACC------------------------

----------------------------------------------------
CREATE OR REPLACE TRIGGER budget_add_upd_del
   BEFORE INSERT OR UPDATE
   ON budget
   FOR EACH ROW
DECLARE
BEGIN
   IF INSERTING
   THEN                                               ---when value inserting
--------------------------------------------

      --for row no of Acc
      SELECT NVL (MAX (row_no), 0) + 1
        INTO :NEW.row_no
        FROM budget;
   ---------------ending updating--------------
   END IF;
END;
/
--no.8
create table trn_sngl (
  ROW_NO        NUMBER(15)                      NOT NULL,
  FP_NO         NUMBER(2)                       NOT NULL,
  J_CODE        VARCHAR2(3)                NOT NULL,
  VAT_FLAG      CHAR(1),
  VAT           NUMBER(15,2),
  VAT_PERCEN    NUMBER(5,2),
  TAX_FLAG      CHAR(1),
  TAX           NUMBER(15,2),
  TAX_PERCEN    NUMBER(5,2),
  PROJECT_CODE  VARCHAR2(8),
  VOUCH_NO      VARCHAR2(8)                NOT NULL,
  TN_DATE       DATE                            NOT NULL,
  AC_DR         VARCHAR2(9)                NOT NULL,
  AC_CR         VARCHAR2(9)                NOT NULL,
  TN_AMNT       NUMBER(13,2)                    NOT NULL,
  F_YEAR        VARCHAR2(9)                NOT NULL,
  TN_DESCR1     VARCHAR2(500),
  TN_DESCR2     VARCHAR2(250),
  PST_FLAG      CHAR(1)                    DEFAULT 'N',
  CURR_CODE     VARCHAR2(3),
  EXCH_RATE     NUMBER(8,4),
  USER_ID       NUMBER(4),
  LC_NO         VARCHAR2(30),
  REF_ID        VARCHAR2(20),
  VAT_PAID      CHAR(1)                    DEFAULT 'N',
  TAX_PAID      CHAR(1)                    DEFAULT 'N',
  SECU_DEP      NUMBER(15,2),
  SEC_DEP_FLAG  CHAR(1),
  ADV_FLAG      CHAR(1),
  ADV_AGAIN     VARCHAR2(12),
  deb_flag      char(1),
  cre_flag      char(1),
  chq_date      date,
      ----------
       SYSDT            DATE      DEFAULT  SYSDATE CONSTRAINT NN_trnsngl_SYSDT NOT NULL,
       constraint       projectcode_fk            foreign key(project_code) references project(project_code))
/
create index trnsngl_ndx
on trn_sngl(j_code,vouch_no)
/
--============================================================
---------------trigger for trn_sngl------------------------
--=============================================================
create or replace trigger trnsngl_add_upd_del
          before insert on trn_sngl
          for each row
begin
  if inserting then   ---when value inserting
  --------------------------------------------
     
    if :new.ac_dr=:new.ac_cr then       ---debit/credit checking same ac_no
    
       raise_application_error(-20000,'Account type or name can not be emty');
       else

      --for row no of Trn_sngl
      select   nvl(max(row_no),'0')+1
      into     :new.row_no
      from     trn_sngl;

         
    end if;
   --------------------endig insertion---------
 
   elsif updating  then  ----when value updating
   ------------------------------------------
      if :new.ac_dr=:new.ac_cr  then         ---debit/credit checking null value

         raise_application_error(-20000,'Account type or name can not be emty');
      
      end if;
   ---------------ending updating--------------
  end if;

end;
--============================================================================
--=============================================================================
/
--no.9
create table stmt_lst (
       file_no        varchar2(4),  
       file_desc      varchar2(50)      not null,
       user_id        number(4),
     --------------
       SYSDT          DATE   DEFAULT  SYSDATE CONSTRAINT NN_stmtlst_SYSDT NOT NULL,
       constraint     fileno_pk       primary key(file_no))
/
create or replace trigger stmtlst_add_upd_del
          before insert on stmt_lst
          for each row
begin
  if inserting then   ---when value inserting
  --------------------------------------------
     
          --for row no of stmt_lst
      select         nvl(max(file_no),9)+1
      into           :new.file_no
      from           stmt_lst;
 
     
        --------------------endig insertion---------
 
   elsif updating  then  ----when value updating
   ------------------------------------------
   null;
   ---------------ending updating--------------
  end if;

end;
/
--no.10
create table stmt_dta (
       row_no         number(8)          not null,
       file_no        varchar2(4),
       file_desc      varchar2(60), 
       line_no        number(3,0),   
       texts          varchar2(40),
       note           varchar2(2),
       ac11           varchar2(9),
       ac12           varchar2(9),
       figr_posi      number(3,0),
       sub_total      varchar2(1),
       pnt            char(1),
       p_formula      varchar2(51),
       range_val1     number(16,2),
       prnt_val1      number(16,2),
       pcnt           number(6,2),
       user_id        number(4),
      -----------
       SYSDT          DATE        DEFAULT SYSDATE CONSTRAINT NN_stmtdta_SYSDT NOT NULL,
       constraint     fileno_fk                   foreign key(file_no) references stmt_lst(file_no),
       constraint     lineno_unk  Unique(file_no,line_no))
/
--no.11
create or replace view open_vu
          as select ac_name,ac_no,init_dr,init_cr from acc
/
create or replace trigger stmtdta_add_upd_del
          before insert on stmt_dta
          for each row
begin
  if inserting then   ---when value inserting
  --------------------------------------------
        
      select    nvl(max(row_no),0)+1
      into      :new.row_no from stmt_dta;
       
   --------------------endig insertion---------
 
  end if;

end;
-----------------------------------------------------
/
create table deprec(
       row_no                number(8),
       dep_date              date,       
       ldgr_code             number(6),
       ac_no                 varchar2(9)      not null,       
       ac_name               varchar2(100)    not null,    
       acqui_value           number(15,2),
       open_accumul          number(15,2),
       dep_rate              number(15,2),
       curr_yr_dep           number(15,2),
       accumul_dep           number(15,2),
     ------------------
       SYSDT                DATE                       DEFAULT SYSDATE CONSTRAINT NN_deprec_SYSDT NOT NULL)
/

create or replace trigger deprec_add_upd_del
          before insert or update on deprec
          for each row
  
begin
  if inserting then   ---when value inserting
  --------------------------------------------
     
     --for row no of Acc      
      select nvl(max(row_no),0)+1 into  :new.row_no
      from   deprec ;
             
    --------------------endig insertion---------
                
 ---------------ending updating--------------
  end if;

end;
----------------------------------------------------
/
CREATE TABLE ASSETS_INFO
(
  ROW_NO             		NUMBER(5),
  ASST_CODE          		VARCHAR2(12 BYTE),
  AC_NO              		VARCHAR2(12 BYTE),
  ASST_TYPE          		VARCHAR2(30 BYTE),
  ASST_CATAGORY      	VARCHAR2(30 BYTE),
  ASST_DESC          		VARCHAR2(100 BYTE),
  SUPPLIER_INFO      	VARCHAR2(150 BYTE),
  USER_INFO          		VARCHAR2(75 BYTE),
  VOUCHER_NO         	NUMBER(15),
  COST_CENTER        	VARCHAR2(15 BYTE),
  BOOK_VALUE         	NUMBER(10,2),
  RESIDUAL_VALUE     	NUMBER(10,2),
  LIFE_TIME          		NUMBER(5,2),
  RETIRMENT_DATE     	DATE,
  DEPR_RATE          		NUMBER(5,2),
  EFFECTIVE_DATE     	DATE,
  DEPR_AC            		VARCHAR2(12 BYTE),
  PROV_DEPR_AC       	VARCHAR2(12 BYTE),
  USER_ID            		NUMBER(4),
  COMP_CODE          	VARCHAR2(3 BYTE),
  SYDATE             		DATE                           DEFAULT sysdate,
  CONSTRAINT asst_row_no_pk     PRIMARY KEY(row_no),
  CONSTRAINT asst_depac_fk      FOREIGN KEY (DEPR_AC) REFERENCES ACC(ac_no),
  CONSTRAINT asst_provdepac_fk  FOREIGN KEY (PROV_DEPR_AC) REFERENCES ACC(ac_no)
)
/
--------------------- TRIGGER FOR ASSETS INFO----------------------------
CREATE OR REPLACE TRIGGER assets_info_add_upd_del
          before insert on ASSETS_INFO
          for each row
BEGIN
 if inserting then   ---when value inserting
    
   --row number generating
   select  nvl(max(row_no),0)+1
   into    :new.row_no
   from    ASSETS_INFO;     
 end if;
END;
/
--no.13
create table stock_grp(
       row_no        number(3),
       comp_code     varchar2(3),
       grp_code      varchar2(4),
       unit          varchar2(6),
       grp_name      varchar2(25),
       user_id       number(4),
      ------------
       SYSDT            DATE    DEFAULT SYSDATE CONSTRAINT NN_stockgrp_SYSDT NOT NULL,
       constraint       stockgrp_company_fk foreign key(comp_code)  references Company(comp_code))
/
------------------trigger for stock_grp--------
create or replace trigger stockgrp_add_upd_del
          before insert on stock_grp
          for each row
begin
  if inserting then   ---when value inserting
  --------------------------------------------
   if :new.grp_name is null then
      raise_application_error(-20000,'unit or name can not be emty');
   Else     
   --generating Group code
   select    nvl(max(grp_code),99)+1 
   into      :new.grp_code
   from      stock_grp;

   --generating row_no.
   select    nvl(max(row_no),0)+1
   into      :new.row_no
   from      stock_grp;  
   end if;   
 --------------------endig insertion--------- 
  end if;
end;
------------------------------------------------
/
--no12
create table model (
       comp_code      varchar2(3),
       model_no       varchar2(4),  
       model_name     varchar2(40),
       user_id        number(4),
      ------------
       SYSDT          DATE    DEFAULT SYSDATE CONSTRAINT NN_model_SYSDT NOT NULL,
       constraint     model_company_fk  foreign key(comp_code)   references Company(comp_code))
/
----------------------Trigger for model--------------
create or replace trigger model_add_upd_del
          before insert on model
          for each row
begin
  if inserting then   ---when value inserting
  --------------------------------------------
   if :new.model_name is null then
      raise_application_error(-20000,'Model name can not be emty');
   Else     
    select nvl(max(model_no),10)+1
    into   :new.model_no 
    from   model;
   end if;  
 --------------------endig insertion---------
  end if;
end;
------------------------------------------
/
--no.14
create table stocks(
                comp_code        varchar2(3),
                row_no           number(10)       not null,
		item_code        number(12),
		descrp           varchar2(50),
                unit             varchar2(20),
                user_id          number(4),
                model_name       varchar2(30),
                grp_code         varchar2(4),
               -------------
                SYSDT         DATE         DEFAULT SYSDATE CONSTRAINT NN_stock_SYSDT NOT NULL,
                constraint    desc_pk             primary key  (item_code),
                constraint     stocks_company_fk  foreign key(comp_code)  references Company(comp_code))		
/
CREATE OR REPLACE TRIGGER stocks_add_upd_del
          before insert on stocks
          for each row
declare
   counter number(15);
begin

  -----Dublicate item code checking
  select count(item_code)
  into   counter
  from   stocks
  where  item_code=:new.item_code;

  if inserting then   ---when value inserting
  --------------------------------------------
   if :new.descrp is null or counter>0 then
      raise_application_error(-20000,'unit or name can not be emty');
   Else

   -----------------------------------------------------------------------------------
   select  nvl(max(row_no),0)+1
   into    :new.row_no
   from    stocks;

   --item_code genarate
   select  nvl(max(item_code),:new.grp_code||'00000')+1 into :new.item_code from stocks
   where   item_code like :new.grp_code||'%' ;

   end if;
 --------------------endig insertion---------
  end if;
end;
------------------------------------------------------------
--====================================================
/
--no.15
create table godown(
                    comp_code          varchar2(3),
                    godown_code       varchar2(25),
                    godown_name       varchar2(50),
                    location          varchar2(80),
                   ---------------
                    SYSDT         DATE         DEFAULT SYSDATE CONSTRAINT NN_godown_SYSDT NOT NULL,
                    constraint     godown_company_fk  foreign key(comp_code)  references Company(comp_code))
/
create table open_stocks(
        row_no          number(10)       not null,
        godown_code     varchar2(25),
        item_code      number(12),
        item_name     varchar2(50)      not null,
        opn_qnty      number(9),
        opn_prate     number(10,2),
        unit          varchar2(20),
        pst_flg       char(1) DEFAULT 'N',
        model_name    Varchar2(30),
        ref_item      varchar2(25),
        price         number(15,2),
        qnty_ton      number(15,6),
         -------------
        SYSDT         DATE   DEFAULT SYSDATE     CONSTRAINT NN_openstock_SYSDT   NOT NULL, 
        constraint    openstock_itemcode_fk      foreign key(item_code)          references  stocks(item_code))
/
create index openstock_ndx
on open_stocks(item_code)
/
------------------Trigger for Stocks Table-------------------
CREATE OR REPLACE TRIGGER openstocks_add_upd_del
          before insert or update on open_stocks
          for each row
declare
   counter number(10);
   
begin



  if inserting then                                                          ---if value inserting
  --------------------------------------------
           -----------------------------------------------------------------------------------
     --row no generating
     select  nvl(max(row_no),'0')+1
     into    :new.row_no
     from    open_stocks;
     :new.price:=:new.opn_qnty*:new.opn_prate;                --calculating price

      if :new.unit='KG' then
      :new.qnty_ton:=:new.opn_qnty/1000;

       elsif :new.unit='LTR' then
      :new.qnty_ton:=:new.opn_qnty/1086.96;

      elsif :new.unit='MT' then
      :new.qnty_ton:=:new.opn_qnty;

      end if;
                                                                    ---end if Checking

       -------------------endig insertion---------

   ELSIF UPDATING then                                                          ---if value UPDATING
    --------------------------------------------
          -----------------------------------------------------------------------------------
       :new.price:=:new.opn_qnty*:new.opn_prate;              --calculating price

       if :new.unit='KG' then
      :new.qnty_ton:=:new.opn_qnty/1000;

       elsif :new.unit='LTR' then
      :new.qnty_ton:=:new.opn_qnty/1086.96;

      elsif :new.unit='MT' then
      :new.qnty_ton:=:new.opn_qnty;

      end if;

                                                                   ---end if Checking
   --------------------endig updating---------



  end if;

end;
--===========================================================
--============================================================
/

--no.19
create table trans_invt(
       row_no       number(15),
       TRANS_ID     NUMBER(16),
       COMP_CODE    VARCHAR2(3),
       FP_NO        NUMBER(2),
       COST_CNT     VARCHAR2(4),
       VOUCH_NO     VARCHAR2(8),
       V_CODE       VARCHAR2(4),
       TN_DATE      DATE,
       DELV_DATE    DATE,
       ORDER_NO     VARCHAR2(50),
       REF_NO       VARCHAR2(50),
       ALLOT_NO     VARCHAR2(25),
       CONSIG_NO    VARCHAR2(30),
       AC_DR        VARCHAR2(9),
       AC_CR        VARCHAR2(9),
       F_YEAR       VARCHAR2(9),
       TN_DESCR1    VARCHAR2(75),
       TN_DESCR2    VARCHAR2(50),
       PST_FLAG     CHAR(1)                     DEFAULT 'N',
       CURR_CODE    VARCHAR2(3),
       EXCH_RATE    NUMBER(8,4),
       USER_ID      NUMBER(4),
       DEALER_TYPE  VARCHAR2(25),
       PRTY_CODE    VARCHAR2(12),
       LC_NO        VARCHAR2(25),
       CURR_TYPE    VARCHAR2(25),
       PRES_RATE    NUMBER(10,3), 
       LC_AMNT      NUMBER(15,2),
       BANK_NAME    VARCHAR2(50),
       LC_DATE      DATE,
       BANK_NO      VARCHAR2(12), 
      -------------
       SYSDT          DATE    DEFAULT SYSDATE CONSTRAINT NN_trnsinvt_SYSDT NOT NULL,
       constraint     transid_invt_pk primary key(trans_id),
       constraint     trninvt_company_fk  foreign key(comp_code)  references Company(comp_code))
/
create index tinvt_ndx
on trans_invt(v_code,vouch_no)
/
-----------------------trigger for trans_invt table---------------
create or replace trigger transinvt_add_upd_del
          before insert on trans_invt
          for each row
begin
 
  
  if inserting then   ---when value inserting
  --------------------------------------------
   if :new.tn_date is null  then
      raise_application_error(-20000,'date can not be emty');
   Else
  -----------------------------------------------------------------------------------

 --transaction id generating	
   select  nvl(max(trans_id),'0')+1
   into    :new.trans_id
   from    trans_invt;

--generating vouch no
   select  nvl(max(vouch_no),'10000')+1
   into    :new.vouch_no
   from    trans_invt 
   where   v_code=:new.v_code;

   end if;
--------------------endig insertion---------
 
  end if;

end;
------------------------------------------------------------
/
--no.20
create table trans_item(
       ROW_NO       NUMBER(15),
  TRANS_ID     NUMBER(16),
  COMP_CODE    VARCHAR2(3),
  ITEM_CODE    NUMBER(12),
  ITEM_NAME    VARCHAR2(50),
  GODOWN_CODE  VARCHAR2(25),
  UNIT         VARCHAR2(20),
  VOUCH_NO     VARCHAR2(8),
  V_CODE       VARCHAR2(4),
  RATE         NUMBER(10,2),
  PR_RATE      NUMBER(10,2),
  QNTY         NUMBER(10)                       NOT NULL,
  PRICE        NUMBER(12),
  FX_SRATE     NUMBER(12),
  FX_SDCNT     NUMBER(3),
  DISCOUNT     NUMBER(10),
  SRET_VOUCH   VARCHAR2(8),
  PRET_VOUCH   VARCHAR2(8),
  COST_CNT     VARCHAR2(4),
  EXP_DATE     DATE,
  USER_ID      NUMBER(4),
  QNTY_TON     NUMBER(15,6),
  REF_ITEM     VARCHAR2(25),
  CURR_TYPE    VARCHAR2(25),
  PRES_RATE    NUMBER(10,3),
  FAL_RATE     NUMBER(10,2),
    --------------
       SYSDT          DATE   DEFAULT SYSDATE CONSTRAINT NN_transitem_SYSDT NOT NULL,
       constraint     invt_item_fk   foreign key(trans_id)        references trans_invt(trans_id),
       constraint     trnitem_company_fk  foreign key(comp_code)  references  Company(comp_code))
/
create index titem_ndx
on trans_item(godown_code,v_code,vouch_no)
/
--=================================================================================
--TRIGER FOR TRANS_ITEM
--=================================================================================
CREATE OR REPLACE TRIGGER "PSL".transitem_add_upd_del
          before insert OR UPDATE on TRANS_ITEM
          for each row
declare
   counter number(10);
   bal     number(15);
begin



  if inserting then                                                          ---if value inserting
  --------------------------------------------
     if :new.qnty=0 then               ---if for cheking
        raise_application_error(-20000,'unit or name can not be emty');
     Else
      -----------------------------------------------------------------------------------
     --row no generating
     select  nvl(max(row_no),'0')+1
     into    :new.row_no
     from    trans_item;
     :new.price:=:new.qnty*:new.rate-nvl(:new.discount,0);                --calculating price
      
      if :new.unit='KG' then
      :new.qnty_ton:=:new.qnty/1000;
       
       elsif :new.unit='LTR' then
      :new.qnty_ton:=:new.qnty/1086.96;
      
      elsif :new.unit='MT' then
      :new.qnty_ton:=:new.qnty;
       
      end if;
     end if;                                                               ---end if Checking
     
       -------------------endig insertion---------

   ELSIF UPDATING then                                                          ---if value UPDATING
    --------------------------------------------
     if :new.qnty=0 then               ---if for cheking
        raise_application_error(-20000,'unit or name can not be emty');
     Else
     -----------------------------------------------------------------------------------
       :new.price:=:new.qnty*:new.rate-nvl(:new.discount,0);              --calculating price
       
       if :new.unit='KG' then
      :new.qnty_ton:=:new.qnty/1000;
       
       elsif :new.unit='LTR' then
      :new.qnty_ton:=:new.qnty/1086.96;
      
      elsif :new.unit='MT' then
      :new.qnty_ton:=:new.qnty;
       
      end if;

     end if;                                                               ---end if Checking
   --------------------endig updating---------
    
   

  end if;

end;
--===========================================================
--============================================================
/

create table transfer(
       row_no         number(15),
       comp_code      varchar2(3),
       item_code      number(12),
       item_name      varchar2(50),          
       fgcode         varchar2(25),
       tgcode         varchar2(25),
       unit           varchar2(20),
       rate           number(10,2),
       qnty           number(10)       not null,
       price          number(12,0),
       pst_flg       char(1) DEFAULT 'N',
       ref_item      varchar2(25),
       qnty_ton      number(15,6),
       --------------
       SYSDT          DATE   DEFAULT SYSDATE CONSTRAINT NN_transfer_SYSDT NOT NULL,
       constraint     transfer_fk   foreign key(item_code)        references stocks(item_code),
       constraint     transfer_company_fk  foreign key(comp_code)  references  Company(comp_code))
/
create index transfer_ndx
on transfer(item_code,fgcode,tgcode,qnty)
/
--=================================================================================
--TRIGER FOR TRANS_ITEM
--=================================================================================
CREATE OR REPLACE TRIGGER "PSL".transfer_add_upd_del
          before insert or update on transfer
          for each row
declare
   counter number(10);
begin


  if inserting then                                                          ---if value inserting
  --------------------------------------------
     
      -----------------------------------------------------------------------------------
     --row no generating
     select  nvl(max(row_no),0)+1
     into    :new.row_no
     from    transfer;
     
     :new.price:=:new.qnty*:new.rate;                --calculating price

      if :new.unit='KG' then
      :new.qnty_ton:=:new.qnty/1000;

       elsif :new.unit='LTR' then
      :new.qnty_ton:=:new.qnty/1086.96;

      elsif :new.unit='MT' then
      :new.qnty_ton:=:new.qnty;

      end if;
       -------------------endig insertion---------

   ELSIF UPDATING then                                                          ---if value UPDATING
    --------------------------------------------
     
     -----------------------------------------------------------------------------------
       :new.price:=:new.qnty*:new.rate;              --calculating price

       if :new.unit='KG' then
      :new.qnty_ton:=:new.qnty/1000;

       elsif :new.unit='LTR' then
      :new.qnty_ton:=:new.qnty/1086.96;

      elsif :new.unit='MT' then
      :new.qnty_ton:=:new.qnty;

      end if;

   --------------------endig updating---------

  end if;

end;
--===========================================================
--============================================================
/
--no.23
create table q_list(
             trans_id     number(16),
             subject      varchar2(75),
             sub_name     varchar2(75),
             address      varchar2(100),
             user_id      number(4),
           ------------
             SYSDT          DATE   DEFAULT   SYSDATE CONSTRAINT NN_q_list_SYSDT NOT NULL,
             constraint     transid_qlist_pk primary key(trans_id))
/
--no.24
create table qlist_detals(
             trans_id       number(16),
             item_name      varchar2(50),
             descreption    varchar2(250),
             qnty           number(10),
             rate           number(15,2),
             price          number(15,2),
             user_id            number(4),
           -----------
             SYSDT          DATE   DEFAULT  SYSDATE CONSTRAINT NN_qlistdet_SYSDT NOT NULL,
             constraint     detail_qlist_fk     foreign key(trans_id)        references q_list(trans_id))
/
CREATE TABLE CURR_RATE
(
  ROW_NO       NUMBER(8),
  CURR_CODE    NUMBER(8),
  CURR_NAME    VARCHAR2(25 BYTE),
  CURR_COUNTY  VARCHAR2(35 BYTE),
  PREV_RATE    NUMBER(10,3),
  PRES_RATE    NUMBER(10,3),
  SYDATE       DATE                             DEFAULT sysdate               NOT NULL,
  EXC_RATE     NUMBER(10,3)
)
/
----TRIGER FOR CURR_RATE
--=================================================================================
create or replace trigger currrate_add_upd_del
          before insert  on curr_rate
          for each row
begin  
  if inserting then   ---when value inserting
  -----------------------------------------------------------------------------------    
   select  nvl(max(row_no),0)+1
   into    :new.row_no
   from    curr_rate;
   end if;   
 --------------------endig insertion--------- 
end;
------------------------------------------------------------
/
create table chalan(
    row_no          number(8),    
    chln_no         number(8),         ------in chalan from  transection no represent chalan form
    vouch_no        number(8),
    chln_dt         date,
    code_no         varchar2(50),
    bnk_dist        varchar2(50),
    bnk_brnch       varchar2(50),
    chln_type       varchar2(15),
    ref_id          varchar2(10),
    prty_name       varchar2(100),
    chq_no          varchar2(15),
    ac_no           varchar2(9),
    chq_dt          date,
    bank            varchar2(50),
    tamt            number(15,2),
    from_nmadd      varchar2(100),
    purpose         varchar2(100),    
    sysdt           date  default sysdate  constraints    nn_chalan_sysdt  not null    
)
/
------------trigger for chalan----------
create or replace trigger chalan_add_upd_del
          before insert on chalan
          for each row
begin
 
  
  if inserting then   ---when value inserting
  -------------------------------------------- 
 --row number generating    
   select  nvl(max(row_no),'0')+1
   into    :new.row_no
   from    chalan;
   
   select  nvl(max(chln_no),'10000')+1
   into    :new.chln_no
   from    chalan;

--------------------endig insertion--------- 
  end if;
end;
/


-------initial value-------------------
--No.1---------------------------------------------------
--company default setting
insert into company(
             comp_code,
             comp_name,
             yr_st_dt,
             address1
             )
              values(
             '01',
             'TRADING CORPORATION OF BANGLADESH',
             '01-jan-2011',
             'TCB Bhaban, Kawran Bazar,Dhaka-1215'            
             )
/
commit
/
--No.2 user table------------------------------------
insert into level_inf(level_desc)
values('admin')
/
--No.2 user table------------------------------------
insert into users(username,userpass,Userlevel, user_id)
values('user1','user1',0,'1')
/
--No.4--------------------------------------------
--setting fiscal period
declare
--variable declaeration
init_date    date;
yr           varchar2(9);
num1         varchar2(9);
num2         varchar2(9);
s_date       date;
e_date       date;
i            number;
fis_no       number;
c_code       varchar2(3);
		
begin
--at frist all row delete of fiscal
delete from fiscal;
fis_no:=0;

--getting date from commany
select yr_st_dt into init_date from company; 


--fiscal year;
for i in 0..11 loop
  num1:=to_char(init_date,'fmyyyy');
  num2:=concat('-',(num1+1));
  yr:=concat(num1,num2);
	
--starting date 
  s_date:=add_months(init_date,i);
  fis_no:=i+1;

 --inserting value
   insert into fiscal(f_year,fp_no,mnth_name,st_date,en_date)
   values(yr,fis_no,to_char(s_date,'fmMonth'),s_date,last_day(s_date));

end loop;

end;
/
--=============DISTRICT INFORMATION========================
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (1, 'DHAKA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (2, 'GAZIPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (3, 'NARAYANGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (4, 'NARSINGDI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (5, 'MUNSHIGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (6, 'CHITTAGONG');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (7, 'COX''S BAZAR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (8, 'BANDERBAN');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (9, 'RANGAMATI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (10, 'KHAGRACHARI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (11, 'SYLHET');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (12, 'SUNAMGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (13, 'MOULVIBAZAR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (14, 'HABIGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (15, 'COMILLA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (16, 'CHANDPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (17, 'BRAHMANBARIA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (18, 'FENI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (19, 'NOAKHALI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (20, 'LAKSMIPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (21, 'BARISAL');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (22, 'PIROJPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (23, 'JHALUKHATI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (24, 'PATUAKHALI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (25, 'BHOLA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (26, 'BARGUNA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (27, 'FARIDPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (28, 'GOPALGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (29, 'MADARIPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (30, 'SHARIATPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (31, 'RAJBARI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (32, 'KHULNA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (33, 'BAGERHAT');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (34, 'SATKHIRA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (35, 'JESSORE');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (36, 'NARAIL' );
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (37, 'JHENAIDAH');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (38, 'MAGURA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (39, 'KUSHTIA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (40, 'CHUADANGA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (41, 'MEHERPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (42, 'MYMENSHINGH' );
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (43, 'KISHOREGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (44, 'NETROKONA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (45, 'JAMALPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (46, 'SHERPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (47, 'TANGAIL');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (48, 'RAJSHAHI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (49, 'NATORE');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (50, 'NAWABGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (51, 'PABNA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (52, 'SIRAJGONJ');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (53, 'BOGRA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (54, 'JAIPURHAT');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (55, 'NAOGAON');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (56, 'RANGPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (57, 'KURIGURAM');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (58, 'GAIBANDHA');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (59, 'NILPHAMARI');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (60, 'LALMONIRHAT');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (61, 'DINAJPUR');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (62, 'THAKURGAON');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (63, 'PANCHAGARH');
Insert into TDISTRICT
   (DIST_CODE, DIST_NAME)
 Values
   (64, 'MANIKGONJ');
--======================END DISTRICT INFORMATION====================
commit
/
spool off
/                                
exit
/   


