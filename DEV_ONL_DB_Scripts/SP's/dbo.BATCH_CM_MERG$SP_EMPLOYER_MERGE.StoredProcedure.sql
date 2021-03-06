/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_EMPLOYER_MERGE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_MERG$SP_EMPLOYER_MERGE
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	DAILY
Developed On	:	5/3/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_EMPLOYER_MERGE]
 @As_OthpEmplSecondary_IDNO   NUMERIC(9),
 @As_OthpEmplPrimary_IDNO     NUMERIC(9),
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @Ac_IwnGenerate_INDC         CHAR(1),
 @An_Cursor_Cnt               NUMERIC(19),
 @Ad_Run_DATE                 DATETIME2,
 @Ac_Msg_CODE                 CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(MAX) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB                INT				= 0,
          @Lc_StatusFailed_CODE        CHAR(1)			= 'F',
          @Lc_StatusSuccess_CODE       CHAR(1)			= 'S',
          @Lc_TypeErrorE_CODE		   CHAR(1)			= 'E',
          @Lc_PositiveNegPos_CODE	   CHAR(1)			= 'P',
          @Lc_CaseRelationshipPf_CODE  CHAR(1)			= 'P',	
          @Lc_CaseRelationshipNcp_CODE CHAR(1)			= 'A',
          @Lc_CaseMemberStatusA_CODE   CHAR(1)			= 'A',
          @Lc_StatusCaseOpen_CODE	   CHAR(1)			= 'O',	
          @Lc_Space_TEXT               CHAR(1)			= ' ',
          @Lc_TypeChangeMm_CODE		   CHAR(2)			= 'MM',
          @Lc_TypeChangeEe_CODE		   CHAR(2)			= 'EE',
		  @Lc_TypeChangeEt_CODE		   CHAR(2)			= 'ET',
		  @Lc_TypeChangeIw_CODE		   CHAR(2)			= 'IW',
		  @Lc_TypeChangeNm_CODE		   CHAR(2)			= 'NM',
		  @Lc_TypeChangeNs_CODE		   CHAR(2)			= 'NS',
		  @Lc_TypeChangeWt_CODE		   CHAR(2)			= 'WT',
          @Lc_StatusStart_CODE		   CHAR(4)			= 'STRT',
          @Lc_ActivityMajorImiw_CODE   CHAR(4)			= 'IMIW',
          @Lc_ActivityMajorNmsn_CODE   CHAR(4)			= 'NMSN',
          @Ls_BatchRunUser_TEXT        CHAR(5)			= 'BATCH',
          @Lc_EmployerMergJob_ID       CHAR(7)			= 'DEB1040',
          @Lc_Successful_TEXT          CHAR(20)			= 'SUCCESSFUL',
          @Ls_Procedure_NAME           VARCHAR(50)		= 'SP_EMPLOYER_MERGE',
          @Ls_Package_NAME             VARCHAR(50)		= 'BATCH_CM_MERG',
          @Ld_High_DATE				   DATE				= '12/31/9999',
          @Ld_Low_DATE                 DATE				= '01/01/0001';
          
  DECLARE @Li_FetchStatus_NUMB         INT,
          @Ln_Case_IDNO                NUMERIC(6),
          @Ln_SeqReceipt_NUMB          NUMERIC(9),
          @Ln_MemberMci_IDNO           NUMERIC(10),
          @Ln_DisbSeqMax_NUMB          NUMERIC(10),
          @Ln_Batch_NUMB               NUMERIC(10),
          @Ln_Error_NUMB               NUMERIC(10),
          @Ln_ErrorLine_NUMB           NUMERIC(10),
          @Ln_RowCount_NUMB            NUMERIC(10),
          @Ln_Topic_IDNO               NUMERIC(10),
          @Ln_MajorIntSeq_NUMB         NUMERIC(10),
          @Ln_OrderSeq_NUMB            NUMERIC(10),
          @Ln_OthpEmplSecondary_IDNO   NUMERIC(10),
          @Ln_OthpEmplPrimary_IDNO     NUMERIC(10),
          @Ln_RowsAffected_NUMB      NUMERIC(10),
          @Ln_NrrqValidation_QNTY      NUMERIC(10),
          @Ln_NmrqValidation_QNTY      NUMERIC(10),
          @Ln_EiwtValidation_QNTY	   NUMERIC(10),
          @Ln_ApehValidation_QNTY	   NUMERIC(10),
          @Ln_PendTotOffset_AMNT       NUMERIC(11,2),
          @Ln_AssessTotOverPay_AMNT    NUMERIC(11,2),
          @Ln_RecTotOverPay_AMNT       NUMERIC(11,2),
          @Ln_TransEventSeq_NUMB       NUMERIC(19),
          @Ln_Unique_IDNO              NUMERIC(19),
          @Ln_DisburseSeq_NUMB         NUMERIC(19),
          @Ln_EventGlobalBeginSeq_NUMB NUMERIC(19),
          @Lc_CheckRecipient_CODE      CHAR(1),
          @Lc_SourceBatch_CODE         CHAR(3),
          @Lc_Msg_CODE                 CHAR(5),
          @Lc_CheckRecipient_ID		   CHAR(10),
          @Lc_Worker_ID                CHAR(30),
          @Ls_Sql_TEXT                 VARCHAR(200)		= '',
          @Ls_DescNote_TEXT            VARCHAR(1000),
          @Ls_Sqldata_TEXT             VARCHAR(1000)	= '',
          @Ls_Error_DESC               VARCHAR(4000),
          @Ls_DescriptionError_TEXT    VARCHAR (MAX),
          @Ld_Disburse_DATE            DATE,
          @Ld_Batch_DATE               DATE,
          @Ld_Run_DATE                 DATE,
          @Ld_Current_DTTM             DATETIME2		= dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Lx_XmlData_XML              XML;

  BEGIN TRY
   SET @Ld_Run_DATE = @Ad_Run_DATE;
   
   --Data into Temporary table.
   --Insert Into #Case_tab1
   -- 13691 - Closed Cases excluded from creating alert - Start
   SELECT DISTINCT
          c.Case_IDNO
     INTO #Case_tab1
     FROM CMEM_Y1 c
     JOIN EHIS_Y1 e
       ON e.MemberMci_IDNO = c.MemberMci_IDNO
    WHERE e.OthpPartyEmpl_IDNO = @As_OthpEmplSecondary_IDNO
      AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
      AND EXISTS ( SELECT 1
					 FROM CASE_Y1 a
					WHERE a.Case_IDNO = c.Case_IDNO
					  AND a.StatusCase_CODE = @Lc_StatusCaseOpen_CODE);
	-- 13691 - Closed Cases excluded from creating alert - End
	
   -- Case Cursor Declaration  
   DECLARE Case_CUR CURSOR LOCAL FORWARD_ONLY FOR
    SELECT Case_IDNO
      FROM #Case_tab1;

   BEGIN
    SET @Ln_OthpEmplSecondary_IDNO = @As_OthpEmplSecondary_IDNO;
    SET @Ln_OthpEmplPrimary_IDNO = @As_OthpEmplPrimary_IDNO;
    ------------------------------------------------------------------------------------------------
    --  IW_EMPLOYERS
    ------------------------------------------------------------------------------------------------  
    SET @Ls_Sql_TEXT = 'IW_EMPLOYERS EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    -- BEGIN IWEM UPDATE  
    IF EXISTS (SELECT 1
                 FROM IWEM_Y1
                WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO)
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT IWEM COUNT - EMERG UPDATION LOG';

      SELECT @Ln_RowsAffected_NUMB = COUNT(1)
        FROM IWEM_Y1
       WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO;

      IF @Ln_RowsAffected_NUMB > 0
       BEGIN
        SELECT @Lx_XmlData_XML = (SELECT a.*,
                                         'U' merge_status
                                    FROM IWEM_Y1 a
                                   WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO
                                  FOR XML PATH('ROWS'), TYPE);

        SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                            FROM (SELECT t.c.exist('ROWS') AS id
                                                    FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

        SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - IWEM_Y1';

        INSERT EMLG_Y1
               (OthpEmplPrimary_IDNO,
                OthpEmplSecondary_IDNO,
                Table_NAME,
                RowsAffected_NUMB,
                TransactionEventSeq_NUMB,
                Merge_DATE,
                RowDataXml_TEXT)
        VALUES ( @Ln_OthpEmplPrimary_IDNO,
                 @Ln_OthpEmplSecondary_IDNO,
                 'IWEM_Y1',
                 @Ln_RowsAffected_NUMB,
                 @An_TransactionEventSeq_NUMB,
                 @Ad_Run_DATE,
                 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

        SET @Lx_XmlData_XML = NULL;
       END

      SET @Ls_Sql_TEXT = 'DELETE IWEM_Y1 1';

      -- Deleting the duplicate records from IWEM_Y1 for secondary employer
      -- when the primary keys other id_othp_employer are same.
      DELETE FROM IWEM_Y1
        FROM IWEM_Y1 a
       WHERE a.OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO
         AND EXISTS (SELECT 1
                       FROM IWEM_Y1 b
                      WHERE b.Case_IDNO = a.Case_IDNO
                        AND b.OthpEmployer_IDNO = @Ln_OthpEmplPrimary_IDNO
                        AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                        AND b.MemberMci_IDNO = a.MemberMci_IDNO
                        AND b.IwnStatus_CODE = a.IwnStatus_CODE
                        AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);

      SET @Ls_Sql_TEXT = 'UPDATE IWEM_Y1 1';

      -- Updating the duplicate records from IWEM for secondary employer
      -- and having an existence of primary employer for that same case.
      UPDATE a
         SET a.EndValidity_DATE = @Ld_Run_DATE
        FROM IWEM_Y1 a
       WHERE a.OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO
         AND a.End_DATE	= @Ld_High_DATE
         AND a.EndValidity_DATE = @Ld_High_DATE
         AND EXISTS (SELECT 1
                       FROM IWEM_Y1 b
                      WHERE a.Case_IDNO = b.Case_IDNO
                        AND b.OthpEmployer_IDNO = @Ln_OthpEmplPrimary_IDNO
                        AND b.IwnStatus_CODE IN ('A', 'P')
                        AND b.End_DATE	= @Ld_High_DATE
                        AND b.EndValidity_DATE = @Ld_High_DATE);

      SET @Ls_Sql_TEXT = 'UPDATE IWEM_Y1';

      UPDATE IWEM_Y1
         SET OthpEmployer_IDNO = @Ln_OthpEmplPrimary_IDNO
       WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO;

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;
      
      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE NOT SUCCESSFUL';
        RAISERROR (50001,16,1);
       END
     END;

    -- END IWEM UPDATE
    ----------------------------------------------------------------------------------------------
    -- EHIS -- EMPLOYMENT_DETAILS
    ----------------------------------------------------------------------------------------------       
    -- BEGIN EHIS UPDATE
    SET @Ls_Sql_TEXT = 'EHIS EMERG ';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    -- EHIS CURSOR         
    DECLARE Ehis_CUR CURSOR LOCAL FORWARD_ONLY FOR
     SELECT DISTINCT
            MemberMci_IDNO
       FROM EHIS_Y1
      WHERE OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO;

	-- 13599 - Logging is moved outside the cursor for doing only one time - Start
	SET @Ls_Sql_TEXT = 'SELECT EHIS COUNT - EMERG UPDATION LOG';

	SELECT @Ln_RowsAffected_NUMB = COUNT(1)
	 FROM EHIS_Y1
	WHERE OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO;

	IF @Ln_RowsAffected_NUMB > 0
	BEGIN
	 SELECT @Lx_XmlData_XML = (SELECT a.*,
									  'U' merge_status
								 FROM EHIS_Y1 a
								WHERE OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
							   FOR XML PATH('ROWS'), TYPE);

	 SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
										 FROM (SELECT t.c.exist('ROWS') AS id
												 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

	 SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - EHIS_Y1 ';

	 INSERT EMLG_Y1
			(OthpEmplPrimary_IDNO,
			 OthpEmplSecondary_IDNO,
			 Table_NAME,
			 RowsAffected_NUMB,
			 TransactionEventSeq_NUMB,
			 Merge_DATE,
			 RowDataXml_TEXT)
	 VALUES ( @Ln_OthpEmplPrimary_IDNO,
			  @Ln_OthpEmplSecondary_IDNO,
			  'EHIS_Y1',
			  @Ln_RowsAffected_NUMB,
			  @An_TransactionEventSeq_NUMB,
			  @Ad_Run_DATE,
			  CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

	 SET @Lx_XmlData_XML = NULL;
	END
	
	-- 13599 - Logging is moved outside the cursor for doing only one time - End
	
    OPEN Ehis_CUR

    SET @Ls_Sql_TEXT = 'FETCH Ehis_CUR - 1';

    FETCH NEXT FROM Ehis_CUR INTO @Ln_MemberMci_IDNO;

    SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS

    WHILE @Li_FetchStatus_NUMB = 0
      BEGIN
       
       SET @Ls_Sql_TEXT =' CHECK WHETHER TO GENERATE ENF-01 NOTICE OR NOT';
		
       -- ENF-01 - BEGIN
       IF (@Ac_IwnGenerate_INDC = 'Y')
        BEGIN
         -- Cursor Declaration for cases in Immediate Income Withholding for ENF-01 notice generation
         DECLARE Cmem_CUR CURSOR LOCAL FORWARD_ONLY FOR
          SELECT DISTINCT
                 c.Case_IDNO
            FROM CMEM_Y1 c
            JOIN DMJR_Y1 d
              ON d.Case_IDNO = c.Case_IDNO
             AND d.MemberMci_IDNO = c.MemberMci_IDNO
           WHERE c.MemberMci_IDNO = @Ln_MemberMci_IDNO
             AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPf_CODE)
             AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusA_CODE
             AND d.ActivityMajor_CODE = @Lc_ActivityMajorImiw_CODE
             AND d.Status_CODE = @Lc_StatusStart_CODE
             AND d.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO;

         -- Case Cursor
         OPEN Cmem_CUR;

         SET @Ls_Sql_TEXT = 'FETCH Cmem_CUR';

         FETCH NEXT FROM Cmem_CUR INTO @Ln_Case_IDNO;

         SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS

         BEGIN
          WHILE @Li_FetchStatus_NUMB = 0
           BEGIN
            --   if ind_iwn_generate is Yes and IMIW started then generate ENF-01 Notice
            SET @Ls_Sql_TEXT = 'BATCH_COMMON.SP_INSERT_ACTIVITY';


				
			SET @Ls_SqlData_TEXT = ' Case_IDNO = ' + ISNULL(CAST(@Ln_Case_IDNO AS VARCHAR(6)), '') 			
								+ ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_MemberMci_IDNO AS VARCHAR(10)), '')
								+ ', OthpEmplPrimary_IDNO = ' + ISNULL(CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(9)), '')
								+ ', TransactionEventSeq_NUMB = ' + ISNULL(CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(19)), '');

				 SET @Ls_Sql_TEXT	 = 'EXEC  BATCH_COMMON$SP_INSERT_ELFC';										  
				 EXECUTE BATCH_COMMON$SP_INSERT_ELFC
						 @An_Case_IDNO                = @Ln_Case_IDNO,
						 @An_OrderSeq_NUMB            = 1 ,
						 @An_MemberMci_IDNO           = @Ln_MemberMci_IDNO,
						 @An_OthpSource_IDNO          = @Ln_OthpEmplPrimary_IDNO,
						 @Ac_TypeChange_CODE          = @Lc_TypeChangeMm_CODE,
						 @Ac_NegPos_CODE              = @Lc_PositiveNegPos_CODE,
						 @Ac_Process_ID               = @Lc_EmployerMergJob_ID ,
						 @Ad_Create_DATE              = @Ad_Run_DATE,
						 @Ac_Reference_ID             = 'NOPRI~ENF-01',
						 @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
						 @Ac_WorkerUpdate_ID          = @Lc_EmployerMergJob_ID,
						 @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
						 @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;
		 
				IF @Ac_Msg_CODE <> @Lc_StatusSuccess_CODE
				   BEGIN
						SET @Ls_DescriptionError_TEXT = 'EXEC  BATCH_COMMON$SP_INSERT_ELFC FAILS';										  
						RAISERROR (50001,16,1);
				   END	

            FETCH NEXT FROM Cmem_CUR INTO @Ln_Case_IDNO;

            SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS;
           END

          CLOSE Cmem_CUR;

          DEALLOCATE Cmem_CUR
       END

       -- ENF-01 - END
       --HEHIS
       -- Deleting the duplicate records from VEHIS if a member has both
       -- Primary and Secondary OTHP as employers and the below conditions.
       -- If Secondary OTHP is Primary Employer and Primary OTHP is not
       -- Primary Employer then Primary OTHP will be deleted from EHIS.
       SET @Ls_Sql_TEXT = ' INSERT HEHIS PRIMARY 1 ';

       INSERT INTO HEHIS_Y1
                   (MemberMci_IDNO,
                    OthpPartyEmpl_IDNO,
                    BeginEmployment_DATE,
                    EndEmployment_DATE,
                    TypeIncome_CODE,
                    DescriptionOccupation_TEXT,
                    IncomeNet_AMNT,
                    IncomeGross_AMNT,
                    FreqIncome_CODE,
                    FreqPay_CODE,
                    SourceLoc_CODE,
                    SourceReceived_DATE,
                    Status_CODE,
                    Status_DATE,
                    SourceLocConf_CODE,
                    InsProvider_INDC,
                    CostInsurance_AMNT,
                    FreqInsurance_CODE,
                    DpCoverageAvlb_INDC,
                    EmployerPrime_INDC,
                    DpCovered_INDC,
                    EligCoverage_DATE,
                    InsReasonable_INDC,
                    LimitCcpa_INDC,
                    PlsLastSearch_DATE,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB)
       SELECT a.MemberMci_IDNO,
              a.OthpPartyEmpl_IDNO,
              a.BeginEmployment_DATE,
              a.EndEmployment_DATE,
              a.TypeIncome_CODE,
              a.DescriptionOccupation_TEXT,
              a.IncomeNet_AMNT,
              a.IncomeGross_AMNT,
              a.FreqIncome_CODE,
              a.FreqPay_CODE,
              a.SourceLoc_CODE,
              a.SourceReceived_DATE,
              a.Status_CODE,
              a.Status_DATE,
              a.SourceLocConf_CODE,
              a.InsProvider_INDC,
              a.CostInsurance_AMNT,
              a.FreqInsurance_CODE,
              a.DpCoverageAvlb_INDC,
              a.EmployerPrime_INDC,
              a.DpCovered_INDC,
              a.EligCoverage_DATE,
              a.InsReasonable_INDC,
              a.LimitCcpa_INDC,
              a.PlsLastSearch_DATE,
              a.BeginValidity_DATE,
              @Ld_Run_DATE,
              a.WorkerUpdate_ID,
              a.Update_DTTM,
              a.TransactionEventSeq_NUMB
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.EndEmployment_DATE > @Ld_Run_DATE
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
          AND a.EmployerPrime_INDC != 'Y'
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
                         AND b.EmployerPrime_INDC = 'Y');

       SET @Ls_Sql_TEXT = ' DELETE EHIS PRIMARY 1 ';

       DELETE FROM EHIS_Y1
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.EndEmployment_DATE > @Ld_Run_DATE
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
          AND a.EmployerPrime_INDC != 'Y'
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
                         AND b.EmployerPrime_INDC = 'Y');

       -- If Status of Secondary OTHP status is Good and Primary OTHP is not
       -- Good then Primary OTHP will be deleted from EHIS.
       SET @Ls_Sql_TEXT = ' INSERT HEHIS PRIMARY 2 ';

       INSERT INTO HEHIS_Y1
                   (MemberMci_IDNO,
                    OthpPartyEmpl_IDNO,
                    BeginEmployment_DATE,
                    EndEmployment_DATE,
                    TypeIncome_CODE,
                    DescriptionOccupation_TEXT,
                    IncomeNet_AMNT,
                    IncomeGross_AMNT,
                    FreqIncome_CODE,
                    FreqPay_CODE,
                    SourceLoc_CODE,
                    SourceReceived_DATE,
                    Status_CODE,
                    Status_DATE,
                    SourceLocConf_CODE,
                    InsProvider_INDC,
                    CostInsurance_AMNT,
                    FreqInsurance_CODE,
                    DpCoverageAvlb_INDC,
                    EmployerPrime_INDC,
                    DpCovered_INDC,
                    EligCoverage_DATE,
                    InsReasonable_INDC,
                    LimitCcpa_INDC,
                    PlsLastSearch_DATE,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB)
       SELECT a.MemberMci_IDNO,
              a.OthpPartyEmpl_IDNO,
              a.BeginEmployment_DATE,
              a.EndEmployment_DATE,
              a.TypeIncome_CODE,
              a.DescriptionOccupation_TEXT,
              a.IncomeNet_AMNT,
              a.IncomeGross_AMNT,
              a.FreqIncome_CODE,
              a.FreqPay_CODE,
              a.SourceLoc_CODE,
              a.SourceReceived_DATE,
              a.Status_CODE,
              a.Status_DATE,
              a.SourceLocConf_CODE,
              a.InsProvider_INDC,
              a.CostInsurance_AMNT,
              a.FreqInsurance_CODE,
              a.DpCoverageAvlb_INDC,
              a.EmployerPrime_INDC,
              a.DpCovered_INDC,
              a.EligCoverage_DATE,
              a.InsReasonable_INDC,
              a.LimitCcpa_INDC,
              a.PlsLastSearch_DATE,
              a.BeginValidity_DATE,
              @Ld_Run_DATE,
              a.WorkerUpdate_ID,
              a.Update_DTTM,
              a.TransactionEventSeq_NUMB
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
          AND ((a.Status_CODE != 'Y'
                AND a.EndEmployment_DATE > @Ld_Run_DATE)
                OR a.EndEmployment_DATE <= @Ld_Run_DATE)
          AND EXISTS (SELECT 1
                        FROM ehis_y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
                         AND b.Status_CODE = 'Y');

       SET @Ls_Sql_TEXT = ' DELETE EHIS PRIMARY 2 ';

       DELETE FROM EHIS_Y1
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
          AND ((a.Status_CODE != 'Y'
                AND a.EndEmployment_DATE > @Ld_Run_DATE)
                OR a.EndEmployment_DATE <= @Ld_Run_DATE)
          AND EXISTS (SELECT 1
                        FROM ehis_y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
                         AND b.Status_CODE = 'Y');

       -- If Status of Primary OTHP status is Good or Pending then Secondary OTHP
       -- will be deleted from EHIS.
       SET @Ls_Sql_TEXT = ' INSERT HEHIS SECONDARY 1 ';

       INSERT INTO HEHIS_Y1
                   (MemberMci_IDNO,
                    OthpPartyEmpl_IDNO,
                    BeginEmployment_DATE,
                    EndEmployment_DATE,
                    TypeIncome_CODE,
                    DescriptionOccupation_TEXT,
                    IncomeNet_AMNT,
                    IncomeGross_AMNT,
                    FreqIncome_CODE,
                    FreqPay_CODE,
                    SourceLoc_CODE,
                    SourceReceived_DATE,
                    Status_CODE,
                    Status_DATE,
                    SourceLocConf_CODE,
                    InsProvider_INDC,
                    CostInsurance_AMNT,
                    FreqInsurance_CODE,
                    DpCoverageAvlb_INDC,
                    EmployerPrime_INDC,
                    DpCovered_INDC,
                    EligCoverage_DATE,
                    InsReasonable_INDC,
                    LimitCcpa_INDC,
                    PlsLastSearch_DATE,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB)
       SELECT a.MemberMci_IDNO,
              a.OthpPartyEmpl_IDNO,
              a.BeginEmployment_DATE,
              a.EndEmployment_DATE,
              a.TypeIncome_CODE,
              a.DescriptionOccupation_TEXT,
              a.IncomeNet_AMNT,
              a.IncomeGross_AMNT,
              a.FreqIncome_CODE,
              a.FreqPay_CODE,
              a.SourceLoc_CODE,
              a.SourceReceived_DATE,
              a.Status_CODE,
              a.Status_DATE,
              a.SourceLocConf_CODE,
              a.InsProvider_INDC,
              a.CostInsurance_AMNT,
              a.FreqInsurance_CODE,
              a.DpCoverageAvlb_INDC,
              a.EmployerPrime_INDC,
              a.DpCovered_INDC,
              a.EligCoverage_DATE,
              a.InsReasonable_INDC,
              a.LimitCcpa_INDC,
              a.PlsLastSearch_DATE,
              a.BeginValidity_DATE,
              @Ld_Run_DATE,
              a.WorkerUpdate_ID,
              a.Update_DTTM,
              a.TransactionEventSeq_NUMB
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
                         AND b.Status_CODE IN ('Y', 'P'));

       SET @Ls_Sql_TEXT = ' DELETE VEHIS SECONDARY 1 ';

       DELETE FROM EHIS_Y1
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
                         AND b.Status_CODE IN ('Y', 'P'));

       -- If Status of Secondary OTHP status is Pending with Open dated and Primary OTHP
       -- is end dated then Primary OTHP will be deleted from EHIS.
       SET @Ls_Sql_TEXT = ' INSERT HEHIS PRIMARY 3 ';

       INSERT INTO HEHIS_Y1
                   (MemberMci_IDNO,
                    OthpPartyEmpl_IDNO,
                    BeginEmployment_DATE,
                    EndEmployment_DATE,
                    TypeIncome_CODE,
                    DescriptionOccupation_TEXT,
                    IncomeNet_AMNT,
                    IncomeGross_AMNT,
                    FreqIncome_CODE,
                    FreqPay_CODE,
                    SourceLoc_CODE,
                    SourceReceived_DATE,
                    Status_CODE,
                    Status_DATE,
                    SourceLocConf_CODE,
                    InsProvider_INDC,
                    CostInsurance_AMNT,
                    FreqInsurance_CODE,
                    DpCoverageAvlb_INDC,
                    EmployerPrime_INDC,
                    DpCovered_INDC,
                    EligCoverage_DATE,
                    InsReasonable_INDC,
                    LimitCcpa_INDC,
                    PlsLastSearch_DATE,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB)
       SELECT a.MemberMci_IDNO,
              a.OthpPartyEmpl_IDNO,
              a.BeginEmployment_DATE,
              a.EndEmployment_DATE,
              a.TypeIncome_CODE,
              a.DescriptionOccupation_TEXT,
              a.IncomeNet_AMNT,
              a.IncomeGross_AMNT,
              a.FreqIncome_CODE,
              a.FreqPay_CODE,
              a.SourceLoc_CODE,
              a.SourceReceived_DATE,
              a.Status_CODE,
              a.Status_DATE,
              a.SourceLocConf_CODE,
              a.InsProvider_INDC,
              a.CostInsurance_AMNT,
              a.FreqInsurance_CODE,
              a.DpCoverageAvlb_INDC,
              a.EmployerPrime_INDC,
              a.DpCovered_INDC,
              a.EligCoverage_DATE,
              a.InsReasonable_INDC,
              a.LimitCcpa_INDC,
              a.PlsLastSearch_DATE,
              a.BeginValidity_DATE,
              @Ld_Run_DATE,
              a.WorkerUpdate_ID,
              a.Update_DTTM,
              a.TransactionEventSeq_NUMB
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
          AND a.EndEmployment_DATE <= @Ld_Run_DATE
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
                         AND b.Status_CODE = 'P');

       SET @Ls_Sql_TEXT = ' DELETE VEHIS PRIMARY 3 ';

       DELETE FROM EHIS_Y1
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
          AND a.EndEmployment_DATE <= @Ld_Run_DATE
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.EndEmployment_DATE > @Ld_Run_DATE
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
                         AND b.Status_CODE = 'P');

       -- If still duplicates with Primary and Secondary OTHP on same member exists,
       --then all the secondary OTHP records will be deleted from EHIS.
       SET @Ls_Sql_TEXT = ' INSERT HEHIS SECONDARY 2 ';

       INSERT INTO HEHIS_Y1
                   (MemberMci_IDNO,
                    OthpPartyEmpl_IDNO,
                    BeginEmployment_DATE,
                    EndEmployment_DATE,
                    TypeIncome_CODE,
                    DescriptionOccupation_TEXT,
                    IncomeNet_AMNT,
                    IncomeGross_AMNT,
                    FreqIncome_CODE,
                    FreqPay_CODE,
                    SourceLoc_CODE,
                    SourceReceived_DATE,
                    Status_CODE,
                    Status_DATE,
                    SourceLocConf_CODE,
                    InsProvider_INDC,
                    CostInsurance_AMNT,
                    FreqInsurance_CODE,
                    DpCoverageAvlb_INDC,
                    EmployerPrime_INDC,
                    DpCovered_INDC,
                    EligCoverage_DATE,
                    InsReasonable_INDC,
                    LimitCcpa_INDC,
                    PlsLastSearch_DATE,
                    BeginValidity_DATE,
                    EndValidity_DATE,
                    WorkerUpdate_ID,
                    Update_DTTM,
                    TransactionEventSeq_NUMB)
       SELECT a.MemberMci_IDNO,
              a.OthpPartyEmpl_IDNO,
              a.BeginEmployment_DATE,
              a.EndEmployment_DATE,
              a.TypeIncome_CODE,
              a.DescriptionOccupation_TEXT,
              a.IncomeNet_AMNT,
              a.IncomeGross_AMNT,
              a.FreqIncome_CODE,
              a.FreqPay_CODE,
              a.SourceLoc_CODE,
              a.SourceReceived_DATE,
              a.Status_CODE,
              a.Status_DATE,
              a.SourceLocConf_CODE,
              a.InsProvider_INDC,
              a.CostInsurance_AMNT,
              a.FreqInsurance_CODE,
              a.DpCoverageAvlb_INDC,
              a.EmployerPrime_INDC,
              a.DpCovered_INDC,
              a.EligCoverage_DATE,
              a.InsReasonable_INDC,
              a.LimitCcpa_INDC,
              a.PlsLastSearch_DATE,
              a.BeginValidity_DATE,
              @Ld_Run_DATE,
              a.WorkerUpdate_ID,
              a.Update_DTTM,
              a.TransactionEventSeq_NUMB
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO);

       SET @Ls_Sql_TEXT = ' DELETE VEHIS SECONDARY 2 ';

       DELETE FROM EHIS_Y1
         FROM EHIS_Y1 a
        WHERE a.MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND a.OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
          AND EXISTS (SELECT 1
                        FROM EHIS_Y1 b
                       WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                         AND b.OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO);

       -- Physical update of Secondary records with Primary records if any exists.
       SET @Ls_Sql_TEXT = 'UPDATE VEHIS';

       UPDATE EHIS_Y1
          SET OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
        WHERE MemberMci_IDNO = @Ln_MemberMci_IDNO
          AND OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO;
      END
   -- 13691 - BSTL Batch errors Receiving Unknown Batch Errors	- Start
	   FETCH NEXT FROM Ehis_CUR INTO @Ln_MemberMci_IDNO;
       SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS
    END
    
    CLOSE Ehis_CUR;
    DEALLOCATE Ehis_CUR
    -- 13691 - BSTL Batch errors Receiving Unknown Batch Errors	- End

    -- END EHIS UPDATE
    ------------------------------------------------------------------------------------------------
    -- HEHIS -- EMPLOYMENT_DETAILS_HIST
    ------------------------------------------------------------------------------------------------      
    SET @Ls_Sql_TEXT = 'HEHIS EMERG ';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    IF EXISTS (SELECT 1
                 FROM HEHIS_Y1
                WHERE OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO)
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT HEHIS COUNT - EMERG UPDATION LOG';

      SELECT @Ln_RowsAffected_NUMB = COUNT(1)
        FROM HEHIS_Y1
       WHERE OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO;

      IF @Ln_RowsAffected_NUMB > 0
       BEGIN
        SELECT @Lx_XmlData_XML = (SELECT a.*,
                                         'U' merge_status
                                    FROM HEHIS_Y1 a
                                   WHERE OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO
                                  FOR XML PATH('ROWS'), TYPE);

        SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                            FROM (SELECT t.c.exist('ROWS') AS id
                                                    FROM @Lx_XMLDATA_XML.nodes('ROWS') t(c)) a);

        SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - HEHIS_Y1 ';

        INSERT EMLG_Y1
               (OthpEmplPrimary_IDNO,
                OthpEmplSecondary_IDNO,
                Table_NAME,
                RowsAffected_NUMB,
                TransactionEventSeq_NUMB,
                Merge_DATE,
                RowDataXml_TEXT)
        VALUES ( @Ln_OthpEmplPrimary_IDNO,
                 @Ln_OthpEmplSecondary_IDNO,
                 'HEHIS_Y1',
                 @Ln_RowsAffected_NUMB,
                 @An_TransactionEventSeq_NUMB,
                 @Ad_Run_DATE,
                 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

        SET @Lx_XmlData_XML = NULL;
       END

      SET @Ls_Sql_TEXT = 'UPDATE HEHIS';

      UPDATE HEHIS_Y1
         SET OthpPartyEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
       WHERE OthpPartyEmpl_IDNO = @Ln_OthpEmplSecondary_IDNO;

     END

    ------------------------------------------------------------------------------------------------
    -- MAJOR_ACTIVITY_DIARY
    ------------------------------------------------------------------------------------------------  
    --DMJR START     
    SET @Ls_Sql_TEXT = 'MAJOR_ACTIVITY_DIARY EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));
    -- Cursor declaration for cases in open chains other than IMIW for
    -- secondary employer and having an existence of primary employer for that same case.
    SET @Ls_Sql_TEXT = 'DMJR CUR';

	-- 13599 - Logging is moved outside the cursor for doing only one time - Start

    DECLARE Dmjr_CUR CURSOR LOCAL FORWARD_ONLY FOR
     SELECT Case_IDNO,
            OrderSeq_NUMB,
            MajorIntSeq_NUMB
       FROM DMJR_Y1 a
      WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
		AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE)
        AND a.Status_CODE = @Lc_StatusStart_CODE
        AND EXISTS (SELECT 1
                      FROM DMJR_Y1 b
                     WHERE b.Case_IDNO = a.Case_IDNO
                       AND b.OthpSource_IDNO = @Ln_OthpEmplPrimary_IDNO
                       AND b.Status_CODE = @Lc_StatusStart_CODE
                       AND b.ActivityMajor_CODE = a.ActivityMajor_CODE);
                       

    IF EXISTS (SELECT 1
                 FROM DMJR_Y1 a
                WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
                  AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE))
     BEGIN
     
     SET @Ls_Sql_TEXT = 'SELECT DMJR COUNT - EMERG UPDATION LOG';

     SELECT @Ln_RowsAffected_NUMB = COUNT(1)
       FROM DMJR_Y1 a
      WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
        AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE);

     IF @Ln_RowsAffected_NUMB > 0
      BEGIN
       SELECT @Lx_XmlData_XML = (SELECT a.*,
                                        'U' merge_status
                                   FROM DMJR_Y1 a
                                  WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
                                    AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE)
                                 FOR XML PATH('ROWS'), TYPE);

       SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                           FROM (SELECT t.c.exist('ROWS') AS id
                                                   FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

       SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DMJR_Y1';

       INSERT EMLG_Y1
              (OthpEmplPrimary_IDNO,
               OthpEmplSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               TransactionEventSeq_NUMB,
               Merge_DATE,
               RowDataXml_TEXT)
       VALUES ( @Ln_OthpEmplPrimary_IDNO,
                @Ln_OthpEmplSecondary_IDNO,
                'DMJR_Y1',
                @Ln_RowsAffected_NUMB,
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

       SET @Lx_XmlData_XML = NULL;
      END
      -- 13599 - Logging is moved outside the cursor for doing only one time - End
      -- Dmjr_CUR Cursor
      OPEN Dmjr_CUR;

      SET @Ls_Sql_TEXT = 'FETCH Dmjr_CUR - 1';

      FETCH NEXT FROM Dmjr_CUR INTO @Ln_Case_IDNO, @Ln_OrderSeq_NUMB, @Ln_MajorIntSeq_NUMB;

      SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS

      BEGIN
       WHILE @Li_FetchStatus_NUMB = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE DMJR 1';
         SET @Ls_Sqldata_TEXT = 'ID_CASE ' + CAST(@Ln_Case_IDNO AS CHAR(10)) + 'ID_MEMBER ' + CAST(@Ln_MemberMci_IDNO AS CHAR(10)) + 'TransactionEventSeq_NUMB ' + CAST(@An_TransactionEventSeq_NUMB AS VARCHAR(1000));

         EXEC BATCH_CM_MERG$SP_CLOSE_ACTIVITY
          @As_Case_IDNO                = @Ln_Case_IDNO,
          @An_OrderSeq_NUMB            = @Ln_OrderSeq_NUMB,
          @An_MajorIntSeq_NUMB         = @Ln_MajorIntSeq_NUMB,
          @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
          @As_WorkerUpdate_ID          = @Ls_BatchRunUser_TEXT,
          @Ad_Run_DATE                 = @Ld_Run_DATE,
          @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

         IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           SET @Ls_Sql_TEXT = 'SP_CLOSE_ACTIVITY FAILED';

           RAISERROR (50001,16,1);
          END;

         FETCH NEXT FROM Dmjr_CUR INTO @Ln_Case_IDNO, @Ln_OrderSeq_NUMB, @Ln_MajorIntSeq_NUMB;

         SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS;
        END

       CLOSE Dmjr_CUR;

       DEALLOCATE Dmjr_CUR
      END

      SET @Ls_Sql_TEXT = 'UPDATE DMJR_Y1 ';

	  -- 13599 - Employer Source Remedy alone considered to merge - Start
      UPDATE DMJR_Y1
         SET OthpSource_IDNO = @Ln_OthpEmplPrimary_IDNO
       WHERE OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
         AND ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE);
      -- 13599 - Employer Source Remedy alone considered to merge - End
         
      SET @Ln_RowCount_NUMB = @@ROWCOUNT;

      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'DMJR_Y1 UPDATE NOT SUCCESSFUL';
        RAISERROR (50001,16,1);
       END
     END

    --DMJR END 
    ------------------------------------------------------------------------------------------------
    -- MAJOR_ACTIVITY_DIARY_HIST
    ------------------------------------------------------------------------------------------------
    --HDMJR START   
    SET @Ls_Sql_TEXT = 'MAJOR_ACTIVITY_DIARY EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    IF EXISTS (SELECT 1
                 FROM HDMJR_Y1 a
                WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
                  AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE))
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT HDMJR COUNT - EMERG UPDATION LOG';

      SELECT @Ln_RowsAffected_NUMB = COUNT(1)
        FROM HDMJR_Y1 a
       WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
         AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE);

      IF @Ln_RowsAffected_NUMB > 0
       BEGIN
        SELECT @Lx_XmlData_XML = (SELECT a.*,
                                         'U' merge_status
                                    FROM HDMJR_Y1 a
                                   WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
                                     AND a.ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE)
                                  FOR XML PATH('ROWS'), TYPE);

        SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                            FROM (SELECT t.c.exist('ROWS') AS id
                                                    FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

        SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - HDMJR_Y1';

        INSERT EMLG_Y1
               (OthpEmplPrimary_IDNO,
                OthpEmplSecondary_IDNO,
                Table_NAME,
                RowsAffected_NUMB,
                TransactionEventSeq_NUMB,
                Merge_DATE,
                RowDataXml_TEXT)
        VALUES ( @Ln_OthpEmplPrimary_IDNO,
                 @Ln_OthpEmplSecondary_IDNO,
                 'HDMJR_Y1',
                 @Ln_RowsAffected_NUMB,
                 @An_TransactionEventSeq_NUMB,
                 @Ad_Run_DATE,
                 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

        SET @Lx_XmlData_XML = NULL;
       END

      SET @Ls_Sql_TEXT = 'UPDATE HDMJR ';
	  UPDATE HDMJR_Y1
         SET OthpSource_IDNO = @Ln_OthpEmplPrimary_IDNO
       WHERE OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
         AND ActivityMajor_CODE IN (@Lc_ActivityMajorImiw_CODE, @Lc_ActivityMajorNmsn_CODE);

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;
      
      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE HDMJR NOT SUCCESSFUL';
        RAISERROR (50001,16,1);
       END
     END

    --HDMJR END            
    ------------------------------------------------------------------------------------------------
    -- MEMBER_INSURANCE
    ------------------------------------------------------------------------------------------------          
    --MINS START
    
    SET @Ls_Sql_TEXT = 'MEMBER_INSURANCE EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    IF EXISTS (SELECT 1
                 FROM MINS_Y1
                WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO)
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT MINS_Y1 COUNT - EMERG UPDATION LOG';

      SELECT @Ln_RowsAffected_NUMB = COUNT(1)
        FROM MINS_Y1
       WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO;

      IF @Ln_RowsAffected_NUMB > 0
       BEGIN
        SELECT @Lx_XmlData_XML = (SELECT a.*,
                                         'U' merge_status
                                    FROM MINS_Y1 a
                                   WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO
                                  FOR XML PATH('ROWS'), TYPE);

        SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                            FROM (SELECT t.c.exist('ROWS') AS id
                                                    FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

        SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - MINS_Y1';

        INSERT EMLG_Y1
               (OthpEmplPrimary_IDNO,
                OthpEmplSecondary_IDNO,
                Table_NAME,
                RowsAffected_NUMB,
                TransactionEventSeq_NUMB,
                Merge_DATE,
                RowDataXml_TEXT)
        VALUES ( @Ln_OthpEmplPrimary_IDNO,
                 @Ln_OthpEmplSecondary_IDNO,
                 'MINS_Y1',
                 @Ln_RowsAffected_NUMB,
                 @An_TransactionEventSeq_NUMB,
                 @Ad_Run_DATE,
                 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

        SET @Lx_XmlData_XML = NULL;
       END

      SET @Ls_Sql_TEXT = 'UPDATE MINS_Y1 ';

      UPDATE MINS_Y1
         SET OthpEmployer_IDNO = @Ln_OthpEmplPrimary_IDNO
       WHERE OthpEmployer_IDNO = @Ln_OthpEmplSecondary_IDNO;

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;
      
      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE MINS_Y1 NOT SUCCESSFUL';
        RAISERROR(50001,16,1);
       END
     END

    --MINS END          
    ------------------------------------------------------------------------------------------------
    -- OTHP_ADDRESS_XREF
    ------------------------------------------------------------------------------------------------
    -- OTHP_ADDRESS  - Start
    SET @Ls_Sql_TEXT = 'OTHP_ADDRESS_XREF EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    IF EXISTS (SELECT 1
                 FROM OTHX_Y1
                WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO)
     BEGIN
      SET @Ls_Sql_TEXT = 'SELECT OTHX COUNT - EMERG UPDATION LOG';

      SELECT @Ln_RowsAffected_NUMB = COUNT(1)
        FROM OTHX_Y1
       WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO;

      IF @Ln_RowsAffected_NUMB > 0
       BEGIN
        SELECT @Lx_XmlData_XML = (SELECT a.*,
                                         'U' merge_status
                                    FROM OTHX_Y1 a
                                   WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO
                                  FOR XML PATH('ROWS'), TYPE);

        SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                            FROM (SELECT t.c.exist('ROWS') AS id
                                                    FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

        SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - OTHX_Y1';

        INSERT EMLG_Y1
               (OthpEmplPrimary_IDNO,
                OthpEmplSecondary_IDNO,
                Table_NAME,
                RowsAffected_NUMB,
                TransactionEventSeq_NUMB,
                Merge_DATE,
                RowDataXml_TEXT)
        VALUES ( @Ln_OthpEmplPrimary_IDNO,
                 @Ln_OthpEmplSecondary_IDNO,
                 'OTHX_Y1',
                 @Ln_RowsAffected_NUMB,
                 @An_TransactionEventSeq_NUMB,
                 @Ad_Run_DATE,
                 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

        SET @Lx_XmlData_XML = NULL;
       END

      SET @Ls_Sql_TEXT = 'UPDATE OTHX_Y1 - 1 ';

      UPDATE OTHX_Y1
         SET EndValidity_DATE = @Ld_Run_DATE
        FROM OTHX_Y1 a
       WHERE a.otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO
         AND EXISTS (SELECT 1
                       FROM othx_y1 b
                      WHERE b.otherparty_IDNO = @Ln_OthpEmplPrimary_IDNO);

      SET @Ls_Sql_TEXT = 'UPDATE OTHX_Y1 - 2 ';

      UPDATE OTHX_Y1
         SET otherparty_IDNO = @Ln_OthpEmplPrimary_IDNO
       WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO;

      SET @Ln_RowCount_NUMB = @@ROWCOUNT;
      
      IF @Ln_RowCount_NUMB = 0
       BEGIN
        SET @Ls_DescriptionError_TEXT = 'UPDATE OTHX_Y1 NOT SUCCESSFUL';
        RAISERROR(50001,16,1);
       END
     END

    -- OTHP_ADDRESS  - End
    ------------------------------------------------------------------------------------------------
    -- RECEIPT
    ------------------------------------------------------------------------------------------------
    -- RECEIPT START
    SET @Ls_Sql_TEXT = 'SELECT RCTH COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM RCTH_Y1 a
     WHERE ISNUMERIC(a.RefundRecipient_ID) = 1 
       AND a.RefundRecipient_ID = @Ln_OthpEmplSecondary_IDNO
       AND EXISTS (SELECT 1
                     FROM (SELECT b.Batch_DATE,
                                  b.SourceBatch_CODE,
                                  b.Batch_NUMB,
                                  b.SeqReceipt_NUMB
                             FROM DHLD_Y1 b
                            WHERE ISNUMERIC(b.CheckRecipient_ID) =  1
                              AND b.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                              AND b.CheckRecipient_CODE = '3'
                           UNION
                           SELECT c.Batch_DATE,
                                  c.SourceBatch_CODE,
                                  c.Batch_NUMB,
                                  c.SeqReceipt_NUMB
                             FROM DSBL_Y1 c
                            WHERE ISNUMERIC(c.CheckRecipient_ID) = 1 
                              AND c.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                              AND c.CheckRecipient_CODE = '3')x
                    WHERE a.Batch_DATE = x.Batch_DATE
                      AND a.SourceBatch_CODE = x.SourceBatch_CODE
                      AND a.Batch_NUMB = x.Batch_NUMB
                      AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB);

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM RCTH_Y1 a
                                 WHERE ISNUMERIC(a.RefundRecipient_ID) = 1 
								   AND a.RefundRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                   AND EXISTS (SELECT 1
                                                 FROM (SELECT b.Batch_DATE,
                                                              b.SourceBatch_CODE,
                                                              b.Batch_NUMB,
                                                              b.SeqReceipt_NUMB
                                                         FROM DHLD_Y1 b
                                                        WHERE ISNUMERIC(b.CheckRecipient_ID) = 1 
														  AND b.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                                          AND b.CheckRecipient_CODE = '3'
                                                       UNION
                                                       SELECT c.Batch_DATE,
                                                              c.SourceBatch_CODE,
                                                              c.Batch_NUMB,
                                                              c.SeqReceipt_NUMB
                                                         FROM DSBL_Y1 c
                                                        WHERE ISNUMERIC(c.CheckRecipient_ID) = 1 
														  AND c.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                                          AND c.CheckRecipient_CODE = '3')x
                                                WHERE a.Batch_DATE = x.Batch_DATE
                                                  AND a.SourceBatch_CODE = x.SourceBatch_CODE
                                                  AND a.Batch_NUMB = x.Batch_NUMB
                                                  AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB)
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - RCTH_Y1';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'RCTH_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = 'RECEIPT EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));
    -- Update VRCTH for refund receipts that have been either disbursed or disbursement hold
    SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1';

    UPDATE RCTH_Y1
       SET RefundRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR)
      FROM RCTH_Y1 a
     WHERE ISNUMERIC(a.RefundRecipient_ID) = 1 
	   AND a.RefundRecipient_ID = @Ln_OthpEmplSecondary_IDNO
       AND EXISTS (SELECT 1
                     FROM (SELECT b.Batch_DATE,
                                  b.SourceBatch_CODE,
                                  b.Batch_NUMB,
                                  b.SeqReceipt_NUMB
                             FROM DHLD_Y1 b
                            WHERE ISNUMERIC(b.CheckRecipient_ID) = 1 
							  AND b.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
	                          AND b.CheckRecipient_CODE = '3'
                           UNION
                           SELECT c.Batch_DATE,
                                  c.SourceBatch_CODE,
                                  c.Batch_NUMB,
                                  c.SeqReceipt_NUMB
                             FROM DSBL_Y1 c
                            WHERE ISNUMERIC(c.CheckRecipient_ID) = 1 
							  AND c.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
							  AND c.CheckRecipient_CODE = '3')x
                    WHERE a.Batch_DATE = x.Batch_DATE
                      AND a.SourceBatch_CODE = x.SourceBatch_CODE
                      AND a.Batch_NUMB = x.Batch_NUMB
                      AND a.SeqReceipt_NUMB = x.SeqReceipt_NUMB);

    SET @Ls_Sql_TEXT = 'Rcth_CUR CURSOR';

    DECLARE Rcth_CUR CURSOR LOCAL FORWARD_ONLY FOR
     SELECT r.Batch_DATE,
            r.Batch_NUMB,
            r.SeqReceipt_NUMB,
            r.SourceBatch_CODE,
            r.EventGlobalBeginSeq_NUMB
       FROM RCTH_Y1 r
      WHERE ISNUMERIC(r.RefundRecipient_ID) = 1 
	    AND r.RefundRecipient_ID = @Ln_OthpEmplSecondary_IDNO
        AND r.Distribute_DATE = @Ld_Low_DATE
        AND r.StatusReceipt_CODE IN ('U', 'H')
        AND r.RefundRecipient_CODE = '3'
        AND r.ReasonStatus_CODE IN ('SNRP', 'USRP');

    OPEN Rcth_CUR;

    SET @Ls_Sql_TEXT = 'FETCH Rcth_CUR';

    FETCH NEXT FROM Rcth_CUR INTO @Ld_Batch_DATE, @Ln_Batch_NUMB, @Ln_SeqReceipt_NUMB, @Lc_SourceBatch_CODE, @Ln_EventGlobalBeginSeq_NUMB;

    SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS

    BEGIN
     WHILE @Li_FetchStatus_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = ' OLD EMPLOYER: ' + @Ln_OthpEmplSecondary_IDNO + ' NEW MEMBER: ' + @Ln_OthpEmplPrimary_IDNO + ' Batch_DATE: ' + CAST(@Ld_Batch_DATE AS VARCHAR(20)) + ' Batch_NUMB: ' + @Ln_Batch_NUMB + ' SeqReceipt_NUMB: ' + @Ln_SeqReceipt_NUMB + ' SourceBatch_CODE: ' + @Lc_SourceBatch_CODE + ' EventGlobalBeginSeq_NUMB: ' + @Ln_EventGlobalBeginSeq_NUMB;
       SET @Ls_Sql_TEXT = 'UPDATE RCTH_Y1';

       UPDATE RCTH_Y1
          SET RefundRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR)
        WHERE Batch_DATE = @Ld_Batch_DATE
          AND Batch_NUMB = @Ln_Batch_NUMB
          AND SeqReceipt_NUMB = @Ln_SeqReceipt_NUMB
          AND SourceBatch_CODE = @Lc_SourceBatch_CODE
          AND EventGlobalBeginSeq_NUMB = @Ln_EventGlobalBeginSeq_NUMB;

       FETCH NEXT FROM Rcth_CUR INTO @Ld_Batch_DATE, @Ln_Batch_NUMB, @Ln_SeqReceipt_NUMB, @Lc_SourceBatch_CODE, @Ln_EventGlobalBeginSeq_NUMB;

       SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS;
      END

     CLOSE Rcth_CUR;

     DEALLOCATE Rcth_CUR
    END

    --POFL- START          
    
    SET @Ls_Sql_TEXT = 'PAYEE_OFFSET_LOG  EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    -- Case Cursor Declaration  
    -- To get the Case updates in the System for IVE cases.
    DECLARE Pofl_CUR CURSOR LOCAL FORWARD_ONLY FOR
     SELECT SUM (PendOffset_AMNT) OVER (PARTITION BY TypeRecoupment_CODE, RecoupmentPayee_CODE) PendTotOffset_AMNT,
            SUM (AssessOverPay_AMNT) OVER (PARTITION BY TypeRecoupment_CODE, RecoupmentPayee_CODE ) AssessTotOverPay_AMNT,
            SUM (RecoverPay_AMNT) OVER (PARTITION BY TypeRecoupment_CODE, RecoupmentPayee_CODE) RecTotOverPay_AMNT,
            a.Unique_IDNO
       FROM POFL_Y1 a
      WHERE ISNUMERIC(a.CheckRecipient_ID) = 1 
	    AND a.CheckRecipient_ID IN (@Ln_OthpEmplPrimary_IDNO,@Ln_OthpEmplSecondary_IDNO)
	    AND a.CheckRecipient_CODE = '3'
      ORDER BY a.TypeRecoupment_CODE,
               a.RecoupmentPayee_CODE,
               a.Unique_IDNO;

    SET @Ls_Sql_TEXT = 'SELECT POFL COUNT - EMERG UPDATION LOG';

	SELECT @Ln_RowsAffected_NUMB = COUNT(1)
	  FROM POFL_Y1 a
	 WHERE ISNUMERIC(a.CheckRecipient_ID) = 1 
	  AND a.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
	  AND a.CheckRecipient_CODE = '3';

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
	   SET @Ls_Sql_TEXT = 'SELECT POFL Data for XML Logging';
       SELECT @Lx_XmlData_XML = (SELECT a.*,
                                        'U' merge_status
                                   FROM POFL_Y1 a
                                  WHERE ISNUMERIC(a.CheckRecipient_ID) = 1
                                    AND a.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                    AND a.CheckRecipient_CODE = '3'
                                 FOR XML PATH('ROWS'), TYPE);

       SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                           FROM (SELECT t.c.exist('ROWS') AS id
                                                   FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

       SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - POFL_Y1';

       INSERT EMLG_Y1
              (OthpEmplPrimary_IDNO,
               OthpEmplSecondary_IDNO,
               Table_NAME,
               RowsAffected_NUMB,
               TransactionEventSeq_NUMB,
               Merge_DATE,
               RowDataXml_TEXT)
       VALUES ( @Ln_OthpEmplPrimary_IDNO,
                @Ln_OthpEmplSecondary_IDNO,
                'POFL_Y1',
                @Ln_RowsAffected_NUMB,
                @An_TransactionEventSeq_NUMB,
                @Ad_Run_DATE,
                CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

       SET @Lx_XmlData_XML = NULL;
     
      -- Pofl_CUR Cursor
      OPEN Pofl_CUR;

      SET @Ls_Sql_TEXT = 'FETCH Pofl_CUR - 1';

      FETCH NEXT FROM Pofl_CUR INTO @Ln_PendTotOffset_AMNT, @Ln_AssessTotOverPay_AMNT, @Ln_RecTotOverPay_AMNT, @Ln_Unique_IDNO;

      SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS

      BEGIN
       WHILE @Li_FetchStatus_NUMB = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'UPDATE POFL_Y1 Failed';
         SET @Ls_Sqldata_TEXT = 'ID_CASE ' + @Ln_Case_IDNO + 'ID_MEMBER ' + @Ln_MemberMci_IDNO + 'TransactionEventSeq_NUMB' + @An_TransactionEventSeq_NUMB;

         UPDATE POFL_Y1
            SET CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR),
                PendTotOffset_AMNT = @Ln_PendTotOffset_AMNT,
                AssessTotOverPay_AMNT = @Ln_AssessTotOverPay_AMNT,
                RecTotOverPay_AMNT = @Ln_RecTotOverPay_AMNT
          WHERE Unique_IDNO = @Ln_Unique_IDNO;

         FETCH NEXT FROM Pofl_CUR INTO @Ln_PendTotOffset_AMNT, @Ln_AssessTotOverPay_AMNT, @Ln_RecTotOverPay_AMNT, @Ln_Unique_IDNO;

         SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS;
        END

       CLOSE Pofl_CUR;

       DEALLOCATE Pofl_CUR
      END
     END

    --POFL- END          
    ------------------------------------------------------------------------------------------------------
    --       Merge DISBURSEMENT tables
    ------------------------------------------------------------------------------------------------------
    -- Merge DISB START
    SET @Ls_Sql_TEXT = ' DSBH_Y1 EMERG UPDATION';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    DECLARE Dsbh_CUR CURSOR LOCAL FORWARD_ONLY FOR
     SELECT a.CheckRecipient_ID,
            a.CheckRecipient_CODE,
            a.Disburse_DATE,
            a.DisburseSeq_NUMB
       FROM DSBH_Y1 a
      WHERE ISNUMERIC(a.CheckRecipient_ID) = 1
        AND a.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
        AND a.CheckRecipient_CODE = '3'
        AND EXISTS (SELECT 1
                      FROM DSBH_Y1 b
                     WHERE ISNUMERIC(b.CheckRecipient_ID) = 1
					   AND b.CheckRecipient_ID = @Ln_OthpEmplPrimary_IDNO
                       AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
                       AND b.Disburse_DATE = a.Disburse_DATE
                       AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB)
      ORDER BY a.CheckRecipient_ID,
               a.CheckRecipient_CODE,
               a.Disburse_DATE,
               a.DisburseSeq_NUMB;
               
	SET @Ls_Sql_TEXT = 'SELECT DSBH_Y1 COUNT - EMERG UPDATION LOG';

   SELECT @Ln_RowsAffected_NUMB = COUNT(1)
     FROM DSBH_Y1 a
    WHERE ISNUMERIC(a.CheckRecipient_ID) = 1
	  AND a.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
      AND EXISTS (SELECT 1
                    FROM DSBH_Y1 b
                   WHERE ISNUMERIC(b.CheckRecipient_ID) = 1
					 AND b.CheckRecipient_ID = @Ln_OthpEmplPrimary_IDNO
                     AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
                     AND b.Disburse_DATE = a.Disburse_DATE
                     AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB);

   IF @Ln_RowsAffected_NUMB > 0
    BEGIN
     SELECT @Lx_XmlData_XML = (SELECT a.*,
                                      'U' merge_status
                                 FROM DSBH_Y1 a
                                WHERE ISNUMERIC(a.CheckRecipient_ID) = 1
								  AND a.CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                  AND EXISTS (SELECT 1
                                                FROM DSBH_Y1 b
                                               WHERE ISNUMERIC(b.CheckRecipient_ID) = 1
												 AND b.CheckRecipient_ID = @Ln_OthpEmplPrimary_IDNO
												 AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
                                                 AND b.Disburse_DATE = a.Disburse_DATE
                                                 AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB)
                               FOR XML PATH('ROWS'), TYPE);

     SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                         FROM (SELECT t.c.exist('ROWS') AS id
                                                 FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

     SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DSBH_Y1';

     INSERT EMLG_Y1
            (OthpEmplPrimary_IDNO,
             OthpEmplSecondary_IDNO,
             Table_NAME,
             RowsAffected_NUMB,
             TransactionEventSeq_NUMB,
             Merge_DATE,
             RowDataXml_TEXT)
     VALUES ( @Ln_OthpEmplPrimary_IDNO,
              @Ln_OthpEmplSecondary_IDNO,
              'DSBH_Y1',
              @Ln_RowsAffected_NUMB,
              @An_TransactionEventSeq_NUMB,
              @Ad_Run_DATE,
              CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

     SET @Lx_XmlData_XML = NULL;
    END

    OPEN Dsbh_CUR;

    SET @Ls_Sql_TEXT = 'FETCH CUR_DSBH';

    FETCH NEXT FROM Dsbh_CUR INTO @Lc_CheckRecipient_ID, @Lc_CheckRecipient_CODE, @Ld_Disburse_DATE, @Ln_DisburseSeq_NUMB;

    SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS

    BEGIN
     WHILE @Li_FetchStatus_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = ' SELECT DSBH_Y1 ';

       SELECT @Ln_DisbSeqMax_NUMB = MAX(d.DisburseSeq_NUMB) + 1
         FROM DSBH_Y1 d
        WHERE ISNUMERIC(d.CheckRecipient_ID) = 1
		  AND d.CheckRecipient_ID IN (@Ln_OthpEmplPrimary_IDNO, @Ln_OthpEmplSecondary_IDNO)
          AND d.CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND d.Disburse_DATE = @Ld_Disburse_DATE;

       SET @Ls_Sql_TEXT = ' UPDATE DSBH_Y1 ';

       UPDATE DSBH_Y1
          SET DisburseSeq_NUMB = @Ln_DisbSeqMax_NUMB,
              CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
        WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND Disburse_DATE = @Ld_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DisburseSeq_NUMB;

       SET @Ls_Sql_TEXT = ' UPDATE DSBL_Y1 ';

       UPDATE DSBL_Y1
          SET DisburseSeq_NUMB = @Ln_DisbSeqMax_NUMB,
              CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
        WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND Disburse_DATE = @Ld_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DisburseSeq_NUMB;

       SET @Ls_Sql_TEXT = ' UPDATE DADR_Y1 ';

       UPDATE DADR_Y1
          SET DisburseSeq_NUMB = @Ln_DisbSeqMax_NUMB,
              CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
        WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND Disburse_DATE = @Ld_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DisburseSeq_NUMB;

       SET @Ls_Sql_TEXT = ' UPDATE DEFT_Y1 ';

       UPDATE DEFT_Y1
          SET DisburseSeq_NUMB = @Ln_DisbSeqMax_NUMB,
              CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
        WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND Disburse_DATE = @Ld_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DisburseSeq_NUMB;

       --Update DSBC sequence--
       SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1 ';

       UPDATE DSBC_Y1
          SET DisburseSeq_NUMB = @Ln_DisbSeqMax_NUMB,
              CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
        WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND Disburse_DATE = @Ld_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DisburseSeq_NUMB;

       --Update DSBC original sequence--
       SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1 UPD2 ';

       UPDATE DSBC_Y1
          SET DisburseOrigSeq_NUMB = @Ln_DisbSeqMax_NUMB,
              CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
        WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND DisburseOrig_DATE = @Ld_Disburse_DATE
          AND DisburseOrigSeq_NUMB = @Ln_DisburseSeq_NUMB;

       --Update DHLD original sequence--
       SET @Ls_Sql_TEXT = ' UPDATE VDHLD ';

       UPDATE DHLD_Y1
          SET DisburseSeq_NUMB = @Ln_DisbSeqMax_NUMB,
              CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
        WHERE CheckRecipient_ID = @Lc_CheckRecipient_ID
          AND CheckRecipient_CODE = @Lc_CheckRecipient_CODE
          AND Disburse_DATE = @Ld_Disburse_DATE
          AND DisburseSeq_NUMB = @Ln_DisburseSeq_NUMB;

       FETCH NEXT FROM Dsbh_CUR INTO @Lc_CheckRecipient_ID, @Lc_CheckRecipient_CODE, @Ld_Disburse_DATE, @Ln_DisburseSeq_NUMB;

       SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS;
      END

     CLOSE Dsbh_CUR;

     DEALLOCATE Dsbh_CUR
    END

    --physical update for secondary recip-id
    SET @Ls_Sql_TEXT = 'SELECT DSBH_Y12 COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM DSBH_Y1
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM DSBH_Y1 a
                                 WHERE ISNUMERIC(CheckRecipient_ID) = 1
								  AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DSBH_Y12';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'DSBH_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = ' UPDATE VDSBH2 ';

    UPDATE DSBH_Y1
       SET CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    --Update DSBL
    SET @Ls_Sql_TEXT = 'SELECT DSBL_Y1 COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM DSBL_Y1
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM DSBL_Y1 a
                                 WHERE ISNUMERIC(CheckRecipient_ID) = 1
								   AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DSBL_Y1';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'DSBL_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = ' UPDATE VDSBL ';

    UPDATE DSBL_Y1
       SET CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    --Update DADR_Y1
    SET @Ls_Sql_TEXT = 'SELECT DADR COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM DADR_Y1
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM DADR_Y1 a
                                 WHERE ISNUMERIC(CheckRecipient_ID) = 1
								   AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DADR_Y1';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'DADR_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = ' UPDATE VDADR ';

    UPDATE DADR_Y1
       SET CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    --Update DEFT_Y1
    SET @Ls_Sql_TEXT = 'SELECT DEFT COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM DEFT_Y1
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM DEFT_Y1 a
                                 WHERE ISNUMERIC(CheckRecipient_ID) = 1
								   AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DEFT_Y1';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'DEFT_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = ' UPDATE DEFT_Y1';

    UPDATE DEFT_Y1
       SET CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    --Update DSBC_Y1
    SET @Ls_Sql_TEXT = 'SELECT DSBC COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM DSBC_Y1
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM DSBC_Y1 a
                                 WHERE ISNUMERIC(CheckRecipient_ID) = 1
								   AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DSBC_Y1';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'DSBC_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1 ';

    UPDATE DSBC_Y1
       SET CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    --Update DSBC_Y1 ORIG
    SET @Ls_Sql_TEXT = 'SELECT DSBC COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM DSBC_Y1
     WHERE ISNUMERIC(CheckRecipientOrig_ID) = 1
       AND CheckRecipientOrig_ID = @Ln_OthpEmplSecondary_IDNO;

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM DSBC_Y1 a
                                 WHERE ISNUMERIC(CheckRecipientOrig_ID) = 1
								   AND CheckRecipientOrig_ID = @Ln_OthpEmplSecondary_IDNO
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DSBC_Y1 ORIG';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'DSBC_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = ' UPDATE DSBC_Y1 ORIG ';

    UPDATE DSBC_Y1
       SET CheckRecipientOrig_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
     WHERE ISNUMERIC(CheckRecipientOrig_ID) = 1
       AND CheckRecipientOrig_ID = @Ln_OthpEmplSecondary_IDNO;

    --Update DHLD_Y1
    SET @Ls_Sql_TEXT = 'SELECT DHLD COUNT - EMERG UPDATION LOG';

    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM DHLD_Y1
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM DHLD_Y1 a
                                 WHERE ISNUMERIC(CheckRecipient_ID) = 1
								   AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - DHLD_Y1';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'DHLD_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = ' UPDATE DHLD';

    UPDATE DHLD_Y1
       SET CheckRecipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR(10))
     WHERE ISNUMERIC(CheckRecipient_ID) = 1
       AND CheckRecipient_ID = @Ln_OthpEmplSecondary_IDNO;

    -- Merge DISB END          
    -------------------------------------------------------------------------------------------------------
    -- OTHP -- OTHER_PARTY
    -------------------------------------------------------------------------------------------------------
    -- OTHP START
    SET @Ls_Sql_TEXT = 'OTHP EMERG ';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));

    IF EXISTS (SELECT 1
                 FROM OTHP_Y1
                WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO
                  AND EndValidity_DATE = @Ld_High_DATE)
     BEGIN
      --Update OTHP_Y1
      SET @Ls_Sql_TEXT = 'SELECT OTHP_Y1 COUNT - EMERG UPDATION LOG';

      SELECT @Ln_RowsAffected_NUMB = COUNT(1)
        FROM OTHP_Y1
       WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO
         AND EndValidity_DATE = @Ld_High_DATE;

      IF @Ln_RowsAffected_NUMB > 0
       BEGIN
        SELECT @Lx_XmlData_XML = (SELECT a.*,
                                         'U' merge_status
                                    FROM OTHP_Y1 a
                                   WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO
                                     AND EndValidity_DATE =@Ld_High_DATE
                                  FOR XML PATH('ROWS'), TYPE);

        SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                            FROM (SELECT t.c.exist('ROWS') AS id
                                                    FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

        SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - OTHP_Y1';

        INSERT EMLG_Y1
               (OthpEmplPrimary_IDNO,
                OthpEmplSecondary_IDNO,
                Table_NAME,
                RowsAffected_NUMB,
                TransactionEventSeq_NUMB,
                Merge_DATE,
                RowDataXml_TEXT)
        VALUES ( @Ln_OthpEmplPrimary_IDNO,
                 @Ln_OthpEmplSecondary_IDNO,
                 'OTHP_Y1',
                 @Ln_RowsAffected_NUMB,
                 @An_TransactionEventSeq_NUMB,
                 @Ad_Run_DATE,
                 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

        SET @Lx_XmlData_XML = NULL;
       END

      SET @Ls_Sql_TEXT = ' UPDATE OTHP_Y1';

      UPDATE OTHP_Y1
         SET EndValidity_DATE = @Ad_Run_DATE,
             NewOtherParty_IDNO = @Ln_OthpEmplPrimary_IDNO
       WHERE otherparty_IDNO = @Ln_OthpEmplSecondary_IDNO;

      IF @@ROWCOUNT = 0
       BEGIN
        SET @Ls_Sql_TEXT = 'OTHP_Y1 UPDATE FAILED';
        RAISERROR (50001,16,1);
       END
     END

    -- OTHP END         
    -------------------------------------------------------------------------------------------------
    -- ELFC -- ID_OTHP_SOURCE  
    -------------------------------------------------------------------------------------------------
    -- ELFC - START
    SET @Ls_Sql_TEXT = 'ELFC EMERG ';
    SET @Ls_Sqldata_TEXT = 'OthpEmplPrimary_IDNO: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10)) + 'OthpEmplSecondary_IDNO: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10));
    --Update ELFC_Y1
    SET @Ls_Sql_TEXT = 'SELECT ELFC COUNT - EMERG UPDATION LOG';

	-- 13691 - Merge to consider only Employer source from ELFC - Start
    SELECT @Ln_RowsAffected_NUMB = COUNT(1)
      FROM ELFC_Y1 a
     WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
       AND a.TypeChange_CODE IN (@Lc_TypeChangeMm_CODE, @Lc_TypeChangeEe_CODE, @Lc_TypeChangeEt_CODE, @Lc_TypeChangeIw_CODE, 
								@Lc_TypeChangeNm_CODE, @Lc_TypeChangeNs_CODE, @Lc_TypeChangeWt_CODE);

    IF @Ln_RowsAffected_NUMB > 0
     BEGIN
      SELECT @Lx_XmlData_XML = (SELECT a.*,
                                       'U' merge_status
                                  FROM ELFC_Y1 a
                                 WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
								   AND a.TypeChange_CODE IN (@Lc_TypeChangeMm_CODE, @Lc_TypeChangeEe_CODE, @Lc_TypeChangeEt_CODE, @Lc_TypeChangeIw_CODE, 
										@Lc_TypeChangeNm_CODE, @Lc_TypeChangeNs_CODE, @Lc_TypeChangeWt_CODE)
                                FOR XML PATH('ROWS'), TYPE);

      SELECT @Ln_RowsAffected_NUMB = (SELECT COUNT(*)
                                          FROM (SELECT t.c.exist('ROWS') AS id
                                                  FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

      SET @Ls_Sql_TEXT = ' INSERT INTO EMLG - ELFC_Y1';

      INSERT EMLG_Y1
             (OthpEmplPrimary_IDNO,
              OthpEmplSecondary_IDNO,
              Table_NAME,
              RowsAffected_NUMB,
              TransactionEventSeq_NUMB,
              Merge_DATE,
              RowDataXml_TEXT)
      VALUES ( @Ln_OthpEmplPrimary_IDNO,
               @Ln_OthpEmplSecondary_IDNO,
               'ELFC_Y1',
               @Ln_RowsAffected_NUMB,
               @An_TransactionEventSeq_NUMB,
               @Ad_Run_DATE,
               CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

      SET @Lx_XmlData_XML = NULL;
     END

    SET @Ls_Sql_TEXT = 'DELETE ELFC ';

    DELETE ELFC_Y1
      FROM ELFC_Y1 a
     WHERE a.OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
       AND a.TypeChange_CODE IN (@Lc_TypeChangeMm_CODE, @Lc_TypeChangeEe_CODE, @Lc_TypeChangeEt_CODE, @Lc_TypeChangeIw_CODE, 
										@Lc_TypeChangeNm_CODE, @Lc_TypeChangeNs_CODE, @Lc_TypeChangeWt_CODE)
       AND EXISTS (SELECT 1
                     FROM ELFC_Y1 b
                    WHERE b.MemberMci_IDNO = a.MemberMci_IDNO
                      AND b.Case_IDNO = a.Case_IDNO
                      AND b.OrderSeq_NUMB = a.OrderSeq_NUMB
                      AND b.typechange_CODE = a.typechange_CODE
                      AND b.OthpSource_IDNO = @Ln_OthpEmplPrimary_IDNO
                      AND b.process_DATE = a.process_DATE
                      AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);

    UPDATE ELFC_Y1
       SET OthpSource_IDNO = @Ln_OthpEmplPrimary_IDNO
     WHERE OthpSource_IDNO = @Ln_OthpEmplSecondary_IDNO
	   AND TypeChange_CODE IN (@Lc_TypeChangeMm_CODE, @Lc_TypeChangeEe_CODE, @Lc_TypeChangeEt_CODE, @Lc_TypeChangeIw_CODE, 
										@Lc_TypeChangeNm_CODE, @Lc_TypeChangeNs_CODE, @Lc_TypeChangeWt_CODE);
	-- 13691 - Merge to consider only Employer source from ELFC - End
    -- ELFC - END 
    
	--- NRRQ_Y1 Start
	--  PHYSICAL UPDATE ID_RECIPIENT - NRRQ_Y1 
	-- 13599 - String Numeric column and Numeric column comparison issue Fix  - Start
	SET @Ls_Sql_TEXT = 'NRRQ EMERG ';
	IF EXISTS (SELECT 1 FROM NRRQ_Y1 WHERE Recipient_CODE IN ('OE','SI') 
					AND ISNUMERIC(Recipient_ID) = 1
					AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO)
	BEGIN
		SET @Ls_Sql_TEXT = 'SELECT NRRQ COUNT - EMRG UPDATION LOG';
		
		SELECT @Ln_NrrqValidation_QNTY = COUNT(1) 
				FROM NRRQ_Y1 
				WHERE Recipient_CODE IN ('OE','SI') 
				  AND ISNUMERIC(Recipient_ID) = 1
				  AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO;
				  
		IF @Ln_NrrqValidation_QNTY >  0 
			BEGIN
				 SELECT @Lx_XmlData_XML = (SELECT a.*,
												 'U' merge_status
											FROM NRRQ_Y1 a
										   WHERE Recipient_CODE IN ('OE','SI') 
											 AND ISNUMERIC(Recipient_ID) = 1
											 AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO
										  FOR XML PATH('ROWS'), TYPE);
										  
			SELECT @Ln_NrrqValidation_QNTY = (SELECT COUNT(*)
                                        FROM (SELECT t.c.exist('ROWS') AS id
                                                FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
                                                
			SET @Ls_Sql_TEXT = 'INSERT INTO EMLG - NRRQ_Y1';  
			
				INSERT EMLG_Y1
				   (OthpEmplPrimary_IDNO,
					OthpEmplSecondary_IDNO,
					Table_NAME,
					RowsAffected_NUMB,
					TransactionEventSeq_NUMB,
					Merge_DATE,
					RowDataXml_TEXT)
				VALUES ( @Ln_OthpEmplPrimary_IDNO,
						 @Ln_OthpEmplSecondary_IDNO,
						 'NRRQ_Y1',
						 @Ln_NrrqValidation_QNTY,
						 @An_TransactionEventSeq_NUMB,
						 @Ad_Run_DATE,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

			SET @Lx_XmlData_XML = NULL;	  
			END
			
		SET @Ls_Sql_TEXT = 'UPDATE NRRQ_Y1 - 1';		
		
		UPDATE a			
               SET a.Recipient_ID = @Ln_OthpEmplPrimary_IDNO
            FROM NRRQ_Y1 a
             WHERE a.Recipient_CODE IN ('OE','SI') 
			   AND ISNUMERIC(Recipient_ID) = 1
			   AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO;
		
	END			
	-- 13599 - String Numeric column and Numeric column comparison issue Fix  - End				
	--- NRRQ_Y1 Ends
	--- NMRQ_Y1 Start
	--  PHYSICAL UPDATE ID_RECIPIENT - NMRQ_Y1 
	-- 13599 - String Numeric column and Numeric column comparison issue Fix  - Start
	SET @Ls_Sql_TEXT = 'NMRQ EMERG ';
	IF EXISTS (SELECT 1 FROM NMRQ_Y1 WHERE Recipient_CODE IN ('OE','SI') 
					AND ISNUMERIC(Recipient_ID) = 1
					AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO)
	BEGIN
		SET @Ls_Sql_TEXT = 'SELECT NMRQ COUNT - EMRG UPDATION LOG';
		
		SELECT @Ln_NMRQValidation_QNTY = COUNT(1) 
				FROM NMRQ_Y1 
				WHERE Recipient_CODE IN ('OE','SI') 
				  AND ISNUMERIC(Recipient_ID) = 1
					AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO;
				  
		IF @Ln_NMRQValidation_QNTY >  0 
			BEGIN
				 SELECT @Lx_XmlData_XML = (SELECT a.*,
												 'U' merge_status
											FROM NMRQ_Y1 a
										   WHERE Recipient_CODE IN ('OE','SI') 
											 AND ISNUMERIC(Recipient_ID) = 1
											 AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO
										  FOR XML PATH('ROWS'), TYPE);
										  
			SELECT @Ln_NMRQValidation_QNTY = (SELECT COUNT(*)
                                        FROM (SELECT t.c.exist('ROWS') AS id
                                                FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
                                                
			SET @Ls_Sql_TEXT = 'INSERT INTO EMLG - NMRQ_Y1';  
			
				INSERT EMLG_Y1
				   (OthpEmplPrimary_IDNO,
					OthpEmplSecondary_IDNO,
					Table_NAME,
					RowsAffected_NUMB,
					TransactionEventSeq_NUMB,
					Merge_DATE,
					RowDataXml_TEXT)
				VALUES ( @Ln_OthpEmplPrimary_IDNO,
						 @Ln_OthpEmplSecondary_IDNO,
						 'NMRQ_Y1',
						 @Ln_NMRQValidation_QNTY,
						 @An_TransactionEventSeq_NUMB,
						 @Ad_Run_DATE,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

			SET @Lx_XmlData_XML = NULL;	  
			END
			
		SET @Ls_Sql_TEXT = 'UPDATE NMRQ_Y1 - 1';		
		
		UPDATE a			
               SET a.Recipient_ID = CAST(@Ln_OthpEmplPrimary_IDNO AS VARCHAR)
            FROM NMRQ_Y1 a
             WHERE a.Recipient_CODE IN ('OE','SI') 
			   AND ISNUMERIC(Recipient_ID) = 1
			   AND Recipient_ID  = @Ln_OthpEmplSecondary_IDNO;
		
	END	
	-- 13599 - String Numeric column and Numeric column comparison issue Fix  - End						
	--- NMRQ_Y1 Ends	
	--  PHYSICAL UPDATE OthpSource_IDNO - EIWT_Y1 
	SET @Ls_Sql_TEXT = 'EIWT_Y1 EMRG ';
	
	IF EXISTS (SELECT 1 FROM EIWT_Y1 WHERE OthpSource_IDNO =  @Ln_OthpEmplSecondary_IDNO)
	BEGIN
		SET @Ls_Sql_TEXT = 'SELECT EIWT_Y1 COUNT - EMRG UPDATION LOG';
		
		--- Delete
		SELECT @Ln_EiwtValidation_QNTY = COUNT(1) 
				FROM EIWT_Y1 a
				WHERE OthpSource_IDNO =  @Ln_OthpEmplSecondary_IDNO
				AND EXISTS(SELECT 1 FROM EIWT_Y1 b 
							WHERE OthpSource_IDNO =  @Ln_OthpEmplPrimary_IDNO
								  AND b.Case_IDNO = a.Case_IDNO
								  AND b.IwSent_DATE = a.IwSent_DATE);
								  				  
		IF @Ln_EiwtValidation_QNTY >  0 
			BEGIN
				-- Delete
				 SELECT @Lx_XmlData_XML = (SELECT a.*,
												 'D' merge_status
											FROM EIWT_Y1 a
										   WHERE OthpSource_IDNO =  @Ln_OthpEmplSecondary_IDNO
											AND EXISTS(SELECT 1 FROM EIWT_Y1 b 
														WHERE OthpSource_IDNO =  @Ln_OthpEmplPrimary_IDNO
															  AND b.Case_IDNO = a.Case_IDNO
															  AND b.IwSent_DATE = a.IwSent_DATE)
										  FOR XML PATH('ROWS'), TYPE);
										  
			SELECT @Ln_EiwtValidation_QNTY = (SELECT COUNT(*)
                                        FROM (SELECT t.c.exist('ROWS') AS id
                                                FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
                                                
			SET @Ls_Sql_TEXT = 'INSERT INTO EMLG - EIWT_Y1';  
			
				INSERT EMLG_Y1
				   (OthpEmplPrimary_IDNO,
					OthpEmplSecondary_IDNO,
					Table_NAME,
					RowsAffected_NUMB,
					TransactionEventSeq_NUMB,
					Merge_DATE,
					RowDataXml_TEXT)
				VALUES ( @Ln_OthpEmplPrimary_IDNO,
						 @Ln_OthpEmplSecondary_IDNO,
						 'EIWT_Y1',
						 @Ln_EiwtValidation_QNTY,
						 @An_TransactionEventSeq_NUMB,
						 @Ad_Run_DATE,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

			SET @Lx_XmlData_XML = NULL;	  
			SET @Ln_EiwtValidation_QNTY = 0;
			
			SET @Ls_Sql_TEXT = 'DELETE EIWT_Y1 - 1';		
		
			DELETE EIWT_Y1 FROM EIWT_Y1 AS  a
	              WHERE OthpSource_IDNO =  @Ln_OthpEmplSecondary_IDNO
				  AND EXISTS(SELECT 1 FROM EIWT_Y1 b 
									WHERE OthpSource_IDNO =  @Ln_OthpEmplPrimary_IDNO
										  AND b.Case_IDNO = a.Case_IDNO
										  AND b.IwSent_DATE = a.IwSent_DATE);
			END
		
		--- Update 
		SELECT @Ln_EiwtValidation_QNTY = COUNT(1) 
				FROM EIWT_Y1 a
				WHERE OthpSource_IDNO =  @Ln_OthpEmplSecondary_IDNO
				AND NOT EXISTS(SELECT 1 FROM EIWT_Y1 b 
							WHERE OthpSource_IDNO =  @Ln_OthpEmplPrimary_IDNO
								  AND b.Case_IDNO = a.Case_IDNO
								  AND b.IwSent_DATE = a.IwSent_DATE);
								  				  
		IF @Ln_EiwtValidation_QNTY >  0 
			BEGIN
				-- Update
				 SELECT @Lx_XmlData_XML = (SELECT a.*,
												 'U' merge_status
											FROM EIWT_Y1 a
										   WHERE OthpSource_IDNO =  @Ln_OthpEmplSecondary_IDNO
											AND NOT EXISTS(SELECT 1 FROM EIWT_Y1 b 
																WHERE OthpSource_IDNO =  @Ln_OthpEmplPrimary_IDNO
																	  AND b.Case_IDNO = a.Case_IDNO
																	  AND b.IwSent_DATE = a.IwSent_DATE)
										  FOR XML PATH('ROWS'), TYPE);
										  
			SELECT @Ln_EiwtValidation_QNTY = (SELECT COUNT(*)
                                        FROM (SELECT t.c.exist('ROWS') AS id
                                                FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
                                                
			SET @Ls_Sql_TEXT = 'INSERT INTO EMLG - EIWT_Y1';  
			
				INSERT EMLG_Y1
				   (OthpEmplPrimary_IDNO,
					OthpEmplSecondary_IDNO,
					Table_NAME,
					RowsAffected_NUMB,
					TransactionEventSeq_NUMB,
					Merge_DATE,
					RowDataXml_TEXT)
				VALUES ( @Ln_OthpEmplPrimary_IDNO,
						 @Ln_OthpEmplSecondary_IDNO,
						 'EIWT_Y1',
						 @Ln_EiwtValidation_QNTY,
						 @An_TransactionEventSeq_NUMB,
						 @Ad_Run_DATE,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

			SET @Lx_XmlData_XML = NULL;	  
			END
			
		SET @Ls_Sql_TEXT = 'UPDATE EIWT_Y1 - 1';		
		
		UPDATE a			
               SET a.OthpSource_IDNO = @Ln_OthpEmplPrimary_IDNO
            FROM EIWT_Y1 a
              WHERE OthpSource_IDNO =  @Ln_OthpEmplSecondary_IDNO
			  AND NOT EXISTS(SELECT 1 FROM EIWT_Y1 b 
								WHERE OthpSource_IDNO =  @Ln_OthpEmplPrimary_IDNO
									  AND b.Case_IDNO = a.Case_IDNO
									  AND b.IwSent_DATE = a.IwSent_DATE);
		
	END							
	--- EIWT_Y1 Ends	
	--  PHYSICAL UPDATE OthpEmpl_IDNO - APEH_Y1 
	SET @Ls_Sql_TEXT = 'APEH_Y1 EMRG';
	
	IF EXISTS (SELECT 1 FROM APEH_Y1 WHERE OthpEmpl_IDNO =  @Ln_OthpEmplSecondary_IDNO)
	BEGIN
		SET @Ls_Sql_TEXT = 'SELECT APEH_Y1 COUNT - EMRG UPDATION LOG';
		
		SELECT @Ln_ApehValidation_QNTY = COUNT(1) 
				FROM APEH_Y1 
				WHERE OthpEmpl_IDNO =  @Ln_OthpEmplSecondary_IDNO;
				  
		IF @Ln_ApehValidation_QNTY >  0 
			BEGIN
				 SELECT @Lx_XmlData_XML = (SELECT a.*,
												 'U' merge_status
											FROM APEH_Y1 a
										   WHERE OthpEmpl_IDNO =  @Ln_OthpEmplSecondary_IDNO
										  FOR XML PATH('ROWS'), TYPE);
										  
			SELECT @Ln_ApehValidation_QNTY = (SELECT COUNT(*)
                                        FROM (SELECT t.c.exist('ROWS') AS id
                                                FROM @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
                                                
			SET @Ls_Sql_TEXT = 'INSERT INTO EMLG - APEH_Y1';  
			
				INSERT EMLG_Y1
					   (OthpEmplPrimary_IDNO,
						OthpEmplSecondary_IDNO,
						Table_NAME,
						RowsAffected_NUMB,
						TransactionEventSeq_NUMB,
						Merge_DATE,
						RowDataXml_TEXT)
				VALUES ( @Ln_OthpEmplPrimary_IDNO,
						 @Ln_OthpEmplSecondary_IDNO,
						 'APEH_Y1',
						 @Ln_ApehValidation_QNTY,
						 @An_TransactionEventSeq_NUMB,
						 @Ad_Run_DATE,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)));

			SET @Lx_XmlData_XML = NULL;	  
			END
			
		SET @Ls_Sql_TEXT = 'UPDATE APEH_Y1 - 1';		
		
		UPDATE a			
               SET a.OthpEmpl_IDNO = @Ln_OthpEmplPrimary_IDNO
            FROM APEH_Y1 a
              WHERE OthpEmpl_IDNO =  @Ln_OthpEmplSecondary_IDNO;
		
	END							
	--- APEH_Y1 Ends

    -------------------------------------------------------------------------------------------------
    -- CASE/EMERG -- INSERT ACTIVITY  
    -------------------------------------------------------------------------------------------------
    -- EMERG - START
    SET @Ls_Sql_TEXT = 'CASE CURSOR CMEM_Y1';

    OPEN Case_CUR;

    SET @Ls_Sql_TEXT = 'FETCH Case_CUR';

    FETCH NEXT FROM Case_CUR INTO @Ln_Case_IDNO;

    SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS

    BEGIN
     WHILE @Li_FetchStatus_NUMB = 0
      BEGIN
       SET @Ls_Sql_TEXT = 'CASE ID: ' + CAST (@Ln_Case_IDNO AS CHAR(10)) + ' OLD EMPLOYER: ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10)) + ' NEW MEMBER: ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10));
       SET @Ls_DescNote_TEXT = 'SECONDARY EMPLOYER ' + CAST(@Ln_OthpEmplSecondary_IDNO AS CHAR(10)) + ' MERGED WITH PRIMARY EMPLOYER ' + CAST(@Ln_OthpEmplPrimary_IDNO AS CHAR(10));
       SET @Ls_Sql_TEXT = 'SELECT WORKER - CASE';

       IF EXISTS (SELECT 1
                    FROM CASE_Y1
                   WHERE Case_IDNO = @Ln_Case_IDNO)
        BEGIN
         SELECT @Lc_Worker_ID = Worker_ID
           FROM CASE_Y1
          WHERE Case_IDNO = @Ln_Case_IDNO;
        END
       ELSE
        BEGIN
         SET @Lc_Worker_ID = ' ';
        END

       SET @Ls_Sql_TEXT = 'INSERTING ACTIVITY - CASE/EMERG - FOR EMPLOYER MERGE ';

       EXECUTE BATCH_COMMON$SP_INSERT_ACTIVITY
        @An_Case_IDNO                = @Ln_Case_IDNO,
        @An_MemberMci_IDNO           = 0,
        @Ac_ActivityMajor_CODE       = 'CASE',
        @Ac_ActivityMinor_CODE       = 'EMERG',
        @Ac_Subsystem_CODE           = 'CM',
        @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
        @Ac_WorkerUpdate_ID          = @Ls_BatchRunUser_TEXT,
        @Ac_WorkerDelegate_ID        = @Lc_Worker_ID,
        @Ad_Run_DATE                 = @Ld_Run_DATE,
        @An_TopicIn_IDNO             = 0,
        @An_Topic_IDNO               = @Ln_Topic_IDNO OUTPUT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT    = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_INSERT_ACTIVITY - CASE/EMERG - FAILED';

         RAISERROR(50001,16,1);
        END;

	    SET @Ls_Sql_TEXT = 'INSERTING NOTES - CASE/EMERG - FOR EMPLOYER MERGE ';
       INSERT NOTE_Y1
              (Case_IDNO,
               Topic_IDNO,
               Post_IDNO,
               MajorIntSeq_NUMB,
               MinorIntSeq_NUMB,
               Office_IDNO,
               Category_CODE,
               Subject_CODE,
               Callback_INDC,
               NotifySender_INDC,
               TypeContact_CODE,
               SourceContact_CODE,
               MethodContact_CODE,
               Status_CODE,
               TypeAssigned_CODE,
               WorkerAssigned_ID,
               RoleAssigned_ID,
               WorkerCreated_ID,
               Start_DATE,
               Due_DATE,
               Action_DATE,
               Received_DATE,
               OpenCases_CODE,
               DescriptionNote_TEXT,
               BeginValidity_DATE,
               EndValidity_DATE,
               WorkerUpdate_ID,
               TransactionEventSeq_NUMB,
               EventGlobalSeq_NUMB,
               Update_DTTM,
               TotalReplies_QNTY,
               TotalViews_QNTY)
       VALUES( @Ln_Case_IDNO,
               @Ln_Topic_IDNO,
               1,
               0,
               0,
               @Li_Zero_NUMB,
               @Lc_Space_TEXT,
               'EMERG',
               @Lc_Space_TEXT,
               'N',
               @Lc_Space_TEXT,
               @Lc_Space_TEXT,
               @Lc_Space_TEXT,
               @Lc_Space_TEXT,
               @Lc_Space_TEXT,
               @Lc_Space_TEXT,
               @Lc_Space_TEXT,
               @Ls_BatchRunUser_TEXT,
               @Ld_Low_DATE,
               @Ld_Low_DATE,
               @Ld_High_DATE,
               @Ld_High_DATE,
               @Lc_Space_TEXT,
               @Ls_DescNote_TEXT,
               @Ld_Run_DATE,
               @Ld_High_DATE,
               @Ls_BatchRunUser_TEXT,
               @An_TransactionEventSeq_NUMB,
               @Li_Zero_NUMB,
               @Ld_Current_DTTM,
               @Li_Zero_NUMB,
               @Li_Zero_NUMB);

       IF @@ROWCOUNT = 0
        BEGIN
         SET @Ls_Sql_TEXT = 'INSERTING NOTE TABLE - FOR EMERG - FAILED';

         RAISERROR(50001,16,1);
        END;

       FETCH NEXT FROM Case_CUR INTO @Ln_Case_IDNO;

       SELECT @Li_FetchStatus_NUMB = @@FETCH_STATUS;
      END

     CLOSE Case_CUR;

     DEALLOCATE Case_CUR
    END

    -- EMERG -- END
    
    END
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
  
   --Check for Exception information to log the description text based on the error
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = ISNULL(SUBSTRING(ERROR_MESSAGE(), 1, 200),' ')+ ISNULL(@Ls_DescriptionError_TEXT,'');;
    END

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
