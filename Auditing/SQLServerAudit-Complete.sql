USE [master]
GO

/****** Object:  Audit [Audit-20221110-153314]    Script Date: 27/02/2023 8:46:19 AM ******/
CREATE SERVER AUDIT [Audit-20221110-153314]
TO FILE 
(	FILEPATH = N'D:\SQLAuditLogins\'
	,MAXSIZE = 512 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE, AUDIT_GUID = 'b7910c6b-7cf9-4be1-8b17-324d7c897636')
WHERE (NOT [server_principal_name] like 'enterprise%' AND NOT [server_principal_name] like 'nt service%' AND NOT [server_principal_name] like 'odyssey%')

ALTER SERVER AUDIT [Audit-20221110-153314] WITH (STATE = OFF)
GO

-- how to read data
;WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2008/sqlaudit_data' AS ns)
SELECT audi.event_time,audi.session_id,audi.server_principal_name,audi.database_name,audi.succeeded, T.c.value('(ns:address/text())[1]', 'nvarchar(30)') as Client_Ip
FROM     (SELECT *, cast(additional_information AS xml) AS additional_xml
                FROM fn_get_audit_file('L:\TGFGLBDEV Backups\SQLAuditLogins\*.*', NULL, NULL)) AS audi
CROSS    APPLY additional_xml.nodes('/ns:action_info') AS T(c)
Go

