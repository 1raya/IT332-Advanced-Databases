
/*Type Table*/

CREATE TABLE TYP (
M_TYPE       VARCHAR(15)       NOT NULL,
PRIMARY KEY (M_TYPE)) TABLESPACE IT;


/* Member Table */
CREATE TABLE MEMBER_(
PIN          INT          NOT NULL,
M_BDATE      DATE         NOT NULL,
JOINED_DATE  DATE         NOT NULL,
PRIMARY KEY (PIN))TABLESPACE IT;  

/* View will calculate the expired date from joined date */
CREATE VIEW MEMBER_VV AS
SELECT  PIN,M_BDATE,JOINED_DATE,
JOINED_DATE+120 AS EXPIRED_DATE
FROM MEMBER_;

/* view will calculate the member age and member status */
CREATE VIEW MEMBER_V AS
SELECT PIN,
JOINED_DATE,
EXPIRED_DATE,
M_BDATE,
ROUND(MONTHS_BETWEEN(SYSDATE, M_BDATE)/12,0) AS AGE,
CASE
WHEN SYSDATE > EXPIRED_DATE THEN 'IS EXPIRED' ELSE 'ACTIVE' 
END M_STATUS
FROM MEMBER_VV;

/* NF of member table */
CREATE TABLE M_NAME (
PIN         INT          NOT NULL,
F_NAME      VARCHAR(15)  NOT NULL,
L_NAME      VARCHAR(15)  NOT NULL,
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN)ON DELETE CASCADE)TABLESPACE IT;

/* NF of member table */
CREATE TABLE M_ADRESS(
PIN         INT         NOT NULL,
M_CITY      VARCHAR (20),
ZIPCODE     INT,
BULDINGNO   INT,
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN))TABLESPACE IT;

/* NF of member table */
CREATE TABLE MEMBER_T(
PIN        INT           NOT NULL,
M_TYPE     VARCHAR(15)   NOT NULL,
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN),
FOREIGN KEY (M_TYPE)REFERENCES TYP(M_TYPE))TABLESPACE IT;

/* NF of member table */
CREATE TABLE M_CONTACT(
PIN         INT         NOT NULL,
CONTACT     VARCHAR(30) NOT NULL,
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN),
UNIQUE(CONTACT))TABLESPACE IT;

/* Privilege table */
CREATE TABLE PRIVLIGE (
P_NUM          INT           NOT NULL,
P_NAME         VARCHAR(20)   NOT NULL,
PRIMARY KEY (P_NUM))TABLESPACE IT;

/* this view will specify Maximum number of item that member can borrow it as well as Maximum number of renewal */
CREATE VIEW PRIVLIGE_V AS
SELECT P_NUM,
P_NAME,
CASE 
WHEN P_NAME = 'STUDENT' THEN 5 
WHEN P_NAME ='GRADUATE'THEN 2
WHEN P_NAME ='STAFF'   THEN 10
WHEN P_NAME ='COMMUNITY PATRON' THEN 10
ELSE 0
END  MAX_ITEM,
CASE 
WHEN P_NAME = 'STUDENT' THEN 2 
WHEN P_NAME ='GRADUATE'THEN 1
WHEN P_NAME ='STAFF'   THEN 3
WHEN P_NAME ='COMMUNITY PATRON' THEN 3
ELSE 0
END  MAX_RENEWAL,
CASE 
WHEN P_NAME = 'STUDENT' THEN '3 MONTHS' 
WHEN P_NAME ='GRADUATE'THEN '3 MONTHS'
WHEN P_NAME ='STAFF'   THEN '3 MONTHS'
WHEN P_NAME ='COMMUNITY PATRON' THEN '3 MONTHS'
ELSE 'DEFOALT'
END  LOAN_PERIOD
FROM PRIVLIGE;

/* NF of Privilege table */
CREATE TABLE MEMBER_P(
PIN         INT        NOT NULL,
P_NUM       INT        NOT NULL,
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN),
FOREIGN KEY (P_NUM)REFERENCES  PRIVLIGE(P_NUM))TABLESPACE IT;

/* Fine table */
CREATE TABLE FINE_ (
F_ID         INT            NOT NULL,
F_STATUS     VARCHAR(15)    DEFAULT  'NOT PAID',
F_DESC       VARCHAR(40)   NOT NULL,
PRIMARY KEY (F_ID))TABLESPACE IT;


