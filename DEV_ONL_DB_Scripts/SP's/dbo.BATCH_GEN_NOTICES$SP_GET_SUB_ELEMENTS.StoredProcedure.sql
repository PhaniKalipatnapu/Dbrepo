/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS gets sub element values of repeating elements in Notice
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_GET_PROCEDURE_NAME
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS]
 @As_Proc_NAME             VARCHAR(75),
 @An_MemberMci_IDNO		   NUMERIC(10) = 0,
 @An_Seq_NUMB              NUMERIC(6),
 @As_Result_TEXT           VARCHAR(MAX) OUTPUT,
 @Ac_Msg_CODE              CHAR (5) OUTPUT ,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
 
  SET NOCOUNT ON;
  
  CREATE TABLE #SubValues_P1
   (
     ELEMENT_NAME  VARCHAR(200),
     ELEMENT_VALUE VARCHAR(500)
   );

  --13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - Start  
  CREATE TABLE #SubElements6_P1
  (  
	   OrderEnt_DATE VARCHAR(100),
       File_ID VARCHAR(100),
       CASE_IDNO VARCHAR(100),
       ROWNUM VARCHAR(100) 
  );
 --13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - End
 
  DECLARE @Ls_ErrorDesc_TEXT                     VARCHAR(4000),
          @Ls_Sql_TEXT                           VARCHAR(100) = '',
          @Ls_Sqldata_TEXT                       VARCHAR (1000) = '',
          @Ls_DescriptionError_TEXT              VARCHAR(4000),
          @Ls_Output_TEXT                        VARCHAR(MAX) = '',
          @Ln_Case_IDNO                          NUMERIC(6),
          @Ls_XMLParent_Element_NAME             VARCHAR(MAX),
          @Lc_Notice_ID                          VARCHAR(8),
          @Ls_AssetOpt_TEXT                      VARCHAR(15) = 'ASS1',
          @Ld_Run_DATE                           DATETIME2,
          @Ln_NcpMemberMci_IDNO                  NUMERIC(10),
          @Ln_CpMemberMci_IDNO                   NUMERIC(10),
          @Ln_MemberMci_IDNO                     NUMERIC(10),
          @inputParamValue_TEXT                  VARCHAR(300),
          @inputParam_TEXT                       VARCHAR(100),
          @Ls_ColumnName_List_TEXT               VARCHAR(max),
          @Ls_SQLString_TEXT                     VARCHAR(max),
          @Ln_Counter_NUMB                       INT,
          @Ls_Line1_ADDR                         VARCHAR(50),
          @Ls_Line2_ADDR                         VARCHAR(50),
          @Ls_Line3_ADDR                         VARCHAR(50),
          @Ls_City_ADDR                          VARCHAR(28),
          @Ls_State_ADDR                         VARCHAR(2),
          @Ls_Zip_ADDR                           VARCHAR(15),
          @Ls_Attn_ADDR                          VARCHAR(40),
          @Ln_Recipient_IDNO                     VARCHAR(10),
          @Ln_Application_IDNO                   NUMERIC(15),
          @Ln_FatherMci_IDNO                     NUMERIC(10),
          @Ln_MotherMci_IDNO                     NUMERIC(10),
          @GetMultiple_Records_CUR               CURSOR,
          @GetFormat_Element_CUR                 CURSOR,
          @Ls_Element_TEXT                       VARCHAR(100),
          @Ls_Element_NAME                       VARCHAR(100),
          @Ls_ElementValue_TEXT                  VARCHAR(MAX),
          @Ls_Element_VALUE                      VARCHAR(300),
          @Ls_Ele_Format_CODE                    VARCHAR(100),
          @Ls_Format_CODE                        VARCHAR(10),
          @Ls_SQLParameterString_TEXT            VARCHAR(MAX),
          @Ls_ParmDefinition_TEXT                NVARCHAR(MAX),
          @Ls_SQLProcName_TEXT                   VARCHAR(75),
          @Ls_Dyn_SQLString_TEXT                 NVARCHAR(MAX),
          @As_FormattedResult_TEXT               VARCHAR(MAX),
          @Ls_SubElementQryString_TEXT           NVARCHAR(MAX),
          @Ls_SubElementsXml_TEXT                VARCHAR(MAX),
          @Ln_RowCount_NUMB                      NUMERIC,
          @Ls_ExecString_TEXT                    VARCHAR(MAX),
          @Lc_StatusSuccess_CODE                 CHAR,
          @Ls_SelectColumnList_TEXT              VARCHAR(max),
          @Ls_TableName_TEXT                     VARCHAR(50),
          @Ln_StringLen_NUMB                     NUMERIC,
          @Lc_StatusFailed_CODE                  CHAR,
          @Ln_RowCount1_NUMB                     NUMERIC,
          @Ln_RowCount2_NUMB                     NUMERIC,
          @Ln_RowCount3_NUMB                     NUMERIC,
          @Ln_RowCount5_NUMB                     NUMERIC,
          @Ln_RowCount6_NUMB                     NUMERIC,
          @Ln_RowCount7_NUMB                     NUMERIC,
          @Ln_RowCount8_NUMB                     NUMERIC,
          @Ln_RowCount9_NUMB                     NUMERIC,
          @Ln_RowCount10_NUMB                    NUMERIC,
          @Ln_RowCount11_NUMB                    NUMERIC,
          @Ln_RowCount12_NUMB                    NUMERIC,
          @Ln_RowCount13_NUMB                    NUMERIC,
          @Ln_RowCount14_NUMB                    NUMERIC,
          @Ln_RowCount15_NUMB                    NUMERIC,
          @Ln_RowCount16_NUMB                    NUMERIC,
          @Ln_RowCount17_NUMB                    NUMERIC,
          @Ln_RowCount18_NUMB                    NUMERIC,
          @Ln_RowCount19_NUMB                    NUMERIC,
          @Ln_RowCount20_NUMB                    NUMERIC,
          @Ln_RowCount21_NUMB                    NUMERIC,
          @Ln_RowCount22_NUMB                    NUMERIC,
          @Ln_RowCount23_NUMB                    NUMERIC,
          @Ln_RowCount24_NUMB                    NUMERIC,
          @Ln_RowCount25_NUMB					 NUMERIC,
		  @Ln_RowCount26_NUMB					 NUMERIC,
		  @Ln_RowCount27_NUMB					 NUMERIC,
		  @Ln_RowCount28_NUMB					 NUMERIC,
		  @Ln_RowCount29_NUMB					 NUMERIC,
		  @Ln_RowCount30_NUMB					 NUMERIC,
		  @Ln_RowCount31_NUMB					 NUMERIC,
		  @Ln_RowCount32_NUMB					 NUMERIC,
		  @Ln_RowCount33_NUMB					 NUMERIC,
		  @Ln_RowCount34_NUMB					 NUMERIC,
		  @Ln_RowCount35_NUMB					 NUMERIC,
		  @Ln_RowCount36_NUMB					 NUMERIC,
		  @Ln_RowCount37_NUMB					 NUMERIC,
		  @Ln_RowCount38_NUMB					 NUMERIC,
		  @Ln_RowCount39_NUMB					 NUMERIC,
		  @Ln_RowCount40_NUMB					 NUMERIC,
          @Ln_RequiredFieldCount_NUMB			 NUMERIC,
          @Ls_SubElementsTotalEle_TEXT           VARCHAR(MAX),
          @Ls_SubElementsTotalList_TEXT          VARCHAR(MAX),
          @Ls_SubElementsTotalEleColumnList_TEXT NVARCHAR(MAX),
          @Ls_TolSubElementsOutput_TEXT          VARCHAR(MAX),
          @Lc_Mask_INDC							 CHAR(1),
          @Ln_Zero_NUMB                          NUMERIC,
          @Ls_Routine_TEXT                       VARCHAR(70) = 'BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS',
		  @Ln_OrderSeq_NUMB						 NUMERIC(2),
		  @Ln_MajorIntSeq_NUMB					 NUMERIC(5),
		  @Ln_OthpSource_IDNO					 NUMERIC(9),
		  @Ln_Schedule_NUMB						 NUMERIC(10),
		  @Lc_Worker_ID							 CHAR(30),
		  --13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - Start
		  @Lc_Reference_ID						 CHAR(30);
		  --13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - End
	        DECLARE @NoticeElementsData_P1 TABLE(
           Element_NAME  VARCHAR(150),
           Element_VALUE VARCHAR(MAX)
       ); 
  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';
  SET @Ln_Zero_NUMB = 0;

  BEGIN TRY
  
   INSERT INTO @NoticeElementsData_P1 --VALUES(Element_NAME,Element_VALUE)
              SELECT Element_NAME,Element_VALUE FROM #NoticeElementsData_P1;
   --Cursor gets input values from temp table(#NoticeElementsData_P1) and assign @Ln_Case_IDNO and @Ls_Notice_IDNO in order to use to get Putative Father Lust          
	SET @Ac_Msg_CODE = '';
	SET @As_DescriptionError_TEXT = '';

	SET @GetMultiple_Records_CUR = CURSOR FOR
			SELECT ELEMENT_NAME,
				   ELEMENT_VALUE
			  FROM @NoticeElementsData_P1
			 WHERE ELEMENT_NAME IN ('CASE_IDNO', 'NOTICE_ID', 'MEMBERMCI_IDNO', 'APPLICATION_IDNO', 'Recipient_ID', 'GENERATE_DATE','SCHEDULE_NUMB');

   OPEN @GetMultiple_Records_CUR

   FETCH NEXT FROM @GetMultiple_Records_CUR INTO @inputParam_TEXT, @inputParamValue_TEXT;

   WHILE @@FETCH_STATUS = 0
    BEGIN
     IF @inputParam_TEXT = 'CASE_IDNO'
      SET @Ln_Case_IDNO = @inputParamValue_TEXT;

     IF @inputParam_TEXT = 'NOTICE_ID'
      SET @Lc_Notice_ID = @inputParamValue_TEXT;

     IF @inputParam_TEXT = 'MEMBERMCI_IDNO'
      SET @Ln_MemberMci_IDNO = @inputParamValue_TEXT;

     IF @inputParam_TEXT = 'APPLICATION_IDNO'
      SET @Ln_Application_IDNO = @inputParamValue_TEXT;

     IF @inputParam_TEXT = 'Recipient_ID'
      SET @Ln_Recipient_IDNO = @inputParamValue_TEXT;
     
     IF @inputParam_TEXT = 'GENERATE_DATE'
		SET @Ld_Run_DATE = @inputParamValue_TEXT;
		
	 IF @inputParam_TEXT = 'SCHEDULE_NUMB'
		SET @Ln_Schedule_NUMB = @inputParamValue_TEXT;	

     FETCH NEXT FROM @GetMultiple_Records_CUR INTO @inputParam_TEXT, @inputParamValue_TEXT;
    END

   CLOSE @GetMultiple_Records_CUR;

   DEALLOCATE @GetMultiple_Records_CUR;

   SET @Ln_OrderSeq_NUMB = (SELECT Element_VALUE
							  FROM @NoticeElementsData_P1
							 WHERE Element_NAME = 'orderseq_numb');
   

   SET @Ls_Sqldata_TEXT = 'Cp_MemberMci_IDNO';

   SELECT @Ln_CpMemberMci_IDNO =  Element_VALUE      
	 FROM @NoticeElementsData_P1      
	WHERE Element_NAME = 'Cp_MemberMci_IDNO';
      
	   
   SET @Ls_Sqldata_TEXT = 'Ncp_MemberMci_IDNO';

   SELECT @Ln_NcpMemberMci_IDNO = Element_VALUE      
	 FROM @NoticeElementsData_P1      
	WHERE Element_NAME = 'Ncp_MemberMci_IDNO';
   
   SET @Ln_MajorIntSeq_NUMB = (SELECT Element_VALUE
								 FROM @NoticeElementsData_P1
								WHERE Element_NAME = 'MajorIntSeq_NUMB');
   
   SET @Ln_FatherMci_IDNO = (SELECT DISTINCT
									CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE
							   FROM @NoticeElementsData_P1
							 WHERE Element_NAME = 'FATHERMCI_IDNO');
   
   SET @Ln_MotherMci_IDNO = (SELECT DISTINCT
									CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE
							   FROM @NoticeElementsData_P1
							  WHERE Element_NAME = 'MOTHERMCI_IDNO');
   
   
    IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_PF_DETAILS'
		BEGIN
		     --12590 - Pending CR - CSI-02-Waiver side-printing on 2 pages when signature is captured. Fix - Start
			 SELECT *
			   INTO #SubElements1_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_PF_DETAILS(@Ln_Case_IDNO ,@Lc_Notice_ID)) AS Tmp_P1;
			 --12590 - Pending CR - CSI-02-Waiver side-printing on 2 pages when signature is captured. Fix - End
			 SET @Ln_RowCount1_NUMB =(SELECT COUNT(*)
										FROM #SubElements1_P1);
		                                
			 SET @Ls_TableName_TEXT = '#SubElements1_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount1_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_DETAILS'
		BEGIN
			--12955 - CR0320 Change to NMSN Eligibility and ENF-03 Mapping 20131115 Fix - Start
			 SELECT *
			   INTO #SubElements2_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_DETAILS(@Ln_Case_IDNO, @Ld_Run_DATE,@Lc_Notice_ID)) AS Tmp_P1;
		    --12955 - CR0320 Change to NMSN Eligibility and ENF-03 Mapping 20131115 Fix - End
			 SET @Ln_RowCount2_NUMB = (SELECT COUNT(*)
										 FROM #SubElements2_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements2_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount2_NUMB;
		END
		ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_DETAILS_EST_NOTICES'
		BEGIN
			
			 SELECT *
			   INTO #SubElements38_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_DETAILS_EST_NOTICES(@Ln_Case_IDNO, @Ld_Run_DATE)) AS Tmp_P1;
		             
			 SET @Ln_RowCount38_NUMB = (SELECT COUNT(*)
										 FROM #SubElements38_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements38_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount38_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_OBLE_DEPENDENT_DTLS'
		BEGIN
			 SELECT *
			   INTO #SubElements15_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_OBLE_DEPENDENT_DTLS(@Ln_Case_IDNO, @Ld_Run_DATE)) AS Tmp_P1;

			 SET @Ln_RowCount15_NUMB = (SELECT COUNT(*)
										  FROM #SubElements15_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements15_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount15_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_CP_DISBURSEMENT_DTLS'
		BEGIN
			 SELECT *
			   INTO #SubElements16_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_CP_DISBURSEMENT_DTLS(@Ln_Case_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount16_NUMB = (SELECT COUNT(*)
										  FROM #SubElements16_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements16_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount16_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_NCP_PAYMENTS_DTLS'
		BEGIN
			 SELECT *
			   INTO #SubElements37_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_NCP_PAYMENTS_DTLS(@Ln_Case_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount37_NUMB = (SELECT COUNT(*)
										  FROM #SubElements37_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements37_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount37_NUMB;
		END	
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_RECIPIENT_CASE_LIST'      
		BEGIN
			 IF @Lc_Notice_ID IN ('LOC-02', 'CSM-01')
				BEGIN
					SET @Ln_Recipient_IDNO = @Ln_MemberMci_IDNO;
				END
			 ELSE IF @Lc_Notice_ID = 'LOC-03'
				BEGIN
					SET @Ln_Recipient_IDNO = @Ln_CpMemberMci_IDNO;
				END
			 ELSE IF @Lc_Notice_ID = 'LOC-04'
				BEGIN
					IF @Ln_NcpMemberMci_IDNO = 0 OR @Ln_NcpMemberMci_IDNO IS NULL 
					BEGIN
						SET @Ln_NcpMemberMci_IDNO = @Ln_MemberMci_IDNO
					END
					SET @Ln_Recipient_IDNO = @Ln_NcpMemberMci_IDNO;
				END
				
			 SELECT *
			   INTO #SubElements3_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICES$SF_GET_RECIPIENT_CASE_LIST(@Ln_Recipient_IDNO)) AS Tmp_P1;
		     
			 SET @Ln_RowCount3_NUMB = (SELECT COUNT(*)
										 FROM #SubElements3_P1);
			
			 SET @Ls_TableName_TEXT = '#SubElements3_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount3_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_CP_CASE_LIST'          
		BEGIN
			
			 SELECT *
			   INTO #SubElements21_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_CP_CASE_LIST(@Ln_CpMemberMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount21_NUMB = (SELECT COUNT(*)
										  FROM #SubElements21_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements21_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount21_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_NCP_CASE_LIST'        
		BEGIN
			 
			 SELECT *
			   INTO #SubElements25_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_NCP_CASE_LIST(@Ln_NcpMemberMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount25_NUMB = (SELECT COUNT(*)
										  FROM #SubElements25_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements25_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount25_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_IVA_IVE_CASE_LIST'        
		BEGIN
			
			 SELECT *
			   INTO #SubElements22_P1
			   FROM (
			   SELECT *
					   FROM dbo.BATCH_GEN_NOTICES$SF_GET_IVA_IVE_CASE_LIST(@Ln_CpMemberMci_IDNO, @Ld_Run_DATE)) AS Tmp_P1;
		     
			 SET @Ln_RowCount22_NUMB = (SELECT COUNT(*)
										  FROM #SubElements22_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements22_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount22_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_FIN_ASSET_LIST'
		BEGIN
			--13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - Start
			 SELECT @Ln_OthpSource_IDNO = OthpSource_IDNO, @Lc_Reference_ID = Reference_ID
			   FROM DMJR_Y1
			  WHERE Case_IDNO = @Ln_Case_IDNO
			    AND MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB;
			
			 IF @Ln_MemberMci_IDNO <> 0
				 AND @Ln_MemberMci_IDNO IS NOT NULL
				BEGIN
					
					 SELECT *
						INTO #SubElements5_P1
						FROM (
						SELECT * 
							FROM dbo.BATCH_GEN_NOTICES$SF_GET_FIN_ASSET_LIST(@Ln_NcpMemberMci_IDNO, @Ln_OthpSource_IDNO, @Lc_Reference_ID)) AS Tmp_P1;
			--13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - End		
					SET @Ln_RowCount5_NUMB = (SELECT COUNT(*)
											   FROM #SubElements5_P1);
			       
					SET @Ls_TableName_TEXT = '#SubElements5_P1';
					SET @Ln_RowCount_NUMB = @Ln_RowCount5_NUMB;
				END
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_NCP_FIDM_CASE_LIST'
		BEGIN
			 
			 IF @Ln_MemberMci_IDNO <> 0
				 AND @Ln_MemberMci_IDNO IS NOT NULL
				BEGIN
					--13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - Start
					IF @Lc_Notice_ID = 'ENF-41' OR @Lc_Notice_ID = 'ENF-43' OR @Lc_Notice_ID = 'ENF-53'
						BEGIN
							
							INSERT INTO #SubElements6_P1
						    SELECT * FROM dbo.BATCH_GEN_NOTICES$SF_GET_NCP_FIDM_CASE_LIST(@Ln_NcpMemberMci_IDNO, @Ln_MajorIntSeq_NUMB, @Ln_Case_IDNO) AS Tmp_P1;   

						END
					ELSE
						BEGIN
							
							INSERT INTO #SubElements6_P1
							SELECT * FROM dbo.BATCH_GEN_NOTICES$SF_GET_NCP_FIDM_CASE_LIST(@Ln_NcpMemberMci_IDNO, @Ln_MajorIntSeq_NUMB, DEFAULT) AS Tmp_P1;	
					
						END   
					--13020 - CR0331 Modify FIDM Forms to List One Account Per Notice - End	
				   SET @Ln_RowCount6_NUMB = (SELECT COUNT(*)
											   FROM #SubElements6_P1);
			       
				   SET @Ls_TableName_TEXT = '#SubElements6_P1';
				   SET @Ln_RowCount_NUMB = @Ln_RowCount6_NUMB;
				END
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_CONCEPTION_DTLS'
		BEGIN
			 SELECT *
			   INTO #SubElements7_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_CONCEPTION_DTLS(@Ln_Case_IDNO, @Ld_Run_DATE)) AS Tmp_P1;
			 SET @Ln_RowCount7_NUMB = (SELECT COUNT(*)
										 FROM #SubElements7_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements7_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount7_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_FATHER_ASSET_INFO '
		BEGIN
			 
			 SELECT *
			   INTO #SubElements8_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_FATHER_ASSET_INFO(@Ln_FatherMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount8_NUMB = (SELECT COUNT(*)
										 FROM #SubElements8_P1);
			 
			 SET @Ls_TableName_TEXT = '#SubElements8_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount8_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_MOTHER_ASSET_INFO'
		BEGIN
			 
			 SELECT *
			   INTO #SubElements9_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_MOTHER_ASSET_INFO(@Ln_MotherMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount9_NUMB = (SELECT COUNT(*)
										 FROM #SubElements9_P1);
		                                 
			 SET @Ls_TableName_TEXT = '#SubElements9_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount9_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_MOTOR_VEHICLE_INFO'
		BEGIN
			 
			 SELECT *
			   INTO #SubElements10_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_MOTOR_VEHICLE_INFO(@Ln_CpMemberMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount10_NUMB = (SELECT COUNT(*)
										  FROM #SubElements10_P1);

			 SET @Ls_TableName_TEXT = '#SubElements10_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount10_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_ASFN_ASSETTYPE1_INFO'
		BEGIN
			 SELECT *
			   INTO #SubElements11_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_ASFN_ASSETTYPE1_INFO(@Ln_CpMemberMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount11_NUMB = (SELECT COUNT(*)
										  FROM #SubElements11_P1);
			
			 SET @Ls_TableName_TEXT = '#SubElements11_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount11_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_ASFN_ASSETTYPE2_INFO'
		BEGIN
			 SELECT *
			   INTO #SubElements12_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_ASFN_ASSETTYPE2_INFO(@Ln_CpMemberMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount12_NUMB = (SELECT COUNT(*)
										  FROM #SubElements12_P1);
				
			 SET @Ls_TableName_TEXT = '#SubElements12_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount12_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_DEP_PAT_DETAILS'
		BEGIN
			 
			 SET @Ls_Line1_ADDR = '';
			 SET @Ls_Line2_ADDR = '';
			 SET @Ls_Line3_ADDR = '';
			 SET @Ls_City_ADDR = '';
			 SET @Ls_State_ADDR = '';
			 SET @Ls_Zip_ADDR = '';

			 IF (@Ln_Case_IDNO IS NOT NULL
				 AND @Ln_Case_IDNO <> 0)
			  BEGIN
			   EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_ADDRESS
				@An_MemberMci_IDNO        = @Ln_CpMemberMci_IDNO,
				@Ad_Run_DATE              = @Ld_Run_DATE,
				@As_Prefix_TEXT           = 'CP',
				@Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
				@As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
				
				IF @Ac_Msg_CODE = 'F'
					BEGIN
						RETURN;
					END

			   SET @Ls_Attn_ADDR = (SELECT DISTINCT
										   ISNULL(CONVERT(VARCHAR(MAX), Element_VALUE), '') AS Element_VALUE
									  FROM #NoticeElementsData_P1
									 WHERE Element_NAME = 'CP_ADDR_ATTN');
			   SET @Ls_Line1_ADDR = (SELECT ISNULL(CONVERT(VARCHAR(MAX), Element_VALUE), '') AS Element_VALUE
									   FROM #NoticeElementsData_P1
									  WHERE Element_NAME = 'CP_ADDR_LINE1');
			   SET @Ls_Line2_ADDR = (SELECT ISNULL(CONVERT(VARCHAR(MAX), Element_VALUE), '') AS Element_VALUE
									   FROM #NoticeElementsData_P1
									  WHERE Element_NAME = 'CP_ADDR_LINE2');
			   SET @Ls_Line3_ADDR = (SELECT ISNULL(CONVERT(VARCHAR(MAX), Element_VALUE), '') AS Element_VALUE
									   FROM #NoticeElementsData_P1
									  WHERE Element_NAME = 'CP_ADDR_LINE3');
			   SET @Ls_City_ADDR = (SELECT ISNULL(CONVERT(VARCHAR(MAX), Element_VALUE), '') AS Element_VALUE
									  FROM #NoticeElementsData_P1
									 WHERE Element_NAME = 'CP_ADDR_CITY');
			   SET @Ls_State_ADDR = (SELECT ISNULL(CONVERT(VARCHAR(MAX), Element_VALUE), '') AS Element_VALUE
									   FROM #NoticeElementsData_P1
									  WHERE Element_NAME = 'CP_ADDR_ST');
			   SET @Ls_Zip_ADDR = (SELECT ISNULL(CONVERT(VARCHAR(MAX), Element_VALUE), '') AS Element_VALUE
									 FROM #NoticeElementsData_P1
									WHERE Element_NAME = 'CP_ADDR_ZIP');
			  END

			 SELECT *
			   INTO #SubElements14_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_DEP_PAT_DETAILS(@Ln_Case_IDNO, @Ld_Run_DATE, @Ls_Attn_ADDR, @Ls_Line1_ADDR, @Ls_Line2_ADDR, @Ls_Line3_ADDR, @Ls_City_ADDR, @Ls_State_ADDR, @Ls_Zip_ADDR)) AS Tmp_P1;

			 SET @Ln_RowCount14_NUMB = (SELECT COUNT(*)
										  FROM #SubElements14_P1);
				
			 SET @Ls_TableName_TEXT = '#SubElements14_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount14_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_CASE_ORDER_DTLS'
		BEGIN
			 	 
			 SELECT *
			   INTO #SubElements13_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_CASE_ORDER_DTLS(@Ln_Case_IDNO, @Ld_Run_DATE, @Ln_NcpMemberMci_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount13_NUMB =(SELECT COUNT(*)
										 FROM #SubElements13_P1);
				
			 SET @Ls_TableName_TEXT = '#SubElements13_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount13_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_APRE_CP_DETAILS'
		BEGIN
			
			 IF @Ln_Application_IDNO = 0 OR @Ln_Application_IDNO IS NULL
				SET @Ln_RowCount28_NUMB = 0;
			 
			 IF (@Ln_Application_IDNO != 0 AND @Ln_Application_IDNO IS NOT NULL)
				BEGIN
					 SELECT *
					   INTO #SubElements28_P1
					   FROM (SELECT *
							   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_APRE_CP_DETAILS(@Ln_Application_IDNO, @Ld_Run_DATE)) AS Tmp_P1;

					 SET @Ln_RowCount28_NUMB =(SELECT COUNT(*)
												 FROM #SubElements28_P1);
					 
					 SET @Ls_TableName_TEXT = '#SubElements28_P1';
					 SET @Ln_RowCount_NUMB = @Ln_RowCount28_NUMB;
				END
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_APRE_NCP_DETAILS'
		BEGIN
			
			 IF @Ln_Application_IDNO = 0 OR @Ln_Application_IDNO IS NULL
				SET @Ln_RowCount29_NUMB = 0;
			 
			 IF (@Ln_Application_IDNO != 0 AND @Ln_Application_IDNO IS NOT NULL)
				BEGIN
					 SELECT *
					   INTO #SubElements29_P1
					   FROM (SELECT *
							   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_APRE_NCP_DETAILS(@Ln_Application_IDNO, @An_MemberMci_IDNO , @Ld_Run_DATE)) AS Tmp_P1;

					 SET @Ln_RowCount29_NUMB =(SELECT COUNT(*)
												 FROM #SubElements29_P1);
					 
					 SET @Ls_TableName_TEXT = '#SubElements29_P1';
					 SET @Ln_RowCount_NUMB = @Ln_RowCount29_NUMB;
				END
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_ALSP_LIST'
		BEGIN
			
			 IF @Ln_Application_IDNO = 0 OR @Ln_Application_IDNO IS NULL
				SET @Ln_RowCount30_NUMB = 0;
			 
			 IF (@Ln_Application_IDNO != 0 AND @Ln_Application_IDNO IS NOT NULL)
				BEGIN
					 SELECT *
					   INTO #SubElements30_P1
					   FROM (SELECT *
							   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_ALSP_LIST(@Ln_Application_IDNO, @An_MemberMci_IDNO)) AS Tmp_P1;

					 SET @Ln_RowCount30_NUMB =(SELECT COUNT(*)
												 FROM #SubElements30_P1);
					 
					 IF (SELECT SUM(CAST(owed_amnt AS MONEY)) FROM #SubElements30_P1) = 0
					 	BEGIN
					 		 INSERT INTO #NoticeElementsData_P1
					 			VALUES('tot_owed_amnt', '');
					 	END
					 ELSE
					 	BEGIN
					 		 INSERT INTO #NoticeElementsData_P1
					 			VALUES('tot_owed_amnt', (SELECT CONVERT(VARCHAR, SUM(CAST(owed_amnt AS MONEY)), 1)
					 										FROM #SubElements30_P1));
					 	END
					 	
					 IF (SELECT SUM(CAST(balance_amnt AS MONEY)) FROM #SubElements30_P1) = 0
						BEGIN
							INSERT INTO #NoticeElementsData_P1
					 			VALUES('tot_balance_amnt', '');
						END
					 ELSE
						BEGIN
							 INSERT INTO #NoticeElementsData_P1
								VALUES('tot_balance_amnt', (SELECT CONVERT(VARCHAR, SUM(CAST(balance_amnt AS MONEY)), 1)
															FROM #SubElements30_P1));
						END
					 
					 IF (SELECT SUM(CAST(paid_amnt AS MONEY)) FROM #SubElements30_P1) = 0
						BEGIN
							INSERT INTO #NoticeElementsData_P1
					 			VALUES('tot_paid_amnt', '');
						END
					 ELSE
						BEGIN
							 INSERT INTO #NoticeElementsData_P1
								VALUES('tot_paid_amnt', (SELECT CONVERT(VARCHAR, SUM(CAST(paid_amnt AS MONEY)), 1)
															FROM #SubElements30_P1));
						END
						
					 SET @Ls_TableName_TEXT = '#SubElements30_P1';
					 SET @Ln_RowCount_NUMB = @Ln_RowCount30_NUMB;
				END
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_GENETIC_DEPENDENT_DETAILS'
		BEGIN
			 IF @Ln_Schedule_NUMB = 0 OR ISNULL(@Ln_Schedule_NUMB,0) = 0
			 BEGIN
				SELECT @Ln_Schedule_NUMB = MAX(s.Schedule_NUMB) 
				FROM SWKS_Y1 s JOIN DMNR_Y1 d 
				ON s.Schedule_NUMB = d.Schedule_NUMB
				AND d.Case_IDNO = @Ln_Case_IDNO
				AND d.Case_IDNO = s.Case_IDNO 
				AND d.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
			 END
			 SELECT *
			   INTO #SubElements31_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_GENETIC_DEPENDENT_DETAILS(@Ln_Case_IDNO,@Ln_Schedule_NUMB,@Lc_Notice_ID)) AS Tmp_P1;

			 SET @Ln_RowCount31_NUMB =(SELECT COUNT(*)
										 FROM #SubElements31_P1);
			 
			 SET @Ls_TableName_TEXT = '#SubElements31_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount31_NUMB;
		END
		-- Defect 12800 - CR0296 EST-10 and 11 Paternity Test Results 20131023 Fix - Start –
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_GENETIC_DEPENDENT_EXCLUDE_DETAILS'
		BEGIN
			 IF @Ln_Schedule_NUMB = 0 OR ISNULL(@Ln_Schedule_NUMB,0) = 0
			 BEGIN
				SELECT @Ln_Schedule_NUMB = MAX(s.Schedule_NUMB) 
				FROM SWKS_Y1 s JOIN DMNR_Y1 d 
				ON s.Schedule_NUMB = d.Schedule_NUMB
				AND d.Case_IDNO = @Ln_Case_IDNO
				AND d.Case_IDNO = s.Case_IDNO 
				AND d.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
			 END

			 SELECT *
			   INTO #SubElements39_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_GENETIC_DEPENDENT_EXCLUDE_DETAILS(@Ln_Case_IDNO,@Ln_Schedule_NUMB)) AS Tmp_P1;

			 SET @Ln_RowCount39_NUMB =(SELECT COUNT(*)
										 FROM #SubElements39_P1);
			 
			 SET @Ls_TableName_TEXT = '#SubElements39_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount39_NUMB;
		END	
		ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_GENETIC_DEPENDENT_INCLUDE_DETAILS'
		BEGIN
			 IF @Ln_Schedule_NUMB = 0 OR ISNULL(@Ln_Schedule_NUMB,0) = 0
			 BEGIN
				SELECT @Ln_Schedule_NUMB = MAX(s.Schedule_NUMB) 
				FROM SWKS_Y1 s JOIN DMNR_Y1 d 
				ON s.Schedule_NUMB = d.Schedule_NUMB
				AND d.Case_IDNO = @Ln_Case_IDNO
				AND d.Case_IDNO = s.Case_IDNO 
				AND d.MajorIntSeq_NUMB = @Ln_MajorIntSeq_NUMB
			 END

			 SELECT *
			   INTO #SubElements40_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_GENETIC_DEPENDENT_INCLUDE_DETAILS(@Ln_Case_IDNO,@Ln_Schedule_NUMB)) AS Tmp_P1;

			 SET @Ln_RowCount40_NUMB =(SELECT COUNT(*)
										 FROM #SubElements40_P1);
			 
			 SET @Ls_TableName_TEXT = '#SubElements40_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount40_NUMB;
		END	
		-- Defect 12800 - CR0296 EST-10 and 11 Paternity Test Results 20131023 Fix - End –
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_DEP_COVEREDBYCP_DENTALINS_DTLS'
		BEGIN
			
			 IF @Ln_Application_IDNO = 0 OR @Ln_Application_IDNO IS NULL
				SET @Ln_RowCount17_NUMB = 0;
			 
			 IF ((@Ln_Application_IDNO != 0 AND @Ln_Application_IDNO IS NOT NULL) AND (@Ln_CpMemberMci_IDNO != 0 AND @Ln_CpMemberMci_IDNO IS NOT NULL))
				BEGIN
					 SELECT *
					   INTO #SubElements17_P1
					   FROM (SELECT *
							   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_DEP_COVEREDBYCP_DENTALINS_DTLS(@Ln_Application_IDNO, @Ln_CpMemberMci_IDNO)) AS Tmp_P1;

					 SET @Ln_RowCount17_NUMB =(SELECT COUNT(*)
												 FROM #SubElements17_P1);
					 
					 SET @Ls_TableName_TEXT = '#SubElements17_P1';
					 SET @Ln_RowCount_NUMB = @Ln_RowCount17_NUMB;
				END
				
				
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_DEP_COVEREDBYCP_INS_DTLS'
		BEGIN
			
			 IF @Ln_Application_IDNO = 0 OR @Ln_Application_IDNO IS NULL
				BEGIN
					SET @Ln_RowCount18_NUMB = 0;
				END
			 
			 IF (@Ln_Application_IDNO != 0 AND @Ln_Application_IDNO IS NOT NULL) AND (@Ln_CpMemberMci_IDNO != 0 AND @Ln_CpMemberMci_IDNO IS NOT NULL)
				BEGIN
					SELECT *
					INTO #SubElements18_P1
					FROM  (SELECT *
							FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_DEP_COVEREDBYCP_INS_DTLS(@Ln_Application_IDNO, @Ln_CpMemberMci_IDNO)) AS Tmp_P1;
			
					SET @Ln_RowCount18_NUMB =(SELECT COUNT(*)
												FROM #SubElements18_P1);

					SET @Ls_TableName_TEXT = '#SubElements18_P1';
					SET @Ln_RowCount_NUMB = @Ln_RowCount18_NUMB;
				END
			 ELSE
				BEGIN
					SET @Ln_RowCount18_NUMB = 0;
				END
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_APRE_DEPENDENT_DETAILS'
		BEGIN
			 
			 SELECT *
			   INTO #SubElements19_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_APRE_DEPENDENT_DETAILS(@Ln_Application_IDNO)) AS Tmp_P1;

			 SET @Ln_RowCount19_NUMB =(SELECT COUNT(*)
										 FROM #SubElements19_P1);
				
			 SET @Ls_TableName_TEXT = '#SubElements19_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount19_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_CP_AMNT_DETAILS'
		BEGIN
			 
			 SELECT *
			   INTO #SubElements20_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICES$SF_GET_CP_AMNT_DETAILS(@Ln_CpMemberMci_IDNO, @Ld_Run_DATE)) AS Tmp_P1;

			 SET @Ln_RowCount20_NUMB =(SELECT COUNT(*)
										 FROM #SubElements20_P1);
				
			 SET @Ls_TableName_TEXT = '#SubElements20_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount20_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_GET_OVERPAY_DETAILS'
		BEGIN
			
			 SELECT *
			   INTO #SubElements23_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_FIN$SF_GET_OVERPAY_DETAILS(@Ln_Case_IDNO, @Lc_Notice_ID, @Ld_Run_DATE)) AS Tmp_P1;

			 SET @Ln_RowCount23_NUMB =(SELECT COUNT(*)
										 FROM #SubElements23_P1);
				
			 SET @Ls_TableName_TEXT = '#SubElements23_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount23_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_PAT_DEPENDENT_DETAILS '
		BEGIN
			
			 SELECT *
			   INTO #SubElements24_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_PAT_DEPENDENT_DETAILS (@Ln_Case_IDNO)) AS Tmp_P1;
			  
			  SET @Ln_RowCount24_NUMB =(SELECT COUNT(*)
										 FROM #SubElements24_P1);
			 
			 SET @Ls_TableName_TEXT = '#SubElements24_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount24_NUMB
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_OBGLR_FAILED_TO_PAY_CASE_LIST'
		BEGIN
			
			 SELECT *
			   INTO #SubElements26_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICES$SF_GET_OBGLR_FAILED_TO_PAY_CASE_LIST(@Ln_MemberMci_IDNO, @Ld_Run_DATE)) AS Tmp_P1;
		     
			 SET @Ln_RowCount26_NUMB = (SELECT COUNT(*)
										 FROM #SubElements26_P1)
		     
			 SET @Ls_TableName_TEXT = '#SubElements26_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount26_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_OBGLR_FAILED_TO_PAY_CASE_LIST2'
		BEGIN
			SELECT *
			   INTO #SubElements27_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICES$SF_GET_OBGLR_FAILED_TO_PAY_CASE_LIST2(@Ln_MemberMci_IDNO, @Ld_Run_DATE)) AS Tmp_P1;
		     
			 SET @Ln_RowCount27_NUMB = (SELECT COUNT(*)
										 FROM #SubElements27_P1)
		     
			 SET @Ls_TableName_TEXT = '#SubElements27_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount27_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_FIN$SF_QUERY_LSUP'
        BEGIN
              
               SELECT *
                 INTO #SubElements32_P1
                 FROM (SELECT *
                             FROM dbo.BATCH_GEN_NOTICE_FIN$SF_QUERY_LSUP(@Ln_Case_IDNO, @Ln_OrderSeq_NUMB)) AS Tmp_P1;

              SET @Ln_RowCount32_NUMB = (SELECT COUNT(*)
                                           FROM #SubElements32_P1)

                    SET @Ls_TableName_TEXT = '#SubElements32_P1';
              SET @Ln_RowCount_NUMB = @Ln_RowCount32_NUMB;
        END
    ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICES$SF_GET_LEG154DEPENDENT_DETAILS'
        BEGIN
            --13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - Start    
            SET @Lc_Worker_ID = (SELECT DISTINCT
										CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE
								   FROM @NoticeElementsData_P1
								  WHERE Element_NAME = 'Worker_Parameter_ID');
			--13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - End
			SELECT *
              INTO #SubElements33_P1
              FROM (SELECT *
                         FROM dbo.BATCH_GEN_NOTICES$SF_GET_Leg154DEPENDENT_DETAILS(@Ln_Case_IDNO, @Lc_Worker_ID, @Ld_Run_DATE )) AS Tmp_P1;

            SET @Ln_RowCount33_NUMB = (SELECT COUNT(*) 
										   FROM #SubElements33_P1)

            SET @Ls_TableName_TEXT = '#SubElements33_P1';
            SET @Ln_RowCount_NUMB = @Ln_RowCount33_NUMB;
        END
    ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_NCP_DETAILS'
		BEGIN
			
			SELECT *
			  INTO #SubElements34_P1
			  FROM (SELECT *
			          FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_NCP_DETAILS(@Ln_Case_IDNO, @Ld_Run_DATE)) AS Tmp_P1;

			SET @Ln_RowCount34_NUMB =(SELECT COUNT(*)
										FROM #SubElements34_P1);
	      
		    SET @Ls_TableName_TEXT = '#SubElements34_P1';
		    SET @Ln_RowCount_NUMB = @Ln_RowCount34_NUMB;
		END
	 ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE$SF_GET_YNGST_CHILD_DTLS'  
		BEGIN  
		     
			SELECT *  
			  INTO #SubElements35_P1  
			  FROM (SELECT *  
					 FROM dbo.BATCH_GEN_NOTICE$SF_GET_YNGST_CHILD_DTLS(@Ln_Case_IDNO)) AS Tmp_P1;  
		  
		    SET @Ln_RowCount35_NUMB =(SELECT COUNT(*)  
				  FROM #SubElements35_P1);  
		  
			SET @Ls_TableName_TEXT = '#SubElements35_P1'  
			SET @Ln_RowCount_NUMB = @Ln_RowCount35_NUMB;
		END
	ELSE IF @As_Proc_NAME = 'BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_DETAILS_CSM_17'
		BEGIN
			
			 SELECT *
			   INTO #SubElements36_P1
			   FROM (SELECT *
					   FROM dbo.BATCH_GEN_NOTICE_MEMBER$SF_GET_DEPENDENT_DETAILS_CSM_17(@Ln_Case_IDNO, @Ld_Run_DATE)) AS Tmp_P1;
		             
			 SET @Ln_RowCount36_NUMB = (SELECT COUNT(*)
					 FROM #SubElements36_P1);
		     
			 SET @Ls_TableName_TEXT = '#SubElements36_P1';
			 SET @Ln_RowCount_NUMB = @Ln_RowCount36_NUMB;
		END		
    ELSE
		BEGIN
			 SET @Ls_TableName_TEXT = '';
			 SET @Ln_RowCount_NUMB = 0;
		END

   SELECT @Ls_XMLParent_Element_NAME = Element_NAME
     FROM NDEL_Y1
    WHERE Notice_ID = @Lc_Notice_ID
	  AND TypeElement_CODE = 'M'
	  AND Seq_NUMB = CONVERT(NUMERIC(5), @An_Seq_NUMB);
	
   -- Gets column list to Unpivot  #SubElements_P1 table           
   SELECT @Ls_ColumnName_List_TEXT = COALESCE(@Ls_ColumnName_List_TEXT + ',', '') + NAME
     FROM tempdb.sys.columns
    WHERE object_id = OBJECT_ID('tempdb..' + @Ls_TableName_TEXT + '');
	
   SET @Ln_Counter_NUMB = 1;
   
   ---UnPivot #SubElements_P1 and by joining  NDEL and Subelements get element name and format CODE into #SUBVALUES_P1 table          
   WHILE (@Ln_Counter_NUMB <= @Ln_RowCount_NUMB)
    BEGIN
     
     SET @Ls_SQLString_TEXT='SELECT * INTO #SubColumn_P1 FROM(          
							  SELECT name1, namevalue
							  FROM           
								(SELECT * FROM ' + @Ls_TableName_TEXT + '          
									WHERE ROWNUM = ' + CONVERT(VARCHAR, @Ln_Counter_NUMB) + ') P          
								 UNPIVOT           
								 (namevalue FOR name1 IN ([' + REPLACE(@Ls_ColumnName_List_TEXT, ',', '],[') + ']))          
								 AS unpvt) Y ;          
				              
							 IF (SELECT COUNT(*) FROM #SubValues_P1)>0          
								DELETE FROM #SubValues_P1                
				             
							 INSERT INTO #SubValues_P1
								SELECT name1, namevalue
								  FROM #SubColumn_P1
								 WHERE name1 IN (SELECT Element_NAME
												   FROM NDEL_Y1 a
												  WHERE a.NOTICE_ID = ''' + @Lc_Notice_ID + ''' 
												    AND a.parentSeq_NUMB = ' + CONVERT(VARCHAR(max), @An_Seq_NUMB) + ');
							   ';

     EXEC(@Ls_SQLString_TEXT)
	 
	 UPDATE #SubValues_P1
	    SET Element_NAME = LOWER(Element_NAME);
	 
	  
	 --Apply formatting For all elements in #SubValues_P1 table          
     SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_SUB_ELMENTS';
     SET @Ls_ErrorDesc_TEXT='BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA : No Sub elements Data For Formatting'
     
     SET @GetFormat_Element_CUR = CURSOR FOR
		 SELECT  V.Element_NAME,
				 V.Element_VALUE,
				 p.Format_CODE,
				 P.Mask_INDC
			FROM #SubValues_P1 V, NDEL_Y1 P
		   WHERE v.ELEMENT_NAME = P.Element_NAME
			 AND P.NOTICE_ID = @Lc_Notice_ID
			 AND P.parentSeq_NUMB = @An_Seq_NUMB
			 AND P.Format_CODE <> '';

     OPEN @GetFormat_Element_CUR

     FETCH NEXT FROM @GetFormat_Element_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Ls_Format_CODE,@Lc_Mask_INDC

     WHILE @@FETCH_STATUS = 0
		  BEGIN
			   SET @Ls_Element_TEXT=@Ls_Element_NAME;
			   SET @Ls_ElementValue_TEXT=@Ls_Element_VALUE;
			   SET @Ls_Ele_Format_CODE=@Ls_Format_CODE;
			   SET @Lc_Mask_INDC = @Lc_Mask_INDC 
		       
			   SET @Ls_SQLProcName_TEXT = 'BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA';
			   SET @Ls_Dyn_SQLString_TEXT = 'EXEC ' + @Ls_SQLProcName_TEXT + ' ' + @Ls_SQLParameterString_TEXT;
				
			   IF @Ls_Ele_Format_CODE <> ''
				BEGIN
				  EXEC  BATCH_GEN_NOTICES$SP_GET_FORMAT_DATA
								@As_Element_NAME			= @Ls_Element_TEXT,
								@As_Element_VALUE			= @Ls_ElementValue_TEXT,
								@Ac_Format_CODE				= @Ls_Ele_Format_CODE,
								@Ac_Mask_INDC				= @Lc_Mask_INDC,
								@As_FormattedResult_TEXT	= @As_FormattedResult_TEXT OUTPUT,
								@As_DescriptionError_TEXT	= @As_DescriptionError_TEXT OUTPUT,
								@Ac_Msg_CODE				= @Ac_Msg_CODE OUTPUT;
		          
				  IF @Ac_Msg_CODE = 'F'
					BEGIN
						RETURN;
					END
		          
				  UPDATE #SubValues_P1
					 SET ELEMENT_VALUE = @As_FormattedResult_TEXT
				   WHERE ELEMENT_NAME = @Ls_Element_TEXT;
				  
				END

			   FETCH NEXT FROM @GetFormat_Element_CUR INTO @Ls_Element_NAME, @Ls_Element_VALUE, @Ls_Format_CODE,@Lc_Mask_INDC
		  END

     CLOSE @GetFormat_Element_CUR;

     DEALLOCATE @GetFormat_Element_CUR;
     
     SELECT @Ls_SubElementsXml_TEXT = COALESCE(@Ls_SubElementsXml_TEXT, '') + '<' + a.Element_NAME + '>' + ISNULL(a.Element_Value, '') + '</' + a.Element_NAME + '>'  
	   FROM (SELECT Element_NAME,
					ISNULL(T.Element_VALUE, '') Element_VALUE
			   FROM #SubValues_P1 T
			  WHERE EXISTS (SELECT 1
							  FROM NDEL_Y1 V
							 WHERE V.ELEMENT_NAME = T.ELEMENT_NAME
							   AND V.ParentSeq_NUMB = @An_Seq_NUMB)) a
	  
	 SET @Ls_SubElementsXml_TEXT = '<row>' + @Ls_SubElementsXml_TEXT + '</row>';
	  
	 SET @Ls_Output_TEXT = @Ls_Output_TEXT + @Ls_SubElementsXml_TEXT;
	 
	 SET @Ls_SubElementsXml_TEXT = '';
	 
	 -- Raise error if child element does not have value for the required element and rows returned from the appropriate procedure
	 SELECT @Ln_RequiredFieldCount_NUMB = Count(DISTINCT  V.Element_NAME)
	   FROM NDEL_Y1 V
	  WHERE V.Input_CODE = 'O'  
		AND v.Required_INDC = 'Y'
		AND v.Notice_ID = @Lc_Notice_ID
		AND v.ParentSeq_NUMB = @An_Seq_NUMB;
	
	 IF @Ln_RequiredFieldCount_NUMB > 0
		BEGIN
			
			SET @ls_sql_TEXT = @As_Proc_NAME;
			SET @Ls_Sqldata_TEXT = 'Procedure Name : '+@As_Proc_NAME +'Seq number :'+CAST(@An_Seq_NUMB AS CHAR);
		
			  INSERT INTO #NoticeErrors_P1  
				SELECT  
				DISTINCT  V.Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB) AS Element_NAME, 
						  'E0058'  , 
						  'Sub Element ' + V.Element_NAME + ' not populated in Parent Element of ' + @Ls_XMLParent_Element_NAME + ' while executing procedure: ' + @As_Proc_NAME
				 FROM NDEL_Y1 V
				WHERE V.Input_CODE = 'O'  
				  AND V.Required_INDC = 'Y'
				  AND V.Notice_ID = @Lc_Notice_ID 
				  AND V.ParentSeq_NUMB = @An_Seq_NUMB
				  AND V.Element_NAME NOT LIKE 'option_%'
				  AND (	EXISTS (  SELECT 1  
									FROM #SubValues_P1
								   WHERE Element_NAME = V.Element_NAME  
									 AND (LTRIM(RTRIM(Element_Value)) = '' OR Element_Value IS NULL)
							   )
						OR NOT EXISTS(SELECT 1
										FROM #SubValues_P1
									   WHERE Element_NAME = V.Element_NAME )
					   );
			   
		 END
	 
	 SET @Ln_Counter_NUMB = @Ln_Counter_NUMB + 1;
    END

    	SET @Ls_Output_TEXT = '<' + @Ls_XMLParent_Element_NAME + ' count = "' + CAST(@Ln_RowCount_NUMB AS VARCHAR) + '">' + @Ls_Output_TEXT + '</' + @Ls_XMLParent_Element_NAME + '>'
	
	   SET @As_Result_TEXT = @Ls_Output_TEXT;
	
	-- Raise error when no rows returned from the appropriate procedure
	IF @Ln_RowCount_NUMB = 0
		BEGIN
			
			SET @ls_sql_TEXT = @As_Proc_NAME
			SET @Ls_Sqldata_TEXT = 'Procedure Name : '+@As_Proc_NAME +'Seq number :'+CAST(@An_Seq_NUMB AS CHAR)
		
			  INSERT INTO #NoticeErrors_P1  
				SELECT  
				DISTINCT  V.Element_NAME + ':1' AS Element_NAME, 
						  'E0058'  , 
						  'Sub Element ' + V.Element_NAME + ' not populated in Parent Element of ' + @Ls_XMLParent_Element_NAME + ' while executing procedure: ' + @As_Proc_NAME--@Ac_Msg_CODE, @As_DescriptionError_TEXT
				 FROM NDEL_Y1 V
				WHERE V.Input_CODE = 'O'  
				  AND V.Required_INDC = 'Y'
				  AND V.Notice_ID = @Lc_Notice_ID 
				  AND V.ParentSeq_NUMB = @An_Seq_NUMB
				  AND V.Element_NAME NOT LIKE 'option_%'
				  AND (	EXISTS (  SELECT 1  
									FROM #SubValues_P1
								   WHERE Element_NAME = V.Element_NAME  
									 AND (LTRIM(RTRIM(Element_Value)) = '' OR Element_Value IS NULL)
							   )
						OR NOT EXISTS(SELECT 1
										FROM #SubValues_P1
									   WHERE Element_NAME = V.Element_NAME )
					   );
		 END
	
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
  
   IF CURSOR_STATUS ('local', '@GetFormat_Element_CUR') IN (0, 1)
    BEGIN
     CLOSE @GetFormat_Element_CUR

     DEALLOCATE @GetFormat_Element_CUR
    END

   IF CURSOR_STATUS ('local', '@GetMultiple_Records_CUR') IN (0, 1)
    BEGIN
     CLOSE @GetMultiple_Records_CUR

     DEALLOCATE @GetMultiple_Records_CUR
    END

   SET @Ac_Msg_CODE=@Lc_StatusFailed_CODE;
   SET @Ls_Sql_TEXT='GET PROCEDURE NAMES FROM NDEL_Y1 '
 
   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE(), 'BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS') + ' Procedure' + '. Error Desc - ' + @Ls_ErrorDesc_TEXT + '. Error Execute Location - ' + @ls_sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error in ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICES$SP_GET_SUB_ELEMENTS') + ' Procedure' + '. Error Desc - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error Execute Location - ' + @ls_sql_TEXT + '. Error List Key - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
   
  END CATCH
 END




GO
