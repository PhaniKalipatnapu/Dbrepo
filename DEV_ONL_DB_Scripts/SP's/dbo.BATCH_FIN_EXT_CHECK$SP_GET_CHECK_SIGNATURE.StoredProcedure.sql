/****** Object:  StoredProcedure [dbo].[BATCH_FIN_EXT_CHECK$SP_GET_CHECK_SIGNATURE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_FIN_EXT_CHECK$SP_GET_CHECK_SIGNATURE
Programmer Name		: IMP Team
Description			: Get Ivd Director's signature  from USES_Y1 table
Frequency   		:
Developed On		:
Called By   		: None
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_EXT_CHECK$SP_GET_CHECK_SIGNATURE]
 @As_ESignature_BIN		   VARCHAR(4000) OUTPUT,
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_No_INDC					CHAR(1) = 'N',
          @Lc_StatusFailed_CODE			CHAR(1) = 'F',
          @Lc_RoleIvdDirectorRS004_ID	CHAR(5) ='RS004',
		  @Lc_JobDaily_ID				CHAR(5) ='DAILY',
          @Lc_Procedure_NAME			CHAR(30) = 'SP_GET_CHECK_SIGNATURE',
          @Ld_High_DATE					DATE = '12/31/9999';
  DECLARE @Ln_Error_NUMB     NUMERIC(11),
          @Ln_ErrorLine_NUMB NUMERIC(11),
          @Ls_Sql_TEXT       VARCHAR(100),
          @Ls_Sqldata_TEXT   VARCHAR(1000);

  BEGIN TRY
   SET @Ls_Sql_TEXT ='SELECT ECHCK_Y1';
   SET @Ls_Sqldata_TEXT ='No_INDC = ' + @Lc_No_INDC;

 SELECT TOP 1 @As_ESignature_BIN =CAST( U.ESignature_BIN as varchar(4000))
		FROM USES_Y1 U
		WHERE  Worker_ID =(
			SELECT TOP 1 Worker_ID 
			FROM USRL_Y1 
			WHERE Role_ID= @Lc_RoleIvdDirectorRS004_ID  
			--Bug 13873 - Check Effective_DATE and Expire_DATE date while selecting signature of ID-Director - START
			AND (SELECT  Run_DATE FROM PARM_Y1 p WHERE p.JOB_ID=@Lc_JobDaily_ID AND p.EndValidity_DATE=@Ld_High_DATE ) BETWEEN
			Effective_DATE AND Expire_DATE
			AND EndValidity_DATE =@Ld_High_DATE
			ORDER BY TransactionEventSeq_NUMB DESC
			)
			
			--Bug 13873 - Check Effective_DATE and Expire_DATE date while selecting signature of ID-Director - END
   
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Lc_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END 

GO
