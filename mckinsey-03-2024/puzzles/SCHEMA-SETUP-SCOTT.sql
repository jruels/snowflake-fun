USE DATABASE DEMO_DB;
CREATE SCHEMA SCOTT;


CREATE TABLE SCOTT.DEPT
(DEPTNO     NUMBER(2) CONSTRAINT PK_DEPT PRIMARY KEY,
 DNAME      VARCHAR(14),
 LOC        VARCHAR(13));


CREATE TABLE SCOTT.EMP
(EMPNO      NUMBER(4) CONSTRAINT PK_EMP PRIMARY KEY,
 ENAME      VARCHAR(10),
 JOB        VARCHAR(9),
 MGR        NUMBER(4),
 HIREDATE   DATE,
 SAL        NUMBER(7,2),
 COMM       NUMBER(7,2),
 DEPTNO     NUMBER(2) CONSTRAINT FK_DEPTNO REFERENCES DEPT);


INSERT INTO SCOTT.DEPT VALUES
(10,'ACCOUNTING' ,'NEW YORK'),
(20,'RESEARCH'   ,'DALLAS'  ),
(30,'SALES'      ,'CHICAGO' ),
(40,'OPERATIONS' ,'BOSTON'  );


INSERT INTO SCOTT.EMP VALUES
(7369,'SMITH' ,'CLERK'    ,7902,to_date('17-12-1980','dd-mm-yyyy') ,800  ,NULL ,20),
(7499,'ALLEN' ,'SALESMAN' ,7698,to_date('20-02-1981','dd-mm-yyyy') ,1600 ,300  ,30),
(7521,'WARD'  ,'SALESMAN' ,7698,to_date('22-02-1981','dd-mm-yyyy') ,1250 ,500  ,30),
(7566,'JONES' ,'MANAGER'  ,7839,to_date('02-04-1981','dd-mm-yyyy') ,2975 ,NULL ,20),
(7654,'MARTIN','SALESMAN' ,7698,to_date('28-09-1981','dd-mm-yyyy') ,1250 ,1400 ,30),
(7698,'BLAKE' ,'MANAGER'  ,7839,to_date('01-05-1981','dd-mm-yyyy') ,2850 ,NULL ,30),
(7782,'CLARK' ,'MANAGER'  ,7839,to_date('09-06-1981','dd-mm-yyyy') ,2450 ,NULL ,10),
(7788,'SCOTT' ,'ANALYST'  ,7566,to_date('19-04-1987','dd-mm-yyyy') ,3000 ,NULL ,20),
(7839,'KING'  ,'PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy') ,5000 ,NULL ,10),
(7844,'TURNER','SALESMAN' ,7698,to_date('08-09-1981','dd-mm-yyyy') ,1500 ,0    ,30),
(7876,'ADAMS' ,'CLERK'    ,7788,to_date('23-05-1987','dd-mm-yyyy') ,1100 ,NULL ,20),
(7900,'JAMES' ,'CLERK'    ,7698,to_date('03-12-1981','dd-mm-yyyy') ,950  ,NULL ,30),
(7902,'FORD'  ,'ANALYST'  ,7566,to_date('03-12-1981','dd-mm-yyyy') ,3000 ,NULL ,20),
(7934,'MILLER','CLERK'    ,7782,to_date('23-01-1982','dd-mm-yyyy') ,1300 ,NULL ,10);