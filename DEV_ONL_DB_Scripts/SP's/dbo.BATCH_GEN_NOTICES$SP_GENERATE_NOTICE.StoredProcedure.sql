/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GENERATE_NOTICE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
Programmer Name	:	IMP Team.
Description		:	This procedure is used to generate notice XML
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GENERATE_NOTICE]
	 @An_Case_IDNO                NUMERIC(6),
	 @Ac_Notice_ID                CHAR(8),
	 @Ac_Worker_ID                CHAR(30)		= ' ',
	 @Ac_SignedOnWorker_ID        CHAR(30)		= NULL,
	 @An_MemberMci_IDNO           NUMERIC(10)	= 0,
	 @An_OthpSource_IDNO          NUMERIC(10)	= 0,
	 @Ac_Reference_ID             CHAR(30)		= ' ',
	 @An_TransHeader_IDNO         NUMERIC(12)	= 0,
	 @Ad_Generate_DATE            DATETIME2,
	 @An_Barcode_NUMB             NUMERIC(9)	= 0,
	 @Ac_Recipient_ID             CHAR(10)		= '',
	 @Ac_Recipient_CODE           VARCHAR(4)	= ' ',
	 @Ac_ActivityMajor_CODE       CHAR(4),
	 @Ac_ActivityMinor_CODE       CHAR(5),
	 @Ac_ReasonStatus_CODE        CHAR(2)		= ' ',
	 @An_MajorIntSeq_NUMB         NUMERIC(5)	= 0,
	 @An_MinorIntSeq_NUMB         NUMERIC(5)	= 0,
	 @An_Schedule_NUMB            NUMERIC(10)	= NULL,
	 @Ad_Schedule_DATE            DATE			= NULL,
	 @Ad_BeginSch_DTTM            DATETIME2,
	 @An_OthpLocation_IDNO        NUMERIC(9),
	 @Ac_ScheduleWorker_ID        CHAR(30),
	 @As_ScheduleListMemberMci_ID VARCHAR(100),
	 @Ac_PrintMethod_CODE         CHAR(1)		= ' ',
	 @Ac_TypeService_CODE         CHAR(1)		= ' ',
	 @Ac_TypeAddress_CODE         CHAR(1)		= ' ',
	 @An_OrderSeq_NUMB            NUMERIC(5)	= 0,
	 @As_XmlInput_TEXT            VARCHAR(MAX),
	 @Ac_Job_ID                   CHAR(7)		= ' ',
	 @An_TransactionEventSeq_NUMB NUMERIC(19)	= 0,
	 @As_XmlOut_TEXT              VARCHAR(MAX)	OUTPUT,
	 @An_BarcodeOut_NUMB          NUMERIC(9)	OUTPUT,
	 @Ac_Msg_CODE                 VARCHAR (5)	OUTPUT,
	 @As_DescriptionError_TEXT    VARCHAR(MAX)	OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;
  	
  CREATE TABLE #NoticeElementsData_P1
   (
     Element_NAME  VARCHAR(150),
     Element_VALUE VARCHAR(MAX)
   );

  CREATE NONCLUSTERED INDEX nedt_INDX
  ON #NoticeElementsData_P1 (Element_NAME);

 
  CREATE TABLE #NoticeErrors_P1
   (
       Element_NAME VARCHAR(150),
       Error_CODE	VARCHAR(18),
       Error_DESC	VARCHAR(300)
   );

  DECLARE 
	@Ln_seq_barcode_NUMB         	NUMERIC(9),
	@Ln_Version_NUMB             	NUMERIC(5),
	@Ln_BarcodeOut_NUMB          	NUMERIC(19),
	@Ln_Record_Count_NUMB        	NUMERIC(4),
	@Lc_StatusSuccess_CODE       	CHAR,
	@Lc_StatusFailed_CODE        	CHAR,
	@Ac_ndel_Input_INDC          	CHAR,
	@Lc_PrintMethod_Local_TEXT   	CHAR(1) = 'L',
	@Lc_PrintMethod_Central_TEXT 	CHAR(1) = 'C',
	@Lc_PrintMethod_View_TEXT    	CHAR(1) = 'V',
	@Lc_PrintMethod_Electronic_TEXT	CHAR(1) = 'E',
	@Lc_CaseStatusOpen_CODE      	CHAR(1) = 'O',
	@Lc_ApprovalRequiredYes_INDC	CHAR(1) = 'Y',
    @Lc_TypeEditNoticeO_CODE		CHAR(1) = 'O',
	@Lc_TypeElement_CODE         	CHAR(1),
	@Lc_StatusNotice_CODE        	CHAR(1),
	@Lc_Mask_INDC					CHAR(1),
	@Lc_File_ID                  	CHAR(10),
	@Lc_Worker_ID				 	CHAR(30),
	@Lc_Worker_Parameter_ID			CHAR(30),
	@Ld_High_DATE                	DATETIME2,
	@Ls_InsertInput_CUR          	CURSOR,
	@GetFormat_Element_CUR			CURSOR,
	@Ls_Xml_Value                   VARCHAR(50), 
	@Ls_Proc_NAME                	VARCHAR(75),
	@Ls_InputParam_TEXT          	VARCHAR(250),
	@Ld_Request_DTTM             	VARCHAR(50),
	@Ld_Update_DTTM              	VARCHAR(50),
	@Ln_CpMci_IDNO				 	NUMERIC(10),
	@Ln_NcpMci_IDNO				 	NUMERIC(10),
	@Ln_Application_IDNO		 	NUMERIC(15),
	@Ln_ParentSeq_NUMB			 	NUMERIC(5) = 0,
	@Ls_Routine_TEXT             	VARCHAR(60) = 'BATCH_GEN_NOTICES$SP_GENERATE_NOTICE',
	@Ls_Sql_TEXT                 	VARCHAR(1000) = ' ',
	@Ls_Element_NAME				VARCHAR(150),
	@Ls_Procedure_NAME				VARCHAR(250),
    @Ls_Element_VALUE			  	VARCHAR(400),
    @Ls_Format_CODE					VARCHAR(10),
    @Ls_Ele_Format_CODE				VARCHAR(100),
	@Ls_Element_TEXT				VARCHAR(100),
	@Ls_Sqldata_TEXT             	VARCHAR(MAX) = ' ',
	@Ls_ElementValue_TEXT			VARCHAR(MAX),
	@Ls_Err_Description_TEXT     	VARCHAR(MAX),
	@Ls_FormattedResult_TEXT		VARCHAR(MAX),
	@Ls_MaskedNoticeXml_TEXT		VARCHAR(MAX),
	@Ls_result_TEXT              	VARCHAR(MAX),
	@Ls_xml_Result_TEXT          	VARCHAR(MAX),
	@Ls_SqlString_TEXT           	NVARCHAR(MAX),
	@Ls_SqlParameterString_TEXT  	NVARCHAR(MAX),
	@Ls_parmDefinition_TEXT      	NVARCHAR(MAX);
	
	DECLARE		
		@Lx_ModifyXml_XML				XML,	
		@Ls_ExecuteQuery_TEXT			NVARCHAR(4000) = '',
		@LS_RECIPIENT_ATTN_ADDR         VARCHAR(100)= '',
		@LS_RECIPIENT_BIRTH_DATE        VARCHAR(100)= '',
		@LS_RECIPIENT_CITY_ADDR         VARCHAR(100)= '',
		@LS_RECIPIENT_COUNTRY_ADDR      VARCHAR(100)= '',
		@LS_RECIPIENT_HOMEPHONE_NUMB    VARCHAR(100)= '',
		@LS_RECIPIENT_LINE1_ADDR        VARCHAR(100)= '',
		@LS_RECIPIENT_LINE2_ADDR        VARCHAR(100)= '',
		@LS_RECIPIENT_MEMBERMCI_IDNO    VARCHAR(100)= '',
		@LS_RECIPIENT_NAME              VARCHAR(100)= '',
		@LS_RECIPIENT_SSN_NUMB          VARCHAR(100)= '',
		@LS_RECIPIENT_STATE_ADDR        VARCHAR(100)= '',
		@LS_RECIPIENT_ZIP_ADDR          VARCHAR(100)= '',
		@Ln_RecipentCount_NUMB	 		NUMERIC(5) = 0,
		@Lc_XmlModifiedFlag_INDC		CHAR(1) = 'N',
		@Lc_XmlExistsFlag_INDC			CHAR(1) = 'N',
		@Lc_TypeAddrZ_CODE				CHAR(1) = 'Z',
		@Lc_TypeAddrV_CODE				CHAR(1) = 'V',
		@Lc_RecipientSi_CODE			CHAR(2)	= 'SI',	
		@Lc_RecipientOe_CODE			CHAR(2)	= 'OE',
		@Lc_ActivityMajorCpls_CODE      CHAR(4) = 'CPLS',
		@Lc_ActivityMinorNorpr_CODE		CHAR(5) = 'NORPR',
		@Lc_Leg191fNotice_ID			CHAR(8) = 'LEG-191F',
		@Lc_Fin07Notice_ID              CHAR(6)	= 'FIN-07',
		@Lc_Fin09Notice_ID              CHAR(6)	= 'FIN-09',
		@Lc_Fin10Notice_ID              CHAR(6)	= 'FIN-10',
		@Lc_Fin11Notice_ID              CHAR(6)	= 'FIN-11',
		@Lc_Fin14Notice_ID              CHAR(6)	= 'FIN-14',
		@Lc_Fin26Notice_ID              CHAR(6)	= 'FIN-26',
		@Lc_Fin27Notice_ID              CHAR(6)	= 'FIN-27',
		@Lc_ENF01Notice_ID              CHAR(6)	= 'ENF-01',
		@Lc_NoticeEnf03_ID			    CHAR(8)	= 'ENF-03',
		@Lc_ENF14Notice_ID              CHAR(6)	= 'ENF-14';

  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';
  SET @Ld_High_DATE = '12-31-9999';
  SET @Ac_ndel_Input_INDC = 'I';
   
  BEGIN TRY
	
	-- IF INT-03 don't validate Case Id when notice is generated from ICOR assist and discovery (2nd) screen function
	IF @Ac_Notice_ID NOT IN ('INT-03', 'CSI-13') OR @An_Case_IDNO NOT IN (0, -1)
	   BEGIN
			IF NOT EXISTS (SELECT 1 
						  FROM CASE_Y1 
						 WHERE Case_IDNO = @An_Case_IDNO)
			BEGIN
			
				SET @As_DescriptionError_TEXT = 'Invalid Case IDNO ';
				SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE ;
				RETURN;
			END
		END
 
	IF ISNUMERIC(@Ac_Notice_ID) = 0
		BEGIN
			/* Start of Notice Esists Check */
			IF NOT EXISTS (SELECT 1 FROM NREF_Y1 WHERE Notice_ID = @Ac_Notice_ID AND EndValidity_DATE = @Ld_High_DATE) 
				BEGIN
				
					SET @As_DescriptionError_TEXT = 'Notice not found in NREF_Y1';
					SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE ;
					RETURN;
				END

			IF NOT EXISTS (SELECT Notice_ID FROM NDEL_Y1 WHERE Notice_ID = @Ac_Notice_ID) 
				BEGIN
				
					SET @As_DescriptionError_TEXT = 'Notice not found in NDEL_Y1';
					SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE ;
					RETURN;
				END
			/* End of Notice Esists Check */
		  
			SET @Ln_Version_NUMB = (SELECT MAX(noticeVersion_NUMB)
									  FROM NVER_Y1
									 WHERE NOTICE_ID = @Ac_Notice_ID
									   AND End_DATE = CONVERT(VARCHAR(10), @Ld_High_DATE, 101));

		   IF CONVERT(VARCHAR(4), @Ln_Version_NUMB) = ''
			BEGIN
				SET @As_DescriptionError_TEXT = 'Notice Version not found in NVER_Y1';
				SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE ;
				RETURN;
			END;
		   --13383 - CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix -Start
		   IF ( (@Ac_Notice_ID LIKE 'ENF-%' AND @Ac_ActivityMajor_CODE != @Lc_ActivityMajorCpls_CODE) OR ( @Ac_Notice_ID LIKE 'FIN-%' AND @Ac_Notice_ID NOT IN(@Lc_Fin09Notice_ID,@Lc_Fin10Notice_ID,@Lc_Fin11Notice_ID,@Lc_Fin14Notice_ID,@Lc_Fin26Notice_ID,@Lc_Fin27Notice_ID)))
		   --13383 - CR0379 Capias License Suspension on Non-Ordered Cases 20140410 Fix -End
			BEGIN
				SELECT @Ln_Record_Count_NUMB = COUNT(1)
				  FROM SORD_Y1
				 WHERE Case_IDNO = @An_Case_IDNO
				   AND TypeOrder_CODE != 'V'
				   /*Fin-07 annual notice will be generated after sord ended also*/
				   AND((LTRIM(RTRIM(@Ac_Notice_ID)) = @Lc_Fin07Notice_ID) 						
						OR (LTRIM(RTRIM(@Ac_Notice_ID)) <> @Lc_Fin07Notice_ID AND @Ad_Generate_DATE BETWEEN OrderEffective_DATE AND OrderEnd_DATE)
						OR (@Ac_Notice_ID = @Lc_ENF14Notice_ID AND OrderEnd_DATE > @Ad_Generate_DATE))
				   AND EndValidity_DATE = @Ld_High_DATE;
				
				IF @Ln_Record_Count_NUMB = 0
					BEGIN
						SET @Ac_Msg_CODE = 'E0077';
						SET @As_DescriptionError_TEXT = 'RECORD NOT FOUND IN SORD_Y1';
						
						RETURN;
					END
			END
		END
	ELSE
		BEGIN
			SET @Ln_Version_NUMB = 0;
		END
   
   SELECT @Ld_Request_DTTM = CAST (@Ad_Generate_DATE AS VARCHAR),
          @Ld_Update_DTTM = CAST(dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() AS VARCHAR);

   -- Code for Handling Cportal STARTS
   -- Generate the Cportal notice electronically when the notice is getting generated for that particular recipient
   IF EXISTS (SELECT 1 
				FROM REFM_Y1 
			   WHERE Table_ID = 'CSWP' 
			     AND TableSub_ID = 'NOTC' 
			     AND Value_code = @Ac_Notice_ID
			     AND @Ac_PrintMethod_CODE != @Lc_PrintMethod_View_TEXT)
	BEGIN
		IF @Ac_Recipient_CODE IN ('FR', 'GR', 'MC', 'MN', 'MS', 'NO', 'NP', 'OP', 'PM')
			BEGIN
				IF EXISTS (SELECT 1 
							 FROM CNTDT_Y1 
							WHERE NoticeTransmission_CODE = 'E' 
							  AND IamUser_ID = (SELECT IamUser_ID 
												  FROM CRUDT_Y1 
												 WHERE Case_IDNO = @An_Case_IDNO
												   AND MemberMci_IDNO = CAST(@Ac_Recipient_ID AS NUMERIC)) 
						  )
					BEGIN
						SET @Ac_PrintMethod_CODE = 'E';
						SET @Ac_TypeService_CODE = 'G';
					END
			END
	END
  
   -- Code for Handling Cportal ENDS
   
   IF @Ac_PrintMethod_CODE = 'L'
    SET @Lc_StatusNotice_CODE = 'P';
   ELSE
    SET @Lc_StatusNotice_CODE = 'G';

   
   SELECT @Lc_File_ID = c.File_ID
	 FROM CASE_Y1 AS c
	WHERE c.Case_IDNO = @An_Case_IDNO
	  AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;
	  
	  IF(ISNULL(@Lc_File_ID,'') = '' OR @Lc_File_ID = '')
	  BEGIN
	   SELECT  TOP 1  @Lc_File_ID = d.File_ID 
	   FROM FDEM_Y1 AS d WHERE 
		d.Case_IDNO = @An_Case_IDNO 
		AND d.EndValidity_DATE = @Ld_High_DATE
		ORDER BY d.TransactionEventSeq_NUMB DESC 
	  END	

   
   SELECT @Ln_Application_IDNO = Application_IDNO
	 FROM CASE_Y1
	WHERE Case_IDNO = @An_Case_IDNO;
               
   IF	  @Ln_Application_IDNO = 0
	  AND @Ac_Notice_ID = 'CSI-01'
	  BEGIN
		SET @Ac_Msg_CODE = 'E1056';
		SET @As_DescriptionError_TEXT = 'Invalid Application ID On Case';
		RETURN;
	  END;
   

   
   SELECT @Ln_CpMci_IDNO = MemberMci_IDNO
	   FROM CMEM_Y1
	  WHERE Case_IDNO = @An_Case_IDNO
		AND CaseRelationShip_CODE = 'C'
		AND CaseMemberStatus_CODE = 'A';
   

   
   SELECT @Ln_NcpMci_IDNO = MemberMci_IDNO
	   FROM CMEM_Y1
	  WHERE Case_IDNO = @An_Case_IDNO
		AND CaseRelationShip_CODE = 'A'
		AND CaseMemberStatus_CODE = 'A';
   

	
   IF (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) IS NOT NULL)
       AND (LTRIM(RTRIM(@Ac_SignedonWorker_ID)) != '')
    BEGIN
     SET @Ac_Worker_ID = @Ac_SignedonWorker_ID;
    END

	--13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - Start  
   IF LTRIM(RTRIM(@Ac_Worker_ID)) = 'BATCH'
		BEGIN
			SELECT @Lc_Worker_Parameter_ID = c.Worker_ID
			  FROM CASE_Y1 AS c
			 WHERE c.Case_IDNO = @An_Case_IDNO
			   AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE;
		END
	ELSE
		BEGIN
			SET @Lc_Worker_Parameter_ID = @Ac_Worker_ID;
		END
		
		
		IF LTRIM(RTRIM(@Ac_Worker_ID)) = 'BATCH'
		BEGIN
				SELECT @Lc_Worker_ID = u.Last_NAME from USEM_Y1 u 
					WHERE Worker_ID IN (SELECT c.Worker_ID
					FROM CASE_Y1 AS c
				  WHERE c.Case_IDNO = @An_Case_IDNO
				 AND c.StatusCase_CODE = @Lc_CaseStatusOpen_CODE)
				 AND u.EndValidity_DATE= @Ld_High_DATE
				 AND @Ad_Generate_DATE BETWEEN u.BeginEmployment_DATE AND u.EndEmployment_DATE
		END
		ELSE
		BEGIN
			SELECT @Lc_Worker_ID = u.Last_NAME 
				FROM USEM_Y1 u 
			  WHERE u.Worker_ID = @Ac_Worker_ID
			  AND u.EndValidity_DATE= @Ld_High_DATE
			  AND @Ad_Generate_DATE BETWEEN u.BeginEmployment_DATE AND u.EndEmployment_DATE
		END
		--13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - End
		  
   INSERT INTO #NoticeElementsData_P1 (Element_NAME,Element_VALUE)
   SELECT 'File_ID', @Lc_File_ID UNION
   SELECT 'Case_IDNO', CAST(@An_Case_IDNO AS VARCHAR) UNION
   SELECT 'Application_IDNO', CAST(@Ln_Application_IDNO AS VARCHAR) UNION
   SELECT 'MEMBERMCI_IDNO', CAST(@An_MemberMci_IDNO AS VARCHAR) UNION
   SELECT 'CP_MEMBERMCI_IDNO',CAST(@Ln_CpMci_IDNO AS VARCHAR) UNION
   SELECT 'NCP_MEMBERMCI_IDNO',CAST(ISNULL(@Ln_NcpMci_IDNO,0) AS VARCHAR) UNION
   SELECT 'OTHERPARTY_IDNO',CAST(@An_OthpSource_IDNO AS VARCHAR) UNION
   SELECT 'REFERENCE_ID', @Ac_Reference_ID UNION
   SELECT 'StatusNotice_CODE', @Lc_StatusNotice_CODE UNION
   SELECT 'NoticeVersion_NUMB', CAST(@Ln_Version_NUMB AS VARCHAR) UNION
   SELECT 'Copies_QNTY', '0' UNION
   SELECT 'Notice_ID', LTRIM(RTRIM(@Ac_Notice_ID)) UNION
   SELECT 'Generate_DATE',CONVERT(VARCHAR(10), @Ad_Generate_DATE, 101) UNION
   SELECT 'Generate_DTTM',CAST(@Ld_Request_DTTM AS VARCHAR) UNION
   SELECT 'Request_DTTM', CAST(@Ld_Request_DTTM AS VARCHAR) UNION
   SELECT 'Update_DTTM',CAST(@Ld_Update_DTTM AS VARCHAR) UNION
   SELECT 'Recipient_CODE', @Ac_Recipient_CODE UNION
   SELECT 'Recipient_ID',@Ac_Recipient_ID UNION
   SELECT 'ActivityMajor_CODE', @Ac_ActivityMajor_CODE UNION
   SELECT 'ActivityMinor_CODE', @Ac_ActivityMinor_CODE UNION
   SELECT 'ReasonStatus_CODE', @Ac_ReasonStatus_CODE UNION
   SELECT 'MajorIntSeq_NUMB', CONVERT(VARCHAR, @An_MajorIntSeq_NUMB) UNION
   SELECT 'MinorIntSeq_NUMB', CONVERT(VARCHAR, @An_MinorIntSeq_NUMB) UNION
   SELECT 'Schedule_NUMB', CONVERT(VARCHAR, @An_Schedule_NUMB) UNION
   SELECT 'DT_HEARING', CASE WHEN CAST(CONVERT(VARCHAR(4), @Ad_Schedule_DATE, 112) AS NUMERIC) != 1900 THEN CONVERT(VARCHAR(10), @Ad_Schedule_DATE, 101) ELSE '' END UNION
   SELECT 'HEARING_TIME', CASE WHEN CAST(CONVERT(VARCHAR(4), @Ad_BeginSch_DTTM, 112) AS NUMERIC) != 1900 THEN SUBSTRING(CONVERT(VARCHAR, CAST(@Ad_BeginSch_DTTM AS DATETIME2), 131), 12, 5)  + ' '  + SUBSTRING(CONVERT(VARCHAR, CAST(@Ad_BeginSch_DTTM AS DATETIME2), 131), 28, 2) ELSE '' END UNION
   SELECT 'Location_IDNO', CAST(@An_OthpLocation_IDNO AS VARCHAR) UNION
   SELECT 'Swks_Worker_ID', @Ac_ScheduleWorker_ID UNION
   SELECT 'Swks_Member_IDNO', @As_ScheduleListMemberMci_ID UNION
   SELECT 'WorkerRequest_ID', LTRIM(RTRIM(@Ac_Worker_ID)) UNION
   SELECT 'WorkerPrinted_ID', @Ac_Worker_ID UNION
   SELECT 'Worker_ID', @Lc_Worker_ID UNION
   SELECT 'Worker_Parameter_ID', @Lc_Worker_Parameter_ID UNION
   SELECT 'Job_ID', LTRIM(RTRIM(@Ac_Job_ID)) UNION
   SELECT 'PrintMethod_CODE', @Ac_PrintMethod_CODE UNION
   SELECT 'TypeService_CODE', @Ac_TypeService_CODE UNION
   SELECT 'orderseq_numb', CAST(@An_OrderSeq_NUMB AS VARCHAR) UNION
   SELECT 'TypeAddress_CODE', @Ac_TypeAddress_CODE UNION
   SELECT 'TransactionEventSeq_NUMB', CAST(@An_TransactionEventSeq_NUMB AS VARCHAR) UNION
   SELECT 'TransHeader_IDNO', CAST(ISNULL(@An_TransHeader_IDNO, 0) AS VARCHAR);
      
   -- Adding Office_IDNO and County_IDNO into the local table
   WITH Case_CTE
			AS (SELECT CAST (c.Office_IDNO AS VARCHAR(15))
							AS Office_IDNO,
					   CAST (c.County_IDNO AS VARCHAR(15))
							AS County_IDNO
					FROM CASE_Y1 c
				WHERE c.Case_IDNO = @An_Case_IDNO
						AND c.StatusCase_CODE =
								@Lc_CaseStatusOpen_CODE)
	INSERT INTO #NoticeElementsData_P1 (Element_NAME,
										Element_VALUE)
		SELECT pvt.Element_NAME, pvt.Element_VALUE
		FROM (SELECT SC.Office_IDNO,
					 SC.County_IDNO
				FROM Case_CTE SC) Z
					UNPIVOT (Element_VALUE FOR Element_NAME IN (Z.Office_IDNO, Z.County_IDNO)) AS pvt;   
   
   -- Get the xml input send from the UI when barcode is not zero, if xml input is not sent, then get it from database
   IF (@An_Barcode_NUMB != 0 AND @An_Barcode_NUMB IS NOT NULL AND (@As_XmlInput_TEXT = '' OR @As_XmlInput_TEXT IS NULL)) 
       OR (@Ac_Notice_ID = @Lc_ENF01Notice_ID AND @An_Barcode_NUMB != 0 AND @An_Barcode_NUMB IS NOT NULL AND (@As_XmlInput_TEXT != '' OR @As_XmlInput_TEXT IS NOT NULL))
	BEGIN
		
		SET @Ls_Sql_TEXT = 'Get Xml_TEXT for the from NXML/AXML';
		SET @Ls_Sqldata_TEXT = ' Barcode_NUMB: ' + CAST(ISNULL(@An_Barcode_NUMB, '') AS VARCHAR);
							 
		SET @As_XmlInput_TEXT = (SELECT Xml_TEXT
								   FROM AXML_Y1
							      WHERE Barcode_NUMB = @An_Barcode_NUMB)

		IF		@As_XmlInput_TEXT = ''
		   OR	@As_XmlInput_TEXT IS NULL
			BEGIN
				 SET @As_XmlInput_TEXT = (SELECT Xml_TEXT
										    FROM NXML_Y1
										   WHERE Barcode_NUMB = @An_Barcode_NUMB)
			END
			
		IF @As_XmlInput_TEXT = ''
		   OR	@As_XmlInput_TEXT IS NULL
			BEGIN
				SET @As_DescriptionError_TEXT = 'Xml Does Not Exist for the Barcode_NUMB in NXML/AXML';
				RAISERROR(50001,16,1);
			END
		SET @Lc_XmlExistsFlag_INDC = 'Y';
	END
   
   IF ISNUMERIC(@Ac_Notice_ID) = 0
	BEGIN
	
	   SET @Ls_InsertInput_CUR = CURSOR
		 FOR SELECT Element_NAME,
					TypeElement_CODE,
					ParentSeq_NUMB
			   FROM NDEl_Y1 n
			  WHERE NOTICE_ID = @Ac_Notice_ID
					AND (	Element_NAME LIKE 'option_%' 
						 OR (Element_NAME like '%esign%' AND Procedure_NAME = '')
						 OR (Element_NAME like '%estamp%' AND Procedure_NAME = '')
						 OR (	  Input_CODE = 'I' 
							  AND NOT EXISTS (SELECT 1
												FROM #NoticeElementsData_P1
											   WHERE Element_NAME = n.Element_NAME)
							)
							--13869 - ENF-31 Address Issue - Fix - START
						 OR (	  @Ac_Worker_ID = 'BATCH'
							  AND NOT EXISTS (SELECT 1
												FROM #NoticeElementsData_P1
											   WHERE Element_NAME = n.Element_NAME)
							  AND (CHARINDEX('</'+Element_NAME+'>', @As_XmlInput_TEXT, 0) != 0
								  OR CHARINDEX('<'+Element_NAME+'/>', @As_XmlInput_TEXT, 0) != 0)
							)
						 OR (	  (@An_Barcode_NUMB != 0 AND @An_Barcode_NUMB IS NOT NULL)
							  AND NOT EXISTS (SELECT 1
												FROM #NoticeElementsData_P1
											   WHERE Element_NAME = n.Element_NAME)
							  AND (CHARINDEX('</'+Element_NAME+'>', @As_XmlInput_TEXT, 0) != 0
									OR CHARINDEX('<'+Element_NAME+'/>', @As_XmlInput_TEXT, 0) != 0)
							)
							--13869 - ENF-31 Address Issue - Fix - END
						 
						 OR ((TypeElement_CODE = 'M') AND @Ac_Notice_ID IN ('INT-01', 'INT-04', 'INT-09', 'LEG-154', 'CSI-05'))
						);

	   OPEN @Ls_InsertInput_CUR

	   FETCH NEXT FROM @Ls_InsertInput_CUR INTO @Ls_InputParam_TEXT, @Lc_TypeElement_CODE, @Ln_ParentSeq_NUMB;

	   WHILE @@FETCH_STATUS = 0
			BEGIN
				
			   DECLARE
					@ElementValue_TEXT		VARCHAR(MAX),
					@Ln_PositionStart_NUMB	NUMERIC(10),
					@Ln_PositionEnd_NUMB	NUMERIC(10);
							
			   IF @Lc_TypeElement_CODE = 'S' 
				 AND (@As_XmlInput_TEXT IS NULL OR LEN(LTRIM(RTRIM(@As_XmlInput_TEXT))) = 0) 
				 AND @Ls_InputParam_TEXT LIKE 'option_%'
				 AND @Ln_ParentSeq_NUMB = 0
				 AND (@An_Barcode_NUMB = 0 OR @An_Barcode_NUMB IS NULL)
					BEGIN
						INSERT INTO #NoticeElementsData_P1 
								VALUES(@Ls_InputParam_TEXT, '');
					END
			   ELSE IF @Lc_TypeElement_CODE = 'S' AND @As_XmlInput_TEXT IS NOT NULL AND LEN(LTRIM(RTRIM(@As_XmlInput_TEXT))) > 0 
					AND @Ln_ParentSeq_NUMB = 0
					AND (@An_Barcode_NUMB = 0 OR @An_Barcode_NUMB IS NULL)
					BEGIN
						
						SET @Ln_PositionStart_numb = 0;
						SET @Ln_PositionEnd_NUMB = 0;
						
						
						SET @Ln_PositionStart_numb = CHARINDEX('<'+@Ls_InputParam_TEXT+'>', @As_XmlInput_TEXT, @Ln_positionStart_NUMB) + LEN('<'+@Ls_InputParam_TEXT+'>');
						
						SET @Ln_PositionEnd_numb = CHARINDEX('</'+@Ls_InputParam_TEXT+'>', @As_XmlInput_TEXT, @Ln_positionStart_NUMB);
						
						IF @Ln_PositionEnd_NUMB != 0
							BEGIN
								SELECT @ElementValue_TEXT = ISNULL(SUBSTRING(@As_XmlInput_TEXT, @Ln_PositionStart_numb , @Ln_PositionEnd_numb - @Ln_PositionStart_numb), 'F');
							END
						ELSE
							BEGIN
								SET @ElementValue_TEXT = '';
							END
						
						IF		(@ElementValue_TEXT <> 'F' AND LTRIM(RTRIM(@ElementValue_TEXT)) != '' AND @ElementValue_TEXT IS NOT NULL AND @Ls_InputParam_TEXT NOT LIKE 'option_%') 
							 OR @Ls_InputParam_TEXT LIKE 'option_%'
							BEGIN 
							   INSERT INTO #NoticeElementsData_P1 
								VALUES(@Ls_InputParam_TEXT, @ElementValue_TEXT);
							END
					END
				ELSE IF @Lc_TypeElement_CODE = 'M'
					BEGIN
						
						SET @ElementValue_TEXT = @As_XmlInput_TEXT;
						--13589 - System error when generating uifsa docs Fix - Start
						IF CHARINDEX('<' + @Ls_InputParam_TEXT + ' count', @ElementValue_TEXT) > 0 AND CHARINDEX('</' + @Ls_InputParam_TEXT + '>',@ElementValue_TEXT) > 0
						--13589 - System error when generating uifsa docs Fix - End
							BEGIN
								SELECT @ElementValue_TEXT =  SUBSTRING(@ElementValue_TEXT,
																		CHARINDEX('<' + @Ls_InputParam_TEXT + ' count', @ElementValue_TEXT),
																		(((CHARINDEX('</' + @Ls_InputParam_TEXT + '>', @ElementValue_TEXT)) - (CHARINDEX('<' + @Ls_InputParam_TEXT + ' count', @ElementValue_TEXT))) + LEN('</' + @Ls_InputParam_TEXT + '>'))
																		);

								INSERT INTO #NoticeElementsData_P1
									 VALUES(@Ls_InputParam_TEXT ,@ElementValue_TEXT);
							END
					END
				ELSE IF @An_Barcode_NUMB != 0 AND @An_Barcode_NUMB IS NOT NULL
					AND @Lc_TypeElement_CODE = 'S' AND @As_XmlInput_TEXT IS NOT NULL AND LEN(LTRIM(RTRIM(@As_XmlInput_TEXT))) > 0 
					AND @Ln_ParentSeq_NUMB = 0
					AND @Ls_InputParam_TEXT = 'applicationncp_list'
					BEGIN
						SET @ElementValue_TEXT = @As_XmlInput_TEXT;
						
						IF CHARINDEX('<' + @Ls_InputParam_TEXT + ' count', @ElementValue_TEXT) > 0
							BEGIN
								SELECT @ElementValue_TEXT =  SUBSTRING(@ElementValue_TEXT,
																		CHARINDEX('<' + @Ls_InputParam_TEXT + ' count', @ElementValue_TEXT),
																		(((CHARINDEX('</' + @Ls_InputParam_TEXT + '>', @ElementValue_TEXT)) - (CHARINDEX('<' + @Ls_InputParam_TEXT + ' count', @ElementValue_TEXT))) + LEN('</' + @Ls_InputParam_TEXT + '>'))
																		);

								INSERT INTO #NoticeElementsData_P1
									 VALUES(@Ls_InputParam_TEXT ,@ElementValue_TEXT);
							END
					END
				ELSE IF @An_Barcode_NUMB != 0 AND @An_Barcode_NUMB IS NOT NULL
					AND @Lc_TypeElement_CODE = 'S' AND @As_XmlInput_TEXT IS NOT NULL AND LEN(LTRIM(RTRIM(@As_XmlInput_TEXT))) > 0 
					AND @Ln_ParentSeq_NUMB = 0
					BEGIN
						
						SET @Ln_PositionStart_numb = 0;
						SET @Ln_PositionEnd_NUMB = 0;
						
						
						SET @Ln_PositionStart_numb = CHARINDEX('<'+@Ls_InputParam_TEXT+'>', @As_XmlInput_TEXT, @Ln_positionStart_NUMB) + LEN('<'+@Ls_InputParam_TEXT+'>');
						
						SET @Ln_PositionEnd_numb = CHARINDEX('</'+@Ls_InputParam_TEXT+'>', @As_XmlInput_TEXT, @Ln_positionStart_NUMB);
						
						IF @Ln_PositionEnd_NUMB != 0
							BEGIN
								SELECT @ElementValue_TEXT = ISNULL(SUBSTRING(@As_XmlInput_TEXT, @Ln_PositionStart_numb , @Ln_PositionEnd_numb - @Ln_PositionStart_numb), 'F');
							END
						ELSE
							BEGIN
								SET @ElementValue_TEXT = '';
							END
						
						IF @ElementValue_TEXT <> 'F' OR @Ls_InputParam_TEXT LIKE 'option_%'
							BEGIN 
							   INSERT INTO #NoticeElementsData_P1 
								VALUES(@Ls_InputParam_TEXT, @ElementValue_TEXT);
							END
					END

					FETCH NEXT FROM @Ls_InsertInput_CUR INTO @Ls_InputParam_TEXT, @Lc_TypeElement_CODE, @Ln_ParentSeq_NUMB;
			END

	   CLOSE @Ls_InsertInput_CUR

	   DEALLOCATE @Ls_InsertInput_CUR;
	END
   
   
   -- IF the barcode number is zero then the notice is generated from scratch by calling BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML procedure   
   -- if not it will get XML  either from NXML_Y1,AXML_Y1 based on print method     
   --IF @Ac_PrintMethod_CODE = @Lc_PrintMethod_Central_TEXT OR @Ac_PrintMethod_CODE = @Lc_PrintMethod_Local_TEXT OR @Ac_PrintMethod_CODE = @Lc_PrintMethod_View_TEXT  
   IF @Ac_PrintMethod_CODE IN (@Lc_PrintMethod_Central_TEXT, @Lc_PrintMethod_Local_TEXT, @Lc_PrintMethod_View_TEXT, @Lc_PrintMethod_Electronic_TEXT)
		BEGIN
			
			IF		@An_Barcode_NUMB = 0
				OR	@An_Barcode_NUMB IS NULL
				BEGIN
					
					IF ISNUMERIC(@Ac_Notice_ID) = 0
						BEGIN
							SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML';
							SET @Ls_Sqldata_TEXT = ' NOTICE_ID: ' + ISNULL(@Ac_Notice_ID, '') 
												 + ' Case_IDNO: ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR) 
												 + ' MemberMci_IDNO: ' + CAST(ISNULL(@An_MemberMci_IDNO, 0) AS VARCHAR)
												 + ' Worker_ID: ' + ISNULL(@Ac_Worker_ID, '')
												 + ' OthpSource_IDNO: ' + CAST(ISNULL(@An_OthpSource_IDNO, 0) AS VARCHAR)
												 + ' ActivityMajor_CODE: ' + ISNULL(@Ac_ActivityMajor_CODE, '')
												 + ' ActivityMinor_CODE: ' + ISNULL(@Ac_ActivityMinor_CODE, '')
												 + ' Reason_CODE: ' + ISNULL(@Ac_ReasonStatus_CODE, '')
												 + ' Barcode_NUMB: ' + CAST(ISNULL(@An_Barcode_NUMB, 0) AS VARCHAR);
							EXEC BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
										@Ac_Notice_ID             = @Ac_Notice_ID,
										@An_Case_IDNO             = @An_Case_IDNO,
										@Ac_Worker_ID		      = @Ac_Worker_ID,
										@An_MemberMci_IDNO        = @An_MemberMci_IDNO,
										@An_OthpSource_IDNO       = @An_OthpSource_IDNO,
										@Ac_ActivityMajor_CODE	  = @Ac_ActivityMajor_CODE,
										@Ac_ActivityMinor_CODE	  = @Ac_ActivityMinor_CODE,
										@Ac_Reason_CODE			  = @Ac_ReasonStatus_CODE,
										@An_Barcode_NUMB		  = @An_Barcode_NUMB,
										@As_XML_Result_Text       = @Ls_xml_Result_TEXT OUTPUT,
										@Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
										@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
					        
							IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
								BEGIN
									RAISERROR(50001,16,1);
								END;
						
							SET @Ls_result_TEXT = @Ls_xml_Result_TEXT;
					         
							SET @Ls_result_TEXT = '<' + LOWER(LTRIM(RTRIM(@Ac_Notice_ID))) + '>' + @Ls_result_TEXT + '</' + LOWER(LTRIM(RTRIM(@Ac_Notice_ID))) + '>'
							
							IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
								BEGIN
									SET @As_XmlOut_TEXT = @Ls_result_TEXT;
									RETURN;
								END
						END
					ELSE
						BEGIN
							SET @Ls_result_TEXT = @As_XmlInput_TEXT;
						END
					
					IF @Ls_result_TEXT != ' ' OR ISNUMERIC(@Ac_Notice_ID) != 0
						BEGIN
							IF @Ac_PrintMethod_CODE != @Lc_PrintMethod_View_TEXT
								BEGIN
									
									
									INSERT INTO dbo.IdentSeqNoBarcode_T1
										VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

									SET @Ln_BarcodeOut_NUMB = @@IDENTITY;
									
									
									INSERT INTO #NoticeElementsData_P1
										VALUES('Barcode_NUMB',
											   CAST(@Ln_BarcodeOut_NUMB AS VARCHAR));
									
									IF NOT EXISTS (SELECT 1
													 FROM #NoticeElementsData_P1
													WHERE Element_NAME NOT IN ('Recipient_CODE', 'Recipient_ID')
													  AND Element_NAME LIKE 'Recipient%')
										BEGIN
											SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS - 1';
											SET @Ls_Sqldata_TEXT = ' Recipient_CODE: ' + ISNULL(@Ac_Recipient_CODE, '') 
																 + ' Recipient_ID: ' + ISNULL(@Ac_Recipient_ID, '')
																 + ' TypeAddress_CODE: ' + ISNULL(@Ac_TypeAddress_CODE, '')
																 + ' Run_DATE: ' + CAST(ISNULL(@Ad_Generate_DATE, '') AS VARCHAR);
																 
											--13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - Start
											IF ((@Ac_Notice_ID = @Lc_ENF01Notice_ID AND @Ac_Recipient_CODE = @Lc_RecipientSi_CODE) OR 
														(@Ac_Notice_ID = @Lc_NoticeEnf03_ID AND @Ac_Recipient_CODE = @Lc_RecipientOe_CODE))
												BEGIN
												SELECT @Ac_Recipient_ID = CAST(O.AddrOthp_IDNO  AS CHAR(10))
													FROM OTHX_Y1 O
													WHERE O.OtherParty_IDNO = CASE WHEN ISNUMERIC( @Ac_Recipient_ID  ) = 1 THEN @Ac_Recipient_ID  ELSE 0 END  
													AND O.EndValidity_DATE = @Ld_High_Date
													AND ((O.TypeAddr_CODE = @Lc_TypeAddrZ_CODE 
															AND @Ac_Notice_ID = @Lc_ENF01Notice_ID 
															AND @Ac_Recipient_CODE = @Lc_RecipientSi_CODE) 
														OR (O.TypeAddr_CODE = @Lc_TypeAddrV_CODE 
															AND @Ac_Notice_ID = @Lc_NoticeEnf03_ID 
															AND @Ac_Recipient_CODE = @Lc_RecipientOe_CODE))
												END			
											--13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - End													
												
											-- Extract the NMRQ/NRRQ recipient columns  
											EXEC BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS     
												 @Ac_Recipient_CODE			= @Ac_Recipient_CODE,
												 @Ac_Recipient_ID			= @Ac_Recipient_ID,  
												 @Ac_TypeAddress_CODE		= @Ac_TypeAddress_CODE,
												 @Ad_Run_DATE				= @Ad_Generate_DATE,  
												 @Ac_Msg_CODE				= @Ac_Msg_CODE  OUTPUT,    
												 @As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT   
											
										   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
												BEGIN
													 IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
													  BEGIN
													   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '');
													  END
													 ELSE
													  BEGIN
													   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
													  END

													 RAISERROR(50001,16,1)/*Uncomment this when NREF_Y1 has data*/
												END
										END
										
								   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS - 1';
								   SET @Ls_Sqldata_TEXT = ' NOTICE_ID: ' + ISNULL(@Ac_Notice_ID, '') 
														+ ' Case_IDNO: ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR);
								   
								   -- Gets NMRQ/NRRQ office worker details   
								   
								   EXEC BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS
												@An_Case_IDNO             = @An_Case_IDNO,
												@Ac_Notice_ID             = @Ac_Notice_ID,
												@Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
												@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
									
								   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
										BEGIN
											 IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
											  BEGIN
											   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$SP_GET_TLE_WORKER_DETAILS' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '');
											  END
											 ELSE
											  BEGIN
											   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$SP_GET_TLE_WORKER_DETAILS' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
											  END
											
										END
								   
								   -- Suppressing Country if it is US issue caused due to second address
									UPDATE #NoticeElementsData_P1
									   SET Element_VALUE = ''
									 WHERE Element_NAME LIKE '%_country_addr'
									   AND LTRIM(RTRIM(Element_VALUE)) = 'US';

								   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA - 1';
								   SET @Ls_Sqldata_TEXT = ' PrintMethod_CODE: ' + ISNULL(@Ac_PrintMethod_CODE, '') 
														+ ' BarcodeIn_NUMB: ' + CAST(ISNULL(@An_Barcode_NUMB, 0) AS VARCHAR)
														+ ' Barcode_NUMB: ' + CAST(ISNULL(@Ln_BarcodeOut_NUMB, 0) AS VARCHAR)
														+ ' Generate_DATE: ' + CAST(ISNULL(@Ad_Generate_DATE, '') AS VARCHAR)
														+ ' TransactionEventSeq_NUMB: ' + CAST(ISNULL(@An_TransactionEventSeq_NUMB, 0) AS VARCHAR)
														+ ' Xml_TEXT: ' + ISNULL(@Ls_result_TEXT, '')
														+ ' TypeService_CODE: ' + ISNULL(@Ac_TypeService_CODE, '')
														+ ' TypeAddress_CODE: ' + ISNULL(@Ac_TypeAddress_CODE, '');
									
								   -- Inserts data to NMRQ_Y1 / NRRQ_Y1 and NXML_Y1/AXML_Y1  
								   EXEC BATCH_GEN_NOTICES$INSERT_NOTICE_DATA
											  @Ac_PrintMethod_CODE         = @Ac_PrintMethod_CODE,
											  @An_BarcodeIn_NUMB		   = @An_Barcode_NUMB,
											  @An_Barcode_NUMB             = @Ln_BarcodeOut_NUMB,
											  @Ad_Generate_DATE            = @Ad_Generate_DATE,
											  @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
											  @As_Xml_TEXT                 = @Ls_result_TEXT,
											  @Ac_TypeService_CODE		   = @Ac_TypeService_CODE,
											  @Ac_TypeAddress_CODE		   = @Ac_TypeAddress_CODE,
											  @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
											  @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;
									
								   IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
										BEGIN
											 IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
												BEGIN
												 SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + SUBSTRING (@As_DescriptionError_TEXT, 1, 4000);
												END
											 ELSE
												BEGIN
												 SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
												END

											RAISERROR(50001,16,1)
										END
								END
								-- If print method is V (View Only)  
							ELSE
								BEGIN
									SET @As_XmlOut_TEXT = @Ls_result_TEXT;
									
									SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
								END
						END
					-- If generated xml is empty  
					ELSE
						BEGIN
							SET @Ls_Sql_TEXT = 'XML Generated Is Empty';
							RAISERROR(50001,16,1);
						END
				END
			 -- If Barcode is greater than 0  
			 ELSE
				BEGIN
					
					-- Delete the elements that are populated in the approval step where it is required and populate again
					DELETE FROM #NoticeElementsData_P1
					 WHERE Element_NAME IN (SELECT DISTINCT Element_NAME
											  FROM RARE_Y1
											 WHERE ActivityMajor_CODE = @Ac_ActivityMajor_CODE
											   AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
											   AND Reason_Code = @Ac_ReasonStatus_CODE
											   AND Notice_ID = @Ac_Notice_ID
											   AND Required_INDC = 'Y'
											   AND Procedure_NAME != ''
										   );
					
					-- Delete all the recipient related tags from the local table
					DELETE FROM #NoticeElementsData_P1
					 WHERE Element_NAME LIKE 'RECIPIENT%'
					   AND Element_NAME NOT IN ('Recipient_CODE', 'Recipient_ID');
					   
					SET @Ln_RecipentCount_NUMB = @@ROWCOUNT;   
					
					
					--13458 -  ENF-18 Address issue during batch generation Fix -Start
					--13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -Start
				     IF @Ac_ActivityMinor_CODE <> @Lc_ActivityMinorNorpr_CODE
                                 AND NOT EXISTS(SELECT 1 
                                                        FROM AFMS_Y1 f 
                                                       WHERE f.ApprovalRequired_INDC = @Lc_ApprovalRequiredYes_INDC 
                                                         AND f.TypeEditNotice_CODE != @Lc_TypeEditNoticeO_CODE
                                                         AND f.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
                                                         AND f.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
                                                         AND f.Reason_CODE = @Ac_ReasonStatus_CODE
                                                         AND f.EndValidity_DATE = @Ld_High_DATE)
					--13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -End	
						BEGIN
							DELETE FROM #NoticeElementsData_P1
								 WHERE Element_NAME IN ('cp_attn_addr', 'cp_line1_addr','cp_line2_addr','cp_city_addr','cp_state_addr','cp_zip_addr','cp_country_addr',
								                           'ncp_attn_addr', 'ncp_line1_addr','ncp_line2_addr','ncp_city_addr','ncp_state_addr','ncp_zip_addr','ncp_country_addr');
						END
					--13458 -  ENF-18 Address issue during batch generation Fix -End
					SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS - 2';
					SET @Ls_Sqldata_TEXT = ' Recipient_CODE: ' + ISNULL(@Ac_Recipient_CODE, '') 
										 + ' Recipient_ID: ' + ISNULL(@Ac_Recipient_ID, '')
										 + ' TypeAddress_CODE: ' + ISNULL(@Ac_TypeAddress_CODE, '')
										 + ' Run_DATE: ' + CAST(ISNULL(@Ad_Generate_DATE, '') AS VARCHAR);
					
					--13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - Start 				
					IF ((@Ac_Notice_ID = @Lc_ENF01Notice_ID AND @Ac_Recipient_CODE = @Lc_RecipientSi_CODE) OR 
												(@Ac_Notice_ID = @Lc_NoticeEnf03_ID AND @Ac_Recipient_CODE = @Lc_RecipientOe_CODE))
					BEGIN												
						SELECT @Ac_Recipient_ID = CAST(O.AddrOthp_IDNO  AS CHAR(10))
									FROM OTHX_Y1 O
									WHERE O.OtherParty_IDNO  = CASE WHEN ISNUMERIC( @Ac_Recipient_ID  ) = 1 THEN @Ac_Recipient_ID  ELSE 0 END     
									AND O.EndValidity_DATE = @Ld_High_Date
									AND ((O.TypeAddr_CODE = @Lc_TypeAddrZ_CODE 
											AND @Ac_Notice_ID = @Lc_ENF01Notice_ID 
											AND @Ac_Recipient_CODE = @Lc_RecipientSi_CODE) 
										OR ( O.TypeAddr_CODE = @Lc_TypeAddrV_CODE 
											AND @Ac_Notice_ID = @Lc_NoticeEnf03_ID 
											AND @Ac_Recipient_CODE = @Lc_RecipientOe_CODE))
					END										
					--13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - End			
							
					-- Execute recipient details procedure to add recipient tags to the local table
					EXEC BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS
										  @Ac_Recipient_CODE		= @Ac_Recipient_CODE,
										  @Ac_Recipient_ID			= @Ac_Recipient_ID,
										  @Ac_TypeAddress_CODE		= @Ac_TypeAddress_CODE,
										  @Ad_Run_DATE				= @Ad_Generate_DATE,
										  @Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT,
										  @As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT					
					IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
						BEGIN
							   IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
								BEGIN
								 SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS FAILED -2' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + SUBSTRING (@As_DescriptionError_TEXT, 1, 4000);
								END
							   ELSE
								BEGIN
								 SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS FAILED -2' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
								END
								
							   RAISERROR(50001,16,1)
						END

					 --13432 - Zip dash missing from address on ENF-38 Fix - Start

					 --Apply formatting For all elements in Temporary table          
					 SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GENERATE_NOTICE';
					 SET @Ls_Sqldata_TEXT = 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA : No Elements Data For Formatting'
				     
					 SET @GetFormat_Element_CUR = CURSOR FOR
						 SELECT  V.Element_NAME,
								 V.Element_VALUE,
								 p.Format_CODE,
								 P.Mask_INDC
							FROM #NoticeElementsData_P1 V, NDEL_Y1 P
						   WHERE v.ELEMENT_NAME = P.Element_NAME
							 AND P.NOTICE_ID = @Ac_Notice_ID
							 AND P.Procedure_NAME = 'BATCH_GEN_NOTICE_CM$SP_GET_RECIPIENT_DETAILS'
							 AND P.Input_CODE = 'O'
							 AND P.Format_CODE <> '';

					 OPEN @GetFormat_Element_CUR

					 FETCH NEXT FROM @GetFormat_Element_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Ls_Format_CODE, @Lc_Mask_INDC;

					 WHILE @@FETCH_STATUS = 0
						  BEGIN
							   SET @Ls_Element_TEXT = @Ls_Element_NAME;
							   SET @Ls_ElementValue_TEXT = @Ls_Element_VALUE;
							   SET @Ls_Ele_Format_CODE = @Ls_Format_CODE;
							   SET @Lc_Mask_INDC = @Lc_Mask_INDC;
						       
							   SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA';
							   SET @Ls_Sqldata_TEXT = 'EXEC ' + @Ls_Sql_TEXT + ' ' + @Ls_SQLParameterString_TEXT;
								
							   IF @Ls_Ele_Format_CODE <> ''
								BEGIN
								  EXEC  BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA
												@As_Element_NAME			= @Ls_Element_TEXT,
												@As_Element_VALUE			= @Ls_ElementValue_TEXT,
												@Ac_Format_CODE				= @Ls_Ele_Format_CODE,
												@Ac_Mask_INDC				= @Lc_Mask_INDC,
												@As_FormattedResult_TEXT	= @Ls_FormattedResult_TEXT OUTPUT,
												@As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT,
												@Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT;
						          
								  IF @Ac_Msg_CODE = 'F'
									BEGIN
										RETURN;
									END
						          
								  UPDATE #NoticeElementsData_P1
									 SET ELEMENT_VALUE = @Ls_FormattedResult_TEXT
								   WHERE ELEMENT_NAME = @Ls_Element_TEXT;
								  
								END

							   FETCH NEXT FROM @GetFormat_Element_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Ls_Format_CODE, @Lc_Mask_INDC;
						  END

					 CLOSE @GetFormat_Element_CUR;

					 DEALLOCATE @GetFormat_Element_CUR;
					--13432 - Zip dash missing from address on ENF-38 Fix - End
					
					/*Replacing recipient details for the second notice*/
					--13802 - NRRQ - Re-printing Administrative Hearing Scheduling Notice ENF-31, the date and time of the hearing does not appear in the notice - START
					IF ((@Ln_RecipentCount_NUMB > 0 
							AND @Lc_XmlExistsFlag_INDC = 'Y' 
							AND  LTRIM(RTRIM(@Ac_Worker_ID)) = 'BATCH') 
						OR LTRIM(RTRIM(@Ac_Job_ID)) ='NRRQ')
					--13802 - NRRQ - Re-printing Administrative Hearing Scheduling Notice ENF-31, the date and time of the hearing does not appear in the notice - END
					BEGIN	
							
							SET @Ls_Sql_TEXT = 'REPLACE RECIPIENT XML';
							
							SET @Lx_ModifyXml_XML = CONVERT(XML,@As_XmlInput_TEXT);
							
							--13802 - NRRQ - Re-printing Administrative Hearing Scheduling Notice ENF-31, the date and time of the hearing does not appear in the notice - START
							IF LTRIM(RTRIM(@Ac_Job_ID)) <> 'NRRQ'
							--13802 - NRRQ - Re-printing Administrative Hearing Scheduling Notice ENF-31, the date and time of the hearing does not appear in the notice - END	
							BEGIN
								SELECT @LS_RECIPIENT_ATTN_ADDR = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_ATTN_ADDR';
								SELECT @LS_RECIPIENT_BIRTH_DATE = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_BIRTH_DATE';
								SELECT @LS_RECIPIENT_CITY_ADDR = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_CITY_ADDR';
								SELECT @LS_RECIPIENT_COUNTRY_ADDR = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_COUNTRY_ADDR';
								SELECT @LS_RECIPIENT_HOMEPHONE_NUMB = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_HOMEPHONE_NUMB';
								SELECT @LS_RECIPIENT_LINE1_ADDR = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_LINE1_ADDR';
								SELECT @LS_RECIPIENT_LINE2_ADDR = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_LINE2_ADDR';
								SELECT @LS_RECIPIENT_MEMBERMCI_IDNO = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_MEMBERMCI_IDNO';
								SELECT @LS_RECIPIENT_NAME = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_NAME';
								SELECT @LS_RECIPIENT_SSN_NUMB = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_SSN_NUMB';
								SELECT @LS_RECIPIENT_STATE_ADDR = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_STATE_ADDR';
								SELECT @LS_RECIPIENT_ZIP_ADDR = Element_VALUE FROM  #NoticeElementsData_P1 WHERE Element_NAME = 'RECIPIENT_ZIP_ADDR';

								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_attn_addr/text())[1] with "'+REPLACE(REPLACE(ISNULL(@LS_RECIPIENT_ATTN_ADDR,''),'&','&amp;'),'''','&apos;')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							

								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_birth_date/text())[1] with "'+ISNULL(@LS_RECIPIENT_BIRTH_DATE,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_city_addr/text())[1] with "'+ISNULL(@LS_RECIPIENT_CITY_ADDR,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_country_addr/text())[1] with "'+ISNULL(@LS_RECIPIENT_COUNTRY_ADDR,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_homephone_numb/text())[1] with "'+ISNULL(@LS_RECIPIENT_HOMEPHONE_NUMB,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_line1_addr/text())[1] with "'+REPLACE(REPLACE(ISNULL(@LS_RECIPIENT_LINE1_ADDR,''),'&','&amp;'),'''','&apos;')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							
								SET @Ls_Xml_Value = @Lx_ModifyXml_XML.value('(//recipient_line2_addr)[1]','VARCHAR(50)')

								IF @Ls_Xml_Value =''
								BEGIN
									SET @Ls_ExecuteQuery_TEXT = 'SET  @Lx_ModifyXml_XML.modify(''insert text {"'+REPLACE(REPLACE(ISNULL(@LS_RECIPIENT_LINE2_ADDR,''),'&','&amp;'),'''','&apos;')+'"} as first into (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_line2_addr)[1]'')'
									EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
								END
								ELSE
								BEGIN
									SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_line2_addr/text())[1] with "'+REPLACE(REPLACE(ISNULL(@LS_RECIPIENT_LINE2_ADDR,''),'&','&amp;'),'''','&apos;')+'"'')';
									EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
								END
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_membermci_idno/text())[1] with "'+ISNULL(@LS_RECIPIENT_MEMBERMCI_IDNO,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_name/text())[1] with "'+REPLACE(REPLACE(REPLACE(ISNULL(@LS_RECIPIENT_NAME,''),'&','&amp;'),'''','&apos;'),'"','@quot')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT		
	
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_ssn_numb/text())[1] with "'+ISNULL(@LS_RECIPIENT_SSN_NUMB,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT							
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_state_addr/text())[1] with "'+ISNULL(@LS_RECIPIENT_STATE_ADDR,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT
							
								SET @Ls_ExecuteQuery_TEXT = 'SET @Lx_ModifyXml_XML.modify(''replace value of (/'+LTRIM(RTRIM(LOWER(@Ac_Notice_ID)))+'/recipient_zip_addr/text())[1] with "'+ISNULL(@LS_RECIPIENT_ZIP_ADDR,'')+'"'')';
								EXEC SP_EXECUTESQL @stmt = @Ls_ExecuteQuery_TEXT ,@params = N'@Lx_ModifyXml_XML xml OUTPUT' ,@Lx_ModifyXml_XML = @Lx_ModifyXml_XML OUTPUT				
							END
							SET @Ls_xml_Result_TEXT = CONVERT(VARCHAR(MAX),@Lx_ModifyXml_XML);
							SET @Lc_XmlModifiedFlag_INDC = 'Y';
							
					END
					
					
					IF @Lc_XmlModifiedFlag_INDC = 'N'
						BEGIN
						
								/*If Perviously generated XML not assinged then generating the notice again*/
								IF LTRIM(RTRIM(@Ac_Worker_ID)) = 'BATCH'
									BEGIN
										IF @Lc_XmlExistsFlag_INDC = 'Y'
											BEGIN
												SET @An_Barcode_NUMB = @An_Barcode_NUMB;
											END
										ELSE
											BEGIN
												SET @An_Barcode_NUMB = 0;
											END
									END
						
							SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML - 2';
							SET @Ls_Sqldata_TEXT = ' NOTICE_ID: ' + ISNULL(@Ac_Notice_ID, '') 
												 + ' Case_IDNO: ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR) 
												 + ' MemberMci_IDNO: ' + CAST(ISNULL(@An_MemberMci_IDNO, 0) AS VARCHAR)
												 + ' Worker_ID: ' + ISNULL(@Ac_Worker_ID, '')
												 + ' OthpSource_IDNO: ' + CAST(ISNULL(@An_OthpSource_IDNO, 0) AS VARCHAR)
												 + ' ActivityMajor_CODE: ' + ISNULL(@Ac_ActivityMajor_CODE, '')
												 + ' ActivityMinor_CODE: ' + ISNULL(@Ac_ActivityMinor_CODE, '')
												 + ' Reason_CODE: ' + ISNULL(@Ac_ReasonStatus_CODE, '')
												 + ' Barcode_NUMB: ' + CAST(ISNULL(@An_Barcode_NUMB, 0) AS VARCHAR);
					        
							EXEC BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
										@Ac_Notice_ID             = @Ac_Notice_ID,
										@An_Case_IDNO             = @An_Case_IDNO,
										@Ac_Worker_ID		      = @Ac_Worker_ID,
										@An_MemberMci_IDNO        = @An_MemberMci_IDNO,
										@An_OthpSource_IDNO       = @An_OthpSource_IDNO,
										@Ac_ActivityMajor_CODE	  = @Ac_ActivityMajor_CODE,
										@Ac_ActivityMinor_CODE	  = @Ac_ActivityMinor_CODE,
										@Ac_Reason_CODE			  = @Ac_ReasonStatus_CODE,
										@An_Barcode_NUMB		  = @An_Barcode_NUMB,
										@As_XML_Result_Text       = @Ls_xml_Result_TEXT OUTPUT,
										@Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
										@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
					        
					       
							IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
								BEGIN
									RAISERROR(50001,16,1);
								END;
							
							SET @Ls_xml_Result_TEXT = '<' + LOWER(LTRIM(RTRIM(@Ac_Notice_ID))) + '>' + @Ls_xml_Result_TEXT + '</' + LOWER(LTRIM(RTRIM(@Ac_Notice_ID))) + '>'
							
							IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
								BEGIN
									SET @As_XmlOut_TEXT = @Ls_xml_Result_TEXT;
									RETURN;
								END
						END
					
					IF		@Ls_xml_Result_TEXT != ''
					   AND	@Ls_xml_Result_TEXT IS NOT NULL
						BEGIN
							
							IF @Ac_PrintMethod_CODE != @Lc_PrintMethod_View_TEXT
								BEGIN
									
									

									INSERT INTO dbo.IdentSeqNoBarcode_T1
										VALUES (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME());

									SET @Ln_BarcodeOut_NUMB = @@IDENTITY;
									
									
								   
									INSERT INTO #NoticeElementsData_P1
										VALUES('Barcode_NUMB',
											   CAST(@Ln_BarcodeOut_NUMB AS VARCHAR));
									
									SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS - 2';
								    SET @Ls_Sqldata_TEXT = ' NOTICE_ID: ' + ISNULL(@Ac_Notice_ID, '') 
														 + ' Case_IDNO: ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR);
									
									-- Gets NMRQ/NRRQ office worker details   
									EXEC BATCH_GEN_NOTICES$SP_GET_ENVELOPE_ADDRESS_DETAILS
												@An_Case_IDNO             = @An_Case_IDNO,
												@Ac_Notice_ID             = @Ac_Notice_ID,
												@Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
												@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

									IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
										BEGIN
											 IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
											  BEGIN
											   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$SP_GET_TLE_WORKER_DETAILS - 2' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + SUBSTRING (@As_DescriptionError_TEXT, 1, 4000);
											  END
											 ELSE
											  BEGIN
											   SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$SP_GET_TLE_WORKER_DETAILS - 2' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
											  END
											
										END
									 
									 -- Suppressing Country if it is US issue caused due to second address
									UPDATE #NoticeElementsData_P1
									   SET Element_VALUE = ''
									 WHERE Element_NAME LIKE '%_country_addr'
									   AND LTRIM(RTRIM(Element_VALUE)) = 'US';

									SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA - 2';
								    SET @Ls_Sqldata_TEXT = ' PrintMethod_CODE: ' + ISNULL(@Ac_PrintMethod_CODE, '') 
														 + ' BarcodeIn_NUMB: ' + CAST(ISNULL(@An_Barcode_NUMB, 0) AS VARCHAR)
														 + ' Barcode_NUMB: ' + CAST(ISNULL(@Ln_BarcodeOut_NUMB, 0) AS VARCHAR)
														 + ' Generate_DATE: ' + CAST(ISNULL(@Ad_Generate_DATE, '') AS VARCHAR)
														 + ' TransactionEventSeq_NUMB: ' + CAST(ISNULL(@An_TransactionEventSeq_NUMB, 0) AS VARCHAR)
														 + ' Xml_TEXT: ' + ISNULL(@Ls_result_TEXT, '')
														 + ' TypeService_CODE: ' + ISNULL(@Ac_TypeService_CODE, '')
														 + ' TypeAddress_CODE: ' + ISNULL(@Ac_TypeAddress_CODE, '');
									
									EXEC BATCH_GEN_NOTICES$INSERT_NOTICE_DATA
													  @Ac_PrintMethod_CODE         = @Ac_PrintMethod_CODE,
													  @An_BarcodeIn_NUMB		   = @An_Barcode_NUMB,
													  @An_Barcode_NUMB             = @Ln_BarcodeOut_NUMB,
													  @Ad_Generate_DATE            = @Ad_Generate_DATE,
													  @An_TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
													  @As_Xml_TEXT                 = @Ls_xml_Result_TEXT,
													  @Ac_TypeService_CODE		   = @Ac_TypeService_CODE,
													  @Ac_TypeAddress_CODE		   = @Ac_TypeAddress_CODE,
													  @Ac_Msg_CODE                 = @Ac_Msg_CODE OUTPUT,
													  @As_DescriptionError_TEXT    = @As_DescriptionError_TEXT OUTPUT;
									
									IF @Ac_Msg_CODE != @Lc_StatusSuccess_CODE
										  BEGIN
											   IF LTRIM(RTRIM(@As_DescriptionError_TEXT)) IS NULL
												BEGIN
												 SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + SUBSTRING (@As_DescriptionError_TEXT, 1, 4000);
												END
											   ELSE
												BEGIN
												 SET @As_DescriptionError_TEXT = ISNULL(@Ls_Routine_TEXT, '') + ' ' + 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '') + ' ' + ISNULL(@As_DescriptionError_TEXT, '');
												END
											   RAISERROR(50001,16,1)
										  END
								END
							ELSE
								BEGIN
									SET @As_XmlOut_TEXT = @Ls_xml_Result_TEXT;
									
									SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
								END
						END
					ELSE
						BEGIN
							 SET @Ls_Proc_NAME = 'BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML'
							 SET @Ls_Sql_TEXT = 'XML Generated Is Empty';
							 SET @Ls_Sqldata_TEXT = '@Ac_Notice_ID: ' + @Ac_Notice_ID + ' @An_Case_IDNO: ' + CAST(@An_Case_IDNO AS CHAR) + ' @Ac_Worker_ID: ' + @Ac_Worker_ID + ' @An_MemberMci_IDNO: ' + CAST(@An_MemberMci_IDNO AS CHAR) + ' @An_OthpSource_IDNO: ' + CAST(@An_OthpSource_IDNO AS CHAR);

							 RAISERROR(50001,16,1);
						END
				END
				
				--13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -Start
				IF @Ac_PrintMethod_CODE = @Lc_PrintMethod_View_TEXT AND @Ac_Notice_ID = @Lc_Leg191fNotice_ID
				  BEGIN
					  SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV';
					  SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR) 
											 + ' Notice_ID: ' + CAST(ISNULL(@Ac_Notice_ID, '') AS VARCHAR)
											 + ' Recipient_CODE: ' + CAST(ISNULL(@Ac_Recipient_CODE, '') AS VARCHAR)
											 + ' Recipient_ID: ' + CAST(ISNULL(@Ac_Recipient_ID, '') AS VARCHAR)
											 + ' XmlInput_TEXT: ' + CAST(ISNULL(@As_XmlOut_TEXT, '') AS VARCHAR(MAX))
					  EXECUTE BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV
					  @An_Case_IDNO             = @An_Case_IDNO,
					  @Ac_Notice_ID             = @Ac_Notice_ID,
					  @Ac_Recipient_CODE        = @Ac_Recipient_CODE,
					  @Ac_Recipient_ID          = @Ac_Recipient_ID,
					  @As_XmlInput_TEXT         = @As_XmlOut_TEXT,
					  @As_XmlOut_TEXT           = @Ls_MaskedNoticeXml_TEXT OUTPUT,
					  @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
					  @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

					 IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
					  BEGIN
					   RAISERROR (50001,16,1);
					  END
					
					 SET @As_XmlOut_TEXT = @Ls_MaskedNoticeXml_TEXT;
				 END
				 --13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -End
	 
     SET @An_BarcodeOut_NUMB = @Ln_BarcodeOut_NUMB;
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
     
    END
  END TRY

  BEGIN CATCH
   IF CURSOR_STATUS ('local', '@Ls_InsertInput_CUR') IN (0, 1)
    BEGIN
     CLOSE @Ls_InsertInput_CUR

     DEALLOCATE @Ls_InsertInput_CUR
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE (), '') + ' Procedure' 
								  + '. Error Desc - ' + ISNULL(@As_DescriptionError_TEXT, '')
								  + '. Error Execute Location - ' + ISNULL(@Ls_Sql_TEXT, '') 
								  + '. Error List Key - ' + ISNULL(@Ls_Sqldata_TEXT, '');
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE (),'') + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
