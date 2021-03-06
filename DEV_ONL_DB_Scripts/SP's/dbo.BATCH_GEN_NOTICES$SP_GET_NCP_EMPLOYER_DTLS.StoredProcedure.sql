/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get NCP employer details from EHIS_Y1
Frequency		:	
Developed On	:	5/10/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_DTLS](
 @An_MemberMci_IDNO			NUMERIC(10),
 @An_OtherParty_IDNO		NUMERIC(10),
 @Ac_ActivityMajor_CODE		CHAR(4),
 @Ad_Run_DATE				DATETIME2,
 @Ac_Msg_CODE				CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT	VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Li_Zero_NUMB				 SMALLINT = 0,
		  @Lc_StatusYes_CODE		 CHAR(1) = 'Y',
		  @Lc_PrefixNcp_TEXT		 CHAR(3)  = 'NCP',
		  @Lc_PrefixNcpEmp_TEXT		 CHAR(7)  = 'NCP_EMP',
		  @Lc_ActivityMajorCrim_CODE CHAR(4)  = 'CRIM',
		  @Lc_ActivityMajorEstp_CODE CHAR(4)  = 'ESTP',
		  @Lc_ActivityMajorLien_CODE CHAR(4)  = 'LIEN',
		  @Lc_ActivityMajorMapp_CODE CHAR(4)  = 'MAPP',
		  @Lc_ActivityMajorPsoc_CODE CHAR(4)  = 'PSOC',
		  @LC_NoticeEnf17_ID		 CHAR(8)  ='ENF-17';
  DECLARE @Lc_StatusFailed_CODE		 CHAR(1),
          @Lc_StatusSuccess_CODE	 CHAR(1),
          @Lc_Notice_ID              CHAR(8),
          @Ls_Routine_TEXT			 VARCHAR(75),
          @Ls_Sql_TEXT				 VARCHAR(200),
          @Ls_Sqldata_TEXT			 VARCHAR(400);
          
  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Routine_TEXT = 'BATCH_GEN_NOTICES$SP_GET_NCP_EMPLOYER_DTLS';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SF_GETNCPMEMBERFORACTIVECASE';
   SET @Ls_Sqldata_TEXT = 'NcpMemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '');

	SELECT @Lc_Notice_ID = Element_VALUE  
	FROM #NoticeElementsData_P1
	WHERE Element_Name = 'Notice_ID'
	
   IF @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorCrim_CODE, @Lc_ActivityMajorEstp_CODE, @Lc_ActivityMajorLien_CODE, @Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorPsoc_CODE)
    BEGIN
     SET @An_OtherParty_IDNO = @Li_Zero_Numb;
	END
     IF		@An_MemberMci_IDNO > 0 
		AND (	 @An_OtherParty_IDNO = @Li_Zero_Numb
			  OR @An_OtherParty_IDNO IS NULL
			)
      BEGIN
      -- ENF-17 Criminal Non Support field mapping Fix - Start
      IF @Lc_Notice_ID = @LC_NoticeEnf17_ID 
      BEGIN
		 SELECT @An_OtherParty_IDNO = a.OthpPartyEmpl_IDNO FROM 
			(SELECT e.OthpPartyEmpl_IDNO,ROW_NUMBER() OVER(PARTITION BY e.MemberMci_IDNO ORDER BY e.EndEmployment_DATE DESC,e.BeginEmployment_DATE DESC) AS RowNum  
				FROM  EHIS_Y1 e
			 WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO AND e.Status_CODE = @Lc_StatusYes_CODE) a
			WHERE RowNum = 1
      END
      ELSE
      BEGIN
       SELECT TOP 1 @An_OtherParty_IDNO = e.OthpPartyEmpl_IDNO
         FROM EHIS_Y1 e
        WHERE e.MemberMci_IDNO = @An_MemberMci_IDNO
          AND (@Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE)				
	      AND e.Status_CODE = @Lc_StatusYes_CODE
          AND e.BeginEmployment_DATE = (SELECT MAX(eh.BeginEmployment_DATE)
                                        FROM EHIS_Y1 eh
                                       WHERE eh.MemberMci_IDNO = @An_MemberMci_IDNO
                                         AND (@Ad_Run_DATE BETWEEN eh.BeginEmployment_DATE AND eh.EndEmployment_DATE)												
                                         AND eh.Status_CODE = @Lc_StatusYes_CODE);
	  END                                         
      -- ENF-17 Criminal Non Support field mapping Fix - End
      END

   IF @An_OtherParty_IDNO != @Li_Zero_Numb
      AND @An_OtherParty_IDNO IS NOT NULL
    BEGIN
     EXECUTE BATCH_GEN_NOTICES$SP_GET_EHIS_DETAILS
      @An_MemberMci_IDNO        = @An_MemberMci_IDNO,
      @An_OtherParty_IDNO       = @An_OtherParty_IDNO,
      @Ad_Run_DATE              = @Ad_Run_DATE,
      @As_Prefix_TEXT           = @Lc_PrefixNcp_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @An_OtherParty_IDNO IS NOT NULL
        AND @An_OtherParty_IDNO != 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1';
       SET @Ls_Sqldata_TEXT = ' OtherParty_IDNO = ' + ISNULL(CAST(@An_OtherParty_IDNO AS VARCHAR), '');

       EXEC BATCH_GEN_NOTICE_CM$SP_GET_OTHP_DTLS
        @An_OtherParty_IDNO       = @An_OtherParty_IDNO,
        @As_Prefix_TEXT           = @Lc_PrefixNcpEmp_TEXT,
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
         BEGIN
           RETURN;
         END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   
 DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Sql_TEXT,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
