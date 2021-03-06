/****** Object:  StoredProcedure [dbo].[BATCH_LOC_INCOMING_FCR$SP_NCOADDRESS_DETAILS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------------
Procedure Name	     : BATCH_LOC_INCOMING_FCR$SP_NCOADDRESS_DETAILS 
Programmer Name		 : IMP Team
Description			 : The procedure reads the the NCOA (National Change of Address Verification )
                       details from the temporary table LFNCA_Y1
                       and look for the NCP to update the AHIS_Y1.  
Frequency			 : Daily
Developed On		 : 04/18/2011
Called By			 : BATCH_LOC_INCOMING_FCR$SP_PROCESS_FCR_RESPONSE
Called On			 : BATCH_COMMON$SP_ADDRESS_UPDATE
					   BATCH_COMMON$SP_BATE_LOG 
					   BATCH_COMMON$SP_BATCH_RESTART_UPDATE
------------------------------------------------------------------------------------------------------------------------
Modified By			 : 
Modified On			 :
Version No			 : 1.0
------------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_LOC_INCOMING_FCR$SP_NCOADDRESS_DETAILS]
 @Ac_Job_ID                  CHAR(7),
 @Ad_Run_DATE                DATE,
 @As_Process_NAME            VARCHAR(100),
 @An_CommitFreq_QNTY         NUMERIC(5),
 @An_ExceptionThreshold_QNTY NUMERIC(5),
 @An_ProcessedRecordCount_QNTY NUMERIC(6) OUTPUT,
 @Ac_Msg_CODE                CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE  @Ln_Exists_NUMB                  NUMERIC(2) = 0,
           @Lc_StatusCaseMemberActive_CODE  CHAR(1) = 'A',
           @Lc_VerificationStatusGood_CODE  CHAR(1) = 'Y',
           @Lc_ProcessY_INDC                CHAR(1) = 'Y',
           @Lc_StatusFailed_CODE            CHAR(1) = 'F',
           @Lc_ErrorTypeError_CODE          CHAR(1) = 'E',
           @Lc_StatusSuccess_CODE           CHAR(1) = 'S',
           @Lc_NcoaReturn_CODE              CHAR(1) = 'A',
           @Lc_MoveTypeInd_CODE             CHAR(1) = 'I',
           @Lc_MoveTypeFam_CODE             CHAR(1) = 'F',
           @Lc_TypeAddressM_CODE            CHAR(1) = 'M',
           @Lc_SourceVerifiedO_CODE         CHAR(1) = 'O',
           @Lc_NcoaResponse01_CODE          CHAR(2) = '01',
           @Lc_NcoaResponse02_CODE          CHAR(2) = '02',
           @Lc_NcoaResponse03_CODE          CHAR(2) = '03',
           @Lc_NcoaResponse04_CODE          CHAR(2) = '04',
           @Lc_NcoaResponse05_CODE          CHAR(2) = '05',
           @Lc_NcoaResponse06_CODE          CHAR(2) = '06',
           @Lc_NcoaResponse10_CODE          CHAR(2) = '10',
           @Lc_NcoaResponse28_CODE          CHAR(2) = '28',
           @Lc_NcoaResponse39_CODE          CHAR(2) = '39',
           @Lc_LocateSourceNca_CODE         CHAR(3) = 'NCA',
           @Lc_ErrorE0019_CODE              CHAR(5) = 'E0019',
           @Lc_ErrorE0606_CODE              CHAR(5) = 'E0606',
           @Lc_ErrorE0907_CODE              CHAR(5) = 'E0907',
           @Lc_ErrorE1089_CODE              CHAR(5) = 'E1089',
           @Lc_ErrorE1381_CODE              CHAR(5) = 'E1381',
           @Lc_ErrorTE019_CODE              CHAR(5) = 'TE019',
           @Lc_ErrorE1368_CODE              CHAR(5) = 'E1368',
           @Lc_ErrorE1369_CODE              CHAR(5) = 'E1369',
           @Lc_ErrorE1370_CODE              CHAR(5) = 'E1370',
           @Lc_ErrorE1371_CODE              CHAR(5) = 'E1371',
           @Lc_ErrorE1372_CODE              CHAR(5) = 'E1372',
           @Lc_BateErrorE1424_CODE          CHAR(5) = 'E1424',
           @Lc_ProcessFcrNcoa_ID            CHAR(8) = 'FCR_ncoa',
           @Lc_BatchRunUser_TEXT            CHAR(30) = 'BATCH',
           @Ls_Procedure_NAME               VARCHAR(60) = 'SP_NCOADDRESS_DETAILS',
           @Ld_High_DATE                    DATE = '12/31/9999';
  DECLARE  @Ln_Zero_NUMB					NUMERIC(1) = 0,
           @Ln_CommitFreq_QNTY				NUMERIC(5) = 0,
           @Ln_ExceptionThreshold_QNTY		NUMERIC(5) = 0,
           @Ln_ProcessedRecordCount_QNTY	NUMERIC(6) = 0,
           @Ln_ProcessedRecordCountCommit_QNTY NUMERIC(6) = 0,
           @Ln_Cur_QNTY						NUMERIC(10,0) = 0,
           @Ln_MemberMci_IDNO				NUMERIC(10) = 0,
           @Ln_Error_NUMB					NUMERIC(11),
           @Ln_ErrorLine_NUMB				NUMERIC(11),
           @Li_FetchStatus_QNTY				SMALLINT,
           @Li_RowCount_QNTY				SMALLINT,
           @Lc_Space_TEXT					CHAR(1) = '',
           @Lc_TypeError_CODE				CHAR(1) = '',
           @Lc_Msg_CODE						CHAR(5) = '',
           @Lc_BateError_CODE               CHAR(5) = '',
           @Ls_Sql_TEXT						VARCHAR(100),
           @Ls_CursorLoc_TEXT				VARCHAR(200),
           @Ls_Sqldata_TEXT					VARCHAR(1000),
           @Ls_BateRecord_TEXT              VARCHAR(4000) = '',
           @Ls_ErrorMessage_TEXT			VARCHAR(4000),
           @Ls_DescriptionError_TEXT		VARCHAR(4000);

  DECLARE FcrNcoaLoc_CUR INSENSITIVE CURSOR FOR
   SELECT n.Seq_IDNO,
          n.Rec_ID,
          n.Ncoa_CODE,
          n.StateFips_CODE,
          n.First_NAME,
          n.Middle_NAME,
          n.Last_NAME,
          n.SubLine1_ADDR,
          n.SubLine2_ADDR,
          n.SubCity_ADDR,
          n.SubState_ADDR,
          n.SubZip_ADDR,
          n.MemberSsn_NUMB,
          CASE
           WHEN LEN(LTRIM(RTRIM(ISNULL(n.MemberMci_IDNO, '')))) = 0
            THEN '0'
           ELSE n.MemberMci_IDNO
          END AS MemberMci_IDNO,
          n.NcoaResponse_CODE,  
          n.ReturnLine1_ADDR,
          n.ReturnLine2_ADDR,
          n.ReturnCity_ADDR,
          n.ReturnState_ADDR,
          n.ReturnZip_ADDR,
          n.NewReturnNcoa_CODE,
          n.AddressChangeEffYearMonth_NUMB,
          n.MoveType_CODE,
          n.CoaNormalization_CODE,
          n.CoaLine1_ADDR,
          n.CoaLine2_ADDR,
          n.CoaCity_ADDR,
          n.CoaState_ADDR,
          n.CoaZip_ADDR,
          n.Process_INDC
     FROM LFNCA_Y1 n
    WHERE n.Process_INDC = 'N'
    ORDER BY Seq_IDNO;
  DECLARE @Ln_FcrNcoaLocCur_Seq_IDNO              NUMERIC(19),
          @Lc_FcrNcoaLocCur_Rec_ID                CHAR(2),
          @Lc_FcrNcoaLocCur_Ncoa_INDC             CHAR(1),
          @Lc_FcrNcoaLocCur_StateFips_CODE        CHAR(2),
          @Lc_FcrNcoaLocCur_First_NAME            CHAR(16),
          @Lc_FcrNcoaLocCur_Middle_NAME           CHAR(16),
          @Lc_FcrNcoaLocCur_Last_NAME             CHAR(30),
          @Lc_FcrNcoaLocCur_SubLine1_ADDR         CHAR(40),
          @Lc_FcrNcoaLocCur_SubLine2_ADDR         CHAR(40),
          @Lc_FcrNcoaLocCur_SubCity_ADDR          CHAR(20),
          @Lc_FcrNcoaLocCur_SubSt_ADDR            CHAR(2),
          @Lc_FcrNcoaLocCur_SubZip_ADDR           CHAR(9),
          @Lc_FcrNcoaLocCur_MemberSsnNumb_TEXT    CHAR(9),
          @Lc_FcrNcoaLocCur_MemberMciIdno_TEXT    CHAR(10),
          @Lc_FcrNcoaLocCur_NcoaResponse_CODE     CHAR(2),
          @Ls_FcrNcoaLocCur_ReturnLine1_ADDR      VARCHAR(50),
          @Ls_FcrNcoaLocCur_ReturnLine2_ADDR      VARCHAR(50),
          @Lc_FcrNcoaLocCur_ReturnCity_ADDR       CHAR(30),
          @Lc_FcrNcoaLocCur_ReturnSt_ADDR         CHAR(2),
          @Lc_FcrNcoaLocCur_ReturnZip_ADDR        CHAR(9),
          @Lc_FcrNcoaLocCur_NewReturn_CODE        CHAR(2),
          @Lc_FcrNcoaLocCur_AddressChangeEff_DATE CHAR(6),
          @Lc_FcrNcoaLocCur_MoveType_CODE         CHAR(1),
          @Lc_FcrNcoaLocCur_Normalization_CODE    CHAR(1),
          @Ls_FcrNcoaLocCur_Line1_ADDR            VARCHAR(50),
          @Ls_FcrNcoaLocCur_Line2_ADDR            VARCHAR(50),
          @Lc_FcrNcoaLocCur_City_ADDR             CHAR(28),
          @Lc_FcrNcoaLocCur_State_ADDR            CHAR(2),
          @Lc_FcrNcoaLocCur_Zip_ADDR              CHAR(15),
          @Lc_FcrNcoaLocCur_Process_INDC          CHAR(1),
          
          @Ln_FcrNcoaLocCur_MemberMci_IDNO		  NUMERIC(10);

  BEGIN TRY
   
   BEGIN TRANSACTION NCOA_DETAILS;

   SET @Ac_Msg_CODE = @Lc_Space_TEXT;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   SET @Ln_Cur_QNTY = ISNULL(@Ln_Cur_QNTY, 0);
   SET @An_ExceptionThreshold_QNTY = ISNULL(@An_ExceptionThreshold_QNTY, 0);
   SET @As_Process_NAME = ISNULL(@As_Process_NAME, 'BATCH_LOC_INCOMING_FCR');
   SET @An_CommitFreq_QNTY = ISNULL(@An_CommitFreq_QNTY, 0);
   SET @Ls_Sql_TEXT = @Lc_Space_TEXT;
   SET @Ls_Sqldata_TEXT = @Lc_Space_TEXT;
   SET @Ls_CursorLoc_TEXT = @Lc_Space_TEXT;
   SET @Lc_Msg_CODE = @Lc_Space_TEXT;
   SET @Ln_CommitFreq_QNTY = @Ln_Zero_NUMB;
   SET @Ln_Cur_QNTY = 0;
   SET @Ls_Sql_TEXT = 'NCOA LOC OPEN CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   OPEN FcrNcoaLoc_CUR;

   SET @Ls_Sql_TEXT = 'NCOA LOC FETCH  CURSOR';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');

   FETCH NEXT FROM FcrNcoaLoc_CUR INTO @Ln_FcrNcoaLocCur_Seq_IDNO, @Lc_FcrNcoaLocCur_Rec_ID, @Lc_FcrNcoaLocCur_Ncoa_INDC, @Lc_FcrNcoaLocCur_StateFips_CODE, @Lc_FcrNcoaLocCur_First_NAME, @Lc_FcrNcoaLocCur_Middle_NAME, @Lc_FcrNcoaLocCur_Last_NAME, @Lc_FcrNcoaLocCur_SubLine1_ADDR, @Lc_FcrNcoaLocCur_SubLine2_ADDR, @Lc_FcrNcoaLocCur_SubCity_ADDR, @Lc_FcrNcoaLocCur_SubSt_ADDR, @Lc_FcrNcoaLocCur_SubZip_ADDR, @Lc_FcrNcoaLocCur_MemberSsnNumb_TEXT, @Lc_FcrNcoaLocCur_MemberMciIdno_TEXT, @Lc_FcrNcoaLocCur_NcoaResponse_CODE, @Ls_FcrNcoaLocCur_ReturnLine1_ADDR, @Ls_FcrNcoaLocCur_ReturnLine2_ADDR, @Lc_FcrNcoaLocCur_ReturnCity_ADDR, @Lc_FcrNcoaLocCur_ReturnSt_ADDR, @Lc_FcrNcoaLocCur_ReturnZip_ADDR, @Lc_FcrNcoaLocCur_NewReturn_CODE, @Lc_FcrNcoaLocCur_AddressChangeEff_DATE, @Lc_FcrNcoaLocCur_MoveType_CODE, @Lc_FcrNcoaLocCur_Normalization_CODE, @Ls_FcrNcoaLocCur_Line1_ADDR, @Ls_FcrNcoaLocCur_Line2_ADDR, @Lc_FcrNcoaLocCur_City_ADDR, @Lc_FcrNcoaLocCur_State_ADDR, @Lc_FcrNcoaLocCur_Zip_ADDR, @Lc_FcrNcoaLocCur_Process_INDC;

   SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;

   -- Process the records with the cursor in the loop 
   WHILE @Li_FetchStatus_QNTY = 0
    BEGIN
    BEGIN TRY
     SAVE TRANSACTION SAVENCOA_DETAILS;
     
     --  UNKNOWN EXCEPTION IN BATCH
     SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
     SET @Lc_TypeError_CODE = @Lc_Space_TEXT;
     IF ISNUMERIC (@Lc_FcrNcoaLocCur_MemberMciIdno_TEXT) = 1
		BEGIN
			SET @Ln_FcrNcoaLocCur_MemberMci_IDNO = @Lc_FcrNcoaLocCur_MemberMciIdno_TEXT;
		END
	 ELSE
		BEGIN 
			SET @Ln_FcrNcoaLocCur_MemberMci_IDNO = @Ln_Zero_NUMB;
		END
		
     SET @Ln_Cur_QNTY = @Ln_Cur_QNTY + 1;
     SET @Ls_CursorLoc_TEXT = 'MemberSsn_NUMB: ' + ISNULL(@Lc_FcrNcoaLocCur_MemberSsnNumb_TEXT, '') + ' MemberMci_IDNO: ' + ISNULL(CAST(@Ln_FcrNcoaLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' MemberFirst_NAME: ' + ISNULL(@Lc_FcrNcoaLocCur_First_NAME, '') + ' MemberLast_NAME: ' + ISNULL(@Lc_FcrNcoaLocCur_Last_NAME, '') + ' CURSOR_COUNT: ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), '');
     SET @Ls_BateRecord_TEXT = ' Rec_ID = ' + ISNULL(@Lc_FcrNcoaLocCur_Rec_ID, '') + ', StateFips_CODE = ' + ISNULL(@Lc_FcrNcoaLocCur_StateFips_CODE, '') + ', First_NAME = ' + ISNULL(@Lc_FcrNcoaLocCur_First_NAME, '') + ', Middle_NAME = ' + ISNULL(@Lc_FcrNcoaLocCur_Middle_NAME, '') + ', Last_NAME = ' + ISNULL(@Lc_FcrNcoaLocCur_Last_NAME, '') + ', SubmittedLine1_ADDR = ' + ISNULL(@Lc_FcrNcoaLocCur_SubLine1_ADDR, '') + ', SubmittedLine2_ADDR = ' + ISNULL(@Lc_FcrNcoaLocCur_SubLine2_ADDR, '') + ', SubmittedCity_ADDR = ' + ISNULL (@Lc_FcrNcoaLocCur_SubCity_ADDR, '') + ', SubmittedState_ADDR = ' + ISNULL(@Lc_FcrNcoaLocCur_SubSt_ADDR, '') + ', SubmittedZip_ADDR = ' + ISNULL (@Lc_FcrNcoaLocCur_SubZip_ADDR, '') + ', MemberSsn_NUMB = ' + ISNULL(@Lc_FcrNcoaLocCur_MemberSsnNumb_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNcoaLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', NcoaResponse_CODE = ' + ISNULL(@Lc_FcrNcoaLocCur_NcoaResponse_CODE, '') + ', NcoaReturnLine1_ADDR = ' + ISNULL(@Ls_FcrNcoaLocCur_ReturnLine1_ADDR, '') + ', NcoaReturnLine2_ADDR = ' + ISNULL (@Ls_FcrNcoaLocCur_ReturnLine2_ADDR, '') + ', NcoaReturnCity_ADDR = ' + ISNULL(@Lc_FcrNcoaLocCur_ReturnCity_ADDR, '') + ', NcoaReturnSt_ADDR = ' + ISNULL (@Lc_FcrNcoaLocCur_ReturnSt_ADDR, '') + ', NcoaReturnZip_ADDR = ' + ISNULL(@Lc_FcrNcoaLocCur_ReturnZip_ADDR, '') + ', NcoaNewReturn_CODE = ' + ISNULL (@Lc_FcrNcoaLocCur_NewReturn_CODE, '') + ', NcoaAddrChangeEff_DATE = ' + ISNULL (@Lc_FcrNcoaLocCur_AddressChangeEff_DATE, '') + ', NcoaMoveType_CODE = ' + ISNULL (@Lc_FcrNcoaLocCur_MoveType_CODE, '') + ', NcoaNormalization_CODE = ' + ISNULL(@Lc_FcrNcoaLocCur_Normalization_CODE, '');
          
     SET @Ln_Exists_NUMB = 0;
     SET @Ls_Sql_TEXT = 'CHECK FOR EXISTANCE OF MemberMci_IDNO IN CMEM_Y1';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNcoaLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ' CaseMemberStatus_CODE = A';
       
     --check for existance of member MCI number 
     SELECT @Ln_Exists_NUMB = COUNT(1)
       FROM CMEM_Y1 c
      WHERE c.MemberMci_IDNO = @Ln_FcrNcoaLocCur_MemberMci_IDNO
        AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE;

     -- Member record not found to process                  
     IF @Ln_Exists_NUMB = 0
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0907_CODE;

       GOTO lx_exception;
      END

     SET @Ls_Sql_TEXT = 'PROCESS NCOA RECORD';
     SET @Ls_Sqldata_TEXT = 'MemberSsn_NUMB = ' + ISNULL(@Lc_FcrNcoaLocCur_MemberSsnNumb_TEXT, '') + ', MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNcoaLocCur_MemberMci_IDNO AS VARCHAR(10)), 0) + ', MemberFirst_NAME = ' + ISNULL(@Lc_FcrNcoaLocCur_First_NAME, '') + ', MemberLast_NAME = ' + ISNULL(@Lc_FcrNcoaLocCur_Last_NAME, '') + ', CURSOR_COUNT = ' + ISNULL(CAST(@Ln_Cur_QNTY AS VARCHAR(10)), '');
        
     -- Do not process ncoa record if CP and NCP/PF medical coverage indicator is N
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse01_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1368_CODE;

       GOTO lx_exception;
      END

     -- Invalid verification request or stat code 
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse02_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1369_CODE;

       GOTO lx_exception;
      END

     -- Invalid ssn    
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse03_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0019_CODE;

       GOTO lx_exception;
      END

     -- Invalid member name     
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse04_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorTE019_CODE;

       GOTO lx_exception;
      END

     --Invalid address     
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse05_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE0606_CODE;

       GOTO lx_exception;
      END

     --Member not registered on IV-D case     
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse06_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1370_CODE;

       GOTO lx_exception;
      END

     --No match found at ncoa     
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse10_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1371_CODE;

       GOTO lx_exception;
      END

     -- Address not available at ncoa     
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse28_CODE
      BEGIN
       
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1372_CODE;

       GOTO lx_exception;
      END

     -- Disclosure prohibited /FV indicator set     
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_NcoaResponse39_CODE
      BEGIN
        
       SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE;
       SET @Lc_BateError_CODE = @Lc_ErrorE1381_CODE;

       GOTO lx_exception;
      END

     SET @Ln_MemberMci_IDNO = @Ln_FcrNcoaLocCur_MemberMci_IDNO;

     -- Check the NCOA response code is spaces,ncoa new return code is 'A', move type is individual or family and address line1 not spaces  
     IF @Lc_FcrNcoaLocCur_NcoaResponse_CODE = @Lc_Space_TEXT
        AND @Lc_FcrNcoaLocCur_NewReturn_CODE = @Lc_NcoaReturn_CODE
        AND @Lc_FcrNcoaLocCur_MoveType_CODE IN (@Lc_MoveTypeInd_CODE, @Lc_MoveTypeFam_CODE)
        AND @Ls_FcrNcoaLocCur_Line1_ADDR <> ' '
      BEGIN
      
       EXECUTE BATCH_COMMON$SP_ADDRESS_UPDATE
        @An_MemberMci_IDNO                   = @Ln_MemberMci_IDNO,
        @Ad_Run_DATE                         = @Ad_Run_DATE,
        @Ac_TypeAddress_CODE                 = @Lc_TypeAddressM_CODE,
        @Ad_Begin_DATE                       = @Ad_Run_DATE,
        @Ad_End_DATE                         = @Ld_High_DATE,
        @Ac_Attn_ADDR                        = @Lc_Space_TEXT,
        @As_Line1_ADDR                       = @Ls_FcrNcoaLocCur_Line1_ADDR,
        @As_Line2_ADDR                       = @Ls_FcrNcoaLocCur_Line2_ADDR,
        @Ac_City_ADDR                        = @Lc_FcrNcoaLocCur_City_ADDR,
        @Ac_State_ADDR                       = @Lc_FcrNcoaLocCur_State_ADDR,
        @Ac_Zip_ADDR                         = @Lc_FcrNcoaLocCur_Zip_ADDR,
        @Ac_Country_ADDR                     = @Lc_Space_TEXT,
        @An_Phone_NUMB                       = @Ln_Zero_NUMB,
        @Ac_SourceLoc_CODE                   = @Lc_LocateSourceNca_CODE,
        @Ad_SourceReceived_DATE              = @Ad_Run_DATE,
        @Ad_Status_DATE                      = @Ad_Run_DATE,
        @Ac_Status_CODE                      = @Lc_VerificationStatusGood_CODE,
        @Ac_SourceVerified_CODE              = @Lc_Space_TEXT,
        @As_DescriptionComments_TEXT         = @Lc_Space_TEXT,
        @As_DescriptionServiceDirection_TEXT = @Lc_Space_TEXT,
        @Ac_Process_ID                       = @Lc_ProcessFcrNcoa_ID,
        @Ac_SignedonWorker_ID                = @Lc_BatchRunUser_TEXT,
        @An_TransactionEventSeq_NUMB         = @Ln_Zero_NUMB,
        @An_OfficeSignedOn_IDNO              = @Ln_Zero_NUMB,
        @Ac_Normalization_CODE               = @Lc_FcrNcoaLocCur_Normalization_CODE,
        @Ac_Msg_CODE                         = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT            = @Ls_DescriptionError_TEXT OUTPUT;

       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
		  BEGIN
			SET @Lc_TypeError_CODE= @Lc_ErrorTypeError_CODE ;
			SET @Lc_BateError_CODE = @Lc_BateErrorE1424_CODE;
			RAISERROR (50001,16,1);
		  END
		 ELSE IF @Lc_Msg_CODE <> @Lc_StatusSuccess_CODE
		      AND @Lc_Msg_CODE <> @Lc_ErrorE1089_CODE
			   BEGIN
				SET @Lc_TypeError_CODE = @Lc_ErrorTypeError_CODE; 
				SET @Lc_BateError_CODE = @Lc_Msg_CODE;
				RAISERROR (50001,16,1);
			   END
		END
	   
     LX_EXCEPTION:;

     -- Check the any errors for writing into the BATE_Y1 table 
     IF @Lc_TypeError_CODE IN ('E', 'F')
      BEGIN
      
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG-3';
       SET @Ls_Sqldata_TEXT = 'Job_IDNO = ' + ISNULL(@Ac_Job_ID, '');
              
       EXECUTE BATCH_COMMON$SP_BATE_LOG
        @As_Process_NAME             = @As_Process_NAME,
        @As_Procedure_NAME           = @Ls_Procedure_NAME,
        @Ac_Job_ID                   = @Ac_Job_ID,
        @Ad_Run_DATE                 = @Ad_Run_DATE,
        @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
        @An_Line_NUMB                = @Ln_Cur_QNTY,
        @Ac_Error_CODE               = @Lc_BateError_CODE,
        @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
        @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
        @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
      
       -- check the update failed 
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'INSERT INTO BATE 11 FAILED FOR ';

         RAISERROR(50001,16,1);
        END
        
       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
         BEGIN  
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		 END 
      END

     END TRY
     BEGIN CATCH
	 BEGIN 
		SET @Ls_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT;
		
        -- Committable transaction checking and Rolling back Savepoint
		IF XACT_STATE() = 1
	    BEGIN
	   	   ROLLBACK TRANSACTION SAVENCOA_DETAILS;
		END
		ELSE
		BEGIN
		    SET @Ls_ErrorMessage_TEXT = @Ls_ErrorMessage_TEXT + '' + SUBSTRING (ERROR_MESSAGE (), 1, 200);
			RAISERROR( 50001 ,16,1);
		END
        SET @Ln_Error_NUMB = ERROR_NUMBER ();
        SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
	   
        IF @Ln_Error_NUMB <> 50001
         BEGIN
          SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
         END
        
        EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
         @As_Procedure_NAME        = @Ls_Procedure_NAME,
         @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
         @As_Sql_TEXT              = @Ls_Sql_TEXT,
         @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
         @An_Error_NUMB            = @Ln_Error_NUMB,
         @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
         @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
        SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATE_LOG';
                
        SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@Ln_FcrNcoaLocCur_MemberMci_IDNO AS VARCHAR), 0) ;

        SET @Ls_BateRecord_TEXT = @Ls_BateRecord_TEXT + ', Error Description = ' + @Ls_DescriptionError_TEXT;

        EXECUTE BATCH_COMMON$SP_BATE_LOG
         @As_Process_NAME             = @As_Process_NAME,
         @As_Procedure_NAME           = @Ls_Procedure_NAME,
         @Ac_Job_ID                   = @Ac_Job_ID,
         @Ad_Run_DATE                 = @Ad_Run_DATE,
         @Ac_TypeError_CODE           = @Lc_ErrorTypeError_CODE,
         @An_Line_NUMB                = @Ln_Cur_QNTY,
         @Ac_Error_CODE               = @Lc_BateError_CODE,
         @As_DescriptionError_TEXT    = @Ls_BateRecord_TEXT,
         @As_ListKey_TEXT             = @Ls_Sqldata_TEXT,
         @Ac_Msg_CODE                 = @Lc_Msg_CODE OUTPUT,
         @As_DescriptionErrorOut_TEXT = @Ls_DescriptionError_TEXT OUTPUT;
     
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       IF @Lc_Msg_CODE = @Lc_ErrorTypeError_CODE
		BEGIN 
			SET @Ln_ExceptionThreshold_QNTY = @Ln_ExceptionThreshold_QNTY + 1;
		END
      END
     END CATCH
     
     SET @Ln_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY + 1 ;
     SET @Ln_CommitFreq_QNTY = @Ln_CommitFreq_QNTY + 1;

     SET @Ls_Sql_TEXT = 'UPDATE LFNCA_Y1';
     SET @Ls_Sqldata_TEXT = 'Seq_IDNO = ' + ISNULL(CAST(@Ln_FcrNcoaLocCur_Seq_IDNO AS VARCHAR), '');

     UPDATE LFNCA_Y1
        SET Process_INDC = @Lc_ProcessY_INDC
      WHERE Seq_IDNO = @Ln_FcrNcoaLocCur_Seq_IDNO;

     SET @Li_RowCount_QNTY = @@ROWCOUNT;

     -- check the update failed
     IF @Li_RowCount_QNTY = 0
      BEGIN
       SET @Ls_ErrorMessage_TEXT = 'UPDATE FAILED LFNCA_Y1';

       RAISERROR(50001,16,1);
      END

     SET @Ls_Sql_TEXT = 'COMMIT FREQUENCY CHECK';
     SET @Ls_Sqldata_TEXT = 'RECORD COMMIT COUNT = ' + ISNULL(CAST(@An_CommitFreq_QNTY AS VARCHAR(10)), '');
     
     -- Check the commit frequecny with the number records processed in the batch for commit
     IF @An_CommitFreq_QNTY <> 0
        AND @Ln_CommitFreq_QNTY >= @An_CommitFreq_QNTY
      BEGIN
       SET @Ls_Sql_TEXT = 'BATCH_COMMON$SP_BATCH_RESTART_UPDATE';
       SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
       
       EXECUTE BATCH_COMMON$SP_BATCH_RESTART_UPDATE
        @Ac_Job_ID                = @Ac_Job_ID,
        @Ad_Run_DATE              = @Ad_Run_DATE,
        @As_RestartKey_TEXT       = @Ln_Cur_QNTY,
        @Ac_Msg_CODE              = @Lc_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

       -- check the restart sp update status
       IF @Lc_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         SET @Ls_ErrorMessage_TEXT = 'BATCH RESTART UPDATE FAILED ';

         RAISERROR(50001,16,1);
        END

       COMMIT TRANSACTION NCOA_DETAILS; 
       BEGIN TRANSACTION NCOA_DETAILS; 
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ln_CommitFreq_QNTY = 0;
      END

     SET @Ls_Sql_TEXT = 'EXCEPTION THRESHOLD CHECK ';
     SET @Ls_Sqldata_TEXT = 'REACHED EXCEPTION THRESHOLD = ' + ISNULL(CAST(@An_ExceptionThreshold_QNTY AS VARCHAR(10)), '');

     -- check the exception count in the batch with the allowed exception count before stopping the batch
     IF @Ln_ExceptionThreshold_QNTY > @An_ExceptionThreshold_QNTY
      BEGIN
       COMMIT TRANSACTION NCOA_DETAILS;
       SET @Ln_ProcessedRecordCountCommit_QNTY = @Ln_ProcessedRecordCountCommit_QNTY + @Ln_CommitFreq_QNTY;
       SET @Ls_ErrorMessage_TEXT = 'REACHED EXCEPTION THRESHOLD' + @Lc_Space_Text + ISNULL(@Ls_CursorLoc_TEXT, '');

       RAISERROR(50001,16,1);
      END

     FETCH NEXT FROM FcrNcoaLoc_CUR INTO @Ln_FcrNcoaLocCur_Seq_IDNO, @Lc_FcrNcoaLocCur_Rec_ID, @Lc_FcrNcoaLocCur_Ncoa_INDC, @Lc_FcrNcoaLocCur_StateFips_CODE, @Lc_FcrNcoaLocCur_First_NAME, @Lc_FcrNcoaLocCur_Middle_NAME, @Lc_FcrNcoaLocCur_Last_NAME, @Lc_FcrNcoaLocCur_SubLine1_ADDR, @Lc_FcrNcoaLocCur_SubLine2_ADDR, @Lc_FcrNcoaLocCur_SubCity_ADDR, @Lc_FcrNcoaLocCur_SubSt_ADDR, @Lc_FcrNcoaLocCur_SubZip_ADDR, @Lc_FcrNcoaLocCur_MemberSsnNumb_TEXT, @Lc_FcrNcoaLocCur_MemberMciIdno_TEXT, @Lc_FcrNcoaLocCur_NcoaResponse_CODE, @Ls_FcrNcoaLocCur_ReturnLine1_ADDR, @Ls_FcrNcoaLocCur_ReturnLine2_ADDR, @Lc_FcrNcoaLocCur_ReturnCity_ADDR, @Lc_FcrNcoaLocCur_ReturnSt_ADDR, @Lc_FcrNcoaLocCur_ReturnZip_ADDR, @Lc_FcrNcoaLocCur_NewReturn_CODE, @Lc_FcrNcoaLocCur_AddressChangeEff_DATE, @Lc_FcrNcoaLocCur_MoveType_CODE, @Lc_FcrNcoaLocCur_Normalization_CODE, @Ls_FcrNcoaLocCur_Line1_ADDR, @Ls_FcrNcoaLocCur_Line2_ADDR, @Lc_FcrNcoaLocCur_City_ADDR, @Lc_FcrNcoaLocCur_State_ADDR, @Lc_FcrNcoaLocCur_Zip_ADDR, @Lc_FcrNcoaLocCur_Process_INDC;

     SET @Li_FetchStatus_QNTY = @@FETCH_STATUS;
    END;

   CLOSE FcrNcoaLoc_CUR;

   DEALLOCATE FcrNcoaLoc_CUR;

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
   SET @As_DescriptionError_TEXT = @Lc_Space_TEXT;
   
   -- Transaction ends 
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCount_QNTY;
   SET @Ls_Sql_TEXT = 'COMMIT THE TRASACTION';
   SET @Ls_Sqldata_TEXT = 'Job_ID = ' + ISNULL(@Ac_Job_ID, '');
  
   COMMIT TRANSACTION NCOA_DETAILS;
  END TRY

  BEGIN CATCH
   
   SET @An_ProcessedRecordCount_QNTY = @Ln_ProcessedRecordCountCommit_QNTY;

   -- Check for any updates in batch for rollback
   IF @@TRANCOUNT > 0
    BEGIN
     ROLLBACK TRANSACTION NCOA_DETAILS;
    END;
    
   -- set the status as failed 
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   -- Check the cursor is open, close and deallocate the cursor
   IF CURSOR_STATUS ('local', 'FcrNcoaLoc_CUR') IN (0, 1)
    BEGIN
     CLOSE FcrNcoaLoc_CUR;

     DEALLOCATE FcrNcoaLoc_CUR;
    END;

   --Set Error Description
   SET @Ln_Error_NUMB = ERROR_NUMBER ();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE ();
  
   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @Ls_ErrorMessage_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_ErrorMessage_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
  
  END CATCH;
 END;


GO
