-- THIS SCRIPT USES "char" THROUGHOUT INSTEAD OF CHAR BECAUSE
-- THE RUST LIBRARY sqlx MAPS i8 TO "char" AND THAT BEHAVIOR
-- CANNOT BE CHANGED
--
-- W IS WHEN, DEFAULTS TO START OF CURRENT TRANSACTION
CREATE UNLOGGED TABLE T(
    U_ID "char" NOT NULL,
    VALOR INTEGER NOT NULL, -- IN CENTS
    TIPO BOOLEAN NOT NULL, -- TRUE FOR 'c', FALSE FOR 'd'
    DESCRICAO TEXT NOT NULL,
    W TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX T_UW ON T(U_ID, W);

-- USERS
--
-- ID IS RECEIVED BY THE API AS 1, 2, 3, 4, 5, AND THEN CONVERTED
-- TO 'A', 'B', 'C', 'D', 'E' FOR STORAGE, FOR NO PARTICULAR REASON.
-- THIS MEANS THE IDS MAX OUT AT 255-64=191, AND SINCE "char" GETS
-- MAPPED TO i8 IN RUST, THE ACTUAL LIMIT IS EVEN LOWER AT 128-64=63.
-- 63 ROWS OUGHT TO BE MORE THAN ENOUGH TO REPRESENT ALL PEOPLE.
-- JUST REMEMBER TO ADD 0x40 WHEN INSERTING A NEW ROW.
CREATE UNLOGGED TABLE U(
    ID "char" NOT NULL,
    LIMITE INTEGER NOT NULL,
    SALDO INTEGER NOT NULL -- OFTEN NEGATIVE
);

-- USERS, THE IMMORTALS
INSERT INTO U(ID, LIMITE, SALDO)
    VALUES('A', 100000, 0), -- ID 0x41
        ('B', 80000, 0), -- ID 0x42
        ('C', 1000000, 0), -- ID 0x43
        ('D', 10000000, 0), -- ID 0x44
        ('E', 500000, 0); -- ID 0x45

-- (NOT CREATING AN INDEX FOR U BECAUSE ITS ID HAS A SIZE OF ONE BYTE)

-- VERIFICATION, UPDATE AND INSERT ALL IN ONE ATOMICALLY
-- PRODUCES 1 ROW IF SUCCESSFUL, 0 ROWS IF DISALLOWED
CREATE OR REPLACE FUNCTION insert_into_t(u_id_arg "char", valor_arg INTEGER, tipo_arg BOOLEAN, descricao_arg TEXT)
RETURNS SETOF U AS $$ -- ALWAYS 0 OR 1 OF U
DECLARE
    user_record U%ROWTYPE;
BEGIN
    PERFORM pg_advisory_lock(CAST(ascii(u_id_arg) AS BIGINT));
    -- CHECK IF OPERATION IS ALLOWED
    -- 'c' IS ALWAYS PERMITTED, 'd' IS ONLY PERMITTED
    -- WHEN SALDO MINUS valor_arg WOULD NOT BECOME SMALLER THAN
    -- THE ADDITIVE INVERSE OF LIMIT
    IF tipo_arg OR (NOT tipo_arg AND EXISTS (
        SELECT 1 FROM U
        WHERE ID = u_id_arg
        AND SALDO - valor_arg >= -LIMITE
    )) THEN
        -- PERFORM THE INSERT INTO T
        -- IT IS ASSUMED THAT EACH VALUE HAS PREVIOUSLY BEEN
        -- VALIDATED AND THIS OPERATION WILL NOT FAIL
        INSERT INTO T (U_ID, VALOR, TIPO, DESCRICAO)
        VALUES (u_id_arg, valor_arg, tipo_arg, descricao_arg);
        
        -- UPDATE SALDO IN U AND GET THE UPDATED ROW
        UPDATE U
        SET SALDO = CASE WHEN tipo_arg THEN SALDO + valor_arg ELSE SALDO - valor_arg END
        WHERE ID = u_id_arg
        RETURNING * INTO user_record;

        PERFORM pg_advisory_unlock(CAST(ascii(u_id_arg) AS BIGINT));
        
        -- RETURN THE UPDATED RECORD OF U
        RETURN NEXT user_record;
    ELSE
        -- RETURN NO ROWS IF THE OPERATION IS NOT PERMITTED
        PERFORM pg_advisory_unlock(CAST(ascii(u_id_arg) AS BIGINT));
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- PARAMETERS
-- NOT TESTED VERY MUCH

-- NO IMPACT ON PERFORMANCE, JUST CONFIRMING THAT WE'RE USING THE
-- SAME ENCODING AS RUST
ALTER SYSTEM SET client_encoding = 'UTF8';
-- DISABLE SQL STATEMENT LOGGING TO REDUCE I/O
ALTER SYSTEM SET log_statement = none;
-- MAX NUMBER OF CONCURRENT CONNECTIONS,
-- USES MORE RESOURCES BUT MAY HELP WHEN WORKLOAD IS HIGHLY PARALLEL
ALTER SYSTEM SET max_connections = 200;
-- MEM THE DB SERVER USES FOR SHARED MEMORY BUFFERS,
-- INCREASES MEM USAGE IN AN ATTEMPT TO DECREASE DISK I/O
ALTER SYSTEM SET shared_buffers = '0.35GB';
-- ESTIMATE OF HOW MUCH MEMORY IS AVAILABLE FOR DISK CACHING
ALTER SYSTEM SET effective_cache_size = '50MB';
-- LETS TRANSACTIONS BE REPORTED AS COMMITTED BEFORE WAITING
-- FOR THE DISK FLUSH, WHICH LEADS TO DATA LOSS IN CASE OF CRASH
-- BUT INCREASES THROUGHPUT SINCE SUCCESSES HAPPEN BEFORE THE
-- CHANGES ARE GUARANTEED TO BE WRITTEN
ALTER SYSTEM SET synchronous_commit = off;
-- DELAY BETWEEN TRANSACTION COMMIT AND WRITE TO DISK, MAY LET
-- MULTIPLE TRANSACTIONS BE COMMITED WITH ONE DISK WRITE;
-- I THINK THIS HAS NO EFFECT SINCE SYNCHRONOUS COMMIT IS OFF
ALTER SYSTEM SET commit_delay = 40;
-- LARGE MAXIMUM TIME BETWEEN WAL CHECKPOINTS, ALTHOUGH WE EXPECT
-- THOSE TO NOT HAPPEN AT ALL DUE TO ANOTHER SETTING
ALTER SYSTEM SET checkpoint_timeout = 86399;
-- AMOUNT OF MEMORY TO BE USED FOR INTERNAL SORT OPERATIONS AND
-- HASH TABLES, INCREASES MEMORY USAGE IN AN ATTEMPT TO AVOID
-- DISK ACCESS BUT MAY CAUSE HIGH USAGE IF THERE ARE MANY
-- CONNECTIONS SIMULTANEOUSLY
ALTER SYSTEM SET work_mem = '12MB';
-- MAX MEM USED FOR TEMPORARY BUFFERS IN EACH SESSION FOR TEMP TABLES
ALTER SYSTEM SET temp_buffers = '120MB';
-- DISABLES WRITING SAFELY TO DISK BEFORE REPORTING SUCCESS,
-- EXPECTED TO INCREASE PERFORMANCE AT THE PRICE OF RISK OF CORRUPTION
ALTER SYSTEM SET fsync = off;
-- DISABLE ROW-LEVEL SECURITY FOR POSSIBLY A SMALL AMOUNT OF
-- PERFORMANCE GAIN, WHICH IS PROBABLY FINE SINCE WE AREN'T
-- PRIORITIZING SECURITY POLICIES (OR AT LEAST I THINK THAT'S
-- NOT MEASURABLE)
ALTER SYSTEM SET row_security = off;
-- NO TIMEOUT FOR SQL STATEMENTS, PREVENTING QUERIES FROM BEING
-- PREMATURELY CANCELLED, BUT RISKS LONG-RUNNING QUERIES STICKING
-- AROUND FOR VERY LONG
ALTER SYSTEM SET statement_timeout = 0;
-- DISABLES THE TIMEOUT FOR OBTAINING A LOCK, WHICH PREVENTS QUERIES
-- FROM BEING CANCELLED BUT ALSO RISKS SESSIONS LASTING VERY LONG
ALTER SYSTEM SET lock_timeout = 0;
-- DISABLE TIMEOUT FOR SESSIONS IDLE IN TRANSACTION, PREVENTS QUERIES
-- FROM BEING CANCELLED BUT MAY LEAD TO SESSIONS HOLDING LOCKS
-- FOR VERY LONG
ALTER SYSTEM SET idle_in_transaction_session_timeout = 0;
-- ENSURE THAT THE DB ISN'T WASTING TIME WITH UNIMPORTANT MESSAGES
ALTER SYSTEM SET client_min_messages = warning;
