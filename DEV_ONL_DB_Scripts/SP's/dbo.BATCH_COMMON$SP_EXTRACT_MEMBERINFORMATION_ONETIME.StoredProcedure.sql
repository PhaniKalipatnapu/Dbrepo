/****** Object:  StoredProcedure [dbo].[BATCH_COMMON$SP_EXTRACT_MEMBERINFORMATION_ONETIME]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_COMMON$SP_EXTRACT_MEMBERINFORMATION_ONETIME
Programmer Name 	: IMP Team
Description			: Modifies and/or adds data on DHSS programs that a client is enrolled in
						1.)	MCI Number -> Starts 1  -  Ends 10  
						2.)	DHSS Division Code -> Starts 11- Ends 13 -- 'DCS'
						3.)	Division Application Service Number ->  Starts 14 - Ends 17 -- 8500
						4.)	Client Case Status Code - Starts 18- Ends 18
						5.)	Client Participant Status Code - Starts 19- Ends 19
						6.)	Client Case Start Date - Starts 20- Ends 29
						7.)	Client Case End Date - Starts 30- Ends 39
						8.)	End Date Empty Indicator - Starts 40- Ends 41
Frequency			: 'ONETIME'
Developed On		:	04/12/2011
Called BY			: 
Called On			: 
--------------------------------------------------------------------------------------------------------------------
Modified BY			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_COMMON$SP_EXTRACT_MEMBERINFORMATION_ONETIME] 
AS
 BEGIN 
	 SET NOCOUNT ON;

	    DECLARE  @Lc_StatusFailed_CODE      CHAR(1) = 'F',
           @Lc_StatusSuccess_CODE			CHAR(1) = 'S',
           @Lc_StatusAbnormalEnd_CODE		CHAR(1) = 'A',
           @Lc_BatchRunUser_TEXT			CHAR(5) = 'BATCH',
           @Lc_Job_ID						CHAR(7) = 'ONTIME',
           @Ls_FileName_NAME				VARCHAR(50) = 'EXTRACTMEMBERINFORMATIONONETIME.TXT',           
           @Ls_Procedure_NAME				VARCHAR(100) = 'BATCH_COMMON$SP_EXTRACT_MEMBERINFORMATION_ONETIME',
           @Ld_Run_DATE						DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE  @Ln_Error_NUMB					NUMERIC(11) = 0,
           @Ln_ErrorLine_NUMB				NUMERIC(11) = 0,
           @Lc_Empty_TEXT					CHAR = '',
           @Lc_Msg_CODE						CHAR(5),
           @Ls_FileLocation_TEXT			VARCHAR(80) = '',
           @Ls_Sql_TEXT						VARCHAR(100) = '',
           @Ls_ErrorMessage_TEXT			VARCHAR(200),
           @Ls_SqlData_TEXT					VARCHAR(1000) = '',
           @Ls_Query_TEXT					VARCHAR(1000),
           @Ls_DescriptionError_TEXT		VARCHAR(4000);
				
					  
	 BEGIN TRY
		
		CREATE TABLE ##ExtractMember_P1
		(
		  Record_TEXT CHAR(42)
		);    
		
		
		SET @Ls_Sql_TEXT = 'SELECT  FROM ENVG_Y1'; 
		SELECT TOP 1 @Ls_FileLocation_TEXT =  OutputPath_TEXT FROM ENVG_Y1;
		
		
		SET @Ls_Sql_TEXT = 'File Location'; 
		SET @Ls_FileLocation_TEXT = @Ls_FileLocation_TEXT + '\decssinternal\';
		
		SET @Ls_Sql_TEXT = 'INSERT INTO ##ExtractMember_P1';
		SET @Ls_Sqldata_TEXT = '';
		
		
		INSERT INTO ##ExtractMember_P1 (Record_TEXT)
		SELECT MemberMci_IDNO + DHSS_Division_CODE +DivisionApplicationService_NUMB+ClientCaseStatus_CODE + ClientParticipantStatus_CODE+
		RIGHT(('             ' + LTRIM(RTRIM(CaseStart_DATE))), 10) + RIGHT(('          ' + LTRIM(RTRIM(CaseClosed_DATE))), 10) + RIGHT(('  ' + LTRIM(RTRIM(EndDateEmpty_INDC))), 2)
				 FROM (
				SELECT RIGHT(('0000000000' + LTRIM(RTRIM(e.MemberMci_IDNO))), 10) AS MemberMci_IDNO,
					   DHSS_Division_CODE,
					   DivisionApplicationService_NUMB,
					   ClientCaseStatus_CODE,
					   CASE WHEN ClientCaseStatus_CODE = 'A' 
							THEN 'A'
						ELSE 'I' END AS ClientParticipantStatus_CODE,
						CASE WHEN CaseStart_DATE <> '01-01-0001'
							THEN CONVERT(CHAR(10), CaseStart_DATE)
						ELSE '          ' END AS CaseStart_DATE ,
						CASE WHEN CaseClosed_DATE <> '01-01-0001'
							THEN CONVERT(CHAR(10), CaseClosed_DATE)
						ELSE '          ' END AS CaseClosed_DATE,
						CASE WHEN CaseClosed_DATE <> '01-01-0001'
							 THEN ' 0'
						ELSE '-1' END AS EndDateEmpty_INDC		
				FROM(
				SELECT MemberMci_IDNO,
					   'DCS' AS DHSS_Division_CODE,
					   '8500' AS DivisionApplicationService_NUMB, 
					   CASE WHEN d.StatusCase_CODE =  'O' AND d.CaseMemberStatus_CODE = 'A' THEN
								'A'
							ELSE
								'C' 
							END AS ClientCaseStatus_CODE,
						CASE WHEN (d.StatusCase_CODE =  'O' OR d.StatusCase_CODE =  'C') THEN
							d.CaseStart_DATE
						 ELSE '01-01-0001' 
						 END CaseStart_DATE,
						 CASE WHEN d.StatusCase_CODE =  'C' THEN
							d.CaseClosed_DATE
						 ELSE '01-01-0001' 
						 END CaseClosed_DATE			
					FROM (SELECT s.MemberMci_IDNO, s.Case_IDNO,s.CaseMemberStatus_CODE, s.StatusCase_CODE,
							ISNULL((SELECT MIN(Opened_DATE) FROM 
										CMEM_Y1  a
									 JOIN CASE_Y1 b
									  ON a.Case_IDNO = b.Case_IDNO	
									WHERE MEMBERMCI_IDNO = s.MemberMci_IDNO
									  AND b.StatusCase_CODE  = s.StatusCase_CODE
										 ),'01-01-0001') AS CaseStart_DATE,
							ISNULL((SELECT MAX(StatusCurrent_DATE) FROM 
										CMEM_Y1  a
									 JOIN CASE_Y1 b
									  ON a.Case_IDNO = b.Case_IDNO	
									WHERE MEMBERMCI_IDNO = s.MemberMci_IDNO
										 AND b.StatusCase_CODE='C'),'01-01-0001') AS CaseClosed_DATE
						FROM ( SELECT d.MemberMci_IDNO, c.Case_IDNO,c.CaseRelationship_CODE,c.CaseMemberStatus_CODE,a.StatusCase_CODE,
									ROW_NUMBER() OVER(PARTITION BY c.MemberMci_IDNO ORDER BY a.StatusCase_CODE DESC,c.CaseMemberStatus_CODE) AS CaseStatusRank_NUMB
										FROM DEMO_Y1 d
										LEFT OUTER JOIN CMEM_Y1 c
											on d.MemberMci_IDNO = c.MemberMci_IDNO
										LEFT OUTER JOIN CASE_Y1 a 
											on a.Case_IDNO = c.Case_IDNO	
										WHERE d.WorkerUpdate_ID = 'CONVERSION')s
							WHERE CaseStatusRank_NUMB = 1)d)e)f;
			
		SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractMember_P1 a';
		SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
		SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + @Ls_FileLocation_TEXT + ', File_NAME = ' + @Ls_FileName_NAME + ', Query_TEXT = ' + @Ls_Query_TEXT;

		EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
		@As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
		@As_File_NAME             = @Ls_FileName_NAME,
		@As_Query_TEXT            = @Ls_Query_TEXT,
		@Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
		@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
		
		IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		BEGIN
			SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA FAILED';
			RAISERROR (50001,16,1);
		END;
		
		SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractMember_P1';

		DROP TABLE ##ExtractMember_P1;
		
	 END TRY
	 BEGIN CATCH
		IF OBJECT_ID('tempdb..##ExtractMember_P1') IS NOT NULL
			BEGIN
				DROP TABLE ##ExtractMember_P1;
			END;

		SET @Ln_Error_NUMB = ERROR_NUMBER();
		SET @Ln_ErrorLine_NUMB = ERROR_LINE();
		SET @Ls_ErrorMessage_TEXT = ISNULL(@Ls_DescriptionError_TEXT,ERROR_MESSAGE());
		
		EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
				@As_Procedure_NAME        = @Ls_Procedure_NAME,
				@As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
				@As_Sql_TEXT              = @Ls_Sql_TEXT,
				@As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
				@An_Error_NUMB            = @Ln_Error_NUMB,
				@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
				@As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
				
			   RAISERROR (@Ls_DescriptionError_TEXT,16,1);

	 END CATCH
 END
 


--EXEC BATCH_COMMON$SP_EXTRACT_MEMBERINFORMATION_ONETIME


GO
