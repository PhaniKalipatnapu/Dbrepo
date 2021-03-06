/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT
Programmer Name		 : IMP Team
Description			 : The procedure inserts/creates the audit details
                       for the records submited to FCR by old system. 
Frequency			 : Daily
Developed On		 : 04/07/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_CASE_ACK_DETAILS
					   BATCH_LOC_INCOMING_FCR$SP_PERSON_ACK_DETAILS
Called On			 : 
-----------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_INSERT_FADT]
 @An_Case_IDNO             NUMERIC(6),
 @An_MemberMci_IDNO        NUMERIC(10),
 @Ac_Action_CODE           CHAR(1),
 @Ac_TypeTrans_CODE        CHAR(2),
 @Ac_TypeCase_CODE         CHAR(1),
 @An_County_IDNO           NUMERIC(3),
 @Ac_Order_INDC            CHAR(1),
 @An_MemberSsn_NUMB        NUMERIC(9),
 @Ad_Birth_DATE            DATE,
 @Ac_Last_NAME             CHAR(20),
 @Ac_First_NAME            CHAR(16),
 @An_Batch_NUMB            NUMERIC(6),
 @Ac_TypeParticipant_CODE  CHAR(2),
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT                      CHAR(1) = ' ',
           @Lc_CaseStatusOpen_CODE             CHAR(1) = 'O',
           @Lc_CaseStatusClosed_CODE           CHAR(1) = 'C',
           @Lc_StatusCaseMemberActive_CODE     CHAR(1) = 'A',
           @Lc_CaseTypeNonIvd_CODE             CHAR(1) = 'H',
           @Lc_RelationshipCaseNcp_TEXT        CHAR(1) = 'A',
           @Lc_RelationshipCaseCp_TEXT         CHAR(1) = 'C',
           @Lc_RelationshipCaseDp_TEXT         CHAR(1) = 'D',
           @Lc_RelationshipCasePutFather_TEXT  CHAR(1) = 'P',
           @Lc_StatusFailed_CODE               CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE              CHAR(1) = 'S',
           @Lc_ActionAdd_CODE                  CHAR(1) = 'A',
           @Lc_ActionChange_CODE               CHAR(1) = 'C',
           @Lc_ActionDelete_CODE               CHAR(1) = 'D',
           @Lc_StatusCaseMemberClose_CODE      CHAR(1) = 'I',
           @Lc_FcrCaseTypeIvd_CODE             CHAR(1) = 'F',
           @Lc_TypeCaseIvd_CODE                CHAR(1) = 'F',
           @Lc_FcrCaseTypeNonIvd_CODE          CHAR(1) = 'N',
           @Lc_RecCaseAcknowledgement_CODE     CHAR(2) = 'FD',
           @Lc_RecPersonAcknowledgement_CODE   CHAR(2) = 'FS',
           @Lc_FcrParticipantNcp_CODE          CHAR(2) = 'NP',
           @Lc_FcrParticipantCp_CODE           CHAR(2) = 'CP',
           @Lc_FcrParticipantDp_CODE           CHAR(2) = 'CH',
           @Lc_FcrParticipantPf_CODE           CHAR(2) = 'PF',
           @Ls_Procedure_NAME                  VARCHAR(60) = 'SP_INSERT_FADT',
           @Ld_Low_DATE                        DATE = '01/01/0001';
  DECLARE  @Ln_Exists_NUMB                     NUMERIC(1) = 0,
		   @Ln_County_IDNO					   NUMERIC(3),
           @Ln_Error_NUMB					   NUMERIC(11),
           @Ln_ErrorLine_NUMB				   NUMERIC(11),
           @Li_RowCount_QNTY				   SMALLINT,
           @Lc_Exception_CODE				   CHAR(1) = '',
           @Lc_StatusCase_CODE                 CHAR(1),
           @Lc_StatusMember_CODE               CHAR(1),
           @Ls_Sql_TEXT						   VARCHAR(100),
           @Ls_Sqldata_TEXT                    VARCHAR(1000),
           @Ls_DescriptionError_TEXT           VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT               VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = ' ';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Exception_CODE = '';
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;

   IF @Ac_TypeTrans_CODE = @Lc_RecCaseAcknowledgement_CODE
    BEGIN
     SET @Ls_Sql_TEXT = 'CHECK FOR THE EXISTANCE OF CASE IN CASE_Y1';
     SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), 0);
     
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CASE_Y1 c
      WHERE c.Case_IDNO = @An_Case_IDNO;

     IF @Ln_Exists_NUMB = 0
      BEGIN
       SET @Ls_DescriptionError_TEXT = 'Case_IDNO NOT FOUND IN CASE_Y1';
       SET @Lc_Exception_CODE = 'N';

       GOTO lx_exception;
      
      END

     IF @Ac_Action_CODE IN (@Lc_ActionAdd_CODE, @Lc_ActionChange_CODE)
      BEGIN
       SET @Lc_StatusCase_CODE = @Lc_CaseStatusOpen_CODE;
      END
     ELSE IF @Ac_Action_CODE = @Lc_ActionDelete_CODE
      BEGIN
       SET @Lc_StatusCase_CODE = @Lc_CaseStatusClosed_CODE;
      END
     ELSE
      BEGIN
       SET @Lc_StatusCase_CODE = @Lc_CaseStatusOpen_CODE;
      END

     SET @Ln_County_IDNO = @An_County_IDNO;
    END
   ELSE
    BEGIN
     IF @Ac_TypeTrans_CODE = @Lc_RecPersonAcknowledgement_CODE
      BEGIN
       SET @Ls_Sql_TEXT = 'CHECK FOR THE EXISTANCE OF MEMBER IN CMEM_Y1';
       SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR (10)), 0);
       
       SELECT @Ln_Exists_NUMB = COUNT(1)
         FROM CMEM_Y1 c
        WHERE c.Case_IDNO = @An_Case_IDNO
          AND c.MemberMci_IDNO = @An_MemberMci_IDNO;

       IF @Ln_Exists_NUMB = 0
        BEGIN
         
         SET @Ls_ErrorMessage_TEXT = 'MEMBER NOT FOUND IN CMEM_Y1';
         SET @Lc_Exception_CODE = 'N';

         GOTO lx_exception;
        END

       IF @Ac_Action_CODE IN (@Lc_ActionAdd_CODE, @Lc_ActionChange_CODE)
        BEGIN
         SET @Lc_StatusMember_CODE = @Lc_StatusCaseMemberActive_CODE;
        END
       ELSE
        BEGIN
         IF @Ac_Action_CODE = @Lc_ActionDelete_CODE
          BEGIN
           SET @Lc_StatusMember_CODE = @Lc_StatusCaseMemberClose_CODE;
          END
         ELSE
          BEGIN
           SET @Lc_StatusMember_CODE = @Lc_StatusCaseMemberActive_CODE;
          END
        END
      END
     ELSE
      BEGIN
       RETURN;
      END
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO FADT_Y1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO = ' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR(6)), 0) + ', MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR (10)), 0);
  
   INSERT FADT_Y1
          (Case_IDNO,
           MemberMci_IDNO,
           Action_CODE,
           TypeTrans_CODE,
           Transmitted_DATE,
           TypeCase_CODE,
           StatusCase_CODE,
           County_IDNO,
           Order_INDC,
           MemberSsn_NUMB,
           Birth_DATE,
           Last_NAME,
           First_NAME,
           CaseRelationship_CODE,
           CaseMemberStatus_CODE,
           Batch_NUMB,
           Response_DATE,
           ResponseFcr_CODE)
   VALUES ( @An_Case_IDNO, -- Case_IDNO
            @An_MemberMci_IDNO, -- MemberMci_IDNO
            @Ac_Action_CODE,		-- Action_CODE
            @Ac_TypeTrans_CODE,	-- TypeTrans_CODE
            @Ld_Low_DATE,		-- Transmitted_DATE
            CASE @Ac_TypeCase_CODE
             WHEN @Lc_FcrCaseTypeIvd_CODE
              THEN @Lc_TypeCaseIvd_CODE
             WHEN @Lc_FcrCaseTypeNonIvd_CODE
              THEN @Lc_CaseTypeNonIvd_CODE
             ELSE @Lc_Space_TEXT
            END, -- TypeCase_CODE
            ISNULL(@Lc_StatusCase_CODE, @Lc_Space_TEXT), -- StatusCase_CODE
            ISNULL(@Ln_County_IDNO, 0), -- County_IDNO
            ISNULL(@Ac_Order_INDC, @Lc_Space_TEXT), -- Order_INDC
            ISNULL(@An_MemberSsn_NUMB, 0), -- MemberSsn_NUMB
            ISNULL(@Ad_Birth_DATE, @Ld_Low_DATE), -- Birth_DATE
            ISNULL(@Ac_Last_NAME, @Lc_Space_TEXT), -- Last_NAME
            ISNULL(@Ac_First_NAME, @Lc_Space_TEXT), -- First_NAME
            CASE @Ac_TypeParticipant_CODE
             WHEN @Lc_FcrParticipantNcp_CODE
              THEN @Lc_RelationshipCaseNcp_TEXT
             WHEN @Lc_FcrParticipantCp_CODE
              THEN @Lc_RelationshipCaseCp_TEXT
             WHEN @Lc_FcrParticipantDp_CODE
              THEN @Lc_RelationshipCaseDp_TEXT
             WHEN @Lc_FcrParticipantPf_CODE
              THEN @Lc_RelationshipCasePutFather_TEXT
             ELSE @Lc_Space_TEXT
            END, -- CaseRelationship_CODE
            ISNULL(@Lc_StatusMember_CODE, @Lc_Space_TEXT), -- CaseMemberStatus_CODE
            @An_Batch_NUMB, -- Batch_NUMB
            @Ld_Low_DATE,	-- Response_DATE
            @Lc_Space_TEXT); -- ResponseFcr_CODE

   SET @Li_RowCount_QNTY = @@ROWCOUNT;

   IF @Li_RowCount_QNTY = 0
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'INSERT INTO FADT_Y1 FAILED';

     RAISERROR(50001,16,1);
    END

   -- Set the status code to success and error description to spaces
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;

   LX_EXCEPTION:;

   IF @Lc_Exception_CODE = 'N'
    BEGIN
     SET @Ac_Msg_CODE = @Lc_Exception_CODE;
     SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
    END
  END TRY

  BEGIN CATCH
   --Set Error Description
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
 
  END CATCH
 END


GO
