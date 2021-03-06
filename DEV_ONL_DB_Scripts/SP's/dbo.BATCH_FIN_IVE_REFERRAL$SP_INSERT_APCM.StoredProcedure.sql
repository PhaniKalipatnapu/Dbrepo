/****** Object:  StoredProcedure [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM
Programmer Name		 : IMP Team
Description			 : The procedure inserts application case member records into the application case member table.
Frequency			 : Daily
Developed On		 : 11/02/2011
Called By			 : 
Called On			 : BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
------------------------------------------------------------------------------------------------------------------------
Modified By			 :
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_FIN_IVE_REFERRAL$SP_INSERT_APCM]
 @An_Application_IDNO             NUMERIC(15),
 @An_MemberMci_IDNO               NUMERIC(10),
 @Ac_CaseRelationship_CODE        CHAR(1),
 @Ac_CreateMemberMci_CODE         CHAR(1),
 @Ac_CpRelationshipToChild_CODE   CHAR(3),
 @Ac_CpRelationshipToNcp_CODE     CHAR(3),
 @Ac_NcpRelationshipToChild_CODE  CHAR(3),
 @Ac_DescriptionRelationship_TEXT CHAR(30),
 @Ad_BeginValidity_DATE           DATE,
 @Ad_EndValidity_DATE             DATE,
 @Ad_Update_DTTM                  DATETIME2,
 @Ac_WorkerUpdate_ID              CHAR(10),
 @An_TransactionEventSeq_NUMB     NUMERIC(19),
 @An_OthpAtty_IDNO                NUMERIC(9),
 @Ac_Applicant_CODE               CHAR(1),
 @Ac_AttyComplaint_INDC           CHAR(1),
 @Ad_FamilyViolence_DATE          DATE,
 @Ac_FamilyViolence_INDC          CHAR(1),
 @Ac_TypeFamilyViolence_CODE      CHAR(2),
 @Ac_Msg_CODE                     CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT        VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_StatusFailed_CODE		CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE		CHAR(1) = 'S',
           @Ls_Procedure_NAME			VARCHAR(60) = 'SP_PROCESS_INSERT_APCM';
  DECLARE  @Ln_Zero_NUMB				NUMERIC(1) = 0,
           @Ln_Error_NUMB				NUMERIC(11),
           @Ln_ErrorLine_NUMB			NUMERIC(11),
           @Li_RowCount_QNTY			SMALLINT,
           @Lc_Space_TEXT				CHAR(1) = ' ',
           @Lc_Exception_CODE			CHAR(1) = '',
           @Ls_Sql_TEXT					VARCHAR(100),
           @Ls_Sqldata_TEXT				VARCHAR(1000),
           @Ls_DescriptionError_TEXT	VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT		VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = ' ';
   SET @As_DescriptionError_TEXT = '';
   SET @Lc_Exception_CODE = '';
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sql_TEXT = 'SELECT FROM APCM_Y1 TABLE ';
   SET @Ls_Sqldata_TEXT = 'APPLICATION IDNO = ' + CAST(@An_Application_IDNO AS VARCHAR(15)) + ', MEMBERMCI IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10));

   INSERT INTO APCM_Y1
               (Application_IDNO,
                MemberMci_IDNO,
                CaseRelationship_CODE,
                CreateMemberMci_CODE,
                CpRelationshipToChild_CODE,
                CpRelationshipToNcp_CODE,
                NcpRelationshipToChild_CODE,
                DescriptionRelationship_TEXT,
                BeginValidity_DATE,
                EndValidity_DATE,
                Update_DTTM,
                WorkerUpdate_ID,
                TransactionEventSeq_NUMB,
                OthpAtty_IDNO,
                Applicant_CODE,
                AttyComplaint_INDC,
                FamilyViolence_DATE,
                FamilyViolence_INDC,
                TypeFamilyViolence_CODE)
        VALUES( @An_Application_IDNO, -- Application_IDNO
                @An_MemberMci_IDNO, -- MemberMci_IDNO
                ISNULL(@Ac_CaseRelationship_CODE, @Lc_Space_TEXT), -- CaseRelationship_CODE
                ISNULL(@Ac_CreateMemberMci_CODE, @Lc_Space_TEXT), --CreateMemberMci_CODE
                ISNULL(@Ac_CpRelationshipToChild_CODE, @Lc_Space_TEXT), -- CpRelationshipToChild_CODE
                ISNULL(@Ac_CpRelationshipToNcp_CODE, @Lc_Space_TEXT), -- CpRelationshipToNcp_CODE
                ISNULL(@Ac_NcpRelationshipToChild_CODE, @Lc_Space_TEXT), -- NcpRelationshipToChild_CODE
                ISNULL(@Ac_DescriptionRelationship_TEXT, @Lc_Space_TEXT), -- DescriptionRelationship_TEXT
                @Ad_BeginValidity_DATE, -- BeginValidity_DATE
                @Ad_EndValidity_DATE, -- EndValidity_DATE
                @Ad_Update_DTTM, -- Update_DTTM
                @Ac_WorkerUpdate_ID, --WorkerUpdate_ID
                @An_TransactionEventSeq_NUMB, --TransactionEventSeq_NUMB 
                @An_OthpAtty_IDNO, -- OthpAtty_IDNO
                ISNULL(@Ac_Applicant_CODE, @Lc_Space_TEXT), -- Applicant_CODE
                ISNULL(@Ac_AttyComplaint_INDC, @Lc_Space_TEXT), -- AttyComplaint_INDC
                @Ad_FamilyViolence_DATE, -- FamilyViolence_DATE
                ISNULL(@Ac_FamilyViolence_INDC, @Lc_Space_TEXT), -- FamilyViolence_INDC
                ISNULL(@Ac_TypeFamilyViolence_CODE, @Lc_Space_TEXT)); --TypeFamilyViolence_CODE

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = @Ln_Zero_NUMB
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'APCM_Y1 INSERT FAILED ';

     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   --Set Error Description
   SET @Ls_ErrorMessage_TEXT = @As_DescriptionError_TEXT;
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
