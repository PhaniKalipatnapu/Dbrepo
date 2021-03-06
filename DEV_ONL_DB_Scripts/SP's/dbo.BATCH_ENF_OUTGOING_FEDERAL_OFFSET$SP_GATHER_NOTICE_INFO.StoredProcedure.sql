/****** Object:  StoredProcedure [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GATHER_NOTICE_INFO]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GATHER_NOTICE_INFO
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GATHER_NOTICE_INFO is 
					  to gather notice information
Frequency		:	'WEEKLY'
Developed On	:	4/19/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_ENF_OUTGOING_FEDERAL_OFFSET$SP_GATHER_NOTICE_INFO] (
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_Yes_INDC                  CHAR(1) = 'Y',
          @Lc_No_INDC                   CHAR(1) = 'N',
          @Lc_TypeTransactionD_CODE     CHAR(1) = 'D',
          @Lc_TypeTransactionI_CODE     CHAR(1) = 'I',
          @Lc_TypeTransactionA_CODE     CHAR(1) = 'A',
          @Lc_TypeTransactionEnf24_CODE CHAR(1) = '4',
          @Lc_TypeTransactionEnf25_CODE CHAR(1) = '5',
          @Lc_TypeTransactionEnf27_CODE CHAR(1) = '7',
          @Lc_TypeReferenceAdm_CODE     CHAR(5) = 'ADM',
          @Lc_TypeReferenceIns_CODE     CHAR(5) = 'INS',
          @Lc_TypeReferencePdc_CODE     CHAR(5) = 'PDC',
          @Lc_TypeReferenceFto_CODE     CHAR(5) = 'FTO',
          @Lc_ActivityMajorAren_CODE    CHAR(4) = 'AREN',
          @Lc_StatusStrt_CODE           CHAR(4) = 'STRT',
          @Lc_NoticeEnf24_ID            CHAR(6) = 'ENF-24',
          @Lc_NoticeEnf25_ID            CHAR(6) = 'ENF-25',
          @Lc_NoticeEnf27_ID            CHAR(6) = 'ENF-27',
          @Ls_Procedure_NAME            VARCHAR(100) = 'SP_GET_NOTICE_DATA',
          @Ld_Run_DATE                  DATE = @Ad_Run_DATE;
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @Ls_Sql_TEXT = 'DELETE #NoticeInfo_P1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM #NoticeInfo_P1;

   SET @Ls_Sql_TEXT = 'DELETE #PifmsDataForNotice_P1';
   SET @Ls_SqlData_TEXT = '';

   DELETE FROM #PifmsDataForNotice_P1;

   /* Scenario - 1
   	If
   		Case IRS Eligible, 
   		Case NOT in IFMS, 
   		Notice NOT in NRRQ,
   	Then
   		Keep this record in PIFMS,
   		Send ENF-24 Notice,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_Yes_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND 0 < (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM IFMS_Y1 B
                       WHERE B.Case_IDNO = A.Case_IDNO
                         AND B.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   /* Scenario - 2
   	If
   		Case IRS Eligible, 
   		Case NOT in IFMS, 
   		Notice in NRRQ,
   		35 days NOT past since Notice was last sent
   	Then
   		Delete this record from PIFMS,
   		Wait for 35 Days,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_Yes_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND NOT EXISTS (SELECT 1
                        FROM IFMS_Y1 B
                       WHERE B.Case_IDNO = A.Case_IDNO
                         AND B.MemberMci_IDNO = A.MemberMci_IDNO)
      AND (EXISTS (SELECT 1
                     FROM HIFMS_Y1 C
                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                      AND C.Case_IDNO = A.Case_IDNO
                      AND C.MemberMci_IDNO = A.MemberMci_IDNO
                      AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                          FROM HIFMS_Y1 D
                                                         WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                           AND D.Case_IDNO = C.Case_IDNO
                                                           AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                      AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
            OR (NOT EXISTS (SELECT 1
                              FROM HIFMS_Y1 C
                             WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                               AND C.Case_IDNO = A.Case_IDNO
                               AND C.MemberMci_IDNO = A.MemberMci_IDNO)
                AND EXISTS (SELECT 1
                              FROM NMRQ_Y1 C
                             WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
                               AND C.Recipient_ID = A.MemberMci_IDNO)))

   /* Scenario - 3
   	If
   		Case IRS Eligible, 
   		Case NOT in IFMS, 
   		Notice in NRRQ,
   		35 days past since Notice was last sent,
   		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   	Then
   		Keep this record in PIFMS,
   		Insert/Update this record in IFMS/FEDH,
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_Yes_INDC AS SendMemberInFile_INDC,
          @Lc_No_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND NOT EXISTS (SELECT 1
                        FROM IFMS_Y1 B
                       WHERE B.Case_IDNO = A.Case_IDNO
                         AND B.MemberMci_IDNO = A.MemberMci_IDNO)
      AND EXISTS (SELECT 1
                    FROM HIFMS_Y1 C
                   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                     AND C.Case_IDNO = A.Case_IDNO
                     AND C.MemberMci_IDNO = A.MemberMci_IDNO
                     AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                         FROM HIFMS_Y1 D
                                                        WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                          AND D.Case_IDNO = C.Case_IDNO
                                                          AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 E
                       WHERE E.Case_IDNO = A.Case_IDNO
                         AND E.MemberMci_IDNO = A.MemberMci_IDNO
                         AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                         AND E.Status_CODE = @Lc_StatusStrt_CODE
                         AND E.TypeReference_CODE = @Lc_TypeReferenceFto_CODE);

   /* Scenario - 4
   	If
   		Case ADM Eligible, 
   		Case NOT in IFMS, 
   		Notice NOT in NRRQ,
   	Then
   		Keep this record in PIFMS,
   		Send ENF-25 Notice,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_Yes_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND 150 <= (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM IFMS_Y1 B
                       WHERE B.Case_IDNO = A.Case_IDNO
                         AND B.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf25_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   /* Scenario - 5
   	If
   		Case ADM Eligible, 
   		Case NOT in IFMS, 
   		Notice in NRRQ,
   		35 days NOT past since Notice was last sent
   	Then
   		Delete this record from PIFMS,
   		Wait for 35 Days,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_Yes_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND NOT EXISTS (SELECT 1
                        FROM IFMS_Y1 B
                       WHERE B.Case_IDNO = A.Case_IDNO
                         AND B.MemberMci_IDNO = A.MemberMci_IDNO)
      AND (EXISTS (SELECT 1
                     FROM HIFMS_Y1 C
                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                      AND C.Case_IDNO = A.Case_IDNO
                      AND C.MemberMci_IDNO = A.MemberMci_IDNO
                      AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                          FROM HIFMS_Y1 D
                                                         WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                           AND D.Case_IDNO = C.Case_IDNO
                                                           AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                      AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
            OR (NOT EXISTS (SELECT 1
                              FROM HIFMS_Y1 C
                             WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                               AND C.Case_IDNO = A.Case_IDNO
                               AND C.MemberMci_IDNO = A.MemberMci_IDNO)
                AND EXISTS (SELECT 1
                              FROM NMRQ_Y1 C
                             WHERE C.Notice_ID = @Lc_NoticeEnf25_ID
                               AND C.Recipient_ID = A.MemberMci_IDNO)))

   /* Scenario - 6
   	If
   		Case ADM Eligible, 
   		Case NOT in IFMS, 
   		Notice in NRRQ,
   		35 days past since Notice was last sent,
   		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   	Then
   		Keep this record in PIFMS,
   		Insert/Update this record in IFMS/FEDH,
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_Yes_INDC AS SendMemberInFile_INDC,
          @Lc_No_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND NOT EXISTS (SELECT 1
                        FROM IFMS_Y1 B
                       WHERE B.Case_IDNO = A.Case_IDNO
                         AND B.MemberMci_IDNO = A.MemberMci_IDNO)
      AND EXISTS (SELECT 1
                    FROM HIFMS_Y1 C
                   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                     AND C.Case_IDNO = A.Case_IDNO
                     AND C.MemberMci_IDNO = A.MemberMci_IDNO
                     AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                         FROM HIFMS_Y1 D
                                                        WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                          AND D.Case_IDNO = C.Case_IDNO
                                                          AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 E
                       WHERE E.Case_IDNO = A.Case_IDNO
                         AND E.MemberMci_IDNO = A.MemberMci_IDNO
                         AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                         AND E.Status_CODE = @Lc_StatusStrt_CODE
                         AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferenceAdm_CODE));

   /* Scenario - 7
   	If
   		Case PAS Eligible, 
   		Case NOT in IFMS, 
   		Notice NOT in NRRQ,
   	Then
   		Keep this record in PIFMS,
   		Send ENF-27 Notice,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_Yes_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf27_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_Yes_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludePas_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
/* Commented for Bug-13374-CR0378 
      AND 2500 <= (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO 
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM IFMS_Y1 B
                       WHERE B.Case_IDNO = A.Case_IDNO
                         AND B.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO)
*/                         
/* ADD BEGIN for Bug-13374-CR0378 */
	AND 2500 <= 
	(
		--check whether member arrears >= 2500
		SELECT SUM(X.Transaction_AMNT) 
		FROM PIFMS_Y1 X
		WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
	)
	AND NOT EXISTS
	(
		--make sure that member doesn't exist in FEDH
		SELECT 1 FROM FEDH_Y1 X
		WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
	)
	AND NOT EXISTS
	(
		--make sure that member doesn't exist in HFEDH
		SELECT 1 FROM HFEDH_Y1 X
		WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
	)
	AND NOT EXISTS
	(
		--make sure that enf-27 never sent for the member
		SELECT 1 FROM HIFMS_Y1 X
		WHERE X.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
		AND X.MemberMci_IDNO = A.MemberMci_IDNO
	)
/* ADD END for Bug-13374-CR0378 */
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf27_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   --/* Scenario - 8
   --	If
   --		Case PAS Eligible, 
   --		Case NOT in IFMS, 
   --		Notice in NRRQ,
   --		35 days NOT past since Notice was last sent
   --	Then
   --		Delete this record from PIFMS,
   --		Wait for 35 Days,
   --		Don't send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_Yes_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_No_INDC AS SendMemberInFile_INDC,
   --       @Lc_Yes_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND NOT EXISTS (SELECT 1
   --                     FROM IFMS_Y1 B
   --                    WHERE B.Case_IDNO = A.Case_IDNO
   --                      AND B.MemberMci_IDNO = A.MemberMci_IDNO)
   --   AND (EXISTS (SELECT 1
   --                  FROM HIFMS_Y1 C
   --                 WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                   AND C.Case_IDNO = A.Case_IDNO
   --                   AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                   AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                       FROM HIFMS_Y1 D
   --                                                      WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                        AND D.Case_IDNO = C.Case_IDNO
   --                                                        AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                   AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
   --         OR (NOT EXISTS (SELECT 1
   --                           FROM HIFMS_Y1 C
   --                          WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                            AND C.Case_IDNO = A.Case_IDNO
   --                            AND C.MemberMci_IDNO = A.MemberMci_IDNO)
   --             AND EXISTS (SELECT 1
   --                           FROM NMRQ_Y1 C
   --                          WHERE C.Notice_ID = @Lc_NoticeEnf27_ID
   --                            AND C.Recipient_ID = A.MemberMci_IDNO)))

   --/* Scenario - 9
   --	If
   --		Case PAS Eligible, 
   --		Case NOT in IFMS, 
   --		Notice in NRRQ,
   --		35 days past since Notice was last sent,
   --		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   --	Then
   --		Keep this record in PIFMS,
   --		Insert/Update this record in IFMS/FEDH,
   --		Send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_No_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_Yes_INDC AS SendMemberInFile_INDC,
   --       @Lc_No_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND NOT EXISTS (SELECT 1
   --                     FROM IFMS_Y1 B
   --                    WHERE B.Case_IDNO = A.Case_IDNO
   --                      AND B.MemberMci_IDNO = A.MemberMci_IDNO)
   --   AND EXISTS (SELECT 1
   --                 FROM HIFMS_Y1 C
   --                WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                  AND C.Case_IDNO = A.Case_IDNO
   --                  AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                      FROM HIFMS_Y1 D
   --                                                     WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                       AND D.Case_IDNO = C.Case_IDNO
   --                                                       AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM DMJR_Y1 E
   --                    WHERE E.Case_IDNO = A.Case_IDNO
   --                      AND E.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
   --                      AND E.Status_CODE = @Lc_StatusStrt_CODE
   --                      AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferencePdc_CODE));

   /* Scenario - 10
   	If
   		Case IRS Eligible, 
   		Case in IFMS,
   		Transaction Type D in the previous run,
   		Notice NOT in NRRQ,
   	Then
   		Keep this record in PIFMS,
   		Send ENF-24 Notice,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_Yes_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND 0 < (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE
                                                          AND C.TypeTransaction_CODE IN ('A', 'M', 'D'))
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                     AND NOT EXISTS(SELECT 1 FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.TypeTransaction_CODE IN ('A', 'M')))
--member should not be sent in file without sending notice when d was sent in the last run
      AND 
(      EXISTS (SELECT 1
                    FROM HIFMS_Y1 C
                   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                     AND C.Case_IDNO = A.Case_IDNO
                     AND C.MemberMci_IDNO = A.MemberMci_IDNO
                     AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                         FROM HIFMS_Y1 D
                                                        WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                          AND D.Case_IDNO = C.Case_IDNO
                                                          AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 42)
	OR 
	(
		NOT EXISTS (SELECT 1
							FROM HIFMS_Y1 C
						   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
							 AND C.Case_IDNO = A.Case_IDNO
							 AND C.MemberMci_IDNO = A.MemberMci_IDNO)
		--AND EXISTS(SELECT 1 FROM NRRQ_Y1 C
		--WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
		--						 AND C.Recipient_ID = A.MemberMci_IDNO
  --       AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
  --                                           FROM NRRQ_Y1 D
  --                                          WHERE D.Notice_ID = C.Notice_ID
  --                                            AND D.Recipient_ID = C.Recipient_ID)
  --       AND DATEDIFF(D, CAST(C.Request_DTTM AS DATE), @Ld_Run_DATE) > 42)								 
	)
) 
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   /* Scenario - 11
   	If
   		Case IRS Eligible, 
   		Case in IFMS, 
   		Transaction Type D in the previous run,
   		Notice in NRRQ,
   		35 days NOT past since Notice was last sent
   	Then
   		Delete this record from PIFMS,
   		Wait for 35 Days,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_Yes_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE
                                                          AND C.TypeTransaction_CODE IN ('A', 'M', 'D'))
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                     AND NOT EXISTS(SELECT 1 FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.TypeTransaction_CODE IN ('A', 'M')))
      AND (EXISTS (SELECT 1
                     FROM HIFMS_Y1 C
                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                      AND C.Case_IDNO = A.Case_IDNO
                      AND C.MemberMci_IDNO = A.MemberMci_IDNO
                      AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                          FROM HIFMS_Y1 D
                                                         WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                           AND D.Case_IDNO = C.Case_IDNO
                                                           AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                      AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
            OR EXISTS (SELECT 1
                         FROM NMRQ_Y1 C
                        WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
                          AND C.Recipient_ID = A.MemberMci_IDNO))

   /* Scenario - 12
   	If
   		Case IRS Eligible, 
   		Case in IFMS,
   		Transaction Type D in the previous run, 
   		Notice in NRRQ,
   		35 days past since Notice was last sent,
   		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   	Then
   		Keep this record in PIFMS,
   		Insert/Update this record in IFMS/FEDH,
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_Yes_INDC AS SendMemberInFile_INDC,
          @Lc_No_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE
                                                          AND C.TypeTransaction_CODE IN ('A', 'M', 'D'))
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                     AND NOT EXISTS(SELECT 1 FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.TypeTransaction_CODE IN ('A', 'M')))
      AND EXISTS (SELECT 1
                    FROM HIFMS_Y1 C
                   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                     AND C.Case_IDNO = A.Case_IDNO
                     AND C.MemberMci_IDNO = A.MemberMci_IDNO
                     AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                         FROM HIFMS_Y1 D
                                                        WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                          AND D.Case_IDNO = C.Case_IDNO
                                                          AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 E
                       WHERE E.Case_IDNO = A.Case_IDNO
                         AND E.MemberMci_IDNO = A.MemberMci_IDNO
                         AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                         AND E.Status_CODE = @Lc_StatusStrt_CODE
                         AND E.TypeReference_CODE = @Lc_TypeReferenceFto_CODE);

   /* Scenario - 13
   	If
   		Case ADM Eligible, 
   		Case in IFMS,
   		Transaction Type D in the previous run, 
   		Notice NOT in NRRQ,
   	Then
   		Keep this record in PIFMS,
   		Send ENF-25 Notice,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_Yes_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND 150 <= (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE
                                                          AND C.TypeTransaction_CODE IN ('A', 'M', 'D'))
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                     AND NOT EXISTS(SELECT 1 FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.TypeTransaction_CODE IN ('A', 'M')))
--member should not be sent in file without sending notice when d was sent in the last run
      AND 
(      EXISTS (SELECT 1
                    FROM HIFMS_Y1 C
                   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                     AND C.Case_IDNO = A.Case_IDNO
                     AND C.MemberMci_IDNO = A.MemberMci_IDNO
                     AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                         FROM HIFMS_Y1 D
                                                        WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                          AND D.Case_IDNO = C.Case_IDNO
                                                          AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 42)
	OR 
	(
		NOT EXISTS (SELECT 1
							FROM HIFMS_Y1 C
						   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
							 AND C.Case_IDNO = A.Case_IDNO
							 AND C.MemberMci_IDNO = A.MemberMci_IDNO)
		--AND EXISTS(SELECT 1 FROM NRRQ_Y1 C
		--WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
		--						 AND C.Recipient_ID = A.MemberMci_IDNO
  --       AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
  --                                           FROM NRRQ_Y1 D
  --                                          WHERE D.Notice_ID = C.Notice_ID
  --                                            AND D.Recipient_ID = C.Recipient_ID)
  --       AND DATEDIFF(D, CAST(C.Request_DTTM AS DATE), @Ld_Run_DATE) > 42)								 
	)
)
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf25_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   /* Scenario - 14
   	If
   		Case ADM Eligible, 
   		Case in IFMS,
   		Transaction Type D in the previous run, 
   		Notice in NRRQ,
   		35 days NOT past since Notice was last sent
   	Then
   		Delete this record from PIFMS,
   		Wait for 35 Days,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_Yes_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE
                                                          AND C.TypeTransaction_CODE IN ('A', 'M', 'D'))
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                     AND NOT EXISTS(SELECT 1 FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.TypeTransaction_CODE IN ('A', 'M')))
      AND (EXISTS (SELECT 1
                     FROM HIFMS_Y1 C
                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                      AND C.Case_IDNO = A.Case_IDNO
                      AND C.MemberMci_IDNO = A.MemberMci_IDNO
                      AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                          FROM HIFMS_Y1 D
                                                         WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                           AND D.Case_IDNO = C.Case_IDNO
                                                           AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                      AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
            OR EXISTS (SELECT 1
                         FROM NMRQ_Y1 C
                        WHERE C.Notice_ID = @Lc_NoticeEnf25_ID
                          AND C.Recipient_ID = A.MemberMci_IDNO))

   /* Scenario - 15
   	If
   		Case ADM Eligible, 
   		Case in IFMS,
   		Transaction Type D in the previous run, 
   		Notice in NRRQ,
   		35 days past since Notice was last sent,
   		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   	Then
   		Keep this record in PIFMS,
   		Insert/Update this record in IFMS/FEDH,
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_Yes_INDC AS SendMemberInFile_INDC,
          @Lc_No_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE
                                                          AND C.TypeTransaction_CODE IN ('A', 'M', 'D'))
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE
                     AND NOT EXISTS(SELECT 1 FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.TypeTransaction_CODE IN ('A', 'M')))
      AND EXISTS (SELECT 1
                    FROM HIFMS_Y1 C
                   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                     AND C.Case_IDNO = A.Case_IDNO
                     AND C.MemberMci_IDNO = A.MemberMci_IDNO
                     AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                         FROM HIFMS_Y1 D
                                                        WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                          AND D.Case_IDNO = C.Case_IDNO
                                                          AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 E
                       WHERE E.Case_IDNO = A.Case_IDNO
                         AND E.MemberMci_IDNO = A.MemberMci_IDNO
                         AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                         AND E.Status_CODE = @Lc_StatusStrt_CODE
                         AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferenceAdm_CODE));

   /* Scenario - 16
   	If
   		Case PAS Eligible, 
   		Case in IFMS,
   		Transaction Type D in the previous run,  
   		Notice NOT in NRRQ,
   	Then
   		Keep this record in PIFMS,
   		Send ENF-27 Notice,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_Yes_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf27_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_Yes_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludePas_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
/* Commented for Bug-13374-CR0378	      
      AND 2500 <= (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE)
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE)
      AND EXISTS (SELECT 1
                    FROM HIFMS_Y1 C
                   WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
                     AND C.Case_IDNO = A.Case_IDNO
                     AND C.MemberMci_IDNO = A.MemberMci_IDNO
                     AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                         FROM HIFMS_Y1 D
                                                        WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                          AND D.Case_IDNO = C.Case_IDNO
                                                          AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                     AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 42)
*/
/* ADD BEGIN for Bug-13374-CR0378 */
	AND 2500 <= 
	(
		--check whether member arrears >= 2500
		SELECT SUM(X.Transaction_AMNT) 
		FROM PIFMS_Y1 X
		WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
	)		
	AND EXISTS
	(
		--check whether the member is currently D in FEDH
		SELECT 1 FROM FEDH_Y1 X
		WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
		AND X.TypeTransaction_CODE = 'D'
		AND X.RejectInd_INDC = 'N'
		AND NOT EXISTS
		(
			--make sure that only D record exists for the member
			SELECT 1 FROM FEDH_Y1 C
			WHERE C.MemberMci_IDNO = X.MemberMci_IDNO
			AND C.TypeTransaction_CODE IN ('A', 'M')
			AND C.RejectInd_INDC = 'N'
		)
		AND NOT EXISTS 
		(
			--make sure that no enf-27 sent for the member after delete
			SELECT 1 FROM HIFMS_Y1 C
			WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
			AND C.MemberMci_IDNO = X.MemberMci_IDNO
			AND C.SubmitLast_DATE > X.SubmitLast_DATE
		)  	
	)
/* ADD END for Bug-13374-CR0378 */
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf27_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   --/* Scenario - 17
   --	If
   --		Case PAS Eligible, 
   --		Case in IFMS, 
   --		Transaction Type D in the previous run,
   --		Notice in NRRQ,
   --		35 days NOT past since Notice was last sent
   --	Then
   --		Delete this record from PIFMS,
   --		Wait for 35 Days,
   --		Don't send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_Yes_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_No_INDC AS SendMemberInFile_INDC,
   --       @Lc_Yes_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE)
   --   AND (EXISTS (SELECT 1
   --                  FROM HIFMS_Y1 C
   --                 WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                   AND C.Case_IDNO = A.Case_IDNO
   --                   AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                   AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                       FROM HIFMS_Y1 D
   --                                                      WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                        AND D.Case_IDNO = C.Case_IDNO
   --                                                        AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                   AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
   --         OR EXISTS (SELECT 1
   --                      FROM NMRQ_Y1 C
   --                     WHERE C.Notice_ID = @Lc_NoticeEnf27_ID
   --                       AND C.Recipient_ID = A.MemberMci_IDNO))

   --/* Scenario - 18
   --	If
   --		Case PAS Eligible, 
   --		Case in IFMS, 
   --		Transaction Type D in the previous run, 
   --		Notice in NRRQ,
   --		35 days past since Notice was last sent,
   --		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   --	Then
   --		Keep this record in PIFMS,
   --		Insert/Update this record in IFMS/FEDH,
   --		Send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_No_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_Yes_INDC AS SendMemberInFile_INDC,
   --       @Lc_No_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE = @Lc_TypeTransactionD_CODE)
   --   AND EXISTS (SELECT 1
   --                 FROM HIFMS_Y1 C
   --                WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                  AND C.Case_IDNO = A.Case_IDNO
   --                  AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                      FROM HIFMS_Y1 D
   --                                                     WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                       AND D.Case_IDNO = C.Case_IDNO
   --                                                       AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM DMJR_Y1 E
   --                    WHERE E.Case_IDNO = A.Case_IDNO
   --                      AND E.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
   --                      AND E.Status_CODE = @Lc_StatusStrt_CODE
   --                      AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferencePdc_CODE));

   /* Scenario - 19
   	If
   		Case IRS Eligible, 
   		Case in IFMS, 
   		Transaction Type NOT D in the previous run,
   		Notice in NRRQ,
   		12 months past since Notice was last sent
   	Then
   		Keep this record in PIFMS,
   		Send ENF-24 Notice (Annual),
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_Yes_INDC AS SendAnnualNotice_INDC,
          @Lc_Yes_INDC AS SendMemberInFile_INDC,
          @Lc_No_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND 0 < (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     --AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                     --                                    FROM IFMS_Y1 C
                     --                                   WHERE C.Case_IDNO = B.Case_IDNO
                     --                                     AND C.MemberMci_IDNO = B.MemberMci_IDNO
                     --                                     AND C.SubmitLast_DATE < @Ld_Run_DATE)
                     --AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
                     AND B.TypeTransaction_CODE IN ('A', 'M'))
      AND (EXISTS (SELECT 1
                     FROM HIFMS_Y1 C
                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                      AND C.Case_IDNO = A.Case_IDNO
                      AND C.MemberMci_IDNO = A.MemberMci_IDNO
                      AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                          FROM HIFMS_Y1 D
                                                         WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
                                                           AND D.Case_IDNO = C.Case_IDNO
                                                           AND D.MemberMci_IDNO = C.MemberMci_IDNO)
                      AND DATEDIFF(D, CAST(C.SubmitLast_DATE AS DATE), @Ld_Run_DATE) >= 365)
            --OR (NOT EXISTS (SELECT 1
            --                  FROM HIFMS_Y1 C
            --                 WHERE C.Case_IDNO = A.Case_IDNO
            --                   AND C.MemberMci_IDNO = A.MemberMci_IDNO)
            --    AND EXISTS (SELECT 1
            --                  FROM IFMS_Y1 B
            --                 WHERE B.Case_IDNO = A.Case_IDNO
            --                   AND B.MemberMci_IDNO = A.MemberMci_IDNO
            --                   AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
            --                                                       FROM IFMS_Y1 C
            --                                                      WHERE C.Case_IDNO = B.Case_IDNO
            --                                                        AND C.MemberMci_IDNO = B.MemberMci_IDNO
            --                                                        AND C.SubmitLast_DATE < @Ld_Run_DATE)
            --                   AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
            --                   AND B.WorkerUpdate_ID = 'CONVERSION'
            --                   AND DATEDIFF(D, CAST(B.SubmitLast_DATE AS DATE), @Ld_Run_DATE) >= 365))
            OR (NOT EXISTS (SELECT 1
                              FROM HIFMS_Y1 C
                             WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                               AND C.Case_IDNO = A.Case_IDNO
                               AND C.MemberMci_IDNO = A.MemberMci_IDNO)
                --AND EXISTS (SELECT 1
                --              FROM HIFMS_Y1 B
                --             WHERE B.Case_IDNO = A.Case_IDNO
                --               AND B.MemberMci_IDNO = A.MemberMci_IDNO
                --               AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MIN(C.TransactionEventSeq_NUMB)
                --                                                   FROM HIFMS_Y1 C
                --                                                  WHERE C.Case_IDNO = B.Case_IDNO
                --                                                    AND C.MemberMci_IDNO = B.MemberMci_IDNO
                --                                                    AND C.SubmitLast_DATE < @Ld_Run_DATE)
                --               AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
                --               AND B.WorkerUpdate_ID = 'CONVERSION'
                --               AND DATEDIFF(D, CAST(B.SubmitLast_DATE AS DATE), @Ld_Run_DATE) >= 365)
                AND EXISTS (SELECT 1
                              FROM NRRQ_Y1 C
                             WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
                               --AND C.Case_IDNO = A.Case_IDNO
                               AND C.Recipient_ID = A.MemberMci_IDNO
                               AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
                                                                   FROM NRRQ_Y1 D
                                                                  WHERE D.Notice_ID = C.Notice_ID
                                                                    --AND D.Case_IDNO = C.Case_IDNO
                                                                    AND D.Recipient_ID = C.Recipient_ID)
                               AND DATEDIFF(D, CAST(C.Request_DTTM AS DATE), @Ld_Run_DATE) >= 365)))
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf24_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   --/* Scenario - 20
   --	If
   --		Case ADM Eligible in the current run, 
   --		Case in IFMS,
   --		Transaction Type NOT D in the previous run, 
   --		Case NOT ADM Eligible in the previous run,
   --		Notice NOT in NRRQ,
   --	Then
   --		Keep this record in PIFMS,
   --		Send ENF-25 Notice,
   --		Don't send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_Yes_INDC AS AdmEligible_INDC,
   --       @Lc_No_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf25_ID AS Notice_ID,
   --       @Lc_No_INDC AS WaitFor35Days_INDC,
   --       @Lc_Yes_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_No_INDC AS SendMemberInFile_INDC,
   --       @Lc_Yes_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludeAdm_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND 150 <= (SELECT SUM(X.Transaction_AMNT)
   --              FROM PIFMS_Y1 X
   --             WHERE X.Case_IDNO = A.Case_IDNO
   --               AND X.MemberMci_IDNO = A.MemberMci_IDNO)
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
   --                  AND B.ExcludeAdm_CODE <> @Lc_No_INDC)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM HIFMS_Y1 C
   --                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
   --                      AND C.Case_IDNO = A.Case_IDNO
   --                      AND C.MemberMci_IDNO = A.MemberMci_IDNO)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM NMRQ_Y1 C
   --                    WHERE C.Notice_ID = @Lc_NoticeEnf25_ID
   --                      AND C.Recipient_ID = A.MemberMci_IDNO)

   --/* Scenario - 21
   --	If
   --		Case ADM Eligible in the current run,
   --		Case in IFMS,
   --		Transaction Type NOT D in the previous run, 
   --		Case NOT ADM Eligible in the previous run,
   --		Notice in NRRQ,
   --		35 days NOT past since Notice was last sent
   --	Then
   --		Delete this record from PIFMS,
   --		Wait for 35 Days,
   --		Don't send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_Yes_INDC AS AdmEligible_INDC,
   --       @Lc_No_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf25_ID AS Notice_ID,
   --       @Lc_Yes_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_No_INDC AS SendMemberInFile_INDC,
   --       @Lc_Yes_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludeAdm_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
   --                  AND B.ExcludeAdm_CODE <> @Lc_No_INDC)
   --   AND (EXISTS (SELECT 1
   --                  FROM HIFMS_Y1 C
   --                 WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
   --                   AND C.Case_IDNO = A.Case_IDNO
   --                   AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                   AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                       FROM HIFMS_Y1 D
   --                                                      WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                        AND D.Case_IDNO = C.Case_IDNO
   --                                                        AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                   AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
   --         OR (NOT EXISTS (SELECT 1
   --                           FROM HIFMS_Y1 C
   --                          WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
   --                            AND C.Case_IDNO = A.Case_IDNO
   --                            AND C.MemberMci_IDNO = A.MemberMci_IDNO)
   --             AND EXISTS (SELECT 1
   --                           FROM NMRQ_Y1 C
   --                          WHERE C.Notice_ID = @Lc_NoticeEnf25_ID
   --                            AND C.Recipient_ID = A.MemberMci_IDNO)))

   --/* Scenario - 22
   --	If
   --		Case ADM Eligible in the current run,
   --		Case in IFMS,
   --		Transaction Type NOT D in the previous run, 
   --		Case NOT ADM Eligible in the previous run,
   --		Notice in NRRQ,
   --		35 days past since Notice was last sent,
   --		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   --	Then
   --		Keep this record in PIFMS,
   --		Insert/Update this record in IFMS/FEDH,
   --		Send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_Yes_INDC AS AdmEligible_INDC,
   --       @Lc_No_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf25_ID AS Notice_ID,
   --       @Lc_No_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_Yes_INDC AS SendMemberInFile_INDC,
   --       @Lc_No_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludeAdm_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
   --                  AND B.ExcludeAdm_CODE <> @Lc_No_INDC)
   --   AND EXISTS (SELECT 1
   --                 FROM HIFMS_Y1 C
   --                WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
   --                  AND C.Case_IDNO = A.Case_IDNO
   --                  AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                      FROM HIFMS_Y1 D
   --                                                     WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                       AND D.Case_IDNO = C.Case_IDNO
   --                                                       AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM DMJR_Y1 E
   --                    WHERE E.Case_IDNO = A.Case_IDNO
   --                      AND E.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
   --                      AND E.Status_CODE = @Lc_StatusStrt_CODE
   --                      AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferenceAdm_CODE));

   /* Scenario - 23
   	If
   		Case PAS Eligible in the current run, 
   		Case in IFMS,
   		Transaction Type NOT D in the previous run, 
   		Case NOT PAS Eligible in the previous run,
   		Notice NOT in NRRQ,
   	Then
   		Keep this record in PIFMS,
   		Send ENF-27 Notice,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_Yes_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf27_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_Yes_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_No_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludePas_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
/* Commented for Bug-13374-CR0378      
      AND 2500 <= (SELECT SUM(X.Transaction_AMNT)
                 FROM PIFMS_Y1 X
                WHERE X.Case_IDNO = A.Case_IDNO
                  AND X.MemberMci_IDNO = A.MemberMci_IDNO)
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                                                         FROM IFMS_Y1 C
                                                        WHERE C.Case_IDNO = B.Case_IDNO
                                                          AND C.MemberMci_IDNO = B.MemberMci_IDNO
                                                          AND C.SubmitLast_DATE < @Ld_Run_DATE)
                     AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
                     AND B.ExcludePas_CODE <> @Lc_No_INDC)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO)
*/
/* ADD BEGIN for Bug-13374-CR0378 */
AND 2500 <= 
(
	--check whether member arrears >= 2500
	SELECT SUM(X.Transaction_AMNT) 
	FROM PIFMS_Y1 X
	WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
)
AND EXISTS
(
	--make sure that member is currently NOT D in FEDH
	SELECT 1 FROM FEDH_Y1 X
	WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
	AND X.TypeTransaction_CODE IN ('A', 'M')
	AND X.RejectInd_INDC = 'N'
)
AND NOT EXISTS
(
	--make sure that member doesn't come from conversion in FEDH
	SELECT 1 FROM FEDH_Y1 X
	WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
	AND X.WorkerUpdate_ID = 'CONVERSION'
)
AND NOT EXISTS
(
	--make sure that member doesn't come from conversion in HFEDH
	SELECT 1 FROM HFEDH_Y1 X
	WHERE X.MemberMci_IDNO = A.MemberMci_IDNO
	AND X.WorkerUpdate_ID = 'CONVERSION'
)
AND NOT EXISTS
(
	--make sure that enf-27 never sent for the member
	SELECT 1 FROM HIFMS_Y1 X
	WHERE X.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
	AND X.MemberMci_IDNO = A.MemberMci_IDNO
)
/* ADD END for Bug-13374-CR0378 */
      AND NOT EXISTS (SELECT 1
                        FROM NMRQ_Y1 C
                       WHERE C.Notice_ID = @Lc_NoticeEnf27_ID
                         AND C.Recipient_ID = A.MemberMci_IDNO)

   --/* Scenario - 24
   --	If
   --		Case PAS Eligible in the current run,
   --		Case in IFMS,
   --		Transaction Type NOT D in the previous run, 
   --		Case NOT PAS Eligible in the previous run,
   --		Notice in NRRQ,
   --		35 days NOT past since Notice was last sent
   --	Then
   --		Delete this record from PIFMS,
   --		Wait for 35 Days,
   --		Don't send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_Yes_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_No_INDC AS SendMemberInFile_INDC,
   --       @Lc_Yes_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
   --                  AND B.ExcludePas_CODE <> @Lc_No_INDC)
   --   AND (EXISTS (SELECT 1
   --                  FROM HIFMS_Y1 C
   --                 WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                   AND C.Case_IDNO = A.Case_IDNO
   --                   AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                   AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                       FROM HIFMS_Y1 D
   --                                                      WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                        AND D.Case_IDNO = C.Case_IDNO
   --                                                        AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                   AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
   --         OR (NOT EXISTS (SELECT 1
   --                           FROM HIFMS_Y1 C
   --                          WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                            AND C.Case_IDNO = A.Case_IDNO
   --                            AND C.MemberMci_IDNO = A.MemberMci_IDNO)
   --             AND EXISTS (SELECT 1
   --                           FROM NMRQ_Y1 C
   --                          WHERE C.Notice_ID = @Lc_NoticeEnf27_ID
   --                            AND C.Recipient_ID = A.MemberMci_IDNO)))

   --/* Scenario - 25
   --	If
   --		Case PAS Eligible in the current run,
   --		Case in IFMS,
   --		Transaction Type NOT D in the previous run, 
   --		Case NOT PAS Eligible in the previous run,
   --		Notice in NRRQ,
   --		35 days past since Notice was last sent,
   --		Memeber NOT in DMJR with Open AREN activity and FTO Reference Type
   --	Then
   --		Keep this record in PIFMS,
   --		Insert/Update this record in IFMS/FEDH,
   --		Send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_No_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_Yes_INDC AS SendMemberInFile_INDC,
   --       @Lc_No_INDC AS DeleteFromPifms_INDC,
   --       @Lc_No_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
   --                  AND B.ExcludePas_CODE <> @Lc_No_INDC)
   --   AND EXISTS (SELECT 1
   --                 FROM HIFMS_Y1 C
   --                WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                  AND C.Case_IDNO = A.Case_IDNO
   --                  AND C.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
   --                                                      FROM HIFMS_Y1 D
   --                                                     WHERE D.TypeTransaction_CODE = C.TypeTransaction_CODE
   --                                                       AND D.Case_IDNO = C.Case_IDNO
   --                                                       AND D.MemberMci_IDNO = C.MemberMci_IDNO)
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) > 35
   --                  AND DATEDIFF(D, C.SubmitLast_DATE, @Ld_Run_DATE) <= 42)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM DMJR_Y1 E
   --                    WHERE E.Case_IDNO = A.Case_IDNO
   --                      AND E.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
   --                      AND E.Status_CODE = @Lc_StatusStrt_CODE
   --                      AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferencePdc_CODE));

   /* Scenario - 26
   	If
   		Case IRS Eligible, 
   		Case in IFMS, 
   		Transaction Type NOT D in the previous run,
   		Notice NOT in NRRQ, (means it is conversion data)
   		Transaction Type is I (Initial)
   		35 days NOT past since the set Last Submit Date for conversion data in IFMS 
   	Then
   		Delete this record from PIFMS,
   		Wait for 35 Days,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_Yes_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_Yes_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     --AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                     --                                    FROM IFMS_Y1 C
                     --                                   WHERE C.Case_IDNO = B.Case_IDNO
                     --                                     AND C.MemberMci_IDNO = B.MemberMci_IDNO
                     --                                     AND C.SubmitLast_DATE < @Ld_Run_DATE)
                     --AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE --Initial
                     AND DATEDIFF(D, B.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO);

   /* Scenario - 27
   	If
   		Case IRS Eligible, 
   		Case in IFMS, 
   		Transaction Type NOT D in the previous run,
   		Notice NOT in NRRQ, (means it is conversion data)
   		Transaction Type is I (Initial)
   		35 days past since the set Last Submit Date for conversion data in IFMS 
   	Then
   		Keep this record in PIFMS,
   		Insert/Update this record in IFMS/FEDH,
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_Yes_INDC AS IrsEligible_INDC,
          @Lc_No_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf24_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_Yes_INDC AS SendMemberInFile_INDC,
          @Lc_No_INDC AS DeleteFromPifms_INDC,
          @Lc_Yes_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     --AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                     --                                    FROM IFMS_Y1 C
                     --                                   WHERE C.Case_IDNO = B.Case_IDNO
                     --                                     AND C.MemberMci_IDNO = B.MemberMci_IDNO
                     --                                     AND C.SubmitLast_DATE < @Ld_Run_DATE)
                     --AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE --Initial
                     AND DATEDIFF(D, B.SubmitLast_DATE, @Ld_Run_DATE) > 35)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf24_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 E
                       WHERE E.Case_IDNO = A.Case_IDNO
                         AND E.MemberMci_IDNO = A.MemberMci_IDNO
                         AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                         AND E.Status_CODE = @Lc_StatusStrt_CODE
                         AND E.TypeReference_CODE = @Lc_TypeReferenceFto_CODE);

   /* Scenario - 28
   	If
   		Case ADM Eligible, 
   		Case in IFMS, 
   		Transaction Type NOT D in the previous run,
   		Notice NOT in NRRQ, (means it is conversion data)
   		Transaction Type is I (Initial)
   		35 days NOT past since the set Last Submit Date for conversion data in IFMS 
   	Then
   		Delete this record from PIFMS,
   		Wait for 35 Days,
   		Don't send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_Yes_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_No_INDC AS SendMemberInFile_INDC,
          @Lc_Yes_INDC AS DeleteFromPifms_INDC,
          @Lc_Yes_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     --AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                     --                                    FROM IFMS_Y1 C
                     --                                   WHERE C.Case_IDNO = B.Case_IDNO
                     --                                     AND C.MemberMci_IDNO = B.MemberMci_IDNO
                     --                                     AND C.SubmitLast_DATE < @Ld_Run_DATE)
                     --AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE --Initial
                     AND DATEDIFF(D, B.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO);

   /* Scenario - 29
   	If
   		Case ADM Eligible, 
   		Case in IFMS, 
   		Transaction Type NOT D in the previous run,
   		Notice NOT in NRRQ, (means it is conversion data)
   		Transaction Type is I (Initial)
   		35 days past since the set Last Submit Date for conversion data in IFMS 
   	Then
   		Keep this record in PIFMS,
   		Insert/Update this record in IFMS/FEDH,
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #NoticeInfo_P1
          (Case_IDNO,
           MemberMci_IDNO,
           IrsEligible_INDC,
           AdmEligible_INDC,
           PasEligible_INDC,
           Notice_ID,
           WaitFor35Days_INDC,
           SendNotice_INDC,
           SendAnnualNotice_INDC,
           SendMemberInFile_INDC,
           DeleteFromPifms_INDC,
           ConversionData_INDC)
   SELECT A.Case_IDNO,
          A.MemberMci_IDNO,
          @Lc_No_INDC AS IrsEligible_INDC,
          @Lc_Yes_INDC AS AdmEligible_INDC,
          @Lc_No_INDC AS PasEligible_INDC,
          @Lc_NoticeEnf25_ID AS Notice_ID,
          @Lc_No_INDC AS WaitFor35Days_INDC,
          @Lc_No_INDC AS SendNotice_INDC,
          @Lc_No_INDC AS SendAnnualNotice_INDC,
          @Lc_Yes_INDC AS SendMemberInFile_INDC,
          @Lc_No_INDC AS DeleteFromPifms_INDC,
          @Lc_Yes_INDC AS ConversionData_INDC
     FROM PIFMS_Y1 A
    WHERE A.ExcludeIrs_CODE = 'N'
      AND A.ExcludeAdm_CODE = @Lc_No_INDC
      AND A.SubmitLast_DATE = @Ld_Run_DATE
      AND EXISTS (SELECT 1
                    FROM IFMS_Y1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     --AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
                     --                                    FROM IFMS_Y1 C
                     --                                   WHERE C.Case_IDNO = B.Case_IDNO
                     --                                     AND C.MemberMci_IDNO = B.MemberMci_IDNO
                     --                                     AND C.SubmitLast_DATE < @Ld_Run_DATE)
                     --AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
                     AND B.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE --Initial
                     AND DATEDIFF(D, B.SubmitLast_DATE, @Ld_Run_DATE) > 35)
      AND NOT EXISTS (SELECT 1
                        FROM HIFMS_Y1 C
                       WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf25_CODE
                         AND C.Case_IDNO = A.Case_IDNO
                         AND C.MemberMci_IDNO = A.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 E
                       WHERE E.Case_IDNO = A.Case_IDNO
                         AND E.MemberMci_IDNO = A.MemberMci_IDNO
                         AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
                         AND E.Status_CODE = @Lc_StatusStrt_CODE
                         AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferenceAdm_CODE));

   --/* Scenario - 30
   --	If
   --		Case PAS Eligible, 
   --		Case in IFMS, 
   --		Transaction Type NOT D in the previous run,
   --		Notice NOT in NRRQ, (means it is conversion data)
   --		Transaction Type is I (Initial)
   --		35 days NOT past since the set Last Submit Date for conversion data in IFMS 
   --	Then
   --		Delete this record from PIFMS,
   --		Wait for 35 Days,
   --		Don't send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_Yes_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_No_INDC AS SendMemberInFile_INDC,
   --       @Lc_Yes_INDC AS DeleteFromPifms_INDC,
   --       @Lc_Yes_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
   --                  AND B.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE --Initial
   --                  AND DATEDIFF(D, B.SubmitLast_DATE, @Ld_Run_DATE) <= 35)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM HIFMS_Y1 C
   --                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                      AND C.Case_IDNO = A.Case_IDNO
   --                      AND C.MemberMci_IDNO = A.MemberMci_IDNO);

   --/* Scenario - 31
   --	If
   --		Case PAS Eligible, 
   --		Case in IFMS, 
   --		Transaction Type NOT D in the previous run,
   --		Notice NOT in NRRQ, (means it is conversion data)
   --		Transaction Type is I (Initial)
   --		35 days past since the set Last Submit Date for conversion data in IFMS 
   --	Then
   --		Keep this record in PIFMS,
   --		Insert/Update this record in IFMS/FEDH,
   --		Send the Member in File
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --INSERT #NoticeInfo_P1
   --       (Case_IDNO,
   --        MemberMci_IDNO,
   --        IrsEligible_INDC,
   --        AdmEligible_INDC,
   --        PasEligible_INDC,
   --        Notice_ID,
   --        WaitFor35Days_INDC,
   --        SendNotice_INDC,
   --        SendAnnualNotice_INDC,
   --        SendMemberInFile_INDC,
   --        DeleteFromPifms_INDC,
   --        ConversionData_INDC)
   --SELECT A.Case_IDNO,
   --       A.MemberMci_IDNO,
   --       @Lc_No_INDC AS IrsEligible_INDC,
   --       @Lc_No_INDC AS AdmEligible_INDC,
   --       @Lc_Yes_INDC AS PasEligible_INDC,
   --       @Lc_NoticeEnf27_ID AS Notice_ID,
   --       @Lc_No_INDC AS WaitFor35Days_INDC,
   --       @Lc_No_INDC AS SendNotice_INDC,
   --       @Lc_No_INDC AS SendAnnualNotice_INDC,
   --       @Lc_Yes_INDC AS SendMemberInFile_INDC,
   --       @Lc_No_INDC AS DeleteFromPifms_INDC,
   --       @Lc_Yes_INDC AS ConversionData_INDC
   --  FROM PIFMS_Y1 A
   -- WHERE A.ExcludeIrs_CODE = 'N'
   --   AND A.ExcludePas_CODE = @Lc_No_INDC
   --   AND A.SubmitLast_DATE = @Ld_Run_DATE
   --   AND EXISTS (SELECT 1
   --                 FROM IFMS_Y1 B
   --                WHERE B.Case_IDNO = A.Case_IDNO
   --                  AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --                  AND B.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(C.TransactionEventSeq_NUMB)
   --                                                      FROM IFMS_Y1 C
   --                                                     WHERE C.Case_IDNO = B.Case_IDNO
   --                                                       AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --                                                       AND C.SubmitLast_DATE < @Ld_Run_DATE)
   --                  AND B.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
   --                  AND B.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE --Initial
   --                  AND DATEDIFF(D, B.SubmitLast_DATE, @Ld_Run_DATE) > 35)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM HIFMS_Y1 C
   --                    WHERE C.TypeTransaction_CODE = @Lc_TypeTransactionEnf27_CODE
   --                      AND C.Case_IDNO = A.Case_IDNO
   --                      AND C.MemberMci_IDNO = A.MemberMci_IDNO)
   --   AND NOT EXISTS (SELECT 1
   --                     FROM DMJR_Y1 E
   --                    WHERE E.Case_IDNO = A.Case_IDNO
   --                      AND E.MemberMci_IDNO = A.MemberMci_IDNO
   --                      AND E.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
   --                      AND E.Status_CODE = @Lc_StatusStrt_CODE
   --                      AND E.TypeReference_CODE IN (@Lc_TypeReferenceFto_CODE, @Lc_TypeReferencePdc_CODE));

   --SELECT '#NoticeInfo_P1', * FROM #NoticeInfo_P1
   /*
   	Store PIFMS data for which the notice has to be sent
   */
   SET @Ls_SqlData_TEXT = '';

   INSERT #PifmsDataForNotice_P1
          (MemberMci_IDNO,
           Case_IDNO,
           MemberSsn_NUMB,
           Last_NAME,
           First_NAME,
           Middle_NAME,
           TaxYear_NUMB,
           TypeArrear_CODE,
           Transaction_AMNT,
           SubmitLast_DATE,
           TypeTransaction_CODE,
           CountySubmitted_IDNO,
           Certified_DATE,
           StateAdministration_CODE,
           ExcludeIrs_CODE,
           ExcludeAdm_CODE,
           ExcludeFin_CODE,
           ExcludePas_CODE,
           ExcludeRet_CODE,
           ExcludeSal_CODE,
           ExcludeDebt_CODE,
           ExcludeVen_CODE,
           ExcludeIns_CODE,
           Submit_INDC,
           CurrentAction_INDC)
   SELECT A.MemberMci_IDNO,
          A.Case_IDNO,
          A.MemberSsn_NUMB,
          A.Last_NAME,
          A.First_NAME,
          A.Middle_NAME,
          A.TaxYear_NUMB,
          A.TypeArrear_CODE,
          A.Transaction_AMNT,
          A.SubmitLast_DATE,
          A.TypeTransaction_CODE,
          A.CountySubmitted_IDNO,
          A.Certified_DATE,
          A.StateAdministration_CODE,
          A.ExcludeIrs_CODE,
          A.ExcludeAdm_CODE,
          A.ExcludeFin_CODE,
          A.ExcludePas_CODE,
          A.ExcludeRet_CODE,
          A.ExcludeSal_CODE,
          A.ExcludeDebt_CODE,
          A.ExcludeVen_CODE,
          A.ExcludeIns_CODE,
          A.Submit_INDC,
          A.CurrentAction_INDC
     FROM PIFMS_Y1 A
    WHERE EXISTS (SELECT 1
                    FROM #NoticeInfo_P1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND (B.SendNotice_INDC = @Lc_Yes_INDC
                           OR B.SendAnnualNotice_INDC = @Lc_Yes_INDC));

   /*
   	Delete the records from PIFMS 
   	for which
   		the notice has to be sent (NOT Annual Notice)
   		there is a wait for 35 days...
   */
   SET @Ls_SqlData_TEXT = 'DeleteFromPifms_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', WaitFor35Days_INDC = ' + ISNULL(@Lc_Yes_INDC, '') + ', SendNotice_INDC = ' + ISNULL(@Lc_Yes_INDC, '');

   DELETE A
     FROM PIFMS_Y1 A
    WHERE EXISTS (SELECT 1
                    FROM #NoticeInfo_P1 B
                   WHERE B.Case_IDNO = A.Case_IDNO
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND (B.DeleteFromPifms_INDC = @Lc_Yes_INDC AND B.Notice_ID <> @Lc_NoticeEnf27_ID)
                     AND (B.WaitFor35Days_INDC = @Lc_Yes_INDC
                           OR B.SendNotice_INDC = @Lc_Yes_INDC));

   --/*
   --	Update Exclusion Codes for ADM/INS/PAS in PIFMS for records that has Open AREN activity in DMJR 
   --	with Reference Type other than FTO (ADM/INS/PDC)
   --*/
   --SET @Ls_SqlData_TEXT = '';

   --UPDATE A
   --   SET A.ExcludeAdm_CODE = A.DerivedExcludeAdm_CODE,
   --       A.ExcludeIns_CODE = A.DerivedExcludeIns_CODE,
   --       A.ExcludePas_CODE = A.DerivedExcludePas_CODE
   --  FROM (SELECT A.ExcludeAdm_CODE,
   --               A.ExcludeIns_CODE,
   --               A.ExcludePas_CODE,
   --               CASE
   --                WHEN C.TypeReference_CODE = @Lc_TypeReferenceAdm_CODE
   --                 THEN @Lc_Yes_INDC
   --                ELSE A.ExcludeAdm_CODE
   --               END AS DerivedExcludeAdm_CODE,
   --               CASE
   --                WHEN C.TypeReference_CODE = @Lc_TypeReferenceIns_CODE
   --                 THEN @Lc_Yes_INDC
   --                ELSE A.ExcludeIns_CODE
   --               END AS DerivedExcludeIns_CODE,
   --               CASE
   --                WHEN C.TypeReference_CODE = @Lc_TypeReferencePdc_CODE
   --                 THEN @Lc_Yes_INDC
   --                ELSE A.ExcludePas_CODE
   --               END AS DerivedExcludePas_CODE
   --          FROM PIFMS_Y1 A,
   --               #NoticeInfo_P1 B,
   --               DMJR_Y1 C
   --         WHERE B.Case_IDNO = A.Case_IDNO
   --           AND B.MemberMci_IDNO = A.MemberMci_IDNO
   --           AND B.SendMemberInFile_INDC = @Lc_Yes_INDC
   --           AND B.SendAnnualNotice_INDC = @Lc_No_INDC
   --           AND C.Case_IDNO = B.Case_IDNO
   --           AND C.MemberMci_IDNO = B.MemberMci_IDNO
   --           AND C.ActivityMajor_CODE = @Lc_ActivityMajorAren_CODE
   --           AND C.Status_CODE = @Lc_StatusStrt_CODE
   --           AND C.TypeReference_CODE <> @Lc_TypeReferenceFto_CODE
   --           AND C.TypeReference_CODE IN (@Lc_TypeReferenceAdm_CODE, @Lc_TypeReferenceIns_CODE, @Lc_TypeReferencePdc_CODE)) A;

   /*
   	If
   		Case in IFMS,
   		Transaction Type NOT D in the previous run,
   		Notice NOT in NRRQ, (means it is conversion data)
   		Transaction Type is I (Initial)
   		35 days past since the set Last Submit Date for conversion data in IFMS
   	Then
   		Set Transaction Type in PIFMS to I to Create an Add record in IFMS/FEDH,
   		Send the Member in File
   */
   SET @Ls_SqlData_TEXT = '';

   UPDATE A
      SET A.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE,
          A.CurrentAction_INDC = @Lc_TypeTransactionI_CODE
     FROM (SELECT B.TypeTransaction_CODE,
                  B.CurrentAction_INDC
             FROM #NoticeInfo_P1 A,
                  PIFMS_Y1 B,
                  IFMS_Y1 C
            WHERE A.ConversionData_INDC = @Lc_Yes_INDC
              AND A.SendMemberInFile_INDC = @Lc_Yes_INDC
              AND A.SendAnnualNotice_INDC = @Lc_No_INDC
              AND B.Case_IDNO = A.Case_IDNO
              AND B.MemberMci_IDNO = A.MemberMci_IDNO
              AND C.Case_IDNO = B.Case_IDNO
              AND C.MemberMci_IDNO = B.MemberMci_IDNO
              --AND C.TransactionEventSeq_NUMB = (SELECT TOP 1 MAX(D.TransactionEventSeq_NUMB)
              --                                    FROM IFMS_Y1 D
              --                                   WHERE D.Case_IDNO = C.Case_IDNO
              --                                     AND D.MemberMci_IDNO = C.MemberMci_IDNO
              --                                     AND D.SubmitLast_DATE < @Ld_Run_DATE)
              --AND C.TypeTransaction_CODE <> @Lc_TypeTransactionD_CODE
              AND C.TypeTransaction_CODE = @Lc_TypeTransactionI_CODE --Initial
          ) A;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
