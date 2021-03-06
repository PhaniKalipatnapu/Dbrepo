/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Program Name		: BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_CODE_LIST
Programmer Name		: IMP Team.
Description			: The procedure BATCH_GEN_NOTICE_UTIL$GET_RECIPIENT_CODE_LIST gets Recipeint code list related to Notice
Frequency			: 
Developed On		: 03/22/2011
Called BY			: 
Called On	: 
---------------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST](
 @An_Case_IDNO              NUMERIC(6),
 @An_MemberMci_IDNO			NUMERIC(10)		= NULL,
 @Ac_Notice_ID              CHAR(8),
 @An_OthpSource_IDNO        NUMERIC(10)		= 0,
 @Ac_ActivityMajor_CODE     CHAR(4),
 @Ac_ActivityMinor_CODE     CHAR(5)			= NULL,
 @Ac_ReasonStatus_CODE      CHAR(2),
 @Ac_StatusApproval_CODE    CHAR(1),
 @An_MajorIntSeq_NUMB       NUMERIC(5),
 @Ac_IvdOutOfStateFips_CODE CHAR(7)			= NULL,
 @Ac_Receipt_ID				CHAR(27)		= NULL,
 @Ac_RecipentType_ID		CHAR(1)			= NULL,
 @Ac_Msg_CODE               CHAR(5)			OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000)	OUTPUT
 )