/* this view will specify the amount of fine */
CREATE VIEW FINE_V AS
SELECT F_ID,
F_DESC,
F_STATUS,
CASE 
WHEN F_DESC = 'LOST' THEN 50.00
WHEN F_DESC ='DAMAGE'THEN 50.00
WHEN F_DESC ='LATE RETURN' THEN 20.00
WHEN F_DESC ='OVER RESRVAION TIME' THEN  10.00
ELSE 00.00
END F_AMOUNT
FROM FINE_;

/* NF of fine table */
CREATE TABLE FINE_F (
F_ID         INT            NOT NULL,
PIN          INT            NOT NULL,
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN),
FOREIGN KEY (F_ID)REFERENCES  FINE_(F_ID))TABLESPACE IT;

/* short loan table*/
CREATE TABLE SHORT_LOAN(
SH_ID           INT        NOT NULL,
SH_DETAILS      VARCHAR(30)NOT NULL,
RESERVE_ST      DATE       NOT NULL,
PRIMARY KEY (SH_ID),
UNIQUE(SH_DETAILS))TABLESPACE IT;

/*specify the reserved end*/
CREATE VIEW SH_V AS
SELECT  SH_ID,SH_DETAILS,RESERVE_ST,
RESERVE_ST+7 AS RESERVE_END
FROM SHORT_LOAN;

/* short loan status */
CREATE VIEW SH_VV AS
SELECT  SH_ID,SH_DETAILS,RESERVE_ST,RESERVE_END,
CASE
WHEN SYSDATE > RESERVE_END THEN 'IS EXPIRED' ELSE 'ACTIVE' 
END SH_STATUS
FROM SH_V;

/* short loan table */
CREATE TABLE SH_LOAN(
SH_ID       INT         NOT NULL,
PIN         INT         NOT NULL,
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN),
FOREIGN KEY (SH_ID)REFERENCES  SHORT_LOAN(SH_ID))TABLESPACE IT;

/* circulation services table */
CREATE TABLE CIRCULATION_SERVICE(
ORDER_NO         INT          NOT NULL,
ORDER_DETILS     VARCHAR(50)  NOT NULL,
PIN              INT          NOT NULL,
PRIMARY KEY (ORDER_NO),
FOREIGN KEY (PIN)REFERENCES MEMBER_(PIN))TABLESPACE IT;

/* room table*/
CREATE TABLE ROOM(
R_NUM             INT                 NOT NULL,
R_TYPE            VARCHAR(30)         NOT NULL,
R_STATUS          VARCHAR(30)         NOT NULL,
R_LOCATION        VARCHAR(30),
R_DURATION        DATE                NOT NULL,
PRIMARY KEY (R_NUM))TABLESPACE IT;

/* NF of room table*/
CREATE TABLE ROOM_ORDER(
R_NUM             INT                 NOT NULL,
ORDER_NUM         INT                 NOT NULL,
FOREIGN KEY (ORDER_NUM) REFERENCES CIRCULATION_SERVICE (ORDER_NO),
FOREIGN KEY (R_NUM)REFERENCES ROOM(R_NUM))TABLESPACE IT;

/* Loan services table */
CREATE TABLE LOAN(
L_RECORD        INT          NOT NULL,
LOAN_ST         DATE         NOT NULL,
LOAN_PERIOD     INT          DEFAULT 90,
L_DESC          VARCHAR(20)  NOT NULL,
PRIMARY KEY (L_RECORD) )TABLESPACE IT ;

 /* this view  calculate the loan end*/
CREATE VIEW LOAN_V AS
SELECT  L_RECORD ,LOAN_ST,LOAN_PERIOD,L_DESC,
LOAN_ST+LOAN_PERIOD AS LOAN_END
FROM LOAN;

/* loan status */
CREATE VIEW LOAN_VV AS
SELECT  L_RECORD ,LOAN_ST,LOAN_PERIOD,LOAN_END,L_DESC,
CASE
WHEN SYSDATE > LOAN_END THEN 'IS EXPIRED' ELSE 'ACTIVE' 
END L_STATUS
FROM LOAN_V;

/* NF of Loan table */
CREATE TABLE L_ORDER(
L_RECORD        INT          NOT NULL,
ORDER_NO        INT          NOT NULL,
FOREIGN KEY (L_RECORD) REFERENCES LOAN (L_RECORD), 
FOREIGN KEY (ORDER_NO) REFERENCES CIRCULATION_SERVICE (ORDER_NO))TABLESPACE IT;

