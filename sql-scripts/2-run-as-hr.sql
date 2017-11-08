/* Copyright (c) 2015, Oracle and/or its affiliates. All rights reserved. */

/******************************************************************************
 *
 * You may not use the identified files except in compliance with the Apache
 * License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * NAME
 *   2-run-as-hr.sql
 *
 * DESCRIPTION
 *   This file creates a table and inserts some sample data that are used by
 *   the application. A query registration is also created. Finally, the
 *   procedure that will be executed when the data changes is created.
 *
 *   Remember to change the IP address in the procedure from 127.0.0.1 to the
 *   correct IP address for the Node.js server.
 *
 *****************************************************************************/

CREATE SEQUENCE jsao_employees_seq INCREMENT BY 1 START WITH 1;

CREATE TABLE jsao_employees (
   employee_id  NUMBER(6,0), 
   first_name   VARCHAR2(20 BYTE), 
   last_name    VARCHAR2(25 BYTE), 
   phone_number VARCHAR2(20 BYTE), 
   hire_date    DATE
);

CREATE OR REPLACE TRIGGER bir_jsao_employees_trg
   BEFORE INSERT ON jsao_employees
   FOR EACH ROW
BEGIN
   IF :new.employee_id IS NULL
   THEN
      :new.employee_id := jsao_employees_seq.nextval;
   END IF;
END bir_jsao_employees_trg;
/

SET DEFINE OFF;

INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Donald','OConnell','650.507.9833',to_date('21-JUN-07','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Douglas','Grant','650.507.9844',to_date('13-JAN-08','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Jennifer','Whalen','515.123.4444',to_date('17-SEP-03','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Michael','Hartstein','515.123.5555',to_date('17-FEB-04','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Pat','Fay','603.123.6666',to_date('17-AUG-05','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Susan','Mavris','515.123.7777',to_date('07-JUN-02','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Hermann','Baer','515.123.8888',to_date('07-JUN-02','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Shelley','Higgins','515.123.8080',to_date('07-JUN-02','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('William','Gietz','515.123.8181',to_date('07-JUN-02','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Steven','King','515.123.4567',to_date('17-JUN-03','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Neena','Kochhar','515.123.4568',to_date('21-SEP-05','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Lex','De Haan','515.123.4569',to_date('13-JAN-01','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Alexander','Hunold','590.423.4567',to_date('03-JAN-06','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Bruce','Ernst','590.423.4568',to_date('21-MAY-07','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('David','Austin','590.423.4569',to_date('25-JUN-05','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Valli','Pataballa','590.423.4560',to_date('05-FEB-06','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Diana','Lorentz','590.423.5567',to_date('07-FEB-07','DD-MON-RR'));
INSERT INTO jsao_employees (FIRST_NAME,LAST_NAME,PHONE_NUMBER,HIRE_DATE) VALUES ('Nancy','Greenberg','515.124.4569',to_date('17-AUG-02','DD-MON-RR'));

COMMIT;

DECLARE

   l_reginfo CQ_NOTIFICATION$_REG_INFO;
   l_cursor  SYS_REFCURSOR;
   l_regid   NUMBER;

BEGIN

    l_reginfo := cq_notification$_reg_info (
        'query_callback',
        dbms_cq_notification.qos_best_effort,
        0, 0, 0
    );

    l_regid := dbms_cq_notification.new_reg_start(l_reginfo);

    OPEN l_cursor FOR
        SELECT dbms_cq_notification.cq_notification_queryid,
            employee_id,
            first_name,
            last_name,
            phone_number,
            hire_date
        FROM hr.jsao_employees;
    CLOSE l_cursor;

    dbms_cq_notification.reg_end;

END;
/

--The following procedure will be executed when the query results are changed
--Set the IP address in the url param to the IP address where where Node.js is listening
CREATE OR REPLACE PROCEDURE query_callback(
    ntfnds IN CQ_NOTIFICATION$_DESCRIPTOR
)

AS

    l_req  UTL_HTTP.REQ;
    l_resp UTL_HTTP.RESP;

BEGIN

    l_req := utl_http.begin_request(
        url    => '127.0.0.1:3000/db',
        method => 'GET'
    );

    l_resp := utl_http.get_response(r => l_req);

    utl_http.end_response(r => l_resp);

END;
/