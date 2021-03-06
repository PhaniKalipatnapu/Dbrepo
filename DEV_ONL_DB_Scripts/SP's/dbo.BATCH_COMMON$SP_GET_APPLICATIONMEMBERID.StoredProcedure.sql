/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_GET_APPLICATIONMEMBERID]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 --------------------------------------------------------------------------------------------------------------------
 Procedure Name		: BATCH_COMMON$SP_GET_APPLICATIONMEMBERID
 Programmer Name	: IMP Team
 Description		: This program is used to generate application negative member id for unknown members 
 Frequency			: 
 Developed On		:	04/12/2011
 Called By			:
 Called On			:
 --------------------------------------------------------------------------------------------------------------------
 Modified By		:
 Modified On		:
 Version No			: 1.0
 --------------------------------------------------------------------------------------------------------------------
 */
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_GET_APPLICATIONMEMBERID]
 @An_MemberSeq_IDNO NUMERIC(10) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ln_MemberSeq_IDNO	NUMERIC(10),
		  @Ls_Sql_TEXT          VARCHAR(100) = '',
		  @Ls_Sqldata_TEXT		VARCHAR(4000) = '';

  BEGIN TRY
  SET @Ls_Sql_TEXT = 'DELETING FROM IMEMB_Y1';
  SET @Ls_Sqldata_TEXT = '';
  
  DELETE FROM IMEMB_Y1;

  SET @Ls_Sql_TEXT = 'INSERT INTO IMEMB_Y1';
  SET @Ls_Sqldata_TEXT = 'Entered_DATE = ' + CAST(DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS VARCHAR) ;
  
  INSERT INTO IMEMB_Y1
      (Entered_DATE)
       VALUES (DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() -- Entered_DATE
       );
  
  SET @Ls_Sql_TEXT = 'ASSIGNING MemberSeq_IDNO';
  SET @Ls_Sqldata_TEXT = '';
    
  SELECT @Ln_MemberSeq_IDNO = a.MemberSeq_IDNO
    FROM IMEMB_Y1 a;
  
  SET @An_MemberSeq_IDNO = @Ln_MemberSeq_IDNO;

  END TRY

  BEGIN CATCH
   SET @An_MemberSeq_IDNO = 0;
  END CATCH
  
 END


GO
