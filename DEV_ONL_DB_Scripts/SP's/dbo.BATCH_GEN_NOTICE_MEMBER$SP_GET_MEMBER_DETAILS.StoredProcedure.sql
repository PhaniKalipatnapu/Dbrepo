/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS
Programmer Name	:	IMP Team.
Description		:	The procedure is used to obtain the member details.
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS] (
 @An_MemberMci_IDNO        NUMERIC (10),
 @As_Prefix_TEXT           VARCHAR (70),
 @Ac_Msg_CODE              CHAR (5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Empty_TEXT				CHAR(1)  = '',
		  @Lc_Space_TEXT				CHAR(1)  = ' ',
		  @Lc_Zero_TEXT					CHAR(1)  = '0',
		  @Lc_StatusSuccess_CODE		CHAR(1)  = 'S',
          @Lc_StatusFailed_CODE			CHAR(1)  = 'F',
          @Lc_CountryUS_CODE			CHAR(2)  = 'US',
          @Lc_MemberCP_CODE				CHAR(2)  = 'CP',
          @Lc_MemberNCP_CODE			CHAR(3)  = 'NCP',
		  @Lc_PrefixMem_TEXT			CHAR(3)  = 'MEM',
		  @Lc_BirthCtry_REFM			CHAR(4)  = 'CTRY', 
          @Lc_TableIdGENR_CODE			CHAR(4)  = 'GENR',
          @Lc_TableIdDEMO_CODE			CHAR(4)  = 'DEMO',
          @Lc_TableSubIdGEND_CODE		CHAR(4)  = 'GEND',
          @Lc_TableSubIdHAIR_CODE		CHAR(4)  = 'HAIR',
          @Lc_TableSubIdRACE_CODE		CHAR(4)  = 'RACE',
          @Lc_TableSubIdEduc_CODE		CHAR(4)  = 'EDUC',
          @Lc_TableSubIdEYEC_CODE		CHAR(4)  = 'EYEC',
          @Lc_NoticeEnf01_ID			CHAR(8)  = 'ENF-01',
		  @Lc_NoticeEnf03_ID			CHAR(8)  = 'ENF-03',
		  @Lc_NoticeLeg144_ID			CHAR(8)  = 'LEG-144',
		  @Lc_Element_Notice_ID			CHAR(10) = 'Notice_ID',
		  @Lc_Element_MemberMci_IDNO	CHAR(20) = 'MemberMci_IDNO',
		  @Ls_Procedure_NAME			VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_GET_MEMBER_DETAILS';
  DECLARE @Ln_Error_NUMB				NUMERIC(11),
          @Ln_ErrorLine_NUMB			NUMERIC(11),
          @Lc_Ive_Agency_ID				NUMERIC(10) = 999998,
          @Lc_Notice_ID					CHAR(8),
          @Lc_Feet_TEXT					CHAR(6)= ' feet ',
          @Lc_Inches_TEXT				CHAR(7)= ' Inches',
          @Ls_Sql_TEXT					VARCHAR(200),
          @Ls_Sqldata_TEXT				VARCHAR(400),
          @Ls_DescriptionError_TEXT		VARCHAR(4000) = '';

   BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Lc_Notice_ID = (SELECT Element_VALUE
                          FROM #NoticeElementsData_P1
                         WHERE Element_NAME = @Lc_Element_Notice_ID);

   IF @As_Prefix_TEXT IS NULL
       OR @As_Prefix_TEXT = @Lc_Empty_TEXT
    BEGIN
     SET @As_Prefix_TEXT = @Lc_PrefixMem_TEXT;
    END

   SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1';
   SET @Ls_Sqldata_TEXT = ' MemberMci_IDNO = ' + ISNULL (CAST (@An_MemberMci_IDNO AS VARCHAR(10)), @Lc_Empty_TEXT);

   DECLARE @NoticeElements_P1 TABLE (
    Element_NAME  VARCHAR (100),
    Element_VALUE VARCHAR (100));

   INSERT INTO @NoticeElements_P1
               (Element_NAME,
                Element_VALUE)
   SELECT pvt.Element_NAME,
          pvt.Element_VALUE
     FROM (SELECT CONVERT (VARCHAR (100), a.MemberMci_IDNO) AS MemberMci_IDNO,
                  CONVERT (VARCHAR (100), a.Last_NAME) AS Last_NAME,
                  CONVERT (VARCHAR (100), a.First_NAME) AS First_NAME,
                  CONVERT (VARCHAR (100), a.Middle_NAME) AS Middle_NAME,
                  CONVERT (VARCHAR (100), a.Suffix_NAME) AS Suffix_NAME,
                  CONVERT (VARCHAR (100), a.FL_NAME) AS FL_NAME,
                  CONVERT (VARCHAR (100), a.Title_NAME) AS Title_NAME,
                  CONVERT (VARCHAR (100), a.Full_NAME) AS NAME,
                  CONVERT (VARCHAR (100), a.MemberSex_CODE) AS MemberSex_INDC,
                  CONVERT (VARCHAR (100), a.MemberSsn_NUMB) AS Ssn_NUMB,
                  CONVERT (VARCHAR (100), a.Birth_DATE) AS Birth_DATE,
                  CONVERT (VARCHAR (100), a.Race_CODE) AS Race_CODE,
                  CONVERT (VARCHAR (100), a.ColorEyes_CODE) AS ColorEyes_CODE,
                  CONVERT (VARCHAR (100), a.EducationLevel_CODE) AS EducationLevel_CODE,
                  CONVERT (VARCHAR (100), a.DescriptionHeight_TEXT) AS DescriptionHeight_TEXT,
                  CONVERT (VARCHAR (100), a.TypeOccupation_CODE) AS TypeOccupation_CODE,
                  CONVERT (VARCHAR (100), a.DescriptionWeightLbs_TEXT) AS DescriptionWeightLbs_TEXT,
                  CONVERT (VARCHAR (100), a.WorkPhone_NUMB) AS WorkPhone_NUMB,
                  CONVERT (VARCHAR (100), a.HomePhone_NUMB) AS HomePhone_NUMB,
                  CONVERT (VARCHAR (100), a.CellPhone_NUMB) AS CellPhone_NUMB,
                  CONVERT (VARCHAR (100), a.Spouse_NAME) AS Spouse_NAME,
                  CONVERT (VARCHAR (100), a.BirthState_CODE) AS BirthState_CODE,
                  CONVERT (VARCHAR (100), a.BirthCity_NAME) AS BirthCity_NAME,
                  CONVERT (VARCHAR (100), a.BirthCountry_CODE) AS BirthCountry_CODE,
                  CONVERT (VARCHAR (100), a.BirthCounty_TEXT) AS BirthCounty_TEXT,
                  CONVERT (VARCHAR (100), a.birthCity_State_Country_TEXT) AS birthCity_State_Country_TEXT,
                  CONVERT (VARCHAR (100), a.DescriptionIdentifyingMarks_TEXT) AS DescriptionIdentifyingMarks_TEXT,
                  CONVERT (VARCHAR (100), a.MotherMaiden_NAME) AS MotherMaiden_NAME,
                  CONVERT (VARCHAR (100), a.ColorHair_CODE) AS ColorHair_CODE
             FROM (SELECT MemberMci_IDNO,
                          RTRIM (d.Last_NAME) + (CASE
                                                  WHEN d.Suffix_NAME <> @Lc_Empty_TEXT
                                                        OR @Lc_Notice_ID in ( @Lc_NoticeEnf01_ID,@Lc_NoticeEnf03_ID)
                                                   THEN @Lc_Space_TEXT
                                                  ELSE @Lc_Empty_TEXT
                                                 END)AS Last_NAME,
                          RTRIM (d.First_NAME) + @Lc_Space_TEXT AS First_NAME,
                          RTRIM (d.Middle_NAME) + @Lc_Space_TEXT AS Middle_NAME,
                          RTRIM(d.Suffix_NAME) AS Suffix_NAME,
                          RTRIM (d.First_NAME) + @Lc_Space_TEXT + RTRIM (d.Last_NAME) AS FL_NAME,
                          d.Title_NAME,
                          RTRIM((RTRIM (d.First_NAME) + @Lc_Space_TEXT + RTRIM (d.Middle_NAME) + @Lc_Space_TEXT + RTRIM(d.Last_NAME) + (CASE
                                                                                                                   WHEN d.Suffix_NAME <> @Lc_Empty_TEXT
                                                                                                                    THEN @Lc_Space_TEXT
                                                                                                                   ELSE @Lc_Empty_TEXT
                                                                                                                  END) + RTRIM(d.Suffix_NAME))) AS Full_NAME,
                          dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableIdGENR_CODE, @Lc_TableSubIdGEND_CODE, d.MemberSex_CODE) AS MemberSex_CODE,
                          d.MemberSsn_NUMB,
                          dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableIdDEMO_CODE, @Lc_TableSubIdHAIR_CODE, d.ColorHair_CODE) AS ColorHair_CODE,
                           CASE WHEN @An_MemberMci_IDNO = @Lc_Ive_Agency_ID THEN  
							  CASE WHEN CAST(CONVERT(VARCHAR(4), d.Birth_DATE, 112) AS NUMERIC) NOT IN(0001)   
							THEN CONVERT(VARCHAR(10), d.Birth_DATE, 101)   
							ELSE @Lc_Empty_TEXT    
							  END   
							  ELSE  
							  CASE WHEN CAST(CONVERT(VARCHAR(4), d.Birth_DATE, 112) AS NUMERIC) NOT IN(1900,0001)   
							THEN CONVERT(VARCHAR(10), d.Birth_DATE, 101)   
							ELSE @Lc_Empty_TEXT    
							  END  
							 END AS Birth_DATE,
                          dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableIdGENR_CODE, @Lc_TableSubIdRACE_CODE, d.Race_CODE) AS Race_CODE,
                          dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableIdDEMO_CODE, @Lc_TableSubIdEYEC_CODE, d.ColorEyes_CODE) AS ColorEyes_CODE,
						  --13625 - INT-04 - General Testimony issues reported by workers Fix - Start
                          dbo.BATCH_COMMON$SF_GET_REFM_DESC_VALUE (@Lc_TableIdDEMO_CODE,@Lc_TableSubIdEduc_CODE,d.EducationLevel_CODE) AS EducationLevel_CODE,
						  --13625 - INT-04 - General Testimony issues reported by workers Fix - End
                          CASE WHEN RTRIM(LTRIM(d.DescriptionHeight_TEXT)) = @Lc_Empty_TEXT THEN
                          @Lc_Zero_TEXT +@Lc_Feet_TEXT + @Lc_Zero_TEXT + @Lc_Inches_TEXT
                          ELSE
                          ISNULL(RTRIM(LTRIM(SUBSTRING(d.DescriptionHeight_TEXT,1,1))),0)+@Lc_Feet_TEXT+ISNULL(RTRIM(LTRIM(SUBSTRING(d.DescriptionHeight_TEXT,2,2))),0) +@Lc_Inches_TEXT 
                          END AS DescriptionHeight_TEXT,
                          d.TypeOccupation_CODE,
                          d.DescriptionWeightLbs_TEXT,
                          d.WorkPhone_NUMB,
                          d.HomePhone_NUMB,
                          d.CellPhone_NUMB,
                          d.Spouse_NAME,
						  -- 13596 - CR0400 Revise Mapping on LEG-144 20140806 - Fix - Start
                          CASE WHEN @Lc_Notice_ID = @Lc_NoticeLeg144_ID AND @As_Prefix_TEXT= @Lc_MemberNCP_CODE AND LTRIM(RTRIM(d.BirthState_CODE))=@Lc_Empty_TEXT THEN
                          dbo.BATCH_COMMON_GETS$SF_GET_REFMDESC(@Lc_BirthCtry_REFM,@Lc_BirthCtry_REFM,d.BirthCountry_CODE)
                          ELSE
                          d.BirthState_CODE END AS BirthState_CODE,
						  -- 13596 - CR0400 Revise Mapping on LEG-144 20140806 - Fix - End
                          d.Birthcity_NAME,
                          d.Birthcity_NAME + @Lc_Space_TEXT + d.BirthState_CODE + (CASE
                                                                         WHEN d.BirthCountry_CODE != @Lc_CountryUS_CODE
                                                                          THEN d.BirthCountry_CODE
                                                                         ELSE @Lc_Empty_TEXT
                                                                        END) AS birthCity_State_Country_TEXT,
                          d.DescriptionIdentifyingMarks_TEXT,
                          d.MotherMaiden_NAME,
                          CASE
                           WHEN d.BirthCountry_CODE = @Lc_Empty_TEXT
                            THEN @Lc_CountryUS_CODE
                           ELSE d.BirthCountry_CODE
                          END AS BirthCountry_CODE,
                          (SELECT County_NAME
                             FROM COPT_Y1 cp
                            WHERE cp.County_IDNO = d.countybirth_idno) AS BirthCounty_TEXT
                     FROM DEMO_Y1 D
                    WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO) a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (MemberMci_IDNO, Last_NAME, First_NAME, Middle_NAME, Suffix_NAME, Title_NAME, NAME, MemberSex_INDC, Ssn_NUMB, Birth_DATE, Race_CODE, ColorEyes_CODE, EducationLevel_CODE, DescriptionHeight_TEXT, TypeOccupation_CODE, DescriptionWeightLbs_TEXT, WorkPhone_NUMB, HomePhone_NUMB, CellPhone_NUMB, Spouse_NAME, BirthState_CODE, BirthCity_NAME, BirthCountry_CODE, BirthCounty_TEXT, birthCity_State_Country_TEXT, DescriptionIdentifyingMarks_TEXT, MotherMaiden_NAME, ColorHair_CODE )) AS pvt;

   SET @Ls_Sql_TEXT = 'INSERT @NoticeElements_P1';
   SET @Ls_Sqldata_TEXT = ' Element_NAME = ' + @As_Prefix_TEXT;

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   SELECT RTRIM(@As_Prefix_TEXT) + '_' + TE.Element_NAME AS Element_NAME,
          TE.Element_VALUE
     FROM @NoticeElements_P1 TE
    WHERE (Element_Name != @Lc_Element_MemberMci_IDNO
       AND RTRIM(@As_Prefix_TEXT) IN (@Lc_MemberCP_CODE, @Lc_MemberNCP_CODE)) /*For CP & NCP MemberMci_IDNO is already fetched in SP_GENERATE_NOTICE */
       OR (@As_Prefix_TEXT NOT IN (@Lc_MemberCP_CODE, @Lc_MemberNCP_CODE));

   SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF ERROR_NUMBER () <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END;


GO
