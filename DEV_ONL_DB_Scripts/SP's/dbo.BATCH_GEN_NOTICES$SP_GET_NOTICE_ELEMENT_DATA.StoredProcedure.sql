/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_NOTICE_ELEMENT_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_NOTICE_ELEMENT_DATA
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICES$SP_GET_NOTICE_ELEMENT_DATA gets procedure names fom NDEL_Y1 to execute the procedures dynamically
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_NOTICE_ELEMENT_DATA]
 @Ac_Notice_ID             CHAR(8),
 @Ac_ActivityMajor_CODE	   CHAR(4),
 @Ac_ActivityMinor_CODE	   CHAR(5),
 @Ac_Reason_CODE		   CHAR(2),
 @An_Barcode_NUMB		   NUMERIC(12),
 @As_Result_TEXT           VARCHAR(MAX) OUTPUT,
 @Ac_Msg_CODE              VARCHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
	BEGIN
		SET NOCOUNT ON;

		DECLARE 
		  @Ls_Sql_TEXT                         VARCHAR(1000) = '',
		  @Ls_Sqldata_TEXT                     VARCHAR (400) = '',
		  @Ls_DescriptionError_TEXT            VARCHAR(4000),
		  @Ls_Error_CODE                       VARCHAR(18),
		  @GetProc_Name_CUR                    CURSOR,
		  @Ls_Routine_TEXT                     VARCHAR(70) = 'BATCH_GEN_NOTICES$SP_GET_NOTICE_ELEMENT_DATA',
		  @Ld_High_DATE                        DATE = '12/31/9999',
		  @Ls_Errorproc_NAME                   VARCHAR(75),
		  @Ls_SQLParameterString_TEXT          NVARCHAR(MAX),
		  @Ls_SQLSubParamaterString_TEXT       NVARCHAR(MAX),
		  @Ls_ParmDefinition_TEXT              NVARCHAR(MAX),
		  @Ls_SUB_Elements_ParmDefinition_TEXT NVARCHAR(MAX),
		  @Ls_SQLProcName_TEXT                 VARCHAR(75),
		  @Ls_SQLString_TEXT                   NVARCHAR(MAX),
		  @Ls_Procedure_NAME                   VARCHAR(75),
		  @Lc_CdTypeElement_CODE               CHAR(1),
		  @Lc_ApprovalRequiredYes_INDC		   CHAR(1) = 'Y',
		  @Lc_TypeEditNoticeO_CODE			   CHAR(1) = 'O',
		  @Ln_Seq_NUMB                         VARCHAR(5),
		  @Lc_StatusFailed_CODE                CHAR(1),
		  @Lc_StatusSuccess_CODE               CHAR(1),
		  @Ln_RowCount_NUMB                    NUMERIC,
		  @Ln_Zero_NUMB                        NUMERIC,
		  @Lc_Input_INDC                       CHAR(1),
		  @As_SubElementsList_TEXT			   VARCHAR(MAX) = ' ',
		  @Ls_Element_NAME					   VARCHAR(150);

		  
  DECLARE @Ls_ErrorDesc_TEXT          				VARCHAR(4000),
          @Ld_Run_DATE                				DATETIME2(0),
          @Ls_ErrorMesg_TEXT          				VARCHAR(4000),
          @Ln_Case_IDNO               				NUMERIC(10),
          @Lc_Notice_ID               				CHAR(8),
          @Ln_MajorIntSeq_NUMB        				NUMERIC(5),
		  @Ln_MinorIntSeq_NUMB		  				NUMERIC(5),  
          @Lc_SwksWorker_ID           				CHAR(30),
          @Lc_Worker_ID               				CHAR(30),
          @Ln_MemberMci_IDNO          				NUMERIC(10),
          @Ln_CpMemberMci_IDNO        				NUMERIC(10),
          @Lc_CheckRecipient_ID       				CHAR(10),
          @Ln_MotherMci_IDNO          				NUMERIC(10),
          @Ln_FatherMci_IDNO          				NUMERIC(10),
          @Ln_CaretakerMci_IDNO       				NUMERIC(10),
          @Ln_NcpMemberMci_IDNO       				NUMERIC(10),
          @Ln_Application_IDNO        				NUMERIC(15),
          @Lc_File_ID                 				VARCHAR(15),
          @Lc_ActivityMinor_CODE      				CHAR(5),
		  @Lc_ActivityMajor_CODE      				CHAR(5),
          @Lc_Recipient_CODE          				CHAR(4),
          @Lc_Action_CODE             				CHAR(1),
          @Lc_Function_CODE           				CHAR(3),
          @Lc_Reason_CODE             				CHAR(5),
          @Lc_ReasonStatus_CODE       				CHAR(5),
          @Lc_StatusNotice_CODE       				CHAR(1),
          @Lc_Recipient_ID          				CHAR(10),
          @Ln_OrderSeq_NUMB               			NUMERIC(5) = 1,
          @Lc_TransOtherStateI_INDC   				CHAR(1) = 'I',
          @Lc_ActivityMinorNorpr_CODE				CHAR(5) ='NORPR',
          @Lc_TransOtherState_INDC    				CHAR(1),
          @Ln_TransHeader_IDNO        				NUMERIC,
          @Lc_OthpStateFips_CODE      				VARCHAR(MAX),
          @Ld_Transaction_DATE        				DATETIME2,
          @Ln_OtherParty_IDNO         				VARCHAR(10),
          @Lc_TypeAddress_CODE        				CHAR(1),

          @Ls_Err_Description_TEXT    				VARCHAR(4000),
          @Lc_InitiatingFips_ID     				CHAR(7),
          @Ln_Office_IDNO             				NUMERIC(10),
          @Ls_Screen_NAME			  				VARCHAR(10),
          @GetRequired_Element_CUR	  				CURSOR,
          @GetFormat_Element_CUR					CURSOR,
          @Ls_Element_TEXT							VARCHAR(100),
          @Ls_ElementValue_TEXT						VARCHAR(MAX),
          @Ls_Ele_Format_CODE						VARCHAR(100),
          @Ls_Format_CODE							VARCHAR(10),
          @Lc_Mask_INDC								CHAR(1),
          @Ls_FormattedResult_TEXT					VARCHAR(MAX),

          @Ls_Element_VALUE			  				VARCHAR(400),
          @ReqElementsCount_NUMB	  				NUMERIC(2) = 0,
		  @Ls_e1081desc_text		  				VARCHAR(100),
		  @Lc_Fips_CODE               				CHAR(7),
          @Lc_Job_ID                  				CHAR(7) = '',
          @Lc_Reference_ID			  				CHAR(30),
          @Ln_OthpLocation_IDNO						NUMERIC(9),
		  @Ln_ElementGroupMinRequired_NUMB			NUMERIC(2),
		  @Ln_ElementGroupMaxRequired_NUMB			NUMERIC(2),
		  @RequiredElements_CUR						CURSOR,
		  @ElementGroup_NUMB						NUMERIC(5) = 0,
		  @Ln_SelectedElementsCount_NUMB			NUMERIC(5) = 0,
		  @Ln_OptionParentSeq_NUMB					NUMERIC(5) = 0,
		  @Ln_OptionSelectedElementsCount_NUMB		NUMERIC(5) = 0,
		  @Ln_ParentElementGroupMinRequired_NUMB	NUMERIC(5) = 0,
		  @Ln_ParentElementGroupMaxRequired_NUMB	NUMERIC(5) = 0,
		  @Ln_ParentGroupSelectedElementsCount_NUMB	NUMERIC(5) = 0,
		  @Ln_ParentSelectedElementCount_NUMB		NUMERIC(5) = 0,
		  @Lc_PrintMethod_CODE						CHAR(1),
		  @Ln_TransactionEventSeq_NUMB				NUMERIC(19);
		  

		SET @Lc_StatusFailed_CODE = 'F';
		SET @Lc_StatusSuccess_CODE = 'S';
		SET @Ln_Zero_NUMB = 0;
		SET @Lc_Input_INDC = 'I';

		BEGIN TRY
			
			SET @Ls_Sql_TEXT = 'Initializing Local Variables by selecting from #NoticeElementsData_P1 in   
			BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC';      
                
     DECLARE @NoticeElementsData_T1 TABLE(
           Element_NAME  VARCHAR(150),
           Element_VALUE VARCHAR(MAX)
       ); 

	   
	   INSERT INTO @NoticeElementsData_T1
	   SELECT * FROM #NoticeElementsData_P1

	   SET @Ls_Sqldata_TEXT = 'NOTICE_ID'

	   SET @Lc_Notice_ID = (SELECT DISTINCT      
								   Element_VALUE      
                                            FROM @NoticeElementsData_T1      
							 WHERE Element_NAME = 'NOTICE_ID');
	   
	   SET @Ls_Sqldata_TEXT = 'Recipient_CODE'   

	   SET @Lc_Recipient_CODE = (SELECT DISTINCT      
										CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE      
                                                   FROM @NoticeElementsData_T1      
								  WHERE Element_NAME = 'Recipient_CODE');
	   
	   SET @Ls_Sqldata_TEXT = 'Recipient_ID'   

	   SET @Lc_Recipient_ID = (SELECT DISTINCT      
										Element_VALUE      
                                                   FROM @NoticeElementsData_T1      
								  WHERE Element_NAME = 'Recipient_ID');
	   
	   SET @Ls_Sqldata_TEXT = 'TypeAddress_CODE'   

	   SET @Lc_TypeAddress_CODE = (SELECT DISTINCT      
										  CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE      
                                                       FROM @NoticeElementsData_T1      
									WHERE Element_NAME = 'TypeAddress_CODE');
	   
	   SET @Ls_Sqldata_TEXT = 'StatusNotice_CODE'   

	   SET @Lc_StatusNotice_CODE = (SELECT DISTINCT      
										   Element_VALUE AS Element_VALUE      
                                                        FROM @NoticeElementsData_T1      
									 WHERE Element_NAME = 'StatusNotice_CODE');
	   
	   SET @Ls_Sqldata_TEXT = 'Worker_Parameter_ID'
	   
	   --13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - Start	
	   SET @Lc_Worker_ID = (SELECT DISTINCT      
								   Element_VALUE      
                                            FROM @NoticeElementsData_T1      
							 WHERE Element_NAME = 'Worker_Parameter_ID');
	   --13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - End
	   
	   SET @Ls_Sqldata_TEXT = 'GENERATE_DATE'

	   SET @Ld_Run_DATE = (SELECT DISTINCT      
								  Element_VALUE      
                                           FROM @NoticeElementsData_T1      
							WHERE Element_NAME = 'GENERATE_DATE');
	   
	   SET @Ls_Sqldata_TEXT = 'Application_IDNO'   

	   SELECT @Ln_Application_IDNO = Element_VALUE      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'Application_IDNO';

	   SET @Ls_Sqldata_TEXT = 'CASE_IDNO'

	   SET @Ln_Case_IDNO = (SELECT DISTINCT      
								   Element_VALUE      
                                            FROM @NoticeElementsData_T1      
							 WHERE Element_NAME = 'CASE_IDNO');
	   
	   SET @Ls_Sqldata_TEXT = 'File_ID'   
	   
	   SET @Lc_File_ID = (SELECT DISTINCT      
								 Element_VALUE      
                                          FROM @NoticeElementsData_T1      
						   WHERE Element_NAME = 'File_ID');
	   
	   SET @Ls_Sqldata_TEXT = 'Office_IDNO'   

	   SELECT @Ln_Office_IDNO = Element_VALUE      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'Office_IDNO';
	   
	   
	   SET @Ls_Sqldata_TEXT = 'MEMBERMCI_IDNO'                               

	   SET @Ln_MemberMci_IDNO = (SELECT DISTINCT      
										ISNULL(Element_VALUE, 0)      
                                                   FROM @NoticeElementsData_T1      
								  WHERE Element_NAME = 'MEMBERMCI_IDNO'      
								  AND (LTRIM(RTRIM(Element_Value)) != '' AND Element_VALUE IS NOT NULL));      
       
	   SET @Ls_Sqldata_TEXT = 'orderseq_numb'                                     

	   SET @Ln_OrderSeq_NUMB= (SELECT DISTINCT      
								  CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE      
                                           FROM @NoticeElementsData_T1      
							WHERE Element_NAME = 'orderseq_numb');
	   
	   
	   SET @Ls_Sqldata_TEXT = 'Cp_MemberMci_IDNO'   

	   SELECT @Ln_CpMemberMci_IDNO =  Element_VALUE      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'Cp_MemberMci_IDNO';
      
	   
	   SET @Ls_Sqldata_TEXT = 'Cp_MemberMci_IDNO for Check Recipient'   

	   SELECT @Lc_CheckRecipient_ID = CONVERT(VARCHAR(10), Element_VALUE)      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'Cp_MemberMci_IDNO';
     
	   
	   SET @Ls_Sqldata_TEXT = 'Ncp_MemberMci_IDNO'   

	   SELECT @Ln_NcpMemberMci_IDNO = Element_VALUE      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'Ncp_MemberMci_IDNO';
	   

	   SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE';

	   SET @Lc_ActivityMajor_CODE = (SELECT DISTINCT      
										  CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE      
                                                       FROM @NoticeElementsData_T1      
									WHERE Element_NAME = 'ActivityMajor_CODE');
	   
	   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE';

	   SET @Lc_ActivityMinor_CODE = (SELECT DISTINCT      
										  CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE      
                                                       FROM @NoticeElementsData_T1      
									WHERE Element_NAME = 'ActivityMinor_CODE');
	   
	   SET @Ls_Sqldata_TEXT = 'ReasonStatus_CODE';

	   SELECT @Lc_ReasonStatus_CODE = Element_VALUE      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'ReasonStatus_CODE';
	   
	   SET @Ls_Sqldata_TEXT = 'MajorInt_SEQ';

	   SET @Ln_MajorIntSeq_NUMB = (SELECT DISTINCT      
										  CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE      
                                                       FROM @NoticeElementsData_T1      
									WHERE Element_NAME = 'MajorIntSeq_NUMB');
    
	  SET @Ls_Sqldata_TEXT = 'MinorInt_SEQ';

	  SET @Ln_MinorIntSeq_NUMB = (SELECT DISTINCT        
										  CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE        
                                                       FROM @NoticeElementsData_T1        
									WHERE Element_NAME = 'MinorIntSeq_NUMB');
	   
     
	   SET @Ls_Sqldata_TEXT = 'OTHERPARTY_IDNO';

	   SET @Ln_OtherParty_IDNO = (SELECT DISTINCT      
										 Element_VALUE      
                                                      FROM @NoticeElementsData_T1      
								   WHERE Element_NAME = 'OTHERPARTY_IDNO');
	   
	   
	   SET @Ls_Sqldata_TEXT = 'REFERENCE_ID';

	   SELECT @Lc_Reference_ID = Element_VALUE
              FROM @NoticeElementsData_T1
		 WHERE Element_NAME = 'REFERENCE_ID';
     
	   
	   SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO'   

	   SET @Ln_TransHeader_IDNO = (SELECT DISTINCT      
										  Element_VALUE AS Element_VALUE      
                                                       FROM @NoticeElementsData_T1      
									WHERE Element_NAME = 'TransHeader_IDNO');      
       

	   SET @Ls_Sqldata_TEXT = 'TransOtherState_INDC'   

	   SET @Lc_TransOtherState_INDC = (SELECT DISTINCT      
											  CONVERT(VARCHAR(5), Element_VALUE) AS Element_VALUE      
                                                             FROM @NoticeElementsData_T1      
										WHERE Element_NAME = 'TransOtherState_INDC');
	   
	   
	   SET @Ls_Sqldata_TEXT = 'Transaction_DATE';

	   SET @Ld_Transaction_DATE = (SELECT DISTINCT      
										  CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE      
                                                       FROM @NoticeElementsData_T1      
									WHERE Element_NAME = 'Transaction_DATE');
	   
	   SET @Ls_Sqldata_TEXT = 'MOTHERMCI_IDNO'   

	   SET @Ln_MotherMci_IDNO = (SELECT DISTINCT      
										Element_VALUE AS Element_VALUE      
                                                   FROM @NoticeElementsData_T1      
								  WHERE Element_NAME = 'MOTHERMCI_IDNO')      
     
	   SET @Ls_Sqldata_TEXT = 'FATHERMCI_IDNO';

	   SET @Ln_FatherMci_IDNO = (SELECT DISTINCT      
										Element_VALUE AS Element_VALUE      
                                                            FROM @NoticeElementsData_T1      
								  WHERE Element_NAME = 'FATHERMCI_IDNO');
     
	   
	   SET @Ls_Sqldata_TEXT = 'CARETAKERMCI_IDNO';

	   SET @Ln_CaretakerMci_IDNO = (SELECT DISTINCT      
										Element_VALUE AS Element_VALUE      
                                                            FROM @NoticeElementsData_T1      
								  WHERE Element_NAME = 'CARETAKERMCI_IDNO');
	   

	   SET @Ls_Sqldata_TEXT = 'OthpStateFips_CODE';

	   IF @Lc_Notice_ID NOT IN ('INT-10', 'INT-11', 'INT-12')
		BEGIN
		   SET @Lc_OthpStateFips_CODE = (SELECT DISTINCT      
												CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE      
                                                               FROM @NoticeElementsData_T1      
										  WHERE Element_NAME = 'OthpStateFips_CODE');
		END
	   ELSE
		BEGIN
			SET @Lc_OthpStateFips_CODE = (SELECT DISTINCT      
												CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE      
                                                               FROM @NoticeElementsData_T1      
										  WHERE Element_NAME = 'IVDOutOfStateFips_CODE');
		END
	   
	   
	   SET @Ls_Sqldata_TEXT = 'FUNCTION_CODE';

	   SELECT @Lc_Function_CODE = Element_VALUE      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'FUNCTION_CODE';
	    
	   
	   SET @Ls_Sqldata_TEXT = 'ACTION_CODE';

	   SELECT @Lc_Action_CODE = Element_VALUE      
           FROM @NoticeElementsData_T1      
	    WHERE Element_NAME = 'ACTION_CODE';
     
	   
	   SET @Ls_Sqldata_TEXT = 'REASON_CODE';

	   SELECT @Lc_Reason_CODE = Element_VALUE      
           FROM @NoticeElementsData_T1      
	    WHERE Element_NAME = 'REASON_CODE';
     
       SET @Ls_Sqldata_TEXT = 'FROM_INITIATE_ID_FIPS'   

	   SELECT @Lc_InitiatingFips_ID = Element_VALUE      
             FROM @NoticeElementsData_T1      
		WHERE Element_NAME = 'FROM_INITIATE_ID_FIPS'      
     
	   
	   SET @Ls_Sqldata_TEXT = 'Swks_Worker_ID';

	   SET @Lc_SwksWorker_ID = (SELECT DISTINCT      
										 Element_VALUE AS Element_VALUE      
                                                  FROM @NoticeElementsData_T1      
								 WHERE Element_NAME = 'Swks_Worker_ID');
	   
	   
	   SET @Ls_Sqldata_TEXT = 'Location_IDNO';
	   
	   SELECT @Ln_OthpLocation_IDNO = Element_VALUE
           FROM @NoticeElementsData_T1
	    WHERE Element_NAME = 'Location_IDNO';
	   
    
	   SELECT @Lc_Fips_CODE = IssuingOrderFips_CODE
         FROM Sord_y1 
        WHERE Case_IDNO = @Ln_Case_IDNO
          AND EndValidity_DATE = @Ld_High_DATE
          AND OrderSeq_NUMB = @Ln_OrderSeq_NUMB;

	   SELECT @Lc_Job_ID = Element_Value     
         FROM @NoticeElementsData_T1
        WHERE Element_Name = 'Job_ID';
	   


	   
	   SET @Ls_Sqldata_TEXT = 'PrintMethod_CODE';
	   
	   SELECT @Lc_PrintMethod_CODE = Element_VALUE
           FROM @NoticeElementsData_T1
	    WHERE Element_NAME = 'PrintMethod_CODE';

	   
	   SET @Ls_Sqldata_TEXT = 'TransactionEventSeq_NUMB';
	   
	   SELECT @Ln_TransactionEventSeq_NUMB = Element_VALUE
           FROM @NoticeElementsData_T1
          WHERE Element_NAME = 'TransactionEventSeq_NUMB';
	   
	   SET @Ac_Msg_CODE = '';


			SET @As_Result_TEXT = '';
			
			IF @An_Barcode_NUMB = 0 OR @An_Barcode_NUMB IS NULL
				BEGIN
					SET @GetProc_Name_CUR = CURSOR FOR 
							   SELECT Element_NAME,
									  Procedure_NAME,
									  TypeElement_CODE,
									  Seq_NUMB
								 FROM NDEL_Y1 n
								WHERE Notice_ID = @Ac_Notice_ID
								  AND Procedure_NAME != ''
								  AND Input_code = 'O'
								  AND Seq_Numb = ( SELECT TOP 1 Seq_Numb
													 FROM NDEL_Y1 i
													WHERE n.Notice_ID = i.Notice_ID
													  AND n.Procedure_Name = i.Procedure_Name
													  And Input_code = 'O')
							 ORDER BY seq_numb;
				END
			ELSE IF @An_Barcode_NUMB != 0 AND @An_Barcode_NUMB IS NOT NULL
				BEGIN
					SET @GetProc_Name_CUR = CURSOR FOR 
							SELECT DISTINCT '' AS Element_NAME,
								   Procedure_NAME,
								   'S' AS TypeElement_CODE,
								   0 AS Seq_NUMB
							  FROM RARE_Y1
							 WHERE ActivityMajor_CODE = @Ac_ActivityMajor_CODE
							   AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
							   AND Reason_CODe = @Ac_Reason_CODE
							   AND Notice_ID = @Ac_Notice_ID
							   AND Procedure_NAME != ''
							   AND Required_INDC = 'Y'
							 UNION
							 SELECT Element_NAME,
									Procedure_NAME,
									TypeElement_CODE,
									Seq_NUMB
							   FROM NDEL_Y1 n
							  WHERE Notice_ID = @Ac_Notice_ID
							    AND Procedure_NAME != ''
							    AND Input_code = 'O'
							    AND TypeElement_CODE = 'M'
							    AND Seq_Numb = ( SELECT TOP 1 Seq_Numb
												   FROM NDEL_Y1 i
												  WHERE n.Notice_ID = i.Notice_ID
												    AND n.Procedure_Name = i.Procedure_Name
												    And Input_code = 'O')
							UNION
							SELECT Element_NAME,
									  Procedure_NAME,
									  TypeElement_CODE,
									  Seq_NUMB
								 FROM NDEL_Y1 n
								WHERE Notice_ID = @Ac_Notice_ID
								  AND (Procedure_NAME = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_CP_ADDRESS'
								        OR Procedure_NAME = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_NCP_ADDRESS'
								        OR Procedure_NAME =  'BATCH_GEN_NOTICE_CM$SP_GET_CP_MAILING_ADDRESS'
								        OR (EXISTS(SELECT 1 FROM 
															#NoticeElementsData_P1 a 
															WHERE a.Element_NAME = n.Element_NAME 
															AND a.Element_VALUE = ' '
															AND a.Element_NAME = 'sch_cnty_selection_code')))
								        
								  AND Input_code = 'O'
								  AND Seq_Numb = ( SELECT TOP 1 Seq_Numb
													 FROM NDEL_Y1 i
													WHERE n.Notice_ID = i.Notice_ID
													  AND n.Procedure_Name = i.Procedure_Name
													  And Input_code = 'O')	
								 --13458 -  ENF-18 Address issue during batch generation Fix -Start
								 AND @Ac_ActivityMinor_CODE <> @Lc_ActivityMinorNorpr_CODE														  				    
								 --13458 -  ENF-18 Address issue during batch generation Fix -End
								  --13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -Start
								 AND NOT EXISTS(SELECT 1 
                                                        FROM AFMS_Y1 f 
                                                       WHERE f.ApprovalRequired_INDC = @Lc_ApprovalRequiredYes_INDC 
                                                         AND f.TypeEditNotice_CODE != @Lc_TypeEditNoticeO_CODE
                                                         AND f.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                                                         AND f.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                                                         AND f.Reason_CODE = @Ac_Reason_CODE
                                                         AND f.EndValidity_DATE = @Ld_High_DATE)
								ORDER BY seq_numb;
							 --13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -End
				END
			
			OPEN @GetProc_Name_CUR

			FETCH NEXT FROM @GetProc_Name_CUR INTO @Ls_Element_NAME, @Ls_Procedure_NAME, @Lc_CdTypeElement_CODE, @Ln_Seq_NUMB
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					
					SET @Ls_SQLProcName_TEXT = @Ls_Procedure_NAME
					
					IF @Ls_SQLProcName_TEXT != 'BATCH_GEN_NOTICES$SP_GET_BATCH_INPUTS'
						BEGIN
							SELECT @Ln_RowCount_NUMB = COUNT(1)
							  FROM sys.objects
							 WHERE name = @Ls_SQLProcName_TEXT;
						END
					
					IF @Ln_RowCount_NUMB = 0
						BEGIN
							SET @As_DescriptionError_TEXT = 'The Procedure ' + @Ls_SQLProcName_TEXT + ' Does Not Exist in the database';
							
							RAISERROR(50001,16,1);
						END
					
					IF @Lc_CdTypeElement_CODE = 'S'
						BEGIN
							
							SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC'
							SET @Ls_Sqldata_TEXT = ' Procedure Name : ' + ISNULL(@Ls_Procedure_NAME, '');

							IF @Ls_SQLProcName_TEXT != 'BATCH_GEN_NOTICES$SP_GET_BATCH_INPUTS'
								BEGIN
									SELECT @Ln_RowCount_NUMB = COUNT(1)
									  FROM pprm_y1
									 WHERE Procedure_NAME = @Ls_SQLProcName_TEXT;
								END
							
							IF @Ln_RowCount_NUMB = 0
								BEGIN
									SET @As_DescriptionError_TEXT = 'The Procedure ' + @Ls_SQLProcName_TEXT + ' Does Not Have Parameters Set in PPRM_Y1';
									
									RAISERROR(50001,16,1);
								END
							

   ---- frames Parameter sting for dynamic sql
   SET @Ls_SQLParameterString_TEXT = (SELECT STUFF((SELECT ',' + Parameter_NAME + CASE
                                                                                   WHEN Output_INDC = 'Y'
                                                                                    THEN ' output '
                                                                                   ELSE ''
                                                                                  END
                                                      FROM PPRM_Y1
                                                     WHERE Procedure_NAME = @Ls_SQLProcName_TEXT
                                                     ORDER BY ParameterPosition_NUMB
                                                    FOR XML PATH('')), 1, 1, ''));
   --frames Parameter definition for dynamic sql
   
   SET @Ls_ParmDefinition_TEXT = 
						'
						@Ac_Notice_ID					CHAR(8),
						@Ac_Recipient_CODE				CHAR(4),
						@Ac_Recipient_ID				VARCHAR(10), --NUMERIC(10),
						@Ac_TypeAddress_CODE			CHAR(1),
						@Ac_StatusNotice_CODE			CHAR(1),
						@Ac_Worker_ID					CHAR(30),
						@Ad_Run_DATE					DATE,
						@An_Application_IDNO			NUMERIC(15),
						@An_Case_IDNO					NUMERIC(6),
						@Ac_File_ID						CHAR(10),
						@An_Office_IDNO					NUMERIC(3),
						@An_MemberMci_IDNO				NUMERIC(10),
						@An_OrderSeq_NUMB				NUMERIC(2),
						@An_CpMemberMci_IDNO			NUMERIC(10),
						@Ac_CheckRecipient_ID			CHAR(10),
						@An_NcpMemberMci_IDNO			NUMERIC(10),
						@Ac_ActivityMajor_CODE			CHAR(4), 
						@Ac_ActivityMinor_CODE			CHAR(5),
						@Ac_ReasonStatus_CODE			CHAR(2),
						@An_MajorIntSeq_NUMB			NUMERIC(5),
						@An_MinorIntSeq_NUMB			NUMERIC(5),
						@An_OtherParty_IDNO				NUMERIC(10),
						@Ac_Reference_ID				CHAR(30),
						@An_TransHeader_IDNO			NUMERIC(12),
						@Ac_TransOtherState_INDC		CHAR(1),
						@Ad_Transaction_DATE			DATE,
						@An_MotherMci_IDNO				NUMERIC(10),
						@An_FatherMci_IDNO				NUMERIC(10),
						@An_CaretakerMci_IDNO			NUMERIC(10),
						@Ac_IVDOutOfStateFips_CODE		CHAR(2),
						@Ac_Function_CODE				CHAR(3),
						@Ac_Action_CODE					CHAR(1),
						@Ac_Reason_CODE					CHAR(5),
						@Ac_Role_ID						CHAR(5),
						@Ac_InitiatingFips_ID			CHAR(7),
						@Ac_SwksWorker_ID				CHAR(30),
						@An_OthpLocation_IDNO			NUMERIC(9),
						@As_Prefix_TEXT					VARCHAR(100),
						@Ac_Fips_CODE					CHAR(7),
						@Ac_Job_ID						CHAR(7),
						@Ac_PrintMethod_CODE			CHAR(1),
						@An_TransactionEventSeq_NUMB	NUMERIC(19),
						--@Ac_Office_CODE				VARCHAR(3),
						--@As_Worker_IDNO				CHAR(30),	 
						--@An_Order_Seq					NUMERIC(5),
						--@Ac_OthpStateFips_CODE		VARCHAR(7),
						--@Ac_CnetTransaction_INDC		CHAR(1),
						--@An_InitiatingFips_IDNO		VARCHAR(7),
						@Ac_Msg_CODE					VARCHAR(5) OUTPUT,
						@As_DescriptionError_TEXT		VARCHAR(4000) OUTPUT'
   SET @Ls_SQLString_TEXT = 'EXEC ' + @Ls_SQLProcName_TEXT + ' ' + @Ls_SQLParameterString_TEXT;
   SET @Ls_Sql_TEXT = 'Execute procedure dynamically';
   SET @Ls_Sqldata_TEXT = ' Proc_NAME : ' + ISNULL(@Ls_SQLProcName_TEXT, '');
	
   EXECUTE SP_EXECUTESQL
				@Ls_SQLString_TEXT,
				@Ls_ParmDefinition_TEXT,
				@Ac_Notice_ID					= @Lc_Notice_ID,
				@Ac_Recipient_CODE				= @Lc_Recipient_CODE,
				@Ac_Recipient_ID				= @Lc_Recipient_ID,
				@Ac_TypeAddress_CODE			= @Lc_TypeAddress_CODE,
				@Ac_StatusNotice_CODE			= @Lc_StatusNotice_CODE,
				@Ac_Worker_ID					= @Lc_Worker_ID,
				@Ad_Run_DATE					= @Ld_Run_DATE,
				@An_Application_IDNO			= @Ln_Application_IDNO,
				@An_Case_IDNO					= @Ln_Case_IDNO,
				@Ac_File_ID						= @Lc_File_ID,
				@An_Office_IDNO					= @Ln_Office_IDNO,
				@An_MemberMci_IDNO				= @Ln_MemberMci_IDNO,
				@An_OrderSeq_NUMB				= @Ln_OrderSeq_NUMB,
				@An_CpMemberMci_IDNO			= @Ln_CpMemberMci_IDNO,
				@Ac_CheckRecipient_ID			= @Lc_CheckRecipient_ID,
				@An_NcpMemberMci_IDNO			= @Ln_NcpMemberMci_IDNO,
				@Ac_ActivityMajor_CODE			= @Lc_ActivityMajor_CODE,
				@Ac_ActivityMinor_CODE			= @Lc_ActivityMinor_CODE,
				@Ac_ReasonStatus_CODE			= @Lc_ReasonStatus_CODE,
				@An_MajorIntSeq_NUMB			= @Ln_MajorIntSeq_NUMB,
				@An_MinorIntSeq_NUMB			= @Ln_MinorIntSeq_NUMB,
				@An_OtherParty_IDNO				= @Ln_OtherParty_IDNO,
				@Ac_Reference_ID				= @Lc_Reference_ID, 
				@An_TransHeader_IDNO			= @Ln_TransHeader_IDNO,
				@Ac_TransOtherState_INDC		= @Lc_TransOtherState_INDC,
				@Ad_Transaction_DATE			= @Ld_Transaction_DATE,
				@An_MotherMci_IDNO				= @Ln_MotherMci_IDNO,
				@An_FatherMci_IDNO				= @Ln_FatherMci_IDNO,
				@An_CaretakerMci_IDNO			= @Ln_CaretakerMci_IDNO,
				@Ac_IVDOutOfStateFips_CODE		= @Lc_OthpStateFips_CODE,
				@Ac_Function_CODE				= @Lc_Function_CODE,
				@Ac_Action_CODE					= @Lc_Action_CODE,
				@Ac_Reason_CODE					= @Lc_Reason_CODE,
				@Ac_Role_ID						= '',
				@Ac_InitiatingFips_ID			= @Lc_InitiatingFips_ID,
				@Ac_SwksWorker_ID				= @Lc_SwksWorker_ID,
				@An_OthpLocation_IDNO			= @Ln_OthpLocation_IDNO,
				@As_Prefix_TEXT					= '',
				@Ac_Fips_CODE					= @Lc_Fips_CODE,
                @Ac_Job_ID						= @Lc_Job_ID,
				@Ac_PrintMethod_CODE			= @Lc_PrintMethod_CODE,
				@An_TransactionEventSeq_NUMB	= @Ln_TransactionEventSeq_NUMB,
				@Ac_Msg_CODE					= @Ac_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT		= @As_DescriptionError_TEXT OUTPUT;


				
                       EXEC BATCH_GEN_NOTICES$SP_EXECUTE_PROC_DYNAMIC
                       @As_Proc_NAME             = @Ls_SQLProcName_TEXT,
                       @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;               

							
							IF @Ac_Msg_CODE = 'F'
								BEGIN
									RETURN;
								END
						END
					 ELSE IF @Lc_CdTypeElement_CODE = 'M'
						BEGIN
						   
						   SELECT @Ln_RowCount_NUMB = COUNT(1)
							 FROM #NoticeElementsData_P1
							WHERE Element_NAME = @Ls_Element_NAME
							  AND Element_VALUE != '' AND Element_VALUE IS NOT NULL
							  AND Element_VALUE LIKE '%<row>%';
						   
						   IF (		@Ls_SQLProcName_TEXT = 'BATCH_GEN_NOTICES$SP_GET_BATCH_INPUTS'
								OR
									@Ln_RowCount_NUMB > 0
							  )
								BEGIN
									SELECT @As_SubElementsList_TEXT = Element_VALUE
									  FROM #NoticeElementsData_P1
									 WHERE Element_NAME = @Ls_Element_NAME;
								END
						   ELSE
								BEGIN
								   SET @Ls_SQLProcName_TEXT = 'BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS'
								   SET @Ls_SQLString_TEXT = 'EXECUTING ' + @Ls_Procedure_NAME;
							       
								   EXEC BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS
													@As_Proc_NAME             = @Ls_Procedure_NAME,
													@An_Seq_NUMB              = @Ln_Seq_NUMB,
													@As_Result_TEXT           = @As_SubElementsList_TEXT OUTPUT, --@As_Result_TEXT OUTPUT,
													@Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
													@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
									
									IF @Ac_Msg_CODE = 'F'
										BEGIN
											RETURN;
										END
										SET @As_SubElementsList_TEXT = REPLACE(@As_SubElementsList_TEXT, '&', '&amp;') 
								END
							
							SET @As_Result_TEXT = @As_SubElementsList_TEXT + ISNULL(@As_Result_TEXT, '')
							
						END
						
					FETCH NEXT FROM @GetProc_Name_CUR INTO @Ls_Element_NAME, @Ls_Procedure_NAME, @Lc_CdTypeElement_CODE, @Ln_Seq_NUMB
				END
			
			CLOSE @GetProc_Name_CUR

			DEALLOCATE @GetProc_Name_CUR;
			
			     IF EXISTS (SELECT 1 
								FROM #NoticeElementsData_P1 a
								WHERE 
									a.Element_NAME ='sch_cnty_selection_code'
									AND a.Element_VALUE = ' ')
					BEGIN
						DELETE 
							FROM #NoticeElementsData_P1 
						WHERE 
							Element_NAME ='sch_cnty_selection_code'
							AND Element_VALUE = ' '
							AND ((SELECT COUNT(1)
									FROM #NoticeElementsData_P1 a
									WHERE 
										a.Element_NAME ='sch_cnty_selection_code') > 1)
					END
			
			SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
			
  END TRY

  BEGIN CATCH
 
   IF CURSOR_STATUS ('local', '@GetProc_Name_CUR') IN (0, 1)
    BEGIN
     CLOSE @GetProc_Name_CUR
     DEALLOCATE @GetProc_Name_CUR
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + @Ls_Routine_TEXT + ' Procedure' 
								  + '. Error Desc - ' + @As_DescriptionError_TEXT 
								  + '. Error Execute Location - ' + @ls_sql_TEXT 
								  + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE (), '') + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error Execute Location - ' + @ls_sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END
   SET @As_DescriptionError_TEXT=@Ls_DescriptionError_TEXT;
   

  END CATCH
 END


GO
