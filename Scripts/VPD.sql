------------------------------------------------------------------------------------------------------------
-- Set Session
    ALTER SESSION SET CONTAINER = FREEPDB1;
    SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM DUAL;

------------------------------------------------------------------------------------------------------------
-- Create Roles
    CREATE ROLE admin;
    CREATE ROLE agent;
    CREATE ROLE customer;
    CREATE ROLE chef;
    CREATE ROLE Housekeeping;
    CREATE ROLE Receptionist;

------------------------------------------------------------------------------------------------------------
-- Create Views

    -- CustomerBookingView
    CREATE OR REPLACE VIEW "CustomerBookingView" AS
    SELECT "booking_id", "hotel_key", "date_key", "lead_time", "stays_in_weekend_nights", "stays_in_week_nights",
        "adults", "children", "babies", "meal", "room_key", "deposit_type", "reservation_status", "reservation_status_date"
    FROM "FactBooking";

    -- ChefBookingView
    CREATE OR REPLACE VIEW "ChefBookingView" AS
    SELECT "booking_id", "hotel_key", "adults", "children", "babies", "meal", "is_canceled"
    FROM "FactBooking";

    -- HouseBookingView
    CREATE OR REPLACE VIEW "HouseBookingView" AS
    SELECT "booking_id", "room_key", "stays_in_week_nights", "stays_in_weekend_nights",
        "reservation_status_date", "is_canceled"
    FROM "FactBooking";

    -- ReceptionBookingView
    CREATE OR REPLACE VIEW "ReceptionBookingView" AS
    SELECT "booking_id", "hotel_key", "customer_key", "room_key", "reservation_status", "reservation_status_date", "is_canceled"
    FROM "FactBooking";

    -- AgentProfileView
    CREATE OR REPLACE VIEW "AgentProfileView" AS
    SELECT "agent_key", "agent_id", "starting_date", "total_work_hours", "total_commission"
    FROM "DimAgent";

    -- CustomerProfileView
    CREATE OR REPLACE VIEW "CustomerProfileView" AS
    SELECT "customer_key", "name", "country", "is_repeated_guest", "previous_bookings_not_canceled", "total_of_special_requests"
    FROM "DimCustomer";

    -- CustomerSecureView
    CREATE OR REPLACE VIEW "CustomerSecureView" AS
    SELECT "customer_key", "email", "phone_number"
    FROM "DimCustomerSecure";

------------------------------------------------------------------------------------------------------------
-- Create Application Context Package
    CREATE OR REPLACE PACKAGE security_ctx_pkg AS
    PROCEDURE set_user_context(p_user_id VARCHAR2, p_user_role VARCHAR2);
    END security_ctx_pkg;
    /

    CREATE OR REPLACE PACKAGE BODY security_ctx_pkg AS
    PROCEDURE set_user_context(p_user_id VARCHAR2, p_user_role VARCHAR2) IS
    BEGIN
        DBMS_SESSION.SET_CONTEXT('security_ctx', 'user_id', p_user_id);
        DBMS_SESSION.SET_CONTEXT('security_ctx', 'user_role', p_user_role);
    END;
    END security_ctx_pkg;
    /

------------------------------------------------------------------------------------------------------------
-- Create the Application Context
    CREATE OR REPLACE CONTEXT security_ctx USING security_ctx_pkg;

------------------------------------------------------------------------------------------------------------
-- Modify Policy Functions to Use This Context
-- For AgentBookingView
    CREATE OR REPLACE FUNCTION agent_view_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role    VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
        v_user_id VARCHAR2(30) := SYS_CONTEXT('security_ctx', 'user_id');
    BEGIN
        IF v_role = 'AGENT' THEN
            RETURN '"agent_key" =' || TO_NUMBER(v_user_id);
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"AgentBookingView"', 'agent_view_policy');

        DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"AgentBookingView"',
            policy_name     => 'agent_view_policy',
            function_schema => 'SYSTEM',
            policy_function => 'agent_view_rls',
            statement_types => 'SELECT'
        );      
    END;
    /
    
------------------------------------------------------------------------------------------------------------
-- For CustomerBookingView
    CREATE OR REPLACE FUNCTION customer_view_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role    VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
        v_user_id VARCHAR2(30) := SYS_CONTEXT('security_ctx', 'user_id');
    BEGIN
        IF v_role = 'CUSTOMER' THEN
            RETURN '"customer_key" = ' || TO_NUMBER(v_user_id);
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"CustomerBookingView"', 'customer_view_policy');
        DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"CustomerBookingView"',
            policy_name     => 'customer_view_policy',
            function_schema => 'SYSTEM',
            policy_function => 'customer_view_rls',
            statement_types => 'SELECT'
        );       
    END;
    /

