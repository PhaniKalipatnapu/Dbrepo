/****** Object:  StoredProcedure [dbo].[BTROP_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[BTROP_INSERT_S1] (
	@Ac_Template_NAME		CHAR(30),
	@As_OptionXml_TEXT		VARCHAR(MAX),
	@As_OptionValue_TEXT	VARCHAR(1500),
	@Ac_SignedOnWorker_ID	CHAR(30),
	@As_Privilege_TEXT		VARCHAR(500),
	@As_Comments_TEXT		VARCHAR(400)
     )             
AS  
/*  
 *     PROCEDURE NAME    : BTROP_INSERT_S1  
 *     DESCRIPTION       : Used to add a new report profile.
						   This procedure is used to create new report profiles.
						   A newly created report profile can be private or assigned to specific roles
						   as listed in the Role Based pop up.
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN  
	DECLARE @Ld_Systemdatetime_DTTM	DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
		INSERT BTROP_Y1	
			(Template_NAME,
			 OptionXml_TEXT,
			 OptionValue_TEXT,
			 Worker_ID,
			 Create_DATE,
			 Privilege_TEXT,
			 Comments_TEXT 
			 )
		VALUES(@Ac_Template_NAME,		--Template_NAME
			   @As_OptionXml_TEXT,		--OptionXml_TEXT
			   @As_OptionValue_TEXT,	--OptionValue_TEXT
			   @Ac_SignedOnWorker_ID,   --Worker_ID
			   @Ld_Systemdatetime_DTTM,	--Create_DATE
			   @As_Privilege_TEXT,		--Privilege_TEXT
			   @As_Comments_TEXT		--Comments_TEXT
		   );
END;--End Of BTROP_INSERT_S1	

GO
