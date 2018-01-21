/*==============================================================*/
/* Table: USERS                                                 */
/*==============================================================*/

create table USERS
(
  USER_ID              NUMBER               not null,
  USER_ROLE            VARCHAR2(5)          not null,
  USER_FIRSTNAME       VARCHAR2(25)         not null,
  USER_LASTNAME        VARCHAR2(25)         not null,
  USER_EMAIL           VARCHAR2(40)         not null,
  USER_PASSWORD        VARCHAR2(40)         not null,
  DELETED              NUMBER(1,0)          DEFAULT 0,
  constraint PK_USERS primary key (USER_ID)
);


/*==============================================================*/
/* Table: CALENDAR                                              */
/*==============================================================*/
create table CALENDAR
(
  CALENDAR_ID          NUMBER               not null,
  USER_ID              NUMBER               not null,
  CALENDAR_NAME        VARCHAR2(25)         not null,
  DELETED              NUMBER(1,0)          DEFAULT 0,
  constraint PK_CALENDAR primary key (CALENDAR_ID)
);

/*==============================================================*/
/* Index: USERS_HAS_CALENDAR_FK                                 */
/*==============================================================*/
create index USERS_HAS_CALENDAR_FK on CALENDAR (
  USER_ID ASC
);

alter table CALENDAR
  add constraint FK_USERS_HAS_CALENDAR foreign key (USER_ID)
references USERS (USER_ID);


/*==============================================================*/
/* Table: TASKPACKAGE                                           */
/*==============================================================*/
create table TASKPACKAGE
(
  PACKAGE_ID           NUMBER               not null,
  CALENDAR_ID          NUMBER               not null,
  PACKAGE_NAME         VARCHAR2(25)         not null,
  PACKAGE_DAY          DATE                 not null,
  REMINDER_DATE        DATE                 NOT NULL,
  DELETED              NUMBER(1,0)          DEFAULT 0,
  constraint PK_TASKPACKAGE primary key (PACKAGE_ID)
);

/*==============================================================*/
/* Index: CALENDAR_HAS_TASKPACKAGE_FK                           */
/*==============================================================*/
create index CALENDAR_HAS_TASKPACKAGE_FK on TASKPACKAGE (
  CALENDAR_ID ASC
);

alter table TASKPACKAGE
   add constraint FK_CALENDAR_HAS_TASKPACK foreign key (CALENDAR_ID)
      references CALENDAR (CALENDAR_ID);
	  
/*==============================================================*/
/* Table: TASK                                                  */
/*==============================================================*/
create table TASK
(
  TASK_ID              NUMBER               not null,
  PACKAGE_ID           NUMBER               not null,
  DESCRIPTION          VARCHAR2(100)        not null,
  PLACE                VARCHAR2(25)         not null,
  DELETED              NUMBER(1,0)          DEFAULT 0,
  constraint PK_TASK primary key (TASK_ID)
);

/*==============================================================*/
/* Index: TASKPACKAGE_HAS_TASK_FK                               */
/*==============================================================*/
create index TASKPACKAGE_HAS_TASK_FK on TASK (
  PACKAGE_ID ASC
);

alter table TASK
  add constraint FK_TASKPACK_TASK foreign key (PACKAGE_ID)
references TASKPACKAGE (PACKAGE_ID);

/*==============================================================*/
/*                      CHECK__USERS                            */
/*==============================================================*/

ALTER TABLE USERS
  ADD CONSTRAINT check_role
CHECK (USER_ROLE IN ('ADMIN' , 'USER'));

ALTER TABLE USERS
  ADD CONSTRAINT check_unique_email
UNIQUE (USER_EMAIL);

ALTER TABLE USERS
  ADD CONSTRAINT check_email
CHECK ( REGEXP_LIKE (USER_EMAIL, '[a-z0-9._]+@[a-z0-9._]+\.[a-z]{2,4}'));

ALTER TABLE USERS
  ADD CONSTRAINT check_firstname
CHECK (REGEXP_LIKE(USER_FIRSTNAME,'[A-Z a-z]{3,20}'));

ALTER TABLE USERS
  ADD CONSTRAINT check_lastname
CHECK (REGEXP_LIKE(USER_LASTNAME,'[A-Z a-z]{3,20}'));

ALTER TABLE USERS
  ADD CONSTRAINT check_password
CHECK (REGEXP_LIKE(USER_PASSWORD,'[A-Za-z0-9_]{6,10}'));

ALTER TABLE USERS
  ADD CONSTRAINT check_delete_user
CHECK (DELETED IN (1,0));

/*==============================================================*/
/*                      CHECK__CALENDAR                         */
/*==============================================================*/

ALTER TABLE CALENDAR
  ADD CONSTRAINT check_calendar_name
CHECK (REGEXP_LIKE(CALENDAR_NAME,'[A-Z a-z]{3,20}'));

ALTER TABLE CALENDAR
  ADD CONSTRAINT check_delete_calendar
