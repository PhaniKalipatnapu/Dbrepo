/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_MEMBER_CASEMANAGEMENT_MERGE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_MERG$SP_MEMBER_CASEMANAGEMENT_MERGE
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	DAILY
Developed On	:	5/3/2012
Called By		:	BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE
Called On		:	BATCH_COMMON$SP_NOTE_INSERT
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_MEMBER_CASEMANAGEMENT_MERGE]
 @An_MemberMciSecondary_IDNO  NUMERIC(10),
 @An_MemberMciPrimary_IDNO    NUMERIC(10),
 @An_Cursor_QNTY              NUMERIC(11),
 @Ad_Run_DATE                 DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_Msg_CODE                 VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  DECLARE @Lc_CheckRecipientCpNcp_CODE    CHAR(1)		= '1',
          @Lc_VerificationStatusGood_CODE CHAR(1)		= 'Y',
          @Lc_StatusFailed_CODE           CHAR(1)		= 'F',
          @Lc_StatusSuccess_CODE          CHAR(1)		= 'S',
          @Lc_StatusLocate_CODE           CHAR(1)		= 'L',
          @Lc_Locate_INDC                 CHAR(1)		= 'N',
          @Lc_StatusNonLocate_CODE        CHAR(1)		= 'N',
          @Lc_TypeAddressC_CODE			  CHAR(1)		= 'C',
          @Lc_TypeEntityMembr_CODE        CHAR(5)		= 'MEMBR',
          @Lc_TypeEntityPayor_CODE        CHAR(5)		= 'PAYOR',
          @Lc_TypeEntityRcpid_CODE        CHAR(5)		= 'RCPID',
          @Lc_TypeEntityWcase_CODE        CHAR(5)		= 'WCASE',
          @Lc_TypeEntityDiseq_CODE        CHAR(5)		= 'DISEQ',
          @Lc_TypeEntityRcpcd_CODE        CHAR(5)		= 'RCPCD',
          @Lc_Package_NAME                CHAR(30)		= 'BATCH_CM_MERG',
          @Ls_Procedure_NAME              VARCHAR(50)	= 'SP_MEMBER_CASEMANAGEMENT_MERGE',
          @Ld_High_DATE                   DATE			= '12/31/9999';
  DECLARE @Ls_FetchStatus_BIT       SMALLINT,
          @Ln_CborValidation_QNTY   NUMERIC(11) = 0,
          @Ln_EftrExists_QNTY       NUMERIC(11) = 0,
          @Ln_EsemExists_QNTY       NUMERIC(11) = 0,
          @Ln_DsbhValidation_QNTY   NUMERIC(11) = 0,
          @Ln_DsblValidation_QNTY   NUMERIC(11) = 0,
          @Ln_MaxDsbh_SEQ           NUMERIC(11) = 0,
          @Ln_DhldValidation_QNTY   NUMERIC(11) = 0,
          @Ln_AhisValidation_QNTY   NUMERIC(11) = 0,
          @Ln_HahisValidation_QNTY  NUMERIC(11) = 0,
          @Ln_IrsaValidation_QNTY   NUMERIC(11) = 0,
          @Ln_BchkValidation_QNTY   NUMERIC(11) = 0,
          @Ln_CpflValidation_QNTY   NUMERIC(11) = 0,
          @Ln_IncmValidation_QNTY   NUMERIC(11) = 0,
          @Ln_IfmsValidation_QNTY   NUMERIC(11) = 0,
          @Ln_HifmsValidation_QNTY  NUMERIC(11) = 0,
          @Ln_IstxValidation_QNTY   NUMERIC(11) = 0,
          @Ln_RjcsValidation_QNTY   NUMERIC(11) = 0,
          @Ln_RjdtValidation_QNTY   NUMERIC(11) = 0,
          @Ln_MdetValidation_QNTY   NUMERIC(11) = 0,
          @Ln_ObleValidation_QNTY   NUMERIC(11) = 0,
          @Ln_MergeDataExists_QNTY  NUMERIC(11) = 0,
          @Lc_ExistsAhis_NUMB       NUMERIC(5)	= 0,
          @Lc_ExistsEhis_NUMB       NUMERIC(5)	= 0,
          @Ln_ChldExists_QNTY       NUMERIC(11) = 0,
          @Ln_DishExists_QNTY       NUMERIC(11) = 0,
          @Ln_CpnoExists_QNTY       NUMERIC(11) = 0,
          @Ln_DcrsExists_QNTY       NUMERIC(11) = 0,
          @Ln_DerrExists_QNTY       NUMERIC(11) = 0,
          @Ln_RecpExists_QNTY       NUMERIC(11) = 0,
          @Ln_EftSvcAcct_QNTY       NUMERIC(11) = 0,
          @Ln_FcrProactive_QNTY     NUMERIC(11) = 0,
          @Ln_FcrDmdc_QNTY          NUMERIC(11) = 0,
          @Ln_IvaChildren_QNTY      NUMERIC(11) = 0,
          @Ln_IvaCp_QNTY            NUMERIC(11) = 0,
          @Ln_DeTaxation_QNTY       NUMERIC(11) = 0,
          @Ln_NmsnTracking_QNTY     NUMERIC(11) = 0,
          @Ln_NmsnUpdates_QNTY      NUMERIC(11) = 0,
          @Ln_Pirst_QNTY            NUMERIC(11) = 0,
          @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Lc_MemberMciSecondary_ID CHAR(10),
          @Lc_MemberMciPrimary_ID   CHAR(10),
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_LastRequest_DATE      DATE,
          @Lx_XmlData_XML           XML;
  DECLARE @Dsbh_CUR                     CURSOR,
          @Rec_Dsbh$CheckRecipient_ID   CHAR(10),
          @Rec_Dsbh$DisburseSeq_NUMB    NUMERIC(19),
          @Rec_Dsbh$CheckRecipient_CODE CHAR(2),
          @Rec_Dsbh$Disburse_DATE       DATE;
  DECLARE @Elfc_CUR                 CURSOR,
          @Elfc_CUR$MemberMci_IDNO  NUMERIC(9),
          @Elfc_CUR$Case_IDNO       NUMERIC(6),
          @Elfc_CUR$OrderSeq_NUMB   NUMERIC(5),
          @Elfc_CUR$OthpSource_IDNO NUMERIC(10),
          @Elfc_CUR$TypeChange_CODE CHAR(2),
          @Elfc_CUR$Process_DATE    DATE;

  BEGIN TRY
   SET @Lc_MemberMciPrimary_ID = CAST(@An_MemberMciPrimary_IDNO AS VARCHAR);
   SET @Lc_MemberMciSecondary_ID = CAST(@An_MemberMciSecondary_IDNO AS VARCHAR);
   -----------------------------------------------------------------------
   -- Merge credit bureau override table  (CBOR)
   -----------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'CBOR MMERG UPDATION'
   SET @Ls_SqlData_TEXT = 'MemberMciPrimary_IDNO: ' + @Lc_MemberMciPrimary_ID + ' MemberMciSecondary_IDNO: ' + @Lc_MemberMciSecondary_ID;

   SELECT @Ln_CborValidation_QNTY = COUNT(1)
     FROM CBOR_Y1
    WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO

   IF @Ln_CborValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM CBOR_Y1 a
                                WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_CborValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - CBOR_Y1 ';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'CBOR_Y1',
              @Ln_CborValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' UPDATE CBOR_Y1 ';

     UPDATE CBOR_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE CBOR_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   -----------------------------------------------------------------------
   -- Merge ELECTRONIC_FUND_TRANSFER table
   -----------------------------------------------------------------------			
   SET @Ls_Sql_TEXT = 'EFTR MMERG UPDATION';

   SELECT @Ln_EftrExists_QNTY = COUNT(1)
     FROM EFTR_Y1
    WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
      AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;

   IF @Ln_EftrExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM EFTR_Y1 b
                                                     WHERE b.CheckRecipient_ID = @An_MemberMciPrimary_IDNO
                                                       AND b.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                                                       AND a.EventGlobalBeginSeq_NUMB = b.EventGlobalBeginSeq_NUMB)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM EFTR_Y1 a
                                WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
                                  AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_EftrExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - EFTR_Y1 ';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'EFTR_Y1',
              @Ln_EftrExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' DELETE FROM EFTR_Y1 ';

     DELETE a
       FROM EFTR_Y1 a
      WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND a.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
        AND EXISTS (SELECT 1
                      FROM EFTR_Y1 AS b
                     WHERE a.CheckRecipient_ID = @An_MemberMciPrimary_IDNO
                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                       AND a.EventGlobalBeginSeq_NUMB = b.EventGlobalBeginSeq_NUMB);

     SET @Ls_Sql_TEXT = ' SELECT EFTR_Y1 2 ';

     SELECT @Ln_EftrExists_QNTY = COUNT(1)
       FROM EFTR_Y1
      WHERE CheckRecipient_ID = @An_MemberMciPrimary_IDNO
        AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
        AND EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_EftrExists_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' UPDATE EFTR_Y1 ';

       UPDATE EFTR_Y1
          SET EndValidity_DATE = @Ad_Run_DATE
        WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
          AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
          AND EndValidity_DATE = @Ld_High_DATE;
      END

     SET @Ls_Sql_TEXT = ' UPDATE EFTR_Y1 2';

     UPDATE EFTR_Y1
        SET CheckRecipient_ID = @An_MemberMciPrimary_IDNO
      WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;
    END

   -----------------------------------------------------------------------
   -- Merge EVENT_SEQ_MATRIX - VESEM  Details
   -----------------------------------------------------------------------		
   SET @Ls_Sql_TEXT = ' ESEM_Y1 MMERG UPDATION';

   SELECT @Ln_EsemExists_QNTY = COUNT(1)
     FROM ESEM_Y1
    WHERE TypeEntity_CODE IN (@Lc_TypeEntityMembr_CODE, @Lc_TypeEntityPayor_CODE, @Lc_TypeEntityRcpid_CODE, @Lc_TypeEntityWcase_CODE,
                              @Lc_TypeEntityDiseq_CODE, @Lc_TypeEntityRcpcd_CODE)
      AND Entity_ID = @Lc_MemberMciSecondary_ID;

   IF @Ln_EsemExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM ESEM_Y1 b
                                                     WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB
                                                       AND b.EventFunctionalSeq_NUMB = a.EventFunctionalSeq_NUMB
                                                       AND b.Entity_ID = @An_MemberMciPrimary_IDNO
                                                       AND b.TypeEntity_CODE = a.TypeEntity_CODE)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM ESEM_Y1 a
                                WHERE TypeEntity_CODE IN (@Lc_TypeEntityMembr_CODE, @Lc_TypeEntityPayor_CODE, @Lc_TypeEntityRcpid_CODE, @Lc_TypeEntityWcase_CODE,
                                                          @Lc_TypeEntityDiseq_CODE, @Lc_TypeEntityRcpcd_CODE)
                                  AND Entity_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_EsemExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - ESEM_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'ESEM_Y1',
              @Ln_EsemExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Ls_Sql_TEXT = ' DELETE ESEM_Y1';

     DELETE a
       FROM ESEM_Y1 AS a
      WHERE a.TypeEntity_CODE IN (@Lc_TypeEntityMembr_CODE, @Lc_TypeEntityPayor_CODE, @Lc_TypeEntityRcpid_CODE, @Lc_TypeEntityWcase_CODE,
                                  @Lc_TypeEntityDiseq_CODE, @Lc_TypeEntityRcpcd_CODE)
        AND a.Entity_ID = @Lc_MemberMciSecondary_ID
        AND EXISTS (SELECT 1
                      FROM ESEM_Y1 AS b
                     WHERE a.EventGlobalSeq_NUMB = b.EventGlobalSeq_NUMB
                       AND a.EventFunctionalSeq_NUMB = b.EventFunctionalSeq_NUMB
                       AND a.Entity_ID = @Lc_MemberMciPrimary_ID
                       AND a.TypeEntity_CODE = b.TypeEntity_CODE);

     SET @Ls_Sql_TEXT = ' UPDATE ESEM_Y1';

     UPDATE a
        SET Entity_ID = @Lc_MemberMciPrimary_ID
       FROM ESEM_Y1 a
      WHERE a.TypeEntity_CODE IN (@Lc_TypeEntityMembr_CODE, @Lc_TypeEntityPayor_CODE, @Lc_TypeEntityRcpid_CODE, @Lc_TypeEntityWcase_CODE,
                                  @Lc_TypeEntityDiseq_CODE, @Lc_TypeEntityRcpcd_CODE)
        AND a.Entity_ID = @Lc_MemberMciSecondary_ID;
    END

   -----------------------------------------------------------------------
   --       Merge DISBURSEMENT tables
   -----------------------------------------------------------------------			
   SET @Ls_Sql_TEXT = ' DSBH_Y1 MMERG UPDATION';
   -- Defining the cursor @Dsbh_CUR					  
   SET @Dsbh_CUR = CURSOR LOCAL FORWARD_ONLY STATIC
   FOR SELECT a.CheckRecipient_ID,
              a.CheckRecipient_CODE,
              a.Disburse_DATE,
              a.DisburseSeq_NUMB
         FROM DSBH_Y1 AS a
        WHERE a.CheckRecipient_ID = @Lc_MemberMciSecondary_ID
          AND EXISTS (SELECT 1
                        FROM DSBH_Y1 AS b
                       WHERE b.CheckRecipient_ID = @Lc_MemberMciPrimary_ID
                         AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
                         AND b.Disburse_DATE = a.Disburse_DATE
                         AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB)
        ORDER BY a.CheckRecipient_ID,
                 a.CheckRecipient_CODE,
                 a.Disburse_DATE,
                 a.DisburseSeq_NUMB;
   SET @Ls_Sql_TEXT = 'OPEN @Dsbh_CUR';

   OPEN @Dsbh_CUR;

   SET @Ls_Sql_TEXT = 'FETCH @Dsbh_CUR - 1';

   FETCH NEXT FROM @Dsbh_CUR INTO @Rec_Dsbh$CheckRecipient_ID, @Rec_Dsbh$CheckRecipient_CODE, @Rec_Dsbh$Disburse_DATE, @Rec_Dsbh$DisburseSeq_NUMB;

   SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;

   -- cursor loop1 Starts @Dsbh_CUR	
   WHILE @Ls_FetchStatus_BIT = 0
    BEGIN
     SET @Ln_DsbhValidation_QNTY = 0;
     SET @Ls_Sql_TEXT = ' SELECT DSBH_Y1 1';

     SELECT @Ln_MaxDsbh_SEQ = MAX(DisburseSeq_NUMB) + 1
       FROM DSBH_Y1
      WHERE CheckRecipient_ID IN (@Lc_MemberMciPrimary_ID, @Lc_MemberMciSecondary_ID)
        AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
        AND Disburse_DATE = @rec_dsbh$Disburse_DATE;

     --VDSBH ---      
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBH_Y1 a
                                WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
                                  AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
                                  AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
                                  AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBH_Y1 1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'DSBH_Y1',
              @Ln_DsbhValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     --Update DSBH sequence--
     SET @Ls_Sql_TEXT = ' UPDATE DSBH_Y1 1';

     UPDATE DSBH_Y1
        SET DisburseSeq_NUMB = @Ln_MaxDsbh_SEQ,
            CheckRecipient_ID = @Lc_MemberMciPrimary_ID
      WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
        AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
        AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
        AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB;

     --DSBL_Y1 ---      
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBL_Y1 a
                                WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
                                  AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
                                  AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
                                  AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsblValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBL_Y1 A';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'DSBL_Y1',
              @Ln_DsblValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     --Update DSBL sequence--
     SET @Ls_Sql_TEXT = ' UPDATE DSBL_Y1 UPDATE ';

     UPDATE DSBL_Y1
        SET DisburseSeq_NUMB = @Ln_MaxDsbh_SEQ,
            CheckRecipient_ID = @Lc_MemberMciPrimary_ID
      WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
        AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
        AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
        AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB;

     -------------------------------------------------------------------------
     --Merge LogDisbursementAddress_T1 table
     --------------------------------------------------------------------------
     --DADR_Y1 --      
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DADR_Y1 a
                                WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
                                  AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
                                  AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
                                  AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DADR_Y1 1';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DADR_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       --Update DADR sequence--         
       SET @Ls_Sql_TEXT = ' UPDATE DADR_Y1 1';

       UPDATE DADR_Y1
          SET DisburseSeq_NUMB = @Ln_MaxDsbh_SEQ,
              CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE DADR_Y1.CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
          AND DADR_Y1.CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
          AND DADR_Y1.Disburse_DATE = @Rec_Dsbh$Disburse_DATE
          AND DADR_Y1.DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB;
      END

     -------------------------------------------------------------------------
     --Merge LogDisbursementEft_T1 table
     --------------------------------------------------------------------------
     --DEFT_Y1---
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DEFT_Y1 a
                                WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
                                  AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
                                  AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
                                  AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DEFT_Y1 1';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DEFT_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       SET @Ls_Sql_TEXT = ' UPDATE DEFT_Y1';

       UPDATE DEFT_Y1
          SET DisburseSeq_NUMB = @Ln_MaxDsbh_SEQ,
              CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
          AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
          AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
          AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB;
      END

     -------------------------------------------------------------------------
     --Merge LogDisbursementHdrChg_T1 table
     --------------------------------------------------------------------------                        
     --DSBC_Y1---
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBC_Y1 a
                                WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
                                  AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
                                  AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
                                  AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBC_Y1 1';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DSBC_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       ---Update DSBC sequence--      
       SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1';

       UPDATE DSBC_Y1
          SET DisburseSeq_NUMB = @Ln_MaxDsbh_SEQ,
              CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
          AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
          AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
          AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB;
      END

     -------------------------------------------------------------------------
     --Merge LogDisbursementHdrChg_T1 table
     -------------------------------------------------------------------------- 							     		
     --DSBC_Y1-Orig --- 
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBC_Y1 a
                                WHERE CheckRecipientOrig_ID = @Rec_Dsbh$CheckRecipient_ID
                                  AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
                                  AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
                                  AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBC_Y1 1 - ORIG';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DSBC_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       ---Update DSBC sequence--      
       SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1 1 -ORIG';

       UPDATE DSBC_Y1
          SET DisburseSeq_NUMB = @Ln_MaxDsbh_SEQ,
              CheckRecipientOrig_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipientOrig_ID = @Rec_Dsbh$CheckRecipient_ID
          AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
          AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
          AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB;
      END

     -------------------------------------------------------------------------
     --Merge LogDisbursementHold_T1 table
     -------------------------------------------------------------------------- 									
     --DHLD_Y1 ---
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DHLD_Y1 a
                                WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
                                  AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
                                  AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
                                  AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DhldValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DhldValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DHLD_Y1 ';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DHLD_Y1',
                @Ln_DhldValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       --Update DHLD original sequence--    
       SET @Ls_Sql_TEXT = ' UPDATE DHLD_Y1';

       UPDATE DHLD_Y1
          SET DisburseSeq_NUMB = @Ln_MaxDsbh_SEQ,
              CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipient_ID = @Rec_Dsbh$CheckRecipient_ID
          AND CheckRecipient_CODE = @Rec_Dsbh$CheckRecipient_CODE
          AND Disburse_DATE = @Rec_Dsbh$Disburse_DATE
          AND DisburseSeq_NUMB = @Rec_Dsbh$DisburseSeq_NUMB;
      END

     --- End of cursor
     FETCH NEXT FROM @Dsbh_CUR INTO @Rec_Dsbh$CheckRecipient_ID, @Rec_Dsbh$CheckRecipient_CODE, @Rec_Dsbh$Disburse_DATE, @Rec_Dsbh$DisburseSeq_NUMB;

     SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;
    END

   CLOSE @Dsbh_CUR;

   DEALLOCATE @Dsbh_CUR;

   --- End of @Dsbh_CUR loop	
   SET @Ls_Sql_TEXT = ' SELECT DABH_Y1 2';

   SELECT @Ln_DsbhValidation_QNTY = COUNT(1)
     FROM DSBH_Y1
    WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID;

   IF @Ln_DsbhValidation_QNTY > 0
    BEGIN
     --DSBH_Y1--
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBH_Y1 a
                                WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBH_Y1 2';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'DSBH_Y1',
              @Ln_DsbhValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     --physical update for secondary recip-id
     SET @Ls_Sql_TEXT = ' UPDATE DSBH_Y1 2';

     UPDATE DSBH_Y1
        SET CheckRecipient_ID = @Lc_MemberMciPrimary_ID
      WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID;

     --DSBL_Y1--
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBL_Y1 a
                                WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBL_Y1 2';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'DSBL_Y1',
              @Ln_DsbhValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' UPDATE DSBL_Y1 2';

     UPDATE DSBL_Y1
        SET CheckRecipient_ID = @Lc_MemberMciPrimary_ID
      WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID;

     --DADR_Y1--
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DADR_Y1 a
                                WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DADR_Y1 2';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DADR_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       SET @Ls_Sql_TEXT = ' UPDATE VDADR_Y1 2';

       UPDATE DADR_Y1
          SET CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID;
      END

     --DEFT_Y1--
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DEFT_Y1 a
                                WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - DEFT_Y1 2';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DEFT_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       SET @Ls_Sql_TEXT = ' UPDATE DEFT_Y1 2';

       UPDATE DEFT_Y1
          SET CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE DEFT_Y1.CheckRecipient_ID = @Lc_MemberMciSecondary_ID;
      END

     --DSBC_Y1--
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBC_Y1 a
                                WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBC_Y1 2';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DSBC_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1 2';

       UPDATE DSBC_Y1
          SET CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID;
      END

     --VDSBC Orig--
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBC_Y1 a
                                WHERE CheckRecipientOrig_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DSBC_Y1 2 ORIG '

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DSBC_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1 2 ORIG';

       UPDATE DSBC_Y1
          SET CheckRecipientOrig_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID;
      END

     --DHLD_Y1--
     SET @Ln_DsbhValidation_QNTY = 0;

     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DHLD_Y1 a
                                WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DsbhValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     IF @Ln_DsbhValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DHLD_Y1 2';

       INSERT MMLG_Y1
              (MemberMciPrimary_IDNO,
               MemberMciSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               RowDataXml_TEXT,
               TransactionEventSeq_NUMB,
               Merge_DATE)
       VALUES ( @An_MemberMciPrimary_IDNO,
                @An_MemberMciSecondary_IDNO,
                'DHLD_Y1',
                @Ln_DsbhValidation_QNTY,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE);

       SET @Lx_XmlData_XML = NULL;
       SET @Ls_Sql_TEXT = ' UPDATE DHLD_Y1 2';

       UPDATE DHLD_Y1
          SET CheckRecipient_ID = @Lc_MemberMciPrimary_ID
        WHERE CheckRecipient_ID = @Lc_MemberMciSecondary_ID;
      END
    END

   ------------------------------------------------------------------------------------------------
   --  AHIS  -- AddressDetails_T1
   ------------------------------------------------------------------------------------------------									  
   SET @Ls_Sql_TEXT = 'SP_MEMBER_MERGE - AHIS MMERG UPDATION';

   SELECT @Ln_AhisValidation_QNTY = COUNT(1)
     FROM AHIS_Y1 AS a
    WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_AhisValidation_QNTY > 0
    BEGIN

     SELECT @Lx_XmlData_XML = (SELECT *
								 FROM (SELECT a.*,
                                      CASE
                                       WHEN a.TypeAddress_CODE != @Lc_TypeAddressC_CODE
                                        AND EXISTS (SELECT 1
                                                      FROM AHIS_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                                                       AND a.TypeAddress_CODE = b.TypeAddress_CODE
                                                       AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM AHIS_Y1 a
                                WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                                UNION
                                SELECT a.*,
									   'U' merge_status
                                  FROM AHIS_Y1 a
                                  JOIN AHIS_Y1 b
                                    ON b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                                   AND b.TypeAddress_CODE = a.TypeAddress_CODE
                                   AND @Ad_Run_DATE BETWEEN b.Begin_DATE AND b.End_DATE
                                 WHERE a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                                   AND a.TypeAddress_CODE = @Lc_TypeAddressC_CODE
                                   AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE) as t
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_AhisValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - AHIS_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'AHIS_Y1',
              @Ln_AhisValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);
     SET @Ls_Sql_TEXT = ' UPDATE AHIS_Y1 - End Date Old LKCA Address';
              
	 UPDATE a
	    SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO,
			End_DATE = @Ad_Run_DATE
	   FROM AHIS_Y1 a
	   JOIN (SELECT a.MemberMci_IDNO,
					a.TypeAddress_CODE,
					a.TransactionEventSeq_NUMB,
					ROW_NUMBER() OVER(PARTITION BY a.TypeAddress_CODE ORDER BY a.Begin_DATE DESC,a.TransactionEventSeq_NUMB DESC) Row_NUMB
			   FROM AHIS_Y1 a
			  WHERE a.MemberMci_IDNO IN (@An_MemberMciPrimary_IDNO,@An_MemberMciSecondary_IDNO)
				AND a.TypeAddress_CODE = @Lc_TypeAddressC_CODE
			    AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE) t
	     ON t.MemberMci_IDNO = a.MemberMci_IDNO
	    AND t.TypeAddress_CODE = a.TypeAddress_CODE
	    AND t.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
	    AND t.Row_NUMB != 1;

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' DELETE FROM AHIS_Y1';

     DELETE a
       FROM AHIS_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1
                      FROM AHIS_Y1 AS b
                     WHERE a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                       AND a.TypeAddress_CODE = b.TypeAddress_CODE
                       AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB);

     SET @Ls_Sql_TEXT = 'UPDATE AHIS_Y1';

     UPDATE AHIS_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE AHIS_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  HAHIS_Y1  -- AddressDetailsHist_T1
   ------------------------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'SP_MEMBER_MERGE - AHIS HISTORY MMERG UPDATION';

   SELECT @Ln_HahisValidation_QNTY = COUNT(1)
     FROM HAHIS_Y1 AS a
    WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_HahisValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM HAHIS_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                                                       AND a.TypeAddress_CODE = b.TypeAddress_CODE
                                                       AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM HAHIS_Y1 a
                                WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_HahisValidation_QNTY = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HAHIS_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'HAHIS_Y1',
              @Ln_HahisValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'DELETE FROM HAHIS_Y1';

     DELETE a
       FROM HAHIS_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1
                      FROM HAHIS_Y1 AS b
                     WHERE a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                       AND a.TypeAddress_CODE = b.TypeAddress_CODE
                       AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB);

     SET @Ls_Sql_TEXT = 'UPDATE HAHIS_Y1';

     UPDATE HAHIS_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE HAHIS_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  ArrearCertAmountIrs_T1
   ------------------------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'SP_MEMBER_MERGE - IRSA_Y1 MMERG UPDATION';

   SELECT @Ln_IrsaValidation_QNTY = COUNT(1)
     FROM IRSA_Y1 AS a
    WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_IrsaValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM IRSA_Y1 a
                                WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_IrsaValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - IRSA_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'IRSA_Y1',
              @Ln_HahisValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' UPDATE IRSA_Y1';

     UPDATE IRSA_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE IRSA_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  BadCheckDetails_T1
   ------------------------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'SP_MEMBER_MERGE - BCHK_Y1 MERG_Y1 UPDATION';

   SELECT @Ln_BchkValidation_QNTY = COUNT(1)
     FROM BCHK_Y1
    WHERE BCHK_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_BchkValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM BCHK_Y1 a
                                WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_BchkValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - BCHK_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'BCHK_Y1',
              @Ln_BchkValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' UPDATE BCHK_Y1';

     UPDATE BCHK_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  CpFeeTransactionLog_T1
   ------------------------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'SP_MEMBER_MERGE - CPFL_Y1 MERG_Y1 UPDATION';

   SELECT @Ln_CpflValidation_QNTY = COUNT(1)
     FROM CPFL_Y1
    WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_CpflValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM CPFL_Y1 a
                                WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_CpflValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - CPFL_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'CPFL_Y1',
              @Ln_CpflValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' UPDATE CPFL_Y1';

     UPDATE CPFL_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  MemberIncome_T1
   ------------------------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'MemberIncome_T1 MMERG UPDATION';

   SELECT @Ln_IncmValidation_QNTY = COUNT(1)
     FROM INCM_Y1
    WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_IncmValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM INCM_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                                                       AND b.SourceIncome_CODE = a.SourceIncome_CODE
                                                       AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM INCM_Y1 a
                                WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_IncmValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - INCM_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'INCM_Y1',
              @Ln_IncmValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' DELETE INCM_Y1';

     DELETE a
       FROM INCM_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1
                      FROM INCM_Y1 AS b
                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                       AND b.SourceIncome_CODE = a.SourceIncome_CODE
                       AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)

     SET @Ls_Sql_TEXT = 'UPDATE INCM_Y1 1';

     UPDATE a
        SET EndValidity_DATE = @Ad_Run_DATE
       FROM INCM_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND EXISTS (SELECT 1 AS expr
                      FROM INCM_Y1 AS b
                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                       AND a.SourceIncome_CODE = b.SourceIncome_CODE
                       AND a.OtherParty_IDNO = b.OtherParty_IDNO
                       AND b.EndValidity_DATE = @Ld_High_DATE);

     SET @Ls_Sql_TEXT = 'UPDATE INCM_Y1 2';

     UPDATE INCM_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  InterceptFmsLog_T1
   ------------------------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'IFMS_Y1 MMERG UPDATION';

   SELECT @Ln_IfmsValidation_QNTY = COUNT(1)
     FROM IFMS_Y1
    WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_IfmsValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM IFMS_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM IFMS_Y1 a
                                WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_IfmsValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - IFMS_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'IFMS_Y1',
              @Ln_IfmsValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'DELETE IFMS_Y1';

     DELETE IFMS_Y1
       FROM IFMS_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1 AS expr
                      FROM IFMS_Y1 AS b
                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO);

     SET @Ls_Sql_TEXT = 'UPDATE IFMS_Y1';

     UPDATE IFMS_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  InterceptFmsLogHist_T1
   ------------------------------------------------------------------------------------------------                  
   SET @Ls_Sql_TEXT = 'HIFMS_Y1 MMERG UPDATION';

   --Delete secondary member record if primary exists
   SELECT @Ln_HifmsValidation_QNTY = COUNT(1)
     FROM HIFMS_Y1
    WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_HifmsValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM HIFMS_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM HIFMS_Y1 a
                                WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_HifmsValidation_QNTY = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HIFMS_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'HIFMS_Y1',
              @Ln_HifmsValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'DELETE HIFMS_Y1';

     DELETE HIFMS_Y1
       FROM HIFMS_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1 AS expr
                      FROM HIFMS_Y1 AS b
                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO);

     SET @Ls_Sql_TEXT = 'UPDATE HIFMS_Y1';

     UPDATE HIFMS_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE HIFMS_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  InterceptStxLog_T1
   ------------------------------------------------------------------------------------------------			
   SET @Ls_Sql_TEXT = 'ISTX_Y1 MMERG UPDATION';

   SELECT @Ln_IstxValidation_QNTY = COUNT(1)
     FROM ISTX_Y1
    WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_IstxValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM ISTX_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM ISTX_Y1 a
                                WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_IstxValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - ISTX_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'ISTX_Y1',
              @Ln_IstxValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'DELETE ISTX_Y1';

     DELETE ISTX_Y1
       FROM ISTX_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1 AS expr
                      FROM ISTX_Y1 AS b
                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO);

     SET @Ls_Sql_TEXT = 'UPDATE ISTX_Y1';

     UPDATE ISTX_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  IrsRejectCases_T1 
   ------------------------------------------------------------------------------------------------			
   SET @Ls_Sql_TEXT = 'RJCS_Y1 MMERG UPDATION';

   SELECT @Ln_RjcsValidation_QNTY = COUNT(1)
     FROM RJCS_Y1 a
    WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND a.Case_IDNO IN (SELECT b.Case_IDNO
                            FROM UCMEM_V1 AS b
                           WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO)

   IF @Ln_RjcsValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM RJCS_Y1 c
                                                     WHERE c.MemberMci_IDNO = @An_MemberMciPrimary_IDNO)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM RJCS_Y1 a
                                WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                                  AND a.Case_IDNO IN (SELECT b.Case_IDNO
                                                        FROM UCMEM_V1 b
                                                       WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO)
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_RjcsValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - RJCS_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'RJCS_Y1',
              @Ln_RjcsValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'DELETE RJCS_Y1';

     DELETE RJCS_Y1
       FROM RJCS_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND a.Case_IDNO IN (SELECT b.Case_IDNO
                              FROM UCMEM_V1 AS b
                             WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO)
        AND EXISTS (SELECT 1 AS expr
                      FROM RJCS_Y1 AS c
                     WHERE c.MemberMci_IDNO = @An_MemberMciPrimary_IDNO)

     SET @Ls_Sql_TEXT = 'UPDATE RJCS_Y1';

     UPDATE RJCS_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
       FROM RJCS_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND a.Case_IDNO IN (SELECT b.Case_IDNO
                              FROM UCMEM_V1 AS b
                             WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO)
    END

   ------------------------------------------------------------------------------------------------
   --  IrsRejectDetails_T1 
   ------------------------------------------------------------------------------------------------			
   SET @Ls_Sql_TEXT = 'RJDT_Y1 MMERG UPDATION';

   SELECT @Ln_RjdtValidation_QNTY = COUNT(1)
     FROM RJDT_Y1
    WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_RjdtValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM RJDT_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM RJDT_Y1 a
                                WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_RjdtValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - RJDT_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'RJDT_Y1',
              @Ln_RjdtValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'DELETE RJDT_Y1';

     DELETE RJDT_Y1
       FROM RJDT_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1 AS expr
                      FROM RJDT_Y1 AS b
                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO);

     SET @Ls_Sql_TEXT = 'UPDATE RJDT_Y1';

     UPDATE RJDT_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   -- MEMBER_DETENTION
   ------------------------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'MDET_Y1 MMERG UPDATION';

   SELECT @Ln_MdetValidation_QNTY = COUNT(1)
     FROM MDET_Y1 AS a
    WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_MdetValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM MDET_Y1 b
                                                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                                                       AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM MDET_Y1 a
                                WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_MdetValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - MDET_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'MDET_Y1',
              @Ln_MdetValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' DELETE FROM MDET_Y1';

     DELETE MDET_Y1
       FROM MDET_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1 AS expr
                      FROM MDET_Y1 AS b
                     WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                       AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB);

     SET @Ls_Sql_TEXT = 'SELECT MDET_Y1 2';

     SELECT @Ln_MdetValidation_QNTY = COUNT(1)
       FROM MDET_Y1
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
        AND EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_MdetValidation_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'SELECT MDET_Y1 3';

       UPDATE MDET_Y1
          SET EndValidity_DATE = @Ad_Run_DATE
        WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;
      END

     SET @Ls_Sql_TEXT = 'UPDATE MDET_Y1';

     UPDATE MDET_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
       FROM MDET_Y1 AS a
      WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   -- OBLIGATION
   ------------------------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'OBLE_Y1 MMERG UPDATION';

   SELECT @Ln_ObleValidation_QNTY = COUNT(1)
     FROM OBLE_Y1 AS a
    WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
            OR a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO)
      AND a.Case_IDNO IN (SELECT b.Case_IDNO
                            FROM UCMEM_V1 AS b
                           WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);

   IF @Ln_ObleValidation_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM OBLE_Y1 a
                                WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                                        OR a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO)
                                  AND a.Case_IDNO IN (SELECT b.Case_IDNO
                                                        FROM UCMEM_V1 b
                                                       WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO)
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_ObleValidation_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - OBLE_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'OBLE_Y1',
              @Ln_ObleValidation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' UPDATE OBLE_Y1 ';

     UPDATE OBLE_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
       FROM OBLE_Y1 AS a
      WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
              OR a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO)
        AND a.Case_IDNO IN (SELECT b.Case_IDNO
                              FROM UCMEM_V1 AS b
                             WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
    END

   ------------------------------------------------------------------------------------------------
   -- LocateStatus_T1
   ------------------------------------------------------------------------------------------------
   BEGIN
    SET @Ls_Sql_TEXT = 'LocateStatus_T1 - LSTT_Y1  MMERG UPDATION';
    SET @Ln_MergeDataExists_QNTY = 0;
    SET @Ls_Sql_TEXT = 'SELECT AHIS_Y1';

    SELECT TOP 1 @Lc_ExistsAhis_NUMB = 1
      FROM AHIS_Y1
     WHERE MemberMci_IDNO = @An_MemberMciPrimary_IDNO
       AND End_DATE = @Ld_High_DATE
       AND @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
       AND Status_CODE = @Lc_VerificationStatusGood_CODE;

    IF @@ROWCOUNT = 0
     BEGIN
      SET @Lc_ExistsAhis_NUMB = 0;
     END

    SET @Ls_Sql_TEXT = 'SELECT EHIS_Y1';

    SELECT @Lc_ExistsEhis_NUMB = 1
      FROM EHIS_Y1
     WHERE MemberMci_IDNO = @An_MemberMciPrimary_IDNO
       AND EndEmployment_DATE = @Ld_High_DATE
       AND @Ad_Run_DATE BETWEEN BeginEmployment_DATE AND EndEmployment_DATE
       AND Status_CODE = @Lc_VerificationStatusGood_CODE;

    IF @@ROWCOUNT = 0
     BEGIN
      SET @Lc_ExistsEhis_NUMB = 0;
     END

    IF (@Lc_ExistsEhis_NUMB = 1
         OR @Lc_ExistsAhis_NUMB = 1)
     BEGIN
      SET @Lc_Locate_INDC = @Lc_StatusLocate_CODE;
     END
    ELSE
     BEGIN
      SET @Lc_Locate_INDC = @Lc_StatusNonLocate_CODE;
     END

    SET @Ls_Sql_TEXT = 'SELECT LSTT_Y1';

    SELECT TOP 1 @Lc_StatusLocate_CODE = StatusLocate_CODE
      FROM LSTT_Y1
     WHERE MemberMci_IDNO = @An_MemberMciPrimary_IDNO
       AND EndValidity_DATE = @Ld_High_DATE;

    IF @@ROWCOUNT = 0
     BEGIN
      SET @Lc_StatusLocate_CODE = 'N'
     END

    IF (@Lc_StatusLocate_CODE <> @Lc_Locate_INDC)
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT *
                                  FROM (SELECT a.*,
                                               'U' merge_status
                                          FROM LSTT_Y1 a
                                         WHERE a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                                           AND a.EndValidity_DATE = @Ld_High_DATE
                                        UNION ALL
                                        SELECT a.*,
                                               'D' merge_status
                                          FROM LSTT_Y1 a
                                         WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO)S
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_MergeDataExists_QNTY = (SELECT COUNT(*)
                                           FROM (SELECT t.c.exist('ROWS') AS id
                                                   FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LSTT_Y1';

      INSERT MMLG_Y1
             (MemberMciPrimary_IDNO,
              MemberMciSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              RowDataXml_TEXT,
              TransactionEventSeq_NUMB,
              Merge_DATE)
      VALUES ( @An_MemberMciPrimary_IDNO,
               @An_MemberMciSecondary_IDNO,
               'LSTT_Y1',
               @Ln_MergeDataExists_QNTY,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE);

      SET @Lx_XmlData_XML = NULL;
      SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1 1';

      UPDATE LSTT_Y1
         SET StatusLocate_CODE = @Lc_Locate_INDC
        FROM LSTT_Y1 AS a
       WHERE a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
         AND a.EndValidity_DATE = @Ld_High_DATE;

      SET @Ls_Sql_TEXT = 'DELETE LSTT_Y1 1';

      DELETE LSTT_Y1
       WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
     END

    SELECT @Lx_XmlData_XML = (SELECT a.*,
                                     'U' merge_status
                                FROM LSTT_Y1 a
                               WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                              FOR XML PATH('ROWS'), TYPE);

    SELECT @Ln_MergeDataExists_QNTY = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

    IF @Ln_MergeDataExists_QNTY > 0
     BEGIN
      SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - LSTT_Y1 2';

      INSERT MMLG_Y1
             (MemberMciPrimary_IDNO,
              MemberMciSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              RowDataXml_TEXT,
              TransactionEventSeq_NUMB,
              Merge_DATE)
      VALUES ( @An_MemberMciPrimary_IDNO,
               @An_MemberMciSecondary_IDNO,
               'LSTT_Y1',
               @Ln_MergeDataExists_QNTY,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE);

      SET @Lx_XmlData_XML = NULL;
      SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1 2';

      UPDATE LSTT_Y1
         SET EndValidity_DATE = @Ad_Run_DATE
        FROM LSTT_Y1 AS a
       WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
         AND a.EndValidity_DATE = @Ld_High_DATE
         AND EXISTS (SELECT 1 AS expr
                       FROM LSTT_Y1 AS b
                      WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                        AND b.EndValidity_DATE = @Ld_High_DATE);

      SET @Ls_Sql_TEXT = 'UPDATE LSTT_Y1 3';

      UPDATE LSTT_Y1
         SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
        FROM LSTT_Y1 AS a
       WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
     END
   END

   -----------------------------------------------------------------------
   -- Merge CpHold_T1 table
   -----------------------------------------------------------------------			
   SET @Ls_Sql_TEXT = 'CHLD_Y1 MMERG UPDATION';

   SELECT @Ln_ChldExists_QNTY = COUNT(1)
     FROM CHLD_Y1
    WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
      AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;

   IF @Ln_ChldExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN (@Ad_Run_DATE BETWEEN a.Effective_DATE AND a.Expiration_DATE
                                             AND a.EndValidity_DATE = @Ld_High_DATE
                                             AND EXISTS (SELECT 1
                                                           FROM CHLD_Y1 b
                                                          WHERE b.CheckRecipient_ID = @An_MemberMciPrimary_IDNO
                                                            AND b.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                                                            AND a.ReasonHold_CODE = b.ReasonHold_CODE
                                                            AND @Ad_Run_DATE BETWEEN b.Effective_DATE AND b.Expiration_DATE
                                                            AND b.EndValidity_DATE = @Ld_High_DATE))
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM CHLD_Y1 a
                                WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO
                                  AND a.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_ChldExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - CHLD_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'CHLD_Y1',
              @Ln_MergeDataExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = ' SELECT CHLD_Y1 2';

     SELECT @Ln_ChldExists_QNTY = COUNT(1)
       FROM CHLD_Y1 AS a
      WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND a.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
        AND @Ad_Run_DATE BETWEEN a.Effective_DATE AND a.Expiration_DATE
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND EXISTS (SELECT 1 AS expr
                      FROM CHLD_Y1 AS b
                     WHERE b.CheckRecipient_ID = @An_MemberMciPrimary_IDNO
                       AND b.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                       AND a.ReasonHold_CODE = b.ReasonHold_CODE
                       AND @Ad_Run_DATE BETWEEN b.Effective_DATE AND b.Expiration_DATE
                       AND b.EndValidity_DATE = @Ld_High_DATE);

     IF @Ln_ChldExists_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = ' DELETE CHLD_Y1';

       DELETE CHLD_Y1
        WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
          AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
      END

     SET @Ls_Sql_TEXT = 'UPDATE CHLD_Y1';

     UPDATE CHLD_Y1
        SET CheckRecipient_ID = @An_MemberMciPrimary_IDNO
      WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;
    END

   --------------------------------------------------------------------------------
   -- DISH_Y1  - Merge DistributionHold_T1
   ---------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'DISH_Y1 MMERG UPDATION';
   SET @Ls_Sql_TEXT = ' SELECT DISH_Y1 1';

   SELECT @Ln_DishExists_QNTY = COUNT(1)
     FROM DISH_Y1
    WHERE CasePayorMCI_IDNO = @An_MemberMciSecondary_IDNO;

   IF @Ln_DishExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN (@Ad_Run_DATE BETWEEN a.Effective_DATE AND a.Expiration_DATE
                                             AND a.EndValidity_DATE = @Ld_High_DATE
                                             AND EXISTS (SELECT 1
                                                           FROM DISH_Y1 b
                                                          WHERE b.CasePayorMCI_IDNO = @An_MemberMciPrimary_IDNO
                                                            AND b.ReasonHold_CODE = a.ReasonHold_CODE
                                                            AND @Ad_Run_DATE BETWEEN Effective_DATE AND Expiration_DATE
                                                            AND b.EndValidity_DATE = @Ld_High_DATE))
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM DISH_Y1 a
                                WHERE a.CasePayorMCI_IDNO = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DishExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DISH_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'DISH_Y1',
              @Ln_DishExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'SELECT DISH_Y1';

     SELECT @Ln_DishExists_QNTY = COUNT(1)
       FROM DISH_Y1 AS a
      WHERE a.CasePayorMCI_IDNO = @An_MemberMciSecondary_IDNO
        AND @Ad_Run_DATE BETWEEN a.Effective_DATE AND a.Expiration_DATE
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND EXISTS (SELECT 1 AS expr
                      FROM DISH_Y1 AS b
                     WHERE b.CasePayorMCI_IDNO = @An_MemberMciPrimary_IDNO
                       AND b.ReasonHold_CODE = a.ReasonHold_CODE
                       AND @Ad_Run_DATE BETWEEN b.Effective_DATE AND b.Expiration_DATE
                       AND b.EndValidity_DATE = @Ld_High_DATE);

     IF @Ln_DishExists_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'DELETE DISH_Y1';

       DELETE DISH_Y1
        WHERE CasePayorMCI_IDNO = @An_MemberMciSecondary_IDNO;
      END

     SET @Ls_Sql_TEXT = ' UPDATE DISH_Y1 '

     UPDATE DISH_Y1
        SET CasePayorMCI_IDNO = @An_MemberMciPrimary_IDNO
      WHERE CasePayorMCI_IDNO = @An_MemberMciSecondary_IDNO;
    END

   -----------------------------------------------------------------------
   -- Merge CpRecoupNotices_T1 table
   -----------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'CPNO_Y1 MMERG UPDATION';
   SET @Ls_Sql_TEXT = ' SELECT CPNO_Y1 1';

   SELECT @Ln_CpnoExists_QNTY = COUNT(1)
     FROM CPNO_Y1
    WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
      AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;

   IF @Ln_CpnoExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM CPNO_Y1 a
                                WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
                                  AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_CpnoExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - CPNO_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'CPNO_Y1',
              @Ln_CpnoExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE CPNO_Y1';

     UPDATE CPNO_Y1
        SET CheckRecipient_ID = @An_MemberMciPrimary_IDNO
      WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
    END

   -----------------------------------------------------------------------
   -- Merge DebitCardRecipients_T1 table
   -----------------------------------------------------------------------	
   SET @Ls_Sql_TEXT = 'DCRS_Y1 MMERG UPDATION';
   SET @Ls_Sql_TEXT = 'SELECT DCRS_Y1';

   SELECT @Ln_DcrsExists_QNTY = COUNT(1)
     FROM DCRS_Y1
    WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO;

   IF @Ln_DcrsExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      CASE
                                       WHEN EXISTS (SELECT 1
                                                      FROM DCRS_Y1 b
                                                     WHERE b.CheckRecipient_ID = @An_MemberMciPrimary_IDNO
                                                       AND a.EventGlobalBeginSeq_NUMB = b.EventGlobalBeginSeq_NUMB)
                                        THEN 'D'
                                       ELSE 'U'
                                      END merge_status
                                 FROM DCRS_Y1 a
                                WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DcrsExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DCRS_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'DCRS_Y1',
              @Ln_DcrsExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'DELETE FROM DCRS_Y1';

     DELETE DCRS_Y1
       FROM DCRS_Y1 AS a
      WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND EXISTS (SELECT 1 AS expr
                      FROM DCRS_Y1 AS b
                     WHERE a.CheckRecipient_ID = @An_MemberMciPrimary_IDNO
                       AND a.EventGlobalBeginSeq_NUMB = b.EventGlobalBeginSeq_NUMB);

     SET @Ls_Sql_TEXT = ' SELECT DCRS_Y1 2';

     SELECT @Ln_DcrsExists_QNTY = COUNT(1)
       FROM DCRS_Y1
      WHERE CheckRecipient_ID = @An_MemberMciPrimary_IDNO
        AND EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_DcrsExists_QNTY > 0
      BEGIN
       SET @Ls_Sql_TEXT = 'UPDATE DCRS_Y1';

       UPDATE DCRS_Y1
          SET EndValidity_DATE = @Ad_Run_DATE
        WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
          AND EndValidity_DATE = @Ld_High_DATE;
      END

     SET @Ls_Sql_TEXT = ' UPDATE DCRS_Y1 2';

     UPDATE DCRS_Y1
        SET CheckRecipient_ID = @An_MemberMciPrimary_IDNO
      WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO;
    END

   -----------------------------------------------------------------------
   -- Merge DsbhEftInfoError_T1 table
   -----------------------------------------------------------------------			 
   SET @Ls_Sql_TEXT = 'DERR_Y1 MMERG UPDATION';

   SELECT @Ln_DerrExists_QNTY = COUNT(1)
     FROM DERR_Y1
    WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
      AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;

   IF @Ln_DerrExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DERR_Y1 a
                                WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
                                  AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_DerrExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DERR_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'DERR_Y1',
              @Ln_DerrExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE DERR_Y1';

     UPDATE DERR_Y1
        SET CheckRecipient_ID = @An_MemberMciPrimary_IDNO
      WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;
    END

   -----------------------------------------------------------------------
   -- Merge RecoupmentPercent_T1 table
   -----------------------------------------------------------------------	
   SET @Ls_Sql_TEXT = 'RECP_Y1  MMERG UPDATION';

   SELECT @Ln_RecpExists_QNTY = COUNT(1)
     FROM RECP_Y1
    WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
      AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;

   IF @Ln_RecpExists_QNTY > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM RECP_Y1 a
                                WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
                                  AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_RecpExists_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - RECP_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'RECP_Y1',
              @Ln_RecpExists_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE RECP_Y1 1';

     UPDATE RECP_Y1
        SET EndValidity_DATE = @Ad_Run_DATE
       FROM RECP_Y1 AS a
      WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND a.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE
        AND a.EndValidity_DATE = @Ld_High_DATE
        AND EXISTS (SELECT 1 AS expr
                      FROM RECP_Y1 AS b
                     WHERE a.CheckRecipient_ID = @An_MemberMciPrimary_IDNO
                       AND a.CheckRecipient_CODE = b.CheckRecipient_CODE
                       AND b.EndValidity_DATE = @Ld_High_DATE);

     SET @Ls_Sql_TEXT = ' UPDATE RECP_Y1 2';

     UPDATE RECP_Y1
        SET CheckRecipient_ID = @An_MemberMciPrimary_IDNO
      WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO
        AND CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;
    END

   ------  Merge Temperory Tables---------------------------
   ------------------------------------------------------------------------------------------------
   --LoadEftSvcAcct_T1
   ------------------------------------------------------------------------------------------------	
   SET @Ls_Sql_TEXT = 'LESVC_Y1 MMERG UPDATION';

   SELECT @Lx_XmlData_XML = (SELECT a.*,
                                    'U' merge_status
                               FROM LESVC_Y1 a
                              WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                             FOR XML PATH('ROWS'), TYPE);

   SELECT @Ln_EftSvcAcct_QNTY = (SELECT COUNT(*)
                                   FROM (SELECT t.c.exist('ROWS') AS id
                                           FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

   IF @Ln_EftSvcAcct_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LESVC_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'LESVC_Y1',
              @Ln_EftSvcAcct_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE LESVC_Y1 ';

     UPDATE LESVC_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE LESVC_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --LoadFcrProactiveDetails_T1
   ------------------------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'LFPDE_Y1 MMERG UPDATION';

   SELECT @Lx_XmlData_XML = (SELECT a.*,
                                    'U' merge_status
                               FROM LFPDE_Y1 a
                              WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                             FOR XML PATH('ROWS'), TYPE);

   SELECT @Ln_FcrProactive_QNTY = (SELECT COUNT(*)
                                     FROM (SELECT t.c.exist('ROWS') AS id
                                             FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

   IF @Ln_FcrProactive_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LFPDE_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'LFPDE_Y1',
              @Ln_FcrProactive_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE LFPDE_Y1 ';

     UPDATE LFPDE_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --  LoadFcrDmdcDetails_T1
   ------------------------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'MMRG_Y1-LFDMD_Y1 MMERG UPDATION';

   SELECT @Lx_XmlData_XML = (SELECT a.*,
                                    'U' merge_status
                               FROM LFDMD_Y1 a
                              WHERE (CpMci_IDNO = @Lc_MemberMciSecondary_ID
                                  OR NcpMci_IDNO = @Lc_MemberMciSecondary_ID
                                  OR PfMci_IDNO = @Lc_MemberMciSecondary_ID
                                  OR ChildMCI_IDNO = @Lc_MemberMciSecondary_ID)
                             FOR XML PATH('ROWS'), TYPE);

   SET @Ls_Sql_TEXT = 'LFDMD_Y1 LOADFCRDMDC COUNT';

   SELECT @Ln_FcrDmdc_QNTY = (SELECT COUNT(*)
                                FROM (SELECT t.c.exist('ROWS') AS id
                                        FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

   IF @Ln_FcrDmdc_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LFDMD_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'LFDMD_Y1',
              @Ln_FcrDmdc_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE LFDMD_Y1 ';

     UPDATE LFDMD_Y1
        SET CpMci_IDNO = CASE
                          WHEN LFDMD_Y1.CpMci_IDNO = @Lc_MemberMciSecondary_ID
                           THEN @Lc_MemberMciPrimary_ID
                          ELSE LFDMD_Y1.CpMci_IDNO
                         END,
            NcpMci_IDNO = CASE
                           WHEN LFDMD_Y1.NcpMci_IDNO = @Lc_MemberMciSecondary_ID
                            THEN @Lc_MemberMciPrimary_ID
                           ELSE LFDMD_Y1.NcpMci_IDNO
                          END,
            PfMci_IDNO = CASE
                          WHEN LFDMD_Y1.PfMci_IDNO = @Lc_MemberMciSecondary_ID
                           THEN @Lc_MemberMciPrimary_ID
                          ELSE LFDMD_Y1.PfMci_IDNO
                         END,
            ChildMCI_IDNO = CASE
                             WHEN LFDMD_Y1.ChildMCI_IDNO = @Lc_MemberMciSecondary_ID
                              THEN @Lc_MemberMciPrimary_ID
                             ELSE LFDMD_Y1.ChildMCI_IDNO
                            END
      WHERE (CpMci_IDNO = @Lc_MemberMciSecondary_ID
          OR NcpMci_IDNO = @Lc_MemberMciSecondary_ID
          OR PfMci_IDNO = @Lc_MemberMciSecondary_ID
          OR ChildMCI_IDNO = @Lc_MemberMciSecondary_ID);
    END

   ------------------------------------------------------------------------------------------------
   --LoadIvaChildrenUpdates_T1
   ------------------------------------------------------------------------------------------------		
   SET @Ls_Sql_TEXT = 'LCHLD_Y1 MMERG UPDATION';

   SELECT @Lx_XmlData_XML = (SELECT a.*,
                                    'U' merge_status
                               FROM LCHLD_Y1 a
                              WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                             FOR XML PATH('ROWS'), TYPE);

   SELECT @Ln_IvaChildren_QNTY = (SELECT COUNT(*)
                                    FROM (SELECT t.c.exist('ROWS') AS id
                                            FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

   IF @Ln_IvaChildren_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LCHLD_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'LCHLD_Y1',
              @Ln_IvaChildren_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE LCHLD_Y1 ';

     UPDATE LCHLD_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   --LoadIvaCpUpdates_T1
   ------------------------------------------------------------------------------------------------
   SET @Ls_Sql_TEXT = 'LICPU_Y1 MMERG UPDATION';

   SELECT @Lx_XmlData_XML = (SELECT a.*,
                                    'U' merge_status
                               FROM LICPU_Y1 a
                              WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                             FOR XML PATH('ROWS'), TYPE);

   SELECT @Ln_IvaCp_QNTY = (SELECT COUNT(*)
                              FROM (SELECT t.c.exist('ROWS') AS id
                                      FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

   IF @Ln_IvaCp_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LICPU_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'LICPU_Y1',
              @Ln_IvaCp_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE LICPU_Y1 ';

     UPDATE LICPU_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   --------------------------------------------------------------------------------
   -- LoadDeTaxation_T1
   ---------------------------------------------------------------------------------	
   SET @Ls_Sql_TEXT = 'LDTAX_Y1 MMERG UPDATION';

   SELECT @Lx_XmlData_XML = (SELECT a.*,
                                    'U' merge_status
                               FROM LDTAX_Y1 a
                              WHERE PayorMCI_IDNO = @An_MemberMciSecondary_IDNO
                             FOR XML PATH('ROWS'), TYPE);

   SELECT @Ln_DeTaxation_QNTY = (SELECT COUNT(*)
                                   FROM (SELECT t.c.exist('ROWS') AS id
                                           FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

   IF @Ln_DeTaxation_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LDTAX_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'LDTAX_Y1',
              @Ln_DeTaxation_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE LDTAX_Y1 ';

     UPDATE LDTAX_Y1
        SET PayorMCI_IDNO = @An_MemberMciPrimary_IDNO
      WHERE PayorMCI_IDNO = @An_MemberMciSecondary_IDNO;
    END

   ------------------------------------------------------------------------------------------------
   -- IntIrsTaxTransaction_T1 Table
   ------------------------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'PIRST_Y1 MMERG UPDATION';

   SELECT @Lx_XmlData_XML = (SELECT a.*,
                                    'U' merge_status
                               FROM PIRST_Y1 a
                              WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
                             FOR XML PATH('ROWS'), TYPE);

   SELECT @Ln_Pirst_QNTY = (SELECT COUNT(*)
                              FROM (SELECT t.c.exist('ROWS') AS id
                                      FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

   IF @Ln_Pirst_QNTY > 0
    BEGIN
     SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - PIRST_Y1';

     INSERT MMLG_Y1
            (MemberMciPrimary_IDNO,
             MemberMciSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             RowDataXml_TEXT,
             TransactionEventSeq_NUMB,
             Merge_DATE)
     VALUES ( @An_MemberMciPrimary_IDNO,
              @An_MemberMciSecondary_IDNO,
              'PIRST_Y1',
              @Ln_Pirst_QNTY,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE);

     SET @Lx_XmlData_XML = NULL;
     SET @Ls_Sql_TEXT = 'UPDATE PIRST_Y1';

     UPDATE PIRST_Y1
        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
    END

   --- Merge Table Ends------	
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = ' ';
  END TRY

  BEGIN CATCH
   ----- Expection for CURSOR
   IF CURSOR_STATUS('LOCAL', '@Elfc_CUR') IN (0, 1)
    BEGIN
     CLOSE @Elfc_CUR;

     DEALLOCATE @Elfc_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
