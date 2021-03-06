/****** Object:  StoredProcedure [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_ADDITIONAL_INFO_DESC]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CI_OUTGOING_CSENET_FILE$SP_ADDITIONAL_INFO_DESC
Programmer Name	:	IMP Team.
Description		:	This procedure is used to update the pending request table based on the status for the appropriate scenario.
Frequency		:	DAILY
Developed On	:	04/04/2011
Called By		:	BATCH_CI_OUTGOING_CSENET_FILE$SP_CSENET_INIT_TRAN
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CI_OUTGOING_CSENET_FILE$SP_ADDITIONAL_INFO_DESC]
 @An_Request_IDNO          NUMERIC(12),
 @Ac_Function_CODE         CHAR(3),
 @Ac_Action_CODE           CHAR(1),
 @Ac_Reason_CODE           CHAR(5),
 @Ad_Run_DATE              DATE,
 @An_MemberMci_IDNO        NUMERIC(10),
 @As_Information_TEXT      VARCHAR(400) OUTPUT,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusSuccess_CODE CHAR(1) = 'S',
          @Lc_StatusFailed_CODE  CHAR(1) = 'F',
          @Ls_Procedure_NAME     VARCHAR(100) = 'BATCH_CI_OUTGOING_CSENET_FILE$SP_ADDITIONAL_INFO_DESC',
          @Ls_Sql_TEXT           VARCHAR(400) = ' ',
          @Ls_Sqldata_TEXT       VARCHAR(4000) = ' ';
  DECLARE @Ln_EmployerPhone_NUMB    NUMERIC(10),
          @Ln_HomePhone_NUMB        NUMERIC(15),
          @Li_Error_NUMB            INT,
          @Li_ErrorLine_NUMB        INT,
          @Li_FetchStatus_NUMB      INT,
          @Lc_ResidentialState_ADDR CHAR(2),
          @Lc_EmployerState_ADDR    CHAR(2),
          @Lc_ResidentialZip_ADDR   CHAR(9),
          @Lc_EmployerEin_ID        CHAR(9),
          @Lc_EmployerZip_ADDR      CHAR(9),
          @Lc_ResidentialCity_ADDR  CHAR(18),
          @Lc_EmployerCity_ADDR     CHAR(18),
          @Lc_ResidentialLine1_ADDR CHAR(25),
          @Lc_ResidentialLine2_ADDR CHAR(25),
          @Lc_EmployerLine1_ADDR    CHAR(25),
          @Lc_EmployerLine2_ADDR    CHAR(25),
          @Ls_Full_NAME             VARCHAR(53),
          @Ls_Employer_NAME         VARCHAR(60),
          @Ls_AdditionalInfo_TEXT   VARCHAR(400) = '',
          @Ls_DescriptionError_TEXT VARCHAR(4000),
          @Ld_Deceased_DATE         DATE,
          @Ld_Information_DATE      DATE;
  DECLARE @Ls_NoticeCur_DescriptionNotice_TEXT VARCHAR(100);

  BEGIN TRY
   SET @Ls_Sql_TEXT = 'ADDITIONAL INFORMATION';

   IF (@Ac_Function_CODE = 'COL'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'CITAX')
    BEGIN
     -- TODO - Need to find out Tax Offset
     -- SET @Ls_AdditionalInfo_TEXT = 'A Tax Offset IN the amount OF $XXX.XX has been disbursed.  Please adjust the NCP''s balance accordingly.';
     SET @Ls_AdditionalInfo_TEXT = '';
    END;
   ELSE IF ((@Ac_Function_CODE = 'ENF'
         OR @Ac_Function_CODE = 'EST'
         OR @Ac_Function_CODE = 'PAT')
       AND @Ac_Action_CODE = 'A'
       AND @Ac_Reason_CODE = 'AADIN')
    BEGIN
     DECLARE Notice_CUR INSENSITIVE CURSOR FOR
      SELECT b.DescriptionNotice_TEXT
        FROM CAIN_Y1 a
             JOIN NREF_Y1 b
              ON a.Notice_ID = b.Notice_ID
       WHERE a.TransHeader_IDNO = @An_Request_IDNO
         AND a.Received_INDC = 'N'
         AND a.Transaction_DATE = @Ad_Run_DATE;

     SET @Ls_Sql_TEXT = 'OPEN Notice_CUR';

     OPEN Notice_CUR;

     SET @Ls_Sql_TEXT = 'FETCH Notice_CUR - 1';

     FETCH NEXT FROM Notice_CUR INTO @Ls_NoticeCur_DescriptionNotice_TEXT;

     SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;

     -- CONCAT the Notice description
     WHILE (@Li_FetchStatus_NUMB = 0)
      BEGIN
       IF (@Ls_AdditionalInfo_TEXT <> '')
        BEGIN
         SET @Ls_AdditionalInfo_TEXT = @Ls_AdditionalInfo_TEXT + ', ';
        END;

       SET @Ls_AdditionalInfo_TEXT = @Ls_AdditionalInfo_TEXT + @Ls_NoticeCur_DescriptionNotice_TEXT;
       SET @Ls_Sql_TEXT = 'FETCH Notice_CUR - 2';

       FETCH NEXT FROM Notice_CUR INTO @Ls_NoticeCur_DescriptionNotice_TEXT;

       SET @Li_FetchStatus_NUMB = @@FETCH_STATUS;
      END;

     IF CURSOR_STATUS('Local', 'Notice_CUR') IN (0, 1)
      BEGIN
       CLOSE Notice_CUR;

       DEALLOCATE Notice_CUR;
      END;

     SET @Ls_AdditionalInfo_TEXT = 'Additional documentation is required before we can proceed: ' + @Ls_AdditionalInfo_TEXT;
    END;
   ELSE IF (@Ac_Function_CODE = 'ENF'
       AND @Ac_Action_CODE = 'M'
       AND @Ac_Reason_CODE = 'GRPOU')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'A CASE has been created FROM the CSENet Referral but we have NOT received the required paperwork TO proceed.  Please send the required paperwork. ';
    END;
   ELSE IF (@Ac_Function_CODE = 'ENF'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'ESORD')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Two copies (one certified) OF the new ORDER will be sent TO you shortly.';
    END;
   ELSE IF (@Ac_Function_CODE = 'EST'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'SIANS')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'The NCP did NOT show FOR the support ORDER hearing.';
    END;
   ELSE IF ((@Ac_Function_CODE = 'EST'
        AND @Ac_Action_CODE = 'P'
        AND @Ac_Reason_CODE = 'SICHS')
        OR (@Ac_Function_CODE = 'PAT'
            AND @Ac_Action_CODE = 'P'
            AND @Ac_Reason_CODE = 'PICHS'))
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT ETHBL_Y1.ActionResolution_DATE';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_Request_IDNO AS VARCHAR), '');

     SELECT @Ld_Information_DATE = a.ActionResolution_DATE
       FROM ETHBL_Y1 a
      WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR);

     SET @Ls_AdditionalInfo_TEXT = 'A hearing has been scheduled IN Delaware ON ' + CONVERT(VARCHAR(10), @Ld_Information_DATE, 101);
    END;
   ELSE IF (@Ac_Function_CODE = 'EST'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'SSCON')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'ORDER Issued/confirmed';
    END;
   ELSE IF (@Ac_Function_CODE = 'EST'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'SSEST')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Support ORDER Established. Two copies (one certified) will be sent TO you shortly.';
    END;
   ELSE IF (@Ac_Function_CODE = 'EST'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'SSMOD')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Support ORDER Modified. Two copies (one certified) will be sent TO you shortly.';
    END;
   ELSE IF (@Ac_Function_CODE = 'PAT'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'PIBTS')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'The Genetic Test has been scheduled.';
    END;
   ELSE IF (@Ac_Function_CODE = 'PAT'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'PIHNS')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Putative father did NOT show FOR paternity court hearing';
    END;
   ELSE IF (@Ac_Function_CODE = 'PAT'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'PIPNS')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Putative father did NOT show FOR genetic test';
    END;
   ELSE IF (@Ac_Function_CODE = 'PAT'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'PIPUD')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Putative father has denied paternity';
    END;
   ELSE IF (@Ac_Function_CODE = 'PAT'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'PSESO')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Paternity established with support ORDER. Two copies OF the Support ORDER (one certified copy) will be sent TO you shortly. ';
    END;
   ELSE IF (@Ac_Function_CODE = 'PAT'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'PSEST')
    BEGIN
     SET @Ls_AdditionalInfo_TEXT = 'Paternity established no support ORDER.';
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'LSADR')
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT ENBLK_Y1.Full_NAME';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_Request_IDNO AS VARCHAR), '');

     SELECT @Ls_Full_NAME = a.First_NAME + ' ' + a.Middle_NAME + ' ' + a.Last_NAME
       FROM ENBLK_Y1 a
      WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR);

     SET @Ls_Sql_TEXT = 'SELECT Residential Address';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_Request_IDNO AS VARCHAR), '');

     SELECT @Lc_ResidentialLine1_ADDR = a.ResidentialLine1_ADDR,
            @Lc_ResidentialLine2_ADDR = a.ResidentialLine2_ADDR,
            @Lc_ResidentialCity_ADDR = a.ResidentialCity_ADDR,
            @Lc_ResidentialState_ADDR = a.ResidentialState_ADDR,
            @Lc_ResidentialZip_ADDR = a.ResidentialZip1_ADDR + a.ResidentialZip2_ADDR,
            @Ln_HomePhone_NUMB = a.HomePhone_NUMB
       FROM ENLBL_Y1 a
      WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR)
        AND a.ResidentialConfirmed_CODE = 'Y';

     SET @Ls_AdditionalInfo_TEXT = 'Confirmed Address FOR NCP IS: ' + @Ls_Full_NAME + ' ' + @Lc_ResidentialLine1_ADDR + ' ' + @Lc_ResidentialLine2_ADDR + ' ' + @Lc_ResidentialCity_ADDR + ' ' + @Lc_ResidentialState_ADDR + ' ' + @Lc_ResidentialZip_ADDR + ' ' + CAST(@Ln_HomePhone_NUMB AS VARCHAR);
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'LSEMP')
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT Employer Details';
     SET @Ls_Sqldata_TEXT = 'TransHeader_IDNO = ' + ISNULL(CAST(@An_Request_IDNO AS VARCHAR), '');

     SELECT @Lc_EmployerEin_ID = a.EmployerEin_ID,
            @Ls_Employer_NAME = a.Employer_NAME,
            @Lc_EmployerLine1_ADDR = a.EmployerLine1_ADDR,
            @Lc_EmployerLine2_ADDR = a.EmployerLine2_ADDR,
            @Lc_EmployerCity_ADDR = a.EmployerCity_ADDR,
            @Lc_EmployerState_ADDR = a.EmployerState_ADDR,
            @Lc_EmployerZip_ADDR = a.EmployerZip1_ADDR + a.EmployerZip2_ADDR,
            @Ln_EmployerPhone_NUMB = a.EmployerPhone_NUMB
       FROM ENLBL_Y1 a
      WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR)
        AND a.EmployerConfirmed_INDC = 'Y';

     SET @Ls_AdditionalInfo_TEXT = 'Confirmed Employer for NCP IS: ' + @Lc_EmployerEin_ID + ' ' + @Ls_Employer_NAME + ' ' + @Lc_EmployerLine1_ADDR + ' ' + @Lc_EmployerLine2_ADDR + ' ' + @Lc_EmployerCity_ADDR + ' ' + @Lc_EmployerState_ADDR + ' ' + @Lc_EmployerZip_ADDR + ' ' + CAST(@Ln_EmployerPhone_NUMB AS VARCHAR);
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'LSOUT')
    BEGIN
     IF EXISTS (SELECT 1
                  FROM ENLBL_Y1 a
                 WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR)
                   AND a.ResidentialConfirmed_CODE = 'Y')
      BEGIN
       SELECT @Lc_ResidentialLine1_ADDR = a.ResidentialLine1_ADDR,
              @Lc_ResidentialLine2_ADDR = a.ResidentialLine2_ADDR,
              @Lc_ResidentialCity_ADDR = a.ResidentialCity_ADDR,
              @Lc_ResidentialState_ADDR = a.ResidentialState_ADDR,
              @Lc_ResidentialZip_ADDR = a.ResidentialZip1_ADDR + a.ResidentialZip2_ADDR
         FROM ENLBL_Y1 a
        WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR)
          AND a.ResidentialConfirmed_CODE = 'Y';
      END
     ELSE IF EXISTS (SELECT 1
                  FROM ENLBL_Y1 a
                 WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR)
                   AND a.MailingConfirmed_CODE = 'Y')
      BEGIN
       SELECT @Lc_ResidentialLine1_ADDR = a.MailingLine1_ADDR,
              @Lc_ResidentialLine2_ADDR = a.MailingLine2_ADDR,
              @Lc_ResidentialCity_ADDR = a.MailingCity_ADDR,
              @Lc_ResidentialState_ADDR = a.MailingState_ADDR,
              @Lc_ResidentialZip_ADDR = a.MailingZip1_ADDR + a.MailingZip2_ADDR
         FROM ENLBL_Y1 a
        WHERE a.TransHeader_IDNO = CAST(@An_Request_IDNO AS VARCHAR)
          AND a.MailingConfirmed_CODE = 'Y';
      END

     SET @Ls_AdditionalInfo_TEXT = 'NCP is not confirmed to be working in Delaware and NCP is Confirmed to be residing outside of Delaware.  NCP confirmed address is:  ' + @Lc_ResidentialLine1_ADDR + ' ' + @Lc_ResidentialLine2_ADDR + ' ' + @Lc_ResidentialCity_ADDR + ' ' + @Lc_ResidentialState_ADDR + ' ' + @Lc_ResidentialZip_ADDR;
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'LUAPD')
    BEGIN
     SET @Ls_Sql_TEXT = 'SELECT DEMO_Y1.Deceased_DATE';
     SET @Ls_Sqldata_TEXT = 'MemberMci_IDNO = ' + ISNULL(CAST(@An_MemberMci_IDNO AS VARCHAR), '');

     SELECT @Ld_Deceased_DATE = a.Deceased_DATE
       FROM DEMO_Y1 a
      WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO;

     SET @Ls_AdditionalInfo_TEXT = 'NCP found - deceased.  Deceased Date is ' + CONVERT(VARCHAR(10), @Ld_Deceased_DATE, 101);
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'GSADD')
    BEGIN
     SELECT @Ls_AdditionalInfo_TEXT = COALESCE(@Ls_AdditionalInfo_TEXT, '') + RTRIM(a.MemberMci_IDNO) + ' has been added as a ' + CASE
                                                                                                                                   WHEN a.CaseRelationShip_CODE = 'C'
                                                                                                                                    THEN 'CP'
                                                                                                                                   WHEN a.CaseRelationShip_CODE = 'D'
                                                                                                                                    THEN 'Dependent'
                                                                                                                                   WHEN a.CaseRelationShip_CODE IN ('A', 'P')
																																    THEN 'NCP'
                                                                                                                                  END + ' on Delaware IV-D Case. '
       FROM CMEM_Y1 a,
            CSPR_Y1 c
      WHERE a.Case_IDNO = c.Case_IDNO
        AND a.BeginValidity_DATE = c.Generated_DATE
        AND c.Request_IDNO = @An_Request_IDNO
        AND a.CaseMemberStatus_CODE = 'A';
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'GSDEL')
    BEGIN
     SELECT @Ls_AdditionalInfo_TEXT = COALESCE(@Ls_AdditionalInfo_TEXT, '') + RTRIM(a.MemberMci_IDNO) + ' has been inactivated as a ' + CASE
                                                                                                                                         WHEN a.CaseRelationShip_CODE = 'C'
                                                                                                                                          THEN 'CP'
                                                                                                                                         WHEN a.CaseRelationShip_CODE = 'D'
                                                                                                                                          THEN 'Dependent'
                                                                                                                                         WHEN a.CaseRelationShip_CODE IN ('A', 'P')
																																		  THEN 'NCP'
                                                                                                                                        END + ' on Delaware IV-D Case. '
       FROM CMEM_Y1 a,
            CSPR_Y1 c
      WHERE a.Case_IDNO = c.Case_IDNO
        AND a.BeginValidity_DATE = c.Generated_DATE
        AND c.Request_IDNO = @An_Request_IDNO
        AND a.CaseMemberStatus_CODE = 'I';
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'GSFIP')
    BEGIN
     SELECT @Ls_AdditionalInfo_TEXT = COALESCE(@Ls_AdditionalInfo_TEXT, '') + 'Delaware FIPS has changed from 10' + RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(h.County_IDNO)), 3) + '00 to 10' + RIGHT(REPLICATE('0', 3) + LTRIM(RTRIM(a.County_IDNO)), 3) + '00. '
       FROM CASE_Y1 a,
            CSPR_Y1 c,
            HCASE_Y1 h
      WHERE a.Case_IDNO = c.Case_IDNO
        AND a.BeginValidity_DATE = c.Generated_DATE
        AND a.BeginValidity_DATE = h.EndValidity_DATE
        AND c.Request_IDNO = @An_Request_IDNO
        AND a.Case_IDNO = h.Case_IDNO
        AND a.County_IDNO != h.County_IDNO;
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'GSMAD')
    BEGIN
     SELECT @Ls_AdditionalInfo_TEXT = COALESCE(@Ls_AdditionalInfo_TEXT, '') + 'Medical Insurance has been added for Dependent ' + CAST(d.childMCI_IDNO AS VARCHAR) + '. ' + LTRIM(RTRIM(o.OtherParty_NAME)) + ', ' + LTRIM(RTRIM(o.Line1_ADDR)) + ', ' + LTRIM(RTRIM(o.Line2_ADDR)) + ', ' + LTRIM(RTRIM(o.City_ADDR)) + ', ' + LTRIM(RTRIM(o.State_ADDR)) + ', ' + LTRIM(RTRIM(o.Zip_ADDR)) + ', ' + CAST(o.Phone_NUMB AS VARCHAR)
       FROM CSPR_Y1 R,
            CMEM_Y1 c,
            MINS_Y1 m,
            DINS_Y1 d,
            OTHP_Y1 o
      WHERE r.Request_IDNO = @An_Request_IDNO
        AND c.Case_IDNO = r.Case_IDNO
        AND c.CaseRelationship_CODE IN ('A', 'P')
        AND c.CaseMemberStatus_CODE = 'A'
        AND m.OthpInsurance_IDNO = o.OtherParty_IDNO
        AND o.EndValidity_DATE = r.EndValidity_DATE
        AND m.MemberMci_IDNO = c.MemberMci_IDNO
        AND M.EndValidity_DATE = r.EndValidity_DATE
        AND M.End_DATE > r.Generated_DATE
        AND M.Begin_DATE = r.Generated_DATE
        AND o.TypeOthp_CODE = 'I'
        AND d.MemberMci_IDNO = m.MemberMci_IDNO
        AND d.OthpInsurance_IDNO = m.OthpInsurance_IDNO
        AND d.EndValidity_DATE = m.EndValidity_DATE
        AND d.End_DATE = m.End_DATE
        AND d.Begin_DATE = m.Begin_DATE;
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'GSMDE')
    BEGIN
     SELECT @Ls_AdditionalInfo_TEXT = COALESCE(@Ls_AdditionalInfo_TEXT, '') + 'Medical Insurance has been deleted for Dependent ' + CAST(d.childMCI_IDNO AS VARCHAR) + '. '
       FROM CSPR_Y1 R,
            CMEM_Y1 c,
            MINS_Y1 m,
            DINS_Y1 d,
            OTHP_Y1 o
      WHERE r.Request_IDNO = @An_Request_IDNO
        AND c.Case_IDNO = r.Case_IDNO
        AND c.CaseRelationship_CODE IN ('A', 'P')
        AND c.CaseMemberStatus_CODE = 'A'
        AND m.OthpInsurance_IDNO = o.OtherParty_IDNO
        AND o.EndValidity_DATE = r.EndValidity_DATE
        AND m.MemberMci_IDNO = c.MemberMci_IDNO
        AND M.EndValidity_DATE = r.EndValidity_DATE
        AND M.End_DATE <= r.Generated_DATE
        AND o.TypeOthp_CODE = 'I'
        AND d.MemberMci_IDNO = m.MemberMci_IDNO
        AND d.OthpInsurance_IDNO = m.OthpInsurance_IDNO
        AND d.EndValidity_DATE = m.EndValidity_DATE
        AND d.End_DATE = m.End_DATE
        AND d.Begin_DATE = m.Begin_DATE;
    END;
   ELSE IF (@Ac_Function_CODE = 'MSC'
       AND @Ac_Action_CODE = 'P'
       AND @Ac_Reason_CODE = 'GSPAD')
    BEGIN
     SELECT @Ls_AdditionalInfo_TEXT = 'Change of Mailing Address for Delaware SDU, ' + LTRIM(RTRIM(f.Line1_ADDR)) + ', ' + LTRIM(RTRIM(f.Line2_ADDR)) + ', ' + LTRIM(RTRIM(f.City_ADDR)) + ', ' + LTRIM(RTRIM(f.State_ADDR)) + ', ' + LTRIM(RTRIM(f.Zip_ADDR))
       FROM FIPS_Y1 f
      WHERE f.StateFips_CODE = '10'
        AND f.EndValidity_DATE = '9999-12-31'
        AND f.TypeAddress_CODE = 'STA'
        AND f.SubTypeAddress_CODE = 'SDU';
    END;

   SET @As_Information_TEXT = @Ls_AdditionalInfo_TEXT;
   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS('Local', 'Notice_CUR') IN (0, 1)
    BEGIN
     CLOSE Notice_CUR;

     DEALLOCATE Notice_CUR;
    END;

   SET @Li_Error_NUMB = ERROR_NUMBER();
   SET @Li_ErrorLine_NUMB = ERROR_LINE();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING(ERROR_MESSAGE(), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH;
 END;


GO