------------------------------------------------------------------------------------------------------------
-- For ChefBookingView
    CREATE OR REPLACE FUNCTION chef_view_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
    BEGIN
        IF v_role = 'CHEF' THEN
            RETURN '"is_canceled" = 0';
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"ChefBookingView"', 'chef_view_policy');
        DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"ChefBookingView"',
            policy_name     => 'chef_view_policy',
            function_schema => 'SYSTEM',
            policy_function => 'chef_view_rls',
            statement_types => 'SELECT'
        );
    END;
    /
    
------------------------------------------------------------------------------------------------------------
-- For HouseBookingView
    CREATE OR REPLACE FUNCTION house_view_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
    BEGIN
        IF v_role = 'HOUSEKEEPING' THEN
            RETURN '"is_canceled" = 1';
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"HouseBookingView"', 'house_view_policy');
    
        DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"HouseBookingView"',
            policy_name     => 'house_view_policy',
            function_schema => 'SYSTEM',
            policy_function => 'house_view_rls',
            statement_types => 'SELECT'
        );
    END;
    /
    
------------------------------------------------------------------------------------------------------------
-- For ReceptionBookingView
    CREATE OR REPLACE FUNCTION reception_view_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
    BEGIN
        IF v_role = 'RECEPTIONIST' THEN
            RETURN '"reservation_status" = ''Check-Out''';
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"ReceptionBookingView"', 'reception_view_policy');
       
        DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"ReceptionBookingView"',
            policy_name     => 'reception_view_policy',
            function_schema => 'SYSTEM',
            policy_function => 'reception_view_rls',
            statement_types => 'SELECT'
        );
    END;
    /
    
------------------------------------------------------------------------------------------------------------
-- For DimAgent
    CREATE OR REPLACE FUNCTION dim_agent_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role     VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
        v_user_id  VARCHAR2(30) := SYS_CONTEXT('security_ctx', 'user_id');
    BEGIN
        IF v_role = 'AGENT' THEN
            RETURN '"agent_id" = ' || TO_NUMBER(v_user_id);
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"DimAgent"', 'dim_agent_policy');

        DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"DimAgent"',
            policy_name     => 'dim_agent_policy',
            function_schema => 'SYSTEM',
            policy_function => 'dim_agent_rls',
            statement_types => 'SELECT'
        );
    END;
    /
    
------------------------------------------------------------------------------------------------------------
--  For DimCustomer
    CREATE OR REPLACE FUNCTION dim_customer_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
    BEGIN
        IF v_role = 'CUSTOMER' THEN
            RETURN '"customer_key" = ' || TO_NUMBER(SYS_CONTEXT('security_ctx', 'user_id'));
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"DimCustomer"', 'dim_customer_policy');

        DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"DimCustomer"',
            policy_name     => 'dim_customer_policy',
            function_schema => 'SYSTEM',
            policy_function => 'dim_customer_rls',
            statement_types => 'SELECT'
        );  
    END;
    /
    
