/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_MEMBER_ESTABLISHMENT_MERGE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_MERG$SP_MEMBER_ESTABLISHMENT_MERGE
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
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_MEMBER_ESTABLISHMENT_MERGE]  
   @An_MemberMciSecondary_IDNO			NUMERIC(10),
   @An_MemberMciPrimary_IDNO			NUMERIC(10),
   @An_Cursor_QNTY						NUMERIC(11),
   @Ad_Run_DATE							DATE,
   @An_TransactionEventSeq_NUMB			NUMERIC(19),
   @Ac_Msg_CODE							CHAR(5)			OUTPUT,
   @As_DescriptionError_TEXT			VARCHAR(4000)	OUTPUT
AS 
   BEGIN
      DECLARE
		@Lc_MergeStatusUpdate_CODE					CHAR(1)		= 'U',
		@Lc_MergeStatusDelete_CODE					CHAR(1)		= 'D',
		@Lc_StatusCaseMemberActive_CODE				CHAR(1)		= 'A', 
		@Lc_RecipientTypeCpNcp_CODE					CHAR(1)		= '1', 
		@Lc_StatusFailed_CODE						CHAR(1)		= 'F', 
		@Lc_StatusSuccess_CODE						CHAR(1)		= 'S', 
		@Lc_TypePersonChild_CODE					CHAR(2)		= 'CI',
		@Lc_TypePersonCp_CODE						CHAR(2)		= 'CP',
		@Lc_TypePersonGuardian_CODE					CHAR(2)		= 'GC',
		@Lc_TypePersonNcp_CODE						CHAR(3)		= 'NCP',
		@Ls_Procedure_NAME							VARCHAR(30) = 'BATCH_CM_MERG$SP_MEMBER_ESTABLISHMENT_MERGE',
		@Ld_Low_DATE								DATE		= '01/01/0001', 
		@Ld_High_DATE								DATE		= '12/31/9999';
      DECLARE
		-- 13588 - Merg Batch Code standard	- Start
		@Li_FetchStatus_QNTY						SMALLINT,
		@Ln_MemberMciPrimary_IDNO					NUMERIC(10), 
		@Ln_MemberMciSecondary_IDNO					NUMERIC(10),
		@Ln_Error_NUMB								NUMERIC(11),
        @Ln_ErrorLine_NUMB							NUMERIC(11),
        @Ln_HdemoExists_QNTY						NUMERIC(11) = 0,
        -- 13271  - MERG - CR0367 Amend MCI Number 20140219 - START
        @Ln_DemoExists_QNTY							NUMERIC(11) = 0,
        -- 13271  - MERG - CR0367 Amend MCI Number 20140219 - END
		@Ln_AkaxExists_QNTY							NUMERIC(11) = 0,
		@Ln_BnkrValidation_QNTY						NUMERIC(11) = 0,
        @Ln_MecnExists_QNTY							NUMERIC(11) = 0,
		@Ln_MpatExists_QNTY							NUMERIC(11) = 0,
		@Ln_HmpatExists_QNTY						NUMERIC(11) = 0,
		@Ln_FadtValidation_QNTY						NUMERIC(11) = 0,
		@Ln_FprjValidation_QNTY						NUMERIC(11) = 0,
		@Ln_FcrqValidation_QNTY						NUMERIC(11) = 0,
		@Ln_FedhValidation_QNTY						NUMERIC(11) = 0,
		@Ln_HfedhValidation_QNTY					NUMERIC(11) = 0,
		@Ln_StntValidation_QNTY						NUMERIC(11) = 0,
		@Ln_TexcValidation_QNTY						NUMERIC(11) = 0,
		@Ln_UrctValidation_QNTY						NUMERIC(11) = 0,
		@Ln_UsrtValidation_QNTY						NUMERIC(11) = 0,
		@Ln_NmrqValidation_QNTY						NUMERIC(11) = 0,
		@Ln_NrrqValidation_QNTY						NUMERIC(11) = 0,
		@Ln_DprsValidation_QNTY						NUMERIC(11) = 0,
		@Ln_CjnrValidation_QNTY						NUMERIC(11) = 0,
		@Ln_LpedValidation_QNTY						NUMERIC(11) = 0,
		@Ln_LcmsValidation_QNTY						NUMERIC(11) = 0,
		@Ln_LpsiValidation_QNTY						NUMERIC(11) = 0,
		@Ln_DsbaValidation_QNTY						NUMERIC(11) = 0,
		@Ln_NaexValidation_QNTY						NUMERIC(11) = 0,
		@Ln_FdemValidation_QNTY						NUMERIC(11) = 0,
		@Ls_Sql_TEXT								VARCHAR(200), 
		@Ls_Sqldata_TEXT							VARCHAR(1000), 
		@Ls_DescriptionError_TEXT					VARCHAR(4000), 
		@Lx_XmlData_XML								XML,
		-- AKAX Cursor and related Variables.
		@Akax_CUR									CURSOR,
		@Akax_REC$LastAlias_NAME					CHAR(20), 
		@Akax_REC$FirstAlias_NAME					CHAR(16), 
		@Akax_REC$MiddleAlias_NAME					CHAR(20), 
		@Akax_REC$Sequence_NUMB						NUMERIC(11), 
		@Akax_REC$TransactionEventSeq_NUMB			NUMERIC(19), 
		@Akax_REC$BeginValidity_DATE				DATE,
		-- MECN Cursor and related Variables.
		@Mecn_CUR									CURSOR,
		@Mecn_REC$TransactionEventSeq_NUMB			NUMERIC(19),
		@Mecn_REC$Contact_IDNO						NUMERIC(9),	
		--- DEMO Cursor and related Variables.
		@Demo_CUR									CURSOR,
		@Demo_REC$Individual_IDNO                   NUMERIC(8),
		@Demo_REC$Last_NAME                         CHAR(20), 
		@Demo_REC$First_NAME                        CHAR(16), 
		@Demo_REC$Middle_NAME                       CHAR(20), 
		@Demo_REC$Suffix_NAME                       CHAR(4),  
		@Demo_REC$Title_NAME                        CHAR(8), 
		@Demo_REC$FullDisplay_NAME                  VARCHAR(60),
		@Demo_REC$MemberSex_CODE                    CHAR(1),
		@Demo_REC$MemberSsn_NUMB                    NUMERIC(9),
		@Demo_REC$Birth_DATE                        DATE,
		@Demo_REC$Emancipation_DATE                 DATE,
		@Demo_REC$LastMarriage_DATE                 DATE,
		@Demo_REC$LastDivorce_DATE                  DATE,
		@Demo_REC$BirthCity_NAME                    CHAR(28), 
		@Demo_REC$BirthState_CODE                   CHAR(2),  
		@Demo_REC$BirthCountry_CODE                 CHAR(2),
		@Demo_REC$DescriptionHeight_TEXT            CHAR(3),  
		@Demo_REC$DescriptionWeightLbs_TEXT         CHAR(3),  
		@Demo_REC$Race_CODE                         CHAR(1),  
		@Demo_REC$ColorHair_CODE                    CHAR(3),  
		@Demo_REC$ColorEyes_CODE                    CHAR(3),  
		@Demo_REC$FacialHair_INDC                   CHAR(2),  
		@Demo_REC$Language_CODE                     CHAR(3),  
		@Demo_REC$TypeProblem_CODE                  CHAR(3),  
		@Demo_REC$Deceased_DATE                     DATE,  
		@Demo_REC$CerDeathNo_TEXT                   CHAR(9),  
		@Demo_REC$LicenseDriverNo_TEXT              CHAR(25), 
		@Demo_REC$AlienRegistn_ID                   CHAR(10), 
		@Demo_REC$WorkPermitNo_TEXT                 CHAR(10), 
		@Demo_REC$BeginPermit_DATE                  DATE,  
		@Demo_REC$EndPermit_DATE                    DATE,  
		@Demo_REC$HomePhone_NUMB                    NUMERIC(15), 
		@Demo_REC$WorkPhone_NUMB                    NUMERIC(15), 
		@Demo_REC$CellPhone_NUMB                    NUMERIC(15), 
		@Demo_REC$Fax_NUMB                          NUMERIC(15), 
		@Demo_REC$Contact_EML                       VARCHAR(100),
		@Demo_REC$Spouse_NAME                       CHAR(40),
		@Demo_REC$Graduation_DATE                   DATE,
		@Demo_REC$EducationLevel_CODE               CHAR(2),  
		@Demo_REC$Restricted_INDC                   CHAR(1),  
		@Demo_REC$Military_ID                       CHAR(10), 
		@Demo_REC$MilitaryBranch_CODE               CHAR(2),  
		@Demo_REC$MilitaryStatus_CODE               CHAR(2),  
		@Demo_REC$MilitaryBenefitStatus_CODE        CHAR(2),  
		@Demo_REC$SecondFamily_INDC                 CHAR(1),  
		@Demo_REC$MeansTestedInc_INDC               CHAR(1),  
		@Demo_REC$SsIncome_INDC                     CHAR(1),  
		@Demo_REC$VeteranComps_INDC                 CHAR(1),  
		@Demo_REC$Assistance_CODE                   CHAR(3),  
		@Demo_REC$DescriptionIdentifyingMarks_TEXT  CHAR(40), 
		@Demo_REC$Divorce_INDC                      CHAR(1), 
		@Demo_REC$BeginValidity_DATE                DATE,
		@Demo_REC$WorkerUpdate_ID                   CHAR(30),
		@Demo_REC$Disable_INDC                      CHAR(1),  
		@Demo_REC$TypeOccupation_CODE               CHAR(3),  
		@Demo_REC$CountyBirth_IDNO                  NUMERIC(3),
		@Demo_REC$MotherMaiden_NAME                 CHAR(30), 
		@Demo_REC$FileLastDivorce_ID                CHAR(15), 
		@Demo_REC$TribalAffiliations_CODE           CHAR(3),  
		@Demo_REC$FormerMci_IDNO                    NUMERIC(10),
		@Demo_REC$StateDivorce_CODE                 CHAR(2),  
		@Demo_REC$CityDivorce_NAME                  CHAR(28), 
		@Demo_REC$StateMarriage_CODE                CHAR(2),
		@Demo_REC$CityMarriage_NAME                 CHAR(28), 
		@Demo_REC$IveParty_IDNO                     NUMERIC(10),	
		--- MPAT Cursor and related Variables.
		@Mpat_CUR									CURSOR,
		@Mpat_REC$BirthCertificate_ID				CHAR(20),
		@Mpat_REC$BornOfMarriage_CODE				CHAR(1),    
		@Mpat_REC$Conception_DATE					DATE,
		@Mpat_REC$ConceptionCity_NAME				CHAR(28),
		@Mpat_REC$ConceptionCounty_IDNO				NUMERIC(3),
		@Mpat_REC$ConceptionState_CODE				CHAR(2),
		@Mpat_REC$ConceptionCountry_CODE			CHAR(2),    
		@Mpat_REC$EstablishedMother_CODE			CHAR(1),    
		@Mpat_REC$EstablishedMotherMci_IDNO			NUMERIC(10),
		@Mpat_REC$EstablishedMotherLast_NAME		CHAR(20),   
		@Mpat_REC$EstablishedMotherFirst_NAME		CHAR(16),   
		@Mpat_REC$EstablishedMotherMiddle_NAME		CHAR(20),   
		@Mpat_REC$EstablishedMotherSuffix_NAME		CHAR(4),    
		@Mpat_REC$EstablishedFather_CODE			CHAR(1),    
		@Mpat_REC$EstablishedFatherMci_IDNO			NUMERIC(10),
		@Mpat_REC$EstablishedFatherLast_NAME		CHAR(20),   
		@Mpat_REC$EstablishedFatherFirst_NAME		CHAR(16),   
		@Mpat_REC$EstablishedFatherMiddle_NAME		CHAR(20),   
		@Mpat_REC$EstablishedFatherSuffix_NAME		CHAR(4),    
		@Mpat_REC$DisEstablishedFather_CODE			CHAR(1),    
		@Mpat_REC$DisEstablishedFatherMci_IDNO		NUMERIC(10),
		@Mpat_REC$DisEstablishedFatherLast_NAME		CHAR(20),   
		@Mpat_REC$DisEstablishedFatherFirst_NAME	CHAR(16),   
		@Mpat_REC$DisEstablishedFatherMiddle_NAME	CHAR(20),   
		@Mpat_REC$DisEstablishedFatherSuffix_NAME	CHAR(4),    
		@Mpat_REC$PaternityEst_INDC					CHAR(1),    
		@Mpat_REC$StatusEstablish_CODE				CHAR(1),    
		@Mpat_REC$StateEstablish_CODE				CHAR(2),    
		@Mpat_REC$FileEstablish_ID					CHAR(10),   
		@Mpat_REC$PaternityEst_CODE					CHAR(2),    
		@Mpat_REC$PaternityEst_DATE					DATE,
		@Mpat_REC$StateDisestablish_CODE			CHAR(2),    
		@Mpat_REC$FileDisestablish_ID				CHAR(10),   
		@Mpat_REC$MethodDisestablish_CODE			CHAR(3),    
		@Mpat_REC$Disestablish_DATE					DATE,
		@Mpat_REC$DescriptionProfile_TEXT			VARCHAR(200),
		@Mpat_REC$QiStatus_CODE						CHAR(1),    
		@Mpat_REC$VapImage_CODE						CHAR(1),    
		@Mpat_REC$WorkerUpdate_ID					CHAR(30),   
		@Mpat_REC$BeginValidity_DATE				DATE,
		-- FADT Cursor and related Variables.
		@Fadt_CUR									CURSOR,
		@Fadt_REC$Case_IDNO							NUMERIC(6), 
		@Fadt_REC$TypeTrans_CODE					CHAR(2),
		-- FPRJ Cursor and related Variables.
		@Fprj_CUR									CURSOR,
		@Fprj_REC$Case_IDNO							NUMERIC(6),
		-- USRT Cursor and related Variables.
		@Usrt_CUR									CURSOR,
		@Usrt_REC$Case_IDNO							NUMERIC(6);
		-- 13588 - Merg Batch Code standard	- End
		
      BEGIN TRY
		---Assin Primary/Secondary Member to local variable-----
		SET @Ln_MemberMciPrimary_IDNO	 = @An_MemberMciPrimary_IDNO
		SET @Ln_MemberMciSecondary_IDNO = @An_MemberMciSecondary_IDNO
		------------
      		---- Table Merge Starts-----		
			------------------------------------------------------------------------------------------------
		--  AKAX  -- MemberAkaNames_T1
		------------------------------------------------------------------------------------------------	
			SET @Ls_Sql_TEXT = 'AKAX MMERG UPDATION';	
			SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' 
								  + ISNULL (CAST (@Ln_MemberMciPrimary_IDNO AS VARCHAR (10)), '')
								  + ' MemberMciSecondary_IDNO: ' 
								  + ISNULL (CAST (@Ln_MemberMciSecondary_IDNO AS VARCHAR (10)), '');
								  
			-- Defining the cursor @Akax_CUR
			SET @Akax_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT a.LastAlias_NAME, 
						   a.FirstAlias_NAME, 
						   a.MiddleAlias_NAME, 
                           a.Sequence_NUMB, 
						   a.TransactionEventSeq_NUMB, 
                           a.BeginValidity_DATE
                     FROM AKAX_Y1 a
                     WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
						
			SET @Ls_Sql_TEXT = 'OPEN @Akax_CUR';
				
			OPEN @Akax_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Akax_CUR - 1';	

			FETCH NEXT FROM @Akax_CUR INTO  @Akax_REC$LastAlias_NAME, @Akax_REC$FirstAlias_NAME, 
											@Akax_REC$MiddleAlias_NAME, @Akax_REC$Sequence_NUMB, 
											@Akax_REC$TransactionEventSeq_NUMB, @Akax_REC$BeginValidity_DATE;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			
			-- cursor loop Starts @Akax_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
					SELECT @Lx_XmlData_XML = ( SELECT a.*, CASE  WHEN EXISTS (SELECT 1 
																				FROM AKAX_Y1 b
																			   WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
																				 AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB )
															THEN @Lc_MergeStatusDelete_CODE
															ELSE @Lc_MergeStatusUpdate_CODE
													 END merge_status 
													FROM AKAX_Y1 a
												 WHERE a.MemberMci_IDNO  = @Ln_MemberMciSecondary_IDNO    
												   AND a.TransactionEventSeq_NUMB = @Akax_REC$TransactionEventSeq_NUMB  For XML PATH('ROWS'),TYPE);
																			
					SELECT @Ln_AkaxExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);    
					
					 SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - AKAX_Y1 1';
					 
					 INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'AKAX_Y1', 
							 @Ln_AkaxExists_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	   
							 
					 SET @Lx_XmlData_XML = NULL;
					 
					 SET @Ls_Sql_TEXT = ' DELETE FROM AKAX_Y1';
					 
					 DELETE a
						 FROM AKAX_Y1 a
						 WHERE 
							a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO AND 
							a.TransactionEventSeq_NUMB = @Akax_REC$TransactionEventSeq_NUMB AND 
							EXISTS 
							(
							   SELECT 1
							   FROM AKAX_Y1 b
							   WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
							     AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB
							)

                     SET @Ls_Sql_TEXT = ' SELECT AKAX_Y1 2';
                     
                     SELECT @Ln_AkaxExists_QNTY = COUNT(1)
					   FROM AKAX_Y1 a
					  WHERE a.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
						AND	a.LastAlias_NAME = @Akax_REC$LastAlias_NAME
						AND	a.FirstAlias_NAME = @Akax_REC$FirstAlias_NAME
						AND	a.MiddleAlias_NAME = @Akax_REC$MiddleAlias_NAME
						AND	a.EndValidity_DATE = @Ld_High_DATE;
							
					IF (@Ln_AkaxExists_QNTY > 0)
                        BEGIN
							SET @Ls_Sql_TEXT = 'UPDATE AKAX_Y1 1';
							UPDATE AKAX_Y1
                              SET EndValidity_DATE = @Ad_Run_DATE
							WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
							  AND TransactionEventSeq_NUMB = @Akax_REC$TransactionEventSeq_NUMB
							  AND EndValidity_DATE = @Ld_High_DATE;
                        END
                    ELSE
						BEGIN
							SET @Ls_Sql_TEXT = 'UPDATE AKAX_Y1 2';
							
							 UPDATE AKAX_Y1
								  SET Sequence_NUMB = ISNULL((SELECT MAX(b.Sequence_NUMB)
													   FROM AKAX_Y1  AS b
													   WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
													     AND b.EndValidity_DATE = @Ld_High_DATE), 0) + 1
								   WHERE 
									  MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO AND 
									  TransactionEventSeq_NUMB = @Akax_REC$TransactionEventSeq_NUMB AND 
									  EndValidity_DATE = @Ld_High_DATE;
						END
					
					SET @Ls_Sql_TEXT = 'UPDATE AKAX_Y1 3';
					
					UPDATE AKAX_Y1
                        SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
                      WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
                        AND TransactionEventSeq_NUMB = @Akax_REC$TransactionEventSeq_NUMB;
                        
                    FETCH NEXT FROM @Akax_CUR INTO  @Akax_REC$LastAlias_NAME, @Akax_REC$FirstAlias_NAME, 
											@Akax_REC$MiddleAlias_NAME, @Akax_REC$Sequence_NUMB, 
											@Akax_REC$TransactionEventSeq_NUMB, @Akax_REC$BeginValidity_DATE;
			
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
                    --- End of @Akax_CUR		  
				END
			CLOSE @Akax_CUR;
			DEALLOCATE @Akax_CUR;
			-- cursor loop Starts @Akax_CUR		
		------------------------------------------------------------------------------------------------
		-- MemberBankruptcy_T1
		------------------------------------------------------------------------------------------------			
			SET @Ls_Sql_TEXT = ' SELECT BNKR_Y1 1';
			
			SELECT @Ln_BnkrValidation_QNTY = COUNT(1)
              FROM BNKR_Y1 a
             WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;	
                           
			IF @Ln_BnkrValidation_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 
																			  FROM BNKR_Y1 b 
																			 WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
																			   AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
																 THEN @Lc_MergeStatusDelete_CODE
																 ELSE @Lc_MergeStatusUpdate_CODE
															 END merge_status
												FROM BNKR_Y1 a
											 WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO For XML PATH('ROWS'),TYPE);
																			
					SELECT @Ln_BnkrValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);    
					
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - BNKR_Y1';
					
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'BNKR_Y1', 
							 @Ln_BnkrValidation_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	  
							 
					 SET @Lx_XmlData_XML = NULL;
					 
					 SET @Ls_Sql_TEXT = 'DELETE FROM BNKR_Y1';
					 
					 DELETE a
					  FROM BNKR_Y1 a
					 WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
					   AND EXISTS 
						(
						   SELECT 1
						   FROM BNKR_Y1 b
						   WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
						     AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB
						)

                    SET @Ls_Sql_TEXT = ' SELECT BNKR_Y1 2';
                    
					 SELECT @Ln_BnkrValidation_QNTY = COUNT(1)
						 FROM BNKR_Y1 b
						 WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
						   AND b.EndValidity_DATE = @Ld_High_DATE;
						   
					IF @Ln_BnkrValidation_QNTY > 0
						BEGIN
							SET @Ls_Sql_TEXT = ' UPDATE BNKR_Y1 1';
							UPDATE BNKR_Y1
							   SET EndValidity_DATE = @Ad_Run_DATE
							WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
							  AND EndValidity_DATE = @Ld_High_DATE;
						END						
						 
						 SET @Ls_Sql_TEXT = ' UPDATE BNKR_Y1 2';
							
						UPDATE BNKR_Y1
							SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
						 FROM BNKR_Y1 a
						 WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
				END
			------------------------------------------------------------------------------------------------
		-- MemberContacts_T1
		------------------------------------------------------------------------------------------------
			SET @Ls_Sql_TEXT = 'SELECT MECN_Y1 FRO Cursor @Mecn_CUR';
			
			SET @Mecn_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					 SELECT a.Contact_IDNO, a.TransactionEventSeq_NUMB
						 FROM MECN_Y1 a
						 WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
						 
			SET @Ls_Sql_TEXT = 'OPEN @Mecn_CUR';;
			
			OPEN @Mecn_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Mecn_CUR - 1';
			
			FETCH NEXT FROM @Mecn_CUR INTO @Mecn_REC$Contact_IDNO,@Mecn_REC$TransactionEventSeq_NUMB;			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			
			-- cursor loop Starts @Mecn_CUR
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
				
					SELECT @Lx_XmlData_XML = (SELECT a.*, 
													 @Lc_MergeStatusUpdate_CODE merge_status 
												FROM MECN_Y1 a 
											   WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
												AND a.Contact_IDNO = @Mecn_REC$Contact_IDNO
												AND a.TransactionEventSeq_NUMB = @Mecn_REC$TransactionEventSeq_NUMB For XML PATH('ROWS'),TYPE);
																			
					SELECT @Ln_MecnExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') id 
																		  FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);    
					
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - MECN_Y1';
					
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'MECN_Y1', 
							 @Ln_MecnExists_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	  
					
					SET @Lx_XmlData_XML = NULL;
					
					IF @Ln_MecnExists_QNTY > 0
						BEGIN
							--update all the valid secondary records
							 SET @Ls_Sql_TEXT = 'UPDATE MECN_Y1';
							 
							 UPDATE MECN_Y1
								  SET Contact_IDNO = ISNULL((SELECT MAX(b.Contact_IDNO)
															  FROM MECN_Y1 b
															 WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
															  AND b.EndValidity_DATE = @Ld_High_DATE), 0) + 1, 
									 MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
							   WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
								 AND Contact_IDNO = @Mecn_REC$Contact_IDNO
								 AND TransactionEventSeq_NUMB = @Mecn_REC$TransactionEventSeq_NUMB
								 AND EndValidity_DATE = @Ld_High_DATE;
						END	
						
					--update all the secondary records including the end-dated records					
					SET @Ls_Sql_TEXT = 'UPDATE MECN_Y1';
					
					UPDATE MECN_Y1
                       SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
                     WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
					   AND Contact_IDNO = @Mecn_REC$Contact_IDNO
					   AND TransactionEventSeq_NUMB = @Mecn_REC$TransactionEventSeq_NUMB;	
					
					--- End of Cursor @Mecn_CUR
					FETCH NEXT FROM @Mecn_CUR INTO @Mecn_REC$Contact_IDNO,@Mecn_REC$TransactionEventSeq_NUMB;			
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
			-- cursor loop Ends @Mecn_CUR
			CLOSE @Mecn_CUR;
			DEALLOCATE @Mecn_CUR;
			
			
			------------------------------------------------------------------------------------------------
		-- DEMO -- MEMBER_DEMOGRAPHICS
		------------------------------------------------------------------------------------------------		
			SET @Ls_Sql_TEXT = 'DEMO_Y1 MMERG UPDATION';
			
			 SELECT @Lx_XmlData_XML = ISNULL((SELECT * FROM ( SELECT a.*,
																	 @Lc_MergeStatusUpdate_CODE merge_status    
																FROM DEMO_Y1 a   
															   WHERE MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
															  UNION ALL  
															  SELECT a.*, 
																	 @Lc_MergeStatusDelete_CODE merge_status    
																FROM DEMO_Y1 a   
															   WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO  ) AS S For XML PATH('ROWS'),TYPE),'');
			
			-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - START
			SET @Ls_Sql_TEXT = 'DEMO COUNT - DEMO_Y1';
			SELECT @Ln_DemoExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') id 
																		  FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);    
			
			SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DEMO_Y1';
			INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
				  VALUES (
					 @Ln_MemberMciPrimary_IDNO, 
					 @Ln_MemberMciSecondary_IDNO, 
					 'DEMO_Y1', 
					 @Ln_DemoExists_QNTY, 
					 ISNULL(CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),''), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);	  
					 
			SET @Lx_XmlData_XML = NULL;		 
			
			IF @Ln_DemoExists_QNTY = 2
				BEGIN
						 -- Defining the cursor @Demo_CUR
						 SET @Demo_CUR =  
							CURSOR LOCAL FORWARD_ONLY STATIC FOR
								SELECT 
									CASE WHEN a.Individual_IDNO  = 0 THEN b.Individual_IDNO ELSE a.Individual_IDNO END AS Individual_IDNO, 
									CASE WHEN (LTRIM(RTRIM(a.Last_NAME))) = '' THEN b.Last_NAME ELSE a.Last_NAME END AS  Last_NAME,
									CASE WHEN (LTRIM(RTRIM(a.First_NAME))) = '' THEN b.First_NAME  ELSE a.First_NAME END AS First_NAME,
									CASE WHEN (LTRIM(RTRIM(a.Middle_NAME)))= '' THEN b.Middle_NAME ELSE a.Middle_NAME END AS Middle_NAME,
									CASE WHEN (LTRIM(RTRIM(a.Suffix_NAME)))= '' THEN b.Suffix_NAME ELSE a.Suffix_NAME END AS Suffix_NAME,
									CASE WHEN (LTRIM(RTRIM(a.Title_NAME )))= '' THEN b.Title_NAME  ELSE a.Title_NAME  END AS Title_NAME,
									CASE WHEN (LTRIM(RTRIM(a.FullDisplay_NAME)))='' THEN b.FullDisplay_NAME ELSE a.FullDisplay_NAME END AS FullDisplay_NAME ,
									CASE WHEN (LTRIM(RTRIM(a.MemberSex_CODE)))='' THEN b.MemberSex_CODE  ELSE a.MemberSex_CODE END AS MemberSex_CODE,
									CASE WHEN a.MemberSsn_NUMB = 0  THEN b.MemberSsn_NUMB ELSE a.MemberSsn_NUMB  END AS MemberSsn_NUMB,
									CASE WHEN a.Birth_DATE = @Ld_Low_DATE THEN b.Birth_DATE ELSE a.Birth_DATE END AS Birth_DATE,
									CASE WHEN a.Emancipation_DATE = @Ld_Low_DATE THEN b.Emancipation_DATE  ELSE a.Emancipation_DATE END AS Emancipation_DATE ,
									CASE WHEN a.LastMarriage_DATE = @Ld_Low_DATE THEN b.LastMarriage_DATE ELSE a.LastMarriage_DATE END AS LastMarriage_DATE ,
									CASE WHEN a.LastDivorce_DATE  = @Ld_Low_DATE THEN b.LastDivorce_DATE ELSE a.LastDivorce_DATE END AS LastDivorce_DATE ,
									CASE WHEN (LTRIM(RTRIM(a.BirthCity_NAME))) = '' THEN b.BirthCity_NAME  ELSE a.BirthCity_NAME  END AS BirthCity_NAME,
									CASE WHEN (LTRIM(RTRIM(a.BirthState_CODE ))) = '' THEN b.BirthState_CODE  ELSE a.BirthState_CODE END AS BirthState_CODE ,
									CASE WHEN (LTRIM(RTRIM(a.BirthCountry_CODE))) =  '' THEN b.BirthCountry_CODE ELSE a.BirthCountry_CODE END AS BirthCountry_CODE,
									CASE WHEN (LTRIM(RTRIM(a.DescriptionHeight_TEXT))) = ''  THEN b.DescriptionHeight_TEXT ELSE a.DescriptionHeight_TEXT END AS DescriptionHeight_TEXT,
									CASE WHEN (LTRIM(RTRIM(a.DescriptionWeightLbs_TEXT))) = '' THEN b.DescriptionWeightLbs_TEXT  ELSE a.DescriptionWeightLbs_TEXT END AS DescriptionWeightLbs_TEXT,
									CASE WHEN (LTRIM(RTRIM(a.Race_CODE))) = '' THEN b.Race_CODE  ELSE a.Race_CODE  END AS Race_CODE,
									CASE WHEN (LTRIM(RTRIM(a.ColorHair_CODE))) = '' THEN b.ColorHair_CODE ELSE a.ColorHair_CODE END AS ColorHair_CODE,
									CASE WHEN (LTRIM(RTRIM(a.ColorEyes_CODE))) = '' THEN b.ColorEyes_CODE ELSE a.ColorEyes_CODE END AS ColorEyes_CODE   ,
									CASE WHEN (LTRIM(RTRIM(a.FacialHair_INDC))) = '' THEN b.FacialHair_INDC ELSE a.FacialHair_INDC END AS FacialHair_INDC,
									CASE WHEN (LTRIM(RTRIM(a.Language_CODE))) = '' THEN b.Language_CODE ELSE a.Language_CODE END AS Language_CODE    ,
									CASE WHEN (LTRIM(RTRIM(a.TypeProblem_CODE))) = '' THEN b.TypeProblem_CODE ELSE a.TypeProblem_CODE END AS TypeProblem_CODE,
									CASE WHEN a.Deceased_DATE = @Ld_Low_DATE THEN b.Deceased_DATE    ELSE a.Deceased_DATE END AS Deceased_DATE    ,
									CASE WHEN (LTRIM(RTRIM(a.CerDeathNo_TEXT))) = '' THEN b.CerDeathNo_TEXT ELSE a.CerDeathNo_TEXT END AS CerDeathNo_TEXT  ,
									CASE WHEN (LTRIM(RTRIM(a.LicenseDriverNo_TEXT))) = '' THEN b.LicenseDriverNo_TEXT  ELSE a.LicenseDriverNo_TEXT END AS LicenseDriverNo_TEXT  ,
									CASE WHEN (LTRIM(RTRIM(a.AlienRegistn_ID))) = '' THEN b.AlienRegistn_ID  ELSE a.AlienRegistn_ID END AS AlienRegistn_ID ,
									CASE WHEN (LTRIM(RTRIM(a.WorkPermitNo_TEXT))) = '' THEN b.WorkPermitNo_TEXT ELSE a.WorkPermitNo_TEXT END AS WorkPermitNo_TEXT,
									CASE WHEN (LTRIM(RTRIM(a.BeginPermit_DATE))) = @Ld_Low_DATE THEN b.BeginPermit_DATE ELSE a.BeginPermit_DATE  END AS BeginPermit_DATE ,
									CASE WHEN (LTRIM(RTRIM(a.EndPermit_DATE))) = @Ld_Low_DATE THEN b.EndPermit_DATE   ELSE a.EndPermit_DATE    END AS EndPermit_DATE   ,
									CASE WHEN a.HomePhone_NUMB = 0 THEN b.HomePhone_NUMB   ELSE a.HomePhone_NUMB    END AS HomePhone_NUMB   ,
									CASE WHEN a.WorkPhone_NUMB = 0 THEN b.WorkPhone_NUMB   ELSE a.WorkPhone_NUMB    END AS WorkPhone_NUMB   ,
									CASE WHEN a.CellPhone_NUMB = 0 THEN b.CellPhone_NUMB ELSE a.CellPhone_NUMB    END AS CellPhone_NUMB   ,
									CASE WHEN a.Fax_NUMB = 0 THEN b.Fax_NUMB ELSE a.Fax_NUMB END AS Fax_NUMB,
									CASE WHEN (LTRIM(RTRIM(a.Contact_EML))) = '' THEN b.Contact_EML ELSE a.Contact_EML END AS Contact_EML,
									CASE WHEN (LTRIM(RTRIM(a.Spouse_NAME))) = '' THEN b.Spouse_NAME ELSE a.Spouse_NAME END AS Spouse_NAME,
									CASE WHEN a.Graduation_DATE = @Ld_Low_DATE THEN b.Graduation_DATE  ELSE a.Graduation_DATE   END AS Graduation_DATE  ,
									CASE WHEN (LTRIM(RTRIM(a.EducationLevel_CODE))) = '' THEN b.EducationLevel_CODE   ELSE a.EducationLevel_CODE    END AS EducationLevel_CODE   ,
									CASE WHEN (LTRIM(RTRIM(a.Restricted_INDC))) = '' THEN b.Restricted_INDC  ELSE a.Restricted_INDC   END AS Restricted_INDC  ,
									CASE WHEN (LTRIM(RTRIM(a.Military_ID))) = '' THEN b.Military_ID ELSE a.Military_ID END AS Military_ID,
									CASE WHEN (LTRIM(RTRIM(a.MilitaryBranch_CODE))) = '' THEN b.MilitaryBranch_CODE   ELSE a.MilitaryBranch_CODE    END AS MilitaryBranch_CODE   ,
									CASE WHEN (LTRIM(RTRIM(a.MilitaryStatus_CODE))) = '' THEN b.MilitaryStatus_CODE   ELSE a.MilitaryStatus_CODE    END AS MilitaryStatus_CODE   ,
									CASE WHEN (LTRIM(RTRIM(a.MilitaryBenefitStatus_CODE))) = '' THEN b.MilitaryBenefitStatus_CODE ELSE a.MilitaryBenefitStatus_CODE  END AS MilitaryBenefitStatus_CODE ,
									CASE WHEN (LTRIM(RTRIM(a.SecondFamily_INDC))) = '' THEN b.SecondFamily_INDC ELSE a.SecondFamily_INDC END AS SecondFamily_INDC,
									CASE WHEN (LTRIM(RTRIM(a.MeansTestedInc_INDC))) = '' THEN b.MeansTestedInc_INDC   ELSE a.MeansTestedInc_INDC    END AS MeansTestedInc_INDC   ,
									CASE WHEN (LTRIM(RTRIM(a.SsIncome_INDC))) = '' THEN b.SsIncome_INDC    ELSE a.SsIncome_INDC END AS SsIncome_INDC    ,
									CASE WHEN (LTRIM(RTRIM(a.VeteranComps_INDC))) = '' THEN b.VeteranComps_INDC ELSE a.VeteranComps_INDC END AS VeteranComps_INDC,
									CASE WHEN (LTRIM(RTRIM(a.Assistance_CODE))) = '' THEN b.Assistance_CODE  ELSE a.Assistance_CODE   END AS Assistance_CODE  ,
									CASE WHEN (LTRIM(RTRIM(a.DescriptionIdentifyingMarks_TEXT))) = '' THEN b.DescriptionIdentifyingMarks_TEXT ELSE a.DescriptionIdentifyingMarks_TEXT END AS DescriptionIdentifyingMarks_TEXT,
									CASE WHEN (LTRIM(RTRIM(a.Divorce_INDC))) = '' THEN b.Divorce_INDC ELSE a.Divorce_INDC END AS Divorce_INDC,
									CASE WHEN (LTRIM(RTRIM(a.BeginValidity_DATE))) = '' THEN b.BeginValidity_DATE    ELSE a.BeginValidity_DATE END AS BeginValidity_DATE    ,
									CASE WHEN (LTRIM(RTRIM(a.WorkerUpdate_ID))) = '' THEN b.WorkerUpdate_ID  ELSE a.WorkerUpdate_ID   END AS WorkerUpdate_ID  ,
									CASE WHEN (LTRIM(RTRIM(a.Disable_INDC ))) = '' THEN b.Disable_INDC ELSE a.Disable_INDC END AS Disable_INDC,
									CASE WHEN (LTRIM(RTRIM(a.TypeOccupation_CODE))) = '' THEN b.TypeOccupation_CODE   ELSE a.TypeOccupation_CODE    END AS TypeOccupation_CODE   ,
									CASE WHEN a.CountyBirth_IDNO = 0 THEN b.CountyBirth_IDNO ELSE a.CountyBirth_IDNO  END AS CountyBirth_IDNO ,
									CASE WHEN (LTRIM(RTRIM(a.MotherMaiden_NAME))) = '' THEN b.MotherMaiden_NAME ELSE a.MotherMaiden_NAME END AS MotherMaiden_NAME,
									CASE WHEN (LTRIM(RTRIM(a.FileLastDivorce_ID))) = '' THEN b.FileLastDivorce_ID    ELSE a.FileLastDivorce_ID END AS FileLastDivorce_ID    ,
									CASE WHEN (LTRIM(RTRIM(a.TribalAffiliations_CODE))) = '' THEN b.TribalAffiliations_CODE    ELSE a.TribalAffiliations_CODE END AS TribalAffiliations_CODE    ,
									CASE WHEN a.FormerMci_IDNO = 0 THEN b.FormerMci_IDNO   ELSE a.FormerMci_IDNO    END AS FormerMci_IDNO   ,
									CASE WHEN (LTRIM(RTRIM(a.StateDivorce_CODE))) = '' THEN b.StateDivorce_CODE ELSE a.StateDivorce_CODE END AS StateDivorce_CODE,
									CASE WHEN (LTRIM(RTRIM(a.CityDivorce_NAME))) = '' THEN b.CityDivorce_NAME ELSE a.CityDivorce_NAME  END AS CityDivorce_NAME ,
									CASE WHEN (LTRIM(RTRIM(a.StateMarriage_CODE))) = '' THEN b.StateMarriage_CODE   ELSE a.StateMarriage_CODE END AS StateMarriage_CODE    ,
									CASE WHEN (LTRIM(RTRIM(a.CityMarriage_NAME))) = '' THEN b.CityMarriage_NAME    ELSE a.CityMarriage_NAME END AS CityMarriage_NAME,
									CASE WHEN a.IveParty_IDNO = 0 THEN b.IveParty_IDNO   ELSE a.IveParty_IDNO END AS IveParty_IDNO 
								FROM (SELECT * FROM DEMO_Y1 WHERE MemberMci_IDNO =  @Ln_MemberMciPrimary_IDNO) a,
									 (SELECT * FROM DEMO_Y1 WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO) b;
									 
						SET @Ls_Sql_TEXT = 'OPEN @Demo_CUR';
						
						OPEN @Demo_CUR;

						SET @Ls_Sql_TEXT = 'FETCH @Demo_CUR - 1';	

						FETCH NEXT FROM @Demo_CUR INTO  @Demo_REC$Individual_IDNO                 ,
														@Demo_REC$Last_NAME                       ,
														@Demo_REC$First_NAME                      ,
														@Demo_REC$Middle_NAME                     ,
														@Demo_REC$Suffix_NAME                     ,
														@Demo_REC$Title_NAME                      ,
														@Demo_REC$FullDisplay_NAME                ,
														@Demo_REC$MemberSex_CODE                  ,
														@Demo_REC$MemberSsn_NUMB                  ,
														@Demo_REC$Birth_DATE                      ,
														@Demo_REC$Emancipation_DATE               ,
														@Demo_REC$LastMarriage_DATE               ,
														@Demo_REC$LastDivorce_DATE                ,
														@Demo_REC$BirthCity_NAME                  ,
														@Demo_REC$BirthState_CODE                 ,
														@Demo_REC$BirthCountry_CODE               ,
														@Demo_REC$DescriptionHeight_TEXT          ,
														@Demo_REC$DescriptionWeightLbs_TEXT       ,
														@Demo_REC$Race_CODE                       ,
														@Demo_REC$ColorHair_CODE                  ,
														@Demo_REC$ColorEyes_CODE                  ,
														@Demo_REC$FacialHair_INDC                 ,
														@Demo_REC$Language_CODE                   ,
														@Demo_REC$TypeProblem_CODE                ,
														@Demo_REC$Deceased_DATE                   ,
														@Demo_REC$CerDeathNo_TEXT                 ,
														@Demo_REC$LicenseDriverNo_TEXT            ,
														@Demo_REC$AlienRegistn_ID                 ,
														@Demo_REC$WorkPermitNo_TEXT               ,
														@Demo_REC$BeginPermit_DATE                ,
														@Demo_REC$EndPermit_DATE                  ,
														@Demo_REC$HomePhone_NUMB                  ,
														@Demo_REC$WorkPhone_NUMB                  ,
														@Demo_REC$CellPhone_NUMB                  ,
														@Demo_REC$Fax_NUMB                        ,
														@Demo_REC$Contact_EML                     ,
														@Demo_REC$Spouse_NAME                     ,
														@Demo_REC$Graduation_DATE                 ,
														@Demo_REC$EducationLevel_CODE             ,
														@Demo_REC$Restricted_INDC                 ,
														@Demo_REC$Military_ID                     ,
														@Demo_REC$MilitaryBranch_CODE             ,
														@Demo_REC$MilitaryStatus_CODE             ,
														@Demo_REC$MilitaryBenefitStatus_CODE      ,
														@Demo_REC$SecondFamily_INDC               ,
														@Demo_REC$MeansTestedInc_INDC             ,
														@Demo_REC$SsIncome_INDC                   ,
														@Demo_REC$VeteranComps_INDC               ,
														@Demo_REC$Assistance_CODE                 ,
														@Demo_REC$DescriptionIdentifyingMarks_TEXT,
														@Demo_REC$Divorce_INDC                    ,
														@Demo_REC$BeginValidity_DATE              ,
														@Demo_REC$WorkerUpdate_ID                 ,
														@Demo_REC$Disable_INDC                    ,
														@Demo_REC$TypeOccupation_CODE             ,
														@Demo_REC$CountyBirth_IDNO                ,
														@Demo_REC$MotherMaiden_NAME               ,
														@Demo_REC$FileLastDivorce_ID              ,
														@Demo_REC$TribalAffiliations_CODE         ,
														@Demo_REC$FormerMci_IDNO                  ,
														@Demo_REC$StateDivorce_CODE               ,
														@Demo_REC$CityDivorce_NAME                ,
														@Demo_REC$StateMarriage_CODE              ,
														@Demo_REC$CityMarriage_NAME               ,
														@Demo_REC$IveParty_IDNO;
							
						SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;                   
						-- cursor loop Starts @Demo_CUR		
						WHILE @Li_FetchStatus_QNTY = 0
							BEGIN
								SET @Ls_Sql_TEXT = ' UPDATE DEMO_Y1';
								
								 UPDATE d SET 
									Individual_IDNO                 = @Demo_REC$Individual_IDNO                 ,
									Last_NAME                       = @Demo_REC$Last_NAME                       ,
									First_NAME                      = @Demo_REC$First_NAME                      ,
									Middle_NAME                     = @Demo_REC$Middle_NAME                     ,
									Suffix_NAME                     = @Demo_REC$Suffix_NAME                     ,
									Title_NAME                      = @Demo_REC$Title_NAME                      ,
									FullDisplay_NAME                = @Demo_REC$FullDisplay_NAME                ,
									MemberSex_CODE                  = @Demo_REC$MemberSex_CODE                  ,
									MemberSsn_NUMB                  = @Demo_REC$MemberSsn_NUMB                  ,
									Birth_DATE                      = @Demo_REC$Birth_DATE                      ,
									Emancipation_DATE               = @Demo_REC$Emancipation_DATE               ,
									LastMarriage_DATE               = @Demo_REC$LastMarriage_DATE               ,
									LastDivorce_DATE                = @Demo_REC$LastDivorce_DATE                ,
									BirthCity_NAME                  = @Demo_REC$BirthCity_NAME                  ,
									BirthState_CODE                 = @Demo_REC$BirthState_CODE                 ,
									BirthCountry_CODE               = @Demo_REC$BirthCountry_CODE               ,
									DescriptionHeight_TEXT          = @Demo_REC$DescriptionHeight_TEXT          ,
									DescriptionWeightLbs_TEXT       = @Demo_REC$DescriptionWeightLbs_TEXT       ,
									Race_CODE                       = @Demo_REC$Race_CODE                       ,
									ColorHair_CODE                  = @Demo_REC$ColorHair_CODE                  ,
									ColorEyes_CODE                  = @Demo_REC$ColorEyes_CODE                  ,
									FacialHair_INDC                 = @Demo_REC$FacialHair_INDC                 ,
									Language_CODE                   = @Demo_REC$Language_CODE                   ,
									TypeProblem_CODE                = @Demo_REC$TypeProblem_CODE                ,
									Deceased_DATE                   = @Demo_REC$Deceased_DATE                   ,
									CerDeathNo_TEXT                 = @Demo_REC$CerDeathNo_TEXT                 ,
									LicenseDriverNo_TEXT            = @Demo_REC$LicenseDriverNo_TEXT            ,
									AlienRegistn_ID                 = @Demo_REC$AlienRegistn_ID                 ,
									WorkPermitNo_TEXT               = @Demo_REC$WorkPermitNo_TEXT               ,
									BeginPermit_DATE                = @Demo_REC$BeginPermit_DATE                ,
									EndPermit_DATE                  = @Demo_REC$EndPermit_DATE                  ,
									HomePhone_NUMB                  = @Demo_REC$HomePhone_NUMB                  ,
									WorkPhone_NUMB                  = @Demo_REC$WorkPhone_NUMB                  ,
									CellPhone_NUMB                  = @Demo_REC$CellPhone_NUMB                  ,
									Fax_NUMB                        = @Demo_REC$Fax_NUMB                        ,
									Contact_EML                     = @Demo_REC$Contact_EML                     ,
									Spouse_NAME                     = @Demo_REC$Spouse_NAME                     ,
									Graduation_DATE                 = @Demo_REC$Graduation_DATE                 ,
									EducationLevel_CODE             = @Demo_REC$EducationLevel_CODE             ,
									Restricted_INDC                 = @Demo_REC$Restricted_INDC                 ,
									Military_ID                     = @Demo_REC$Military_ID                     ,
									MilitaryBranch_CODE             = @Demo_REC$MilitaryBranch_CODE             ,
									MilitaryStatus_CODE             = @Demo_REC$MilitaryStatus_CODE             ,
									MilitaryBenefitStatus_CODE      = @Demo_REC$MilitaryBenefitStatus_CODE      ,
									SecondFamily_INDC               = @Demo_REC$SecondFamily_INDC               ,
									MeansTestedInc_INDC             = @Demo_REC$MeansTestedInc_INDC             ,
									SsIncome_INDC                   = @Demo_REC$SsIncome_INDC                   ,
									VeteranComps_INDC               = @Demo_REC$VeteranComps_INDC               ,
									Assistance_CODE                 = @Demo_REC$Assistance_CODE                 ,
									DescriptionIdentifyingMarks_TEXT= @Demo_REC$DescriptionIdentifyingMarks_TEXT,
									Divorce_INDC                    = @Demo_REC$Divorce_INDC                    ,
									BeginValidity_DATE              = @Demo_REC$BeginValidity_DATE              ,
									WorkerUpdate_ID                 = @Demo_REC$WorkerUpdate_ID                 ,
									Disable_INDC                    = @Demo_REC$Disable_INDC                    ,
									TypeOccupation_CODE             = @Demo_REC$TypeOccupation_CODE             ,
									CountyBirth_IDNO                = @Demo_REC$CountyBirth_IDNO                ,
									MotherMaiden_NAME               = @Demo_REC$MotherMaiden_NAME               ,
									FileLastDivorce_ID              = @Demo_REC$FileLastDivorce_ID              ,
									TribalAffiliations_CODE         = @Demo_REC$TribalAffiliations_CODE         ,
									FormerMci_IDNO                  = @Demo_REC$FormerMci_IDNO                  ,
									StateDivorce_CODE               = @Demo_REC$StateDivorce_CODE               ,
									CityDivorce_NAME                = @Demo_REC$CityDivorce_NAME                ,
									StateMarriage_CODE              = @Demo_REC$StateMarriage_CODE              ,
									CityMarriage_NAME               = @Demo_REC$CityMarriage_NAME               ,
									IveParty_IDNO                   = @Demo_REC$IveParty_IDNO            
									 FROM DEMO_Y1 d
									WHERE D.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO;
							
								-- End of @Demo_CUR	
								FETCH NEXT FROM @Demo_CUR INTO  @Demo_REC$Individual_IDNO                 ,
																@Demo_REC$Last_NAME                       ,
																@Demo_REC$First_NAME                      ,
																@Demo_REC$Middle_NAME                     ,
																@Demo_REC$Suffix_NAME                     ,
																@Demo_REC$Title_NAME                      ,
																@Demo_REC$FullDisplay_NAME                ,
																@Demo_REC$MemberSex_CODE                  ,
																@Demo_REC$MemberSsn_NUMB                  ,
																@Demo_REC$Birth_DATE                      ,
																@Demo_REC$Emancipation_DATE               ,
																@Demo_REC$LastMarriage_DATE               ,
																@Demo_REC$LastDivorce_DATE                ,
																@Demo_REC$BirthCity_NAME                  ,
																@Demo_REC$BirthState_CODE                 ,
																@Demo_REC$BirthCountry_CODE               ,
																@Demo_REC$DescriptionHeight_TEXT          ,
																@Demo_REC$DescriptionWeightLbs_TEXT       ,
																@Demo_REC$Race_CODE                       ,
																@Demo_REC$ColorHair_CODE                  ,
																@Demo_REC$ColorEyes_CODE                  ,
																@Demo_REC$FacialHair_INDC                 ,
																@Demo_REC$Language_CODE                   ,
																@Demo_REC$TypeProblem_CODE                ,
																@Demo_REC$Deceased_DATE                   ,
																@Demo_REC$CerDeathNo_TEXT                 ,
																@Demo_REC$LicenseDriverNo_TEXT            ,
																@Demo_REC$AlienRegistn_ID                 ,
																@Demo_REC$WorkPermitNo_TEXT               ,
																@Demo_REC$BeginPermit_DATE                ,
																@Demo_REC$EndPermit_DATE                  ,
																@Demo_REC$HomePhone_NUMB                  ,
																@Demo_REC$WorkPhone_NUMB                  ,
																@Demo_REC$CellPhone_NUMB                  ,
																@Demo_REC$Fax_NUMB                        ,
																@Demo_REC$Contact_EML                     ,
																@Demo_REC$Spouse_NAME                     ,
																@Demo_REC$Graduation_DATE                 ,
																@Demo_REC$EducationLevel_CODE             ,
																@Demo_REC$Restricted_INDC                 ,
																@Demo_REC$Military_ID                     ,
																@Demo_REC$MilitaryBranch_CODE             ,
																@Demo_REC$MilitaryStatus_CODE             ,
																@Demo_REC$MilitaryBenefitStatus_CODE      ,
																@Demo_REC$SecondFamily_INDC               ,
																@Demo_REC$MeansTestedInc_INDC             ,
																@Demo_REC$SsIncome_INDC                   ,
																@Demo_REC$VeteranComps_INDC               ,
																@Demo_REC$Assistance_CODE                 ,
																@Demo_REC$DescriptionIdentifyingMarks_TEXT,
																@Demo_REC$Divorce_INDC                    ,
																@Demo_REC$BeginValidity_DATE              ,
																@Demo_REC$WorkerUpdate_ID                 ,
																@Demo_REC$Disable_INDC                    ,
																@Demo_REC$TypeOccupation_CODE             ,
																@Demo_REC$CountyBirth_IDNO                ,
																@Demo_REC$MotherMaiden_NAME               ,
																@Demo_REC$FileLastDivorce_ID              ,
																@Demo_REC$TribalAffiliations_CODE         ,
																@Demo_REC$FormerMci_IDNO                  ,
																@Demo_REC$StateDivorce_CODE               ,
																@Demo_REC$CityDivorce_NAME                ,
																@Demo_REC$StateMarriage_CODE              ,
																@Demo_REC$CityMarriage_NAME               ,
																@Demo_REC$IveParty_IDNO;				
								SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
							END
							-- cursor loop Starts @Demo_CUR		
							CLOSE @Demo_CUR;
							DEALLOCATE @Demo_CUR;
							
							SET @Ls_Sql_TEXT = 'DELETE DEMO_Y1';
							
							DELETE DEMO_Y1
								WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
				END	
			ELSE
				BEGIN
					SET @Ls_Sql_TEXT = 'Replace Secondary with Primary in DEMO_Y1';
							
					UPDATE DEMO_Y1 SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
						WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
				END
			-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - END
		------------------------------------------------------------------------------------------------
		-- HDEMO_y1 -- MemberDemographicsHist_T1
		------------------------------------------------------------------------------------------------					
			SET @Ls_Sql_TEXT = ' SELECT FROM HDEMO_Y1'
					  
			SELECT @Ln_HdemoExists_QNTY = COUNT(1)
                           FROM HDEMO_Y1
                           WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
                           
            IF @Ln_HdemoExists_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = ( SELECT a.*, @Lc_MergeStatusDelete_CODE merge_status 
						FROM HDEMO_Y1 a 
					  WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_HdemoExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
													FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
													
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HDEMO_Y1';
			
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'HDEMO_Y1', 
							 @Ln_HdemoExists_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	 
							 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'DELETE FROM HDEMO_Y1';
					
					DELETE HDEMO_Y1
                     WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;

				END
				
		------------------------------------------------------------------------------------------------
		-- MPAT_Y1 -  MemberPaternity_T1
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'MPAT_Y1 MMERG UPDATION';
								  
			SELECT @Ln_MpatExists_QNTY = COUNT(1)
                           FROM MPAT_Y1
                           WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;				
			
			 IF @Ln_MpatExists_QNTY > 0
				BEGIN
					 SELECT @Lx_XmlData_XML = (SELECT * FROM ( SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status    
								FROM MPAT_Y1 a   
							 WHERE MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
							UNION ALL  
							SELECT a.*, @Lc_MergeStatusDelete_CODE merge_status    
								FROM MPAT_Y1 a   
							 WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO  ) AS S For XML PATH('ROWS'),TYPE);

					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - MPAT_Y1';

					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'MPAT_Y1', 
							 @Ln_MpatExists_QNTY, 
							 ISNULL(CAST(@Lx_XmlData_XML AS VARCHAR(MAX)),' '), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	  
							 
					 SET @Lx_XmlData_XML = NULL;
					
					-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - START 
					SET @Ls_Sql_TEXT = ' LOOP FOR MPAT_Y1';
					 
					IF EXISTS (SELECT 1 FROM MPAT_Y1 a WHERE a.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO) 					 
						BEGIN
							 -- Defining the cursor @Mpat_CUR
							 SET @Mpat_CUR =  
								CURSOR LOCAL FORWARD_ONLY STATIC FOR
									SELECT 
										CASE WHEN LTRIM(RTRIM(a.BirthCertificate_ID            )) = '' THEN b.BirthCertificate_ID             ELSE a.BirthCertificate_ID            END AS BirthCertificate_ID,          
										CASE WHEN LTRIM(RTRIM(a.BornOfMarriage_CODE            )) = '' THEN b.BornOfMarriage_CODE             ELSE a.BornOfMarriage_CODE            END AS BornOfMarriage_CODE,             
										CASE WHEN a.Conception_DATE  = @Ld_Low_DATE THEN b.Conception_DATE                 ELSE a.Conception_DATE                 END AS Conception_DATE,                 
										CASE WHEN LTRIM(RTRIM(a.ConceptionCity_NAME            )) = '' THEN b.ConceptionCity_NAME             ELSE a.ConceptionCity_NAME             END AS ConceptionCity_NAME,
										CASE WHEN a.ConceptionCounty_IDNO = 99 THEN b.ConceptionCounty_IDNO           ELSE a.ConceptionCounty_IDNO           END AS ConceptionCounty_IDNO,           
										CASE WHEN LTRIM(RTRIM(a.ConceptionState_CODE           )) = '' THEN b.ConceptionState_CODE            ELSE a.ConceptionState_CODE            END AS ConceptionState_CODE,
										CASE WHEN LTRIM(RTRIM(a.ConceptionCountry_CODE         )) = '' THEN b.ConceptionCountry_CODE          ELSE a.ConceptionCountry_CODE          END AS ConceptionCountry_CODE,          
										CASE WHEN LTRIM(RTRIM(a.EstablishedMother_CODE         )) = '' THEN b.EstablishedMother_CODE          ELSE a.EstablishedMother_CODE          END AS EstablishedMother_CODE,         
										CASE WHEN a.EstablishedMotherMci_IDNO = 0 THEN b.EstablishedMotherMci_IDNO       ELSE a.EstablishedMotherMci_IDNO       END AS EstablishedMotherMci_IDNO,       
										CASE WHEN LTRIM(RTRIM(a.EstablishedMotherLast_NAME     )) = '' THEN b.EstablishedMotherLast_NAME      ELSE a.EstablishedMotherLast_NAME      END AS EstablishedMotherLast_NAME,      
										CASE WHEN LTRIM(RTRIM(a.EstablishedMotherFirst_NAME    )) = '' THEN b.EstablishedMotherFirst_NAME     ELSE a.EstablishedMotherFirst_NAME     END AS EstablishedMotherFirst_NAME,     
										CASE WHEN LTRIM(RTRIM(a.EstablishedMotherMiddle_NAME   )) = '' THEN b.EstablishedMotherMiddle_NAME    ELSE a.EstablishedMotherMiddle_NAME    END AS EstablishedMotherMiddle_NAME,    
										CASE WHEN LTRIM(RTRIM(a.EstablishedMotherSuffix_NAME   )) = '' THEN b.EstablishedMotherSuffix_NAME    ELSE a.EstablishedMotherSuffix_NAME    END AS EstablishedMotherSuffix_NAME,    
										CASE WHEN LTRIM(RTRIM(a.EstablishedFather_CODE         )) = '' THEN b.EstablishedFather_CODE          ELSE a.EstablishedFather_CODE          END AS EstablishedFather_CODE,    
										CASE WHEN a.EstablishedFatherMci_IDNO = 0 THEN b.EstablishedFatherMci_IDNO       ELSE a.EstablishedFatherMci_IDNO       END AS EstablishedFatherMci_IDNO,
										CASE WHEN LTRIM(RTRIM(a.EstablishedFatherLast_NAME     )) = '' THEN b.EstablishedFatherLast_NAME      ELSE a.EstablishedFatherLast_NAME      END AS EstablishedFatherLast_NAME,
										CASE WHEN LTRIM(RTRIM(a.EstablishedFatherFirst_NAME    )) = '' THEN b.EstablishedFatherFirst_NAME     ELSE a.EstablishedFatherFirst_NAME     END AS EstablishedFatherFirst_NAME,     
										CASE WHEN LTRIM(RTRIM(a.EstablishedFatherMiddle_NAME   )) = '' THEN b.EstablishedFatherMiddle_NAME    ELSE a.EstablishedFatherMiddle_NAME    END AS EstablishedFatherMiddle_NAME,    
										CASE WHEN LTRIM(RTRIM(a.EstablishedFatherSuffix_NAME   )) = '' THEN b.EstablishedFatherSuffix_NAME    ELSE a.EstablishedFatherSuffix_NAME    END AS EstablishedFatherSuffix_NAME,   
										CASE WHEN LTRIM(RTRIM(a.DisEstablishedFather_CODE      )) = '' THEN b.DisEstablishedFather_CODE       ELSE a.DisEstablishedFather_CODE       END AS DisEstablishedFather_CODE,    
										CASE WHEN a.DisEstablishedFatherMci_IDNO = 0 THEN b.DisEstablishedFatherMci_IDNO    ELSE a.DisEstablishedFatherMci_IDNO    END AS DisEstablishedFatherMci_IDNO,
										CASE WHEN LTRIM(RTRIM(a.DisEstablishedFatherLast_NAME  )) = '' THEN b.DisEstablishedFatherLast_NAME   ELSE a.DisEstablishedFatherLast_NAME   END AS DisEstablishedFatherLast_NAME,
										CASE WHEN LTRIM(RTRIM(a.DisEstablishedFatherFirst_NAME )) = '' THEN b.DisEstablishedFatherFirst_NAME  ELSE a.DisEstablishedFatherFirst_NAME  END AS DisEstablishedFatherFirst_NAME,  
										CASE WHEN LTRIM(RTRIM(a.DisEstablishedFatherMiddle_NAME)) = '' THEN b.DisEstablishedFatherMiddle_NAME ELSE a.DisEstablishedFatherMiddle_NAME END AS DisEstablishedFatherMiddle_NAME, 
										CASE WHEN LTRIM(RTRIM(a.DisEstablishedFatherSuffix_NAME)) = '' THEN b.DisEstablishedFatherSuffix_NAME ELSE a.DisEstablishedFatherSuffix_NAME END AS DisEstablishedFatherSuffix_NAME,
										CASE WHEN LTRIM(RTRIM(a.PaternityEst_INDC              )) = '' THEN b.PaternityEst_INDC               ELSE a.PaternityEst_INDC               END AS PaternityEst_INDC,
										CASE WHEN LTRIM(RTRIM(a.StatusEstablish_CODE           )) = '' THEN b.StatusEstablish_CODE            ELSE a.StatusEstablish_CODE            END AS StatusEstablish_CODE,
										CASE WHEN LTRIM(RTRIM(a.StateEstablish_CODE            )) = '' THEN b.StateEstablish_CODE             ELSE a.StateEstablish_CODE             END AS StateEstablish_CODE,           
										CASE WHEN LTRIM(RTRIM(a.FileEstablish_ID               )) = '' THEN b.FileEstablish_ID                ELSE a.FileEstablish_ID                END AS FileEstablish_ID,            
										CASE WHEN LTRIM(RTRIM(a.PaternityEst_CODE              )) = '' THEN b.PaternityEst_CODE               ELSE a.PaternityEst_CODE               END AS PaternityEst_CODE,               
										CASE WHEN a.PaternityEst_DATE = @Ld_Low_DATE THEN b.PaternityEst_DATE               ELSE a.PaternityEst_DATE               END AS PaternityEst_DATE,
										CASE WHEN LTRIM(RTRIM(a.StateDisestablish_CODE         )) = '' THEN b.StateDisestablish_CODE          ELSE a.StateDisestablish_CODE          END AS StateDisestablish_CODE,          
										CASE WHEN LTRIM(RTRIM(a.FileDisestablish_ID            )) = '' THEN b.FileDisestablish_ID             ELSE a.FileDisestablish_ID             END AS FileDisestablish_ID,         
										CASE WHEN LTRIM(RTRIM(a.MethodDisestablish_CODE        )) = '' THEN b.MethodDisestablish_CODE         ELSE a.MethodDisestablish_CODE         END AS MethodDisestablish_CODE,
										CASE WHEN a.Disestablish_DATE = @Ld_Low_DATE THEN b.Disestablish_DATE               ELSE a.Disestablish_DATE               END AS Disestablish_DATE,
										CASE WHEN LTRIM(RTRIM(a.DescriptionProfile_TEXT        )) = '' THEN b.DescriptionProfile_TEXT         ELSE a.DescriptionProfile_TEXT         END AS DescriptionProfile_TEXT,
										CASE WHEN LTRIM(RTRIM(a.QiStatus_CODE                  )) = '' THEN b.QiStatus_CODE                   ELSE a.QiStatus_CODE                   END AS QiStatus_CODE,        
										CASE WHEN LTRIM(RTRIM(a.VapImage_CODE                  )) = '' THEN b.VapImage_CODE                   ELSE a.VapImage_CODE                   END AS VapImage_CODE,                  
										CASE WHEN LTRIM(RTRIM(a.WorkerUpdate_ID                )) = '' THEN b.WorkerUpdate_ID                 ELSE a.WorkerUpdate_ID                 END AS WorkerUpdate_ID,
										CASE WHEN a.BeginValidity_DATE  = @Ld_Low_DATE THEN b.BeginValidity_DATE              ELSE a.BeginValidity_DATE              END AS BeginValidity_DATE
									 FROM (SELECT * FROM MPAT_Y1 WHERE MEMBERMCI_IDNO = @Ln_MemberMciPrimary_IDNO) a,
										  (SELECT * FROM MPAT_Y1 WHERE MEMBERMCI_IDNO = @Ln_MemberMciSecondary_IDNO) b;
							 
								SET @Ls_Sql_TEXT = 'OPEN @Mpat_CUR';

								OPEN @Mpat_CUR;

								SET @Ls_Sql_TEXT = 'FETCH @Mpat_CUR - 1';	

								FETCH NEXT FROM @Mpat_CUR INTO  @Mpat_REC$BirthCertificate_ID            ,
																@Mpat_REC$BornOfMarriage_CODE            ,
																@Mpat_REC$Conception_DATE                ,
																@Mpat_REC$ConceptionCity_NAME            ,
																@Mpat_REC$ConceptionCounty_IDNO          ,
																@Mpat_REC$ConceptionState_CODE           ,
																@Mpat_REC$ConceptionCountry_CODE         ,
																@Mpat_REC$EstablishedMother_CODE         ,
																@Mpat_REC$EstablishedMotherMci_IDNO      ,
																@Mpat_REC$EstablishedMotherLast_NAME     ,
																@Mpat_REC$EstablishedMotherFirst_NAME    ,
																@Mpat_REC$EstablishedMotherMiddle_NAME   ,
																@Mpat_REC$EstablishedMotherSuffix_NAME   ,
																@Mpat_REC$EstablishedFather_CODE         ,
																@Mpat_REC$EstablishedFatherMci_IDNO      ,
																@Mpat_REC$EstablishedFatherLast_NAME     ,
																@Mpat_REC$EstablishedFatherFirst_NAME    ,
																@Mpat_REC$EstablishedFatherMiddle_NAME   ,
																@Mpat_REC$EstablishedFatherSuffix_NAME   ,
																@Mpat_REC$DisEstablishedFather_CODE      ,
																@Mpat_REC$DisEstablishedFatherMci_IDNO   ,
																@Mpat_REC$DisEstablishedFatherLast_NAME  ,
																@Mpat_REC$DisEstablishedFatherFirst_NAME ,
																@Mpat_REC$DisEstablishedFatherMiddle_NAME,
																@Mpat_REC$DisEstablishedFatherSuffix_NAME,
																@Mpat_REC$PaternityEst_INDC              ,
																@Mpat_REC$StatusEstablish_CODE           ,
																@Mpat_REC$StateEstablish_CODE            ,
																@Mpat_REC$FileEstablish_ID               ,
																@Mpat_REC$PaternityEst_CODE              ,
																@Mpat_REC$PaternityEst_DATE              ,
																@Mpat_REC$StateDisestablish_CODE         ,
																@Mpat_REC$FileDisestablish_ID            ,
																@Mpat_REC$MethodDisestablish_CODE        ,
																@Mpat_REC$Disestablish_DATE              ,
																@Mpat_REC$DescriptionProfile_TEXT        ,
																@Mpat_REC$QiStatus_CODE                  ,
																@Mpat_REC$VapImage_CODE                  ,
																@Mpat_REC$WorkerUpdate_ID                ,
																@Mpat_REC$BeginValidity_DATE;
					
								SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;                   
								-- cursor loop Starts @Mpat_CUR		
								WHILE @Li_FetchStatus_QNTY = 0
									BEGIN
										SET @Ls_Sql_TEXT = ' UPDATE MPAT_Y1';
										
										 UPDATE d SET 
											BirthCertificate_ID             = @Mpat_REC$BirthCertificate_ID            ,
											BornOfMarriage_CODE             = @Mpat_REC$BornOfMarriage_CODE            ,
											Conception_DATE                 = @Mpat_REC$Conception_DATE                ,
											ConceptionCity_NAME             = @Mpat_REC$ConceptionCity_NAME            ,
											ConceptionCounty_IDNO           = @Mpat_REC$ConceptionCounty_IDNO          ,
											ConceptionState_CODE            = @Mpat_REC$ConceptionState_CODE           ,
											ConceptionCountry_CODE          = @Mpat_REC$ConceptionCountry_CODE         ,
											EstablishedMother_CODE          = @Mpat_REC$EstablishedMother_CODE         ,
											EstablishedMotherMci_IDNO       = @Mpat_REC$EstablishedMotherMci_IDNO      ,
											EstablishedMotherLast_NAME      = @Mpat_REC$EstablishedMotherLast_NAME     ,
											EstablishedMotherFirst_NAME     = @Mpat_REC$EstablishedMotherFirst_NAME    ,
											EstablishedMotherMiddle_NAME    = @Mpat_REC$EstablishedMotherMiddle_NAME   ,
											EstablishedMotherSuffix_NAME    = @Mpat_REC$EstablishedMotherSuffix_NAME   ,
											EstablishedFather_CODE          = @Mpat_REC$EstablishedFather_CODE         ,
											EstablishedFatherMci_IDNO       = @Mpat_REC$EstablishedFatherMci_IDNO      ,
											EstablishedFatherLast_NAME      = @Mpat_REC$EstablishedFatherLast_NAME     ,
											EstablishedFatherFirst_NAME     = @Mpat_REC$EstablishedFatherFirst_NAME    ,
											EstablishedFatherMiddle_NAME    = @Mpat_REC$EstablishedFatherMiddle_NAME   ,
											EstablishedFatherSuffix_NAME    = @Mpat_REC$EstablishedFatherSuffix_NAME   ,
											DisEstablishedFather_CODE       = @Mpat_REC$DisEstablishedFather_CODE      ,
											DisEstablishedFatherMci_IDNO    = @Mpat_REC$DisEstablishedFatherMci_IDNO   ,
											DisEstablishedFatherLast_NAME   = @Mpat_REC$DisEstablishedFatherLast_NAME  ,
											DisEstablishedFatherFirst_NAME  = @Mpat_REC$DisEstablishedFatherFirst_NAME ,
											DisEstablishedFatherMiddle_NAME = @Mpat_REC$DisEstablishedFatherMiddle_NAME,
											DisEstablishedFatherSuffix_NAME = @Mpat_REC$DisEstablishedFatherSuffix_NAME,
											PaternityEst_INDC               = @Mpat_REC$PaternityEst_INDC              ,
											StatusEstablish_CODE            = @Mpat_REC$StatusEstablish_CODE           ,
											StateEstablish_CODE             = @Mpat_REC$StateEstablish_CODE            ,
											FileEstablish_ID                = @Mpat_REC$FileEstablish_ID               ,
											PaternityEst_CODE               = @Mpat_REC$PaternityEst_CODE              ,
											PaternityEst_DATE               = @Mpat_REC$PaternityEst_DATE              ,
											StateDisestablish_CODE          = @Mpat_REC$StateDisestablish_CODE         ,
											FileDisestablish_ID             = @Mpat_REC$FileDisestablish_ID            ,
											MethodDisestablish_CODE         = @Mpat_REC$MethodDisestablish_CODE        ,
											Disestablish_DATE               = @Mpat_REC$Disestablish_DATE              ,
											DescriptionProfile_TEXT         = @Mpat_REC$DescriptionProfile_TEXT        ,
											QiStatus_CODE                   = @Mpat_REC$QiStatus_CODE                  ,
											VapImage_CODE                   = @Mpat_REC$VapImage_CODE                  ,
											WorkerUpdate_ID                 = @Mpat_REC$WorkerUpdate_ID                ,
											BeginValidity_DATE              = @Mpat_REC$BeginValidity_DATE
											 FROM MPAT_Y1 d
											WHERE D.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO;
					
									-- End of @Mpat_CUR	
									FETCH NEXT FROM @Mpat_CUR INTO  @Mpat_REC$BirthCertificate_ID            ,
																	@Mpat_REC$BornOfMarriage_CODE            ,
																	@Mpat_REC$Conception_DATE                ,
																	@Mpat_REC$ConceptionCity_NAME            ,
																	@Mpat_REC$ConceptionCounty_IDNO          ,
																	@Mpat_REC$ConceptionState_CODE           ,
																	@Mpat_REC$ConceptionCountry_CODE         ,
																	@Mpat_REC$EstablishedMother_CODE         ,
																	@Mpat_REC$EstablishedMotherMci_IDNO      ,
																	@Mpat_REC$EstablishedMotherLast_NAME     ,
																	@Mpat_REC$EstablishedMotherFirst_NAME    ,
																	@Mpat_REC$EstablishedMotherMiddle_NAME   ,
																	@Mpat_REC$EstablishedMotherSuffix_NAME   ,
																	@Mpat_REC$EstablishedFather_CODE         ,
																	@Mpat_REC$EstablishedFatherMci_IDNO      ,
																	@Mpat_REC$EstablishedFatherLast_NAME     ,
																	@Mpat_REC$EstablishedFatherFirst_NAME    ,
																	@Mpat_REC$EstablishedFatherMiddle_NAME   ,
																	@Mpat_REC$EstablishedFatherSuffix_NAME   ,
																	@Mpat_REC$DisEstablishedFather_CODE      ,
																	@Mpat_REC$DisEstablishedFatherMci_IDNO   ,
																	@Mpat_REC$DisEstablishedFatherLast_NAME  ,
																	@Mpat_REC$DisEstablishedFatherFirst_NAME ,
																	@Mpat_REC$DisEstablishedFatherMiddle_NAME,
																	@Mpat_REC$DisEstablishedFatherSuffix_NAME,
																	@Mpat_REC$PaternityEst_INDC              ,
																	@Mpat_REC$StatusEstablish_CODE           ,
																	@Mpat_REC$StateEstablish_CODE            ,
																	@Mpat_REC$FileEstablish_ID               ,
																	@Mpat_REC$PaternityEst_CODE              ,
																	@Mpat_REC$PaternityEst_DATE              ,
																	@Mpat_REC$StateDisestablish_CODE         ,
																	@Mpat_REC$FileDisestablish_ID            ,
																	@Mpat_REC$MethodDisestablish_CODE        ,
																	@Mpat_REC$Disestablish_DATE              ,
																	@Mpat_REC$DescriptionProfile_TEXT        ,
																	@Mpat_REC$QiStatus_CODE                  ,
																	@Mpat_REC$VapImage_CODE                  ,
																	@Mpat_REC$WorkerUpdate_ID                ,
																	@Mpat_REC$BeginValidity_DATE;
															
									SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;    
								END
								-- cursor loop Starts @Mpat_CUR		
								CLOSE @Mpat_CUR;
								DEALLOCATE @Mpat_CUR;

								SET @Ls_Sql_TEXT = 'DELETE MPAT_Y1';
					
							DELETE MPAT_Y1
								WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
						END	
					ELSE 
						BEGIN 
							SET @Ls_Sql_TEXT = ' UPDATE MPAT_Y1 SECONDARY TO PRIMARY';
							
							UPDATE MPAT_Y1 SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
								WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
						END
					-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - END 													
				END                           				  

		------------------------------------------------------------------------------------------------
		-- HMPAT_Y1 -- MemberPaternityHist_T1
		------------------------------------------------------------------------------------------------					
			SET @Ls_Sql_TEXT = ' SELECT FROM HMPAT_Y1'
		  
			SELECT @Ln_HmpatExists_QNTY = COUNT(1)
						   FROM HMPAT_Y1
						   WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
               
			IF @Ln_HmpatExists_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = ( SELECT a.*, @Lc_MergeStatusDelete_CODE merge_status 
						FROM HMPAT_Y1 a 
					  WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_HmpatExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
													FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
													
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HMPAT_Y1';

					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'HMPAT_Y1', 
							 @Ln_HmpatExists_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	 
							 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'DELETE FROM HMPAT_Y1';
					
					-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - START 
					DELETE HMPAT_Y1 
					 WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
						AND EXISTS (SELECT 1 FROM HMPAT_Y1 b WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO) 	
						
					/*When Primary Member Not exists in HMPAT_Y1, then replace secondary with primary*/
					IF @@ROWCOUNT = 0
						BEGIN
							SET @Ls_Sql_TEXT = ' UPDATE HMPAT_Y1 SECONDARY TO PRIMARY';
							
							UPDATE MPAT_Y1 SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
								WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
						END					
					-- 13271  - MERG - CR0367 Amend MCI Number 20140219 - END 
				END		
				------------------------------------------------------------------------------------------------
		--  FcrAuditDetails_T1
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'MMRG_Y1 - FADT_Y1 MMERG UPDATION';
			
			-- Defining the cursor @Fadt_CUR
			SET @Fadt_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT DISTINCT Case_IDNO, TypeTrans_CODE
						FROM FADT_Y1
						WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
						ORDER BY Case_IDNO;
						
			SET @Ls_Sql_TEXT = 'OPEN @Fadt_CUR';

			OPEN @Fadt_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Fadt_CUR - 1';	

			FETCH NEXT FROM @Fadt_CUR INTO @Fadt_REC$Case_IDNO, @Fadt_REC$TypeTrans_CODE;
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			-- cursor loop Starts @Ensd_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN				
					SET @Ls_Sql_TEXT = ' SELECT FADT_Y1';			
			 
					 SELECT @Ln_FadtValidation_QNTY = COUNT(1)
						FROM FADT_Y1
						WHERE MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO AND
							  Case_IDNO = @Fadt_REC$Case_IDNO AND
							  TypeTrans_CODE = @Fadt_REC$TypeTrans_CODE;
							  
							  
					IF	@Ln_FadtValidation_QNTY	= 0
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*,  @Lc_MergeStatusUpdate_CODE merge_status FROM FADT_Y1 a     
													WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
												
							SELECT @Ln_FadtValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																				FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																				
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - FADT_Y1';
							INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'FADT_Y1', 
							 @Ln_FadtValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' UPDATE FADT_Y1';
							
							UPDATE FADT_Y1
							   SET  MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
							WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
							  AND Case_IDNO = @Fadt_REC$Case_IDNO
							  AND TypeTrans_CODE = @Fadt_REC$TypeTrans_CODE;
						END		
					ELSE
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*,  
															 @Lc_MergeStatusDelete_CODE merge_status 
														FROM FADT_Y1 a
													   WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
														 AND a.Case_IDNO = @Fadt_REC$Case_IDNO
														 AND a.TypeTrans_CODE = @Fadt_REC$TypeTrans_CODE for XML PATH('ROWS'),TYPE);
												
							SELECT @Ln_FadtValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																				FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																				
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - FADT_Y1 2';
							INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'FADT_Y1', 
							 @Ln_FadtValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = 'DELETE ENSD_Y1';
							
							 DELETE FADT_Y1
							  WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
								AND	Case_IDNO = @Fadt_REC$Case_IDNO
								AND TypeTrans_CODE = @Fadt_REC$TypeTrans_CODE;
						END					
					--End of Loop
					FETCH NEXT FROM @Fadt_CUR INTO @Fadt_REC$Case_IDNO, @Fadt_REC$TypeTrans_CODE;
					SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
				CLOSE @Fadt_CUR;
				DEALLOCATE @Fadt_CUR;
				-- cursor loop Ends @Fadt_CUR
		------------------------------------------------------------------------------------------------
		-- FcrPendingRejects_T1 Table
		------------------------------------------------------------------------------------------------				
			 SET @Ls_Sql_TEXT = 'FPRJ_Y1 MMERG UPDATION';
			 
			 -- Defining the cursor @Fprj_CUR
			SET @Fprj_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT DISTINCT Case_IDNO
						FROM FPRJ_Y1
						WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
						ORDER BY Case_IDNO;
						
			SET @Ls_Sql_TEXT = 'OPEN @Fprj_CUR';

			OPEN @Fprj_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Fprj_CUR - 1';
			
			FETCH NEXT FROM @Fprj_CUR INTO @Fprj_REC$Case_IDNO
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			-- cursor loop Starts @Fprj_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN			
					SET @Ls_Sql_TEXT = ' SELECT FPRJ_Y1';
					
					SELECT @Ln_FprjValidation_QNTY = COUNT(1)
						FROM FPRJ_Y1
						WHERE MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
						  AND Case_IDNO = @Fprj_REC$Case_IDNO;
							  
					 IF @Ln_FprjValidation_QNTY = 0
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*, 
															 @Lc_MergeStatusUpdate_CODE merge_status 
														FROM FPRJ_Y1 a
													   WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
														 AND a.Case_IDNO = @Fprj_REC$Case_IDNO for XML PATH('ROWS'),TYPE);
												
							SELECT @Ln_FprjValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																				FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																				
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - FPRJ_Y1 1';
							INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'FPRJ_Y1', 
							 @Ln_FprjValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' UPDATE FPRJ_Y1';
							
							UPDATE FPRJ_Y1
							  SET  MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
							WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
							  AND Case_IDNO = @Fprj_REC$Case_IDNO;																			
						END
					ELSE
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*, 
															 @Lc_MergeStatusUpdate_CODE merge_status 
														FROM FPRJ_Y1 a
													   WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
														 AND Case_IDNO = @Fprj_REC$Case_IDNO for XML PATH('ROWS'),TYPE);
												
							SELECT @Ln_FprjValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																				FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																				
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - FPRJ_Y1 2';
							INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'FPRJ_Y1', 
							 @Ln_FprjValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
							 SET @Lx_XmlData_XML = NULL;
							 
							 SET @Ls_Sql_TEXT = ' DELETE FPRJ_Y1';
							 
							 DELETE FPRJ_Y1
							  WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
								AND Case_IDNO = @Fprj_REC$Case_IDNO;							 
						END											
					--End of loop
					FETCH NEXT FROM @Fprj_CUR INTO @Fprj_REC$Case_IDNO
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;					
			 	END
			 	CLOSE @Fprj_CUR;
				DEALLOCATE @Fprj_CUR;
				-- cursor loop Ends @Fprj_CUR	
		------------------------------------------------------------------------------------------------
		-- FcrQuarterlyWage_T1
		------------------------------------------------------------------------------------------------					
			SET @Ls_Sql_TEXT = 'SELECT FCRQ_Y1';
			
			SELECT @Ln_FcrqValidation_QNTY = COUNT(1)
				FROM FCRQ_Y1
				WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;

			IF @Ln_FcrqValidation_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status FROM FCRQ_Y1 a 
												WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_FcrqValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																		FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																		
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - FCRQ_Y1';
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @Ln_MemberMciPrimary_IDNO, 
					 @Ln_MemberMciSecondary_IDNO, 
					 'FCRQ_Y1', 
					 @Ln_FcrqValidation_QNTY,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);
					 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE FCRQ_Y1';	
					
					UPDATE FCRQ_Y1
					   SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
					WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;																	
				END
				
		------------------------------------------------------------------------------------------------
		-- FederalLastSent_T1 
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'SELECT FEDH_Y1';
			
			SELECT @Ln_FedhValidation_QNTY = COUNT(1)
				FROM FEDH_Y1
				WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;

			IF @Ln_FedhValidation_QNTY > 0
				BEGIN				
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 FROM FEDH_Y1 b
																				WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO)
																 THEN @Lc_MergeStatusDelete_CODE
																 ELSE @Lc_MergeStatusUpdate_CODE
															 END merge_status FROM FEDH_Y1 a 
													WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_FedhValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																		FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																		
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - FEDH_Y1';
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @Ln_MemberMciPrimary_IDNO, 
					 @Ln_MemberMciSecondary_IDNO, 
					 'FEDH_Y1', 
					 @Ln_FedhValidation_QNTY,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);
					 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' DELETE FEDH_Y1';
					
					DELETE FEDH_Y1
						FROM FEDH_Y1  AS a
						WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
						  AND EXISTS 
						   (
							  SELECT 1
							  FROM FEDH_Y1 b
							  WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
						   );

						SET @Ls_Sql_TEXT = ' UPDATE FEDH_Y1';

						UPDATE FEDH_Y1
						   SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
						 WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
				END
		------------------------------------------------------------------------------------------------
		--  FederalLastSentHist_T1 TABLE
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'SELECT HFEDH_Y1';
			
			--Delete secondary member record if primary exists
			SELECT @Ln_HfedhValidation_QNTY = COUNT(1)
				FROM HFEDH_Y1
				WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO; 
				
			IF @Ln_HfedhValidation_QNTY > 0
				BEGIN				
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 FROM HFEDH_Y1 b
																				WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO)
																 THEN @Lc_MergeStatusDelete_CODE
																 ELSE @Lc_MergeStatusUpdate_CODE
															END merge_status 
												FROM HFEDH_Y1 a 
											   WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO FOR XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_HfedhValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																		FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																		
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HFEDH_Y1';
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @Ln_MemberMciPrimary_IDNO, 
					 @Ln_MemberMciSecondary_IDNO, 
					 'HFEDH_Y1', 
					 @Ln_HfedhValidation_QNTY,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);
					 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' DELETE HFEDH_Y1';
					
					DELETE HFEDH_Y1
						FROM HFEDH_Y1 a
						WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
						  AND EXISTS
						   (
							  SELECT 1
							  FROM HFEDH_Y1 b
							  WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
						   );

						SET @Ls_Sql_TEXT = ' UPDATE HFEDH_Y1';

						UPDATE HFEDH_Y1
						   SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
						WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;			 			
				END
		
		------------------------------------------------------------------------------------------------
		--  TaxCertExclusionDetails_T1 Table
		------------------------------------------------------------------------------------------------	
			SET @Ls_Sql_TEXT = 'MMRG_Y1 - TEXC_Y1 MMERG UPDATION';	
			
			SELECT @Ln_TexcValidation_QNTY = COUNT(1)
				FROM TEXC_Y1
			WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
			
			IF @Ln_TexcValidation_QNTY > 0
			BEGIN
				SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 FROM TEXC_Y1 b 
																			WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO)
															  THEN @Lc_MergeStatusDelete_CODE 
															  ELSE @Lc_MergeStatusUpdate_CODE
														END merge_status FROM TEXC_Y1 a
											 WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
												
				SELECT @Ln_TexcValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
													FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
													
				SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - TEXC_Y1';
				INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
						VALUES (
						 @Ln_MemberMciPrimary_IDNO, 
						 @Ln_MemberMciSecondary_IDNO, 
						 'TEXC_Y1', 
						 @Ln_TexcValidation_QNTY,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
						 @An_TransactionEventSeq_NUMB, 
						 @Ad_Run_DATE);

				SET @Lx_XmlData_XML = NULL;
				
				SET @Ls_Sql_TEXT = 'DELETE TEXC_Y1';

				DELETE TEXC_Y1
				FROM TEXC_Y1  AS a
				WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
				  AND EXISTS ( SELECT 1
								  FROM TEXC_Y1 b
								  WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO);

				SET @Ls_Sql_TEXT = ' UPDATE TEXC_Y1';

				UPDATE TEXC_Y1
				   SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
				WHERE TEXC_Y1.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
			END
		--------------------------------------------------------------------------------
		--  UnidentifiedReceipts_T1
		---------------------------------------------------------------------------------			
			SET @Ls_Sql_TEXT = 'URCT_Y1 MMERG UPDATION';
			
			SELECT @Ln_UrctValidation_QNTY = COUNT(1)
				FROM URCT_Y1
				WHERE IdentifiedPayorMci_IDNO = @Ln_MemberMciSecondary_IDNO;
				
			IF @Ln_UrctValidation_QNTY > 0
				BEGIN				
					 SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status FROM URCT_Y1 a 
												WHERE IdentifiedPayorMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_TexcValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
														
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - URCT_Y1';
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'URCT_Y1', 
							 @Ln_UrctValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);

					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'UPDATE URCT_Y1';		
					
					UPDATE URCT_Y1
					   SET IdentifiedPayorMci_IDNO = @Ln_MemberMciPrimary_IDNO
					WHERE IdentifiedPayorMci_IDNO = @Ln_MemberMciSecondary_IDNO;											
				END
		--------------------------------------------------------------------------------
		-- UserRestrictions_T1 Table
		---------------------------------------------------------------------------------			
			SET @Ls_Sql_TEXT = 'MMRG_Y1 - USRT_Y1 MMERG UPDATION';
			-- Defining the cursor @Usrt_CUR
			SET @Usrt_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT DISTINCT Case_IDNO
						FROM USRT_Y1
						WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
						
			SET @Ls_Sql_TEXT = 'OPEN @Usrt_CUR';

			OPEN @Usrt_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Usrt_CUR - 1';
			
			FETCH NEXT FROM @Usrt_CUR INTO @Usrt_REC$Case_IDNO
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			-- cursor loop Starts @Usrt_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN		
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 
																			  FROM USRT_Y1 b
																			 WHERE MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
																			   AND Case_IDNO  = a.Case_IDNO
																			   AND Worker_ID = a.Worker_ID
																			   AND TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
																 THEN @Lc_MergeStatusDelete_CODE
																 ELSE @Lc_MergeStatusUpdate_CODE
															END merge_status 
												  FROM USRT_Y1 a
												 WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO AND 
													   Case_IDNO       = @Usrt_REC$Case_IDNO for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_UsrtValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
														
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - USRT_Y1';
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'USRT_Y1', 
							 @Ln_UsrtValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'DELETE USRT_Y1';

					DELETE USRT_Y1
					FROM USRT_Y1 a
					WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
					  AND a.Case_IDNO = @Usrt_REC$Case_IDNO 
					  AND EXISTS( SELECT 1
									FROM USRT_Y1 b
								   WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
									 AND b.Case_IDNO = a.Case_IDNO
									 AND b.Worker_ID = a.Worker_ID 
									 AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);
							 
					SET @Ls_Sql_TEXT = 'UPDATE USRT_Y1 1';

					UPDATE a
					   SET EndValidity_DATE = @Ad_Run_DATE
					  FROM USRT_Y1 a
					 WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
					   AND a.Case_IDNO = @Usrt_REC$Case_IDNO 
					   AND a.EndValidity_DATE = @Ld_High_DATE
					   AND EXISTS ( SELECT 1
									  FROM USRT_Y1 b
									 WHERE b.MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO 
									   AND a.Case_IDNO = b.Case_IDNO 
									   AND b.EndValidity_DATE = @Ld_High_DATE);

					SET @Ls_Sql_TEXT = 'DELETE USRT_Y1 2';

					UPDATE USRT_Y1
					   SET MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
					 WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
					   AND Case_IDNO = @Usrt_REC$Case_IDNO;
					
					--End of Loop	
					FETCH NEXT FROM @Usrt_CUR INTO @Usrt_REC$Case_IDNO
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
				CLOSE @Usrt_CUR;
				DEALLOCATE @Usrt_CUR;
				-- cursor loop Starts @Usrt_CUR
		---------------------------------------------------------------------------------
		-- Merge NoticePrintRequest_T1 table
		---------------------------------------------------------------------------------
			-- 13588 - String to Numeric conversion Issue fixed - Start
			SET @Ls_Sql_TEXT = 'SELECT NMRQ_Y1';
			
			SELECT @Ln_NmrqValidation_QNTY = COUNT(1)
				FROM NMRQ_Y1  AS a
				WHERE ISNUMERIC(a.Recipient_ID) = 1
				  AND a.Recipient_ID = @Ln_MemberMciSecondary_IDNO 
				  AND a.Case_IDNO IN 
				   (
					  SELECT b.Case_IDNO
					  FROM UCMEM_V1  AS b
					  WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO);
					  
			IF @Ln_NmrqValidation_QNTY > 0
				BEGIN							  					  
					SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status 
												FROM NMRQ_Y1 a 
												WHERE ISNUMERIC(a.Recipient_ID) = 1
												  AND a.Recipient_ID = @Ln_MemberMciSecondary_IDNO 
												  AND a.Case_IDNO IN (SELECT b.Case_IDNO FROM UCMEM_V1 b
																	WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_NmrqValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
														
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - NMRQ_Y1';
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'NMRQ_Y1', 
							 @Ln_NmrqValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE NMRQ_Y1';

					UPDATE NMRQ_Y1
					   SET Recipient_ID = @Ln_MemberMciPrimary_IDNO
					FROM NMRQ_Y1  AS a
					WHERE ISNUMERIC(a.Recipient_ID) = 1
					  AND a.Recipient_ID = @Ln_MemberMciSecondary_IDNO 
					  AND a.Case_IDNO IN 
					   (
						  SELECT b.Case_IDNO
						  FROM UCMEM_V1  AS b
						  WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
					   );						 
				END
		-----------------------------------------------------------------------
		-- Merge NoticeReprintRequest_T1 table
		-----------------------------------------------------------------------				
			 SET @Ls_Sql_TEXT = 'SELECT NRRQ_Y1';
			 
			 SELECT @Ln_NrrqValidation_QNTY = COUNT(1)
				FROM NRRQ_Y1  AS a
				WHERE ISNUMERIC(a.Recipient_ID) = 1
				  AND a.Recipient_ID = @Ln_MemberMciSecondary_IDNO 
				  AND a.Case_IDNO IN ( SELECT b.Case_IDNO
										 FROM UCMEM_V1  AS b
										WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO); 
					  
			IF @Ln_NrrqValidation_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status  
												FROM NRRQ_Y1 a 
												WHERE ISNUMERIC(a.Recipient_ID) = 1
												  AND a.Recipient_ID = @Ln_MemberMciSecondary_IDNO 
												  AND a.Case_IDNO IN (SELECT b.Case_IDNO FROM UCMEM_V1 b
																	 WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_NrrqValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
														
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - NRRQ_Y1';
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'NRRQ_Y1', 
							 @Ln_NrrqValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE NRRQ_Y1 '

					UPDATE NRRQ_Y1
					   SET Recipient_ID = @Ln_MemberMciPrimary_IDNO
					FROM NRRQ_Y1  AS a
					WHERE ISNUMERIC(a.Recipient_ID) = 1
					  AND a.Recipient_ID = @Ln_MemberMciSecondary_IDNO 
					  AND a.Case_IDNO IN ( SELECT b.Case_IDNO
											 FROM UCMEM_V1  AS b
											WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO);
				END
				-- 13588 - String to Numeric conversion Issue fixed - End
		 --------------------------------------------------------------------------------
		-- Merge DocketPersons_T1 Table
		---------------------------------------------------------------------------------
			SET @Ls_Sql_TEXT = 'MMRG_Y1 - DPRS_Y1 MMERG UPDATION'
			-- 13693 - DPRS Primary Voilation Fix and Associated MemberMci Merge Implementation - Start
			SELECT @Ln_DprsValidation_QNTY = COUNT(1)
			  FROM DPRS_Y1 d
			 WHERE d.DocketPerson_IDNO = @Ln_MemberMciSecondary_IDNO
			   AND d.TypePerson_CODE IN (@Lc_TypePersonCp_CODE,@Lc_TypePersonNcp_CODE,@Lc_TypePersonChild_CODE,@Lc_TypePersonGuardian_CODE);
			
			IF @Ln_DprsValidation_QNTY > 0
				BEGIN	
					-- Delete Primary when it is COF and corresponding Secondary is DF in same docket
				   -- Delete Secondary when it is COF and corresponding Primary is DF in same docket
				   -- Delete Primary when it is CPL and corresponding Secondary is PL in same docket
				   -- Delete Secondary when it is CPL and corresponding Primary is PL in same docket
					SELECT @Lx_XmlData_XML = (SELECT a.* ,@Lc_MergeStatusDelete_CODE merge_status 
												FROM DPRS_Y1 a
												WHERE a.DocketPerson_IDNO IN (@Ln_MemberMciPrimary_IDNO, @Ln_MemberMciSecondary_IDNO) 
												  AND a.TypePerson_CODE IN (@Lc_TypePersonNcp_CODE, @Lc_TypePersonCp_CODE) 
												  AND a.EndValidity_DATE = @Ld_High_DATE 
												  AND a.EffectiveEnd_DATE = @Ld_High_DATE 
												  AND EXISTS (SELECT 1 
																FROM DPRS_Y1 b
																WHERE a.File_ID = b.File_ID 
																  AND b.DocketPerson_IDNO IN (@Ln_MemberMciPrimary_IDNO, @Ln_MemberMciSecondary_IDNO) 
																  AND (b.TypePerson_CODE = @Lc_TypePersonNcp_CODE
																		OR b.TypePerson_CODE = @Lc_TypePersonCp_CODE) 
																  AND a.DocketPerson_IDNO <> b.DocketPerson_IDNO 
																  AND b.EndValidity_DATE = @Ld_High_DATE 
																  AND b.EffectiveEnd_DATE = @Ld_High_DATE) for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_DprsValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
														
					IF @Ln_DprsValidation_QNTY > 0
						BEGIN
							SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - DPRS_Y1 1';
							INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'DPRS_Y1', 
							 @Ln_DprsValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' DELETE DPRS_Y1';

							DELETE DPRS_Y1
							FROM DPRS_Y1  AS a
							WHERE a.DocketPerson_IDNO IN ( @Ln_MemberMciPrimary_IDNO, @Ln_MemberMciSecondary_IDNO ) 
							  AND a.TypePerson_CODE IN (@Lc_TypePersonNcp_CODE, @Lc_TypePersonCp_CODE) 
							  AND a.EndValidity_DATE = @Ld_High_DATE 
							  AND a.EffectiveEnd_DATE = @Ld_High_DATE 
							  AND EXISTS 
							   (
								  SELECT 1
								  FROM DPRS_Y1 b
								  WHERE a.File_ID = b.File_ID 
								    AND b.DocketPerson_IDNO IN ( @Ln_MemberMciPrimary_IDNO, @Ln_MemberMciSecondary_IDNO ) 
								    AND ((b.TypePerson_CODE = @Lc_TypePersonNcp_CODE) 
											OR (b.TypePerson_CODE = @Lc_TypePersonCp_CODE)) 
									AND a.DocketPerson_IDNO <> b.DocketPerson_IDNO 
									AND b.EndValidity_DATE = @Ld_High_DATE 
									AND b.EffectiveEnd_DATE = @Ld_High_DATE);
						END	
						
					
					SELECT @Lx_XmlData_XML = (SELECT a.* ,@Lc_MergeStatusDelete_CODE merge_status FROM DPRS_Y1 a
												WHERE a.DocketPerson_IDNO = @Ln_MemberMciSecondary_IDNO 
												  AND a.TypePerson_CODE = @Lc_TypePersonChild_CODE 
												  AND a.EndValidity_DATE = @Ld_High_DATE 
												  AND a.EffectiveEnd_DATE = @Ld_High_DATE 
												  AND EXISTS (SELECT 1 
																FROM DPRS_Y1 b
																WHERE a.File_ID = b.File_ID 
																  AND b.DocketPerson_IDNO = @Ln_MemberMciPrimary_IDNO 
																  AND b.TypePerson_CODE = @Lc_TypePersonChild_CODE  
																  AND a.DocketPerson_IDNO <> b.DocketPerson_IDNO 
																  AND b.EndValidity_DATE = @Ld_High_DATE 
																  AND b.EffectiveEnd_DATE = @Ld_High_DATE) for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_DprsValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
														
					IF @Ln_DprsValidation_QNTY > 0
						BEGIN
							SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - DPRS_Y1 2';
							INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'DPRS_Y1', 
							 @Ln_DprsValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' DELETE DPRS_Y1 2';

							DELETE DPRS_Y1
							FROM DPRS_Y1  AS a
							WHERE a.DocketPerson_IDNO = @Ln_MemberMciSecondary_IDNO  
							  AND a.TypePerson_CODE = @Lc_TypePersonChild_CODE
							  AND a.EndValidity_DATE = @Ld_High_DATE
							  AND a.EffectiveEnd_DATE = @Ld_High_DATE
							  AND EXISTS ( SELECT 1
											FROM DPRS_Y1  AS b
										   WHERE a.File_ID = b.File_ID 
											 AND b.DocketPerson_IDNO = @Ln_MemberMciPrimary_IDNO 
											 AND b.TypePerson_CODE = @Lc_TypePersonChild_CODE
											 AND a.DocketPerson_IDNO <> b.DocketPerson_IDNO
											 AND b.EndValidity_DATE = @Ld_High_DATE
											 AND b.EffectiveEnd_DATE = @Ld_High_DATE);
						END	
						
					SET @Lx_XmlData_XML = NULL;		
																
					SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status FROM DPRS_Y1 a
						WHERE a.DocketPerson_IDNO = @Ln_MemberMciSecondary_IDNO
						  AND a.TypePerson_CODE IN (@Lc_TypePersonCp_CODE,@Lc_TypePersonNcp_CODE,@Lc_TypePersonChild_CODE,@Lc_TypePersonGuardian_CODE) for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_DprsValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
					IF @Ln_DprsValidation_QNTY > 0
						BEGIN
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DPRS_Y1 2';	
							INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
							VALUES (
							 @Ln_MemberMciPrimary_IDNO, 
							 @Ln_MemberMciSecondary_IDNO, 
							 'DPRS_Y1', 
							 @Ln_DprsValidation_QNTY,
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
							 SET @Lx_XmlData_XML = NULL;
							 
							 SET @Ls_Sql_TEXT = ' UPDATE DPRS_Y1 '

							UPDATE DPRS_Y1
							   SET DocketPerson_IDNO = @Ln_MemberMciPrimary_IDNO
							 WHERE DocketPerson_IDNO = @Ln_MemberMciSecondary_IDNO
							   AND TypePerson_CODE IN (@Lc_TypePersonCp_CODE,@Lc_TypePersonNcp_CODE,@Lc_TypePersonChild_CODE,@Lc_TypePersonGuardian_CODE);
						END
				END	
				
			SET @Ls_Sql_TEXT = 'MMRG_Y1 - DPRS_Y1 MMERG UPDATION 3';
			
			SELECT @Ln_DprsValidation_QNTY = COUNT(1)
				FROM DPRS_Y1 d
				WHERE d.AssociatedMemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
			
			IF @Ln_DprsValidation_QNTY > 0
				BEGIN

					SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status    FROM DPRS_Y1 a
						WHERE a.AssociatedMemberMci_IDNO = @Ln_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
												
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DPRS_Y1 3';	
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @Ln_MemberMciPrimary_IDNO, 
					 @Ln_MemberMciSecondary_IDNO, 
					 'DPRS_Y1', 
					 @Ln_DprsValidation_QNTY,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);
					 
					 SET @Lx_XmlData_XML = NULL;
					 
					 SET @Ls_Sql_TEXT = ' UPDATE DPRS_Y1 3'

					UPDATE DPRS_Y1
					   SET AssociatedMemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
					WHERE AssociatedMemberMci_IDNO = @Ln_MemberMciSecondary_IDNO;
			END	
			-- 13693 - DPRS Primary Voilation Fix and Associated MemberMci Merge Implementation - End											
				
		------------------------------------------------------------------------------------------------
		-- CaseJournalActivity_T1 Table
		------------------------------------------------------------------------------------------------							 		
			SET @Ls_Sql_TEXT = 'SELECT CJNR_Y1';
			
			 SELECT @Ln_CjnrValidation_QNTY = COUNT(1)
				 FROM CJNR_Y1  AS a
				 WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
				   AND a.Case_IDNO IN ( SELECT b.Case_IDNO
										 FROM UCMEM_V1  AS b
										WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO);	
					   	
			IF @Ln_CjnrValidation_QNTY > 0
				BEGIN	
					SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE AS merge_status FROM CJNR_Y1 a
						WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO AND 
							  a.Case_IDNO  IN (SELECT Case_IDNO FROM UCMEM_V1 b
												WHERE MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_CjnrValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);	
														
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - CJNR_Y1';	
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @Ln_MemberMciPrimary_IDNO, 
					 @Ln_MemberMciSecondary_IDNO, 
					 'CJNR_Y1', 
					 @Ln_CjnrValidation_QNTY,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);	
					 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE CJNR_Y1';

					UPDATE CJNR_Y1
					   SET 
						  MemberMci_IDNO = @Ln_MemberMciPrimary_IDNO
					FROM CJNR_Y1 a
					WHERE a.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO 
					  AND a.Case_IDNO IN 
					   (SELECT b.Case_IDNO
						  FROM UCMEM_V1  AS b
						  WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO);					 		    						  
				END
		------------------------------------------------------------------------------------------------
		-- DocumentMaintenance_T1 Table
		------------------------------------------------------------------------------------------------		
			SET @Ls_Sql_TEXT = 'SELECT FDEM_Y1';
			
			SELECT @Ln_FdemValidation_QNTY = COUNT(1)
				FROM FDEM_Y1 a
				WHERE ( a.Petitioner_IDNO = @Ln_MemberMciSecondary_IDNO 
					OR a.Respondent_IDNO = @Ln_MemberMciSecondary_IDNO)
				  AND a.Case_IDNO IN (SELECT b.Case_IDNO
										FROM UCMEM_V1 b
									   WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO); 
									   
			IF @Ln_FdemValidation_QNTY > 0
				BEGIN	
					SELECT @Lx_XmlData_XML = (SELECT a.*, @Lc_MergeStatusUpdate_CODE merge_status FROM FDEM_Y1 a 
						WHERE (a.Petitioner_IDNO = @Ln_MemberMciSecondary_IDNO 
								OR a.Respondent_IDNO = @Ln_MemberMciSecondary_IDNO) 
						  AND a.Case_IDNO IN (SELECT b.Case_IDNO FROM UCMEM_V1 b  
												WHERE b.MemberMci_IDNO =  @Ln_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_FdemValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
														
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - FDEM_Y1';	
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @Ln_MemberMciPrimary_IDNO, 
					 @Ln_MemberMciSecondary_IDNO, 
					 'FDEM_Y1', 
					 @Ln_FdemValidation_QNTY,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);		
					 
					 SET @Lx_XmlData_XML = NULL;
					 
					 SET @Ls_Sql_TEXT = ' UPDATE FDEM_Y1';
					 	
					 UPDATE FDEM_Y1
					   SET 
						  Petitioner_IDNO = 
							 CASE 
								WHEN a.Petitioner_IDNO = @Ln_MemberMciSecondary_IDNO THEN @Ln_MemberMciPrimary_IDNO
								ELSE a.Petitioner_IDNO
							 END, 
						  Respondent_IDNO = 
							 CASE 
								WHEN a.Respondent_IDNO = @Ln_MemberMciSecondary_IDNO THEN @Ln_MemberMciPrimary_IDNO
								ELSE a.Respondent_IDNO
							 END
					FROM FDEM_Y1  AS a
					WHERE (a.Petitioner_IDNO = @Ln_MemberMciSecondary_IDNO OR a.Respondent_IDNO = @Ln_MemberMciSecondary_IDNO) AND a.Case_IDNO IN
					   (
						  SELECT b.Case_IDNO
						  FROM UCMEM_V1  AS b
						  WHERE b.MemberMci_IDNO = @Ln_MemberMciSecondary_IDNO
					   )		
				END	
		    -- 13599 - CMEM and HCMEM merge is moved to at the end of the Merge. 
      		--- Table Merge Ends-------											
			SET @Ac_Msg_CODE = 	@Lc_StatusSuccess_CODE;
			SET @As_DescriptionError_TEXT = ' ';					
      END TRY
      BEGIN CATCH
		----- Expection for CURSOR
		IF CURSOR_STATUS('VARIABLE','@@Akax_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Akax_CUR;                                 
			DEALLOCATE @Akax_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Mecn_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Mecn_CUR;                                 
			DEALLOCATE @Mecn_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@Demo_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Demo_CUR;                                 
			DEALLOCATE @Demo_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@Mpat_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Mpat_CUR;                                 
			DEALLOCATE @Mpat_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Fadt_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Fadt_CUR;                                 
			DEALLOCATE @Fadt_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Fprj_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Fprj_CUR;                                 
			DEALLOCATE @Fprj_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Usrt_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Usrt_CUR;                                 
			DEALLOCATE @Usrt_CUR;                            
		END
		
	   -- 13588 - Merg Batch Code standard - Start	
       SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
	   SET @Ln_Error_NUMB = ERROR_NUMBER();
	   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

	   IF @Ln_Error_NUMB <> 50001
		BEGIN
		 SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
		END;

	   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
		@As_Procedure_NAME        = @Ls_Procedure_NAME,
		@As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
		@As_Sql_TEXT              = @Ls_Sql_TEXT,
		@As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
		@An_Error_NUMB            = @Ln_Error_NUMB,
		@An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
		@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;			
	   -- 13588 - Merg Batch Code standard - End									   
      END CATCH
   END


GO
