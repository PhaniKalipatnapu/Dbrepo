/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_MEMBER_ENFORCEMENT_MERGE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_MERG$SP_MEMBER_ENFORCEMENT_MERGE
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
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_MEMBER_ENFORCEMENT_MERGE](  
   @An_MemberMciSecondary_IDNO				NUMERIC(10),
   @An_MemberMciPrimary_IDNO				NUMERIC(10),
   @An_Cursor_QNTY							NUMERIC(11),
   @Ad_Run_DATE								DATE,
   @An_TransactionEventSeq_NUMB				NUMERIC(19),
   @Ac_Msg_CODE								VARCHAR(5)  OUTPUT,
   @As_DescriptionError_TEXT				VARCHAR(4000)  OUTPUT
   )
AS 
   BEGIN
      DECLARE
		@Lc_StatusCaseMemberActive_CODE				CHAR(1)			= 'A', 
		@Lc_RecipientTypeCpNcp_CODE					CHAR(1)			= '1', 
		@Lc_StatusFailed_CODE						CHAR(1)			= 'F', 
		@Lc_StatusSuccess_CODE						CHAR(1)			= 'S',
		@Lc_TypeOthpSourceNcp_CODE					CHAR(1)			= 'A',
		@Lc_TypeOthpSourcePf_CODE					CHAR(1)			= 'P',
		@Lc_TypeOthpSourceCp_CODE					CHAR(1)			= 'C',
		@Lc_TypeOthpSourceDep_CODE					CHAR(1)			= 'D',
		@Lc_ActivityMajorCase_CODE					CHAR(4)			= 'CASE', 
		@Lc_ActivityMajorLsnr_CODE					CHAR(4)			= 'LSNR',
		-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Starts
		@Lc_ActivityMajorCpls_CODE					CHAR(4)			= 'CPLS',
		-- 13383 - CR0379 Capias License Suspension on Non-Ordered Cases - Ends
		@Lc_BatchRunUser_TEXT						CHAR(30)		= 'BATCH', 
		@Lc_Package_NAME							CHAR(30)		= 'BATCH_CM_MERG', 
		@Ls_Procedure_NAME							CHAR(30)		= 'SP_MEMBER_ENFORCEMENT_MERGE', 
		@Ld_Low_DATE								DATE			= '01/01/0001', 
		@Ld_High_DATE								DATE			= '12/31/9999'; 
		
	  DECLARE
		@Li_FetchStatus_QNTY						SMALLINT,
		@Ln_Error_NUMB								NUMERIC(11),
		@Ln_ErrorLine_NUMB							NUMERIC(11),
		@Ln_MergeDataExists_QNTY					NUMERIC(11)		= 0, 
		@Ln_DinsValidationDEP_QNTY					NUMERIC(11)		= 0,
		@Ln_IwemValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_AsfnValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_MinsValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_MssnValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_MhisExists_QNTY							NUMERIC(11)		= 0,
		@Ln_HmhisValidation_QNTY					NUMERIC(11)		= 0,
        @Ln_DmnrValidation_QNTY						NUMERIC(11)		= 0, 
        @Ln_HdmnrValidation_QNTY					NUMERIC(11)		= 0,
        @Ln_InStateqwValidation_QNTY				NUMERIC(11)		= 0,
        @Ln_AsreValidation_QNTY						NUMERIC(11)		= 0, 
        @Ln_AsrvValidation_QNTY						NUMERIC(11)		= 0,	
        @Ln_PlicValidation_QNTY						NUMERIC(11)		= 0, 
        @Ln_SwksValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_SlstValidation_QNTY						NUMERIC(11)		= 0,
        @Ln_CncbValidation_QNTY						NUMERIC(11)		= 0,
        @Ln_HswksValidation_QNTY					NUMERIC(11)		= 0,
		@Ln_RcthValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_LsupExists_QNTY							NUMERIC(11)		= 0,
		@Ln_PoflExists_QNTY							NUMERIC(11)		= 0,
		@Ln_EnsdValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_GtstValidation_QNTY						NUMERIC(11)		= 0,
		@Ln_ExistsCmem_NUMB							NUMERIC(11)		= 0,
		@Ln_HcmemValidation_QNTY					NUMERIC(11)		= 0,		
		@Lc_MemberMciPrimary_ID						CHAR(10), 
		@Lc_MemberMciSecondary_ID					CHAR(10),  
		@Ls_Sql_TEXT								VARCHAR(200), 
		@Ls_Sqldata_TEXT							VARCHAR(1000), 
		@Ls_DescriptionError_TEXT					VARCHAR(4000),
		@Lx_XmlData_XML								XML;
	DECLARE
		@Dmjr_CUR									CURSOR,
		@Dmjr_REC$Case_IDNO							NUMERIC(6), 
		@Dmjr_REC$OrderSeq_NUMB						NUMERIC(11), 
		@Dmjr_REC$MajorIntSEQ_NUMB					NUMERIC(11);	
	DECLARE
		@HDmjr_CUR									CURSOR,
		@HDmjr_REC$Case_IDNO						NUMERIC(6), 
		@HDmjr_REC$OrderSeq_NUMB					NUMERIC(11), 
		@HDmjr_REC$MajorIntSEQ_NUMB					NUMERIC(11),
		@Ln_DmjrValidation_QNTY						NUMERIC(11)		= 0,
        @Ln_HDmjrValidation_QNTY					NUMERIC(11)		= 0;
    DECLARE
        @Asfn_CUR									CURSOR,
		@Asfn_REC$AssetSeq_NUMB						NUMERIC(3), 
		@Asfn_REC$TransactionEventSeq_NUMB			NUMERIC(19), 
		@Asfn_REC$SourceLoc_CODE					CHAR(3), 
		@Asfn_REC$Asset_CODE						CHAR(3);
	DECLARE
		@Asre_CUR									CURSOR,
		@Asre_REC$AssetSeq_NUMB						NUMERIC(3), 
		@Asre_REC$TransactionEventSeq_NUMB			NUMERIC(19), 
		@Asre_REC$SourceLoc_CODE					CHAR(3), 
		@Asre_REC$Asset_CODE						CHAR(3);
	DECLARE
		@Asrv_CUR									CURSOR,
		@Asrv_REC$AssetSeq_NUMB						NUMERIC(3), 
		@Asrv_REC$TransactionEventSeq_NUMB			NUMERIC(19), 
		@Asrv_REC$SourceLoc_CODE					CHAR(3), 
		@Asrv_REC$Asset_CODE						CHAR(3);
	DECLARE
		@Swks_CUR									CURSOR,
		@Swks_REC$Case_IDNO							NUMERIC(6),
		@Swks_REC$Schedule_NUMB						NUMERIC(10); 
	DECLARE
		@Hswks_CUR									CURSOR,
		@Hswks_REC$Case_IDNO						NUMERIC(6),
		@Hswks_REC$Schedule_NUMB					NUMERIC(10);
	DECLARE 
		@Cptb_CUR									CURSOR,
		@Cptb_REC$BlockSeq_NUMB						NUMERIC(2),
		@Cptb_REC$TransHeader_IDNO					NUMERIC(12),
		@Cptb_REC$IVDOutOfStateFips_CODE			CHAR(2),
		@Cptb_REC$Transaction_DATE					DATE;
	DECLARE
		@Rcth_CUR									CURSOR,
		@Rcth_REC$Batch_NUMB						NUMERIC(4),          
		@Rcth_REC$SeqReceipt_NUMB					NUMERIC(6),
		@Rcth_REC$SourceBatch_CODE					CHAR(3), 
		@Rcth_REC$Batch_DATE						DATE;
	DECLARE	
		@Pofl_CUR									CURSOR,
		@Pofl_REC$PendTotOffsetSUM_AMNT				NUMERIC(11),
		@Pofl_REC$AssessTotOverpaySUM_AMNT			NUMERIC(11),
		@Pofl_REC$RecTotOverpaySUM_AMNT				NUMERIC(11),
		@Pofl_REC$Unique_IDNO						NUMERIC(19);
	DECLARE
		@Ensd_CUR									CURSOR,
		@Ensd_REC$Case_IDNO							NUMERIC(6);
	DECLARE
		@Gtst_CUR									CURSOR,
		@Gtst_REC$Case_IDNO							NUMERIC(6),
		@Gtst_REC$Schedule_NUMB						NUMERIC(10);
	DECLARE
		@Hcmem_CUR									CURSOR,
		@Hcmem_REC$Case_IDNO						NUMERIC(6);
		
      BEGIN TRY		
		
		SET @Lc_MemberMciPrimary_ID = CAST (@An_MemberMciPrimary_IDNO AS CHAR);
		SET @Lc_MemberMciSecondary_ID = CAST (@An_MemberMciSecondary_IDNO AS CHAR);  
		------------------------------------------------------------------------------------------------
		-- DINS_Y1 - DependantInsurance_T1 - For ChildMCI_IDNO
		------------------------------------------------------------------------------------------------
			SET @Ls_Sql_TEXT = 'DINS_Y1 MMERG UPDATION';
			SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' + @Lc_MemberMciPrimary_ID + ' MemberMciSecondary_IDNO: ' + @Lc_MemberMciSecondary_ID;	
			SET @Ls_Sql_TEXT = ' SELECT DINS_Y1 ';
			
			SELECT @Ln_DinsValidationDEP_QNTY = COUNT(1)
                    FROM DINS_Y1  AS a
                 WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					  OR a.ChildMCI_IDNO = @An_MemberMciSecondary_IDNO);
					  
			IF @Ln_DinsValidationDEP_QNTY > 0
                  BEGIN
						SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 
																				  FROM DINS_Y1 b 
																				WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
																				  AND b.OthpInsurance_IDNO = a.OthpInsurance_IDNO 
																				  AND b.InsuranceGroupNo_TEXT = a.InsuranceGroupNo_TEXT
																				  AND b.PolicyInsNo_TEXT = a.PolicyInsNo_TEXT 
																				  AND b.ChildMCI_IDNO = a.ChildMCI_IDNO
																				  AND b.Begin_DATE = a.Begin_DATE
																				  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
												THEN 'D'
												ELSE 'U'
											END merge_status
								FROM DINS_Y1 a
							 WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
								 OR a.ChildMCI_IDNO = @An_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
						
						  SELECT @Ln_DinsValidationDEP_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
													FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);	
													
						  SET @Ls_Sql_TEXT = ' INSERT INTO MEGR_Y1 - DINS_Y1';

						  INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
						    VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'DINS_Y1', 
								 @Ln_DinsValidationDEP_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE);		
								 
						SET @Lx_XmlData_XML = NULL;
						
						SET @Ls_Sql_TEXT = ' DELETE FROM DINS_Y1';
						
						DELETE DINS_Y1
						 FROM DINS_Y1  AS a
						 WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
								OR a.ChildMCI_IDNO = @An_MemberMciSecondary_IDNO)
						   AND EXISTS (SELECT 1
										 FROM DINS_Y1  AS b
										WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
										  AND b.OthpInsurance_IDNO = a.OthpInsurance_IDNO
										  AND b.InsuranceGroupNo_TEXT = a.InsuranceGroupNo_TEXT
										  AND b.PolicyInsNo_TEXT = a.PolicyInsNo_TEXT
										  AND b.ChildMCI_IDNO = a.ChildMCI_IDNO
										  AND b.Begin_DATE = a.Begin_DATE 
										  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);
						
						---Logical update to end duplicate rows---			 
						SET @Ls_Sql_TEXT = 'UPDATE DINS_Y1 1';
						
						UPDATE DINS_Y1
							SET EndValidity_DATE = @Ad_Run_DATE
						 FROM DINS_Y1  AS a
						 WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
								OR a.ChildMCI_IDNO = @An_MemberMciSecondary_IDNO)  
						   AND	a.EndValidity_DATE = @Ld_High_DATE 
						   AND EXISTS (SELECT 1
										FROM DINS_Y1  AS b
									   WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
										 AND b.OthpInsurance_IDNO = a.OthpInsurance_IDNO
										 AND b.InsuranceGroupNo_TEXT = a.InsuranceGroupNo_TEXT
										 AND b.PolicyInsNo_TEXT = a.PolicyInsNo_TEXT
										 AND b.ChildMCI_IDNO = a.ChildMCI_IDNO
										 AND b.Begin_DATE = a.Begin_DATE
										 AND b.EndValidity_DATE = @Ld_High_DATE);
										  
						SET @Ls_Sql_TEXT = 'UPDATE DINS_Y1 2';
						
						UPDATE DINS_Y1
							SET MemberMci_IDNO =  CASE 
											 WHEN a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
											 ELSE a.MemberMci_IDNO
										  END, 
									   ChildMCI_IDNO = 
										  CASE 
											 WHEN a.ChildMCI_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
											 ELSE a.ChildMCI_IDNO
										  END
								 FROM DINS_Y1  AS a
								 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
									OR a.ChildMCI_IDNO = @An_MemberMciPrimary_IDNO;								
					END				
				
				
			------------------------------------------------------------------------------------------------
		-- EHIS -- EMPLOYMENT_DETAILS
		------------------------------------------------------------------------------------------------	
			SET @Ln_MergeDataExists_QNTY = 0;
			SET @Ls_Sql_TEXT = 'EHIS_Y1 MMERG UPDATION';	
			
			SELECT @Ln_MergeDataExists_QNTY = COUNT(1)
					FROM EHIS_Y1
					WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;		
			
			IF @Ln_MergeDataExists_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT s.*, CASE WHEN EXISTS (SELECT 1 
																			  FROM EHIS_Y1 p
 																			 WHERE p.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
 																			   AND p.OthpPartyEmpl_IDNO = s.OthpPartyEmpl_IDNO                     
 																			   AND p.BeginEmployment_DATE = s.BeginEmployment_DATE)               
 													  THEN 'D' 
 													  ELSE 'U'          
 														 END merge_status   
 												FROM EHIS_Y1 s  
											 WHERE s.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_MergeDataExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
										FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
					
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - EHIS_Y1';
					
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					  VALUES (
						 @An_MemberMciPrimary_IDNO, 
						 @An_MemberMciSecondary_IDNO, 
						 'EHIS_Y1', 
						 @Ln_MergeDataExists_QNTY, 
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
						 @An_TransactionEventSeq_NUMB, 
						 @Ad_Run_DATE);
						 
					SET @Lx_XmlData_XML = NULL;						 
						 
					SET @Ls_Sql_TEXT = 'DELETE EHIS_Y1';
					
					DELETE s
					  FROM EHIS_Y1 s
					 WHERE s.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					   AND EXISTS ( SELECT 1
									  FROM EHIS_Y1 p
									 WHERE p.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
									   AND p.OthpPartyEmpl_IDNO = s.OthpPartyEmpl_IDNO
									   AND p.BeginEmployment_DATE = s.BeginEmployment_DATE);
								   
					SET @Ls_Sql_TEXT = 'UPDATE EHIS_Y1';
					
					UPDATE EHIS_Y1
                     SET  MemberMci_IDNO = @An_MemberMciPrimary_IDNO, 
						  EmployerPrime_INDC = 'N'
					WHERE EHIS_Y1.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;					
				END	
		------------------------------------------------------------------------------------------------
		-- HEHIS -- EMPLOYMENT_DETAILS_HIST
		------------------------------------------------------------------------------------------------
			SET @Ln_MergeDataExists_QNTY = 0;
			SET @Ls_Sql_TEXT = 'HEHIS_Y1 MMERG UPDATION';
			
			SELECT @Ln_MergeDataExists_QNTY = COUNT(1)
				FROM HEHIS_Y1
				WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
				
			IF (@Ln_MergeDataExists_QNTY > 0)
               BEGIN
					SELECT @Lx_XmlData_XML = (SELECT s.*, CASE WHEN EXISTS (SELECT 1 
																			  FROM HEHIS_Y1 p 
																			WHERE p.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																			  AND p.OthpPartyEmpl_IDNO = s.OthpPartyEmpl_IDNO                     
																			  AND p.BeginEmployment_DATE = s.BeginEmployment_DATE                       
																			  AND p.TransactionEventSeq_NUMB = s.TransactionEventSeq_NUMB)              
								  THEN 'D'           
								  ELSE 'U'           
							   END merge_status   
								   FROM HEHIS_Y1 s  
								 WHERE s.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_MergeDataExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
										FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
										
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HEHIS_Y1';
					
					INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
						  VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'HEHIS_Y1', 
							 @Ln_MergeDataExists_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);
							 
					SET @Lx_XmlData_XML = NULL;							 
							 
					SET @Ls_Sql_TEXT = 'DELETE HEHIS_Y1';
					
					DELETE s
					  FROM HEHIS_Y1 s
					 WHERE s.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					   AND EXISTS ( SELECT 1 
									  FROM HEHIS_Y1 p
									 WHERE p.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
									   AND p.OthpPartyEmpl_IDNO = s.OthpPartyEmpl_IDNO 
									   AND p.BeginEmployment_DATE = s.BeginEmployment_DATE
									   AND p.TransactionEventSeq_NUMB = s.TransactionEventSeq_NUMB);
							   
					SET @Ls_Sql_TEXT = 'UPDATE HEHIS_Y1';
					UPDATE HEHIS_Y1
					  SET  MemberMci_IDNO = @An_MemberMciPrimary_IDNO
					WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
               END		
      	------------------------------------------------------------------------------------------------
		--  EnforcementLocateInterface_T1
		------------------------------------------------------------------------------------------------
			-- 13693 - Inserting Null XML for ELFC Table is fixed - Start
			SET @Ls_Sql_TEXT = 'ELFC_Y1 MMERG UPDATION';	
	
			SELECT @Ln_MergeDataExists_QNTY = COUNT(1)
			   FROM ELFC_Y1  AS a
			 WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					OR a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO 
					OR a.Reference_ID = @Lc_MemberMciSecondary_ID) 
				AND a.Case_IDNO IN ( SELECT b.Case_IDNO
									   FROM UCMEM_V1  AS b
									   WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
			
			IF @Ln_MergeDataExists_QNTY > 0
			BEGIN
				
					SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status    
						FROM ELFC_Y1 a   
					  WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							OR a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO 
							OR a.Reference_ID = @Lc_MemberMciSecondary_ID) 
						AND a.Case_IDNO IN (  SELECT b.Case_IDNO
												FROM UCMEM_V1  AS b
											   WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) FOR XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_MergeDataExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
										FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);  
										
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - ELFC_Y1';
					
					INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
						  VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'ELFC_Y1', 
							 @Ln_MergeDataExists_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	
							 
					SET @Lx_XmlData_XML = NULL;							 	
							 
					SET @Ls_Sql_TEXT = 'UPDATE ELFC_Y1';			
					
					UPDATE a
                        SET MemberMci_IDNO = 
                              CASE 
                                 WHEN a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
                                 ELSE a.MemberMci_IDNO
                              END, 
                           OthpSource_IDNO = 
                              CASE 
                                 WHEN a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
                                 ELSE a.OthpSource_IDNO
                              END, 
                           Reference_ID = 
                              CASE 
                                 WHEN a.Reference_ID = @Lc_MemberMciSecondary_ID THEN @Lc_MemberMciPrimary_ID
                                 ELSE a.Reference_ID
                              END
						 FROM ELFC_Y1 a
						 WHERE (a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
								OR a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO 
								OR a.Reference_ID = @Lc_MemberMciSecondary_ID) 
						    AND a.Case_IDNO IN ( SELECT b.Case_IDNO
													FROM UCMEM_V1  AS b
													WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
				END
				-- 13693 - Inserting Null XML for ELFC Table is fixed - End
			
		------------------------------------------------------------------------------------------------
		--  IwEmployers_T1 
		------------------------------------------------------------------------------------------------			
			 SET @Ls_Sql_TEXT = 'SELECT IWEM_Y1';	
			 
			SELECT @Ln_IwemValidation_QNTY = COUNT(1)
                   FROM IWEM_Y1  AS a
                   WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					 AND a.Case_IDNO IN (SELECT b.Case_IDNO
										   FROM UCMEM_V1 AS b
										  WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
			 
			 IF @Ln_IwemValidation_QNTY > 0
                  BEGIN
						SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status  FROM IWEM_Y1 a   
														WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
	 													  AND a.Case_IDNO IN (SELECT b.Case_IDNO  
	 																			FROM UCMEM_V1 b 
	 																			WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
																			
						SELECT @Ln_IwemValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
										FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);

					 SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - IWEM_Y1';

					 INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'IWEM_Y1', 
							 @Ln_IwemValidation_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	
							 
					 SET @Lx_XmlData_XML = NULL;
                 
					 SET @Ls_Sql_TEXT = 'UPDATE IWEM_Y1';

					 UPDATE IWEM_Y1
                        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                      FROM IWEM_Y1  AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						AND a.Case_IDNO IN ( SELECT b.Case_IDNO
											   FROM UCMEM_V1  AS b
											   WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
                        
				  END	
		------------------------------------------------------------------------------------------------
		--  MajorActivityDiary_T1 
		------------------------------------------------------------------------------------------------			
			SET @Ls_Sql_TEXT = 'DMJR_Y1 MMERG UPDATION';
			-- 13599 - Correct MemberMci Source alone replaced in Othp Source ID Column - Start 
			-- Defining the cursor @Dmjr_CUR
			SET @Dmjr_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT a.Case_IDNO, a.OrderSeq_NUMB, a.MajorIntSEQ_NUMB
                     FROM DMJR_Y1  AS a
                     WHERE a.Case_IDNO IN 
                        (SELECT b.Case_IDNO
                           FROM UCMEM_V1  AS b
                           WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) 
                            AND ( a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
								OR ( a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO 
									 AND a.TypeOthpSource_CODE IN (@Lc_TypeOthpSourceNcp_CODE,@Lc_TypeOthpSourcePf_CODE,@Lc_TypeOthpSourceCp_CODE,@Lc_TypeOthpSourceDep_CODE)
									 AND a.ActivityMajor_CODE NOT IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE))
								OR ( ISNUMERIC(a.Reference_ID) = 1
									 AND a.Reference_ID = @Lc_MemberMciSecondary_ID));

			SET @Ls_Sql_TEXT = 'OPEN @Dmjr_CUR';
			
			OPEN @Dmjr_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Dmjr_CUR - 1';	

			FETCH NEXT FROM @Dmjr_CUR INTO @Dmjr_REC$Case_IDNO, @Dmjr_REC$OrderSeq_NUMB, @Dmjr_REC$MajorIntSEQ_NUMB;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;								  
			
			-- cursor loop1 Starts @Dmjr_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN 
					SELECT @Lx_XmlData_XML = ( SELECT a.*, 'U' merge_status    
						FROM DMJR_Y1 a   
					 WHERE Case_IDNO = @Dmjr_REC$Case_IDNO    
					   AND OrderSeq_NUMB = @Dmjr_REC$OrderSeq_NUMB 
					   AND MajorIntSEQ_NUMB = @Dmjr_REC$MajorIntSEQ_NUMB For XML PATH('ROWS'),TYPE);
																			
					SELECT @Ln_DmjrValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
										FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);    
										
					SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - DMJR_Y1';
										
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'DMJR_Y1', 
							 @Ln_DmjrValidation_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	 
							 
					SET @Lx_XmlData_XML = NULL;							                     
					
					SET @Ls_Sql_TEXT = 'UPDATE DMJR_Y1';
					
					UPDATE DMJR_Y1
                        SET 
                           MemberMci_IDNO = 
                              CASE 
                                 WHEN a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                                 THEN @An_MemberMciPrimary_IDNO
                                 ELSE a.MemberMci_IDNO
                              END, 
                           OthpSource_IDNO = 
                              CASE 
                                 WHEN a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO
									  AND a.TypeOthpSource_CODE IN (@Lc_TypeOthpSourceNcp_CODE,@Lc_TypeOthpSourcePf_CODE,@Lc_TypeOthpSourceCp_CODE,@Lc_TypeOthpSourceDep_CODE)
									  AND a.ActivityMajor_CODE NOT IN (@Lc_ActivityMajorLsnr_CODE,@Lc_ActivityMajorCpls_CODE)
                                 THEN @An_MemberMciPrimary_IDNO
                                 ELSE a.OthpSource_IDNO
                              END, 
                           Reference_ID = 
                              CASE 
                                 WHEN ISNUMERIC(a.Reference_ID) = 1 
									  AND a.Reference_ID = @Lc_MemberMciSecondary_ID 
								 THEN @Lc_MemberMciPrimary_ID
                                 ELSE a.Reference_ID
                              END
                     FROM DMJR_Y1  AS a
                     WHERE a.Case_IDNO = @Dmjr_REC$Case_IDNO 
                       AND a.OrderSeq_NUMB = @Dmjr_REC$OrderSeq_NUMB
                       AND a.MajorIntSEQ_NUMB = @Dmjr_REC$MajorIntSEQ_NUMB;				
			
					FETCH NEXT FROM @Dmjr_CUR INTO @Dmjr_REC$Case_IDNO, @Dmjr_REC$OrderSeq_NUMB, @Dmjr_REC$MajorIntSEQ_NUMB;
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;								  						
					-- End of loop @Dmjr_CUR
				END
			CLOSE @Dmjr_CUR;
			DEALLOCATE @Dmjr_CUR;
			-- 13599 - Correct MemberMci Source alone replaced in Othp Source ID Column - End
			 -- cursor loop Ends @Dmjr_CUR	
		------------------------------------------------------------------------------------------------
		--  MajorActivityDiaryHist_T1 
		------------------------------------------------------------------------------------------------			
			SET @Ls_Sql_TEXT = 'HDMJR_Y1 MMERG UPDATION';
			 
			-- Defining the cursor @HDmjr_CUR
			SET @HDmjr_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT a.Case_IDNO, a.OrderSeq_NUMB, a.MajorIntSEQ_NUMB
                     FROM HDMJR_Y1  AS a
                     WHERE a.Case_IDNO IN 
                        (SELECT b.Case_IDNO
                           FROM UCMEM_V1  AS b
                           WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) 
                            AND ( a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
								  OR a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO 
								  OR a.Reference_ID = @Lc_MemberMciSecondary_ID);

			SET @Ls_Sql_TEXT = 'OPEN @HDmjr_CUR';
			
			OPEN @HDmjr_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @HDmjr_CUR - 1';	

			FETCH NEXT FROM @HDmjr_CUR INTO @HDmjr_REC$Case_IDNO, @HDmjr_REC$OrderSeq_NUMB, @HDmjr_REC$MajorIntSEQ_NUMB;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;								  
			
			-- cursor loop1 Starts @HDmjr_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN 
					SELECT @Lx_XmlData_XML = ( SELECT a.*, 'U' merge_status    
						FROM HDMJR_Y1 a   
					 WHERE Case_IDNO = @HDmjr_REC$Case_IDNO    
					   AND OrderSeq_NUMB = @HDmjr_REC$OrderSeq_NUMB 
					   AND MajorIntSEQ_NUMB = @HDmjr_REC$MajorIntSEQ_NUMB For XML PATH('ROWS'),TYPE);
																			
					SELECT @Ln_HDmjrValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
										FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);    
										
					SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - HDMJR_Y1';
										
					INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'HDMJR_Y1', 
							 @Ln_HDmjrValidation_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	                     
					
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'UPDATE HDMJR_Y1';
					
					UPDATE HDMJR_Y1
                        SET 
                           MemberMci_IDNO = 
                              CASE 
                                 WHEN a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
                                 ELSE a.MemberMci_IDNO
                              END, 
                           OthpSource_IDNO = 
                              CASE 
                                 WHEN a.OthpSource_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
                                 ELSE a.OthpSource_IDNO
                              END, 
                           Reference_ID = 
                              CASE 
                                 WHEN a.Reference_ID = @Lc_MemberMciSecondary_ID THEN @Lc_MemberMciPrimary_ID
                                 ELSE a.Reference_ID
                              END
                     FROM HDMJR_Y1  AS a
                     WHERE a.Case_IDNO = @HDmjr_REC$Case_IDNO 
                       AND a.OrderSeq_NUMB = @HDmjr_REC$OrderSeq_NUMB 
                       AND a.MajorIntSEQ_NUMB = @HDmjr_REC$MajorIntSEQ_NUMB;				
			
					FETCH NEXT FROM @HDmjr_CUR INTO @HDmjr_REC$Case_IDNO, @HDmjr_REC$OrderSeq_NUMB, @HDmjr_REC$MajorIntSEQ_NUMB;
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;								  						
					-- End of loop @HDmjr_CUR
				END
			CLOSE @HDmjr_CUR;
			DEALLOCATE @HDmjr_CUR;
			 -- cursor loop Ends @HDmjr_CUR
		------------------------------------------------------------------------------------------------
		-- ASFN_Y1  -- MemberFinAssets_T1
		------------------------------------------------------------------------------------------------
			SET @Ls_Sql_TEXT = 'ASFN_Y1 MMERG UPDATION';
							  
			SET @Ls_Sql_TEXT = '@Asfn_CUR CURSOR';
			-- Defining the cursor @Asfn_CUR
			SET @Asfn_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT  TransactionEventSeq_NUMB, 
							SourceLoc_CODE, 
							AssetSeq_NUMB, 
							Asset_CODE
                     FROM ASFN_Y1
                     WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO; 
                     
			SET @Ls_Sql_TEXT = 'OPEN @Asfn_CUR';

			OPEN @Asfn_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Asfn_CUR - 1';	

			FETCH NEXT FROM @Asfn_CUR INTO @Asfn_REC$TransactionEventSeq_NUMB, @Asfn_REC$SourceLoc_CODE, @Asfn_REC$AssetSeq_NUMB, @Asfn_REC$Asset_CODE 

			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;        
			
			-- Cursor loop Starts @Asfn_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
						SELECT @Lx_XmlData_XML = (SELECT a.*, CASE  WHEN a.EndValidity_DATE <> @Ld_High_DATE 
												AND EXISTS (SELECT 1 FROM ASFN_Y1 b 
																WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
																  AND b.Asset_CODE  = a.Asset_CODE 
																  AND b.AssetSeq_NUMB = a.AssetSeq_NUMB
																  AND b.SourceLoc_CODE = a.SourceLoc_CODE
																  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
												THEN 'D'
												ELSE 'U' 
											END merge_status
								FROM ASFN_Y1 a
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
							   AND a.Asset_CODE = @Asfn_REC$Asset_CODE
							   AND a.AssetSeq_NUMB = @Asfn_REC$AssetSeq_NUMB   
							   AND a.SourceLoc_CODE = @Asfn_REC$SourceLoc_CODE  
							   AND a.TransactionEventSeq_NUMB = @Asfn_REC$TransactionEventSeq_NUMB for XML PATH('ROWS'),TYPE);
						
						SELECT @Ln_AsfnValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
													FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
													
						SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - ASFN_Y1';

						INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'ASFN_Y1', 
							 @Ln_AsfnValidation_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	
							 
						 SET @Lx_XmlData_XML = NULL;
						 
						 SET @Ls_Sql_TEXT = 'UPDATE ASFN_Y1 1';
						 
						 UPDATE ASFN_Y1
							SET AssetSeq_NUMB = ISNULL(
								  (
									 SELECT MAX(b.AssetSeq_NUMB) + 1
									 FROM ASFN_Y1  AS b
									 WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO AND b.EndValidity_DATE = @Ld_High_DATE
								  ), 1), 
							   MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						 FROM ASFN_Y1  AS a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						   AND a.Asset_CODE = @Asfn_REC$Asset_CODE
						   AND a.AssetSeq_NUMB = @Asfn_REC$AssetSeq_NUMB
						   AND a.SourceLoc_CODE = @Asfn_REC$SourceLoc_CODE
						   AND a.TransactionEventSeq_NUMB = @Asfn_REC$TransactionEventSeq_NUMB
						   AND a.EndValidity_DATE = @Ld_High_DATE;

					SET @Ls_Sql_TEXT = ' DELETE ASFN_Y1';
					
					DELETE ASFN_Y1
					  FROM ASFN_Y1  AS a
					 WHERE  a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO  
						AND	a.Asset_CODE = @Asfn_REC$Asset_CODE
						AND	a.AssetSeq_NUMB = @Asfn_REC$AssetSeq_NUMB
						AND	a.SourceLoc_CODE = @Asfn_REC$SourceLoc_CODE
						AND	a.TransactionEventSeq_NUMB = @Asfn_REC$TransactionEventSeq_NUMB
						AND	a.EndValidity_DATE <> @Ld_High_DATE
						AND	EXISTS ( SELECT 1
									   FROM ASFN_Y1  AS b
									  WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
										AND b.Asset_CODE = a.Asset_CODE 
										AND b.AssetSeq_NUMB = a.AssetSeq_NUMB
										AND b.SourceLoc_CODE = a.SourceLoc_CODE
										AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB )
					
					SET @Ls_Sql_TEXT = 'UPDATE ASFN_Y1 2';		 
					
					 UPDATE ASFN_Y1
							SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						 FROM ASFN_Y1  AS a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						   AND a.Asset_CODE = @Asfn_REC$Asset_CODE 
						   AND a.AssetSeq_NUMB = @Asfn_REC$AssetSeq_NUMB
						   AND a.SourceLoc_CODE = @Asfn_REC$SourceLoc_CODE
						   AND a.TransactionEventSeq_NUMB = @Asfn_REC$TransactionEventSeq_NUMB;	
							
					FETCH NEXT FROM @Asfn_CUR INTO @Asfn_REC$TransactionEventSeq_NUMB, @Asfn_REC$SourceLoc_CODE, @Asfn_REC$AssetSeq_NUMB, @Asfn_REC$Asset_CODE 

					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS; 					
				END
				
			CLOSE @Asfn_CUR;
			DEALLOCATE @Asfn_CUR;
		------------------------------------------------------------------------------------------------
		-- MINS_Y1 - MemberInsurance_T1
		------------------------------------------------------------------------------------------------						
			SET @Ls_Sql_TEXT = 'MINS_Y1 MMERG UPDATION';	
							  
			SET @Ls_Sql_TEXT = ' SELECT MINS_Y1 ';
			
			SELECT @Ln_MinsValidation_QNTY = COUNT(1)
                           FROM MINS_Y1  AS a
                           WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
                  
			 IF @Ln_MinsValidation_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE  WHEN EXISTS (SELECT 1 
																				FROM MINS_Y1 b 
																				WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
																				  AND b.OthpInsurance_IDNO = a.OthpInsurance_IDNO
																				  AND b.InsuranceGroupNo_TEXT = a.InsuranceGroupNo_TEXT
																				  AND b.PolicyInsNo_TEXT = a.PolicyInsNo_TEXT
																				  AND b.Begin_DATE = a.Begin_DATE
																				  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
																 THEN 'D'
																 ELSE 'U'
														 END merge_status
												FROM MINS_Y1 a WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
						SELECT @Ln_MinsValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
													FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
													
						SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - MINS_Y1';

						INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						  VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'MINS_Y1', 
							 @Ln_MinsValidation_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE);	
							 
						 SET @Lx_XmlData_XML = NULL;
						 
						 SET @Ls_Sql_TEXT = 'DELETE FROM MINS_Y1';
						 
						 DELETE MINS_Y1
							 FROM MINS_Y1  AS a
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND EXISTS ( SELECT 1
												FROM MINS_Y1  AS b
											   WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
												 AND b.OthpInsurance_IDNO = a.OthpInsurance_IDNO
												 AND b.InsuranceGroupNo_TEXT = a.InsuranceGroupNo_TEXT
												 AND b.PolicyInsNo_TEXT = a.PolicyInsNo_TEXT
												 AND b.Begin_DATE = a.Begin_DATE
												 AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);
									  
						--update vmins to end duplicate rows--
						SET @Ls_Sql_TEXT = ' UPDATE MINS_Y1 1';
						
						UPDATE MINS_Y1
							SET EndValidity_DATE = @Ad_Run_DATE
						 FROM MINS_Y1  AS a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						   AND a.EndValidity_DATE = @Ld_High_DATE
						   AND EXISTS ( SELECT 1
										 FROM MINS_Y1  AS b
									   WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
										 AND b.OthpInsurance_IDNO = a.OthpInsurance_IDNO
										 AND b.InsuranceGroupNo_TEXT = a.InsuranceGroupNo_TEXT
										 AND b.PolicyInsNo_TEXT = a.PolicyInsNo_TEXT
										 AND b.Begin_DATE = a.Begin_DATE
										 AND b.EndValidity_DATE = @Ld_High_DATE);
					
					SET @Ls_Sql_TEXT = 'UPDATE MINS_Y1 2';
					
					UPDATE MINS_Y1
                        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                     FROM MINS_Y1  AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;						
				END			 
			------------------------------------------------------------------------------------------------
		-- MemberSsn_T1
		------------------------------------------------------------------------------------------------					
			SET @Ls_Sql_TEXT = 'SELECT DINS_Y1';
			
			SELECT @Ln_MssnValidation_QNTY = COUNT(1)
               FROM MSSN_Y1
               WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
               
             IF @Ln_MssnValidation_QNTY > 0
                  BEGIN
						 SELECT @Lx_XmlData_XML = (SELECT a.*, CASE  WHEN EXISTS (SELECT 1 FROM MSSN_Y1 b 
																WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																  AND b.MemberSsn_NUMB  = a.MemberSsn_NUMB
																  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB) 
																		THEN 'D'
																		ELSE 'U'
																	END merge_status
														FROM MSSN_Y1 a
													 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
						  SELECT @Ln_MssnValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
													FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
													
						SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - MSSN_Y1';
						
						INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
						    VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'MSSN_Y1', 
								 @Ln_MssnValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE);		
								 
						SET @Lx_XmlData_XML = NULL;
						
						SET @Ls_Sql_TEXT = 'DELETE FROM MSSN_Y1';
						
						DELETE MSSN_Y1
							 FROM MSSN_Y1  AS a
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND EXISTS (SELECT 1
										   FROM MSSN_Y1  AS b
										   WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
											 AND b.MemberSsn_NUMB = a.MemberSsn_NUMB
											 AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);
									  
						SET @Ls_Sql_TEXT = 'UPDATE MSSN_Y1 1';
						
						UPDATE MSSN_Y1
								SET EndValidity_DATE = @Ad_Run_DATE
							 FROM MSSN_Y1  AS s
							 WHERE s.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND s.EndValidity_DATE = @Ld_High_DATE 
							   AND EXISTS ( SELECT 1
											   FROM MSSN_Y1  AS p
											   WHERE p.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
												 AND s.MemberSsn_NUMB = p.MemberSsn_NUMB 
												 AND s.Enumeration_CODE = p.Enumeration_CODE
												 AND p.EndValidity_DATE = @Ld_High_DATE);
												  
						SET @Ls_Sql_TEXT = 'UPDATE MSSN_Y1 2';	
						
						UPDATE MSSN_Y1
							SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						 WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;							
                  END
		------------------------------------------------------------------------------------------------
		-- MemberWelfareDetails_T1
		------------------------------------------------------------------------------------------------                  
			SET @Ls_Sql_TEXT = 'SELECT MHIS_Y1';	
			
			SELECT @Ln_MhisExists_QNTY = COUNT(1)
               FROM MHIS_Y1  AS a
               WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;		
               
			IF @Ln_MhisExists_QNTY > 0
				BEGIN            			
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE  WHEN EXISTS (SELECT 1 FROM MHIS_Y1 b 
														WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
														  AND b.Case_IDNO = a.Case_IDNO)
										   THEN 'D' 
										   ELSE 'U' 
									 END merge_status 
							FROM MHIS_Y1 a 
						 WHERE a.MemberMci_IDNO  = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
					  SELECT @Ln_MhisExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
												FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
												
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - MHIS_Y1';
					INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
						    VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'MHIS_Y1', 
								 @Ln_MhisExists_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE);
								 
					 SET @Lx_XmlData_XML = NULL;
					 
					 SET @Ls_Sql_TEXT = ' DELETE MHIS_Y1';
					 
					 DELETE MHIS_Y1
                     FROM MHIS_Y1  AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                       AND EXISTS ( SELECT 1
									  FROM MHIS_Y1  AS b
									 WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
									   AND a.Case_IDNO = b.Case_IDNO);

                     SET @Ls_Sql_TEXT = ' UPDATE MHIS_Y1';

                     UPDATE MHIS_Y1
                        SET  MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                      WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
				END
				
		------------------------------------------------------------------------------------------------
		-- MemberWelfareDetailsHist_T1
		------------------------------------------------------------------------------------------------                  
			SET @Ls_Sql_TEXT = 'SELECT HMHIS_Y1';	
			
			SELECT @Ln_HmhisValidation_QNTY = COUNT(1)
                           FROM HMHIS_Y1  AS a
                           WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                             AND a.Case_IDNO IN ( SELECT b.Case_IDNO
													 FROM UCMEM_V1  AS b
													 WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);	
               
			IF @Ln_HmhisValidation_QNTY > 0
				BEGIN            			
					SELECT @Lx_XmlData_XML = ( SELECT a.*,  CASE WHEN  EXISTS (SELECT 1 FROM HMHIS_Y1 c
																					WHERE c.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																					  AND a.Case_IDNO = c.Case_IDNO 
																					  AND a.Start_DATE = c.Start_DATE 
																					  AND a.EventGlobalBeginSeq_NUMB = c.EventGlobalBeginSeq_NUMB)
																	THEN 'D'
																	ELSE 'U'
																END merge_status
													FROM HMHIS_Y1 a 
												 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
												   AND a.Case_IDNO IN (SELECT b.Case_IDNO 
																		 FROM UCMEM_V1 b
																		WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) FOR XML PATH('ROWS'),TYPE);
						
					  SELECT @Ln_HmhisValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
												
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HMHIS_Y1';
					INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
						    VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'HMHIS_Y1', 
								 @Ln_HmhisValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE);
								 
					 SET @Lx_XmlData_XML = NULL;
					 
					 SET @Ls_Sql_TEXT = ' DELETE HMHIS_Y1';
					 
					 DELETE HMHIS_Y1
						 FROM HMHIS_Y1  AS a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						   AND a.Case_IDNO IN ( SELECT b.Case_IDNO
												  FROM UCMEM_V1  AS b
												 WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) 
						   AND EXISTS ( SELECT 1
										  FROM HMHIS_Y1  AS c
										 WHERE c.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
										   AND a.Case_IDNO = c.Case_IDNO 
										   AND a.Start_DATE = c.Start_DATE 
										   AND a.EventGlobalBeginSeq_NUMB = c.EventGlobalBeginSeq_NUMB);

                     SET @Ls_Sql_TEXT = ' UPDATE HMHIS_Y1';

                     UPDATE HMHIS_Y1
							SET 
							   MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						 FROM HMHIS_Y1  AS a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						   AND a.Case_IDNO IN ( SELECT b.Case_IDNO
												  FROM UCMEM_V1  AS b
												 WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
				END		
		------------------------------------------------------------------------------------------------
		-- MinorActivityDiary_T1
		------------------------------------------------------------------------------------------------		
			SET @Ls_Sql_TEXT = 'SELECT DMNR_Y1';
			
			SELECT @Ln_DmnrValidation_QNTY = COUNT(1)
                   FROM DMNR_Y1  AS a
                   WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                     AND a.Case_IDNO IN ( SELECT b.Case_IDNO
											FROM UCMEM_V1  AS b
										   WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);

			IF @Ln_DmnrValidation_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = ( SELECT a.*, 'U' merge_status   
												 FROM DMNR_Y1 a  
												WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO   
												  AND a.Case_IDNO IN (SELECT b.Case_IDNO 
																		FROM UCMEM_V1 b 
																	   WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) FOR XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_DmnrValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																			  FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);   
																
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - DMNR_Y1';
					INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
						    VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'DMNR_Y1', 
								 @Ln_DmnrValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE);
								 
					 SET @Lx_XmlData_XML = NULL;
					 
					 SET @Ls_Sql_TEXT = ' UPDATE DMNR_Y1';
					 
					 UPDATE DMNR_Y1
							SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						 FROM DMNR_Y1  AS a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						   AND a.Case_IDNO IN ( SELECT b.Case_IDNO
												  FROM UCMEM_V1 AS b
												 WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
				END
		------------------------------------------------------------------------------------------------
		-- MinorActivityDiaryHist_T1
		------------------------------------------------------------------------------------------------
			 SET @Ls_Sql_TEXT = 'SELECT HDMNR_Y1';
			
			SELECT @Ln_HdmnrValidation_QNTY = COUNT(1)
              FROM HDMNR_Y1  AS a
             WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
			   AND a.Case_IDNO IN (SELECT b.Case_IDNO
									FROM UCMEM_V1  AS b
									WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
                                 
			IF @Ln_HdmnrValidation_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status 
							FROM HDMNR_Y1 a  
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
						   AND a.Case_IDNO IN (SELECT b.Case_IDNO  FROM UCMEM_V1 b 
													WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_DmnrValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																
					SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - HDMNR_Y1';
					
					INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
						    VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'HDMNR_Y1', 
								 @Ln_DmnrValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE);
								 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'UPDATE HDMNR_Y1';
					
					UPDATE HDMNR_Y1
                        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                     FROM HDMNR_Y1  AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                       AND a.Case_IDNO IN ( SELECT b.Case_IDNO
											  FROM UCMEM_V1  AS b
											WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);
				END
		------------------------------------------------------------------------------------------------
		-- EmployerQuarterlyWage_T1
		------------------------------------------------------------------------------------------------
			SET @Ls_Sql_TEXT = 'EMQW_Y1 MMERG UPDATION';			
			SET @Ls_Sql_TEXT = ' SELECT EMQW_Y1';
			
			SELECT @Ln_InStateqwValidation_QNTY = COUNT(1)
				FROM EMQW_Y1  AS a
			 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
			 
			IF @Ln_InStateqwValidation_QNTY > 0
				BEGIN		
					SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status    FROM EMQW_Y1 a
												WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_InStateqwValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																
					SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - EMQW_Y1';
					
					INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
						    VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'EMQW_Y1', 
								 @Ln_InStateqwValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE);
								 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'UPDATE EMQW_Y1';
					
					UPDATE EMQW_Y1
						   SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						FROM EMQW_Y1 AS a
						WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
				END
			------------------------------------------------------------------------------------------------
			-- ProfessionalLicense_T1
			------------------------------------------------------------------------------------------------
				SET @Ls_Sql_TEXT = 'SELECT OBLE_Y1';
				
				SELECT @Ln_PlicValidation_QNTY = COUNT(1)
	                   FROM PLIC_Y1  AS a
	                   WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
	            
	            IF @Ln_PlicValidation_QNTY > 0
					BEGIN
						SELECT @Lx_XmlData_XML = (SELECT a.*, CASE  WHEN EXISTS (SELECT 1 
																					FROM PLIC_Y1 b 
																				   WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																					 AND b.TypeLicense_CODE = a.TypeLicense_CODE
																					 AND b.LicenseNo_TEXT = a.LicenseNo_TEXT 
																					 AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
																   THEN 'D'
																   ELSE 'U'
															  END merge_status
													FROM PLIC_Y1 a
												 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
							
							SELECT @Ln_PlicValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																	FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
																	
							SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - PLIC_Y1';
						
							INSERT MMLG_Y1(
										  MemberMciPrimary_IDNO, 
										  MemberMciSecondary_IDNO, 
										  Table_NAME, 
										  RowsAffected_NUMB, 
										  RowDataXml_TEXT, 
										  TransactionEventSeq_NUMB, 
										  Merge_DATE)
									VALUES (
										 @An_MemberMciPrimary_IDNO, 
										 @An_MemberMciSecondary_IDNO, 
										 'PLIC_Y1', 
										 @Ln_PlicValidation_QNTY, 
										 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
										 @An_TransactionEventSeq_NUMB, 
										 @Ad_Run_DATE); 
										 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' DELETE FROM PLIC_Y1';
							
							DELETE PLIC_Y1
								 FROM PLIC_Y1  AS a
								 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
								   AND EXISTS ( SELECT 1
												  FROM PLIC_Y1  AS b
												 WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
												   AND a.TypeLicense_CODE = b.TypeLicense_CODE 
												   AND a.LicenseNo_TEXT = b.LicenseNo_TEXT 
												   AND a.TransactionEventSeq_NUMB = b.TransactionEventSeq_NUMB );
							
							SET @Ls_Sql_TEXT = ' UPDATE PLIC_Y1 1';
							
							UPDATE PLIC_Y1
								SET EndValidity_DATE = @Ad_Run_DATE
							 FROM PLIC_Y1  AS a
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND a.EndValidity_DATE = @Ld_High_DATE 
							   AND EXISTS ( SELECT 1
											  FROM PLIC_Y1  AS b
											 WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
											   AND b.TypeLicense_CODE = a.TypeLicense_CODE 
											   AND b.LicenseNo_TEXT = a.LicenseNo_TEXT 
											   AND b.EndValidity_DATE = @Ld_High_DATE );
	
							 SET @Ls_Sql_TEXT = ' UPDATE PLIC_Y1 2';
	
							 UPDATE PLIC_Y1
								SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
							 FROM PLIC_Y1  AS a
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
					END		
			------------------------------------------------------------------------------------------------
		-- ASRE_Y1 -- RealtyAssets_T1
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'ASRE_Y1 MMERG UPDATION';
			
			-- Defining the cursor @Asre_CUR
			SET @Asre_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					 SELECT 
                        TransactionEventSeq_NUMB, 
                        SourceLoc_CODE, 
                        AssetSeq_NUMB, 
                        Asset_CODE
                     FROM ASRE_Y1
                     WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
                     
            SET @Ls_Sql_TEXT = 'OPEN @Asre_CUR';
			
			OPEN @Asre_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Asre_CUR - 1';	

			FETCH NEXT FROM @Asre_CUR INTO  @Asre_REC$TransactionEventSeq_NUMB, @Asre_REC$SourceLoc_CODE, 
											@Asre_REC$AssetSeq_NUMB, @Asre_REC$Asset_CODE;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			-- cursor loop Starts @Asre_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
					SELECT @Lx_XmlData_XML = ( SELECT a.*, CASE WHEN a.EndValidity_DATE <> @Ld_High_DATE  
																 AND EXISTS 
																		(SELECT 1 
																			FROM ASRE_Y1 b 
																		  WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																		    AND b.Asset_CODE  = a.Asset_CODE 
																			AND b.AssetSeq_NUMB = a.AssetSeq_NUMB 
																			AND b.SourceLoc_CODE = a.SourceLoc_CODE 
																			AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
																THEN 'D'
																ELSE 'U'
															  END merge_status
													FROM ASRE_Y1 a
												   WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
													 AND a.Asset_CODE = @Asre_REC$Asset_CODE 
													 AND a.AssetSeq_NUMB = @Asre_REC$AssetSeq_NUMB 
													 AND a.SourceLoc_CODE = @Asre_REC$SourceLoc_CODE 
													 AND a.TransactionEventSeq_NUMB = @Asre_REC$TransactionEventSeq_NUMB for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_AsreValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
					
					SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - ASRE_Y1';
				
					INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
							VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'ASRE_Y1', 
								 @Ln_AsreValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE); 
								 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE ASRE_Y1';
					
					
					UPDATE ASRE_Y1
                        SET 
                           AssetSeq_NUMB = ISNULL((SELECT MAX(b.AssetSeq_NUMB) + 1
													 FROM ASRE_Y1  AS b
													WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
													  AND b.EndValidity_DATE = @Ld_High_DATE), 1), 
                           MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                     WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO  
                       AND TransactionEventSeq_NUMB = @Asre_REC$TransactionEventSeq_NUMB 
                       AND SourceLoc_CODE = @Asre_REC$SourceLoc_CODE
                       AND Asset_CODE = @Asre_REC$Asset_CODE
                       AND AssetSeq_NUMB = @Asre_REC$AssetSeq_NUMB
                       AND EndValidity_DATE = @Ld_High_DATE;
                        

					SET @Ls_Sql_TEXT = 'DELETE ASRE_Y1';
					
					DELETE ASRE_Y1
                     FROM ASRE_Y1 a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                       AND a.TransactionEventSeq_NUMB = @Asre_REC$TransactionEventSeq_NUMB
                       AND a.SourceLoc_CODE = @Asre_REC$SourceLoc_CODE
                       AND a.Asset_CODE = @Asre_REC$Asset_CODE
                       AND a.AssetSeq_NUMB = @Asre_REC$AssetSeq_NUMB
                       AND a.EndValidity_DATE <> @Ld_High_DATE
                       AND EXISTS ( SELECT 1
									  FROM ASRE_Y1 b
									 WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
									   AND b.Asset_CODE = a.Asset_CODE 
									   AND b.AssetSeq_NUMB = a.AssetSeq_NUMB 
									   AND b.SourceLoc_CODE = a.SourceLoc_CODE 
									   AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);
                              
                              
					SET @Ls_Sql_TEXT = ' UPDATE ASRE_Y1 2';

                     UPDATE ASRE_Y1
                        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                     FROM ASRE_Y1  AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                       AND a.Asset_CODE = @Asre_REC$Asset_CODE
                       AND a.AssetSeq_NUMB = @Asre_REC$AssetSeq_NUMB
                       AND a.SourceLoc_CODE = @Asre_REC$SourceLoc_CODE
                       AND a.TransactionEventSeq_NUMB = @Asre_REC$TransactionEventSeq_NUMB;    
				
					-- End of Loop @Asre_CUR
					FETCH NEXT FROM @Asre_CUR INTO  @Asre_REC$TransactionEventSeq_NUMB, @Asre_REC$SourceLoc_CODE, 
											@Asre_REC$AssetSeq_NUMB, @Asre_REC$Asset_CODE;
			
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
			CLOSE @Asre_CUR;
			DEALLOCATE @Asre_CUR;
			-- Cursor loop Ends @Asre_CUR		
		------------------------------------------------------------------------------------------------
		-- ASRV_Y1 -- RegisteredVehicles_T1
		------------------------------------------------------------------------------------------------			
			SET @Ls_Sql_TEXT = 'ASRV_Y1 MMERG UPDATION';	
								  
			-- Defining the cursor @Asrv_CUR
			SET @Asrv_CUR =  
			CURSOR LOCAL FORWARD_ONLY STATIC FOR
				SELECT  TransactionEventSeq_NUMB, 
						SourceLoc_CODE, 
						AssetSeq_NUMB, 
						Asset_CODE
                     FROM ASRV_Y1
                     WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
					
			SET @Ls_Sql_TEXT = 'OPEN @Asrv_CUR';

			OPEN @Asrv_CUR;
			
			SET @Ls_Sql_TEXT = 'FETCH @Asrv_CUR - 1';	

			FETCH NEXT FROM @Asrv_CUR INTO @Asrv_REC$TransactionEventSeq_NUMB, @Asrv_REC$SourceLoc_CODE, @Asrv_REC$AssetSeq_NUMB , @Asrv_REC$Asset_CODE;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			
			-- Cursor loop Starts @Asrv_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE  WHEN a.EndValidity_DATE <> @Ld_High_DATE  
																 AND EXISTS (SELECT 1 
																			   FROM ASRV_Y1 b 
																			  WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																			    AND b.Asset_CODE  = a.Asset_CODE 
																				AND b.AssetSeq_NUMB = a.AssetSeq_NUMB 
																				AND b.SourceLoc_CODE = a.SourceLoc_CODE 
																				AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
										  THEN 'D'
										  ELSE 'U'
									 END merge_status
							FROM ASRV_Y1 a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						   AND a.Asset_CODE = @Asrv_REC$Asset_CODE
						   AND a.AssetSeq_NUMB = @Asrv_REC$AssetSeq_NUMB
						   AND a.SourceLoc_CODE = @Asrv_REC$SourceLoc_CODE
						   AND a.TransactionEventSeq_NUMB = @Asrv_REC$TransactionEventSeq_NUMB for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_AsrvValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);  
					
					SET @Ls_Sql_TEXT = 'INSERT MMLG_Y1 :  ASRV_Y1';
																
					INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
							VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'ASRV_Y1', 
								 @Ln_AsrvValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE); 
								 
					
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'UPDATE ASRV_Y1';
					
					UPDATE ASRV_Y1
                        SET AssetSeq_NUMB = ISNULL(
                              (
                                 SELECT MAX(b.AssetSeq_NUMB) + 1
									FROM ASRV_Y1  AS b
                                 WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO AND b.EndValidity_DATE = @Ld_High_DATE
                              ), 1), 
                           MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                     FROM ASRV_Y1  AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                       AND a.TransactionEventSeq_NUMB = @Asrv_REC$TransactionEventSeq_NUMB
                       AND a.SourceLoc_CODE = @Asrv_REC$SourceLoc_CODE
                       AND a.Asset_CODE = @Asrv_REC$Asset_CODE
                       AND a.EndValidity_DATE = @Ld_High_DATE;
					
					SET @Ls_Sql_TEXT = ' DELETE ASRV_Y1';
					
					DELETE ASRV_Y1
                     FROM ASRV_Y1 AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                       AND a.TransactionEventSeq_NUMB = @Asrv_REC$TransactionEventSeq_NUMB 
                       AND a.SourceLoc_CODE = @Asrv_REC$SourceLoc_CODE 
                       AND a.Asset_CODE = @Asrv_REC$Asset_CODE 
                       AND a.AssetSeq_NUMB = @Asrv_REC$AssetSeq_NUMB 
                       AND a.EndValidity_DATE <> @Ld_High_DATE 
                       AND EXISTS 
                        (
                           SELECT 1
                           FROM ASRV_Y1  AS b
                           WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO  
                             AND b.Asset_CODE = a.Asset_CODE 
                             AND b.AssetSeq_NUMB = a.AssetSeq_NUMB 
                             AND b.SourceLoc_CODE = a.SourceLoc_CODE
                             AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB
                        );
                        
                        
                     SET @Ls_Sql_TEXT = ' UPDATE VASRV_Y1 2';

                     UPDATE ASRV_Y1
                        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                     FROM ASRV_Y1  AS a
                     WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
                       AND a.Asset_CODE = @Asrv_REC$Asset_CODE 
                       AND a.AssetSeq_NUMB = @Asrv_REC$AssetSeq_NUMB
                       AND a.SourceLoc_CODE = @Asrv_REC$SourceLoc_CODE
                       AND a.TransactionEventSeq_NUMB = @Asrv_REC$TransactionEventSeq_NUMB;				
					
					-- End of @Asrv_CUR
					FETCH NEXT FROM @Asrv_CUR INTO @Asrv_REC$TransactionEventSeq_NUMB, @Asrv_REC$SourceLoc_CODE, @Asrv_REC$AssetSeq_NUMB , @Asrv_REC$Asset_CODE;			
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END			
			CLOSE @Asrv_CUR;
			DEALLOCATE @Asrv_CUR;
			-- Cursor loop Ends @Asrv_CUR	
		------------------------------------------------------------------------------------------------
		-- Schedule_T1
		------------------------------------------------------------------------------------------------				
			 SET @Ls_Sql_TEXT = 'SWKS_Y1 MMERG UPDATION';	
								  
			 -- Defining the cursor @Swks_CUR
			 SET @Swks_CUR =  
					CURSOR LOCAL FORWARD_ONLY STATIC FOR
						SELECT DISTINCT Schedule_NUMB, Case_IDNO
							FROM SWKS_Y1
							WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
							ORDER BY Schedule_NUMB, Case_IDNO;
							
			SET @Ls_Sql_TEXT = 'OPEN @Swks_CUR';
				
			OPEN @Swks_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Swks_CUR - 1';	

			FETCH NEXT FROM @Swks_CUR INTO @Swks_REC$Schedule_NUMB, @Swks_REC$Case_IDNO;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;	
						
			-- cursor loop1 Starts @Swks_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
					SET @Ls_Sql_TEXT = 'SELECT SWKS_Y1';
					
					SELECT @Ln_SwksValidation_QNTY = COUNT(1)
					  FROM SWKS_Y1
					 WHERE MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
					   AND Schedule_NUMB = @Swks_REC$Schedule_NUMB 
					   AND Case_IDNO = @Swks_REC$Case_IDNO;
					
					IF @Ln_SwksValidation_QNTY = 0
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status  
							  FROM SWKS_Y1 a  
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND a.Schedule_NUMB = @Swks_REC$Schedule_NUMB 
							   AND a.Case_IDNO = @Swks_REC$Case_IDNO for XML PATH('ROWS'),TYPE);
						
							SELECT @Ln_SwksValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
																
							SET @Ls_Sql_TEXT = 'INSERT INTO MMLG_Y1 - SWKS_Y1 2';
							
							INSERT MMLG_Y1(
										  MemberMciPrimary_IDNO, 
										  MemberMciSecondary_IDNO, 
										  Table_NAME, 
										  RowsAffected_NUMB, 
										  RowDataXml_TEXT, 
										  TransactionEventSeq_NUMB, 
										  Merge_DATE)
									VALUES (
										 @An_MemberMciPrimary_IDNO, 
										 @An_MemberMciSecondary_IDNO, 
										 'SWKS_Y1', 
										 @Ln_SwksValidation_QNTY, 
										 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
										 @An_TransactionEventSeq_NUMB, 
										 @Ad_Run_DATE); 
										 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' UPDATE SWKS_Y1 '

							UPDATE SWKS_Y1
							   SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
							 WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND Schedule_NUMB = @Swks_REC$Schedule_NUMB 
							   AND Case_IDNO = @Swks_REC$Case_IDNO;
						END
					ELSE
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*, 'D' merge_status 
														FROM SWKS_Y1 a 
													   WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
													     AND a.Schedule_NUMB = @Swks_REC$Schedule_NUMB 
														 AND a.Case_IDNO = @Swks_REC$Case_IDNO for XML PATH('ROWS'),TYPE);
						
							SELECT @Ln_SwksValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
																
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - SWKS_Y1 2';		
							
							INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
							VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'SWKS_Y1', 
								 @Ln_SwksValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE); 
								 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = 'DELETE SWKS_Y1';

							DELETE SWKS_Y1
							 WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND Schedule_NUMB = @Swks_REC$Schedule_NUMB 
							   AND Case_IDNO = @Swks_REC$Case_IDNO;											
						END
							
					--End of loop @Swks_CUR						
					FETCH NEXT FROM @Swks_CUR INTO @Swks_REC$Schedule_NUMB, @Swks_REC$Case_IDNO;
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
			CLOSE @Swks_CUR;
			DEALLOCATE @Swks_CUR;
			-- Cursor loop Ends @Swks_CUR	
		------------------------------------------------------------------------------------------------
		-- ScheduleHist_T1
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'HSWKS_Y1 MMERG UPDATION';
			
			-- Defining the cursor @Hswks_CUR					  
			SET @Hswks_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT DISTINCT Schedule_NUMB, Case_IDNO
						FROM HSWKS_Y1
						WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
						ORDER BY Schedule_NUMB, Case_IDNO;
						
			SET @Ls_Sql_TEXT = 'OPEN @Hswks_CUR';

			OPEN @Hswks_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Hswks_CUR - 1';	

			FETCH NEXT FROM @Hswks_CUR INTO @Hswks_REC$Schedule_NUMB, @Hswks_REC$Case_IDNO ;

			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;		
			
			-- cursor loop1 Starts @Hswks_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN		
					 SET @Ls_Sql_TEXT = ' SELECT HSWKS_Y1';
					 
					  SELECT @Ln_HswksValidation_QNTY = COUNT(1)
						 FROM HSWKS_Y1
						 WHERE MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
						   AND Schedule_NUMB = @Hswks_REC$Schedule_NUMB 
						   AND Case_IDNO = @Hswks_REC$Case_IDNO;

					IF @Ln_HswksValidation_QNTY = 0
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status 
														FROM HSWKS_Y1 a 
													   WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
													     AND a.Case_IDNO = @Hswks_REC$Case_IDNO 
													     AND a.Schedule_NUMB = @Hswks_REC$Schedule_NUMB for XML PATH('ROWS'),TYPE);
						
							SELECT @Ln_HswksValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
																
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HSWKS_Y1';		
							
							INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
							VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'HSWKS_Y1', 
								 @Ln_HswksValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE); 
								 
								 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' UPDATE HSWKS_Y1 1'

							UPDATE HSWKS_Y1
							   SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
							 WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND Schedule_NUMB = @Hswks_REC$Schedule_NUMB 
							   AND Case_IDNO = @Hswks_REC$Case_IDNO;
						END
					ELSE
						BEGIN
							SELECT @Lx_XmlData_XML = (SELECT a.*, 'D' merge_status
								FROM HSWKS_Y1 a
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							   AND a.Case_IDNO = @Hswks_REC$Case_IDNO 
							   AND a.Schedule_NUMB = @Hswks_REC$Schedule_NUMB for XML PATH('ROWS'),TYPE);
						
							SELECT @Ln_HswksValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
																
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HSWKS_Y1 2';	
							
							INSERT MMLG_Y1(
								  MemberMciPrimary_IDNO, 
								  MemberMciSecondary_IDNO, 
								  Table_NAME, 
								  RowsAffected_NUMB, 
								  RowDataXml_TEXT, 
								  TransactionEventSeq_NUMB, 
								  Merge_DATE)
							VALUES (
								 @An_MemberMciPrimary_IDNO, 
								 @An_MemberMciSecondary_IDNO, 
								 'HSWKS_Y1', 
								 @Ln_HswksValidation_QNTY, 
								 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
								 @An_TransactionEventSeq_NUMB, 
								 @Ad_Run_DATE); 
								 
							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = ' DELETE HSWKS_Y1';

							DELETE HSWKS_Y1
							WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
							  AND Schedule_NUMB = @Hswks_REC$Schedule_NUMB 
							  AND Case_IDNO = @Hswks_REC$Case_IDNO;
						END
					--- End of Loop
					FETCH NEXT FROM @Hswks_CUR INTO @Hswks_REC$Schedule_NUMB, @Hswks_REC$Case_IDNO ;
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END				  							
			CLOSE @Hswks_CUR;
			DEALLOCATE @Hswks_CUR;
			-- Cursor loop Ends @Hswks_CUR	
		------------------------------------------------------------------------------------------------
		-- StateLastSent_T1
		------------------------------------------------------------------------------------------------				  
			SET @Ls_Sql_TEXT = 'SLST_Y1 MMERG UPDATION';
								  
			SELECT @Ln_SlstValidation_QNTY = COUNT(1)
				FROM SLST_Y1  AS a
				WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
			
			IF @Ln_SlstValidation_QNTY > 0
				BEGIN				
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 FROM SLST_Y1 b WHERE 
													b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO)             
															  THEN 'D'
															  ELSE 'U'
														  END merge_status 
												FROM SLST_Y1 a 
											 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO  for XML PATH('ROWS'),TYPE);
						
					SELECT @Ln_SlstValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
																
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - SLST_Y1';	
							
					INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
					VALUES (
						 @An_MemberMciPrimary_IDNO, 
						 @An_MemberMciSecondary_IDNO, 
						 'SLST_Y1', 
						 @Ln_SlstValidation_QNTY, 
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
						 @An_TransactionEventSeq_NUMB, 
						 @Ad_Run_DATE); 
						 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' DELETE SLST_Y1';

					DELETE SLST_Y1
					  FROM SLST_Y1  AS a
					 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					   AND EXISTS ( SELECT 1
									  FROM SLST_Y1  AS b
									 WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO);
							  
					SET @Ls_Sql_TEXT = 'UPDATE SLST_Y1';

					UPDATE SLST_Y1
					   SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
					FROM SLST_Y1  AS a
					WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
				END
			------------------------------------------------------------------------------------------------
		-- CsenetNcpBlocks_T1
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'CNCB_Y1 MMERG UPDATION';
			
			SET @Ls_Sql_TEXT = ' SELECT CNCB_Y1'; 
			
			SELECT @Ln_CncbValidation_QNTY = COUNT(1)
               FROM CNCB_Y1  AS a
               WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
               
			IF @Ln_CncbValidation_QNTY > 0
                  BEGIN
						SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status    FROM CNCB_Y1 a
														WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
						
						SELECT @Ln_CncbValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a); 
																
						SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - CNCB_Y1';
						
						INSERT MMLG_Y1(
							  MemberMciPrimary_IDNO, 
							  MemberMciSecondary_IDNO, 
							  Table_NAME, 
							  RowsAffected_NUMB, 
							  RowDataXml_TEXT, 
							  TransactionEventSeq_NUMB, 
							  Merge_DATE)
						VALUES (
							 @An_MemberMciPrimary_IDNO, 
							 @An_MemberMciSecondary_IDNO, 
							 'CNCB_Y1', 
							 @Ln_CncbValidation_QNTY, 
							 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
							 @An_TransactionEventSeq_NUMB, 
							 @Ad_Run_DATE); 
							 
						SET @Lx_XmlData_XML = NULL;
						
						SET @Ls_Sql_TEXT = 'UPDATE CNCB_Y1 1';
						
						UPDATE CNCB_Y1
							SET  MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						 FROM CNCB_Y1  AS a
						 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
                  END   
		------------------------------------------------------------------------------------------------
		-- CsenetParticipantBlocks_T1
		------------------------------------------------------------------------------------------------                            
			SET @Ls_Sql_TEXT = 'CPTB_Y1 MMERG UPDATION';
									  
			-- Defining the cursor @Cptb_CUR
			 SET @Cptb_CUR =  
					CURSOR LOCAL FORWARD_ONLY STATIC FOR
						SELECT TransHeader_IDNO, IVDOutOfStateFips_CODE,Transaction_DATE, BlockSeq_NUMB 
							 FROM CPTB_Y1  AS a
							 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;				 
							
			SET @Ls_Sql_TEXT = 'OPEN @Cptb_CUR';
				
			OPEN @Cptb_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Cptb_CUR - 1';	

			FETCH NEXT FROM @Cptb_CUR INTO @Cptb_REC$TransHeader_IDNO, @Cptb_REC$IVDOutOfStateFips_CODE, @Cptb_REC$Transaction_DATE, @Cptb_REC$BlockSeq_NUMB;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
						
			--Cursor loop Starts @Cptb_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN					
					SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status 
												FROM CPTB_Y1 a
												WHERE TransHeader_IDNO = @Cptb_REC$TransHeader_IDNO 
												  AND IVDOutOfStateFips_CODE = @Cptb_REC$IVDOutOfStateFips_CODE 
												  AND Transaction_DATE = @Cptb_REC$Transaction_DATE 
												  AND BlockSeq_NUMB = @Cptb_REC$BlockSeq_NUMB for XML PATH('ROWS'),TYPE);
													  
													  
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - CPTB_Y1';				 
					INSERT MMLG_Y1(
									  MemberMciPrimary_IDNO, 
									  MemberMciSecondary_IDNO, 
									  Table_NAME, 
									  RowsAffected_NUMB, 
									  RowDataXml_TEXT, 
									  TransactionEventSeq_NUMB, 
									  Merge_DATE)
								VALUES (
									 @An_MemberMciPrimary_IDNO, 
									 @An_MemberMciSecondary_IDNO, 
									 'CPTB_Y1', 
									 1, 
									 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
									 @An_TransactionEventSeq_NUMB, 
									 @Ad_Run_DATE); 																		  
					
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'UPDATE CPTB_Y1';
					
					UPDATE CPTB_Y1
                        SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
                     FROM CPTB_Y1  AS a
                     WHERE TransHeader_IDNO = @Cptb_REC$TransHeader_IDNO 
                       AND IVDOutOfStateFips_CODE = @Cptb_REC$IVDOutOfStateFips_CODE 
                       AND Transaction_DATE = @Cptb_REC$Transaction_DATE 
                       AND BlockSeq_NUMB = @Cptb_REC$BlockSeq_NUMB;
						   							  
					---End of loop
					FETCH NEXT FROM @Cptb_CUR INTO @Cptb_REC$TransHeader_IDNO, @Cptb_REC$IVDOutOfStateFips_CODE, @Cptb_REC$Transaction_DATE, @Cptb_REC$BlockSeq_NUMB;			
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
				CLOSE @Cptb_CUR;
				DEALLOCATE @Cptb_CUR;
				--Cursor loop Ends @Cptb_CUR
		--------------------------------------------------------------------------------
		-- Merge Receipt_T1
		---------------------------------------------------------------------------------									
			SET @Ls_Sql_TEXT = 'RCTH_Y1 MMERG UPDATION';	
			
			 -- Defining the cursor @Rcth_CUR
			 SET @Rcth_CUR =  
					CURSOR LOCAL FORWARD_ONLY STATIC FOR
						SELECT DISTINCT a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB
							FROM RCTH_Y1  AS a
							WHERE (a.PayorMCI_IDNO = @An_MemberMciSecondary_IDNO OR 
								   a.RefundRecipient_ID = @Lc_MemberMciSecondary_ID );
							
			SET @Ls_Sql_TEXT = 'OPEN @Rcth_CUR';
				
			OPEN @Rcth_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Rcth_CUR - 1';	

			FETCH NEXT FROM @Rcth_CUR INTO @Rcth_REC$Batch_DATE, @Rcth_REC$SourceBatch_CODE, @Rcth_REC$Batch_NUMB, @Rcth_REC$SeqReceipt_NUMB;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			
			-- cursor loop Starts @Rcth_CUR		
			WHILE @Li_FetchStatus_QNTY = 0				
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status 
												FROM RCTH_Y1 a
												WHERE Batch_DATE = @Rcth_REC$Batch_DATE 
												  AND SourceBatch_CODE = @Rcth_REC$SourceBatch_CODE 
												  AND Batch_NUMB = @Rcth_REC$Batch_NUMB 
												  AND SeqReceipt_NUMB = @Rcth_REC$SeqReceipt_NUMB for XML PATH('ROWS'),TYPE);
											
					SELECT @Ln_RcthValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																			FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																			
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - RCTH_Y1';
					
					INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
					VALUES (
						 @An_MemberMciPrimary_IDNO, 
						 @An_MemberMciSecondary_IDNO, 
						 'RCTH_Y1', 
						 @Ln_RcthValidation_QNTY,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
						 @An_TransactionEventSeq_NUMB, 
						 @Ad_Run_DATE);
						 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE RCTH_Y1';

					UPDATE  RCTH_Y1
					   SET PayorMCI_IDNO = 
							 CASE 
								WHEN PayorMCI_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
								ELSE PayorMCI_IDNO
							 END, 
						  RefundRecipient_ID = 
							 CASE 
								WHEN RefundRecipient_ID = @Lc_MemberMciSecondary_ID THEN @Lc_MemberMciPrimary_ID
								ELSE RefundRecipient_ID
							 END
					WHERE Batch_DATE = @Rcth_REC$Batch_DATE 
					  AND SourceBatch_CODE = @Rcth_REC$SourceBatch_CODE 
					  AND Batch_NUMB = @Rcth_REC$Batch_NUMB 
					  AND SeqReceipt_NUMB = @Rcth_REC$SeqReceipt_NUMB;
					
					--End of Loop @Rcth_CUR
					FETCH NEXT FROM @Rcth_CUR INTO @Rcth_REC$Batch_DATE, @Rcth_REC$SourceBatch_CODE, @Rcth_REC$Batch_NUMB, @Rcth_REC$SeqReceipt_NUMB;			
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;	
				END
				CLOSE @Rcth_CUR;
				DEALLOCATE @Rcth_CUR;
				-- cursor loop Ends @Rcth_CUR		
		-----------------------------------------------------------------------------
		-- Merge Log Support Current
		-----------------------------------------------------------------------------	
			SET @Ls_Sql_TEXT = ' SELECT LSUP_Y1';
			 
			SELECT @Ln_LsupExists_QNTY = COUNT(1)
			  FROM LSUP_Y1  AS a
			  WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO 
			    AND a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE 
			    AND a.Case_IDNO IN 
				 (
					SELECT b.Case_IDNO
					FROM UCMEM_V1  AS b
					WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
				 ); 

			IF @Ln_LsupExists_QNTY > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status FROM LSUP_Y1 a
												WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO 
												  AND a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE 
												  AND a.Case_IDNO IN (SELECT b.Case_IDNO 
																		FROM UCMEM_V1 b
																		WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO) for XML PATH('ROWS'),TYPE);
											
					SELECT @Ln_LsupExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																			FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																			
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - LSUP_Y1';
					INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
					VALUES (
						 @An_MemberMciPrimary_IDNO, 
						 @An_MemberMciSecondary_IDNO, 
						 'LSUP_Y1', 
						 @Ln_LsupExists_QNTY,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
						 @An_TransactionEventSeq_NUMB, 
						 @Ad_Run_DATE);
						 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE LSUP_Y1';
					
					UPDATE LSUP_Y1
					   SET CheckRecipient_ID = @An_MemberMciPrimary_IDNO
					FROM LSUP_Y1  AS a
					WHERE a.CheckRecipient_ID = @An_MemberMciSecondary_IDNO 
					  AND a.CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE 
					  AND a.Case_IDNO IN ( SELECT b.Case_IDNO
											FROM UCMEM_V1  AS b
											WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO);					
				END		
		---------------------------------------------------------------------------------
		-- Merge PayeeOffsetLog_T1 table
		---------------------------------------------------------------------------------	
			SET @Ls_Sql_TEXT = ' SELECT POFL_Y1';
			
			--verify existance of POFL record for Primary ID   
			SELECT @Ln_PoflExists_QNTY = COUNT(1)
			FROM POFL_Y1
			WHERE CheckRecipient_ID = @An_MemberMciSecondary_IDNO 
			  AND CheckRecipient_CODE = @Lc_RecipientTypeCpNcp_CODE; 
				  
			-- Defining the cursor @Pofl_CUR
			SET @Pofl_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT  Unique_IDNO,
							 SUM(PendOffset_AMNT) OVER (partition BY TypeRecoupment_CODE, RecoupmentPayee_CODE) PendTotOffsetSUM_AMNT,
							 SUM(AssessOverpay_AMNT) OVER (partition BY TypeRecoupment_CODE, RecoupmentPayee_CODE) AssessTotOverpaySUM_AMNT,
							 SUM(RecOverpay_AMNT) OVER (partition BY TypeRecoupment_CODE, RecoupmentPayee_CODE) RecTotOverpaySUM_AMNT
						FROM POFL_Y1 a
						WHERE a.CheckRecipient_ID IN ( @An_MemberMciPrimary_IDNO, @An_MemberMciSecondary_IDNO )
						ORDER BY TypeRecoupment_CODE, RecoupmentPayee_CODE,Unique_IDNO;

			--If secondary exists update all secondary recipients with Primary ID and amounts
			IF @Ln_PoflExists_QNTY > 0
				BEGIN
					
					SET @Ls_Sql_TEXT = 'OPEN @Pofl_CUR';

					OPEN @Pofl_CUR;

					SET @Ls_Sql_TEXT = 'FETCH @Pofl_CUR - 1';

					FETCH NEXT FROM @Pofl_CUR INTO @Pofl_REC$Unique_IDNO, @Pofl_REC$PendTotOffsetSUM_AMNT, 
												   @Pofl_REC$AssessTotOverpaySUM_AMNT, @Pofl_REC$RecTotOverpaySUM_AMNT;

					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
					--Cursor loop Starts @Pofl_CUR		
					WHILE @Li_FetchStatus_QNTY = 0
						BEGIN
							SET @Ls_Sql_TEXT = '@Pofl_CUR MMERG LOOP';
							
							SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status FROM POFL_Y1 a
														WHERE Unique_IDNO = @Pofl_REC$Unique_IDNO for XML PATH('ROWS'),TYPE);
											
							SELECT @Ln_PoflExists_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																						FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																			
							SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - POFL_Y1';
							INSERT MMLG_Y1(
										  MemberMciPrimary_IDNO, 
										  MemberMciSecondary_IDNO, 
										  Table_NAME, 
										  RowsAffected_NUMB, 
										  RowDataXml_TEXT, 
										  TransactionEventSeq_NUMB, 
										  Merge_DATE)
									VALUES (
										 @An_MemberMciPrimary_IDNO, 
										 @An_MemberMciSecondary_IDNO, 
										 'POFL_Y1', 
										 @Ln_PoflExists_QNTY,
										 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
										 @An_TransactionEventSeq_NUMB, 
										 @Ad_Run_DATE);

							SET @Lx_XmlData_XML = NULL;
							
							SET @Ls_Sql_TEXT = 'UPDATE POFL_Y1';
							
							UPDATE POFL_Y1
                              SET 
                                 CheckRecipient_ID = @An_MemberMciPrimary_IDNO, 
                                 PendTotOffset_AMNT = @Pofl_REC$PendTotOffsetSUM_AMNT, 
                                 AssessTotOverpay_AMNT = @Pofl_REC$AssessTotOverpaySUM_AMNT, 
                                 RecTotOverpay_AMNT = @Pofl_REC$RecTotOverpaySUM_AMNT
                           FROM POFL_Y1  AS b
                           WHERE Unique_IDNO = @Pofl_REC$Unique_IDNO;
							
							-- Loop ends
							FETCH NEXT FROM @Pofl_CUR INTO @Pofl_REC$Unique_IDNO, @Pofl_REC$PendTotOffsetSUM_AMNT, 
												   @Pofl_REC$AssessTotOverpaySUM_AMNT, @Pofl_REC$RecTotOverpaySUM_AMNT;
							SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
						END
						CLOSE @Pofl_CUR;
						DEALLOCATE @Pofl_CUR;
						--Cursor loop Ends @Pofl_CUR		
				END			   
			
		------------------------------------------------------------------------------------------------
		-- EnforcementStagingDetails_T1 TABLE
		------------------------------------------------------------------------------------------------	
			 SET @Ls_Sql_TEXT = 'ENSD_Y1 MMERG UPDATION';
			 
			-- Defining the cursor @Ensd_CUR
			SET @Ensd_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT a.Case_IDNO
						FROM ENSD_Y1  AS a
						WHERE a.NcpPf_IDNO = @An_MemberMciSecondary_IDNO 
						   OR a.CpMci_IDNO = @An_MemberMciSecondary_IDNO
						
			SET @Ls_Sql_TEXT = 'OPEN @Ensd_CUR';

			OPEN @Ensd_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Ensd_CUR - 1';	

			FETCH NEXT FROM @Ensd_CUR INTO @Ensd_REC$Case_IDNO;

			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			-- cursor loop1 Starts @Ensd_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, 'U' merge_status FROM ENSD_Y1 a 
												WHERE Case_IDNO = @Ensd_REC$Case_IDNO for XML PATH('ROWS'),TYPE);
											
					SELECT @Ln_EnsdValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																			FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																			
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - ENSD_Y1';
					INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
					VALUES (
						 @An_MemberMciPrimary_IDNO, 
						 @An_MemberMciSecondary_IDNO, 
						 'ENSD_Y1', 
						 @Ln_EnsdValidation_QNTY,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
						 @An_TransactionEventSeq_NUMB, 
						 @Ad_Run_DATE);
						 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = ' UPDATE ENSD_Y1';
					
					UPDATE ENSD_Y1
					   SET 
						  NcpPf_IDNO = 
							 CASE 
								WHEN NcpPf_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
								ELSE NcpPf_IDNO
							 END, 
						  CpMci_IDNO = 
							 CASE 
								WHEN CpMci_IDNO = @An_MemberMciSecondary_IDNO THEN @An_MemberMciPrimary_IDNO
								ELSE CpMci_IDNO
							 END
					WHERE Case_IDNO = @Ensd_REC$Case_IDNO; 
					--End of loop
					FETCH NEXT FROM @Ensd_CUR INTO @Ensd_REC$Case_IDNO;
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
				CLOSE @Ensd_CUR;
				DEALLOCATE @Ensd_CUR;
				-- cursor loop1 Starts @Ensd_CUR	
			------------------------------------------------------------------------------------------------
		-- GeneticTesting_T1 TABLE
		------------------------------------------------------------------------------------------------				
			SET @Ls_Sql_TEXT = 'MMRG_Y1 - GTST_Y1 MMERG UPDATION';
			
			-- Defining the cursor @Gtst_CUR
			SET @Gtst_CUR =  
				CURSOR LOCAL FORWARD_ONLY STATIC FOR
					SELECT DISTINCT Case_IDNO, Schedule_NUMB
						FROM GTST_Y1
						WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO
						ORDER BY Case_IDNO, Schedule_NUMB;
						
			SET @Ls_Sql_TEXT = 'OPEN @Gtst_CUR';

			OPEN @Gtst_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Gtst_CUR - 1';
			
			FETCH NEXT FROM @Gtst_CUR INTO @Gtst_REC$Case_IDNO, @Gtst_REC$Schedule_NUMB
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			-- cursor loop Starts @Gtst_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN			
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE  WHEN EXISTS (SELECT 1 FROM GTST_Y1 b 
																					WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																					  AND b.Case_IDNO = a.Case_IDNO 
																					  AND b.Schedule_NUMB = a.Schedule_NUMB 
																					  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
																	 THEN 'D'
																	 ELSE 'U'
															  END merge_status
													FROM GTST_Y1 a
												 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
												   AND a.Case_IDNO = @Gtst_REC$Case_IDNO 
												   AND a.Schedule_NUMB   = @Gtst_REC$Schedule_NUMB for XML PATH('ROWS'),TYPE);
												
						SELECT @Ln_GtstValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
																		FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
																		
						SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - GTST_Y1';
						INSERT MMLG_Y1(
						  MemberMciPrimary_IDNO, 
						  MemberMciSecondary_IDNO, 
						  Table_NAME, 
						  RowsAffected_NUMB, 
						  RowDataXml_TEXT, 
						  TransactionEventSeq_NUMB, 
						  Merge_DATE)
						VALUES (
						 @An_MemberMciPrimary_IDNO, 
						 @An_MemberMciSecondary_IDNO, 
						 'GTST_Y1', 
						 @Ln_GtstValidation_QNTY,
						 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
						 @An_TransactionEventSeq_NUMB, 
						 @Ad_Run_DATE);
						 
					  SET @Lx_XmlData_XML = NULL;
					  
					  SET @Ls_Sql_TEXT = ' DELETE GTST_Y1';

					  DELETE GTST_Y1
						FROM GTST_Y1  AS a
					   WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					     AND a.Case_IDNO = @Gtst_REC$Case_IDNO 
					     AND a.Schedule_NUMB = @Gtst_REC$Schedule_NUMB 
					     AND EXISTS ( SELECT 1
										FROM GTST_Y1  AS b
									   WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
										 AND b.Case_IDNO = a.Case_IDNO 
										 AND b.Schedule_NUMB = a.Schedule_NUMB 
										 AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);

						SET @Ls_Sql_TEXT = 'UPDATE VGTST_Y1 1';								   
						 
						UPDATE GTST_Y1
						   SET  EndValidity_DATE = @Ad_Run_DATE
						FROM GTST_Y1  AS a
						WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						  AND a.Case_IDNO = @Gtst_REC$Case_IDNO 
						  AND a.Schedule_NUMB = @Gtst_REC$Schedule_NUMB 
						  AND a.EndValidity_DATE = @Ld_High_DATE 
						  AND EXISTS 
						   (
							  SELECT 1
							  FROM GTST_Y1  AS b
							  WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
							    AND b.Case_IDNO = a.Case_IDNO 
							    AND b.Schedule_NUMB = a.Schedule_NUMB 
							    AND b.EndValidity_DATE = @Ld_High_DATE
						   );

					SET @Ls_Sql_TEXT = 'UPDATE GTST_Y1 2';		
					
					UPDATE GTST_Y1
					   SET  MemberMci_IDNO = @An_MemberMciPrimary_IDNO
					WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					  AND Case_IDNO = @Gtst_REC$Case_IDNO 
					  AND Schedule_NUMB = @Gtst_REC$Schedule_NUMB;
					   
					-- End of loop
					FETCH NEXT FROM @Gtst_CUR INTO @Gtst_REC$Case_IDNO, @Gtst_REC$Schedule_NUMB
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
				CLOSE @Gtst_CUR;
				DEALLOCATE @Gtst_CUR;
				-- cursor loop Ends @Gtst_CUR
				
			-- 13599 - CMEM and HCMEM merge is moved to at the end of the Merge - Start	
			------------------------------------------------------------------------------------------------
			-- CMEM -- CASE MEMBER
			------------------------------------------------------------------------------------------------	
			SET @Ls_Sql_TEXT = ' SELECT CMEM_Y1';
			
			SELECT  @Ln_ExistsCmem_NUMB = COUNT(1)
				FROM CMEM_Y1
				WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

			IF @Ln_ExistsCmem_NUMB > 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 FROM CMEM_Y1 b
																				WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																				  AND b.Case_IDNO = a.Case_IDNO) 
																 THEN 'D'
																 ELSE 'U'
															END merge_status FROM CMEM_Y1 a
												WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_ExistsCmem_NUMB = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
												FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
												
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - CMEM_Y1';	
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @An_MemberMciPrimary_IDNO, 
					 @An_MemberMciSecondary_IDNO, 
					 'CMEM_Y1', 
					 @Ln_ExistsCmem_NUMB,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);		
					 
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'DELETE CMEM_Y1';
					
					DELETE CMEM_Y1
						FROM CMEM_Y1  AS a
						WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
						 AND EXISTS 
						   (
							  SELECT 1
							  FROM CMEM_Y1  AS b
							  WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
							    AND a.Case_IDNO = b.Case_IDNO
						   );

						SET @Ls_Sql_TEXT = 'UPDATE CMEM_Y1';

						UPDATE CMEM_Y1
						   SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
						WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;					
				END
		------------------------------------------------------------------------------------------------
		--  CaseMembersHist_T1
		------------------------------------------------------------------------------------------------								
			 SET @Ls_Sql_TEXT = 'MMRG_Y1 - HCMEM_Y1 MMERG UPDATION';
			 
			 -- Defining the cursor @Hcmem_CUR
			 SET @Hcmem_CUR =  
					CURSOR LOCAL FORWARD_ONLY STATIC FOR
						SELECT DISTINCT Case_IDNO
							FROM HCMEM_Y1
							WHERE MemberMci_IDNO = @An_MemberMciSecondary_IDNO;
							
			SET @Ls_Sql_TEXT = 'OPEN @Hcmem_CUR';
				
			OPEN @Hcmem_CUR;

			SET @Ls_Sql_TEXT = 'FETCH @Hcmem_CUR - 1';	

			FETCH NEXT FROM @Hcmem_CUR INTO @Hcmem_REC$Case_IDNO;
			
			SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
			--Cursor loop Starts @Hcmem_CUR		
			WHILE @Li_FetchStatus_QNTY = 0
				BEGIN
					SELECT @Lx_XmlData_XML = (SELECT a.*, CASE WHEN EXISTS (SELECT 1 FROM HCMEM_Y1 b 
																				WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
																				  AND b.Case_IDNO = a.Case_IDNO 
																				  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
																  THEN 'D'
																  ELSE 'U'
															 END merge_status FROM HCMEM_Y1 a
												 WHERE a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
												   AND a.Case_IDNO   = @Hcmem_REC$Case_IDNO for XML PATH('ROWS'),TYPE);
												
					SELECT @Ln_HcmemValidation_QNTY = (SELECT COUNT(*) FROM (SELECT t.c.exist('ROWS') AS id  
														FROM  @Lx_XmlData_XML.nodes('ROWS') t(c)) a);
												
					SET @Ls_Sql_TEXT = ' INSERT INTO MMLG_Y1 - HCMEM_Y1';	
					INSERT MMLG_Y1(
					  MemberMciPrimary_IDNO, 
					  MemberMciSecondary_IDNO, 
					  Table_NAME, 
					  RowsAffected_NUMB, 
					  RowDataXml_TEXT, 
					  TransactionEventSeq_NUMB, 
					  Merge_DATE)
					VALUES (
					 @An_MemberMciPrimary_IDNO, 
					 @An_MemberMciSecondary_IDNO, 
					 'HCMEM_Y1', 
					 @Ln_HcmemValidation_QNTY,
					 CAST(@Lx_XmlData_XML AS VARCHAR(MAX)), 
					 @An_TransactionEventSeq_NUMB, 
					 @Ad_Run_DATE);							
					
					SET @Lx_XmlData_XML = NULL;
					
					SET @Ls_Sql_TEXT = 'DELETE HCMEM_Y1';

					DELETE HCMEM_Y1
					FROM HCMEM_Y1  AS a
					WHERE a.Case_IDNO = @Hcmem_REC$Case_IDNO 
					  AND a.MemberMci_IDNO = @An_MemberMciSecondary_IDNO 
					  AND EXISTS ( SELECT 1
									FROM HCMEM_Y1  AS b
									WHERE b.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
									  AND b.Case_IDNO = a.Case_IDNO 
									  AND b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB);
					
					SET @Ls_Sql_TEXT = 'UPDATE HCMEM_Y1';

					UPDATE HCMEM_Y1
					   SET MemberMci_IDNO = @An_MemberMciPrimary_IDNO
					WHERE Case_IDNO = @Hcmem_REC$Case_IDNO 
					  AND MemberMci_IDNO = @An_MemberMciSecondary_IDNO;					
					
					-- End of loop
					FETCH NEXT FROM @Hcmem_CUR INTO @Hcmem_REC$Case_IDNO;			
					SELECT @Li_FetchStatus_QNTY = @@FETCH_STATUS;
				END
				CLOSE @Hcmem_CUR;
				DEALLOCATE @Hcmem_CUR;
				--Cursor loop Ends @Hcmem_CUR	
				-- 13599 - CMEM and HCMEM merge is moved to at the end of the Merge - End	
					      		
      		------ Table Merge Ends -------								
      		
			SET @Ac_Msg_CODE = 	@Lc_StatusSuccess_CODE;
			SET @As_DescriptionError_TEXT = ' ';					
      END TRY
      BEGIN CATCH
      
		IF CURSOR_STATUS('VARIABLE','@@Dmjr_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Dmjr_CUR;                                 
			DEALLOCATE @Dmjr_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@HDmjr_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @HDmjr_CUR;                                 
			DEALLOCATE @HDmjr_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Asfn_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Asfn_CUR;                                 
			DEALLOCATE @Asfn_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Asre_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Asre_CUR;                                 
			DEALLOCATE @Asre_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Asrv_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Asrv_CUR;                                 
			DEALLOCATE @Asrv_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Swks_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Swks_CUR;                                 
			DEALLOCATE @Swks_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Hswks_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Hswks_CUR;                                 
			DEALLOCATE @Hswks_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Cptb_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Cptb_CUR;                                 
			DEALLOCATE @Cptb_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Rcth_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Rcth_CUR;                                 
			DEALLOCATE @Rcth_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Pofl_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Pofl_CUR;                                 
			DEALLOCATE @Pofl_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Ensd_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Ensd_CUR;                                 
			DEALLOCATE @Ensd_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Gtst_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Gtst_CUR;                                 
			DEALLOCATE @Gtst_CUR;                            
		END
		IF CURSOR_STATUS('VARIABLE','@@Hcmem_CUR') IN (0,1) 
		BEGIN                                             
			CLOSE @Hcmem_CUR;                                 
			DEALLOCATE @Hcmem_CUR;                            
		END
		
		SET @Ac_Msg_CODE		= @Lc_StatusFailed_CODE;
		SET @Ln_Error_NUMB		= ERROR_NUMBER();
		SET @Ln_ErrorLine_NUMB	= ERROR_LINE();
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