/* collection table */
CREATE TABLE COLLECTION(
C_NAME       VARCHAR(30)   NOT NULL,
C_TYPE       VARCHAR(30)   NOT NULL,
SERIAL_NO    INT           NOT NULL,
L_RECORD      INT          NOT NULL,
FOREIGN KEY (L_RECORD) REFERENCES LOAN(L_RECORD),
PRIMARY KEY (C_NAME))TABLESPACE IT;

/* Journals table */
CREATE TABLE JURNAL(
J_ID          INT           NOT NULL,
J_TITLE       VARCHAR(50)   NOT NULL,
J_DESC        VARCHAR(500)  NOT NULL,
J_COPIES      INT           NOT NULL,
PRIMARY KEY (J_ID))TABLESPACE IT;

  /* this view will show the availability */
 CREATE VIEW J_V AS
 SELECT J_ID,J_TITLE,J_DESC,J_COPIES,
 CASE WHEN J_COPIES>0 THEN 'AVILABLE' ELSE 'NOT AVILABLE' 
 END J_STATUS
 FROM JURNAL;

 /* will show available journal */
 CREATE VIEW vJURNALSTATUS AS
 SELECT J_TITLE, J_STATUS
 FROM J_V
 WHERE J_STATUS ='AVILABLE';
 
 /* NF of journal table */
CREATE TABLE JURNAL_C(
J_ID        INT           NOT NULL,
C_NAME      VARCHAR(30)   NOT NULL,
FOREIGN KEY (J_ID) REFERENCES JURNAL (J_ID),
FOREIGN KEY  (C_NAME) REFERENCES COLLECTION (C_NAME))TABLESPACE IT;


/* Books table */
CREATE TABLE BOOK(
ISBN            VARCHAR(30)    NOT NULL,
B_AUTHER        VARCHAR(30)    NOT NULL,
B_TITLE         VARCHAR(70)    NOT NULL,
B_PUBLISHER     VARCHAR(30)    NOT NULL,
B_COPIES        INT            NOT NULL,
PRIMARY KEY (ISBN))TABLESPACE IT;

 /* NF of book table */
CREATE TABLE BOOK_NOTE(
ISBN           VARCHAR(30)    NOT NULL,
NO_OF_PAGES    INT,
ADDITION       INT,
LANGAGE        VARCHAR(30)    NOT NULL,
FOREIGN KEY (ISBN) REFERENCES BOOK (ISBN))TABLESPACE IT;

 /* NF of book table */
CREATE TABLE BOOK_C(
ISBN       VARCHAR(30)    NOT NULL,
C_NAME     VARCHAR(30)    NOT NULL,
FOREIGN KEY (ISBN) REFERENCES BOOK (ISBN),
FOREIGN KEY (C_NAME) REFERENCES COLLECTION (C_NAME))TABLESPACE IT;

 /* videoRecording and soundRecording table */
CREATE TABLE RECORD_(
R_ID           INT            NOT NULL,
R_DESC         VARCHAR(400),
R_PUBLISHER    VARCHAR(30)    NOT NULL,
PRIMARY KEY (R_ID))TABLESPACE IT;

 /* NF of recording table */
CREATE TABLE RECORD_LOC(
R_ID           INT           NOT NULL,
R_LOCATION     VARCHAR(500)  NOT NULL,
FOREIGN KEY (R_ID) REFERENCES RECORD_ (R_ID))TABLESPACE IT ;


 /* NF of recording table */
CREATE TABLE RECORD_C(
R_ID         INT           NOT NULL,
C_NAME       VARCHAR(30)   NOT NULL,
FOREIGN KEY (R_ID) REFERENCES RECORD_ (R_ID),
FOREIGN KEY (C_NAME) REFERENCES COLLECTION (C_NAME))TABLESPACE IT;


 /* thesis table */
CREATE TABLE THESIS (
TH_ID            INT           NOT NULL,
TH_AUTHER        VARCHAR(30)   NOT NULL,
TH_LOCATION      VARCHAR(500)  NOT NULL,
TH_DESC          VARCHAR(400)  NOT NULL,
PRIMARY KEY (TH_ID))TABLESPACE IT;

 /* NF of thesis table */
CREATE TABLE THESIS_C(
TH_ID            INT           NOT NULL,
C_NAME           VARCHAR(30)   NOT NULL,
FOREIGN KEY (TH_ID) REFERENCES THESIS (TH_ID),
FOREIGN KEY (C_NAME) REFERENCES COLLECTION (C_NAME))TABLESPACE IT;