------------------------------------------------------------------------------------------------------------
--  For DimCustomerSecure
    CREATE OR REPLACE FUNCTION dim_customer_secure_rls (
        schema_name VARCHAR2,
        table_name  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_role VARCHAR2(30) := UPPER(SYS_CONTEXT('security_ctx', 'user_role'));
    BEGIN
        IF v_role = 'CUSTOMER' THEN
            RETURN '"customer_key" = ' || TO_NUMBER(SYS_CONTEXT('security_ctx', 'user_id'));
        ELSIF v_role = 'ADMIN' THEN
            RETURN '1=1';
        ELSE
            RETURN '1=0';
        END IF;
    END;
    /

    BEGIN
        -- Drop policies on tables
        DBMS_RLS.DROP_POLICY('SYSTEM', '"DimCustomerSecure"', 'dim_customer_secure_policy');
            DBMS_RLS.ADD_POLICY(
            object_schema   => 'SYSTEM',
            object_name     => '"DimCustomerSecure"',
            policy_name     => 'dim_customer_secure_policy',
            function_schema => 'SYSTEM',
            policy_function => 'dim_customer_secure_rls',
            statement_types => 'SELECT'
        ); 
    END;
    /

------------------------------------------------------------------------------------------------------------
-- Grant Table and View Access to Roles
    -- Admin Access
    GRANT ALL ON "FactBooking" TO admin;
    GRANT ALL ON "DimAgent" TO admin;
    GRANT ALL ON "DimCustomer" TO admin;
    GRANT ALL ON "DimCustomerSecure" TO admin;
    GRANT ALL ON "AgentBookingView" TO admin;
    GRANT ALL ON "AgentProfileView" TO admin;
    GRANT ALL ON "CustomerBookingView" TO admin;
    GRANT ALL ON "CustomerProfileView" TO admin;
    GRANT ALL ON "CustomerSecureView" TO admin;
    GRANT ALL ON "ChefBookingView" TO admin;
    GRANT ALL ON "ReceptionBookingView" TO admin;
    GRANT ALL ON "DimHotel" TO admin;
    GRANT ALL ON "DimDate" TO admin;
    GRANT ALL ON "DimRoom" TO admin;

    -- Agent Access
    GRANT SELECT ON "AgentBookingView" TO agent;
    GRANT SELECT ON "AgentProfileView" TO agent;
    GRANT SELECT ON "DimHotel" TO agent;
    GRANT SELECT ON "DimDate" TO agent;
    GRANT SELECT ON "DimRoom" TO agent;

    -- Customer Access
    GRANT SELECT ON "CustomerBookingView" TO customer;
    GRANT SELECT ON "CustomerProfileView" TO customer;
    GRANT SELECT ON "CustomerSecureView" TO customer;
    GRANT SELECT ON "DimHotel" TO customer;
    GRANT SELECT ON "DimDate" TO customer;

    -- Chef Access
    GRANT SELECT ON "ChefBookingView" TO chef;
    GRANT SELECT ON "DimHotel" TO chef;
    GRANT SELECT ON "DimDate" TO chef;
    GRANT SELECT ON "DimRoom" TO chef;

    -- Receptionist Access
    GRANT SELECT ON "ReceptionBookingView" TO receptionist;
    GRANT SELECT ON "DimHotel" TO receptionist;
    GRANT SELECT ON "DimDate" TO receptionist;
    GRANT SELECT ON "DimRoom" TO receptionist;

------------------------------------------------------------------------------------------------------------
-- Creat Users with Roles
    -- Admin User
    CREATE USER admin_user IDENTIFIED BY admin123;
    GRANT CONNECT TO admin_user;
    GRANT admin TO admin_user;

    -- Agent User
    CREATE USER agent_user IDENTIFIED BY agent123;
    GRANT CONNECT TO agent_user;
    GRANT agent TO agent_user;

    -- Customer User
    CREATE USER customer_user IDENTIFIED BY cust123;
    GRANT CONNECT TO customer_user;
    GRANT customer TO customer_user;

    -- Chef User
    CREATE USER chef_user IDENTIFIED BY chef123;
    GRANT CONNECT TO chef_user;
    GRANT chef TO chef_user;

    -- HouseKeeping User
    CREATE USER house_user IDENTIFIED BY house123;
    GRANT CONNECT TO house_user;
    GRANT Housekeeping TO house_user;

    -- Receptionist User
    CREATE USER reception_user IDENTIFIED BY reception123;
    GRANT CONNECT TO reception_user;
    GRANT Receptionist TO reception_user;

------------------------------------------------------------------------------------------------------------
-- Logon Trigger
CREATE OR REPLACE TRIGGER set_context_on_login
AFTER LOGON ON DATABASE
BEGIN
  -- Log initial trigger firing
  INSERT INTO login_audit VALUES (
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    SYSTIMESTAMP,
    'Trigger fired for user: ' || SYS_CONTEXT('USERENV', 'SESSION_USER')
  );

  CASE SYS_CONTEXT('USERENV', 'SESSION_USER')
    WHEN 'ADMIN_USER' THEN
        security_ctx_pkg.set_user_context('0', 'admin');
    WHEN 'AGENT_USER' THEN
        security_ctx_pkg.set_user_context('291', 'agent');
    WHEN 'CUSTOMER_USER' THEN
        security_ctx_pkg.set_user_context('202', 'customer');
    WHEN 'CHEF_USER' THEN
        security_ctx_pkg.set_user_context('0', 'chef');
    WHEN 'HOUSE_USER' THEN
        security_ctx_pkg.set_user_context('0', 'HouseKeeping');
    WHEN 'RECEPTION_USER' THEN
        security_ctx_pkg.set_user_context('0', 'Receptionist');
    ELSE
      BEGIN
        INSERT INTO login_audit VALUES (
          SYS_CONTEXT('USERENV', 'SESSION_USER'),
          SYSTIMESTAMP,
          'SwitchCase failed for: ' || SYS_CONTEXT('USERENV', 'SESSION_USER')
        );
      END;
  END CASE;
END;
/

------------------------------------------------------------------------------------------------------------
-- User Connection (Modify SERVICE NAME in tnsnames.ora and change connection type to TNS)
    -- Grant EXECUTE on the Package to PUBLIC 
    GRANT EXECUTE ON security_ctx_pkg TO PUBLIC;

    -- Recompile the Trigger and Package
    ALTER TRIGGER set_context_on_login COMPILE;
    ALTER PACKAGE security_ctx_pkg COMPILE;

    -- Check on Security Context
    SELECT * FROM DBA_CONTEXT WHERE NAMESPACE = 'SECURITY_CTX';

    -- Connect to Admin User
    CONNECT admin_user/admin123@FREEPDB1;
    
    -- Check User Context
    SELECT SYS_CONTEXT('security_ctx', 'user_role') AS role, SYS_CONTEXT('security_ctx', 'user_id') AS user_id FROM DUAL;
    SELECT * FROM SYSTEM.login_audit ORDER BY LOG_TIME;


