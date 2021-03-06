/****** Object:  StoredProcedure [dbo].[BATCH_LOC_OUTGOING_FCR$SP_GENERATE_FCR_FILE]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_LOC_OUTGOING_FCR$SP_GENERATE_FCR_FILE
Programmer Name	:	IMP Team.
Description		:	The purpose of BATCH_LOC_OUTGOING_FCR$SP_GENERATE_FCR_FILE batch process is to Generate 
					  FCR Request using the data from EFCAS_Y1, EFMEM_Y1, EFQRY_Y1 and EFNCA_Y1.
Frequency		:	'DAILY'
Developed On	:	4/27/2012
Called By		:	NONE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_OUTGOING_FCR$SP_GENERATE_FCR_FILE] (
 @Ad_Run_DATE              DATE,
 @As_File_NAME             VARCHAR(50),
 @As_FileLocation_TEXT     VARCHAR(80),
 @An_Batch_NUMB            NUMERIC(6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_Space_TEXT         CHAR = ' ',
          @Lc_Zero_TEXT          CHAR = '0',
          @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Lc_InStateFips_CODE   CHAR(2) = '10',
          @Lc_RecHeader_ID       CHAR(2) = 'FA',
          @Lc_RecCase_ID         CHAR(2) = 'FC',
          @Lc_RecPerson_ID       CHAR(2) = 'FP',
          @Lc_RecQuery_ID        CHAR(2) = 'FR',
          @Lc_RecNcoa_ID         CHAR(2) = 'NC',
          @Lc_RecTrailer_ID      CHAR(2) = 'FZ',
          @Lc_Version_TEXT       CHAR(5) = '01.00',
          @Ls_File_NAME          VARCHAR(50) = @As_File_NAME,
          @Ls_FileLocation_TEXT  VARCHAR(80) = @As_FileLocation_TEXT,
          @Ls_Procedure_NAME     VARCHAR(100) = 'SP_GENERATE_FCR_FILE',
          @Ld_Run_DATE           DATE = @Ad_Run_DATE;
  DECLARE @Ln_Error_NUMB            NUMERIC(11),
          @Ln_ErrorLine_NUMB        NUMERIC(11),
          @Ln_RecordCount_QNTY      NUMERIC(11) = 0,
          @Li_FetchStatus_QNTY      SMALLINT,
          @Lc_Msg_CODE              CHAR(5),
          @Ls_Sql_TEXT              VARCHAR(100) = '',
          @Ls_ErrorMessage_TEXT     VARCHAR(200),
          @Ls_SqlData_TEXT          VARCHAR(1000) = '',
          @Ls_Record_TEXT           VARCHAR(1000),
          @Ls_Query_TEXT            VARCHAR(1000),
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Start_DATE            DATETIME2;
  DECLARE @Lc_FcrCaseCur_Rec_ID                      CHAR(2),
          @Lc_FcrCaseCur_TypeAction_CODE             CHAR(1),
          @Lc_FcrCaseCur_Case_IDNO                   CHAR(15),
          @Lc_FcrCaseCur_TypeCase_CODE               CHAR(1),
          @Lc_FcrCaseCur_Order_INDC                  CHAR(1),
          @Lc_FcrCaseCur_CountyFips_CODE             CHAR(3),
          @Lc_FcrCaseCur_UserField_NAME              CHAR(15),
          @Lc_FcrCaseCur_CasePrevious_IDNO           CHAR(15),
          @Lc_FcrMemberCur_Rec_ID                    CHAR(2),
          @Lc_FcrMemberCur_TypeAction_CODE           CHAR(1),
          @Lc_FcrMemberCur_Case_IDNO                 CHAR(15),
          @Lc_FcrMemberCur_ReservedFcr_CODE          CHAR(2),
          @Lc_FcrMemberCur_UserField_NAME            CHAR(15),
          @Lc_FcrMemberCur_CountyFips_CODE           CHAR(3),
          @Lc_FcrMemberCur_TypeLocReq_CODE           CHAR(2),
          @Lc_FcrMemberCur_BundleResults_INDC        CHAR(1),
          @Lc_FcrMemberCur_TypeParticipant_CODE      CHAR(2),
          @Lc_FcrMemberCur_FamilyViolence_CODE       CHAR(2),
          @Lc_FcrMemberCur_MemberMci_IDNO            CHAR(15),
          @Lc_FcrMemberCur_Sex_CODE                  CHAR(1),
          @Lc_FcrMemberCur_Birth_DATE                CHAR(8),
          @Lc_FcrMemberCur_MemberSsn_NUMB            CHAR(9),
          @Lc_FcrMemberCur_PreviousMemberSsn_NUMB    CHAR(9),
          @Lc_FcrMemberCur_First_NAME                CHAR(16),
          @Lc_FcrMemberCur_Middle_NAME               CHAR(16),
          @Lc_FcrMemberCur_Last_NAME                 CHAR(30),
          @Lc_FcrMemberCur_CityBirth_ADDR            CHAR(16),
          @Lc_FcrMemberCur_StCountryBirth_ADDR       CHAR(4),
          @Lc_FcrMemberCur_FirstFather_NAME          CHAR(16),
          @Lc_FcrMemberCur_MiddleFather_NAME         CHAR(1),
          @Lc_FcrMemberCur_LastFather_NAME           CHAR(16),
          @Lc_FcrMemberCur_FirstMother_NAME          CHAR(16),
          @Lc_FcrMemberCur_MiddleMother_NAME         CHAR(1),
          @Lc_FcrMemberCur_LastMother_NAME           CHAR(16),
          @Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB     CHAR(9),
          @Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB CHAR(9),
          @Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB CHAR(9),
          @Lc_FcrMemberCur_FirstAdditional1_NAME     CHAR(16),
          @Lc_FcrMemberCur_MiddleAdditional1_NAME    CHAR(16),
          @Lc_FcrMemberCur_LastAdditional1_NAME      CHAR(30),
          @Lc_FcrMemberCur_FirstAdditional2_NAME     CHAR(16),
          @Lc_FcrMemberCur_MiddleAdditional2_NAME    CHAR(16),
          @Lc_FcrMemberCur_LastAdditional2_NAME      CHAR(30),
          @Lc_FcrMemberCur_FirstAdditional3_NAME     CHAR(16),
          @Lc_FcrMemberCur_MiddleAdditional3_NAME    CHAR(16),
          @Lc_FcrMemberCur_LastAdditional3_NAME      CHAR(30),
          @Lc_FcrMemberCur_FirstAdditional4_NAME     CHAR(16),
          @Lc_FcrMemberCur_MiddleAdditional4_NAME    CHAR(16),
          @Lc_FcrMemberCur_LastAdditional4_NAME      CHAR(30),
          @Lc_FcrMemberCur_NewMemberMci_IDNO         CHAR(15),
          @Lc_FcrMemberCur_Irs1099_INDC              CHAR(1),
          @Lc_FcrMemberCur_LocateSource1_CODE        CHAR(3),
          @Lc_FcrMemberCur_LocateSource2_CODE        CHAR(3),
          @Lc_FcrMemberCur_LocateSource3_CODE        CHAR(3),
          @Lc_FcrMemberCur_LocateSource4_CODE        CHAR(3),
          @Lc_FcrMemberCur_LocateSource5_CODE        CHAR(3),
          @Lc_FcrMemberCur_LocateSource6_CODE        CHAR(3),
          @Lc_FcrMemberCur_LocateSource7_CODE        CHAR(3),
          @Lc_FcrMemberCur_LocateSource8_CODE        CHAR(3),
          @Lc_FcrQueryCur_Rec_ID                     CHAR(2),
          @Lc_FcrQueryCur_TypeAction_CODE            CHAR(1),
          @Lc_FcrQueryCur_Case_IDNO                  CHAR(15),
          @Lc_FcrQueryCur_UserField_NAME             CHAR(15),
          @Lc_FcrQueryCur_CountyFips_CODE            CHAR(3),
          @Lc_FcrQueryCur_MemberMci_IDNO             CHAR(15),
          @Lc_FcrQueryCur_MemberSsn_NUMB             CHAR(9),
          @Lc_FcrNcoaCur_Rec_ID                      CHAR(2),
          @Lc_FcrNcoaCur_TypeAction_CODE             CHAR(1),
          @Lc_FcrNcoaCur_StateFips_CODE              CHAR(2),
          @Lc_FcrNcoaCur_First_NAME                  CHAR(16),
          @Lc_FcrNcoaCur_Middle_NAME                 CHAR(16),
          @Lc_FcrNcoaCur_Last_NAME                   CHAR(30),
          @Lc_FcrNcoaCur_Line1_ADDR                  CHAR(40),
          @Lc_FcrNcoaCur_Line2_ADDR                  CHAR(40),
          @Lc_FcrNcoaCur_City_ADDR                   CHAR(20),
          @Lc_FcrNcoaCur_State_ADDR                  CHAR(2),
          @Lc_FcrNcoaCur_Zip_ADDR                    CHAR(9),
          @Lc_FcrNcoaCur_MemberSsn_NUMB              CHAR(9),
          @Lc_FcrNcoaCur_MemberMci_IDNO              CHAR(15),
          @Lc_FcrNcoaCur_UserField_NAME              CHAR(15);
  --cursor to select case details 
  DECLARE FcrCase_CUR INSENSITIVE CURSOR FOR
   SELECT A.Rec_ID,
          A.TypeAction_CODE,
          A.Case_IDNO,
          A.TypeCase_CODE,
          A.Order_INDC,
          A.CountyFips_CODE,
          A.UserField_NAME,
          A.CasePrevious_IDNO
     FROM EFCAS_Y1 A;
  --cursor to select member details
  DECLARE FcrMember_CUR INSENSITIVE CURSOR FOR
   SELECT A.Rec_ID,
          A.TypeAction_CODE,
          A.Case_IDNO,
          A.ReservedFcr_CODE,
          A.UserField_NAME,
          A.CountyFips_CODE,
          A.TypeLocReq_CODE,
          @Lc_Space_TEXT AS BundleResults_INDC,
          A.TypeParticipant_CODE,
          A.FamilyViolence_CODE,
          A.MemberMci_IDNO,
          A.Sex_CODE,
          A.Birth_DATE,
          A.MemberSsn_NUMB,
          A.PreviousMemberSsn_NUMB,
          A.First_NAME,
          A.Middle_NAME,
          A.Last_NAME,
          A.CityBirth_NAME,
          A.StCountryBirth_CODE,
          A.FirstFather_NAME,
          A.MiddleFather_NAME,
          A.LastFather_NAME,
          A.FirstMother_NAME,
          A.MiddleMother_NAME,
          A.LastMother_NAME,
          A.IrsUsedMemberSsn_NUMB,
          A.MemberAdditional1Ssn_NUMB,
          A.MemberAdditional2Ssn_NUMB,
          A.FirstAdditional1_NAME,
          A.MiddleAdditional1_NAME,
          A.LastAdditional1_NAME,
          A.FirstAdditional2_NAME,
          A.MiddleAdditional2_NAME,
          A.LastAdditional2_NAME,
          A.FirstAdditional3_NAME,
          A.MiddleAdditional3_NAME,
          A.LastAdditional3_NAME,
          A.FirstAdditional4_NAME,
          A.MiddleAdditional4_NAME,
          A.LastAdditional4_NAME,
          A.NewMemberMci_IDNO,
          A.Irs1099_INDC,
          A.LocateSource1_CODE,
          A.LocateSource2_CODE,
          A.LocateSource3_CODE,
          A.LocateSource4_CODE,
          A.LocateSource5_CODE,
          A.LocateSource6_CODE,
          A.LocateSource7_CODE,
          A.LocateSource8_CODE
     FROM EFMEM_Y1 A
    ORDER BY A.TypeAction_CODE;
  --cursor to select fcr query details
  DECLARE FcrQuery_CUR INSENSITIVE CURSOR FOR
   SELECT A.Rec_ID,
          A.TypeAction_CODE,
          A.Case_IDNO,
          A.UserField_NAME,
          A.CountyFips_CODE,
          A.MemberMci_IDNO,
          A.MemberSsn_NUMB
     FROM EFQRY_Y1 A;
  --cursor to select ncoa details
  DECLARE FcrNcoa_CUR INSENSITIVE CURSOR FOR
   SELECT A.Rec_ID,
          A.TypeAction_CODE,
          A.StateFips_CODE,
          A.First_NAME,
          A.Middle_NAME,
          A.Last_NAME,
          A.Line1_ADDR,
          A.Line2_ADDR,
          A.City_ADDR,
          A.State_ADDR,
          A.Zip_ADDR,
          A.MemberSsn_NUMB,
          A.MemberMci_IDNO,
          A.UserField_NAME
     FROM EFNCA_Y1 A;

  BEGIN TRY
   SET @Ld_Start_DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'CREATE ##ExtractFcr_P1';

   CREATE TABLE ##ExtractFcr_P1
    (
	  Seq_IDNO NUMERIC IDENTITY(1, 1),    
      Record_TEXT CHAR(640)
    );

   SET @Ls_Sql_TEXT = 'PREPARE HEADER RECORD';
   SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
   SET @Ls_Record_TEXT = @Lc_RecHeader_ID + @Lc_InStateFips_CODE + @Lc_Version_TEXT + CONVERT(VARCHAR(8), @Ld_Run_DATE, 112) + (RIGHT(REPLICATE('0', 6) + LTRIM(RTRIM(CAST(@An_Batch_NUMB AS VARCHAR))), 6)) + REPLICATE(@Lc_Space_TEXT, 617);
   SET @Ls_Sql_TEXT = 'WRITE HEADER RECORD TO FILE';
   SET @Ls_SqlData_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

   INSERT INTO ##ExtractFcr_P1
               (Record_TEXT)
   SELECT @Ls_Record_TEXT AS Record_TEXT;

   SET @Ls_Sql_TEXT = 'OPEN FcrCase_CUR';

   OPEN FcrCase_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrCase_CUR - 1';

   FETCH NEXT FROM FcrCase_CUR INTO @Lc_FcrCaseCur_Rec_ID, @Lc_FcrCaseCur_TypeAction_CODE, @Lc_FcrCaseCur_Case_IDNO, @Lc_FcrCaseCur_TypeCase_CODE, @Lc_FcrCaseCur_Order_INDC, @Lc_FcrCaseCur_CountyFips_CODE, @Lc_FcrCaseCur_UserField_NAME, @Lc_FcrCaseCur_CasePrevious_IDNO;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH FcrCase_CUR';

   --prepare and write case detail records to file
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Record_TEXT = '';
     SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
     
     IF ISNUMERIC(ISNULL(@Lc_FcrCaseCur_Case_IDNO, '')) = 0
     OR CAST(@Lc_FcrCaseCur_Case_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrCaseCur_Case_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrCaseCur_Case_IDNO = RIGHT(('000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrCaseCur_Case_IDNO, '0')))), 6);
     END
     
     IF ISNUMERIC(ISNULL(@Lc_FcrCaseCur_CasePrevious_IDNO, '')) = 0
     OR CAST(@Lc_FcrCaseCur_CasePrevious_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrCaseCur_CasePrevious_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrCaseCur_CasePrevious_IDNO = RIGHT(('000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrCaseCur_CasePrevious_IDNO, '0')))), 6);
     END
          
     SET @Ls_Sql_TEXT = 'PREPARE CASE DETAIL RECORD';
     SET @Ls_Record_TEXT = ISNULL(@Lc_FcrCaseCur_Rec_ID, @Lc_RecCase_ID) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrCaseCur_TypeAction_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrCaseCur_Case_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrCaseCur_TypeCase_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrCaseCur_Order_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrCaseCur_CountyFips_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + REPLICATE(@Lc_Space_TEXT, 2) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrCaseCur_UserField_NAME)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrCaseCur_CasePrevious_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + REPLICATE(@Lc_Space_TEXT, 585);
     SET @Ls_Sql_TEXT = 'WRITE CASE DETAIL RECORD TO FILE';
     SET @Ls_SqlData_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

     INSERT INTO ##ExtractFcr_P1
                 (Record_TEXT)
     SELECT @Ls_Record_TEXT AS Record_TEXT;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrCase_CUR - 2';

     FETCH NEXT FROM FcrCase_CUR INTO @Lc_FcrCaseCur_Rec_ID, @Lc_FcrCaseCur_TypeAction_CODE, @Lc_FcrCaseCur_Case_IDNO, @Lc_FcrCaseCur_TypeCase_CODE, @Lc_FcrCaseCur_Order_INDC, @Lc_FcrCaseCur_CountyFips_CODE, @Lc_FcrCaseCur_UserField_NAME, @Lc_FcrCaseCur_CasePrevious_IDNO;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'FcrCase_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE FcrCase_CUR';

     CLOSE FcrCase_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FcrCase_CUR';

     DEALLOCATE FcrCase_CUR;
    END

   SET @Ls_Sql_TEXT = 'OPEN FcrMember_CUR';

   OPEN FcrMember_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrMember_CUR - 1';

   FETCH NEXT FROM FcrMember_CUR INTO @Lc_FcrMemberCur_Rec_ID, @Lc_FcrMemberCur_TypeAction_CODE, @Lc_FcrMemberCur_Case_IDNO, @Lc_FcrMemberCur_ReservedFcr_CODE, @Lc_FcrMemberCur_UserField_NAME, @Lc_FcrMemberCur_CountyFips_CODE, @Lc_FcrMemberCur_TypeLocReq_CODE, @Lc_FcrMemberCur_BundleResults_INDC, @Lc_FcrMemberCur_TypeParticipant_CODE, @Lc_FcrMemberCur_FamilyViolence_CODE, @Lc_FcrMemberCur_MemberMci_IDNO, @Lc_FcrMemberCur_Sex_CODE, @Lc_FcrMemberCur_Birth_DATE, @Lc_FcrMemberCur_MemberSsn_NUMB, @Lc_FcrMemberCur_PreviousMemberSsn_NUMB, @Lc_FcrMemberCur_First_NAME, @Lc_FcrMemberCur_Middle_NAME, @Lc_FcrMemberCur_Last_NAME, @Lc_FcrMemberCur_CityBirth_ADDR, @Lc_FcrMemberCur_StCountryBirth_ADDR, @Lc_FcrMemberCur_FirstFather_NAME, @Lc_FcrMemberCur_MiddleFather_NAME, @Lc_FcrMemberCur_LastFather_NAME, @Lc_FcrMemberCur_FirstMother_NAME, @Lc_FcrMemberCur_MiddleMother_NAME, @Lc_FcrMemberCur_LastMother_NAME, @Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB, @Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB, @Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB, @Lc_FcrMemberCur_FirstAdditional1_NAME, @Lc_FcrMemberCur_MiddleAdditional1_NAME, @Lc_FcrMemberCur_LastAdditional1_NAME, @Lc_FcrMemberCur_FirstAdditional2_NAME, @Lc_FcrMemberCur_MiddleAdditional2_NAME, @Lc_FcrMemberCur_LastAdditional2_NAME, @Lc_FcrMemberCur_FirstAdditional3_NAME, @Lc_FcrMemberCur_MiddleAdditional3_NAME, @Lc_FcrMemberCur_LastAdditional3_NAME, @Lc_FcrMemberCur_FirstAdditional4_NAME, @Lc_FcrMemberCur_MiddleAdditional4_NAME, @Lc_FcrMemberCur_LastAdditional4_NAME, @Lc_FcrMemberCur_NewMemberMci_IDNO, @Lc_FcrMemberCur_Irs1099_INDC, @Lc_FcrMemberCur_LocateSource1_CODE, @Lc_FcrMemberCur_LocateSource2_CODE, @Lc_FcrMemberCur_LocateSource3_CODE, @Lc_FcrMemberCur_LocateSource4_CODE, @Lc_FcrMemberCur_LocateSource5_CODE, @Lc_FcrMemberCur_LocateSource6_CODE, @Lc_FcrMemberCur_LocateSource7_CODE, @Lc_FcrMemberCur_LocateSource8_CODE;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH FcrMember_CUR';

   --prepare and write person detail records to file
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Record_TEXT = '';
     SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
     
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_Case_IDNO, '')) = 0
     OR CAST(@Lc_FcrMemberCur_Case_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_Case_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_Case_IDNO = RIGHT(('000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_Case_IDNO, '0')))), 6);
     END
          
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_MemberMci_IDNO, '')) = 0
     OR CAST(@Lc_FcrMemberCur_MemberMci_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_MemberMci_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_MemberMci_IDNO = RIGHT(('0000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_MemberMci_IDNO, '0')))), 10);
     END
     
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_MemberSsn_NUMB, '')) = 0
     OR CAST(@Lc_FcrMemberCur_MemberSsn_NUMB AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_MemberSsn_NUMB = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_MemberSsn_NUMB = RIGHT(('000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_MemberSsn_NUMB, '0')))), 9);
     END
          
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_PreviousMemberSsn_NUMB, '')) = 0
     OR CAST(@Lc_FcrMemberCur_PreviousMemberSsn_NUMB AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_PreviousMemberSsn_NUMB = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_PreviousMemberSsn_NUMB = RIGHT(('000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_PreviousMemberSsn_NUMB, '0')))), 9);
     END
          
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB, '')) = 0
     OR CAST(@Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB = RIGHT(('000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB, '0')))), 9);
     END
          
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB, '')) = 0
     OR CAST(@Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB = RIGHT(('000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB, '0')))), 9);
     END
     
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB, '')) = 0
     OR CAST(@Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB = RIGHT(('000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB, '0')))), 9);
     END
     
     IF ISNUMERIC(ISNULL(@Lc_FcrMemberCur_NewMemberMci_IDNO, '')) = 0
     OR CAST(@Lc_FcrMemberCur_NewMemberMci_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrMemberCur_NewMemberMci_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrMemberCur_NewMemberMci_IDNO = RIGHT(('0000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrMemberCur_NewMemberMci_IDNO, '0')))), 10);
     END
          
     SET @Ls_Sql_TEXT = 'PREPARE PERSON DETAIL RECORD';
     SET @Ls_Record_TEXT = ISNULL(@Lc_FcrMemberCur_Rec_ID, @Lc_RecPerson_ID) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_TypeAction_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_Case_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + REPLICATE(@Lc_Space_TEXT, 2) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_UserField_NAME)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_CountyFips_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + REPLICATE(@Lc_Space_TEXT, 2) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_TypeLocReq_CODE)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) + REPLICATE(@Lc_Space_TEXT, 1) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_TypeParticipant_CODE)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_FamilyViolence_CODE)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MemberMci_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_Sex_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_Birth_DATE)) + REPLICATE(' ', 8)), 8) AS CHAR(8)), REPLICATE(@Lc_Space_TEXT, 8))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MemberSsn_NUMB)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_PreviousMemberSsn_NUMB)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_First_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_Middle_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_Last_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_CityBirth_ADDR)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_StCountryBirth_ADDR)) + REPLICATE(' ', 4)), 4) AS CHAR(4)), REPLICATE(@Lc_Space_TEXT, 4))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_FirstFather_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MiddleFather_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LastFather_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_FirstMother_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MiddleMother_NAME)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LastMother_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_FirstAdditional1_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MiddleAdditional1_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LastAdditional1_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_FirstAdditional2_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MiddleAdditional2_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LastAdditional2_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_FirstAdditional3_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MiddleAdditional3_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LastAdditional3_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_FirstAdditional4_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_MiddleAdditional4_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LastAdditional4_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_NewMemberMci_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_Irs1099_INDC)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource1_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource2_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource3_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource4_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource5_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource6_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource7_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrMemberCur_LocateSource8_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + REPLICATE(@Lc_Space_TEXT, 21) + REPLICATE(@Lc_Space_TEXT, 15) + REPLICATE(@Lc_Space_TEXT, 9) + REPLICATE(@Lc_Space_TEXT, 43);
     SET @Ls_Sql_TEXT = 'WRITE PERSON DETAIL RECORD TO FILE';
     SET @Ls_SqlData_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

     INSERT INTO ##ExtractFcr_P1
                 (Record_TEXT)
     SELECT @Ls_Record_TEXT AS Record_TEXT;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrMember_CUR - 2';

     FETCH NEXT FROM FcrMember_CUR INTO @Lc_FcrMemberCur_Rec_ID, @Lc_FcrMemberCur_TypeAction_CODE, @Lc_FcrMemberCur_Case_IDNO, @Lc_FcrMemberCur_ReservedFcr_CODE, @Lc_FcrMemberCur_UserField_NAME, @Lc_FcrMemberCur_CountyFips_CODE, @Lc_FcrMemberCur_TypeLocReq_CODE, @Lc_FcrMemberCur_BundleResults_INDC, @Lc_FcrMemberCur_TypeParticipant_CODE, @Lc_FcrMemberCur_FamilyViolence_CODE, @Lc_FcrMemberCur_MemberMci_IDNO, @Lc_FcrMemberCur_Sex_CODE, @Lc_FcrMemberCur_Birth_DATE, @Lc_FcrMemberCur_MemberSsn_NUMB, @Lc_FcrMemberCur_PreviousMemberSsn_NUMB, @Lc_FcrMemberCur_First_NAME, @Lc_FcrMemberCur_Middle_NAME, @Lc_FcrMemberCur_Last_NAME, @Lc_FcrMemberCur_CityBirth_ADDR, @Lc_FcrMemberCur_StCountryBirth_ADDR, @Lc_FcrMemberCur_FirstFather_NAME, @Lc_FcrMemberCur_MiddleFather_NAME, @Lc_FcrMemberCur_LastFather_NAME, @Lc_FcrMemberCur_FirstMother_NAME, @Lc_FcrMemberCur_MiddleMother_NAME, @Lc_FcrMemberCur_LastMother_NAME, @Lc_FcrMemberCur_IrsUsedMemberSsn_NUMB, @Lc_FcrMemberCur_MemberAdditional1Ssn_NUMB, @Lc_FcrMemberCur_MemberAdditional2Ssn_NUMB, @Lc_FcrMemberCur_FirstAdditional1_NAME, @Lc_FcrMemberCur_MiddleAdditional1_NAME, @Lc_FcrMemberCur_LastAdditional1_NAME, @Lc_FcrMemberCur_FirstAdditional2_NAME, @Lc_FcrMemberCur_MiddleAdditional2_NAME, @Lc_FcrMemberCur_LastAdditional2_NAME, @Lc_FcrMemberCur_FirstAdditional3_NAME, @Lc_FcrMemberCur_MiddleAdditional3_NAME, @Lc_FcrMemberCur_LastAdditional3_NAME, @Lc_FcrMemberCur_FirstAdditional4_NAME, @Lc_FcrMemberCur_MiddleAdditional4_NAME, @Lc_FcrMemberCur_LastAdditional4_NAME, @Lc_FcrMemberCur_NewMemberMci_IDNO, @Lc_FcrMemberCur_Irs1099_INDC, @Lc_FcrMemberCur_LocateSource1_CODE, @Lc_FcrMemberCur_LocateSource2_CODE, @Lc_FcrMemberCur_LocateSource3_CODE, @Lc_FcrMemberCur_LocateSource4_CODE, @Lc_FcrMemberCur_LocateSource5_CODE, @Lc_FcrMemberCur_LocateSource6_CODE, @Lc_FcrMemberCur_LocateSource7_CODE, @Lc_FcrMemberCur_LocateSource8_CODE;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'FcrMember_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE FcrMember_CUR';

     CLOSE FcrMember_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FcrMember_CUR';

     DEALLOCATE FcrMember_CUR;
    END

   SET @Ls_Sql_TEXT = 'OPEN FcrQuery_CUR';

   OPEN FcrQuery_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrQuery_CUR - 1';

   FETCH NEXT FROM FcrQuery_CUR INTO @Lc_FcrQueryCur_Rec_ID, @Lc_FcrQueryCur_TypeAction_CODE, @Lc_FcrQueryCur_Case_IDNO, @Lc_FcrQueryCur_UserField_NAME, @Lc_FcrQueryCur_CountyFips_CODE, @Lc_FcrQueryCur_MemberMci_IDNO, @Lc_FcrQueryCur_MemberSsn_NUMB;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH FcrQuery_CUR';

   --prepare and write fcr query records to file
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Record_TEXT = '';
     SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
     
     IF ISNUMERIC(ISNULL(@Lc_FcrQueryCur_Case_IDNO, '')) = 0
     OR CAST(@Lc_FcrQueryCur_Case_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrQueryCur_Case_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrQueryCur_Case_IDNO = RIGHT(('000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrQueryCur_Case_IDNO, '0')))), 6);
     END
          
     IF ISNUMERIC(ISNULL(@Lc_FcrQueryCur_MemberMci_IDNO, '')) = 0
     OR CAST(@Lc_FcrQueryCur_MemberMci_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrQueryCur_MemberMci_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrQueryCur_MemberMci_IDNO = RIGHT(('0000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrQueryCur_MemberMci_IDNO, '0')))), 10);
     END
     
     IF ISNUMERIC(ISNULL(@Lc_FcrQueryCur_MemberSsn_NUMB, '')) = 0
     OR CAST(@Lc_FcrQueryCur_MemberSsn_NUMB AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrQueryCur_MemberSsn_NUMB = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrQueryCur_MemberSsn_NUMB = RIGHT(('000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrQueryCur_MemberSsn_NUMB, '0')))), 9);
     END
     
     SET @Ls_Sql_TEXT = 'PREPARE FCR QUERY RECORD';
     SET @Ls_Record_TEXT = ISNULL(@Lc_FcrQueryCur_Rec_ID, @Lc_RecQuery_ID) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrQueryCur_TypeAction_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrQueryCur_Case_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrQueryCur_UserField_NAME)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrQueryCur_CountyFips_CODE)) + REPLICATE(' ', 3)), 3) AS CHAR(3)), REPLICATE(@Lc_Space_TEXT, 3))) + REPLICATE(@Lc_Space_TEXT, 2) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrQueryCur_MemberMci_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrQueryCur_MemberSsn_NUMB)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) + REPLICATE(@Lc_Space_TEXT, 2) + REPLICATE(@Lc_Space_TEXT, 576);
     SET @Ls_Sql_TEXT = 'WRITE FCR QUERY RECORD TO FILE';
     SET @Ls_SqlData_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

     INSERT INTO ##ExtractFcr_P1
                 (Record_TEXT)
     SELECT @Ls_Record_TEXT AS Record_TEXT;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrQuery_CUR - 2';

     FETCH NEXT FROM FcrQuery_CUR INTO @Lc_FcrQueryCur_Rec_ID, @Lc_FcrQueryCur_TypeAction_CODE, @Lc_FcrQueryCur_Case_IDNO, @Lc_FcrQueryCur_UserField_NAME, @Lc_FcrQueryCur_CountyFips_CODE, @Lc_FcrQueryCur_MemberMci_IDNO, @Lc_FcrQueryCur_MemberSsn_NUMB;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'FcrQuery_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE FcrQuery_CUR';

     CLOSE FcrQuery_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FcrQuery_CUR';

     DEALLOCATE FcrQuery_CUR;
    END

   SET @Ls_Sql_TEXT = 'OPEN FcrNcoa_CUR';

   OPEN FcrNcoa_CUR;

   SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrNcoa_CUR - 1';

   FETCH NEXT FROM FcrNcoa_CUR INTO @Lc_FcrNcoaCur_Rec_ID, @Lc_FcrNcoaCur_TypeAction_CODE, @Lc_FcrNcoaCur_StateFips_CODE, @Lc_FcrNcoaCur_First_NAME, @Lc_FcrNcoaCur_Middle_NAME, @Lc_FcrNcoaCur_Last_NAME, @Lc_FcrNcoaCur_Line1_ADDR, @Lc_FcrNcoaCur_Line2_ADDR, @Lc_FcrNcoaCur_City_ADDR, @Lc_FcrNcoaCur_State_ADDR, @Lc_FcrNcoaCur_Zip_ADDR, @Lc_FcrNcoaCur_MemberSsn_NUMB, @Lc_FcrNcoaCur_MemberMci_IDNO, @Lc_FcrNcoaCur_UserField_NAME;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
   SET @Ls_Sql_TEXT = 'LOOP THROUGH FcrNcoa_CUR';

   --prepare and write ncoa records to file  
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
     SET @Ls_Record_TEXT = '';
     SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
     
     IF ISNUMERIC(ISNULL(@Lc_FcrNcoaCur_MemberSsn_NUMB, '')) = 0
     OR CAST(@Lc_FcrNcoaCur_MemberSsn_NUMB AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrNcoaCur_MemberSsn_NUMB = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrNcoaCur_MemberSsn_NUMB = RIGHT(('000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrNcoaCur_MemberSsn_NUMB, '0')))), 9);
     END
          
     IF ISNUMERIC(ISNULL(@Lc_FcrNcoaCur_MemberMci_IDNO, '')) = 0
     OR CAST(@Lc_FcrNcoaCur_MemberMci_IDNO AS NUMERIC) = 0
     BEGIN
		SET @Lc_FcrNcoaCur_MemberMci_IDNO = '';
     END
     ELSE
     BEGIN
		SET @Lc_FcrNcoaCur_MemberMci_IDNO = RIGHT(('0000000000' + LTRIM(RTRIM(ISNULL(@Lc_FcrNcoaCur_MemberMci_IDNO, '0')))), 10);
     END
     
     SET @Ls_Sql_TEXT = 'PREPARE NCOA RECORD';
     SET @Ls_Record_TEXT = ISNULL(@Lc_FcrNcoaCur_Rec_ID, @Lc_RecNcoa_ID) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_TypeAction_CODE)) + REPLICATE(' ', 1)), 1) AS CHAR(1)), REPLICATE(@Lc_Space_TEXT, 1))) + REPLICATE(@Lc_Space_TEXT, 15) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_StateFips_CODE)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) + REPLICATE(@Lc_Space_TEXT, 44) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_First_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_Middle_NAME)) + REPLICATE(' ', 16)), 16) AS CHAR(16)), REPLICATE(@Lc_Space_TEXT, 16))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_Last_NAME)) + REPLICATE(' ', 30)), 30) AS CHAR(30)), REPLICATE(@Lc_Space_TEXT, 30))) + REPLICATE(@Lc_Space_TEXT, 34) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_Line1_ADDR)) + REPLICATE(' ', 40)), 40) AS CHAR(40)), REPLICATE(@Lc_Space_TEXT, 40))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_Line2_ADDR)) + REPLICATE(' ', 40)), 40) AS CHAR(40)), REPLICATE(@Lc_Space_TEXT, 40))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_City_ADDR)) + REPLICATE(' ', 20)), 20) AS CHAR(20)), REPLICATE(@Lc_Space_TEXT, 20))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_State_ADDR)) + REPLICATE(' ', 2)), 2) AS CHAR(2)), REPLICATE(@Lc_Space_TEXT, 2))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_Zip_ADDR)) + REPLICATE(' ', 9)), 9) AS CHAR(9)), REPLICATE(@Lc_Space_TEXT, 9))) + REPLICATE(@Lc_Space_TEXT, 42) + (RIGHT(REPLICATE('0', 9) + LTRIM(RTRIM(@Lc_FcrNcoaCur_MemberSsn_NUMB)), 9)) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_MemberMci_IDNO)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + (ISNULL(CAST(LEFT((LTRIM(RTRIM(@Lc_FcrNcoaCur_UserField_NAME)) + REPLICATE(' ', 15)), 15) AS CHAR(15)), REPLICATE(@Lc_Space_TEXT, 15))) + REPLICATE(@Lc_Space_TEXT, 288);
     SET @Ls_Sql_TEXT = 'WRITE NCOA RECORD TO FILE';
     SET @Ls_SqlData_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

     INSERT INTO ##ExtractFcr_P1
                 (Record_TEXT)
     SELECT @Ls_Record_TEXT AS Record_TEXT;

     SET @Ls_Sql_TEXT = 'FETCH NEXT FROM FcrNcoa_CUR - 2';

     FETCH NEXT FROM FcrNcoa_CUR INTO @Lc_FcrNcoaCur_Rec_ID, @Lc_FcrNcoaCur_TypeAction_CODE, @Lc_FcrNcoaCur_StateFips_CODE, @Lc_FcrNcoaCur_First_NAME, @Lc_FcrNcoaCur_Middle_NAME, @Lc_FcrNcoaCur_Last_NAME, @Lc_FcrNcoaCur_Line1_ADDR, @Lc_FcrNcoaCur_Line2_ADDR, @Lc_FcrNcoaCur_City_ADDR, @Lc_FcrNcoaCur_State_ADDR, @Lc_FcrNcoaCur_Zip_ADDR, @Lc_FcrNcoaCur_MemberSsn_NUMB, @Lc_FcrNcoaCur_MemberMci_IDNO, @Lc_FcrNcoaCur_UserField_NAME;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END

   IF CURSOR_STATUS('LOCAL', 'FcrNcoa_CUR') IN (0, 1)
    BEGIN
     SET @Ls_Sql_TEXT = 'CLOSE FcrNcoa_CUR';

     CLOSE FcrNcoa_CUR;

     SET @Ls_Sql_TEXT = 'DEALLOCATE FcrNcoa_CUR';

     DEALLOCATE FcrNcoa_CUR;
    END

   SET @Ls_Sql_TEXT = 'PREPARE TRAILER RECORD';
   SET @Ln_RecordCount_QNTY = @Ln_RecordCount_QNTY + 1;
   SET @Ls_Record_TEXT = @Lc_RecTrailer_ID + (RIGHT(REPLICATE('0', 8) + LTRIM(RTRIM(CAST(@Ln_RecordCount_QNTY AS VARCHAR))), 8)) + REPLICATE(@Lc_Space_TEXT, 617);
   SET @Ls_Sql_TEXT = 'WRITE TRAILER RECORD TO FILE';
   SET @Ls_SqlData_TEXT = 'Record_TEXT = ' + ISNULL(@Ls_Record_TEXT, '');

   INSERT INTO ##ExtractFcr_P1
               (Record_TEXT)
   SELECT @Ls_Record_TEXT AS Record_TEXT;

   --Extract data from table to a File.
   SET @Ls_Query_TEXT = 'SELECT Record_TEXT FROM ##ExtractFcr_P1 ORDER BY Seq_IDNO';
   SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_EXTRACT_DATA';
   SET @Ls_SqlData_TEXT = 'FileLocation_TEXT = ' + ISNULL(@Ls_FileLocation_TEXT, '') + ', File_NAME = ' + ISNULL(@Ls_File_NAME, '') + ', Query_TEXT = ' + ISNULL(@Ls_Query_TEXT, '');

   EXECUTE BATCH_COMMON$SP_EXTRACT_DATA
    @As_FileLocation_TEXT     = @Ls_FileLocation_TEXT,
    @As_File_NAME             = @Ls_File_NAME,
    @As_Query_TEXT            = @Ls_Query_TEXT,
    @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
    BEGIN
     SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;

     RAISERROR (50001,16,1);
    END;

   --Drop the temporary table.
   SET @Ls_Sql_TEXT = 'DROP TABLE ##ExtractFcr_P1';

   DROP TABLE ##ExtractFcr_P1;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('LOCAL', 'FcrCase_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrCase_CUR;

     DEALLOCATE FcrCase_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'FcrMember_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrMember_CUR;

     DEALLOCATE FcrMember_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'FcrQuery_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrQuery_CUR;

     DEALLOCATE FcrQuery_CUR;
    END

   IF CURSOR_STATUS('LOCAL', 'FcrNcoa_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrNcoa_CUR;

     DEALLOCATE FcrNcoa_CUR;
    END

   IF OBJECT_ID('tempdb..##ExtractFcr_P1') IS NOT NULL
    BEGIN
     DROP TABLE ##ExtractFcr_P1;
    END;

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

   SELECT '@Ls_DescriptionError_TEXT  = ' + @Ls_DescriptionError_TEXT;

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
