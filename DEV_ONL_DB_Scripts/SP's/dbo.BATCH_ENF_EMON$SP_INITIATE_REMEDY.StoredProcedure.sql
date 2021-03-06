/****** Object:  StoredProcedure [dbo].[BATCH_ENF_EMON$SP_INITIATE_REMEDY]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name    : BATCH_ENF_EMON$SP_INITIATE_REMEDY
Programmer Name   : IMP Team
Description       : This is used to initiate new remedy from existing Case Process Remedy
Frequency         :
Developed On      : 01/05/2012
Called BY         : BATCH_ENF_EMON$SP_SYSTEM_UPDATE
Called On		  : BATCH_ENF_ELFC$SP_INITIATE_REMEDY
--------------------------------------------------------------------------------------------------------------------
Modified BY       :
Modified On       :
Version No        : 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_EMON$SP_INITIATE_REMEDY] (
 @An_Case_IDNO                NUMERIC(6),
 @An_OrderSeq_NUMB            NUMERIC(2),
 @An_MemberMci_IDNO           NUMERIC (10),
 @Ac_Subsystem_CODE           CHAR(2),
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5) = '',
 @Ac_ReasonStatus_CODE        CHAR(2) = '',
 @Ac_TypeOthpSource_CODE      CHAR(4),
 @An_OthpSource_IDNO          NUMERIC(10),
 @Ac_TypeChange_CODE          CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_WorkerUpdate_ID          CHAR(30),
 @Ac_TypeReference_CODE       CHAR(5) = ' ',
 @Ac_Reference_ID             CHAR(30) = ' ',
 @Ad_Run_DATE                 DATE,
 @Ac_Process_ID               CHAR(10),
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB                    INT = 0,
          @Li_Count_NUMB                   INT = 0,
          @Lc_Space_TEXT                   CHAR(1) = ' ',
          @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
          @Lc_StatusFailed_CODE            CHAR(1) = 'F',
          @Lc_TypeOthpSourceNcp_CODE       CHAR(1) = 'A',
          @Lc_TypeReferenceDna_CODE		   CHAR(1) = 'S',	         
          @Lc_SubsystemCaseManagement_CODE CHAR(2) = 'CM',
          @Lc_SubsystemEstablishment_CODE  CHAR(2) = 'ES',
          @Lc_ReasonStatusCa_CODE          CHAR(2) = 'CA',
          @Lc_ReasonStatusPd_CODE          CHAR(2) = 'PD',
          @Lc_ReasonJa_CODE                CHAR(2) = 'JA',
          @Lc_ReasonVs_CODE                CHAR(2) = 'VS',
          @Lc_ActivityMajor_CODE           CHAR(4) = NULL,
          @Lc_ActivityMajorCoop_CODE       CHAR(4) = 'COOP',
          @Lc_ActivityMajorEstp_CODE       CHAR(4) = 'ESTP',
          @Lc_ActivityMajorGtst_CODE       CHAR(4) = 'GTST',
          @Lc_ActivityMajorVapp_CODE       CHAR(4) = 'VAPP',
          @Lc_ActivityMajorMapp_CODE       CHAR(4) = 'MAPP',
          @Lc_ActivityMajorCclo_CODE       CHAR(4) = 'CCLO',
          @Lc_ActivityMajorEmnp_CODE       CHAR(4) = 'EMNP',
          @Lc_ActivityMajorObra_CODE       CHAR(4) = 'OBRA',
          @Lc_StatusStart_CODE             CHAR(4) = 'STRT',
          @Lc_ActivityMinorAcces_CODE      CHAR(5) = 'ACCES',
          @Lc_ActivityMinorAlocv_CODE      CHAR(5) = 'ALOCV',
          @Lc_ActivityMinorPatde_CODE      CHAR(5) = 'PATDE',
          @Lc_ActivityMinorPetde_CODE      CHAR(5) = 'PETDE',
          @Ls_Routine_TEXT                 VARCHAR(100) = 'BATCH_ENF_EMON$SP_INITIATE_REMEDY';
  DECLARE @Li_Error_NUMB            INT,
          @Li_ErrorLine_NUMB        INT,
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Sql_TEXT              VARCHAR(300),
          @Ls_Sqldata_TEXT          VARCHAR(3000),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   
   SET @Ls_Sql_TEXT = 'SELECT DMJR_Y1,CMEM_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST(@An_Case_IDNO AS VARCHAR(6)) + ', OrderSeq_NUMB = ' + CAST(@An_OrderSeq_NUMB AS VARCHAR(2)) + ', TransactionEventSeq_NUMB = ' + CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(19)) + ', ActivityMajor_CODE = ' + @Ac_ActivityMajor_CODE + ', Subsystem_CODE = ' + @Ac_Subsystem_CODE + ', TypeOthpSource_CODE = ' + @Ac_TypeOthpSource_CODE + ', OthpSource_IDNO = ' + CAST(@An_OthpSource_IDNO AS VARCHAR(10));
   IF(@Ac_ActivityMajor_CODE IN (@Lc_ActivityMajorCclo_CODE, @Lc_ActivityMajorEmnp_CODE, @Lc_ActivityMajorObra_CODE))
    BEGIN
     SET @Lc_ActivityMajor_CODE = @Lc_ActivityMajorMapp_CODE;
     SET @Ac_TypeReference_CODE = @Ac_ActivityMajor_CODE;
    END
   ELSE IF(@Ac_ActivityMajor_CODE = @Lc_ActivityMajorVapp_CODE)
    BEGIN
     SET @Lc_ActivityMajor_CODE = @Lc_ActivityMajorGtst_CODE;
     SET @Ac_TypeReference_CODE = @Lc_TypeReferenceDna_CODE;
    END
   ELSE IF(@Ac_ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
      AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorPatde_CODE
      AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusPd_CODE)
    BEGIN
     SET @Lc_ActivityMajor_CODE = @Lc_ActivityMajorVapp_CODE;
    END
   ELSE IF((@Ac_ActivityMajor_CODE = @Lc_ActivityMajorCoop_CODE
       AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorAcces_CODE
       AND @Ac_ReasonStatus_CODE = @Lc_ReasonJa_CODE)
       OR (@Ac_ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE
           AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorPetde_CODE
           AND @Ac_ReasonStatus_CODE = @Lc_ReasonStatusCa_CODE))
    BEGIN
     SET @Ac_Subsystem_CODE = @Lc_SubsystemCaseManagement_CODE;
     SET @Lc_ActivityMajor_CODE = @Lc_ActivityMajorCclo_CODE;
     SET @Ac_TypeOthpSource_CODE = @Lc_TypeOthpSourceNcp_CODE;
     SET @An_OthpSource_IDNO = @An_MemberMci_IDNO;
    END
   ELSE IF(@Ac_ActivityMajor_CODE = @Lc_ActivityMajorCoop_CODE
      AND @Ac_ActivityMinor_CODE = @Lc_ActivityMinorAlocv_CODE
      AND @Ac_ReasonStatus_CODE = @Lc_ReasonVs_CODE)
    BEGIN
     SET @Ac_Subsystem_CODE = @Lc_SubsystemEstablishment_CODE;
     SET @Lc_ActivityMajor_CODE = @Lc_ActivityMajorEstp_CODE;
     SET @Ac_TypeOthpSource_CODE = @Lc_TypeOthpSourceNcp_CODE;
     SET @An_OthpSource_IDNO = @An_MemberMci_IDNO;
    END
	IF @Lc_ActivityMajor_CODE IN (@Lc_ActivityMajorMapp_CODE, @Lc_ActivityMajorGtst_CODE)
	BEGIN
	   SELECT @Li_Count_NUMB = COUNT(1)
		 FROM DMJR_Y1 j
		WHERE j.Case_IDNO = @An_Case_IDNO
		  AND j.OrderSeq_NUMB IN(@Li_Zero_NUMB, @An_OrderSeq_NUMB)
		  AND j.ActivityMajor_CODE = @Lc_ActivityMajor_CODE
		  AND j.OthpSource_IDNO = @An_OthpSource_IDNO
		  AND j.TypeReference_CODE = @Ac_TypeReference_CODE
		  AND j.MemberMci_IDNO = @An_MemberMci_IDNO
		  AND j.Status_CODE = @Lc_StatusStart_CODE;
	 END
	 ELSE
      BEGIN
		SELECT @Li_Count_NUMB = COUNT(1)
		 FROM DMJR_Y1 j
		WHERE j.Case_IDNO = @An_Case_IDNO
		  AND j.OrderSeq_NUMB IN(@Li_Zero_NUMB, @An_OrderSeq_NUMB)
		  AND j.ActivityMajor_CODE = @Lc_ActivityMajor_CODE
		  AND j.OthpSource_IDNO = @An_OthpSource_IDNO
		  AND j.MemberMci_IDNO = @An_MemberMci_IDNO
		  AND j.Status_CODE = @Lc_StatusStart_CODE;
	  END
	
   IF (@Li_Count_NUMB <> @Li_Zero_NUMB)
    BEGIN
     SET @Lc_ActivityMajor_CODE = NULL;
    END

   IF @Lc_ActivityMajor_CODE IS NOT NULL
    BEGIN
     EXEC BATCH_ENF_ELFC$SP_INITIATE_REMEDY
      @Ac_TypeChange_CODE          = @Ac_TypeChange_CODE,
      @An_Case_IDNO                = @An_Case_IDNO,
      @An_OrderSeq_NUMB            = @An_OrderSeq_NUMB,
      @An_MemberMci_IDNO           = @An_MemberMci_IDNO,
      @An_OthpSource_IDNO          = @An_OthpSource_IDNO,
      @Ac_TypeOthpSource_CODE      = @Ac_TypeOthpSource_CODE,
      @Ac_ActivityMajor_CODE       = @Lc_ActivityMajor_CODE,
      @Ac_Subsystem_CODE           = @Ac_Subsystem_CODE,
      @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
      @Ac_Worker_ID                = @Ac_WorkerUpdate_ID,
      @Ad_Run_DATE                 = @Ad_Run_DATE,
      @Ac_TypeReference_CODE       = @Ac_TypeReference_CODE,
      @Ac_Reference_ID             = @Ac_Reference_ID,
      @Ac_Process_ID               = @Ac_Process_ID,
      @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
    END

   IF (@Ac_Msg_CODE != @Lc_StatusSuccess_CODE)
    BEGIN
     RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @Ls_DescriptionError_TEXT = @Lc_Space_TEXT;
  END TRY

  BEGIN CATCH
   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Routine_TEXT,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
