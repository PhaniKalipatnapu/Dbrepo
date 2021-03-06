/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_APPLICATIONID]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_GET_APPLICATIONID
Programmer Name		: IMP Team
Description			: This procedure is used to generate Application ID  
Frequency			: 
Developed On		: 04/12/2011
Called By			:
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_APPLICATIONID]
 @An_Application_IDNO NUMERIC(15) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_Application_IDNO	NUMERIC(15),
		  @Ls_Sql_TEXT          VARCHAR(100) = '',
		  @Ls_Sqldata_TEXT		VARCHAR(4000) = '';

  BEGIN TRY
  SET @Ls_Sql_TEXT = 'DELETING FROM IdentSeqStateApplication_T1';
  SET @Ls_Sqldata_TEXT = '';
  
  DELETE FROM IdentSeqStateApplication_T1;

  SET @Ls_Sql_TEXT = 'INSERT INTO IdentSeqStateApplication_T1';
  SET @Ls_Sqldata_TEXT = 'Entered_DATE = ' + CAST(DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS VARCHAR) ;
  INSERT INTO IdentSeqStateApplication_T1
		(Entered_DATE)
       VALUES (DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() --Entered_DATE
				);

  SET @Ls_Sql_TEXT = 'ASSIGNING APPLICATION IDNO';
  SET @Ls_Sqldata_TEXT = '';
  SELECT @Ln_Application_IDNO = a.Seq_IDNO
    FROM IdentSeqStateApplication_T1 a;
	
  SET @An_Application_IDNO = @Ln_Application_IDNO;
  
  END TRY
  
  BEGIN CATCH 
	SET @An_Application_IDNO = @Ln_Application_IDNO;
  END CATCH
  
 END


GO
