/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_INSURANCE_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name		: BATCH_GEN_NOTICE_MEMBER$SP_GET_INSURANCE_DTLS
Programmer Name		: IMP Team.
Description_TEXT	: This procedure gets the Insurance Details like Insurance Group Number Text, Policy Number Text and Begin Date
Frequency			:
Developed On		: 02-08-2011
Called By			: BATCH_COMMON$SP_FORMAT_BUILD_XML
Called On			: 
-------------------------------------------------------------------------------------------------------------------------
Modified By			:
Modified On			:
Version No			: 1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_INSURANCE_DTLS](
 @An_Case_IDNO					NUMERIC(6),
 @An_MemberMci_IDNO				NUMERIC(10),
 @An_MajorIntSeq_NUMB			NUMERIC(5),
 @As_Prefix_TEXT				VARCHAR(100),
 @Ac_Msg_CODE					CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT		VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  DECLARE @Lc_StatusSuccess_CODE     CHAR(1)			= 'S',
          @Ls_StatusNoDataFound_CODE CHAR(1)			= 'N',
          @Lc_StatusFailed_CODE      CHAR(1)			= 'F',
          @Lc_StatusCg_CODE			 CHAR(2)			= 'CG',
          @Ls_Routine_TEXT           VARCHAR(100)		= 'BATCH_GEN_NOTICE_MEMBER$SP_GET_INSURANCE_DTLS',
          @Ld_High_DATE              DATE				= '12/31/9999';
  DECLARE @Ls_Sql_TEXT               VARCHAR(200),
          @Ls_Sqldata_TEXT           VARCHAR(400),
          @Ls_DescriptionError_TEXT  VARCHAR(4000),
          @Ls_SqlQuery_TEXT          VARCHAR(MAX),
          @Ld_Today_DATE			 DATE				= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
          
    DECLARE @NoticeElements_P1 TABLE
                        (Element_NAME    VARCHAR (100),
                         Element_VALUE   VARCHAR (100));          
          

  BEGIN TRY
   SET @Ac_Msg_CODE = '';
   SET @As_DescriptionError_TEXT = '';  

   
   IF (@An_MemberMci_IDNO IS NOT NULL AND @An_MemberMci_IDNO <> 0)
    BEGIN
     INSERT INTO @NoticeElements_P1(Element_NAME,Element_VALUE)
				(SELECT Element_NAME, Element_VALUE from  
					   (   
					   SELECT    
						CONVERT(VARCHAR(100),OthpInsurance_IDNO) AS othp_insurance_idno,  
						CONVERT(VARCHAR(100),InsuranceGroupNo_TEXT) AS insurance_group_no_text,
						CONVERT(VARCHAR(100),PolicyInsNO_TEXT) AS policy_ins_no_text,     
						CONVERT(VARCHAR(100),Begin_DATE) AS policy_begin_date
					   FROM ( SELECT m.OthpInsurance_IDNO,
									 m.InsuranceGroupNo_TEXT,
									 m.PolicyInsNo_TEXT,
									 m.Begin_DATE
								FROM
								 (SELECT m.OthpInsurance_IDNO,
										 m.InsuranceGroupNo_TEXT,
										 m.PolicyInsNo_TEXT,
										 m.Begin_DATE,
										 ROW_NUMBER() OVER(ORDER BY m.Added_DATE DESC) rno
									FROM
									  (SELECT m.OthpInsurance_IDNO,
											  m.InsuranceGroupNo_TEXT,
											  m.PolicyInsNo_TEXT,
											  m.Begin_DATE,
											  (SELECT MIN(BeginValidity_DATE)
												 FROM MINS_Y1
												WHERE MemberMci_IDNO = m.MemberMci_IDNO
												  AND OthpInsurance_IDNO = m.OthpInsurance_IDNO
												  AND InsuranceGroupNo_TEXT = m.InsuranceGroupNo_TEXT
												  AND PolicyInsNo_TEXT = m.PolicyInsNo_TEXT) Added_DATE
										 FROM MINS_Y1 m
										WHERE CAST(m.MemberMci_IDNO AS VARCHAR) =  (SELECT d.Reference_ID
																					  FROM DMJR_Y1 d
																					 WHERE d.Case_IDNO = @An_Case_IDNO
																					   AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB) 
										  AND m.MedicalIns_INDC = 'Y'
										  AND m.Status_CODE = @Lc_StatusCg_CODE
										  AND m.EndValidity_DATE = @Ld_High_DATE AND
										   @Ld_Today_DATE >= m.Begin_DATE AND 
										  @Ld_Today_DATE  < m.End_DATE) m) m
							   WHERE m.rno = 1) m
							  ) up  
						UNPIVOT   
						(Element_VALUE FOR Element_NAME IN (othp_insurance_idno,
													 insurance_group_no_text,
													 policy_ins_no_text,
													 policy_begin_date
													))  
						AS pvt);
						
			SET @Ls_Sql_TEXT = 'UPDATE @NoticeElements_P1';
			SET @Ls_Sqldata_TEXT = ' @Prefix_TEXT = ' + @As_Prefix_TEXT;
			
			UPDATE  @NoticeElements_P1 
				SET Element_NAME =  @As_Prefix_TEXT + '_' + Element_NAME
			 WHERE Element_NAME!= 'othp_insurance_idno';
			
			INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_VALUE)
            SELECT TE.Element_NAME,
                   TE.Element_VALUE
              FROM @NoticeElements_P1 TE;
    END

   SET @AC_Msg_CODE = @LC_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   DECLARE	@Li_Error_NUMB				INT = ERROR_NUMBER (),
			@Li_ErrorLine_NUMB		    INT =  ERROR_LINE ();
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END
         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Sql_TEXT,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  END CATCH
 END


GO
