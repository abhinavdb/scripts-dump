-- STEP 1: Check for a existing session to drop it and Create XEvent Session to capture login failures
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='XE_LOGIN_FAILURE')
  DROP EVENT session [XE_LOGIN_FAILURE] ON SERVER;
GO
CREATE EVENT SESSION [XE_LOGIN_FAILURE] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(package0.collect_system_time,package0.event_sequence,package0.process_id,sqlserver.client_hostname,
	sqlserver.context_info,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.session_id))

WITH (STARTUP_STATE=OFF)
GO


-- STEP 2: Start the XEvent Session
ALTER EVENT SESSION [XE_LOGIN_FAILURE] ON SERVER STATE = START;

-- STEP 3: Read live data

-- STEP 4: Stop the XEvent Session
ALTER EVENT SESSION [XE_LOGIN_FAILURE] ON SERVER STATE = STOP;

-- STEP 5: Drop the XEvent Session
DROP EVENT SESSION [XE_LOGIN_FAILURE] ON SERVER;



