/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROCEDURES]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Program Name		: BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROCEDURES
Programmer Name		: IMP Team.
Description			: The procedure BATCH_GEN_NOTICE_UTIL$EXEC_RECP_DETAILS_PROC gets recipient details by calling seperate procedure for each recipient
Frequency			: 
Developed On		: 03/22/2011
Called BY			: 
Called On       	: 
-----------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROCEDURES]
 @As_Proc_NAME              VARCHAR(75),
 @An_Case_IDNO              NUMERIC(6),
 @Ac_Notice_ID              CHAR(8),
 @An_MemberMci_IDNO			NUMERIC(10),
 @An_OthpSource_IDNO        NUMERIC(10),
 @An_MajorIntSeq_NUMB       NUMERIC(5),
 @Ac_IVDOutOfStateFips_CODE CHAR(7),
 @Ac_Receipt_ID				CHAR(27)	= NULL,
 @Ac_Recipient_CODE         CHAR(2),
 @Ac_PrintMethod_CODE       CHAR(1),
 @Ac_TypeService_CODE       CHAR(1),
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
AS
 DECLARE 
		 @Lc_StatusSuccess_CODE          CHAR(1) = 'S',
         @Lc_StatusFailed_CODE           CHAR(1) = 'F',
         @Ls_Routine_TEXT                VARCHAR(75) = 'BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROC';
         
 DECLARE
         @Lc_Error_CODE                  CHAR(4),
         @Ls_ErrorDesc_TEXT              VARCHAR(4000),
         @Ls_Sql_TEXT                    VARCHAR(100) = '',
         @Ls_Sqldata_TEXT                VARCHAR(1000) = '',
         @Ls_Err_Description_TEXT        VARCHAR(4000),
         @Ls_ErrorMesg_TEXT              VARCHAR(4000),
         @Ls_SQLProcParameterString_TEXT NVARCHAR(MAX),
         @Ls_SqlString_TEXT              NVARCHAR(MAX),
         @Ls_ParamDefinition_TEXT        NVARCHAR(MAX);

 BEGIN
 
  BEGIN TRY
	
   SET @Ls_SQLProcParameterString_TEXT = (SELECT STUFF((SELECT ',' + Parameter_NAME + CASE
                                                                                       WHEN Output_INDC = 'Y'
                                                                                        THEN ' OUTPUT'
                                                                                       ELSE ''
                                                                                      END
                                                          FROM PPRM_Y1
                                                         WHERE Procedure_NAME = @As_Proc_NAME
                                                         ORDER BY ParameterPosition_NUMB
                                                        FOR XML PATH('')), 1, 1, ''));
                                                       
   SET @Ls_ParamDefinition_TEXT =  '@An_Case_IDNO				NUMERIC(6),
									@An_MemberMci_IDNO			NUMERIC(10),
									@An_OthpSource_IDNO			NUMERIC(10),
									@An_MajorIntSeq_NUMB		NUMERIC(5),
									@Ac_Notice_ID				CHAR(8),
									@Ac_IVDOutOfStateFips_CODE	CHAR(7),
									@Ac_Receipt_ID				CHAR(27),
									@Ac_Recipient_CODE			CHAR(2),
									@Ac_PrintMethod_CODE		CHAR(1),
									@Ac_TypeService_CODE		CHAR(1),
									@Ac_Msg_CODE				VARCHAR(5) OUTPUT,
									@As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT';

   SET @Ls_SqlString_TEXT = 'EXEC ' + @As_Proc_NAME + ' ' + @Ls_SQLProcParameterString_TEXT;

   EXECUTE SP_EXECUTESQL
				@Ls_SqlString_TEXT,
				@Ls_ParamDefinition_TEXT,
				@Ac_Recipient_CODE         = @Ac_Recipient_CODE,
				@An_OthpSource_IDNO        = @An_OthpSource_IDNO,
				@Ac_Notice_ID			   = @Ac_Notice_ID,
				@An_Case_IDNO              = @An_Case_IDNO,
				@An_MemberMci_IDNO		   = @An_MemberMci_IDNO,
				@An_MajorIntSeq_NUMB       = @An_MajorIntSeq_NUMB,
				@Ac_IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE,
				@Ac_Receipt_ID			   = @Ac_Receipt_ID,
				@Ac_PrintMethod_CODE       = @Ac_PrintMethod_CODE,
				@Ac_TypeService_CODE       = @Ac_TypeService_CODE,
				@Ac_Msg_CODE               = @Ac_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT  = @As_DescriptionError_TEXT OUTPUT;

   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
    BEGIN
     IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
      BEGIN
       SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + @As_Proc_NAME + ' ' + ISNULL(@Ls_Sqldata_TEXT, '');
      END
     ELSE
      BEGIN
       SET @As_DescriptionError_TEXT = ISNULL(@As_DescriptionError_TEXT, ' ') + ' ' + ISNULL(@Ls_Routine_TEXT, '') + ' ' + @As_Proc_NAME + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@Ls_ErrorMesg_TEXT, '');

       RAISERROR(50001,16,1)
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE=@Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = ISNULL(@As_DescriptionError_TEXT, ' ') + ' ' + 'Error IN ' + ISNULL(ERROR_PROCEDURE(), 'BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROC') + ' PROCEDURE' + '. Error DESC - ' + ISNULL(@Ls_ErrorMesg_TEXT, '') + '. Error EXECUTE Location - ' + ISNULL(@Ls_Sql_TEXT, ' ') + '. Error List KEY - ' + ISNULL(@Ls_Sqldata_TEXT, ' ');
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROC') + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT =@Ls_Err_Description_TEXT;
  END CATCH
 END


GO