AS
 CREATE TABLE #NoticeRecipients_P1
  (
    Recipient_ID     CHAR(10),
    Recipient_NAME   VARCHAR(60),
    Recipient_CODE   VARCHAR(4),
    PrintMethod_CODE CHAR(1),
    TypeService_CODE CHAR(1)
  )
 
 DECLARE @Lc_StatusSuccess_CODE          CHAR(1)		= 'S',
         @Lc_StatusFailed_CODE           CHAR(1)		= 'F',
         @Lc_StatusApproval_CODE         CHAR(1)		= 'I',
         @Lc_Empty_TEXT					 CHAR(1)		= '',
         @Lc_NcpRecipentType_ID			 CHAR(1)		= 'A',
         @Lc_CpRecipentType_ID			 CHAR(1)		= 'C',
         @Lc_BothRecipentType_ID		 CHAR(1)		= 'B',
         @Lc_Yes_INDC					 CHAR(1)		= 'Y',	
         @Lc_TypeAddrZ_CODE				 CHAR(1)        = 'Z',
         @Lc_TypeAddrV_CODE				 CHAR(1)        = 'V',
         @Lc_No_INDC					 CHAR(1)		= 'N',
         @Lc_RecipientSi_CODE			 CHAR(2)		= 'SI',	
         @Lc_RecipientOe_CODE			 CHAR(2)		= 'OE',
         @Lc_ActivityMajorCase_CODE		 CHAR(4)		= 'CASE',
         @Lc_TableEiwo_ID				 CHAR(4)		= 'EIWO',
         @Lc_TableSubSkip_ID			 CHAR(4)		= 'SKIP',
         @Lc_NoticeFin07_ID				 CHAR(8)		= 'FIN-07',
         @Lc_NoticeEnf01_ID				 CHAR(8)		= 'ENF-01',
         @Lc_NoticeEnf03_ID			     CHAR(8)		= 'ENF-03',
         @Ls_Routine_TEXT                VARCHAR(75)	= 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST',
         @Ld_High_DATE                   DATE			= '12/31/9999';
 DECLARE
         @Lc_CheckRecipient_ID			 VARCHAR(10),
		 @Lc_CheckRecipient_CODE		 CHAR(1),
		 @Ls_Proc_NAME                   VARCHAR(75),
         @Ls_Sql_TEXT                    VARCHAR(100)	= '',
         @Ls_Sqldata_TEXT                VARCHAR(1000)	= '',
         @Ls_Err_Description_TEXT        VARCHAR(4000)	= '',
         @Ls_sqlString_TEXT              NVARCHAR(MAX),
         @Ls_SQLProcParameterString_TEXT NVARCHAR(MAX),
         @SQLProcParameterStringLOC_TEXT NVARCHAR(MAX),
         @Ls_ParmDefinition_TEXT         NVARCHAR(MAX);
       
 DECLARE
		@Get_Recipient_CUR					CURSOR,
		@Lc_RecipientCur_CODE				CHAR(2), 
		@Lc_RecipientCur_PrintMethod_CODE	CHAR(1), 
		@Lc_RecipienCur_TypeService_CODE	CHAR(1);

 BEGIN
  BEGIN TRY
   IF @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE OR (@Ac_ActivityMajor_CODE = '' AND @Ac_Notice_ID = 'CSI-13')
    BEGIN
     SET @Get_Recipient_CUR = CURSOR
     FOR SELECT Recipient_CODE,
                CASE
                 WHEN @Ac_StatusApproval_CODE = @Lc_StatusApproval_CODE
                  THEN @Lc_StatusApproval_CODE
                 ELSE a.PrintMethod_CODE
                END AS print_method,
                a.TypeService_CODE AS type_service
           FROM NREP_Y1 a
          WHERE a.Notice_ID = @Ac_Notice_ID
            AND a.EndValidity_DATE = @Ld_High_DATE
            AND ((@Ac_Notice_ID = @Lc_NoticeFin07_ID AND @Ac_RecipentType_ID  =@Lc_NcpRecipentType_ID AND Recipient_CODE IN ('MN')) OR
				  (@Ac_Notice_ID = @Lc_NoticeFin07_ID AND @Ac_RecipentType_ID  =@Lc_CpRecipentType_ID AND Recipient_CODE IN ('MC')) OR
				   (@Ac_Notice_ID = @Lc_NoticeFin07_ID AND @Ac_RecipentType_ID  =@Lc_BothRecipentType_ID AND Recipient_CODE IN ('MN','MC')) OR
				 @Ac_Notice_ID <> @Lc_NoticeFin07_ID);
    END
   ELSE IF ISNUMERIC(@Ac_Notice_ID) = 0
    BEGIN
     SET @Get_Recipient_CUR = CURSOR
     FOR SELECT Recipient_CODE,
                CASE
                 WHEN @Ac_StatusApproval_CODE = @Lc_StatusApproval_CODE
                  THEN @Lc_StatusApproval_CODE
                 ELSE a.PrintMethod_CODE
                END AS print_method,
                a.TypeService_CODE AS type_service
           FROM AFMS_Y1 a
          WHERE a.Notice_ID = @Ac_Notice_ID
            AND a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
            AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
            AND a.Reason_CODE = @Ac_ReasonStatus_CODE
            AND a.EndValidity_DATE = @Ld_High_DATE
            -- Defect 13263 - CR0365 e-IWO Notice to NCP 20140217 Fix - Start --
            AND ( a.Notice_ID != @Lc_NoticeEnf01_ID
				  OR a.Recipient_CODE != @Lc_RecipientSi_CODE
				  OR NOT EXISTS (SELECT 1
									 FROM OTHP_Y1 o
									WHERE o.OtherParty_IDNO = @An_OthpSource_IDNO
									  AND o.EndValidity_DATE = @Ld_High_DATE
									  AND o.Eiwn_INDC = @Lc_Yes_INDC
									  AND EXISTS ( SELECT 1
													 FROM REFM_Y1 r
													WHERE r.Table_ID = @Lc_TableEiwo_ID
													  AND r.TableSub_ID = @Lc_TableSubSkip_ID
													  AND r.DescriptionValue_TEXT = @Lc_No_INDC)));
			-- Defect 13263 - CR0365 e-IWO Notice to NCP 20140217 Fix - End --
    END
   -- Scanned Documents
   ELSE IF ISNUMERIC(@Ac_Notice_ID) != 0
	BEGIN
	 SET @Get_Recipient_CUR = CURSOR FOR
	 SELECT Recipient_CODE,
			PrintMethod_CODE AS print_method,
			TypeService_CODE AS type_service
	   FROM AFMS_Y1
	  WHERE ActivityMajor_CODE = @Ac_ActivityMajor_CODE
		AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
		AND Reason_CODE = @Ac_ReasonStatus_CODE
		AND EndValidity_DATE = @Ld_High_DATE
		AND Notice_ID = '';
	 
	END

   OPEN @Get_Recipient_CUR

   FETCH NEXT FROM @Get_Recipient_CUR INTO @Lc_RecipientCur_CODE, @Lc_RecipientCur_PrintMethod_CODE, @Lc_RecipienCur_TypeService_CODE;

   WHILE @@FETCH_STATUS = 0
    BEGIN
	
     SET @Ls_Proc_NAME=(SELECT Procedure_NAME
                          FROM NRPM_Y1
                         WHERE Recipient_CODE = @Lc_RecipientCur_CODE);
		
     IF @Ls_Proc_NAME IS NOT NULL
         AND @Ls_Proc_NAME <> ''
      BEGIN
      
      --13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - Start
	   SELECT @An_OthpSource_IDNO = CAST(O.AddrOthp_IDNO  AS NUMERIC(10))
					FROM OTHX_Y1 O
					WHERE O.OtherParty_IDNO  = @An_OthpSource_IDNO     
					AND O.EndValidity_DATE = @Ld_High_Date
					AND ((O.TypeAddr_CODE = @Lc_TypeAddrZ_CODE 
							AND @Ac_Notice_ID = @Lc_NoticeEnf01_ID 
							AND @Lc_RecipientCur_CODE = @Lc_RecipientSi_CODE) 
						OR (O.TypeAddr_CODE = @Lc_TypeAddrV_CODE 
							AND @Ac_Notice_ID = @Lc_NoticeEnf03_ID 
							AND @Lc_RecipientCur_CODE = @Lc_RecipientOe_CODE))
	  --13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - Start					
					
	   	
       EXEC BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROCEDURES
        @As_Proc_NAME              = @Ls_Proc_NAME,
        @An_Case_IDNO              = @An_Case_IDNO,
        @Ac_Notice_ID			   = @Ac_Notice_ID,
        @An_MemberMci_IDNO		   = @An_MemberMci_IDNO,
        @An_OthpSource_IDNO        = @An_OthpSource_IDNO,
        @An_MajorIntSeq_NUMB       = @An_MajorIntSeq_NUMB,
        @Ac_IvdOutOfStateFips_CODE = @Ac_IvdOutOfStateFips_CODE,
        @Ac_Receipt_ID			   = @Ac_Receipt_ID,
        @Ac_Recipient_CODE         = @Lc_RecipientCur_CODE,
        @Ac_PrintMethod_CODE       = @Lc_RecipientCur_PrintMethod_CODE,
        @Ac_TYpeService_CODE       = @Lc_RecipienCur_TypeService_CODE,
        @Ac_Msg_CODE               = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT  = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
        BEGIN
         SELECT *
           FROM #NoticeRecipients_P1;

         IF @As_DescriptionError_TEXT IS NULL
             OR LTRIM(RTRIM(@As_DescriptionError_TEXT)) = ''
          BEGIN
           SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROCEDURES' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '');
          END
         ELSE
          BEGIN
           SET @As_DescriptionError_TEXT = @Ls_Routine_TEXT + ' ' + 'BATCH_GEN_NOTICE_UTIL$SP_EXEC_RECIPIENT_DETAILS_PROCEDURES' + ' ' + @Ls_Sqldata_TEXT + ' ' + @As_DescriptionError_TEXT;

           RAISERROR(50001,16,1);
          END
        END
      END

     FETCH NEXT FROM @Get_Recipient_CUR INTO @Lc_RecipientCur_CODE, @Lc_RecipientCur_PrintMethod_CODE, @Lc_RecipienCur_TypeService_CODE;
    END

   CLOSE @Get_Recipient_CUR;

   DEALLOCATE @Get_Recipient_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';

   SELECT *
     FROM #NoticeRecipients_P1;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ls_Sql_TEXT='GET RECIPIENT CODE LIST FAILED';

   IF CURSOR_STATUS ('local', '@Get_Recipient_CUR') IN (0, 1)
    BEGIN
     CLOSE @Get_Recipient_CUR

     DEALLOCATE @Get_Recipient_CUR
    END

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE(), 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST') + ' PROCEDURE' + '. Error DESC - ' + @As_DescriptionError_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_CODE_LIST') + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
