/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_NCP_DETAILS
Programmer Name	:	IMP Team.
Description		:	This procedure is used to get NCP details from DEMO_Y1
Frequency		:	
Developed On	:	2/17/2012
Called By		:	BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NCP_DETAILS] (
 @An_Case_IDNO			   NUMERIC(6),
 @An_NcpMemberMci_IDNO     NUMERIC(10),
 @An_MemberMci_IDNO		   NUMERIC(10),
 @Ac_ActivityMajor_CODE    CHAR(4),
 @An_OtherParty_IDNO       NUMERIC(10),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS 
  BEGIN
  SET NOCOUNT ON;
  DECLARE @Lc_StatusFailed_CODE				CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
          @Lc_CaseMemberStatusActive_CODE	CHAR(1) = 'A',
          @Lc_CaseRelationshipPf_CODE		CHAR(1) = 'P',
          @Lc_CaseRelationshipNcp_CODE		CHAR(1) = 'A',
          @Lc_ActivityMajorESTP_CODE		CHAR(4) = 'ESTP',
          @Lc_ActivityMajorROFO_CODE		CHAR(4) = 'ROFO',
          @Lc_ActivityMajorAren_CODE		CHAR(4) = 'AREN',
		  @Lc_ActivityMajorCsln_CODE		CHAR(4) = 'CSLN',
		  @Lc_ActivityMajorFidm_CODE		CHAR(4) = 'FIDM',
		  @Lc_ActivityMajorLien_CODE		CHAR(4) = 'LIEN',
		  @Lc_ActivityMajorImiw_CODE		CHAR(4) = 'IMIW',
		  @Lc_ActivityMajorNmsn_CODE		CHAR(4) = 'NMSN',
		  @Lc_ActivityMajorGtst_CODE		CHAR(4) = 'GTST', 
		  @Lc_ActivityMajorMapp_CODE		CHAR(4) = 'MAPP', 
		  @Lc_ActivityMajorObra_CODE		CHAR(4) = 'OBRA', 
		  @Lc_ActivityMajorVapp_CODE		CHAR(4) = 'VAPP',
		  @Lc_ActivityMajorCase_CODE		CHAR(4) = 'CASE',
		  @Lc_ActivityMajorLsnr_CODE		CHAR(4) = 'LSNR',
		  @Lc_ActivityMajorCpls_CODE		CHAR(4) = 'CPLS',
          @Lc_PrefixNCP_TEXT				CHAR(5) = 'NCP',
          @Ls_Procedure_NAME				VARCHAR(75) = 'BATCH_GEN_NOTICES$SP_GET_NCP_DETAILS';
  DECLARE @Ln_MemberMci_IDNO				NUMERIC(10) = 0,
          @Ls_Sql_TEXT						VARCHAR(100),
          @Ls_Sqldata_TEXT					VARCHAR(200),
          @Ls_Err_Description_TEXT			VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   SELECT @Ln_MemberMci_IDNO = CASE
                                WHEN @Ac_ActivityMajor_CODE = @Lc_ActivityMajorROFO_CODE
                                 THEN @An_MemberMci_IDNO
                                WHEN @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorAren_CODE,@Lc_ActivityMajorCsln_CODE,@Lc_ActivityMajorFidm_CODE,@Lc_ActivityMajorLien_CODE,@Lc_ActivityMajorImiw_CODE,@Lc_ActivityMajorNmsn_CODE ) --!= @Lc_ActivityMajorESTP_CODE
                                 THEN @An_NcpMemberMci_IDNO
                                WHEN @Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorGtst_CODE, @Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorObra_CODE, @Lc_ActivityMajorVapp_CODE) 
									 AND (SELECT COUNT(1)
											FROM CMEM_Y1
										   WHERE MemberMci_IDNO = @An_OtherParty_IDNO
											 AND Case_IDNO = @An_Case_IDNO
										     AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
										     AND CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)) = 0
								 THEN @An_MemberMci_IDNO
								WHEN @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE AND @An_OtherParty_IDNO IS NOT NULL AND @An_OtherParty_IDNO != 0
									 AND (SELECT COUNT(1)
											FROM CMEM_Y1
										   WHERE MemberMci_IDNO = @An_OtherParty_IDNO
											 AND Case_IDNO = @An_Case_IDNO
										     AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
										     AND CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)) != 0
								 THEN @An_OtherParty_IDNO
								WHEN @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE AND @An_NcpMemberMci_IDNO IS NOT NULL AND @An_NcpMemberMci_IDNO != 0
								 THEN @An_NcpMemberMci_IDNO
								 --13383 - CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix -Start
								WHEN @Ac_ActivityMajor_CODE IN(@Lc_ActivityMajorCase_CODE,@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE) AND @An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO != 0
									 AND (SELECT COUNT(1)
											FROM CMEM_Y1
										   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
										     AND Case_IDNO = @An_Case_IDNO
										     AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
										     AND CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)) != 0
								 THEN @An_MemberMci_IDNO
								 --13383 - CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix -End
								WHEN @Ac_ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE AND @An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO != 0
									 AND (SELECT COUNT(1)
											FROM CMEM_Y1
										   WHERE MemberMci_IDNO = @An_MemberMci_IDNO
										     AND Case_IDNO = @An_Case_IDNO
										     AND CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
										     AND CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)) = 0
								 THEN (SELECT TOP 1 MemberMci_IDNO
										FROM CMEM_Y1
									   WHERE CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
									     AND CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
									     AND Case_IDNO = @An_Case_IDNO)
                                ELSE @An_OtherParty_IDNO
                               END;

   IF ((@Ln_MemberMci_IDNO IS NOT NULL)
       AND @Ln_MemberMci_IDNO > 0)
    BEGIN
    
    SET @Ls_Sqldata_TEXT = 'Ln_MemberMci_IDNO = ' + CAST(@Ln_MemberMci_IDNO AS VARCHAR(10));

    /*Before generating Notice check NCP in active for the case*/
    IF ISNULL((SELECT 1 
		FROM  CMEM_Y1 c
		 WHERE  c.Case_IDNO = @An_Case_IDNO
			AND c.MemberMci_IDNO = @Ln_MemberMci_IDNO
			AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
			AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)),0) = 0
		BEGIN 
			  SET @Ls_Sql_TEXT = 'NCP/PF NOT ACTIVE';
			  RAISERROR(50001,16,1);
		END
    
    
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS';     

     EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS
      @An_MemberMci_IDNO        = @Ln_MemberMci_IDNO,
      @As_Prefix_TEXT           = @Lc_PrefixNCP_TEXT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT = ERROR_NUMBER (),
           @Li_ErrorLine_NUMB INT = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_Err_Description_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_Err_Description_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