CHECK (DELETED IN (1,0));

/*==============================================================*/
/*                      CHECK__TASKPACKAGE                      */
/*==============================================================*/

ALTER TABLE TASKPACKAGE
  ADD CONSTRAINT check_package_name
CHECK (REGEXP_LIKE(PACKAGE_NAME,'[A-Z a-z]{3,20}'));

ALTER TABLE TASKPACKAGE
  ADD CONSTRAINT check_delete_package
CHECK (DELETED IN (1,0));	 


/*==============================================================*/
/*                      CHECK__TASK                             */
/*==============================================================*/
ALTER TABLE TASK
  ADD CONSTRAINT check_task_description
CHECK (REGEXP_LIKE(DESCRIPTION,'[A-Z a-z 0-9]{0,100}'));

ALTER TABLE TASK
  ADD CONSTRAINT check_task_place
CHECK (REGEXP_LIKE(PLACE,'[A-Z a-z 0-9]{0,25}'));

ALTER TABLE TASK
  ADD CONSTRAINT check_delete_task
CHECK (DELETED IN (1,0));


/*==============================================================*/
/*                        SEQUENCE TRIGGERS                     */
/*==============================================================*/

CREATE SEQUENCE USERS_SEQ START WITH 1;
CREATE SEQUENCE CALENDAR_SEQ START WITH 1;
CREATE SEQUENCE TASKPACK_SEQ START WITH 1;
CREATE SEQUENCE TASK_SEQ START WITH 1;


CREATE OR REPLACE TRIGGER USERS_BIR
BEFORE INSERT ON USERS
FOR EACH ROW

  BEGIN
    SELECT USERS_SEG.NEXTVAL
    INTO   :NEW.USER_ID
    FROM   DUAL;
  END;


CREATE OR REPLACE TRIGGER CALENDAR_BIR
BEFORE INSERT ON CALENDAR
FOR EACH ROW

  BEGIN
    SELECT CALENDAR_SEG.NEXTVAL
    INTO   :NEW.CALENDAR_ID
    FROM   DUAL;
  END;
  
  
create or replace TRIGGER TASKPACKK_BIR
BEFORE INSERT ON TASKPACKAGE
FOR EACH ROW

  BEGIN
    IF (:NEW.PACKAGE_ID IS NULL) THEN
    SELECT TASKPACK_SEQ.NEXTVAL INTO
  	:NEW.PACKAGE_ID FROM DUAL;
  	END IF;
END;

CREATE OR REPLACE TRIGGER TASK_BIR
BEFORE INSERT ON TASK
FOR EACH ROW

  BEGIN
    SELECT TASK_SEG.NEXTVAL
    INTO   :NEW.TASK_ID
    FROM   DUAL;
  END;	 
 
  
/*==============================================================*/
/*                      CREATE VIEWS                            */
/*==============================================================*/   
CREATE OR REPLACE VIEW USER_VIEW AS
  SELECT USER_ID,USER_ROLE , USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL , USER_PASSWORD FROM USERS
  WHERE DELETED != 1;

CREATE OR REPLACE VIEW CALENDAR_VIEW AS
  SELECT CALENDAR_ID, USER_ID ,CALENDAR_NAME FROM CALENDAR
  WHERE DELETED != 1;
  
CREATE OR REPLACE VIEW TASKPACKAGE_VIEW AS
  SELECT PACKAGE_ID, CALENDAR_ID, PACKAGE_NAME, PACKAGE_DAY , REMINDER_DATE FROM TASKPACKAGE
  WHERE DELETED != 1;
  
CREATE OR REPLACE VIEW TASK_VIEW AS
  SELECT TASK_ID, PACKAGE_ID, DESCRIPTION, PLACE  FROM TASK
  WHERE DELETED != 1;  

  
/*==============================================================*/
/*                        VIEW TRIGGERS                         */
/*==============================================================*/	 
 
CREATE OR REPLACE TRIGGER USER_INSERT
INSTEAD OF INSERT ON USER_VIEW
FOR EACH ROW
  BEGIN
    INSERT INTO USERS(USER_ID, USER_ROLE, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PASSWORD)
    VALUES (
      :NEW.USER_ID,
      :NEW.USER_ROLE,
      :NEW.USER_FIRSTNAME,
      :NEW.USER_LASTNAME,
      :NEW.USER_EMAIL,
      :NEW.USER_PASSWORD);
  END;

CREATE OR REPLACE TRIGGER USER_DELETE
INSTEAD OF DELETE ON USER_VIEW
  BEGIN
    UPDATE USERS
    SET DELETED = 1
    WHERE USER_ID = :OLD.USER_ID;
  END;

  
