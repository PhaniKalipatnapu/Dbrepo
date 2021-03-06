/****** Object:  StoredProcedure [dbo].[BATCH_COMMON_MHIS$SP_UPDATE_MHIS_RECORD]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON_MHIS$SP_UPDATE_MHIS_RECORD
Programmer Name		: IMP Team
Description			: This Procedure move the MHIS Update the MHIS Record for the period
Frequency			: 
Developed On		: 04/12/2011
Called By			: None
Called On			:
--------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0	
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON_MHIS$SP_UPDATE_MHIS_RECORD] (
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_Case_IDNO             NUMERIC(6),
 @Ac_TypeWelfare_CODE      CHAR(1),
 @An_CaseWelfare_IDNO      NUMERIC(10),
 @An_WelfareMemberMci_IDNO NUMERIC(10),
 @Ad_MinBeginElig_DATE     DATE,
 @Ad_OldEnd_DATE           DATE,
 @Ad_Start_DATE            DATE,
 @Ad_End_DATE              DATE = '12/31/9999',
 @An_EventGlobalSeq_NUMB   NUMERIC(19),
 @Ac_Reason_CODE           CHAR(2),
 @Ad_Run_DATE              DATE,
 @Ac_SignedOnWorker_ID     CHAR(30), 
 @Ac_Msg_CODE              CHAR(1) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Lc_Space_TEXT          CHAR(1) = ' ',
           @Lc_StatusFailed_CODE   CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE  CHAR(1) = 'S',
           @Ls_Procedure_NAME      VARCHAR(100) = 'SPKG_MHIS$SP_MODIFY_MHIS_PROCESS',
           @Ld_High_DATE           DATE = '12/31/9999';
  DECLARE  @Ln_Error_NUMB         NUMERIC(11,0),
           @Ln_ErrorLine_NUMB     NUMERIC(11,0),
           @Li_Rowcount_QNTY      INT,
           @Ls_Sql_TEXT           VARCHAR(100) = '',
           @Ls_Sqldata_TEXT       VARCHAR(1000) = '',
           @Ls_ErrorMessage_TEXT  VARCHAR(2000);
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   
   SET @Ls_Sql_TEXT = 'DELETE MHIS_Y1 ';
   SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'');

   DELETE FROM MHIS_Y1
   OUTPUT Deleted.MemberMci_IDNO,
          Deleted.Case_IDNO,
          Deleted.Start_DATE,
          Deleted.End_DATE,
          Deleted.TypeWelfare_CODE,
          Deleted.CaseWelfare_IDNO,
          Deleted.WelfareMemberMci_IDNO,
          Deleted.CaseHead_INDC,
          Deleted.Reason_CODE,
          Deleted.EventGlobalBeginSeq_NUMB,
          @An_EventGlobalSeq_NUMB AS EventGlobalEndSeq_NUMB,
          Deleted.BeginValidity_DATE,
          @Ad_Run_DATE AS EndValidity_DATE
   INTO HMHIS_Y1
    WHERE MemberMci_IDNO = @An_MemberMci_IDNO
      AND Case_IDNO = @An_Case_IDNO
      AND Start_DATE >= @Ad_MinBeginElig_DATE
      AND End_DATE <= @Ad_OldEnd_DATE
      AND EventGlobalBeginSeq_NUMB != @An_EventGlobalSeq_NUMB;

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF(@Ad_Start_DATE IS NOT NULL)
    BEGIN
     IF @Ac_TypeWelfare_CODE = 'N'
	   BEGIN 
	    SET @An_CaseWelfare_IDNO = 0;
	   END 
	 
	 SET @Ls_Sql_TEXT = 'INSERT INTO MHIS_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST( @An_MemberMci_IDNO AS VARCHAR ),'')+ ', Case_IDNO = ' + ISNULL(CAST( @An_Case_IDNO AS VARCHAR ),'')+ ', Start_DATE = ' + ISNULL(CAST( @Ad_Start_DATE AS VARCHAR ),'')+ ', TypeWelfare_CODE = ' + ISNULL(@Ac_TypeWelfare_CODE,'')+ ', CaseWelfare_IDNO = ' + ISNULL(CAST( @An_CaseWelfare_IDNO AS VARCHAR ),'')+ ', WelfareMemberMci_IDNO = ' + ISNULL(CAST( @An_WelfareMemberMci_IDNO AS VARCHAR ),'')+ ', CaseHead_INDC = ' + ISNULL(@Lc_Space_TEXT,'')+ ', Reason_CODE = ' + ISNULL(@Ac_Reason_CODE,'')+ ', BeginValidity_DATE = ' + ISNULL(CAST( @Ad_Run_DATE AS VARCHAR ),'')+ ', EventGlobalBeginSeq_NUMB = ' + ISNULL(CAST( @An_EventGlobalSeq_NUMB AS VARCHAR ),'')+ ', EventGlobalEndSeq_NUMB = ' + ISNULL(CAST( 0 AS VARCHAR ),'');

     INSERT INTO MHIS_Y1
                 (MemberMci_IDNO,
                  Case_IDNO,
                  Start_DATE,
                  End_DATE,
                  TypeWelfare_CODE,
                  CaseWelfare_IDNO,
                  WelfareMemberMci_IDNO,
                  CaseHead_INDC,
                  Reason_CODE,
                  BeginValidity_DATE,
                  EventGlobalBeginSeq_NUMB,
                  EventGlobalEndSeq_NUMB)
          VALUES ( @An_MemberMci_IDNO,--MemberMci_IDNO
                   @An_Case_IDNO,--Case_IDNO
                   @Ad_Start_DATE,--Start_DATE
                   ISNULL(@Ad_End_DATE, @Ld_High_DATE),--End_DATE
                   @Ac_TypeWelfare_CODE,--TypeWelfare_CODE
                   @An_CaseWelfare_IDNO,--CaseWelfare_IDNO
                   @An_WelfareMemberMci_IDNO,--WelfareMemberMci_IDNO
                   @Lc_Space_TEXT,--CaseHead_INDC
                   @Ac_Reason_CODE,--Reason_CODE
                   @Ad_Run_DATE,--BeginValidity_DATE
                   @An_EventGlobalSeq_NUMB,--EventGlobalBeginSeq_NUMB
                   0 --EventGlobalEndSeq_NUMB
     );

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF(@Li_Rowcount_QNTY = 0)
      BEGIN
       SET @Ls_ErrorMessage_TEXT ='MHIS_INSERT FAILED';

       RAISERROR(50001,16,1);
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

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
