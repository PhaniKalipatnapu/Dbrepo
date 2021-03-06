/****** Object:  StoredProcedure [dbo].[BTROP_UPDATE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[BTROP_UPDATE_S1] (
	@As_OptionXml_TEXT		VARCHAR(MAX),
	@As_OptionValue_TEXT	VARCHAR(1500),
	@As_Privilege_TEXT		VARCHAR(500),
	@As_Comments_TEXT		VARCHAR(400),
	@An_Report_IDNO			NUMERIC(10,0),
    @Ac_SignedOnWorker_ID	CHAR(30) 
     )             
AS  
/*  
 *     PROCEDURE NAME    : BTROP_UPDATE_S1  
 *     DESCRIPTION       : Used to update a selected report profile.
						   This procedure is used to make changes to existing report templates.
                           Its invoked on click of the Save button under Report Profiles.
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
 BEGIN 
   DECLARE @Ld_Systemdatetime_DTTM	DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
		 UPDATE BTROP_Y1
			SET OptionXml_TEXT		=	@As_OptionXml_TEXT,
				OptionValue_TEXT	=	@As_OptionValue_TEXT,
				Create_DATE			=	@Ld_Systemdatetime_DTTM,
				Privilege_TEXT		=	@As_Privilege_TEXT,
				Comments_TEXT		=	@As_Comments_TEXT
		  WHERE Report_IDNO			=	@An_Report_IDNO
			AND Worker_ID			=	@Ac_SignedOnWorker_ID;
		    
		 DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);
			 SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;  
		  SELECT @Ln_RowsAffected_NUMB;   
 END;--End of BTROP_UPDATE_S1    

GO