CREATE OR REPLACE TRIGGER CALENDAR_INSERT
INSTEAD OF INSERT ON CALENDAR_VIEW
FOR EACH ROW
  BEGIN
    INSERT INTO CALENDAR(CALENDAR_ID,USER_ID,CALENDAR_NAME)
    VALUES (
      :NEW.CALENDAR_ID,
      :NEW.USER_ID,
      :NEW.CALENDAR_NAME);
  END;

CREATE OR REPLACE TRIGGER CALENDAR_DELETE
INSTEAD OF DELETE ON CALENDAR_VIEW
  BEGIN
    UPDATE CALENDAR
    SET DELETED = 1
    WHERE CALENDAR_ID = :OLD.CALENDAR_ID;
  END;

 
CREATE OR REPLACE TRIGGER TASKPACKAGE_INSERT
INSTEAD OF INSERT ON TASKPACKAGE_VIEW FOR EACH ROW
  DECLARE
    SYS_DATE DATE;

  BEGIN
    SELECT SYSDATE INTO SYS_DATE FROM DUAL;
    IF TRUNC(SYS_DATE) > :NEW.PACKAGE_DAY THEN 
      RAISE_APPLICATION_ERROR(-20001 , 'ERROR: PACKAGE DATE MUST BE AT LEAST CURRENT DATE ' );
    ELSE IF :NEW.PACKAGE_DAY< :NEW.REMINDER_DATE  THEN
      RAISE_APPLICATION_ERROR(-20001 , 'ERROR:  REMINDER DATE INCORRECT ' );
     ELSE IF TRUNC(SYS_DATE)> :NEW.REMINDER_DATE THEN
     RAISE_APPLICATION_ERROR(-20001 , 'ERROR:  REMINDER DATE IS OUT ' );
     ELSE
      INSERT INTO TASKPACKAGE(PACKAGE_ID, CALENDAR_ID, PACKAGE_NAME, PACKAGE_DAY , REMINDER_DATE)
      VALUES (
        :NEW.PACKAGE_ID,
        :NEW.CALENDAR_ID,
        :NEW.PACKAGE_NAME,
        :NEW.PACKAGE_DAY,
        :NEW.REMINDER_DATE);
     END IF;
     END IF;
     END IF;
  END;




CREATE OR REPLACE TRIGGER TASKPACKAGE_DELETE
INSTEAD OF DELETE ON TASKPACKAGE_VIEW
  BEGIN
    UPDATE TASKPACKAGE
    SET DELETED = 1
    WHERE PACKAGE_ID = :OLD.PACKAGE_ID;
  END; 
 

CREATE OR REPLACE TRIGGER TASK_INSERT INSTEAD OF
INSERT ON TASK_VIEW FOR EACH ROW 

BEGIN
  
    INSERT
    INTO TASK
    (
      TASK_ID,
      PACKAGE_ID,
      DESCRIPTION,
      PLACE
    )
    VALUES
      (
        :NEW.TASK_ID,
        :NEW.PACKAGE_ID,
        :NEW.DESCRIPTION,
        :NEW.PLACE
      );
END;
 
CREATE OR REPLACE TRIGGER TASK_DELETE
INSTEAD OF DELETE ON TASK_VIEW
  BEGIN
    UPDATE TASK
    SET DELETED = 1
    WHERE TASK_ID = :OLD.TASK_ID;
  END;  

create or replace TRIGGER TASKPACK_BIR
BEFORE INSERT ON TASKPACKAGE
FOR EACH ROW
DECLARE 
 MAX_ID NUMBER;

  BEGIN
  
    SELECT MAX(PACKAGE_ID) INTO MAX_ID FROM TASKPACKAGE;
    SELECT (MAX_ID +1)
    INTO   :NEW.PACKAGE_ID
    FROM   DUAL;
  END;
  

 
 CREATE OR REPLACE TRIGGER USERS_BIR
BEFORE INSERT ON USERS
FOR EACH ROW
DECLARE 
 MAX_ID NUMBER;

  BEGIN
	SELECT MAX(USER_ID) INTO MAX_ID FROM USERS;
    SELECT (MAX_ID +1)
    INTO   :NEW.USER_ID
    FROM   DUAL;
  END;
  
 CREATE OR REPLACE TRIGGER CALENDAR_BIR
BEFORE INSERT ON CALENDAR
FOR EACH ROW
DECLARE 
 MAX_ID NUMBER;


  BEGIN
    SELECT MAX(CALENDAR_ID) INTO MAX_ID FROM CALENDAR;  
    SELECT (MAX_ID +1)
    INTO   :NEW.CALENDAR_ID
    FROM   DUAL;
  END; 
  
 
CREATE OR REPLACE TRIGGER TASK_BIR
BEFORE INSERT ON TASK
FOR EACH ROW
DECLARE 
 MAX_ID NUMBER;

  BEGIN
	SELECT MAX(TASK_ID) INTO MAX_ID FROM TASK; 
    SELECT (MAX_ID +1)
    INTO   :NEW.TASK_ID
    FROM   DUAL;
  END;	 
 

  

  
COMMIT ;  